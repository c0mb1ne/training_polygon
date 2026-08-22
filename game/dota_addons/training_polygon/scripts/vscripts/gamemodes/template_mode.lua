--TODO: describe what this gamemode does
if template_mode == nil then
  template_mode = class({})
end


function template_mode:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "template_mode" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(0, 0, 128) -- TODO: set real training location
    self.trainingPlace = self.trainingPlaceDefault

    -- TODO: define self.spellTable / self.unitTable / self.modifierTable etc. here,
    -- following the pattern used in dodge.lua / timing.lua if this mode needs one

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_template_mode_respawn_pos", function(_, event)
        template_mode:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("template_mode_reset_respawn_pos", function(_, event)
        template_mode:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("template_mode_training_end", function(_, event)
        template_mode:PrepareDeactivate()
    end)
    -- TODO: add a listener for this mode's own spell table request, e.g.
    -- CustomGameEventManager:RegisterListener("get_template_mode_spell_table", function(_, event)
    --     template_mode:SendSpellTable()
    -- end)

    self.deactivateCalled = false

    print('template_mode inited')
end

--[[ function template_mode:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("template_mode_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function template_mode:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    template_mode:SendRespawnPos()
end ]]

function template_mode:Prepare(args)
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
        template_mode:StartGame(self.pendingArgs)
    end)
end

function template_mode:StartGame(args)
    -- TODO: spawn the player hero, position it at self.trainingPlace, set up the scenario
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
end

function template_mode:OnNPCSpawned(keys)
    -- TODO: react to units spawning (e.g. tag the player hero once it exists)
end

function template_mode:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function template_mode:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    return true
end

function template_mode:DamageFilter(event)
    -- TODO: return false to prevent specific damage instances, true to allow
    return true
end

function template_mode:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

function template_mode:OnEntityHurt(keys)
    -- TODO: react to entities taking damage
end

function template_mode:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    -- CustomGameEventManager:Send_ServerToAllClients("template_mode_spell_table", self.spellTable)
end

function template_mode:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function template_mode:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

template_mode:Init()
GamemodeManager:RegisterMode(template_mode.name, template_mode, template_mode.type)