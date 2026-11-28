if invoke_training == nil then
    invoke_training = class({})
end

local PLAYER_HERO = "npc_dota_hero_invoker"
local DEFAULT_TRAINING_PLACE = Vector(-5065, 4226, 128)
local STATS_TIMER = "invoke_training_stats"
local MAX_QUEUE_DEPTH = 6
local FILLER_SPELL = "invoker_filler"

local ORBS = {
    invoker_quas = true,
    invoker_wex = true,
    invoker_exort = true,
}

-- `area` spells are evaluated as one cast after all same-tick effects arrive.
-- Point spells intentionally complete one requested target, as in the legacy trainer.
-- spellPool on the mode is the extension point for custom spell filters later.
local SPELLS = {
    {name = "invoker_cold_snap", recipe = {"invoker_quas", "invoker_quas", "invoker_quas"}},
    {name = "invoker_ghost_walk", recipe = {"invoker_quas", "invoker_quas", "invoker_wex"}, area = true, challengeTargets = 2},
    {name = "invoker_tornado", recipe = {"invoker_quas", "invoker_wex", "invoker_wex"}, area = true},
    {name = "invoker_emp", recipe = {"invoker_wex", "invoker_wex", "invoker_wex"}, area = true, challengeTargets = 4},
    {name = "invoker_alacrity", recipe = {"invoker_wex", "invoker_wex", "invoker_exort"}},
    {name = "invoker_chaos_meteor", recipe = {"invoker_exort", "invoker_exort", "invoker_wex"}},
    {name = "invoker_sun_strike", recipe = {"invoker_exort", "invoker_exort", "invoker_exort"}},
    {name = "invoker_forge_spirit", recipe = {"invoker_exort", "invoker_exort", "invoker_quas"}},
    {name = "invoker_ice_wall", recipe = {"invoker_quas", "invoker_quas", "invoker_exort"}, area = true, challengeTargets = 2},
    {name = "invoker_deafening_blast", recipe = {"invoker_exort", "invoker_quas", "invoker_wex"}, area = true},
}

local SPELL_BY_NAME = {}
for _, spell in ipairs(SPELLS) do
    SPELL_BY_NAME[spell.name] = spell
end

local TARGETS = {
    {heroName = "npc_dota_hero_earth_spirit"},
    {heroName = "npc_dota_hero_ember_spirit"},
    {heroName = "npc_dota_hero_storm_spirit"},
    {heroName = "npc_dota_hero_void_spirit"},
}

-- Storm remains the single target, matching the original trainer.
local TARGET_SETUPS = {
    [1] = {3},
    [2] = {1, 3},
    [3] = {1, 2, 3},
    [4] = {1, 2, 3, 4},
}

local TARGET_LAYOUTS = {
    [1] = {{0, 1.75}},
    [2] = {{-1, -0.55}, {1, -0.55}},
    [3] = {{-1, -0.58}, {0, 1.15}, {1, -0.58}},
    [4] = {{-1, 1}, {1, 1}, {1, -1}, {-1, -1}},
}

local EMP_RADIUS = 680
-- Use the shorter legacy wall and generous margins to avoid borderline requests.
local ICE_WALL_SPAWN_DISTANCE = 200
local ICE_WALL_WIDTH = 105
local ICE_WALL_HALF_LENGTH = 1120 / 2
local ICE_WALL_HIT_HALF_WIDTH = ICE_WALL_WIDTH / 2 - 5
local ICE_WALL_EXCLUSION_DISTANCE = ICE_WALL_WIDTH + 25
local ICE_WALL_ANGLE_SAMPLES = 72
local DEBUG_DRAW_DURATION = 5
local DEBUG_TARGET_RADIUS = 80
local DEBUG_AREA_COLOR = Vector(255, 210, 0)
local DEBUG_HIT_COLOR = Vector(40, 255, 80)
local DEBUG_WRONG_COLOR = Vector(255, 50, 50)
local DEBUG_MISS_COLOR = Vector(255, 210, 0)
local POINT_THINKERS = {
    {modifier = "modifier_invoker_sun_strike", spell = "invoker_sun_strike", radius = 175},
    {modifier = "modifier_invoker_emp", spell = "invoker_emp", radius = EMP_RADIUS},
    {modifier = "modifier_invoker_chaos_meteor_land", spell = "invoker_chaos_meteor", radius = 275},
}

local function EventBool(value)
    return value == true or value == 1 or value == "1"
end

local function SettingBool(value, default)
    if value == nil then return default end
    return EventBool(value)
end

local function ClampInteger(value, min, max, default)
    value = tonumber(value)
    if value == nil or value ~= value then return default end
    return math.min(max, math.max(min, math.floor(value)))
end

local function IsValidUnit(unit)
    return unit ~= nil and not unit:IsNull()
end

