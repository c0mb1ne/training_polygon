if glimpse_dodge == nil then
    glimpse_dodge = class({})
end

function glimpse_dodge:Init()
    self.type = "sandbox"
    self.name = "glimpse_dodge"
    self.activated = false
    self.Player = nil
    self.playerHero = nil
    self.trainingPlaceDefault = Vector(-2111.1826171875, -6378.5185546875, 128)
    self.trainingPlace = self.trainingPlaceDefault

    -- castPoint is the part of the dodge that must finish before Glimpse ends.
    -- dodgeWindow is the invulnerability time that must cover Glimpse's end.
    self.spellTable = {
        item_manta = {
            hero_name = "from_js",
            is_ability = false,
            castPoint = 0,
            dodgeWindow = 0.1
        },
        chaos_knight_phantasm = {
            hero_name = "npc_dota_hero_chaos_knight",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("chaos_knight_phantasm", {"AbilityCastPoint"}, "0.4"),
            dodgeWindow = DotaDB:GetAbilityValue("chaos_knight_phantasm", {"AbilityValues", "invuln_duration"}, "0.5")
        },
        --raptor dance only dodge damage from glimpse, not relocating
        --[[ kez_raptor_dance = {
            hero_name = "npc_dota_hero_kez",
            is_ability = true,
            level = 1,
            castPoint = 0,
            dodgeWindow = DotaDB:GetAbilityValue("kez_raptor_dance", {"AbilityValues", "invuln_period"}, "0.2"),
            damageOnly=true
        }, ]]
        kez_echo_slash = {
            hero_name = "npc_dota_hero_kez",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("kez_echo_slash", {"AbilityCastPoint"}, "0.2"),
            dodgeWindow = 0.1,
            timebarDisabled=true
        },
        naga_siren_mirror_image = {
            hero_name = "npc_dota_hero_naga_siren",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("naga_siren_mirror_image", {"AbilityCastPoint"}, "0.65"),
            dodgeWindow = DotaDB:GetAbilityValue("naga_siren_mirror_image", {"AbilityValues", "invuln_duration"}, "0.3")
        },
        shredder_timber_chain = {
            hero_name = "npc_dota_hero_shredder",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("shredder_timber_chain", {"AbilityCastPoint"}, "0.3"),
            dodgeWindow = 0.1,
            timebarDisabled=true
        },
        chaos_knight_phantasm = {
            hero_name = "npc_dota_hero_chaos_knight",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("chaos_knight_phantasm", {"AbilityCastPoint"}, "0.4"),
            dodgeWindow = DotaDB:GetAbilityValue("chaos_knight_phantasm", {"AbilityValues", "invuln_duration"}, "0.5")
        },
        sandking_burrowstrike = {
            hero_name = "npc_dota_hero_sand_king",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("sandking_burrowstrike", {"AbilityCastPoint"}, "0.0"),
            dodgeWindow = 0.1 --probably need calcualation but im lazy
        },
        phantom_lancer_doppelwalk = {
            hero_name = "npc_dota_hero_phantom_lancer",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("phantom_lancer_doppelwalk", {"AbilityCastPoint"}, "0.1"),
            dodgeWindow = DotaDB:GetAbilityValue("phantom_lancer_doppelwalk", {"AbilityValues", "delay"}, "0.5"),
        },
        --[[ bane_nightmare = {
            hero_name = "npc_dota_hero_bane",
            is_ability = true,
            level = 1,
            castPoint = DotaDB:GetAbilityValue("bane_nightmare", {"AbilityCastPoint"}, "0.4"),
            dodgeWindow = 1
        } ]]
    }

    -- Cast pacing. A cast needs both the delay and movement requirements met.
    self.movementDistanceToCast = 600
    self.initialCastDelay = 4
    self.minimumCastDelay = 1
    self.maximumCastDelay = 5
    self.castDelayDecreaseOnSuccess = 0.25
    self.castDelayIncreaseOnFail = 0.5

    self.glimpseProjectileSpeed = 600
    self.glimpseMaxTravelTime = 1.8
    self.castOrderTimeout = 3
    self.castRetryDelay = 0.25
    self.endWatchdogGrace = 0.25
    self.disruptorCastRange = 1500
    self.disruptorSpawnMinRange = 700
    self.disruptorSpawnMaxRange = 1100
    self.teleportVerifyRadius = 64

    self.currentDodgeType = nil
    self.selectedEntry = nil
    self.playerHeroName = nil
    self.dodgeItem = nil
    self.dodgeSpell = nil
    self.travelBootsEnabled = false
    self.travelBoots = nil
    self.travelBootsScroll = nil
    self.townPortalSlot = 15
    self.disruptor = nil
    self.glimpseAbility = nil
    self.disruptorSpawning = false
    self.deactivateCalled = false
    self.currentCastDelay = self.initialCastDelay
    self.movementAnchor = nil
    self.nextCastAt = nil
    self.nextCastTimer = nil
    self.castWatchdogTimer = nil
    self.glimpseWatchTimer = nil
    self.visionTimer = nil
    self.cycle = {id = 0, phase = "idle"}
    self.heroHurt=false
    CustomGameEventManager:RegisterListener("glimpse_dodge_training_end", function(_, event)
        glimpse_dodge:PrepareDeactivate()
    end)
    CustomGameEventManager:RegisterListener("get_glimpse_dodge_spell_table", function(_, event)
        glimpse_dodge:SendSpellTable()
    end)

    print("glimpse_dodge inited")
