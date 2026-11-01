if alchemist == nil then
  alchemist = class({})
end

function alchemist:Init()
    self.type = "sandbox"
    self.name = "alchemist"
    self.activated = false
    self.Player = nil
    self.playerHero = nil
    self.trainingPlaceDefault = Vector(0, 0, 128)
    self.trainingPlace = self.trainingPlaceDefault

    self.timebarEnabled = true
    self.deactivateCalled = false

    CustomGameEventManager:RegisterListener("alchemist_mode_end", function(_, event)
        alchemist:PrepareDeactivate()
    end)

    print('alchemist inited')
end

function alchemist:Prepare(args)
    print("[Alchemist] Preparing gamemode")
    precache:clearTable()

    precache:PrecacheAddPlayerUnitToList({"npc_dota_hero_alchemist"})

    self.pendingArgs = args

    precache:doPrecache(function()
        alchemist:StartGame(self.pendingArgs)
    end)
end

function alchemist:StartGame(args)
    print("[Alchemist] Starting game after precache")
    self.activated = true

    if TRAINING_PLACE ~= nil then
        self.trainingPlace = TRAINING_PLACE
    end

    self.timebarEnabled = args.timebar ~= 0

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})

    self.Player = PlayerResource:GetPlayer(0)
    local old_hero = self.Player:GetAssignedHero()
    self.playerHero = replaceHero(old_hero, "npc_dota_hero_alchemist")
    self.playerHero:SetMoveCapability(1)
    self.playerHero:SetBaseHealthRegen(100)
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
    removeItems(self.playerHero)
    local item = CreateItem("item_manta", self.playerHero, self.playerHero)
    self.playerHero:AddItem(item)
    local ability = self.playerHero:FindAbilityByName("alchemist_unstable_concoction")
    ability:SetLevel(1)

    if self.timebarEnabled then
        Timebar:Show()
    end
end

function alchemist:PrepareDeactivate()
    self.deactivateCalled = true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function alchemist:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timebar:Hide()
    Timebar:ResetLines()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

alchemist:Init()
GamemodeManager:RegisterMode(alchemist.name, alchemist, alchemist.type)
