if armlet == nil then
  armlet = class({})
end

function armlet:Init()
    self.type = "sandbox"
    self.name = "armlet"
    self.activated = false
    self.Player = nil
    self.playerHero = nil
    self.trainingPlaceDefault = Vector(0, 0, 128)
    self.trainingPlace = self.trainingPlaceDefault

    self.attacker = nil
    self.attackerName = nil
    self.fakeMod = false
    self.damageBonus = 0
    self.deactivateCalled = false

    CustomGameEventManager:RegisterListener("armlet_mode_end", function(_, event)
        armlet:PrepareDeactivate()
    end)
    CustomGameEventManager:RegisterListener("armlet_mode_mod_attacker", function(_, event)
        armlet:ModAttacker(event)
    end)

    print('armlet inited')
end

function armlet:Prepare(args)
    print("[Armlet] Preparing gamemode")
    precache:clearTable()

    self.attackerName = args.unitName or "npc_dota_hero_abaddon"

    precache:PrecacheAddPlayerUnitToList({"npc_dota_hero_life_stealer"})
    precache:PrecacheAddUnitToList({self.attackerName})

    self.pendingArgs = args

    precache:doPrecache(function()
        armlet:StartGame(self.pendingArgs)
    end)
end

function armlet:StartGame(args)
    print("[Armlet] Starting game after precache")
    self.activated = true
    self.fakeMod = false
    self.damageBonus = 0

    if TRAINING_PLACE ~= nil then
        self.trainingPlace = TRAINING_PLACE
    end

    CustomGameEventManager:Send_ServerToAllClients("load_hud", {name = self.name})

    self.Player = PlayerResource:GetPlayer(0)
    local old_hero = self.Player:GetAssignedHero()
    self.playerHero = replaceHero(old_hero, "npc_dota_hero_life_stealer")
    self.playerHero:SetMoveCapability(1)
    self.playerHero:SetAttackCapability(0)
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
    self.playerHero:SetDayTimeVisionRange(4000)
    removeItems(self.playerHero)
    local item = CreateItem("item_armlet", self.playerHero, self.playerHero)
    self.playerHero:AddItem(item)
    local aegis = CreateItem("item_aegis", self.playerHero, self.playerHero)
    self.playerHero:AddItem(aegis)

    local position = randomCirclePosition(500, self.playerHero)
    self.attacker = CreateUnitByName(self.attackerName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self.attacker:SetBaseHealthRegen(0)
    if self.attacker:GetUnitName() == "npc_dota_hero_invoker" then
        self.attacker:RemoveAbility("invoker_quas")
    end
    if self.attackerName == "npc_dota_goodguys_tower1_mid" or self.attackerName == "npc_dota_goodguys_tower2_mid" then
        self.attacker:SetAbsOrigin(position)
    end
    local boots = CreateItem("item_travel_boots", self.attacker, self.attacker)
    self.attacker:AddItem(boots)
    self.attacker:AddNewModifier(self.attacker, nil, "modifier_razor_static_link_buff", {})
    self.attacker:AddAbility("huskar_berserkers_blood")
    local abilka = self.attacker:FindAbilityByName("huskar_berserkers_blood")
    abilka:SetLevel(4)
    self.attacker:SetBaseHealthRegen(-(self.attacker:GetHealthRegen()))
    self.attacker:SetContextThink(DoUniqueString("attack_hero"),
        function()
            if self.activated and IsValidEntity(self.attacker) and self.attacker:IsAlive() then
                self.attacker:MoveToTargetToAttack(self.playerHero)
            end
        end,
    0)
    Timers:CreateTimer("armlet_mode_fakemod_thinker", {
        useGameTime = true,
        endTime = math.random(100, 200) / 100,
        callback = function()
            if self.activated and self.fakeMod == true then
                if IsValidEntity(self.attacker) then
                    self.attacker:Stop()
                end
            end
            return math.random(100, 200) / 100
        end
    })
    CustomGameEventManager:Send_ServerToAllClients("armlet_mode_started", {attacker = self.attacker:entindex()})
end

function armlet:ModAttacker(event)
    if self.attacker == nil or not IsValidEntity(self.attacker) then
        return
    end
    local modType = event.type
    if modType == "fm" then
        self.fakeMod = not self.fakeMod
    elseif modType == "as" then
        self:ChangeAttackSpeed(tonumber(event.value))
    elseif modType == "ad" then
        self:ChangeAttackDamage(tonumber(event.value))
    end
end

function armlet:ChangeAttackSpeed(asPoints)
    local unit = self.attacker
    local oldHealth = unit:GetHealth()
    local maxHealth = unit:GetMaxHealth()
    local affHealth = maxHealth / 100 * 90
    local changeHealth = affHealth / 340 * asPoints
    unit:ModifyHealth(oldHealth - changeHealth, nil, false, 0)
end

function armlet:ChangeAttackDamage(asPoints)
    self.damageBonus = self.damageBonus + asPoints
    self.attacker:SetModifierStackCount("modifier_razor_static_link_buff", self.attacker, self.damageBonus)
end

function armlet:PrepareDeactivate()
    self.deactivateCalled = true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function armlet:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timers:RemoveTimer("armlet_mode_fakemod_thinker")
    if self.attacker ~= nil and IsValidEntity(self.attacker) then
        self.attacker:RemoveSelf()
    end
    self.attacker = nil
    self.fakeMod = false
    self.damageBonus = 0
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
end

armlet:Init()
GamemodeManager:RegisterMode(armlet.name, armlet, armlet.type)