end

function glimpse_dodge:Prepare(args)
    args = args or {}

    local timingType = args.timingType or "item_manta"
    if self.spellTable[timingType] == nil then
        timingType = "item_manta"
    end

    local entry = self.spellTable[timingType]
    local defaultHero = tostring(args.defaultHero or "npc_dota_hero_antimage")
    if DotaDB:GetHeroKV(defaultHero) == nil then
        defaultHero = "npc_dota_hero_antimage"
    end

    self.pendingArgs = {
        timingType = timingType,
        defaultHero = defaultHero,
        travelBoots = args.travelBoots == true or args.travelBoots == 1
    }

    precache:clearTable()
    precache:PrecacheAddUnitToList({"npc_dota_hero_disruptor"})
    if entry.hero_name == "from_js" then
        precache:PrecacheAddPlayerUnitToList({defaultHero})
    else
        precache:PrecacheAddPlayerUnitToList({entry.hero_name})
    end

    precache:doPrecache(function()
        glimpse_dodge:StartGame(glimpse_dodge.pendingArgs)
    end)
end

function glimpse_dodge:StartGame(args)
    self.activated = true
    self.deactivateCalled = false
    self.currentCastDelay = self.initialCastDelay
    self.movementAnchor = nil
    self.nextCastAt = nil
    self.cycle = {id = 0, phase = "idle"}
    self.currentDodgeType = args.timingType
    self.selectedEntry = self.spellTable[self.currentDodgeType]
    self.travelBootsEnabled = args.travelBoots
    self.travelBoots = nil
    self.travelBootsScroll = nil

    self.Player = PlayerResource:GetPlayer(0)
    if self.selectedEntry.hero_name == "from_js" then
        self.playerHeroName = args.defaultHero
    else
        self.playerHeroName = self.selectedEntry.hero_name
    end

    self.playerHero = replaceHero(self.Player:GetAssignedHero(), self.playerHeroName)
    removeItems(self.playerHero)
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    self.playerHero:SetAttackCapability(0)
    self.playerHero:SetMoveCapability(1)
    self.playerHero:SetAbsOrigin(GetGroundPosition(self.trainingPlace, self.playerHero))
    FindClearSpaceForUnit(self.playerHero, self.playerHero:GetAbsOrigin(), true)

    if self.selectedEntry.is_ability then
        self.dodgeSpell = self.playerHero:FindAbilityByName(self.currentDodgeType)
        if self.dodgeSpell ~= nil then
            self.dodgeSpell:SetLevel(self.selectedEntry.level or 1)
        end
    else
        self.dodgeItem = CreateItem(self.currentDodgeType, self.playerHero, self.playerHero)
        self.playerHero:AddItem(self.dodgeItem)
    end

    if self.travelBootsEnabled then
        self.travelBoots = CreateItem("item_travel_boots", self.playerHero, self.playerHero)
        self.playerHero:AddItem(self.travelBoots)
        self.travelBootsScroll = self.playerHero:GetItemInSlot(self.townPortalSlot)
    end

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})
    Timebar:ResetLines()
    if not self.selectedEntry.timebarDisabled then
        Timebar:Show()
    end
    ComboTracker:Configure({
        active = true,
        anchor = "bottom_right",
        timeout = 2,
        tiers = {5, 10, 20, 30, 50, 100}
    })

    -- Trees and elevation no longer block the bot's ability to acquire the hero.
    self.visionTimer = Timers:CreateTimer(0, function()
        if not self.activated or not IsValidEntity(self.playerHero) then
            return nil
        end
        AddFOWViewer(DOTA_TEAM_BADGUYS, self.playerHero:GetAbsOrigin(), 1800, 1.1, false)
        return 1
    end)

    self:SpawnDisruptor()
    self:ArmNextCast(self.currentCastDelay)
