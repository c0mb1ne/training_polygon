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

    CustomGameEventManager:RegisterListener("get_lasthit_training_starting_items", function(_, event)
        lasthit_training:SendItemTable()
    end)

    self.deactivateCalled = false
    self.startingItems = {
        consumables = {
            "item_tango",
            "item_flask", 
            "item_faerie_fire",
            "item_blood_grenade",
            "item_clarity",
            "item_enchanted_mango",
            "item_magic_stick",
            "item_ward_observer",
            "item_ward_sentry",
            "item_bottle",
            "item_dust",
            "item_smoke_of_deceit",
        },
        attributes = {
            "item_branches",
            "item_gauntlets",
            "item_slippers",
            "item_mantle",
            "item_circlet",
            "item_bracer",
            "item_wraith_band",
            "item_null_talisman",
            "item_crown",
            "item_belt_of_strength",
            "item_boots_of_elves",
            "item_robe"
        },
        accessories = {
            "item_ring_of_regen",
            "item_sobi_mask",
            "item_ring_of_protection",
            "item_quelling_blade",
            "item_fluffy_hat",
            "item_wizard_hat",
            "item_wind_lace",
            "item_boots",
            "item_orb_of_frost",
            "item_blight_stone",
            "item_orb_of_venom",
            "item_blades_of_attack"
        }
    }
    self.playerHeroName=""
    self.selectedLane=""
    self.selectedSide=""
    self.playerSpawns={
        [DOTA_TEAM_BADGUYS]={
            top=Vector(-5879.5595703125,5738.4077148438,128),
            mid=Vector(-216.69892883301,601.20617675781,128),
            bot=Vector(5786.7495117188,-2833.177734375,128)
        },
        [DOTA_TEAM_GOODGUYS]={
            top=Vector(-6468.7875976563,3327.4189453125,128),
            mid=Vector(-1493.5354003906,-744.01934814453,128),
            bot=Vector(5176.671875,-5708.5913085938,128)
        }
    }
    
    self.waveTimer=nil
end
--Vector(-6468.7875976563,3327.4189453125,128)
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
    local defaultHero = args.defaultHero or "npc_dota_hero_antimage"
    precache:PrecacheAddPlayerUnitToList({defaultHero})
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
    
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
    --for mid game starts at 15 sec after first wave spawn, for other lanes at 25
    --[[ CreepController:SpawnCreepWave25sec(DOTA_TEAM_GOODGUYS,'top','initial')
    CreepController:SpawnCreepWave15sec(DOTA_TEAM_GOODGUYS,'mid','initial')
    CreepController:SpawnCreepWave25sec(DOTA_TEAM_GOODGUYS,'bot','initial')
    CreepController:SpawnCreepWave25sec(DOTA_TEAM_BADGUYS,'top','initial')
    CreepController:SpawnCreepWave15sec(DOTA_TEAM_BADGUYS,'mid','initial')
    CreepController:SpawnCreepWave25sec(DOTA_TEAM_BADGUYS,'bot','initial') ]]
    --[[ CreepController:CalibrateCreepWaveSpawnPositions(10, 15.0) ]]
    self.playerHeroName=args.defaultHero
    if args.selectedSide=="direside" then
        self.selectedSide=DOTA_TEAM_BADGUYS
    else
        self.selectedSide=DOTA_TEAM_GOODGUYS
    end
    if args.selectedLane=="topLane" then
        self.selectedLane="top"
    elseif args.selectedLane=="midLane" then
        self.selectedLane="mid"
    else
        self.selectedLane="bot"
    end
    
    self.Player=PlayerResource:GetPlayer(0)
    local old_hero=self.Player:GetAssignedHero()
    self.playerHero=replaceHero(old_hero,self.playerHeroName)
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    print('debug:',self.selectedSide,self.selectedLane,self.playerSpawns[self.selectedSide][self.selectedLane])
    self.playerHero:SetAbsOrigin(self.playerSpawns[self.selectedSide][self.selectedLane])
    --[[ PlayerResource:SetCustomTeamAssignment(args.PlayerID,self.selectedSide) ]]
    self.playerHero:SetTeam(self.selectedSide)
    self.Player=PlayerResource:GetPlayer(0)
    self.Player:SetTeam(self.selectedSide)
    local cycleStartTime
    if self.selectedLane=="mid" then
        cycleStartTime=15
        CreepController:SpawnCreepWave15sec(DOTA_TEAM_BADGUYS,self.selectedLane,'initial')
        CreepController:SpawnCreepWave15sec(DOTA_TEAM_GOODGUYS,self.selectedLane,'initial')
    else
        cycleStartTime=5
        CreepController:SpawnCreepWave25sec(DOTA_TEAM_BADGUYS,self.selectedLane,'initial')
        CreepController:SpawnCreepWave15sec(DOTA_TEAM_GOODGUYS,self.selectedLane,'initial')
    end
    self.waveTimer=Timers:CreateTimer(cycleStartTime,function()
        CreepController:SpawnCreepWave(DOTA_TEAM_BADGUYS,self.selectedLane,'initial')
        CreepController:SpawnCreepWave(DOTA_TEAM_GOODGUYS,self.selectedLane,'initial')
    end)
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

function lasthit_training:SendItemTable()
    
    CustomGameEventManager:Send_ServerToAllClients("lasthit_training_spell_table", self.startingItems)
end

function lasthit_training:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function lasthit_training:Deactivate()
    self.activated = false
    Timers:RemoveTimer(self.waveTimer)
    self.deactivateCalled = false
    self.playerHero:SetTeam(DOTA_TEAM_GOODGUYS)
    self.Player:SetTeam(DOTA_TEAM_GOODGUYS)
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

lasthit_training:Init()
GamemodeManager:RegisterMode(lasthit_training.name, lasthit_training, lasthit_training.type)