local function RandomChoice(list)
    if #list == 0 then return nil end
    return list[RandomInt(1, #list)]
end

local function RecipeContainsPair(recipe, firstOrb, secondOrb)
    local counts = {}
    for _, orb in ipairs(recipe) do
        counts[orb] = (counts[orb] or 0) + 1
    end

    local needed = {}
    needed[firstOrb] = (needed[firstOrb] or 0) + 1
    needed[secondOrb] = (needed[secondOrb] or 0) + 1
    for orb, count in pairs(needed) do
        if (counts[orb] or 0) < count then return false end
    end
    return true
end

function invoke_training:Init()
    self.type = "sandbox"
    self.name = "invoke_training"
    self.activated = false
    self.deactivateCalled = false
    self.Player = nil
    self.playerHero = nil
    self.trainingPlaceDefault = DEFAULT_TRAINING_PLACE
    self.trainingPlace = self.trainingPlaceDefault
    self.targetSpacing = 400 -- Base distance between spirits; EMP groups use these positions.
    self.spellTable = SPELLS
    self.spellPool = SPELLS
    self.targets = {}
    self.targetByEntIndex = {}
    self.forgedSpirits = {}
    self.pendingCasts = {}
    self.orbHistory = {}
    self.orbsSinceSuccess = 0
    self.sessionId = 0
    self.argsKeeper = nil

    CustomGameEventManager:RegisterListener("invoke_training_training_end", function()
        invoke_training:PrepareDeactivate()
    end)
    CustomGameEventManager:RegisterListener("invoke_training_training_retry", function()
        if invoke_training.argsKeeper == nil then return end
        invoke_training.argsKeeper.retry = 1
        invoke_training:StartGame(invoke_training.argsKeeper)
    end)
    CustomGameEventManager:RegisterListener("get_invoke_training_state", function()
        invoke_training:SendQueue()
        invoke_training:SendStats()
    end)
    CustomGameEventManager:RegisterListener("get_invoke_training_spell_table", function()
        invoke_training:SendSpellTable()
    end)

    print("invoke_training inited")
end

function invoke_training:Prepare(args)
    print("[invoke_training] Preparing gamemode")
    precache:clearTable()

    local unitsToPrecache = {TARGETS[1].heroName, TARGETS[2].heroName, TARGETS[3].heroName,
        TARGETS[4].heroName, "npc_dota_invoker_forged_spirit"}
    precache:PrecacheAddUnitToList(unitsToPrecache)
    precache:PrecacheAddPlayerUnitToList({PLAYER_HERO})

    self.pendingArgs = args or {}
    precache:doPrecache(function()
        invoke_training:StartGame(invoke_training.pendingArgs)
    end)
end

function invoke_training:ReadSpellPool(requested)
    self.spellPool = SPELLS
    if not IsInToolsMode() or type(requested) ~= "table" then return end

    local enabled = {}
    for _, spellName in pairs(requested) do
        if type(spellName) == "string" and SPELL_BY_NAME[spellName] ~= nil then
            enabled[spellName] = true
        end
    end

    local filtered = {}
    for _, spell in ipairs(SPELLS) do
        if enabled[spell.name] then table.insert(filtered, spell) end
    end
    if #filtered > 0 then self.spellPool = filtered end
end

local function DebugGroundPoint(position)
    local ground = GetGroundPosition(position, nil)
    return Vector(ground.x, ground.y, ground.z + 8)
end

function invoke_training:DrawDebugCircle(position, radius, color)
    if not self.debugDraw or not IsInToolsMode() then return end
    DebugDrawCircle(DebugGroundPoint(position), color, 16, radius, false, DEBUG_DRAW_DURATION)
end

function invoke_training:DrawDebugGroundLine(startPoint, endPoint, color)
    local first = DebugGroundPoint(startPoint)
    local second = DebugGroundPoint(endPoint)
    DebugDrawLine(first, second, color.x, color.y, color.z, false, DEBUG_DRAW_DURATION)
end

function invoke_training:DrawDebugStrip(startPoint, endPoint, width, color)
    if not self.debugDraw or not IsInToolsMode() then return end
    local delta = endPoint - startPoint
    if delta:Length2D() == 0 then return end
    local direction = Vector(delta.x, delta.y, 0):Normalized()
    local offset = Vector(-direction.y, direction.x, 0) * (width / 2)
    local firstMin, firstMax = startPoint - offset, startPoint + offset
    local secondMin, secondMax = endPoint - offset, endPoint + offset
    self:DrawDebugGroundLine(firstMin, secondMin, color)
    self:DrawDebugGroundLine(firstMax, secondMax, color)
    self:DrawDebugGroundLine(firstMin, firstMax, color)
    self:DrawDebugGroundLine(secondMin, secondMax, color)
end

local function GetIceWallCastGeometry(hero)
    if not IsValidUnit(hero) then return nil end
    local forward = hero:GetForwardVector()
    forward.z = 0
    if forward:Length2D() == 0 then return nil end
    forward = forward:Normalized()
    local center = hero:GetAbsOrigin() + forward * ICE_WALL_SPAWN_DISTANCE
    local wallDirection = Vector(-forward.y, forward.x, 0)
    return center - wallDirection * ICE_WALL_HALF_LENGTH,
        center + wallDirection * ICE_WALL_HALF_LENGTH
end

function invoke_training:DrawIceWallDebug(startPoint, endPoint)
    if not self.debugDraw or not IsInToolsMode() then return end
    if startPoint == nil or endPoint == nil then
        startPoint, endPoint = GetIceWallCastGeometry(self.playerHero)
    end
    if startPoint == nil then return end
    self:DrawDebugStrip(startPoint, endPoint, ICE_WALL_WIDTH, DEBUG_AREA_COLOR)
end

function invoke_training:ReadSettings(args)
    args = args or {}
    self.mode = tostring(args.mode or "practice") == "challenge" and "challenge" or "practice"
    self.targetCount = ClampInteger(args.targetCount, 1, #TARGETS, 3)
    self.queueDepth = ClampInteger(args.queueDepth, 1, MAX_QUEUE_DEPTH,
        self.mode == "challenge" and 6 or 1)
    self.oneSphere = SettingBool(args.oneSphere, false)
    self.debugDraw = IsInToolsMode() and SettingBool(args.debugDraw, false) or false
    self:ReadSpellPool(args.enabledSpells)
end

function invoke_training:StartGame(args)
    args = args or {}
    local retry = EventBool(args.retry)
    self:Clear()
    self:ReadSettings(args)
    self.argsKeeper = args
    args.retry = 0

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})
    self.activated = true
    self:ResetStats()

    local playerID = tonumber(args.PlayerID) or 0
    self.Player = PlayerResource:GetPlayer(playerID)
    local hero = self.Player:GetAssignedHero()
    if not retry or not IsValidUnit(self.playerHero) then
        hero = replaceHero(hero, PLAYER_HERO)
        removeItems(hero)
    else
        hero = self.playerHero
    end
    self.playerHero = hero

    hero:SetBaseIntellect(100)
    hero:SetBaseHealthRegen(100)
    hero:SetBaseManaRegen(100)
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:SetAbsOrigin(self.trainingPlace)
    FindClearSpaceForUnit(hero, self.trainingPlace, true)
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)

    for orb in pairs(ORBS) do
        local ability = hero:FindAbilityByName(orb)
        if ability ~= nil then ability:SetLevel(1) end
    end
    local invoke = hero:FindAbilityByName("invoker_invoke")
    if invoke ~= nil then invoke:SetLevel(1) end

    self.orbHistory = {}
    self.orbsSinceSuccess = 0
    self:CreateTargets()
    if self.mode == "challenge" then
        for _ = 1, self.queueDepth do self:PushChallengeWave() end
    else
        for _, target in ipairs(self.targets) do self:FillPracticeQueue(target) end
    end
    self:TouchCurrentRequests()

    ComboTracker:Configure({active = true, anchor = "bottom_right", timeout = 3,
        tiers = {5, 10, 20, 30, 50, 100}})
    ComboTracker:Add()

    self:SendQueue()
    self:SendStats()
    self:StartStatsTimer()
    print("[invoke_training] Started", self.mode, "targets:", self.targetCount,
        "queue:", self.queueDepth, "one sphere:", self.oneSphere)
