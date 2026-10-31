--[[
    ComboTracker - server-side controller for the combo / streak HUD panel (singleton, like Notifications).

    Usage:
        require("libraries.combo_tracker")   -- the file calls ComboTracker:Init() at the bottom

        ComboTracker:Configure({
            anchor   = "bottom_left",  -- see ComboTracker.ANCHORS, or { x = 10, y = 70 } (% of screen)
            timeout  = 4,              -- optional: combo breaks after N seconds without Add()
            tiers    = { 10, 30, 60 }, -- optional: values where the look changes (default { 5, 10, 20 })
            onBreak  = function(last) end,
            onChange = function(value, prev) end,
        })

        ComboTracker:Add()                 -- +1 (kill, hit, etc.)
        ComboTracker:Add(3)
        ComboTracker:Set(10)
        ComboTracker:Break()               -- lose the combo (plays the shatter animation if it was >= x2)
        ComboTracker:MoveTo("top_right", 0.6)
        ComboTracker:MoveTo({ x = 50, y = 30 })
        ComboTracker:SetTiers({ 25, 50, 100 })
        ComboTracker:GetTier()             -- current tier number (1 = base look)
        ComboTracker:Deactivate()          -- disable + hide instantly (e.g. gamemode without combos)
        ComboTracker:Activate()

    The Lua side only owns the number. The UI decides what to draw:
      * nothing is shown below x2
      * going x1 -> x2 plays the appear animation
      * every change plays a pop animation
      * Break() plays the shatter animation; if the combo reaches x2 again while shattering,
        it is queued and shown only when the shatter animation has finished
]]

if ComboTracker == nil then
  ComboTracker = class({})
end

-- the combo is only displayed from this value up (keep in sync with MIN_VISIBLE in combo_tracker.js)
ComboTracker.MIN_VISIBLE = 2

-- Tiers: a list of ascending values. Tier 1 is the base look; reaching the first value gives
-- tier 2, the second value tier 3, and so on. { 5, 10, 20 } -> x2-4 tier 1, x5-9 tier 2,
-- x10-19 tier 3, x20+ tier 4. The look of each tier lives in combo_tracker.css (.ComboTierN).
ComboTracker.DEFAULT_TIERS = { 5, 10, 20 }
ComboTracker.MAX_TIERS = 8 -- keep in sync with MAX_TIERS in combo_tracker.js

-- Centre of the panel in % of the screen (x from the left, y from the top).
-- The panel is 300x300 px, tune these to your layout.
ComboTracker.ANCHORS = {
  top_left      = { x = 9,  y = 24 },
  top_center    = { x = 50, y = 24 },
  top_right     = { x = 91, y = 24 },
  center_left   = { x = 9,  y = 50 },
  center        = { x = 50, y = 50 },
  center_right  = { x = 91, y = 50 },
  bottom_left   = { x = 9,  y = 68 },
  bottom_center = { x = 50, y = 68 },
  bottom_right  = { x = 91, y = 68 },
}

