if aim_compet == nil then
    aim_compet = class({})
end

local PLAYER_HERO_NAME = "npc_dota_hero_pangolier"
local DEFAULT_TARGET_HERO = "npc_dota_hero_axe"
local DEFAULT_TARGET_UNIT = "npc_dota_observer_wards"

-- The menu requests this catalogue instead of keeping its own list of units.
-- icon may point at a base Dota unit when a custom unit has no portrait of its own.
local TARGET_UNITS = {
    {name = "npc_dota_observer_wards", label = "#aimUnitObserverWard"},
    {name = "npc_dota_sentry_wards", label = "#aimUnitSentryWard"},
    {name = "npc_dota_creep_badguys_melee", label = "#aimUnitMeleeCreep"},
    {name = "npc_dota_creep_badguys_ranged", label = "#aimUnitRangedCreep"},
    {name = "npc_dota_badguys_siege", label = "#aimUnitSiegeCreep"},
    {
        name = "npc_dota_neutral_centaur_khan_custom",
        label = "#aimTargetCentaur",
        icon = "npc_dota_neutral_centaur_khan",
    },
}
local TARGET_UNIT_BY_NAME = {}
for _, entry in ipairs(TARGET_UNITS) do
    TARGET_UNIT_BY_NAME[entry.name] = entry
end

-- Every enabled color owns a target type. A blade only destroys targets of the
-- same color; using it on any other color is a normal failed click.
local TARGET_COLORS = {
    {
        name = "yellow", item = "item_aim_topor", render = {255, 215, 40},
        abilities = {"aim_compet_topor_ability", "aim_compet_topor_ability_2", "aim_compet_topor_ability_3", "aim_compet_topor_ability_4"},
    },
    {
        name = "blue", item = "item_aim_topor2", render = {0, 89, 255},
        abilities = {"aim_compet_topor2_ability", "aim_compet_topor2_ability_2", "aim_compet_topor2_ability_3", "aim_compet_topor2_ability_4"},
    },
    {
        name = "green", item = "item_aim_topor3", render = {40, 220, 80},
        abilities = {"aim_compet_topor3_ability", "aim_compet_topor3_ability_2", "aim_compet_topor3_ability_3", "aim_compet_topor3_ability_4"},
    },
    {
        name = "red", item = "item_aim_topor4", render = {255, 55, 55},
        abilities = {"aim_compet_topor4_ability", "aim_compet_topor4_ability_2", "aim_compet_topor4_ability_3", "aim_compet_topor4_ability_4"},
    },
}

local ITEM_COLOR_INDEX = {}
for colorIndex, color in ipairs(TARGET_COLORS) do
    ITEM_COLOR_INDEX[color.item] = colorIndex
    for _, abilityName in ipairs(color.abilities) do
        ITEM_COLOR_INDEX[abilityName] = colorIndex
    end
end

local TIMER_DISPLAY = "aim_compet_time_display"
local TIMER_TARGET_CYCLE = "aim_compet_target_cycle"

local DEFAULT_ROUND_TIME = 60
local MIN_ROUND_TIME, MAX_ROUND_TIME = 10, 600
local MIN_INTERVAL, MAX_INTERVAL = 0.1, 3
local MIN_EXPONENT, MAX_EXPONENT = 0.2, 5
local CLASSIC_DECAY = 0.08
local TARGET_CAP = 500
local TARGET_HP = 200
local TARGET_DECAY_TICK = 0.1
local DEFAULT_TARGET_LIFETIME = 2.0
local MIN_TARGET_LIFETIME, MAX_TARGET_LIFETIME = 0.5, 5
local MIN_MOVE_SPEED, MAX_MOVE_SPEED = 50, 2000
local MAX_MOVE_SPEED_RAMP = 1000
local MIN_MODEL_SCALE, MAX_MODEL_SCALE = 0.2, 2.0
local MOVEMENT_WAYPOINTS = 10

local DEFAULT_TRAINING_PLACE = Vector(-5065, 4226, 128)
local AREA_PRESETS = {
    classic = {
        minX = -750, minY = -350, maxX = 750, maxY = 650,
        origin = DEFAULT_TRAINING_PLACE,
        vision = 1200, castRange = 1200, treeRadius = 1500,
    },
    all_map = {
        minX = -6000, minY = -6000, maxX = 6000, maxY = 6000,
        origin = Vector(0, 0, 128),
        vision = 16000, castRange = 20000, treeRadius = 12000,
    },
}

