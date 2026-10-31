--prepared all generic methods single gamemode needs
--init prepare deactivate are necessary, events and damage filters can be removed if not used
if aim_compet == nil then
  aim_compet = class({})
end

local WARD_NAME = "npc_dota_observer_wards"
local HERO_NAME = "npc_dota_hero_pangolier"

local TIMER_DISPLAY = "aim_compet_time_display"
local TIMER_WARD_CYCLE = "aim_compet_ward_cycle"

local ROUND_TIME = 60      -- seconds, was WARD_TIMER
local MAX_WARDS = 107      -- total wards spawned per round
local WARD_HP = 200
local WARD_HP_DECAY = 10   -- hp lost every WARD_DECAY_TICK seconds
local WARD_DECAY_TICK = 0.1

-- play area relative to the hero (was hardcoded in aim_training_start)
local AREA_MIN_X, AREA_MIN_Y = 750, 350
local AREA_MAX_X, AREA_MAX_Y = 750, 650

-- ward placement rules
local HERO_MIN_RANGE = 350       -- wards never spawn closer than this to the hero
local WARD_MIN_GAP = 300         -- wards never spawn closer than this to recent wards
local RECENT_WARDS = 6           -- how many previous wards to check (roughly how many can be alive at once)
local MAX_PLACE_ATTEMPTS = 50    -- hard cap for the placement loop

-- Own seedable RNG (Park-Miller). Dota's RandomInt can't be seeded, and math.random
-- is shared with every other script, so this keeps its own state per instance.
-- Only integer math below 2^53, so it gives the same sequence on every machine.
local RNG_MOD = 2147483647
local RNG_MUL = 16807

local function NewRng(seed)
    local state = math.floor(seed) % RNG_MOD
    if state == 0 then state = 1 end

    local rng = {}
    function rng:Next()
        state = (state * RNG_MUL) % RNG_MOD
        return state
    end
    -- integer in [min, max], inclusive
    function rng:Int(min, max)
        return min + math.floor((self:Next() - 1) / (RNG_MOD - 1) * (max - min + 1))
    end

    -- small seeds give weak first outputs, so burn a few
    for _ = 1, 10 do rng:Next() end
    return rng
end

-- days since 1970-01-01 for a calendar date
local function DaysFromCivil(y, m, d)
    if m <= 2 then y = y - 1 end
    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local mp = (m > 2) and (m - 3) or (m + 9)
    local doy = math.floor((153 * mp + 2) / 5) + d - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return era * 146097 + doe - 719468
end


function aim_compet:Init()
    self.type = "compet" -- Define the type of mode
    self.name = "aim_compet" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated (replaces REACTION_TRAINING)
    self.Player = nil -- Reference to the player
    self.playerHeroName=HERO_NAME
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(-5065,4226,128)
    self.trainingPlace = self.trainingPlaceDefault
    self.startDelay=3
    -- round state (all of these used to be globals)
    self.results = {}       -- was RESULTS_TABLE, time-to-kill of every ward the player killed
    self.wardPool = {}      -- was WARD_POOL, {entindex, spawnTime} of alive wards
    self.wards = {}         -- was AIM_TRASH, every ward spawned this round (for cleanup)
    self.box = nil          -- was AIM_BOX, particles of the play area border
    self.score = 0          -- was AIM_SCORE
    self.combo = 1          -- was AIM_COMBO
    self.maxCombo = 1       -- was AIM_MAX_COMBO
    self.avgTime = 0        -- was AIM_AVG_TIME
    self.hits = 0           -- wards killed by the player (shown on the HUD)
    self.misses = 0         -- wards that died on their own (shown on the HUD)
    self.timeLeft = ROUND_TIME -- was WARD_TIMER
    self.seed = nil        -- seed of the current round (same seed = same ward layout)
    self.spawnPlan = {}     -- ward offsets from the hero, generated from the seed
    self.useSeed = false     -- true: layout comes from a seed (custom or weekly), false: new random seed every round
    self.customSeed = nil   -- manually set seed, overrides the weekly one while useSeed is true
    self.argsKeeper=nil
    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_aim_compet_respawn_pos", function(_, event)
        aim_compet:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("aim_compet_reset_respawn_pos", function(_, event)
        aim_compet:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("aim_compet_training_end", function(_, event)
        aim_compet:PrepareDeactivate()
    end)
    CustomGameEventManager:RegisterListener("aim_compet_training_retry", function(_, event)
        aim_compet.argsKeeper.retry=1
        aim_compet:StartGame(aim_compet.argsKeeper)
    end)
    -- seed controls (event.seed = number, event.value = 1/0 or true/false)
    CustomGameEventManager:RegisterListener("get_aim_compet_seed", function(_, event)
        aim_compet:SendSeed()
    end)
    CustomGameEventManager:RegisterListener("aim_compet_set_seed", function(_, event)
        aim_compet:SetSeed(event.seed)
    end)
    CustomGameEventManager:RegisterListener("aim_compet_show_miss", function(_, event)
        aim_compet:ShowMiss(event.position)
    end)
    CustomGameEventManager:RegisterListener("aim_compet_set_use_seed", function(_, event)
        aim_compet:SetUseSeed(event.value == 1 or event.value == true)
    end)
    -- TODO: add a listener for this mode's own spell table request, e.g.
    -- CustomGameEventManager:RegisterListener("get_aim_compet_spell_table", function(_, event)
    --     aim_compet:SendSpellTable()
    -- end)

    self.deactivateCalled = false

    print('aim_compet inited')
end

--[[ function aim_compet:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function aim_compet:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    aim_compet:SendRespawnPos()
end ]]

function aim_compet:Prepare(args)
    print("[aim_compet] Preparing gamemode")
    precache:clearTable()

    -- units this mode needs precached (wards + the hero that replaceHero will create)
    local unitsToPrecache = {WARD_NAME, HERO_NAME}

    if #unitsToPrecache > 0 then
        precache:PrecacheAddUnitToList(unitsToPrecache)
    end
    --To precache player hero use this
    if self.playerHeroName then
        precache:PrecacheAddPlayerUnitToList({self.playerHeroName})
    end
    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        aim_compet:StartGame(self.pendingArgs)
    end)