local function SanitizeTiers(list)
  local sorted = {}
  for _, v in ipairs(list or {}) do
    if type(v) == "number" and v >= ComboTracker.MIN_VISIBLE then
      sorted[#sorted + 1] = math.floor(v)
    end
  end
  table.sort(sorted)

  local result = {}
  for _, v in ipairs(sorted) do
    if result[#result] ~= v then result[#result + 1] = v end
  end
  while #result > ComboTracker.MAX_TIERS - 1 do
    table.remove(result)
  end
  return result
end

local function ResolvePosition(target)
  if type(target) == "string" then
    local a = ComboTracker.ANCHORS[target]
    if a then return a.x, a.y end
  elseif type(target) == "table" and target.x and target.y then
    return target.x, target.y
  end
  return nil, nil
end

---------------------------------------------------------------------------
-- init / config
---------------------------------------------------------------------------

function ComboTracker:Init()
  self.value    = 0
  self.maxValue = 0
  self.active   = false
  self.timeout  = nil
  self.expireAt = nil
  self.onChange = nil
  self.onBreak  = nil
  self.tiers    = SanitizeTiers(ComboTracker.DEFAULT_TIERS)
  self.pos      = { x = ComboTracker.ANCHORS.bottom_left.x, y = ComboTracker.ANCHORS.bottom_left.y }

  -- the panel was (re)loaded on the client: send it the current state
  if self.readyListener then
    CustomGameEventManager:UnregisterListener(self.readyListener)
  end
  self.readyListener = CustomGameEventManager:RegisterListener("combo_tracker_ready", function(_, event)
    ComboTracker:Sync()
  end)

  -- timeout watcher
  local ent = GameRules:GetGameModeEntity()
  if ent then
    ent:SetContextThink("combo_tracker_think", function()
      if self.active and self.expireAt and GameRules:GetGameTime() >= self.expireAt then
        self:Break()
      end
      return 0.1
    end, 0.1)
  end

  self:Sync()
end

-- config: anchor, timeout, tiers, onChange, onBreak, active (all optional)
function ComboTracker:Configure(config)
  config = config or {}
  if config.anchor ~= nil then self:MoveTo(config.anchor, 0) end
  if config.timeout ~= nil then self:SetTimeout(config.timeout) end
  if config.tiers ~= nil then self:SetTiers(config.tiers) end
  if config.onChange ~= nil then self.onChange = config.onChange end
  if config.onBreak ~= nil then self.onBreak = config.onBreak end
  if config.active == false then self:Deactivate() end
  if config.active == true then self:Activate() end
end

---------------------------------------------------------------------------
-- combo value
---------------------------------------------------------------------------

function ComboTracker:Add(amount)
  return self:Set(self.value + (amount or 1))
end

function ComboTracker:Set(newValue)
  if not self.active then return self.value end

  newValue = math.max(0, math.floor(newValue))
  local prev = self.value

  self.value = newValue
  if newValue > self.maxValue then self.maxValue = newValue end
  self:Refresh()

  if newValue == prev then return newValue end

  local min = ComboTracker.MIN_VISIBLE
  if newValue < min and prev >= min then
    -- combo lost: UI plays the shatter animation
    self:_Send("combo_tracker_break", { last = prev })
    if self.onBreak then self.onBreak(prev) end
  else
    self:_Send("combo_tracker_update", { value = newValue, delta = newValue - prev })
  end

  if self.onChange then self.onChange(newValue, prev) end
  return newValue
end

-- lose the combo
function ComboTracker:Break()
  return self:Set(0)
end

-- restart the timeout countdown without changing the value
function ComboTracker:Refresh()
  if self.timeout and self.value > 0 then
    self.expireAt = GameRules:GetGameTime() + self.timeout
  else
    self.expireAt = nil
  end
end

function ComboTracker:SetTimeout(seconds)
  self.timeout = seconds
  self:Refresh()
end

-- change the tier thresholds, e.g. SetTiers({ 25, 50, 100 }); SetTiers({}) = a single look
function ComboTracker:SetTiers(list)
  self.tiers = SanitizeTiers(list)
  self:_Send("combo_tracker_tiers", { tiers = table.concat(self.tiers, ",") })
end

-- tier number for a value (default: the current value); 1 = base look
function ComboTracker:GetTier(value)
  value = value or self.value
  local tier = 1
  for _, threshold in ipairs(self.tiers) do
    if value >= threshold then tier = tier + 1 end
  end
  return tier
end

function ComboTracker:GetValue() return self.value end
function ComboTracker:GetMax() return self.maxValue end
function ComboTracker:ResetMax() self.maxValue = self.value end
function ComboTracker:IsActive() return self.active end

---------------------------------------------------------------------------
-- activation / movement
---------------------------------------------------------------------------

function ComboTracker:Activate()
  if self.active then return end
  self.active = true
  self:Sync()
end

-- hides the panel instantly and drops the combo; Add/Set are ignored until Activate()
function ComboTracker:Deactivate()
  if not self.active then return end
  self.active = false
  self.value = 0
  self.expireAt = nil
  self:Sync()
end

-- target: anchor name from ComboTracker.ANCHORS or { x = %, y = % }; time: seconds of the slide
function ComboTracker:MoveTo(target, time)
  local x, y = ResolvePosition(target)
  if not x then
    print("[ComboTracker] MoveTo: unknown target " .. tostring(target))
    return
  end
  self.pos = { x = x, y = y }
  self:_Send("combo_tracker_move", { x = x, y = y, time = time or 0.5 })
end

---------------------------------------------------------------------------
-- networking
---------------------------------------------------------------------------

function ComboTracker:_Send(name, data)
  CustomGameEventManager:Send_ServerToAllClients(name, data)
end

-- full state push (used on init, activate/deactivate, and when the UI reports it is ready)
function ComboTracker:Sync()
  self:_Send("combo_tracker_state", {
    active = self.active and 1 or 0,
    value  = self.value,
    tiers  = table.concat(self.tiers, ","),
    x      = self.pos.x,
    y      = self.pos.y,
  })
end

ComboTracker:Init()