end

function invoke_training:CreateTargets()
    local setup = TARGET_SETUPS[self.targetCount]
    local layout = TARGET_LAYOUTS[self.targetCount]
    for row, targetIndex in ipairs(setup) do
        local definition = TARGETS[targetIndex]
        local offset = Vector(layout[row][1] * self.targetSpacing,
            layout[row][2] * self.targetSpacing, 0)
        local position = GetGroundPosition(self.trainingPlace + offset, nil)
        local unit = CreateUnitByName(definition.heroName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        if unit ~= nil then
            unit:SetIdleAcquire(false)
            unit:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
            unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
            unit:SetBaseMoveSpeed(300)
            unit:SetBaseStrength(200)
            unit:SetBaseHealthRegen(500)
            unit:SetBaseManaRegen(100)
            unit:SetDeathXP(0)
            unit:SetMinimumGoldBounty(0)
            unit:SetMaximumGoldBounty(0)
            unit:SetHealth(unit:GetMaxHealth())
            if unit.SetCanRespawn ~= nil then unit:SetCanRespawn(false) end
            unit:SetForwardVector((self.trainingPlace - position):Normalized())

            local record = {
                entity = unit,
                heroName = definition.heroName,
                homePosition = position,
                queue = {},
                returning = false,
            }
            table.insert(self.targets, record)
            self.targetByEntIndex[unit:entindex()] = record
        end
    end
end

function invoke_training:GetTarget(unit)
    if not IsValidUnit(unit) then return nil end
    return self.targetByEntIndex[unit:entindex()]
end

function invoke_training:NewRequest(spellName)
    return {spell = spellName, requestedAt = nil}
end

function invoke_training:TouchCurrentRequests()
    local now = Time()
    for _, target in ipairs(self.targets) do
        local current = target.queue[1]
        if current ~= nil and current.spell ~= FILLER_SPELL and current.requestedAt == nil then
            current.requestedAt = now
        end
    end
end

function invoke_training:FillPracticeQueue(target)
    while #target.queue < self.queueDepth do
        table.insert(target.queue, self:NewRequest(self:GetRandomSpell(target)))
    end
    self:TouchCurrentRequests()
end

function invoke_training:CanEmpHitExactTargets(selected)
    local requested = {}
    local center = Vector(0, 0, 0)
    for row, target in ipairs(self.targets) do
        if selected[row] then
            table.insert(requested, target.homePosition)
            center = center + target.homePosition
        end
    end
    if #requested == 0 then return false end
    center = center / #requested

    -- A small margin keeps borderline valid groups from failing in the damage test.
    local radius = EMP_RADIUS - 5
    local candidates = {center}
    for _, position in ipairs(requested) do
        table.insert(candidates, position)
        -- Radial points preserve valid single-target casts near other spirits.
        for step = 0, 15 do
            local angle = step * math.pi / 8
            table.insert(candidates, position + Vector(
                math.cos(angle) * radius * 0.95,
                math.sin(angle) * radius * 0.95, 0))
        end
    end

    -- Intersections of requested targets' radius circles bound the valid cast area.
    for first = 1, #requested do
        for second = first + 1, #requested do
            local delta = requested[second] - requested[first]
            local distance = delta:Length2D()
            if distance > radius * 2 then return false end
            if distance > 0 then
                local midpoint = (requested[first] + requested[second]) / 2
                local height = math.sqrt(math.max(0, radius * radius - distance * distance / 4))
                local perpendicular = Vector(-delta.y / distance, delta.x / distance, 0)
                table.insert(candidates, midpoint + perpendicular * height)
                table.insert(candidates, midpoint - perpendicular * height)
            end
        end
    end

    for _, point in ipairs(candidates) do
        local valid = true
        for row, target in ipairs(self.targets) do
            local distance = (target.homePosition - point):Length2D()
            -- Requested targets use the margin; excluded targets use the full radius.
            local validForTarget
            if selected[row] then
                validForTarget = distance <= radius
            else
                validForTarget = distance > EMP_RADIUS
            end
            if not validForTarget then
                valid = false
                break
            end
        end
        if valid then return true end
    end
    return false
end

local function DistanceToSegment2D(point, startPoint, endPoint)
    local segment = endPoint - startPoint
    local lengthSquared = segment.x * segment.x + segment.y * segment.y
    if lengthSquared == 0 then return (point - startPoint):Length2D() end
    local offset = point - startPoint
    local projection = (offset.x * segment.x + offset.y * segment.y) / lengthSquared
    projection = math.max(0, math.min(1, projection))
    return (point - (startPoint + segment * projection)):Length2D()
end

function invoke_training:CanIceWallHitExactTargets(selected)
    local requested = {}
    for row, target in ipairs(self.targets) do
        if selected[row] then table.insert(requested, target.homePosition) end
    end
    if #requested == 0 then return false end

    -- Invoker can reposition before casting, so search possible wall placements.
    -- Pair directions guarantee an exact candidate for collinear multi-target walls.
    local directions = {}
    for step = 0, ICE_WALL_ANGLE_SAMPLES - 1 do
        local angle = step * math.pi * 2 / ICE_WALL_ANGLE_SAMPLES
        table.insert(directions, Vector(math.cos(angle), math.sin(angle), 0))
    end
    for first = 1, #requested do
        for second = first + 1, #requested do
            local delta = requested[second] - requested[first]
            local length = delta:Length2D()
            if length > 0 then
                table.insert(directions, Vector(delta.x / length, delta.y / length, 0))
            end
        end
    end

    for _, direction in ipairs(directions) do
        local perpendicular = Vector(-direction.y, direction.x, 0)
        local minAlong, maxAlong, minAcross, maxAcross
        for _, position in ipairs(requested) do
            local relative = position - self.trainingPlace
            local along = relative.x * direction.x + relative.y * direction.y
            local across = relative.x * perpendicular.x + relative.y * perpendicular.y
            if minAlong == nil or along < minAlong then minAlong = along end
            if maxAlong == nil or along > maxAlong then maxAlong = along end
            if minAcross == nil or across < minAcross then minAcross = across end
            if maxAcross == nil or across > maxAcross then maxAcross = across end
        end

        -- Keep requested targets inside the rectangular part, away from the endpoints.
        if maxAlong - minAlong <= (ICE_WALL_HALF_LENGTH - ICE_WALL_HIT_HALF_WIDTH) * 2 then
            local center = self.trainingPlace
                + direction * ((minAlong + maxAlong) / 2)
                + perpendicular * ((minAcross + maxAcross) / 2)
            local startPoint = center - direction * ICE_WALL_HALF_LENGTH
            local endPoint = center + direction * ICE_WALL_HALF_LENGTH
            local valid = true
            for row, target in ipairs(self.targets) do
                local distance = DistanceToSegment2D(target.homePosition, startPoint, endPoint)
                local validForTarget
                if selected[row] then
                    validForTarget = distance <= ICE_WALL_HIT_HALF_WIDTH
                else
                    validForTarget = distance > ICE_WALL_EXCLUSION_DISTANCE
                end
                if not validForTarget then
                    valid = false
                    break
                end
            end
            if valid then return true end
        end
    end
    return false
end

function invoke_training:GetSafeTargetGroups(canHitExact, maximum)
    local groups = {}
    local targetCount = #self.targets
    for mask = 1, 2 ^ targetCount - 1 do
        local selected = {}
        local size = 0
        local value = mask
        for row = 1, targetCount do
            if value % 2 == 1 then
                selected[row] = true
                size = size + 1
            end
            value = math.floor(value / 2)
        end
        if size <= maximum and canHitExact(self, selected) then
            table.insert(groups, {selected = selected, size = size})
        end
    end
    return groups
end

function invoke_training:PushChallengeWave()
    if #self.targets == 0 then return end
    local spellName = self:GetRandomSpell(nil)
    local spell = SPELL_BY_NAME[spellName]
    local maximum = math.min(#self.targets, spell.challengeTargets or 1)
    local requestedTargets = RandomInt(1, maximum)
    local selected = nil
    local canHitExact
    if spellName == "invoker_emp" then
        canHitExact = self.CanEmpHitExactTargets
    elseif spellName == "invoker_ice_wall" then
        canHitExact = self.CanIceWallHitExactTargets
    end

    if canHitExact ~= nil then
        local safeGroups = self:GetSafeTargetGroups(canHitExact, maximum)
        local preferredGroups = {}
        for _, group in ipairs(safeGroups) do
            if group.size == requestedTargets then table.insert(preferredGroups, group) end
        end
        local group = RandomChoice(#preferredGroups > 0 and preferredGroups or safeGroups)
        if group ~= nil then
            selected = group.selected
        else
            -- Custom spacing can make an area spell impossible to isolate.
            spellName = "invoker_cold_snap"
            spell = SPELL_BY_NAME[spellName]
            requestedTargets = 1
        end
    end

    if selected == nil then
        local rows = {}
        for row = 1, #self.targets do rows[row] = row end
        for i = #rows, 2, -1 do
            local j = RandomInt(1, i)
            rows[i], rows[j] = rows[j], rows[i]
        end
        selected = {}
        for i = 1, requestedTargets do selected[rows[i]] = true end
    end

    for row, target in ipairs(self.targets) do
        local requestedSpell = selected[row] and spellName or FILLER_SPELL
        table.insert(target.queue, self:NewRequest(requestedSpell))
    end
    self:TouchCurrentRequests()
end

function invoke_training:GetInvokedSpellNames()
    local excluded = {}
    if not IsValidUnit(self.playerHero) then return excluded end
    for _, index in ipairs({3, 4}) do
        local ability = self.playerHero:GetAbilityByIndex(index)
        if ability ~= nil then excluded[ability:GetAbilityName()] = true end
    end
    return excluded
end

function invoke_training:GetRandomSpell(target)
    local excluded = self:GetInvokedSpellNames()
    if self.oneSphere then
        if target ~= nil and #target.queue > 0 then
            excluded[target.queue[#target.queue].spell] = true
        end
    else
        -- Avoid showing the same spell back-to-back anywhere on the board.
        for _, entry in ipairs(self.targets) do
            if #entry.queue > 0 then excluded[entry.queue[#entry.queue].spell] = true end
        end
    end

    local candidates = {}
    for _, spell in ipairs(self.spellPool) do
        local allowedByOrbs = true
        if self.oneSphere and #self.orbHistory >= 3 then
            allowedByOrbs = RecipeContainsPair(spell.recipe,
                self.orbHistory[2], self.orbHistory[3])
        end
        if allowedByOrbs and not excluded[spell.name] then
            table.insert(candidates, spell)
        end
    end

    -- Drop repeat exclusions first, but never break the one-orb guarantee or
    -- enter the legacy random-until-valid loop.
    if #candidates == 0 then
        local invoked = self:GetInvokedSpellNames()
        for _, spell in ipairs(self.spellPool) do
            local allowedByOrbs = true
            if self.oneSphere and #self.orbHistory >= 3 then
                allowedByOrbs = RecipeContainsPair(spell.recipe,
                    self.orbHistory[2], self.orbHistory[3])
            end
            if allowedByOrbs and not invoked[spell.name] then table.insert(candidates, spell) end
        end
    end
    if #candidates == 0 then candidates = self.spellPool end
    local selected = RandomChoice(candidates)
    return selected ~= nil and selected.name or SPELLS[1].name
end

function invoke_training:GetExpectedTargets(spellName)
    local result = {}
    for _, target in ipairs(self.targets) do
        local current = target.queue[1]
        if current ~= nil and current.spell == spellName then table.insert(result, target) end
    end
    return result
end

function invoke_training:GetTargetsWithModifier(modifierName)
    local result = {}
    for _, target in ipairs(self.targets) do
        if IsValidUnit(target.entity) and target.entity:FindModifierByName(modifierName) ~= nil then
            table.insert(result, target.entity)
        end
    end
    return result
end

function invoke_training:GetTargetsInRadius(position, radius)
    local result = {}
    for _, target in ipairs(self.targets) do
        if IsValidUnit(target.entity) then
            local distance = (target.entity:GetAbsOrigin() - position):Length2D()
            if distance <= radius then table.insert(result, target.entity) end
        end
    end
    return result
end

function invoke_training:GetTargetsInIceWall(startPoint, endPoint)
    local result = {}
    if startPoint == nil or endPoint == nil then return result end
    for _, target in ipairs(self.targets) do
        if IsValidUnit(target.entity) then
            local distance = DistanceToSegment2D(target.entity:GetAbsOrigin(), startPoint, endPoint)
            if distance <= ICE_WALL_WIDTH / 2 then table.insert(result, target.entity) end
        end
    end
    return result
end

function invoke_training:QueueAffectedTarget(spellName, unit)
    local target = self:GetTarget(unit)
    if target == nil then return end
    local pending = self.pendingCasts[spellName]
    if pending == nil then
        pending = {list = {}, seen = {}}
        self.pendingCasts[spellName] = pending
    end
    if pending.seen[target] then return end
    pending.seen[target] = true
    table.insert(pending.list, unit)
    if pending.scheduled then return end

    pending.scheduled = true
    local session = self.sessionId
    Timers:CreateTimer(FrameTime(), function()
        if not self.activated or session ~= self.sessionId then return nil end
        self.pendingCasts[spellName] = nil
        self:ResolveCast(spellName, pending.list)
        return nil
    end)
end

function invoke_training:ResolveCast(spellName, affectedUnits)
    if not self.activated then return false end
    local spell = SPELL_BY_NAME[spellName]
    if spell == nil then return false end

    local expected = self:GetExpectedTargets(spellName)
    local expectedSet = {}
    for _, target in ipairs(expected) do expectedSet[target] = true end

    local affected = {}
    local affectedSet = {}
    for _, unit in ipairs(affectedUnits or {}) do
        local target = self:GetTarget(unit)
        if target ~= nil and not affectedSet[target] then
            affectedSet[target] = true
            table.insert(affected, target)
        end
    end

    if self.debugDraw and IsInToolsMode() then
        for _, target in ipairs(affected) do
            local color = expectedSet[target] and DEBUG_HIT_COLOR or DEBUG_WRONG_COLOR
            self:DrawDebugCircle(target.entity:GetAbsOrigin(), DEBUG_TARGET_RADIUS, color)
        end
        for _, target in ipairs(expected) do
            if not affectedSet[target] then
                self:DrawDebugCircle(target.entity:GetAbsOrigin(), DEBUG_TARGET_RADIUS, DEBUG_MISS_COLOR)
            end
        end
    end

    local correct = {}
    local wrongCount = 0
    for _, target in ipairs(affected) do
        if expectedSet[target] then
            table.insert(correct, target)
        else
            wrongCount = wrongCount + 1
        end
    end

    local failure = nil
    if #expected == 0 then
        failure = "Not requested."
    elseif #affected == 0 then
        failure = "Skill missed."
    elseif wrongCount > 0 then
        failure = "Wrong target."
    elseif spell.area and self.mode == "challenge" then
        local affectedExpected = 0
        for _, target in ipairs(expected) do
            if affectedSet[target] then affectedExpected = affectedExpected + 1 end
        end
        if affectedExpected ~= #expected then failure = "Hit every requested target." end
    elseif #correct ~= 1 or #affected ~= 1 then
        failure = "Wrong target."
    end

    if failure ~= nil then
        self:FailCast(spellName, failure)
        return false
    end

    self:CompleteCast(spell, correct)
    return true
end

function invoke_training:FailCast(spellName, reason)
    self.stats.mistakes = self.stats.mistakes + 1
    self.stats.streak = 0
    self.spellStats[spellName].mistakes = self.spellStats[spellName].mistakes + 1
    ComboTracker:Break()
    ComboTracker:Add()
    Notifications:Show("red", reason, spellName)
    self:SendStats()
end

function invoke_training:CompleteCast(spell, correct)
    local now = Time()
    local requestedAt = 0
    for _, target in ipairs(correct) do
        local request = target.queue[1]
        if request ~= nil and request.requestedAt ~= nil then
            requestedAt = math.max(requestedAt, request.requestedAt)
        end
    end
    local castTime = requestedAt > 0 and math.max(0, now - requestedAt) or 0

    self.stats.successes = self.stats.successes + 1
    self.stats.streak = self.stats.streak + 1
    self.stats.bestStreak = math.max(self.stats.bestStreak, self.stats.streak)
    self.stats.totalCastTime = self.stats.totalCastTime + castTime
    self.stats.totalOrbsPerSuccess = self.stats.totalOrbsPerSuccess + self.orbsSinceSuccess
    self.orbsSinceSuccess = 0

    local spellStats = self.spellStats[spell.name]
    spellStats.successes = spellStats.successes + 1
    spellStats.totalCastTime = spellStats.totalCastTime + castTime

    if self.mode == "challenge" then
        -- A challenge wave advances on every row, including its filler slots.
        for _, target in ipairs(self.targets) do table.remove(target.queue, 1) end
        self:PushChallengeWave()
    else
        for _, target in ipairs(correct) do
            table.remove(target.queue, 1)
            self:FillPracticeQueue(target)
        end
    end
    self:TouchCurrentRequests()

    ComboTracker:Add()
    local icon = #correct >= 3 and "pogchamp" or spell.name
    local text = #correct >= 2 and ("Perfect! x" .. #correct) or "Good!"
    Notifications:Show("green", text, icon)
    self:SendQueue()
    self:SendStats()
end

function invoke_training:OnNPCSpawned(keys)
    if not self.activated then return end
    local npc = EntIndexToHScript(keys.entindex)
    if not IsValidUnit(npc) then return end

    if npc:GetUnitName() == "npc_dota_invoker_forged_spirit" then
        self.forgedSpirits[keys.entindex] = npc
        return
    end

    local session = self.sessionId
    Timers:CreateTimer(0.03, function()
        if not self.activated or session ~= self.sessionId or not IsValidUnit(npc) then return nil end
        for _, entry in ipairs(POINT_THINKERS) do
            if npc:FindModifierByName(entry.modifier) ~= nil then
                local position = npc:GetAbsOrigin()
                self:DrawDebugCircle(position, entry.radius, DEBUG_AREA_COLOR)
                self:ResolveCast(entry.spell, self:GetTargetsInRadius(position, entry.radius))
                break
            end
        end
        return nil
    end)
end

function invoke_training:EvaluateModifierCast(spellName, modifierName, candidates)
    local session = self.sessionId
    Timers:CreateTimer(FrameTime(), function()
        if not self.activated or session ~= self.sessionId then return nil end
        local affected
        if candidates == nil then
            affected = self:GetTargetsWithModifier(modifierName)
        else
            affected = {}
            for _, unit in ipairs(candidates) do
                if IsValidUnit(unit) and unit:FindModifierByName(modifierName) ~= nil then
                    table.insert(affected, unit)
                end
            end
        end
        self:ResolveCast(spellName, affected)
        return nil
    end)
end

function invoke_training:ModifierGained(event)
    if not self.activated then return true end
    local parent = EntIndexToHScript(event.entindex_parent_const)
    if not IsValidUnit(parent) then return true end

    if event.name_const == "modifier_invoker_alacrity" and parent == self.playerHero then
        parent:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
        return true
    end

    local target = self:GetTarget(parent)
    if target == nil then return true end
    if event.name_const == "modifier_invoker_tornado" then
        self:QueueAffectedTarget("invoker_tornado", parent)
    elseif event.name_const == "modifier_invoker_deafening_blast_knockback" then
        self:QueueAffectedTarget("invoker_deafening_blast", parent)
        self:ReturnTargetAfterKnockback(target)
    end
    return true
end

function invoke_training:ReturnTargetAfterKnockback(target)
    if target.returning then return end
    target.returning = true
    local unit = target.entity
    local session = self.sessionId

    Timers:CreateTimer(0.1, function()
        if not self.activated or session ~= self.sessionId or not IsValidUnit(unit) then
            target.returning = false
            return nil
        end
        if unit:FindModifierByName("modifier_invoker_deafening_blast_knockback") ~= nil then
            return 0.1
        end
        if (unit:GetAbsOrigin() - target.homePosition):Length2D() <= 10 then
            unit:Stop()
            target.returning = false
            return nil
        end

        ExecuteOrderFromTable({
            UnitIndex = unit:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = target.homePosition,
            Queue = false,
        })
        return 0.2
    end)
end

function invoke_training:OnAbilityUsed(keys)
    if not self.activated or not IsValidUnit(self.playerHero) then return end
    local abilityName = keys.abilityname
    if abilityName == nil then return end

    if ORBS[abilityName] then
        table.insert(self.orbHistory, abilityName)
        if #self.orbHistory > 3 then table.remove(self.orbHistory, 1) end
        self.stats.totalOrbs = self.stats.totalOrbs + 1
        self.orbsSinceSuccess = self.orbsSinceSuccess + 1
        self:SendStats()
    end

    local ability = self.playerHero:FindAbilityByName(abilityName)
    local session = self.sessionId
    if ability ~= nil then
        Timers:CreateTimer(0.1, function()
            if not self.activated or session ~= self.sessionId or not IsValidUnit(self.playerHero) then return nil end
            ability:EndCooldown()
            ability:RefundManaCost()
            return nil
        end)
    end

    if abilityName == "invoker_ghost_walk" then
        if ability ~= nil then
            self:DrawDebugCircle(self.playerHero:GetAbsOrigin(),
                ability:GetSpecialValueFor("radius"), DEBUG_AREA_COLOR)
        end
        self:EvaluateModifierCast(abilityName, "modifier_invoker_ghost_walk_enemy")
    elseif abilityName == "invoker_ice_wall" then
        local startPoint, endPoint = GetIceWallCastGeometry(self.playerHero)
        self:DrawIceWallDebug(startPoint, endPoint)
        local candidates = self:GetTargetsInIceWall(startPoint, endPoint)
        self:EvaluateModifierCast(abilityName, "modifier_invoker_ice_wall_slow_debuff", candidates)
    end
end

function invoke_training:OnEntityHurt(keys)
    if not self.activated then return end
    local victim = EntIndexToHScript(keys.entindex_killed)
    local attacker = EntIndexToHScript(keys.entindex_attacker)
    if not IsValidUnit(victim) or not IsValidUnit(attacker) then return end
    local target = self:GetTarget(victim)

    local inflictor = nil
    if keys.entindex_inflictor ~= nil then inflictor = EntIndexToHScript(keys.entindex_inflictor) end
    local inflictorName = inflictor ~= nil and not inflictor:IsNull() and inflictor:GetAbilityName() or nil

    if target ~= nil and inflictorName == "invoker_cold_snap" then
        self:ResolveCast("invoker_cold_snap", {victim})
        victim:RemoveModifierByName("modifier_invoker_cold_snap")
        return
    end

    if target ~= nil and attacker:GetUnitName() == "npc_dota_invoker_forged_spirit" then
        self:ResolveCast("invoker_forge_spirit", {victim})
        self.forgedSpirits[attacker:entindex()] = nil
        attacker:ForceKill(false)
        return
    end

    if target ~= nil and attacker == self.playerHero and inflictorName == nil
        and attacker:HasModifier("modifier_invoker_alacrity") then
        self:ResolveCast("invoker_alacrity", {victim})
        attacker:RemoveModifierByName("modifier_invoker_alacrity")
        attacker:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
        attacker:Stop()
    end
end

function invoke_training:OnEntityKilled(keys)
    self.forgedSpirits[keys.entindex_killed] = nil
end

function invoke_training:ResetStats()
    self.stats = {
        successes = 0,
        mistakes = 0,
        streak = 0,
        bestStreak = 0,
        totalCastTime = 0,
        totalOrbs = 0,
        totalOrbsPerSuccess = 0,
        startTime = Time(),
    }
    self.spellStats = {}
    for _, spell in ipairs(SPELLS) do
        self.spellStats[spell.name] = {successes = 0, mistakes = 0, totalCastTime = 0}
    end
end

function invoke_training:StartStatsTimer()
    local session = self.sessionId
    Timers:CreateTimer(STATS_TIMER, {
        useGameTime = true,
        endTime = 0.5,
        callback = function()
            if not self.activated or session ~= self.sessionId then return nil end
            self:SendStats()
            return 0.5
        end,
    })
end

function invoke_training:SendStats()
    if self.stats == nil then return end
    local stats = self.stats
    local attempts = stats.successes + stats.mistakes
    local elapsed = math.max(0, Time() - stats.startTime)
    local accuracy = attempts > 0 and stats.successes / attempts * 100 or 0
    local avgTime = stats.successes > 0 and stats.totalCastTime / stats.successes or 0
    local orbsPerSpell = stats.successes > 0 and stats.totalOrbsPerSuccess / stats.successes or 0
    local spellsPerMinute = elapsed > 0 and stats.successes * 60 / elapsed or 0

    local spellDetails = {}
    for index, spell in ipairs(SPELLS) do
        local entry = self.spellStats[spell.name]
        local spellAttempts = entry.successes + entry.mistakes
        spellDetails[index] = {
            spell = spell.name,
            successes = entry.successes,
            mistakes = entry.mistakes,
            accuracy = spellAttempts > 0 and entry.successes / spellAttempts * 100 or 0,
            avgTime = entry.successes > 0 and entry.totalCastTime / entry.successes or 0,
        }
    end

    CustomGameEventManager:Send_ServerToAllClients("invoke_training_stats", {
        successes = stats.successes,
        mistakes = stats.mistakes,
        accuracy = accuracy,
        streak = stats.streak,
        bestStreak = stats.bestStreak,
        avgTime = avgTime,
        orbsPerSpell = orbsPerSpell,
        spellsPerMinute = spellsPerMinute,
        totalOrbs = stats.totalOrbs,
        elapsed = elapsed,
        spellStats = spellDetails,
    })
end

function invoke_training:SendQueue()
    if not self.activated then return end
    local payload = {
        mode = self.mode,
        targetCount = #self.targets,
        queueDepth = self.queueDepth,
        oneSphere = self.oneSphere and 1 or 0,
        targets = {},
    }
    for row, target in ipairs(self.targets) do
        local queue = {}
        for index, request in ipairs(target.queue) do queue[index] = request.spell end
        payload.targets[row] = {row = row - 1, heroName = target.heroName, queue = queue}
    end
    CustomGameEventManager:Send_ServerToAllClients("invoke_training_queue", payload)
end

function invoke_training:SendSpellTable()
    CustomGameEventManager:Send_ServerToAllClients("invoke_training_spell_table", {data = self.spellTable})
end

function invoke_training:Clear()
    self.activated = false
    self.sessionId = self.sessionId + 1
    Timers:RemoveTimer(STATS_TIMER)
    ComboTracker:Deactivate()

    for _, target in ipairs(self.targets) do
        if IsValidUnit(target.entity) then target.entity:RemoveSelf() end
    end
    self.targets = {}
    self.targetByEntIndex = {}
    self.pendingCasts = {}
    for index, spirit in pairs(self.forgedSpirits) do
        if IsValidUnit(spirit) then spirit:ForceKill(false) end
        self.forgedSpirits[index] = nil
    end
end

function invoke_training:PrepareDeactivate()
    self.deactivateCalled = true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function invoke_training:Deactivate()
    self:Clear()
    self.deactivateCalled = false
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

invoke_training:Init()
GamemodeManager:RegisterMode(invoke_training.name, invoke_training, invoke_training.type)
