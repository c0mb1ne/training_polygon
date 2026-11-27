--prepared all generic methods single gamemode needs
--init prepare deactivate are necessary, events and damage filters can be removed if not used
if glimpse_dodge == nil then
  glimpse_dodge = class({})
end


function glimpse_dodge:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "glimpse_dodge" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(-2111.1826171875,-6378.5185546875,128)  -- TODO: set real training location
    self.trainingPlace = self.trainingPlaceDefault
    self.spellTable={
        item_manta={hero_name="from_js",invulModifier="modifier_manta_phase"},
        chaos_knight_phantasm={hero_name="npc_dota_hero_chaos_knight"},
        kez_echo_slash={hero_name="npc_dota_hero_kez"},
        naga_siren_mirror_image={hero_name="npc_dota_hero_naga_siren"},
        bane_nightmare={hero_name="npc_dota_hero_bane",invulModifier="modifier_bane_nightmare_invulnerable"}
    }
    -- TODO: define self.spellTable / self.unitTable / self.modifierTable etc. here,
    -- following the pattern used in dodge.lua / timing.lua if this mode needs one

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_glimpse_dodge_respawn_pos", function(_, event)
        glimpse_dodge:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("glimpse_dodge_reset_respawn_pos", function(_, event)
        glimpse_dodge:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("glimpse_dodge_training_end", function(_, event)
        glimpse_dodge:PrepareDeactivate()
    end)
    -- TODO: add a listener for this mode's own spell table request, e.g.
    CustomGameEventManager:RegisterListener("get_glimpse_dodge_spell_table", function(_, event)
        glimpse_dodge:SendSpellTable()
    end)
    

    self.deactivateCalled = false
    self.currentDodgeType=nil
    self.selectedEntry=nil
    self.playerHeroName=nil
    print('glimpse_dodge inited')
end

--[[ function glimpse_dodge:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("glimpse_dodge_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function glimpse_dodge:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    glimpse_dodge:SendRespawnPos()
end ]]

function glimpse_dodge:Prepare(args)
    print("[TemplateMode] Preparing gamemode")
    precache:clearTable()

    local timingType = args.timingType or "item_manta"
    local defaultHero = args.defaultHero or "npc_dota_hero_antimage"
    -- TODO: build the list of units this mode needs precached, based on args,
    -- following the unitsToPrecache/unitsAdded pattern from dodge.lua:Prepare()
    local unitsToPrecache = {
        "npc_dota_hero_puck"
    }
    
    if #unitsToPrecache > 0 then
        precache:PrecacheAddUnitToList(unitsToPrecache)
    end
    local entry=self.spellTable[timingType]
    if entry.hero_name=="from_js" then
        precache:PrecacheAddPlayerUnitToList({defaultHero})
    else
        precache:PrecacheAddPlayerUnitToList({entry.hero_name})
    end
    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        glimpse_dodge:StartGame(self.pendingArgs)
    end)
end

function glimpse_dodge:StartGame(args)
    -- TODO: spawn the player hero, position it at self.trainingPlace, set up the scenario
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
end

function glimpse_dodge:OnNPCSpawned(keys)
    -- TODO: react to units spawning (e.g. tag the player hero once it exists)
end

function glimpse_dodge:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function glimpse_dodge:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    return true
end

function glimpse_dodge:DamageFilter(event)
    --return false to prevent specific damage instances, true to allow
    --event.damagetype_const        damage type
    --event.damage      damage (returns full damage even if victim had less hp)
    --event.entindex_victim_const        entindex of victim
    --entindex_attacker_const        entindex of attacker
    return true
end

function glimpse_dodge:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

function glimpse_dodge:OnEntityKilled(keys)
    --keys.fires when entity got killed
    --keys.entindex_killed       victim entindex
    --keys.splitscreenplayer      no idea tbh
    --keys.entindex_attacker      attacker entindex
    --keys.game_event_name        event name
    --keys.entindex_inflictor        entindex of ability killed with (not exist if autoattack)
    --keys.damagebits        no idea always 0
    --keys.game_event_listener       never used
end

function glimpse_dodge:OnEntityHurt(keys)
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

function glimpse_dodge:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    -- CustomGameEventManager:Send_ServerToAllClients("glimpse_dodge_spell_table", self.spellTable)
end

function glimpse_dodge:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function glimpse_dodge:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

glimpse_dodge:Init()
GamemodeManager:RegisterMode(glimpse_dodge.name, glimpse_dodge, glimpse_dodge.type)