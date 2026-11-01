if glimpse == nil then
  glimpse = class({})
end

function glimpse:Init()
    self.type = "sandbox"
    self.name = "glimpse"
    self.activated = false
    self.Player = nil
    self.playerHero = nil

    self.posCounter = 1
    self.courseTimer = nil
    self.safeTime = 0
    self.timebarEnabled = true
    self.deactivateCalled = false

    self.waypoints = {
        Vector(-2422.0070800781, -6116.193359375, 256),
        Vector(-1245.2333984375, -5999.974609375, 384),
        Vector(-523.8134765625, -4384.990234375, 384),
        Vector(-1919.7176513672, -3609.423828125, 256),
        Vector(-1273.9571533203, -2425.5952148438, 256),
        Vector(35.000591278076, -1060.0407714844, 256),
        Vector(1147.3959960938, -1847.8355712891, 256),
        Vector(691.61309814453, -2819.6413574219, 384),
        Vector(723.65277099609, -4053.6479492188, 384),
        Vector(1570.8024902344, -4984.0229492188, 384),
        Vector(2667.7573242188, -5132.1625976563, 384),
        Vector(3861.2648925781, -5158.1889648438, 384),
        Vector(5179.169921875, -4856.3383789063, 384),
        Vector(5271.4018554688, -3861.2421875, 384),
        Vector(5396.7553710938, -2860.8701171875, 384),
        Vector(5129.8325195313, -2041.44921875, 384),
        Vector(4077.0581054688, -1604.6007080078, 384),
        Vector(3281.0180664063, -888.32843017578, 256),
        Vector(3281.0180664063, -888.32843017578, 256),
        Vector(4346.693359375, 22.2731590271, 384),
        Vector(5282.4716796875, 672.21722412109, 384),
        Vector(4417.5463867188, 1227.9084472656, 384),
        Vector(3652.0944824219, 1581.8403320313, 256),
        Vector(3527.0017089844, 2614.1696777344, 256),
        Vector(2845.4792480469, 3421.9670410156, 256),
        Vector(2314.8090820313, 4295.359375, 256),
        Vector(2039.2075195313, 5222.751953125, 256),
        Vector(948.45263671875, 5136.0849609375, 384),
        Vector(452.47994995117, 4112.833984375, 384),
        Vector(609.46936035156, 3086.9895019531, 384),
        Vector(414.80996704102, 2117.0197753906, 384),
        Vector(-301.26800537109, 1506.2410888672, 256.02474975586),
        Vector(-1959.6530761719, 2545.1110839844, 128),
        Vector(-2821.8513183594, 2927.8200683594, 128),
        Vector(-2426.0090332031, 4094.8806152344, 256),
        Vector(-1476.6145019531, 4158.3193359375, 256),
        Vector(-1373.2416992188, 4893.0297851563, 384),
        Vector(-2400.1525878906, 5208.2377929688, 384),
        Vector(-3428.3908691406, 5190.1240234375, 384),
        Vector(-4283.6787109375, 4876.1513671875, 384),
        Vector(-5196.1884765625, 4631.7353515625, 384),
        Vector(-5734.626953125, 4176.001953125, 384),
        Vector(-5719.9614257813, 3208.0983886719, 384),
        Vector(-5268.61328125, 2390.7734375, 384),
        Vector(-4544.7924804688, 1842.5246582031, 384),
        Vector(-5277.8725585938, 1178.6042480469, 384),
        Vector(-5357.44140625, 354.87521362305, 374.92572021484),
        Vector(-4431.1108398438, 510.9345703125, 256),
        Vector(-3980.4260253906, -658.8173828125, 381.55383300781),
        Vector(-5021.8823242188, -1252.4880371094, 384),
        Vector(-4139.744140625, -1509.6024169922, 384),
        Vector(-3342.08984375, -1498.1889648438, 384),
        Vector(-2660.8186035156, -2102.166015625, 256),
        Vector(-2015.6926269531, -2976.1520996094, 256),
        Vector(-2560.7744140625, -3872, 256),
        Vector(-2918.8156738281, -5037.1137695313, 256)
    }

    self.escapeTypes = {"item_manta",
        "phantom_lancer_doppelwalk",
        "naga_siren_mirror_image",
        "ember_spirit_sleight_of_fist",
        "chaos_knight_phantasm",
        "sandking_burrowstrike",
        "shredder_timber_chain"}

    self.escapeHeroes = {"npc_dota_hero_antimage",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_shredder"}

    self.escapeLabels = {"Manta Style",
        "Doppelganger",
        "Mirror Image",
        "Sleight of Fist",
        "Phantasm",
        "Burrowstrike",
        "Timber Chain"}

    self.castPoints = {0, 0.1, 0.65, 0, 0.4, 0, 0.3}
    self.durations = {0.1, 1, 0.3, 0.2, 0.5, 0.175, 0}

    CustomGameEventManager:RegisterListener("glimpse_mode_end", function(_, event)
        glimpse:PrepareDeactivate()
    end)

    print('glimpse inited')
end

function glimpse:Prepare(args)
    print("[Glimpse] Preparing gamemode")
    precache:clearTable()

    local skillId = tonumber(args.skillId) or 1
    precache:PrecacheAddPlayerUnitToList({self.escapeHeroes[skillId]})

    self.pendingArgs = args

    precache:doPrecache(function()
        glimpse:StartGame(self.pendingArgs)
    end)
end

function glimpse:StartGame(args)
    print("[Glimpse] Starting game after precache")
    self.activated = true

    local skillId = tonumber(args.skillId) or 1
    local skillLevel = tonumber(args.level) or 1
    self.timebarEnabled = args.timebar ~= 0

    self.posCounter = 1

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})

    self.Player = PlayerResource:GetPlayer(0)
    local old_hero = self.Player:GetAssignedHero()
    self.playerHero = replaceHero(old_hero, self.escapeHeroes[skillId])
    removeItems(self.playerHero)
    self.playerHero:SetAbsOrigin(self.waypoints[self.posCounter])

    if skillId == 1 then
        local item = CreateItem("item_manta", self.playerHero, self.playerHero)
        self.playerHero:AddItem(item)
    else
        local spell = self.playerHero:FindAbilityByName(self.escapeTypes[skillId])
        if skillId == 6 or skillId == 7 then
            spell:SetLevel(skillLevel)
        else
            spell:SetLevel(1)
        end
    end
    local boots = CreateItem("item_travel_boots", self.playerHero, self.playerHero)
    self.playerHero:AddItem(boots)
    self.playerHero:SetAttackCapability(1)
    self.playerHero:SetMoveCapability(1)
    self:RefreshItems2()

    self.safeTime = self.castPoints[skillId] + self.durations[skillId] / 2

    if self.timebarEnabled then
        Timebar:Show()
    end

    CustomGameEventManager:Send_ServerToAllClients("glimpse_mode_started", {castpoint = self.castPoints[skillId], duration = self.durations[skillId]})

    self.posCounter = self.posCounter + 1
    self.courseTimer = Timers:CreateTimer(5, function()
        self:SpawnGlimpser()
        if self.activated then
            return 5
        else
            return nil
        end
    end)