end

-- args.PlayerID : player id (defaults to 0, it's single player)
-- args.retry    : 1 to restart the round without re-creating hero / items
function aim_compet:StartGame(args)
    args = args or {}
    self.argsKeeper=args
    local retry = (args.retry == 1)
    local playerID = args.PlayerID or 0

    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    --[[ CustomGameEventManager:Send_ServerToAllClients("reaction_start",{type='aim'}) ]]

    if retry then
        print("RETRY")
        self:Clear()
    end

    -- reset round state
    self.results = {}
    self.wardPool = {}
    self.wards = {}
    self.score = 0
    self.combo = 1
    self.maxCombo = 1
    self.avgTime = 0
    self.hits = 0
    self.misses = 0
    self.timeLeft = ROUND_TIME
    self.activated = true
    self:SendCounters() -- resets the HUD on retry

    self.Player = PlayerResource:GetPlayer(playerID)
    local hero = self.Player:GetAssignedHero()
    if not retry then
        hero = replaceHero(hero, HERO_NAME)
        removeItems(hero)
    end
    self.playerHero = hero

    hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:SetDayTimeVisionRange(1200)--dont forget to change back
    hero:SetAbsOrigin(self.trainingPlace)
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
    hero:SetBaseHealthRegen(10)

    if not retry then
        local topor = CreateItem("item_topor", hero, hero)
        hero:AddItem(topor)
        local gem = CreateItem("item_gem", hero, hero)
        hero:AddItem(gem)
        --[[ getConfigAndApply(hero, 'aim') ]]
    end

    -- logging can be started here

    self.seed = self:ResolveSeed(args)
    self.spawnPlan = self:GenerateSpawnPlan(self.seed)
    print("[aim_compet] seed:", self.seed)
    self:SendSeed()

    self:StartTimeDisplay()
    self:StartWardCycle()
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_countdown_start", {})
    -- play area border
    local origin = hero:GetAbsOrigin()
    local minVec = origin - Vector(AREA_MIN_X, AREA_MIN_Y, 0)
    local maxVec = origin + Vector(AREA_MAX_X, AREA_MAX_Y, 0)
    self.box = CreateParticleBox(minVec, maxVec, "particles/custom/range_display_line_red.vpcf", self.Player)
    --combo tracker
    ComboTracker:Configure({ active = true, anchor = "bottom_right", timeout = 2, tiers = { 10, 25, 50, 75, 100, 120 } })
    ComboTracker:Add()
end

-- countdown shown on the HUD, ends the round when it reaches 0
function aim_compet:StartTimeDisplay()
    Timers:CreateTimer(TIMER_DISPLAY, {
        useGameTime = true,
        endTime = self.startDelay,
        callback = function()
            if not self.activated then
                return nil
            end

            CustomGameEventManager:Send_ServerToAllClients("reaction_timer", {time = self.timeLeft})
            self:SendCounters()
            self.timeLeft = self.timeLeft - 1

            if self.timeLeft == -1 then
                self:OnRoundEnd()
                return nil
            end

            if self.timeLeft == 2 then
                -- sound can be emitted here (round is about to end, was "drums")
            end
            return 1
        end
    })
end

function aim_compet:OnRoundEnd()
    --[[ setItemConfig(self.playerHero, 'aim') ]]

    -- result can be sent here:
    --   score = self.score
    --   max combo = self.maxCombo
    --   avg time = math.floor(self.avgTime * 1000) / 1000
    -- ping reading can be done here too
    -- logging can be stopped / saved here
    self.activated==false
    print("wards_destroyed:", #self.results)
end

-- spawns wards, interval between them shrinks so they appear faster and faster
function aim_compet:StartWardCycle()
    local interval = 2
    local wardsCount = 0

    Timers:CreateTimer(TIMER_WARD_CYCLE, {
        useGameTime = true,
        endTime = self.startDelay,
        callback = function()
            if not self.activated then
                return nil
            end

            if interval > 0.4 then
                interval = interval - 0.08
            end

            local pos = self.playerHero:GetAbsOrigin() + self.spawnPlan[wardsCount + 1]
            local ward = CreateUnitByName(WARD_NAME, pos, true, nil, nil, DOTA_TEAM_BADGUYS)
            ward:SetDeathXP(0)
            ward:SetMaxHealth(WARD_HP)
            ward:SetHealth(WARD_HP)
            table.insert(self.wards, ward)

            wardsCount = wardsCount + 1
            if wardsCount == MAX_WARDS then
                return nil
            end
            return interval
        end
    })
end

-- seed that changes every week (weeks start on Monday), so everyone gets the same layout for a week
-- NOTE: this uses the local clock, if you have a server it's safer to get the seed from it and pass args.seed
function aim_compet:GetWeeklySeed()
    local m, d, y = string.match(GetSystemDate(), "(%d+)/(%d+)/(%d+)") -- "MM/DD/YY"
    m, d, y = tonumber(m), tonumber(d), tonumber(y)
    if m == nil or d == nil or y == nil then
        print("[aim_compet] could not read system date, using fallback seed")
        return 1
    end
    if y < 100 then y = y + 2000 end

    -- 1970-01-01 was a Thursday, +3 shifts the week boundary to Monday
    return math.floor((DaysFromCivil(y, m, d) + 3) / 7)
end

-- Picks the seed for a round, in this order:
--   1. args.seed (e.g. given by your server), always wins
--   2. useSeed == true : customSeed if one was set, otherwise the weekly seed
--   3. useSeed == false: a fresh random seed (still shown, so a good layout can be replayed with SetSeed)
function aim_compet:ResolveSeed(args)
    if args and args.seed then
        local s = tonumber(args.seed)
        if s then return math.floor(s) end
    end

    if self.useSeed then
        return self.customSeed or self:GetWeeklySeed()
    end

    return RandomInt(1, RNG_MOD - 1)
end

-- sets a seed for the next rounds and turns seeding on (does not affect the round in progress)
function aim_compet:SetSeed(seed)
    local s = tonumber(seed)
    if s == nil then
        print("[aim_compet] SetSeed: invalid seed", seed)
        return false
    end

    self.customSeed = math.floor(s)
    self.useSeed = true
    print("[aim_compet] custom seed set:", self.customSeed)
    self:SendSeed()
    return true
end

-- back to the weekly seed
function aim_compet:ClearSeed()
    self.customSeed = nil
    self:SendSeed()
end

function aim_compet:SetUseSeed(enabled)
    self.useSeed = enabled and true or false
    print("[aim_compet] useSeed:", self.useSeed)
    self:SendSeed()
end

-- sends seed info to the HUD: seed of the current round, the custom seed (if set) and whether seeding is on
function aim_compet:SendSeed()
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_seed", {
        seed = self.seed,
        customSeed = self.customSeed,
        enabled = self.useSeed
    })