local HERO_MIN_RANGE = 350
local TARGET_MIN_GAP = 300
local RECENT_TARGETS = 6
local MAX_PLACE_ATTEMPTS = 50

local BOUNDING_AREA_PARTICLE = "particles/ui_mouseactions/bounding_area_view.vpcf"

local function GroundPoint(x, y)
    return GetGroundPosition(Vector(x, y, 0), nil)
end

local function DrawGroundBox(minVec, maxVec)
    local c1 = GroundPoint(minVec.x, minVec.y)
    local c2 = GroundPoint(minVec.x, maxVec.y)
    local c3 = GroundPoint(maxVec.x, maxVec.y)
    local c4 = GroundPoint(maxVec.x, minVec.y)

    local fx = ParticleManager:CreateParticle(BOUNDING_AREA_PARTICLE, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, c1)
    ParticleManager:SetParticleControl(fx, 1, c2)
    ParticleManager:SetParticleControl(fx, 2, c3)
    ParticleManager:SetParticleControl(fx, 3, c4)
    ParticleManager:SetParticleControl(fx, 15, Vector(75, 0, 130))
    ParticleManager:SetParticleControl(fx, 16, Vector(1, 0, 0))
    return {fx}
end

-- Own seedable RNG so spawn positions, colors, paths and speeds are reproducible.
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
    function rng:Int(min, max)
        return min + math.floor((self:Next() - 1) / (RNG_MOD - 1) * (max - min + 1))
    end

    for _ = 1, 10 do rng:Next() end
    return rng
end

local function DaysFromCivil(y, m, d)
    if m <= 2 then y = y - 1 end
    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local mp = (m > 2) and (m - 3) or (m + 9)
    local doy = math.floor((153 * mp + 2) / 5) + d - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return era * 146097 + doe - 719468
end

local function ClampNumber(v, lo, hi)
    v = tonumber(v)
    if v == nil or v ~= v then return nil end
    return math.min(hi, math.max(lo, v))
end

local function EventBool(value)
    return value == true or value == 1 or value == "1"
end

local function DefaultBladeSettings()
    return {
        targetType = "unit",
        targetName = DEFAULT_TARGET_UNIT,
        moving = false,
        moveSpeedMin = 600,
        moveSpeedMax = 1500,
        moveSpeedRamp = 0,
        modelScaleStart = 1.0,
        modelScaleEnd = 1.0,
    }
end

function aim_compet:Init()
    self.type = "sandbox"
    self.name = "aim_compet"
    self.activated = false
    self.Player = nil
    self.playerHeroName = PLAYER_HERO_NAME
    self.playerHero = nil
    self.trainingPlaceDefault = DEFAULT_TRAINING_PLACE
    self.trainingPlace = self.trainingPlaceDefault
    self.startDelay = 3

    self.results = {}
    self.targets = {}
    self.targetRecords = {}
    self.box = nil
    self.mapVisionTimer = nil
    self.score = 0
    self.combo = 1
    self.maxCombo = 1
    self.avgTime = 0
    self.hits = 0
    self.misses = 0
    self.timeLeft = DEFAULT_ROUND_TIME
    self.roundTime = DEFAULT_ROUND_TIME
    self.spawnCurve = nil
    self.spawnSchedule = {}
    self.targetLifetime = DEFAULT_TARGET_LIFETIME
    self.targetHpDecay = TARGET_HP * TARGET_DECAY_TICK / DEFAULT_TARGET_LIFETIME

    self.areaPreset = "classic"
    self.area = AREA_PRESETS.classic
    self.itemCount = 1
    self.colorTargets = true
    self.unitTable = TARGET_UNITS
    self.bladeSettings = {}
    for i = 1, #TARGET_COLORS do
        self.bladeSettings[i] = DefaultBladeSettings()
    end
    self.castRange = AREA_PRESETS.classic.castRange
    self.treeRadius = AREA_PRESETS.classic.treeRadius

    self.seed = nil
    self.spawnPlan = {}
    self.useSeed = false
    self.customSeed = nil
    self.argsKeeper = nil

    CustomGameEventManager:RegisterListener("aim_compet_training_end", function()
        aim_compet:PrepareDeactivate()
    end)
    CustomGameEventManager:RegisterListener("aim_compet_training_retry", function()
        if aim_compet.argsKeeper == nil then return end
        aim_compet.argsKeeper.retry = 1
        aim_compet:StartGame(aim_compet.argsKeeper)
    end)
    CustomGameEventManager:RegisterListener("get_aim_compet_seed", function()
        aim_compet:SendSeed()
    end)
    CustomGameEventManager:RegisterListener("get_aim_compet_unit_table", function()
        aim_compet:SendUnitTable()
    end)
    CustomGameEventManager:RegisterListener("aim_compet_set_seed", function(_, event)
        aim_compet:SetSeed(event.seed)
    end)
    CustomGameEventManager:RegisterListener("aim_compet_show_miss", function(_, event)
        aim_compet:ShowMiss(event.position)
    end)
    CustomGameEventManager:RegisterListener("aim_compet_set_use_seed", function(_, event)
        aim_compet:SetUseSeed(EventBool(event.value))
    end)

    self.deactivateCalled = false
    print("aim_compet inited")
