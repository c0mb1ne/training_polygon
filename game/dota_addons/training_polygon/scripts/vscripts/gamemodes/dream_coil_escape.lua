--TODO: describe what this gamemode does
if dream_coil_escape == nil then
  dream_coil_escape = class({})
end


function dream_coil_escape:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "dream_coil_escape" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(0, 0, 128) -- TODO: set real training location
    self.trainingPlace = self.trainingPlaceDefault

    -- TODO: define self.spellTable / self.unitTable / self.modifierTable etc. here,
    -- following the pattern used in dodge.lua / timing.lua if this mode needs one

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_dream_coil_escape_respawn_pos", function(_, event)
        dream_coil_escape:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("dream_coil_escape_reset_respawn_pos", function(_, event)
        dream_coil_escape:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("dream_coil_escape_training_end", function(_, event)
        dream_coil_escape:PrepareDeactivate()
    end)
    -- TODO: add a listener for this mode's own spell table request, e.g.
    -- CustomGameEventManager:RegisterListener("get_dream_coil_escape_spell_table", function(_, event)
    --     dream_coil_escape:SendSpellTable()
    -- end)

    self.deactivateCalled = false

    print('dream_coil_escape inited')
end

--[[ function dream_coil_escape:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("dream_coil_escape_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function dream_coil_escape:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    dream_coil_escape:SendRespawnPos()
end ]]

function dream_coil_escape:Prepare(args)
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
        dream_coil_escape:StartGame(self.pendingArgs)
    end)
end

function dream_coil_escape:StartGame(args)
    -- TODO: spawn the player hero, position it at self.trainingPlace, set up the scenario
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
end

function dream_coil_escape:OnNPCSpawned(keys)
    -- TODO: react to units spawning (e.g. tag the player hero once it exists)
end

function dream_coil_escape:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function dream_coil_escape:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    return true
end

function dream_coil_escape:DamageFilter(event)
    -- TODO: return false to prevent specific damage instances, true to allow
    return true
end

function dream_coil_escape:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

function dream_coil_escape:OnEntityHurt(keys)
    -- TODO: react to entities taking damage
end

function dream_coil_escape:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    -- CustomGameEventManager:Send_ServerToAllClients("dream_coil_escape_spell_table", self.spellTable)
end

function dream_coil_escape:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function dream_coil_escape:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

dream_coil_escape:Init()
GamemodeManager:RegisterMode(dream_coil_escape.name, dream_coil_escape, dream_coil_escape.type)