end

-- sends the stats shown on the HUD (score, combo, hits, misses, hit rate, avg reaction time, time left)
function aim_compet:SendCounters()
    local total = self.hits + self.misses
    local hitRate = 0
    if total > 0 then
        hitRate = math.floor(self.hits / total * 100)
    end

    CustomGameEventManager:Send_ServerToAllClients("aim_compet_refresh_counters", {
        score = self.score,
        combo = self.combo,
        maxCombo = self.maxCombo,
        hits = self.hits,
        misses = self.misses,
        hitRate = hitRate,
        avgTime = self.avgTime,
        timeLeft = math.max(0, self.timeLeft)
    })
end

-- Builds the offsets (relative to the hero) of every ward of the round, up front.
-- It only depends on the seed, not on how fast the player kills wards, so the layout is identical
-- for everyone. Wards are spaced from the last few planned wards instead of alive ones for the same reason.
-- The loop is capped: if no ideal spot is found, the best candidate seen is used.
function aim_compet:GenerateSpawnPlan(seed)
    local rng = NewRng(seed)
    local plan = {}

    for i = 1, MAX_WARDS do
        local best, bestGap = nil, -1

        for _ = 1, MAX_PLACE_ATTEMPTS do
            local offset = Vector(rng:Int(-AREA_MIN_X, AREA_MAX_X), rng:Int(-AREA_MIN_Y, AREA_MAX_Y), 0)

            if offset:Length2D() > HERO_MIN_RANGE then
                local gap = math.huge
                for j = math.max(1, i - RECENT_WARDS), i - 1 do
                    gap = math.min(gap, (offset - plan[j]):Length2D())
                end

                if gap >= WARD_MIN_GAP then
                    best = offset
                    break
                end
                if gap > bestGap then
                    best, bestGap = offset, gap
                end
            end
        end

        -- fallback only if every attempt was too close to the hero (practically impossible)
        plan[i] = best or Vector(HERO_MIN_RANGE + 150, 0, 0)
    end

    return plan