end

function aim_compet:HasAllBladeBindings(args)
    args = args or {}
    local itemCount = math.floor(ClampNumber(args.itemCount, 1, #TARGET_COLORS) or 1)
    local bound = {}
    local slotGroups = {
        SlotsArray(args.aimAbilitySlots, 4),
        SlotsArray(args.aimItemSlots, 6),
    }

    for _, slots in ipairs(slotGroups) do
        for _, itemName in pairs(slots) do
            local colorIndex = ITEM_COLOR_INDEX[itemName]
            if colorIndex ~= nil and colorIndex <= itemCount then
                bound[colorIndex] = true
            end
        end
    end

    for i = 1, itemCount do
        if not bound[i] then return false end
    end
    return true
end

function aim_compet:Prepare(args)
    --[[ if not self:HasAllBladeBindings(args) then
        print("[aim_compet] Launch blocked: every enabled blade must be bound")
        CustomGameEventManager:Send_ServerToAllClients("aim_compet_config_error", {
            message = "#aimBladeBindingError",
        })
        return
    end ]]

    print("[aim_compet] Preparing gamemode")
    precache:clearTable()

    local unitsToPrecache = {PLAYER_HERO_NAME}
    local unitsAdded = {[PLAYER_HERO_NAME] = true}
    for _, entry in ipairs(TARGET_UNITS) do
        table.insert(unitsToPrecache, entry.name)
        unitsAdded[entry.name] = true
    end
    for _, blade in ipairs(self:ParseBladeSettings(args)) do
        if blade.targetType == "hero" and not unitsAdded[blade.targetName] then
            table.insert(unitsToPrecache, blade.targetName)
            unitsAdded[blade.targetName] = true
        end
    end
    precache:PrecacheAddUnitToList(unitsToPrecache)
    precache:PrecacheAddPlayerUnitToList({PLAYER_HERO_NAME})

    self.pendingArgs = args or {}
    precache:doPrecache(function()
        aim_compet:StartGame(aim_compet.pendingArgs)
    end)
end

function aim_compet:StartGame(args)
    args = args or {}
    self.argsKeeper = args
    local retry = args.retry == 1
    local playerID = args.PlayerID or 0

    if retry then
        print("[aim_compet] Retry")
        self:Clear()
    end
    self:ReadRoundSettings(args)

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})

    self.results = {}
    self.targets = {}
    self.targetRecords = {}
    self.score = 0
    self.combo = 1
    self.maxCombo = 1
    self.avgTime = 0
    self.hits = 0
    self.misses = 0
    self.timeLeft = self.roundTime
    self.activated = true
    self:SendCounters()

    self.Player = PlayerResource:GetPlayer(playerID)
    local hero = self.Player:GetAssignedHero()
    if not retry then
        hero = replaceHero(hero, PLAYER_HERO_NAME)
        removeItems(hero)
    end
    self.playerHero = hero

    self.trainingPlace = GetGroundPosition(self.area.origin, nil)
    hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:SetDayTimeVisionRange(self.area.vision)
    hero:SetNightTimeVisionRange(self.area.vision)
    hero:SetAbsOrigin(self.trainingPlace)
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, self.treeRadius, true)
    hero:SetBaseHealthRegen(10)

    if self.areaPreset == "all_map" then
        self.mapVisionTimer = createTempVision(12000, DOTA_TEAM_GOODGUYS, self.trainingPlace, false)
    end

    if not retry then
        self:SetupTopor(hero, args)
    end

    self.seed = self:ResolveSeed(args)
    self.spawnSchedule = self:ComputeSpawnSchedule()
    self.spawnPlan = self:GenerateSpawnPlan(self.seed, #self.spawnSchedule)
    local movingBlades = 0
    for i = 1, self.itemCount do
        if self.bladeSettings[i].moving then movingBlades = movingBlades + 1 end
    end
    print("[aim_compet] seed:", self.seed, "targets planned:", #self.spawnSchedule,
        "zone:", self.areaPreset, "colors:", self.itemCount, "moving blades:", movingBlades)
    self:SendSeed()

    self:StartTimeDisplay()
    self:StartTargetCycle()
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_countdown_start", {})

    local origin = hero:GetAbsOrigin()
    self.box = DrawGroundBox(
        origin + Vector(self.area.minX, self.area.minY, 0),
        origin + Vector(self.area.maxX, self.area.maxY, 0)
    )

    ComboTracker:Configure({active = true, anchor = "bottom_right", timeout = 2, tiers = {10, 25, 50, 75, 100, 120}})
    ComboTracker:Add()
end

local function SlotsArray(arg, count)
    local result = {}
    if type(arg) == "table" then
        for i = 0, count - 1 do
            result[i + 1] = arg[tostring(i)]
        end
    end
    return result
end

function aim_compet:ParseBladeSettings(args)
    local requested = SlotsArray(args and args.aimBladeSettings, #TARGET_COLORS)
    local result = {}

    for i = 1, #TARGET_COLORS do
        local entry = requested[i]
        if type(entry) ~= "table" then entry = {} end
        local blade = DefaultBladeSettings()

        blade.targetType = tostring(entry.targetType or "unit") == "hero" and "hero" or "unit"
        local requestedName = tostring(entry.targetName or "")
        if blade.targetType == "hero" then
            if requestedName ~= "npc_dota_hero_target_dummy" and DotaDB:GetHeroKV(requestedName) ~= nil then
                blade.targetName = requestedName
            else
                blade.targetName = DEFAULT_TARGET_HERO
            end
        else
            blade.targetName = TARGET_UNIT_BY_NAME[requestedName] ~= nil and requestedName or DEFAULT_TARGET_UNIT
        end

        blade.moving = EventBool(entry.moving)
        blade.moveSpeedMin = ClampNumber(entry.moveSpeedMin, MIN_MOVE_SPEED, MAX_MOVE_SPEED) or 600
        blade.moveSpeedMax = ClampNumber(entry.moveSpeedMax, MIN_MOVE_SPEED, MAX_MOVE_SPEED) or 1500
        if blade.moveSpeedMin > blade.moveSpeedMax then
            blade.moveSpeedMin, blade.moveSpeedMax = blade.moveSpeedMax, blade.moveSpeedMin
        end
        blade.moveSpeedRamp = ClampNumber(entry.moveSpeedRamp, 0, MAX_MOVE_SPEED_RAMP) or 0
        blade.modelScaleStart = ClampNumber(entry.modelScaleStart, MIN_MODEL_SCALE, MAX_MODEL_SCALE) or 1.0
        blade.modelScaleEnd = ClampNumber(entry.modelScaleEnd, MIN_MODEL_SCALE, MAX_MODEL_SCALE) or 1.0
        result[i] = blade
    end

    return result
end

function aim_compet:SetupTopor(hero, args)
    local abilitySlots = SlotsArray(args and args.aimAbilitySlots, 4)
    local itemSlots = SlotsArray(args and args.aimItemSlots, 6)

    -- Native abilities interfere with both the custom slots and their Q/W/E/R bindings.
    -- Collect names first so removing one ability cannot shift the next one past our loop.
    local nativeAbilities = {}
    for i = 0, 6 do
        local nativeAbility = hero:GetAbilityByIndex(i)
        if nativeAbility ~= nil then
            table.insert(nativeAbilities, nativeAbility:GetAbilityName())
        end
    end
    for _, abilityName in ipairs(nativeAbilities) do
        hero:RemoveAbility(abilityName)
    end

    for i = 1, 4 do
        local itemName = abilitySlots[i]
        local colorIndex = ITEM_COLOR_INDEX[itemName]
        if colorIndex ~= nil and colorIndex <= self.itemCount then
            local ability = hero:AddAbility(TARGET_COLORS[colorIndex].abilities[i])
            if ability ~= nil then
                ability:SetLevel(1)
                ability:SetAbilityIndex(i - 1)
                if i==4 then
                    ability:SetAbilityIndex(5)
                end
                ability:SetHidden(false)
            end
        end
    end

    for i = 1, 6 do
        local itemName = itemSlots[i]
        local colorIndex = ITEM_COLOR_INDEX[itemName]
        if colorIndex ~= nil and colorIndex <= self.itemCount then
            local item = CreateItem(itemName, hero, hero)
            if item ~= nil then
                hero:AddItem(item)
                local desired = i - 1
                local current = item:GetItemSlot()
                if current >= 0 and current ~= desired then
                    hero:SwapItems(current, desired)
                end
            end
        end
    end
end

function aim_compet:GetToporCastRange()
    return self.castRange or AREA_PRESETS.classic.castRange
end

function aim_compet:FailToporClick(ability, hero)
    ApplyDamage({
        victim = hero,
        attacker = hero,
        damage = 1,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = ability,
    })
end

function aim_compet:UseTopor(ability)
    if not self.activated then return end
    local hero = ability:GetCaster()
    if hero ~= self.playerHero then return end

    local target = nil
    if not ability:GetCursorTargetingNothing() then
        target = ability:GetCursorTarget()
    end

    if target ~= nil and not target:IsNull() and target:IsAlive() then
        local record = self.targetRecords[target:entindex()]
        local bladeColor = ITEM_COLOR_INDEX[ability:GetAbilityName()]
        if record ~= nil and not record.resolved and bladeColor == record.colorIndex then
            target:Kill(ability, hero)
            return
        end
    end

    -- Ground clicks, non-targets and wrong-color blades all count as a fail.
    self:FailToporClick(ability, hero)
end

function aim_compet:StartTimeDisplay()
    Timers:CreateTimer(TIMER_DISPLAY, {
        useGameTime = true,
        endTime = self.startDelay,
        callback = function()
            if not self.activated then return nil end

            CustomGameEventManager:Send_ServerToAllClients("reaction_timer", {time = self.timeLeft})
            self:SendCounters()
            self.timeLeft = self.timeLeft - 1

            if self.timeLeft == -1 then
                self:OnRoundEnd()
                return nil
            end
            return 1
        end,
    })
end

function aim_compet:OnRoundEnd()
    self.activated = false
    Timers:RemoveTimer(TIMER_TARGET_CYCLE)

    for _, target in pairs(self.targets) do
        if not target:IsNull() and target:IsAlive() then
            target:RemoveSelf()
        end
    end
    self.targets = {}
    self.targetRecords = {}

    local total = self.hits + self.misses
    local hitRate = 0
    if total > 0 then
        hitRate = math.floor(self.hits / total * 100)
    end
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_round_results", {
        score = self.score,
        maxCombo = self.maxCombo,
        hits = self.hits,
        misses = self.misses,
        hitRate = hitRate,
        avgTime = self.avgTime,
        reactionTimes = self.results,
    })
    print("[aim_compet] targets destroyed:", #self.results)
end

local CURVE_TYPES = {classic = true, constant = true, linear = true, power = true}

function aim_compet:ReadRoundSettings(args)
    args = args or {}
    self.roundTime = ClampNumber(args.roundTime, MIN_ROUND_TIME, MAX_ROUND_TIME) or DEFAULT_ROUND_TIME

    local curveType = tostring(args.spawnCurveType or "classic")
    if not CURVE_TYPES[curveType] then curveType = "classic" end
    self.spawnCurve = {
        type = curveType,
        startInterval = ClampNumber(args.spawnStartInterval, MIN_INTERVAL, MAX_INTERVAL) or 2.0,
        endInterval = ClampNumber(args.spawnEndInterval, MIN_INTERVAL, MAX_INTERVAL) or 0.4,
        exponent = ClampNumber(args.spawnExponent, MIN_EXPONENT, MAX_EXPONENT) or 2,
    }

    self.targetLifetime = ClampNumber(args.targetLifetime or args.wardLifetime,
        MIN_TARGET_LIFETIME, MAX_TARGET_LIFETIME) or DEFAULT_TARGET_LIFETIME
    self.targetHpDecay = TARGET_HP * TARGET_DECAY_TICK / self.targetLifetime

    local areaPreset = tostring(args.spawnArea or "classic")
    if AREA_PRESETS[areaPreset] == nil then areaPreset = "classic" end
    self.areaPreset = areaPreset
    self.area = AREA_PRESETS[areaPreset]
    self.castRange = self.area.castRange
    self.treeRadius = self.area.treeRadius

    self.itemCount = math.floor(ClampNumber(args.itemCount, 1, #TARGET_COLORS) or 1)
    self.bladeSettings = self:ParseBladeSettings(args)
    self.colorTargets = args.colorTargets == nil or EventBool(args.colorTargets)

    -- Identical targets must remain distinguishable even when colors were disabled.
    local targetNames = {}
    for i = 1, self.itemCount do
        local targetName = self.bladeSettings[i].targetName
        if targetNames[targetName] then
            self.colorTargets = true
            break
        end
        targetNames[targetName] = true
    end
end

function aim_compet:ComputeSpawnSchedule()
    local curve = self.spawnCurve
    local duration = self.roundTime
    local times = {0}
    local t = 0
    local classicInterval = curve.startInterval

    while #times < TARGET_CAP do
        local dt
        if curve.type == "classic" then
            dt = classicInterval
            classicInterval = math.max(curve.endInterval, classicInterval - CLASSIC_DECAY)
        else
            local progress = math.min(1, t / duration)
            if curve.type == "constant" then
                dt = curve.startInterval
            elseif curve.type == "power" then
                dt = curve.startInterval + (curve.endInterval - curve.startInterval) * progress ^ curve.exponent
            else
                dt = curve.startInterval + (curve.endInterval - curve.startInterval) * progress
            end
        end
        dt = math.max(0.05, dt)
        t = t + dt
        if t > duration - self.targetLifetime then break end
        table.insert(times, t)
    end
    return times
end

function aim_compet:StartTargetCycle()
    local schedule = self.spawnSchedule
    local idx = 0

    Timers:CreateTimer(TIMER_TARGET_CYCLE, {
        useGameTime = true,
        endTime = self.startDelay,
        callback = function()
            if not self.activated then return nil end

            idx = idx + 1
            self:SpawnTarget(schedule[idx], self.spawnPlan[idx])
            if idx >= #schedule then return nil end
            return schedule[idx + 1] - schedule[idx]
        end,
    })
end

function aim_compet:SpawnTarget(spawnTime, plan)
    if plan == nil then return end
    local origin = self.playerHero:GetAbsOrigin()
    local pos = GetGroundPosition(origin + plan.offset, nil)
    local colorIndex = plan.colorIndex
    local blade = self.bladeSettings[colorIndex] or DefaultBladeSettings()
    local color = TARGET_COLORS[colorIndex]

    local target = CreateUnitByName(blade.targetName, pos, true, nil, nil, DOTA_TEAM_BADGUYS)
    if target == nil then return end

    target:SetDeathXP(0)
    target:SetMinimumGoldBounty(0)
    target:SetMaximumGoldBounty(0)
    target:SetBaseHealthRegen(0)
    target:SetMaxHealth(TARGET_HP)
    target:SetHealth(TARGET_HP)
    target:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    if target.SetIdleAcquire ~= nil then target:SetIdleAcquire(false) end
    if self.colorTargets then
        target:SetRenderColor(color.render[1], color.render[2], color.render[3])
    end

    local progress = math.min(1, math.max(0, spawnTime / self.roundTime))
    local scale = blade.modelScaleStart + (blade.modelScaleEnd - blade.modelScaleStart) * progress
    target:SetModelScale(scale)

    -- Some created hero entities do not expose SetCanRespawn in VScript.
    if target:IsHero() and target.SetCanRespawn ~= nil then
        target:SetCanRespawn(false)
    end

    if blade.moving then
        local maxSpeed = blade.moveSpeedMax + blade.moveSpeedRamp * progress
        local speed = blade.moveSpeedMin + (maxSpeed - blade.moveSpeedMin) * plan.speedFraction
        target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        target:SetBaseMoveSpeed(speed)
        for i, offset in ipairs(plan.waypoints) do
            ExecuteOrderFromTable({
                UnitIndex = target:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = GetGroundPosition(origin + offset, nil),
                Queue = i > 1,
            })
        end
    else
        target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
    end

    table.insert(self.targets, target)
    self:RegisterTarget(target, colorIndex)
end

function aim_compet:RegisterTarget(target, colorIndex)
    local index = target:entindex()
    if self.targetRecords[index] ~= nil then return end
    self.targetRecords[index] = {
        entity = target,
        spawnTime = Time(),
        colorIndex = colorIndex,
        resolved = false,
    }
    self:StartTargetDecay(target)
end

function aim_compet:StartTargetDecay(target)
    Timers:CreateTimer({
        useGameTime = false,
        endTime = TARGET_DECAY_TICK,
        callback = function()
            if not self.activated or target:IsNull() or not target:IsAlive() then return nil end
            local record = self.targetRecords[target:entindex()]
            if record == nil or record.resolved then return nil end

            local newHp = target:GetHealth()
            if newHp - self.targetHpDecay <= 0 then
                self:ExpireTarget(target)
            else
                target:ModifyHealth(newHp - self.targetHpDecay, nil, true, 0)
            end
            return TARGET_DECAY_TICK
        end,
    })
end

function aim_compet:ExpireTarget(target)
    local index = target:entindex()
    local record = self.targetRecords[index]
    if record == nil or record.resolved then return end

    record.resolved = true
    self:OnTargetMiss(target)
    target:ForceKill(false)
    if self.targetRecords[index] ~= nil then
        self.targetRecords[index] = nil
        if not target:IsNull() then target:RemoveSelf() end
    end
end

function aim_compet:GetWeeklySeed()
    local m, d, y = string.match(GetSystemDate(), "(%d+)/(%d+)/(%d+)")
    m, d, y = tonumber(m), tonumber(d), tonumber(y)
    if m == nil or d == nil or y == nil then
        print("[aim_compet] Could not read system date, using fallback seed")
        return 1
    end
    if y < 100 then y = y + 2000 end
    return math.floor((DaysFromCivil(y, m, d) + 3) / 7)
end

function aim_compet:ResolveSeed(args)
    if args and args.seed then
        local seed = tonumber(args.seed)
        if seed then return math.floor(seed) end
    end
    if self.useSeed then
        return self.customSeed or self:GetWeeklySeed()
    end
    return RandomInt(1, RNG_MOD - 1)
end

function aim_compet:SetSeed(seed)
    local value = tonumber(seed)
    if value == nil then
        print("[aim_compet] SetSeed: invalid seed", seed)
        return false
    end
    self.customSeed = math.floor(value)
    self.useSeed = true
    self:SendSeed()
    return true
end

function aim_compet:ClearSeed()
    self.customSeed = nil
    self:SendSeed()
end

function aim_compet:SetUseSeed(enabled)
    self.useSeed = enabled and true or false
    self:SendSeed()
end

function aim_compet:SendSeed()
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_seed", {
        seed = self.seed,
        customSeed = self.customSeed,
        enabled = self.useSeed,
    })
end

function aim_compet:SendUnitTable()
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_unit_table", {data = self.unitTable})
end

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
        timeLeft = math.max(0, self.timeLeft),
    })