end

function glimpse:SpawnGlimpser()
    local hero = self.playerHero
    AddFOWViewer(DOTA_TEAM_BADGUYS, hero:GetAbsOrigin(), 1000, 5, true)
    local respawnPoint = hero:GetAbsOrigin() + Vector(0, 100, 0)
    CreateUnitByNameAsync("npc_dummy_unit", respawnPoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetMaxHealth(10000)
        unit:SetHealth(10000)
        unit:SetMoveCapability(1)
        unit:SetIdleAcquire(false)
        unit:AddAbility("disruptor_glimpse")
        unit:SetForwardVector((hero:GetOrigin() - respawnPoint):Normalized())
        local ability = unit:FindAbilityByName("disruptor_glimpse")
        ability:SetLevel(1)
        unit:SetContextThink(DoUniqueString("cast_glimpse"),
            function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = ability:entindex(),
                    TargetIndex = hero:entindex(),
                    Queue = 0
                })
            end,
        0)
        unit:SetContextThink(DoUniqueString("remove_glimpser"), function() unit:RemoveSelf() end, 3)
    end)
end

function glimpse:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    if npc == nil then
        return
    end
    Timers:CreateTimer(0.1, function()
        if not npc:IsNull() and npc:IsIllusion() then
            npc:RemoveSelf()
        end
    end)
    if npc:GetUnitName() == "npc_dota_thinker" then
        refreshSkills(self.playerHero)
        local length = (self.playerHero:GetAbsOrigin() - npc:GetAbsOrigin()):Length()
        local glimpseTime = length / 600
        if glimpseTime > 1.8 then
            glimpseTime = 1.8
        end
        CustomGameEventManager:Send_ServerToAllClients("glimpse_mode_casted", {bartime = glimpseTime, castpoint = self.safeTime})
    end
end

function glimpse:OnAbilityUsed(keys)
    local abilityname = keys.abilityname
    if abilityname == "item_manta" then
        Timers:CreateTimer(3, function()
            if self.playerHero ~= nil and not self.playerHero:IsNull() then
                self:RefreshItems2()
                healHero(self.playerHero)
            end
        end)
    end
end

function glimpse:RefreshItems2()
    for i = 0, 10 do
        local currentItem = self.playerHero:GetItemInSlot(i)
        if currentItem ~= nil then
            currentItem:EndCooldown()
        end
    end
end

function glimpse:PrepareDeactivate()
    self.deactivateCalled = true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function glimpse:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    if self.courseTimer ~= nil then
        Timers:RemoveTimer(self.courseTimer)
        self.courseTimer = nil
    end
    Timebar:Hide()
    Timebar:ResetLines()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

glimpse:Init()
GamemodeManager:RegisterMode(glimpse.name, glimpse, glimpse.type)