end

function glimpse_dodge:FindDisruptorSpawn()
    if not IsValidEntity(self.playerHero) then
        return nil
    end

    local heroPosition = self.playerHero:GetAbsOrigin()
    for _ = 1, 24 do
        local angle = RandomFloat(0, 2 * math.pi)
        local distance = RandomFloat(self.disruptorSpawnMinRange, self.disruptorSpawnMaxRange)
        local candidate = heroPosition + Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0)
        candidate.z = GetGroundHeight(candidate, self.playerHero)

        if GridNav:IsTraversable(candidate) and not GridNav:IsBlocked(candidate) then
            return candidate
        end
    end

    return nil
end

function glimpse_dodge:SpawnDisruptor()
    if not self.activated or self.disruptorSpawning or IsValidEntity(self.disruptor) then
        return
    end

    local spawnPosition = self:FindDisruptorSpawn()
    if spawnPosition == nil then
        print("[GlimpseDodge] No walkable Disruptor spawn found; retrying")
        return
    end

    self.disruptorSpawning = true
    CreateUnitByNameAsync("npc_dota_hero_disruptor", spawnPosition, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        self.disruptorSpawning = false
        if not self.activated then
            unit:RemoveSelf()
            return
        end

        self.disruptor = unit
        unit:SetAttackCapability(0)
        unit:SetMoveCapability(0)
        unit:SetIdleAcquire(false)
        unit:SetBaseHealthRegen(300)
        unit:SetBaseManaRegen(300)
        unit:SetMaximumGoldBounty(0)
        unit:SetMinimumGoldBounty(0)
        unit:SetDeathXP(0)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnPosition):Normalized())

        self.glimpseAbility = unit:FindAbilityByName("disruptor_glimpse")
        if self.glimpseAbility == nil then
            print("[GlimpseDodge] Disruptor has no Glimpse ability")
            unit:RemoveSelf()
            self.disruptor = nil
            return
        end

        self.glimpseAbility:SetLevel(4)
    end)
end

function glimpse_dodge:MoveDisruptorIntoRange()
    if not IsValidEntity(self.disruptor) or not IsValidEntity(self.playerHero) then
        return false
    end

    local distance = (self.disruptor:GetAbsOrigin() - self.playerHero:GetAbsOrigin()):Length2D()
    if distance <= self.disruptorCastRange then
        return true
    end

    local spawnPosition = self:FindDisruptorSpawn()
    if spawnPosition == nil then
        return false
    end

    self.disruptor:SetAbsOrigin(spawnPosition)
    FindClearSpaceForUnit(self.disruptor, spawnPosition, true)
    return true
end

-- Arms one scheduler per cycle. resetMovementAnchor=false is used for cast retries,
-- so a failed order does not erase movement already made toward the next cast.
function glimpse_dodge:ArmNextCast(delay, resetMovementAnchor)
    if not self.activated then
        return
    end

    if self.nextCastTimer ~= nil then
        Timers:RemoveTimer(self.nextCastTimer)
        self.nextCastTimer = nil
    end

    self.cycle.phase = "between_casts"
    if resetMovementAnchor ~= false and IsValidEntity(self.playerHero) then
        self.movementAnchor = self.playerHero:GetAbsOrigin()
    end
    self.nextCastAt = GameRules:GetGameTime() + math.max(0, tonumber(delay) or 0)

    self.nextCastTimer = Timers:CreateTimer(0, function()
        if not self.activated then
            return nil
        end
        if self.deactivateCalled then
            self:Deactivate()
            return nil
        end
        if not IsValidEntity(self.playerHero) then
            return nil
        end

        local now = GameRules:GetGameTime()
        if now < self.nextCastAt then
            return math.min(0.1, self.nextCastAt - now)
        end

        -- Do not start another cycle while the previous dodge still disables the hero.
        if self.playerHero:IsOutOfGame() or self.playerHero:IsInvulnerable() or self.playerHero:IsStunned() then
            return 0.1
        end

        if self.movementAnchor == nil then
            self.movementAnchor = self.playerHero:GetAbsOrigin()
            return 0.05
        end

        local movedDistance = (self.playerHero:GetAbsOrigin() - self.movementAnchor):Length2D()
        if movedDistance < self.movementDistanceToCast then
            return 0.05
        end

        if self:StartCastCycle() then
            self.nextCastTimer = nil
            return nil
        end
        return 0.25
    end)
end