end

function aim_compet:GenerateSpawnPlan(seed, count)
    local rng = NewRng(seed)
    local plan = {}

    local function RandomOffset()
        return Vector(
            rng:Int(self.area.minX, self.area.maxX),
            rng:Int(self.area.minY, self.area.maxY),
            0
        )
    end

    for i = 1, count do
        local best, bestGap = nil, -1
        for _ = 1, MAX_PLACE_ATTEMPTS do
            local offset = RandomOffset()
            if offset:Length2D() > HERO_MIN_RANGE then
                local gap = math.huge
                for j = math.max(1, i - RECENT_TARGETS), i - 1 do
                    gap = math.min(gap, (offset - plan[j].offset):Length2D())
                end
                if gap >= TARGET_MIN_GAP then
                    best = offset
                    break
                end
                if gap > bestGap then
                    best, bestGap = offset, gap
                end
            end
        end

        plan[i] = {
            offset = best or Vector(HERO_MIN_RANGE + 150, 0, 0),
            colorIndex = rng:Int(1, self.itemCount),
            speedFraction = rng:Next() / RNG_MOD,
            waypoints = {},
        }
        for j = 1, MOVEMENT_WAYPOINTS do
            plan[i].waypoints[j] = RandomOffset()
        end
    end
    return plan
