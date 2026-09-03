--TODO: describe what this gamemode does
if lasthit_training == nil then
  lasthit_training = class({})
end


function lasthit_training:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "lasthit_training" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(0, 0, 128) -- TODO: set real training location
    self.trainingPlace = self.trainingPlaceDefault

    -- TODO: define self.spellTable / self.unitTable / self.modifierTable etc. here,
    -- following the pattern used in dodge.lua / timing.lua if this mode needs one

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_lasthit_training_respawn_pos", function(_, event)
        lasthit_training:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("lasthit_training_reset_respawn_pos", function(_, event)
        lasthit_training:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("lasthit_training_training_end", function(_, event)
        lasthit_training:PrepareDeactivate()
    end)
    -- TODO: add a listener for this mode's own spell table request, e.g.
    -- CustomGameEventManager:RegisterListener("get_lasthit_training_spell_table", function(_, event)
    --     lasthit_training:SendSpellTable()
    -- end)
    self.startingItems={}
    self.startingItems.consumables={""}
    self.deactivateCalled = false

    print('lasthit_training inited')
end

--[[ function lasthit_training:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("lasthit_training_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function lasthit_training:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    lasthit_training:SendRespawnPos()
end ]]

function lasthit_training:Prepare(args)
    print("[TemplateMode] Preparing gamemode")
    precache:clearTable()

    -- TODO: build the list of units this mode needs precached, based on args,
    -- following the unitsToPrecache/unitsAdded pattern from dodge.lua:Prepare()
    local unitsToPrecache = {}

    if #unitsToPrecache > 0 then
        precache:PrecacheAddUnitToList(unitsToPrecache)
    end

    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        lasthit_training:StartGame(self.pendingArgs)
    end)
end

function lasthit_training:StartGame(args)
    -- TODO: spawn the player hero, position it at self.trainingPlace, set up the scenario
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
end

function lasthit_training:OnNPCSpawned(keys)
    -- TODO: react to units spawning (e.g. tag the player hero once it exists)
end

function lasthit_training:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function lasthit_training:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    return true
end

function lasthit_training:DamageFilter(event)
    -- TODO: return false to prevent specific damage instances, true to allow
    return true
end

function lasthit_training:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

function lasthit_training:OnEntityHurt(keys)
    -- TODO: react to entities taking damage
end

function lasthit_training:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    -- CustomGameEventManager:Send_ServerToAllClients("lasthit_training_spell_table", self.spellTable)
end

function lasthit_training:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function lasthit_training:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

lasthit_training:Init()
GamemodeManager:RegisterMode(lasthit_training.name, lasthit_training, lasthit_training.type)