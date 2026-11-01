if kunkka == nil then
  kunkka = class({})
end

function kunkka:Init()
    self.type = "sandbox"
    self.name = "kunkka"
    self.activated = false
    self.Player = nil
    self.playerHero = nil
    self.trainingPlaceDefault = Vector(0, 0, 128)
    self.trainingPlace = self.trainingPlaceDefault

    self.target = nil
    self.procastType = 1
    self.timebarEnabled = true
    self.deactivateCalled = false

    CustomGameEventManager:RegisterListener("kunkka_mode_end", function(_, event)
        kunkka:PrepareDeactivate()
    end)

    print('kunkka inited')
end

function kunkka:Prepare(args)
    print("[Kunkka] Preparing gamemode")
    precache:clearTable()

    precache:PrecacheAddPlayerUnitToList({"npc_dota_hero_kunkka"})
    precache:PrecacheAddUnitToList({"npc_dota_hero_tiny"})

    self.pendingArgs = args

    precache:doPrecache(function()
        kunkka:StartGame(self.pendingArgs)
    end)
end

function kunkka:StartGame(args)
    print("[Kunkka] Starting game after precache")
    self.activated = true

    if TRAINING_PLACE ~= nil then
        self.trainingPlace = TRAINING_PLACE
    end

    self.procastType = tonumber(args.procast) or 1
    self.timebarEnabled = args.timebar ~= 0

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})

    self.Player = PlayerResource:GetPlayer(0)
    local old_hero = self.Player:GetAssignedHero()
    self.playerHero = replaceHero(old_hero, "npc_dota_hero_kunkka")
    self.playerHero:SetMoveCapability(1)
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
    removeItems(self.playerHero)

    local ability = self.playerHero:FindAbilityByName("kunkka_torrent")
    ability:SetLevel(1)
    local ability3 = self.playerHero:FindAbilityByName("kunkka_x_marks_the_spot")
    ability3:SetLevel(1)
    if self.procastType == 2 then
        local ability2 = self.playerHero:FindAbilityByName("kunkka_ghostship")
        ability2:SetLevel(1)
    end

    self.target = CreateUnitByName("npc_dota_hero_tiny", randomCirclePosition(500, self.playerHero), true, nil, nil, DOTA_TEAM_BADGUYS)
    for i = 1, 5 do
        local booster = CreateItem("item_soul_booster", self.target, self.target)
        self.target:AddItem(booster)
    end
    self.target:SetBaseStrength(0)
    self.target:SetBaseHealthRegen(100)
    self.target:SetAttackCapability(0)
    self.target:SetBaseManaRegen(50)
    self.target:SetBaseMoveSpeed(700)

    Timers:CreateTimer({
        endTime = FrameTime(),
        callback = function()
            local strength = self.target:GetBaseStrength()
            local statusResist = strength * 0.15
            CustomGameEventManager:Send_ServerToAllClients("kunkka_mode_str", {str = strength, sr = statusResist})
        end
    })

    if self.timebarEnabled then
        Timebar:Show()
    end

    CustomGameEventManager:Send_ServerToAllClients("kunkka_mode_started", {procast = self.procastType})
end

function kunkka:PrepareDeactivate()
    self.deactivateCalled = true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function kunkka:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    local trash = Entities:FindAllByName("npc_dota_hero_tiny")
    for _, v in pairs(trash) do
        v:RemoveSelf()
    end
    self.target = nil
    Timebar:Hide()
    Timebar:ResetLines()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

kunkka:Init()
GamemodeManager:RegisterMode(kunkka.name, kunkka, kunkka.type)