function glimpse_dodge:StartCastCycle()
    if not IsValidEntity(self.disruptor) then
        self:SpawnDisruptor()
        return false
    end
    if not self:MoveDisruptorIntoRange() then
        return false
    end

    if self.dodgeSpell ~= nil then
        self.dodgeSpell:EndCooldown()
    end
    if self.dodgeItem ~= nil then
        self.dodgeItem:EndCooldown()
    end
    self.playerHero:SetMana(self.playerHero:GetMaxMana())
    self.disruptor:SetMana(self.disruptor:GetMaxMana())
    self.glimpseAbility:EndCooldown()

    local cycleId = self.cycle.id + 1
    self.cycle = {
        id = cycleId,
        phase = "cast_ordered",
        orderedAt = GameRules:GetGameTime()
    }

    self.disruptor:Stop()
    self.disruptor:SetForwardVector((self.playerHero:GetAbsOrigin() - self.disruptor:GetAbsOrigin()):Normalized())
    ExecuteOrderFromTable({
        UnitIndex = self.disruptor:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        AbilityIndex = self.glimpseAbility:entindex(),
        TargetIndex = self.playerHero:entindex(),
        Queue = false
    })

    self.castWatchdogTimer = Timers:CreateTimer(self.castOrderTimeout, function()
        self.castWatchdogTimer = nil
        if self.activated and self.cycle.id == cycleId and self.cycle.phase == "cast_ordered" then
            print("[GlimpseDodge] Glimpse cast did not start; retrying")
            self:ArmNextCast(self.castRetryDelay, false)
        end
        return nil
    end)
    return true
end

-- Glimpse creates its destination thinker only after Disruptor's cast point.
-- This is the beginning of the projectile travel, not merely the cast order.
function glimpse_dodge:OnGlimpseStart(thinker)
    if not self.activated or self.cycle.phase ~= "cast_ordered" or not IsValidEntity(self.playerHero) then
        return
    end

    if self.castWatchdogTimer ~= nil then
        Timers:RemoveTimer(self.castWatchdogTimer)
        self.castWatchdogTimer = nil
    end

    local startPosition = self.playerHero:GetAbsOrigin()
    local destination = thinker:GetAbsOrigin()
    local travelTime = math.min(
        (startPosition - destination):Length2D() / self.glimpseProjectileSpeed,
        self.glimpseMaxTravelTime
    )

    self.cycle.phase = "glimpse_active"
    self.cycle.thinker = thinker
    self.cycle.startedAt = GameRules:GetGameTime()
    self.cycle.startPosition = startPosition
    self.cycle.destination = destination
    self.cycle.travelTime = travelTime

    Timebar:ResetLines()
    if travelTime > 0 then
        local zoneOffset = travelTime - self.selectedEntry.castPoint - self.selectedEntry.dodgeWindow
        Timebar:PrepareZone(travelTime+self.minimumCastDelay, zoneOffset, self.selectedEntry.dodgeWindow)
        Timebar:Start()
    end

    local cycleId = self.cycle.id
    self.glimpseWatchTimer = Timers:CreateTimer(0, function()
        if not self.activated or self.cycle.id ~= cycleId or self.cycle.phase ~= "glimpse_active" then
            return nil
        end

        if not IsValidEntity(thinker) then
            self.glimpseWatchTimer = nil
            self:OnGlimpseFinish(cycleId, false)
            return nil
        end

        -- The thinker is authoritative; this only closes a stuck cycle.
        if GameRules:GetGameTime() - self.cycle.startedAt >= travelTime + self.endWatchdogGrace then
            self.glimpseWatchTimer = nil
            print("[GlimpseDodge] Glimpse end watchdog fired")
            self:OnGlimpseFinish(cycleId, true)
            return nil
        end

        return FrameTime()
    end)
end

function glimpse_dodge:ModifierGained(event)
    debugModifier(event)
    return true
end
function glimpse_dodge:OnEntityHurt(keys)
    local victim=EntIndexToHScript(keys.entindex_killed)
    if victim==self.playerHero then
        print("hero hurt")
        self.heroHurt=true
        Timebar:BlueLine()
    end
    -- TODO: react to entities taking damage
end

function glimpse_dodge:ResetTravelBootsCooldown()
    if not self.travelBootsEnabled or not IsValidEntity(self.playerHero) then
        return
    end

    if IsValidEntity(self.travelBoots) then
        self.travelBoots:EndCooldown()
    end

    if not IsValidEntity(self.travelBootsScroll) then
        self.travelBootsScroll = self.playerHero:GetItemInSlot(self.townPortalSlot)
    end
    if IsValidEntity(self.travelBootsScroll) then
        self.travelBootsScroll:EndCooldown()
    end
end