end

-- ward loses hp over time, if it would die from that it is killed by itself (counts as a miss)
function aim_compet:StartWardDecay(ward)
    Timers:CreateTimer({
        useGameTime = false,
        endTime = WARD_DECAY_TICK,
        callback = function()
            if not self.activated or ward:IsNull() or not ward:IsAlive() then
                return nil
            end

            local newHp = ward:GetHealth()
            if newHp - WARD_HP_DECAY <= 0 then
                ward:ForceKill(false)
                self:WardKilledHimself(ward)
            else
                ward:ModifyHealth(newHp - WARD_HP_DECAY, nil, true, 0)
            end
            return WARD_DECAY_TICK
        end
    })
end

function aim_compet:OnNPCSpawned(keys)
    if not self.activated then return end

    local npc = EntIndexToHScript(keys.entindex)
    if npc == nil or npc:IsNull() then return end

    if npc:GetUnitName() == WARD_NAME then
        self:StartWardDecay(npc)
        table.insert(self.wardPool, {keys.entindex, Time()})
    end
end

function aim_compet:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function aim_compet:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    return true
end

function aim_compet:DamageFilter(event)
    --return false to prevent specific damage instances, true to allow
    --event.damagetype_const        damage type
    --event.damage      damage (returns full damage even if victim had less hp)
    --event.entindex_victim_const        entindex of victim
    --entindex_attacker_const        entindex of attacker
    return true
end

function aim_compet:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

local function IsWardBase(unit)
    local name = unit:GetName()
    return name == "npc_dota_ward_base" or name == "npc_dota_ward_base_truesight"
end

function aim_compet:ShowMiss(position)
    local vecPos=Vector(position['0'],position['1'],position['2'])
    --[[ print(vecPos,position) ]]
    ParticleMessage:ShowMissSignAtPosition(vecPos, Vector(0,0,30), ParticleMessage.colors.red)

end
function aim_compet:OnEntityKilled(keys)
    --keys.fires when entity got killed
    --keys.entindex_killed       victim entindex
    --keys.splitscreenplayer      no idea tbh
    --keys.entindex_attacker      attacker entindex
    --keys.game_event_name        event name
    --keys.entindex_inflictor        entindex of ability killed with (not exist if autoattack)
    --keys.damagebits        no idea always 0
    --keys.game_event_listener       never used
    --[[ DeepPrintTable(keys) ]]
    if not self.activated then return end

    local killedUnit = EntIndexToHScript(keys.entindex_killed)
    if killedUnit == nil or killedUnit:IsNull() or not IsWardBase(killedUnit) then return end

    local killerEntity = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker) or nil
    local killedByWard = (killerEntity == nil) or killerEntity:IsNull() or IsWardBase(killerEntity)
    
    if killedByWard then
        --doesnt work
        -- ward died on its own (player was too slow)
        --[[ print("ward killed himself")
        -- sound can be emitted here (miss, was "sproing")
        self.combo = 1
        self.misses = self.misses + 1
        self:SendCounters()
        ComboTracker:Break() ]]
        --[[ CustomGameEventManager:Send_ServerToAllClients("reaction_clicked", {
            time = 0, score = 'Bad!', totalscore = self.score, combo = self.combo,
            badx = killedUnit:GetAbsOrigin().x, bady = killedUnit:GetAbsOrigin().y
        }) ]]
    else
        -- ward was killed by player
        self:OnWardHit(keys.entindex_killed)
    end

    killedUnit:RemoveSelf()