end

function aim_compet:ShowMiss(position)
    if type(position) ~= "table" then return end
    local x, y, z = tonumber(position["0"]), tonumber(position["1"]), tonumber(position["2"])
    if x == nil or y == nil or z == nil then return end
    ParticleMessage:ShowMissSignAtPosition(Vector(x, y, z), Vector(0, 0, 30), ParticleMessage.colors.red)
end

function aim_compet:OnEntityKilled(keys)
    if not self.activated then return end
    local index = keys.entindex_killed
    local record = self.targetRecords[index]
    if record == nil then return end

    local killedUnit = EntIndexToHScript(index)
    if killedUnit == nil or killedUnit:IsNull() then
        self.targetRecords[index] = nil
        return
    end

    if not record.resolved then
        record.resolved = true
        local killer = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker) or nil
        if killer ~= nil and not killer:IsNull() and killer == self.playerHero then
            self:OnTargetHit(killedUnit, record)
        else
            self:OnTargetMiss(killedUnit)
        end
    end

    self.targetRecords[index] = nil
    killedUnit:RemoveSelf()
end

function aim_compet:OnTargetMiss(target)
    self.combo = 1
    self.misses = self.misses + 1
    self:SendCounters()
    ComboTracker:Break()
    ComboTracker:Add()
    ParticleMessage:ShowUnluckySign(target, Vector(0, 0, 50), ParticleMessage.colors.red)
    Notifications:SoundOnly("bad")