function glimpse_dodge:OnGlimpseFinish(cycleId, wasTimeout)
    if self.cycle.id ~= cycleId or self.cycle.phase ~= "glimpse_active" then
        return
    end

    local dodged = false
    if IsValidEntity(self.playerHero) then
        dodged = self.playerHero:IsOutOfGame() or self.playerHero:IsInvulnerable()

        -- At a normal Glimpse end the destination thinker has just disappeared.
        -- Checking displacement as well covers modifiers that end on the same frame.
        if not dodged and not wasTimeout and self.cycle.destination ~= nil then
            dodged = (self.playerHero:GetAbsOrigin() - self.cycle.destination):Length2D() > self.teleportVerifyRadius
        end
    end

    if dodged==true and self.heroHurt==false then
        self.currentCastDelay = math.max(self.minimumCastDelay, self.currentCastDelay - self.castDelayDecreaseOnSuccess)
        --[[ Notifications:Show("green", "good", "disruptor_glimpse")
        ComboTracker:Add() ]]
        print("good, glimpse dodged")
    else
        self.currentCastDelay = math.min(self.maximumCastDelay, self.currentCastDelay + self.castDelayIncreaseOnFail)
        --[[ Notifications:Show("red", "bad", "disruptor_glimpse")
        ComboTracker:Break() ]]
        print("bad")
    end
    self.heroHurt=false
    print("[GlimpseDodge] Next cast delay:", self.currentCastDelay)

    local now = GameRules:GetGameTime()
    local previousGlimpseStart = self.cycle.startedAt or self.cycle.orderedAt or now
    local remainingDelay = math.max(0, self.currentCastDelay - (now - previousGlimpseStart))
    self.cycle.thinker = nil
    self:ResetTravelBootsCooldown()

    if self.deactivateCalled then
        self:Deactivate()
    else
        self:ArmNextCast(remainingDelay)
    end
end

function glimpse_dodge:OnNPCSpawned(keys)
    if not self.activated then
        return
    end

    local npc = EntIndexToHScript(keys.entindex)
    if npc == nil then
        return
    end

    if npc:IsIllusion() then
        Timers:CreateTimer(FrameTime(), function()
            if IsValidEntity(npc) then
                npc:RemoveSelf()
            end
            return nil
        end)
        return
    end

    if npc:GetUnitName() == "npc_dota_thinker" and self.cycle.phase == "cast_ordered" then
        self:OnGlimpseStart(npc)
    end
end

function glimpse_dodge:OrderFilter(event)
    if not self.activated or event.issuer_player_id_const == -1 then
        return true
    end
    if event.entindex_ability == nil or event.entindex_ability == 0 then
        return true
    end

    local ability = EntIndexToHScript(event.entindex_ability)
    if ability~=nil then
        if self.cycle.phase == "glimpse_active" and (ability == self.dodgeSpell or ability == self.dodgeItem) then
            Timebar:PlayerAction()
        end
    end
    return true
end

function glimpse_dodge:DamageFilter(event)
    if event.entindex_victim_const == nil then
        return true
    end

    local victim = EntIndexToHScript(event.entindex_victim_const)
    if victim == self.playerHero or victim == self.disruptor then
        return false
    end
    return true
end

function glimpse_dodge:SendSpellTable()
    CustomGameEventManager:Send_ServerToAllClients("glimpse_dodge_spell_table", {data = self.spellTable})
end

function glimpse_dodge:PrepareDeactivate()
    self.deactivateCalled = true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function glimpse_dodge:Deactivate()
    self.activated = false
    self.deactivateCalled = false

    for _, timerName in ipairs({"nextCastTimer", "castWatchdogTimer", "glimpseWatchTimer", "visionTimer"}) do
        if self[timerName] ~= nil then
            Timers:RemoveTimer(self[timerName])
            self[timerName] = nil
        end
    end

    if IsValidEntity(self.disruptor) then
        self.disruptor:RemoveSelf()
    end

    self.disruptor = nil
    self.glimpseAbility = nil
    self.disruptorSpawning = false
    self.dodgeSpell = nil
    self.dodgeItem = nil
    self.travelBootsEnabled = false
    self.travelBoots = nil
    self.travelBootsScroll = nil
    self.selectedEntry = nil
    self.movementAnchor = nil
    self.nextCastAt = nil
    self.cycle.phase = "idle"

    Timebar:ResetLines()
    Timebar:Hide()
    ComboTracker:Configure({active = false})
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

glimpse_dodge:Init()
GamemodeManager:RegisterMode(glimpse_dodge.name, glimpse_dodge, glimpse_dodge.type)