end

function aim_compet:WardKilledHimself(ent)
    --[[ print("ward killed himself") ]]
    -- sound can be emitted here (miss, was "sproing")
    self.combo = 1
    self.misses = self.misses + 1
    self:SendCounters()
    ComboTracker:Break()
    ComboTracker:Add()
    ParticleMessage:ShowUnluckySign(ent,Vector(0,0,50),ParticleMessage.colors['red'])
    Notifications:SoundOnly("bad")
end

function aim_compet:OnWardHit(wardIndex)
    -- find ward in pool
    local indexFound
    for k, v in pairs(self.wardPool) do
        if v[1] == wardIndex then
            indexFound = k
            break
        end
    end
    if indexFound == nil then return end

    local spawnTime = self.wardPool[indexFound][2]
    table.remove(self.wardPool, indexFound)

    local reactionTime = Time() - spawnTime

    self.combo = self.combo + 1
    if self.combo > self.maxCombo then
        self.maxCombo = self.combo
    end

    local score = math.ceil(100 / reactionTime) * self.combo
    self.score = self.score + score

    -- average reaction time
    table.insert(self.results, reactionTime)
    local sum = 0
    for _, t in pairs(self.results) do
        sum = sum + t
    end
    self.avgTime = sum / #self.results
    self.hits = self.hits + 1
    self:SendCounters()
    ComboTracker:Add()
    local wardEnt=EntIndexToHScript(wardIndex)
    local displayDelay=math.floor(reactionTime*1000)/1000
    ParticleMessage:ShowNumber(wardEnt, Vector(0,0,50), displayDelay, ParticleMessage.colors.green, false)
    Notifications:SoundOnly("good")
    --[[ CustomGameEventManager:Send_ServerToAllClients("reaction_clicked", {
        time = reactionTime, score = score, avg = self.avgTime,
        totalscore = self.score, combo = self.combo
    }) ]]
    -- sound can be emitted here (hit, was "frog")
end

function aim_compet:OnEntityHurt(keys)
    --react to entities taking damage
    --keys.entindex_inflictor        entindex of ability if caused by (not exist if autoattack)
    --keys.damagebits         no idea
    --keys.game_event_listener        never needed
    --keys.game_event_name    returns name of event
    --keys.entindex_killed        victim of damage
    --keys.damage     amount of damage taken (actual damage compare to damage filter)
    --keys.entindex_attacker      attacker entindex
    --keys.splitscreenplayer      no idea
    if not self.activated then return end

    local victim = EntIndexToHScript(keys.entindex_killed)
    if victim ~= nil and victim == self.playerHero then
        -- player got hit, combo is lost
        -- sound can be emitted here (miss, was "sproing")
        self.combo = 1
        self:SendCounters()
        ComboTracker:Break()
        ComboTracker:Add()
        Notifications:SoundOnly("bad")
        CustomGameEventManager:Send_ServerToAllClients("aim_compet_where_mouse", {})
        --maybe take cursor position and display something here
        --[[ CustomGameEventManager:Send_ServerToAllClients("reaction_clicked", {
            time = 0, score = 'Bad!', totalscore = self.score, combo = self.combo
        }) ]]
        print("Hero took damage")
    end
end

function aim_compet:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    -- CustomGameEventManager:Send_ServerToAllClients("aim_compet_spell_table", self.spellTable)
end

-- stops timers, removes wards, border particles and trees; also used before a retry (was aimClear)
function aim_compet:Clear()
    self.activated = false
    self.results = {}
    self.wardPool = {}
    self.score = 0
    self.combo = 1
    ComboTracker:Deactivate()
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)

    if self.box ~= nil then
        for _, v in pairs(self.box) do
            ParticleManager:DestroyParticle(v, true)
            ParticleManager:ReleaseParticleIndex(v)
        end
        self.box = nil
    end

    for _, v in pairs(self.wards) do
        if not v:IsNull() then
            v:RemoveSelf()
        end
    end
    self.wards = {}

    Timers:RemoveTimer(TIMER_WARD_CYCLE)
    Timers:RemoveTimer(TIMER_DISPLAY)
end

function aim_compet:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function aim_compet:Deactivate()
    
    self:Clear()
    self.activated = false
    self.deactivateCalled = false
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

aim_compet:Init()
GamemodeManager:RegisterMode(aim_compet.name, aim_compet, aim_compet.type)