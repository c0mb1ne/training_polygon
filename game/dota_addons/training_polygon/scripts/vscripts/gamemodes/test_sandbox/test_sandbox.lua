--prepared all generic methods single gamemode needs
--init prepare deactivate are necessary, events and damage filters can be removed if not used
if test_sandbox == nil then
  test_sandbox = class({})
end


function test_sandbox:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "test_sandbox" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(0, 0, 128) -- TODO: set real training location
    self.trainingPlace = self.trainingPlaceDefault
    self.heroName="npc_dota_hero_ringmaster"
    -- TODO: define self.spellTable / self.unitTable / self.modifierTable etc. here,
    -- following the pattern used in dodge.lua / timing.lua if this mode needs one

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_test_sandbox_respawn_pos", function(_, event)
        test_sandbox:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("test_sandbox_reset_respawn_pos", function(_, event)
        test_sandbox:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("test_sandbox_training_end", function(_, event)
        test_sandbox:PrepareDeactivate()
    end)
    -- TODO: add a listener for this mode's own spell table request, e.g.
    -- CustomGameEventManager:RegisterListener("get_test_sandbox_spell_table", function(_, event)
    --     test_sandbox:SendSpellTable()
    -- end)

    self.deactivateCalled = false

    print('test_sandbox inited')
end

--[[ function test_sandbox:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("test_sandbox_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function test_sandbox:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    test_sandbox:SendRespawnPos()
end ]]

function test_sandbox:Prepare(args)
    print("[TemplateMode] Preparing gamemode")
    precache:clearTable()

    -- TODO: build the list of units this mode needs precached, based on args,
    -- following the unitsToPrecache/unitsAdded pattern from dodge.lua:Prepare()
    local unitsToPrecache = {}

    if #unitsToPrecache > 0 then
        precache:PrecacheAddUnitToList(unitsToPrecache)
    end
    precache:PrecacheAddPlayerUnitToList({self.heroName})
    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        test_sandbox:StartGame(self.pendingArgs)
    end)
end

function test_sandbox:StartGame(args)
    -- TODO: spawn the player hero, position it at self.trainingPlace, set up the scenario
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
    self.Player=PlayerResource:GetPlayer(0)
    local old_hero=self.Player:GetAssignedHero()
    local new_hero=self.heroName
    self.playerHero=replaceHero(old_hero,new_hero)
    self.playerHero:SwapAbilities("ringmaster_empty_souvenir", "ringmaster_funhouse_mirror", false, true)
    local ability=self.playerHero:FindAbilityByName("ringmaster_funhouse_mirror")
    ability:SetCurrentAbilityCharges(99)
    --[[ local modifier=self.playerHero:FindModifierByName("modifier_ringmaster_dark_carnival_souvenirs")
    modifier:SetStackCount(1) ]]
    DebugPanelShow()
    local abilCount=self.playerHero:GetAbilityCount()
    DebugVar("abilCount",abilCount)
    Timers:CreateTimer(0,function()
        for i=0,abilCount-1,1 do
            local ability=self.playerHero:GetAbilityByIndex(i)
            if ability~=nil then
                DebugVar(i,ability:GetAbilityName())
            end
        end
        return FrameTime()
    end)
    --[[ local modifier=self.playerHero:FindModifierByName("modifier_ringmaster_dark_carnival_souvenirs")
    Timers:CreateTimer(5,function()
        local stacks=self.playerHero:GetModifierStackCount("modifier_ringmaster_dark_carnival_souvenirs",self.playerHero)
        print('stacks:',stacks)
        return 5
    end) ]]
end

function test_sandbox:OnNPCSpawned(keys)
    -- TODO: react to units spawning (e.g. tag the player hero once it exists)
end

function test_sandbox:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function test_sandbox:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    debugModifier(event)
    return true
end

function test_sandbox:DamageFilter(event)
    --return false to prevent specific damage instances, true to allow
    --event.damagetype_const        damage type
    --event.damage      damage (returns full damage even if victim had less hp)
    --event.entindex_victim_const        entindex of victim
    --entindex_attacker_const        entindex of attacker
    return true
end

function test_sandbox:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

function test_sandbox:OnEntityKilled(keys)
    --keys.fires when entity got killed
    --keys.entindex_killed       victim entindex
    --keys.splitscreenplayer      no idea tbh
    --keys.entindex_attacker      attacker entindex
    --keys.game_event_name        event name
    --keys.entindex_inflictor        entindex of ability killed with (not exist if autoattack)
    --keys.damagebits        no idea always 0
    --keys.game_event_listener       never used
end

function test_sandbox:OnEntityHurt(keys)
    --react to entities taking damage
    --keys.entindex_inflictor        entindex of ability if caused by (not exist if autoattack)
    --keys.damagebits         no idea
    --keys.game_event_listener        never needed
    --keys.game_event_name    returns name of event
    --keys.entindex_killed        victim of damage
    --keys.damage     amount of damage taken (actual damage compare to damage filter)
    --keys.entindex_attacker      attacker entindex
    --keys.splitscreenplayer      no idea
end

function test_sandbox:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    -- CustomGameEventManager:Send_ServerToAllClients("test_sandbox_spell_table", self.spellTable)
end

function test_sandbox:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function test_sandbox:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    DebugPanelHide()
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

test_sandbox:Init()
if IsInToolsMode() then
    GamemodeManager:RegisterMode(test_sandbox.name, test_sandbox, test_sandbox.type)
end