end

function aim_compet:OnTargetHit(target, record)
    local reactionTime = math.max(0.01, Time() - record.spawnTime)

    self.combo = self.combo + 1
    if self.combo > self.maxCombo then
        self.maxCombo = self.combo
    end

    local score = math.ceil(100 / reactionTime) * self.combo
    self.score = self.score + score

    table.insert(self.results, reactionTime)
    local sum = 0
    for _, time in pairs(self.results) do
        sum = sum + time
    end
    self.avgTime = sum / #self.results
    self.hits = self.hits + 1
    self:SendCounters()
    ComboTracker:Add()

    local displayDelay = math.floor(reactionTime * 1000) / 1000
    ParticleMessage:ShowNumber(target, Vector(0, 0, 50), displayDelay, ParticleMessage.colors.green, false)
    Notifications:SoundOnly("good")
end

function aim_compet:OnEntityHurt(keys)
    if not self.activated then return end
    local victim = EntIndexToHScript(keys.entindex_killed)
    if victim == nil or victim ~= self.playerHero then return end

    self.combo = 1
    self:SendCounters()
    ComboTracker:Break()
    ComboTracker:Add()
    Notifications:SoundOnly("bad")
    CustomGameEventManager:Send_ServerToAllClients("aim_compet_where_mouse", {})
end

function aim_compet:Clear()
    self.activated = false
    self.results = {}
    self.targetRecords = {}
    self.score = 0
    self.combo = 1
    ComboTracker:Deactivate()

    if self.mapVisionTimer ~= nil then
        Timers:RemoveTimer(self.mapVisionTimer)
        self.mapVisionTimer = nil
    end

    GridNav:DestroyTreesAroundPoint(self.trainingPlace, self.treeRadius, true)

    if self.box ~= nil then
        for _, particle in pairs(self.box) do
            ParticleManager:DestroyParticle(particle, true)
            ParticleManager:ReleaseParticleIndex(particle)
        end
        self.box = nil
    end

    for _, target in pairs(self.targets) do
        if not target:IsNull() then
            target:RemoveSelf()
        end
    end
    self.targets = {}

    Timers:RemoveTimer(TIMER_TARGET_CYCLE)
    Timers:RemoveTimer(TIMER_DISPLAY)
end

function aim_compet:PrepareDeactivate()
    self.deactivateCalled = true
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
