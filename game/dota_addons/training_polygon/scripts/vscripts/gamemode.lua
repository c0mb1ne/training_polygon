-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"
CMB_SERVER="http://vh184007.eurodir.ru/tpserver/"
DEVBUG_SERVER="http://tpsite/"
PLAYER_CONFIG=nil
ACTIVE_GAMEMODE=nil
-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
--require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
--require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
--require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
--require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
--require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
--require('libraries/playertables')
-- This library can be used to create container inventories or container shops
--require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
--require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
--require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
--require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')

require('internal/events')
require('casting')
--require('nai')
json = require "json"
-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
require('libraries/dota_database')
require('gamemodes/dodge')

require('libraries/action_logging')
require('libraries/ping_reader')
require('libraries/precache')
require('utils')
ping_reader:Init()
DotaDB:Init()
action_logging:Init()
precache:Init()
dodge:Init()


function GameMode:activateGameMode( args )
  print(args)
  if args['gameModeName']=="dodge" then
    --[[ dodge:Init() ]]
    ACTIVE_GAMEMODE=dodge
  end
  ACTIVE_GAMEMODE:Prepare(args)
  
end
CustomGameEventManager:RegisterListener("activate_game_mode", function(_, eventData)
  GameMode:activateGameMode(eventData)
end)





function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    

end


function GameMode:OnFirstPlayerLoaded()
  --nice place to put things that should be performed on very early stage of the game
  TRAINING_PLACE=nil
  TEST_ID=1
  ebalai=nil
  DebugPrint("[BAREBONES] First Player has loaded")
  if GetMapName() == "dotaaaaa" then
    TRAINING_PLACE=Vector(-2276.069336, 5846.962891, 256.000000)
    local classes_to_remove={"npc_dota_neutral_spawner",
                            "npc_dota_spawner_good_bot",
                            "npc_dota_spawner_good_mid",
                            "npc_dota_spawner_good_top",
                            "npc_dota_spawner_bad_top",
                            "npc_dota_spawner_bad_mid",
                            "npc_dota_spawner_bad_bot"}
    for k,class_to_remove in pairs(classes_to_remove) do
      print("Removing:",class_to_remove)
      local spawns_to_remove=Entities:FindAllByClassname(class_to_remove)
      for k,v in pairs(spawns_to_remove) do
        print(k,"removing")
        v:RemoveSelf()
      end
    end
  else
    TRAINING_PLACE=Vector(0,0,128)
  end
  
  --precacheTable(MANTA_PRECACHE)
  local oldDelayValue=0
  CHEAT_MODE=0
  Timers:CreateTimer("convar_controller", {
    useGameTime = false,
    endTime = 0,
    callback = function()
      if not IsInToolsMode() then
        if GameRules:IsCheatMode() and CHEAT_MODE==0 then
          print("Cheat mode detected")
          CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes="Cheat mode detected"})
          CHEAT_MODE=1
        end
      end



      return FrameTime()
    end
  })
  GameRules:SetTimeOfDay(0.5)
  --doing precache for every hero in game for player, since monster hunter collab PrecacheUnitByNameAsync start accepting playerid argument to precache hero with player's skins, if we dont do that player's heroes with non default skins will have an error model, for non player heroes (bots) we do precache without last argument
  --this should be switched to precaching players hero right before individual mode starts, code below is temporary solution
  print("precaching every hero")
  local heroesKV=LoadKeyValues("scripts/npc/npc_heroes.txt")
  local heroList={}
  for k,v in pairs(heroesKV) do
    if k~="Version" then
        table.insert(heroList,k)
    end
  end
  local index=1
  local totalHeroes=#heroList
  function precache_for_player(hero)
    PrecacheUnitByNameAsync(hero,function()
      print("hero loaded:",hero)
      CustomGameEventManager:Send_ServerToAllClients("precache_progress",{current=index,total=totalHeroes,hero=hero})
      index=index+1
      if index<=#heroList then
        precache_for_player(heroList[index])
      else
        CustomGameEventManager:Send_ServerToAllClients("precache_complete",{})
      end
    end,0)
  end
  --precache_for_player(heroList[index])
end

function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end



function GameMode:OnHeroInGame(hero)

  local cmdPlayer=PlayerResource:GetPlayer(0)
  local steam=PlayerResource:GetSteamID(cmdPlayer:GetPlayerID())
  --[[ print(tostring(steam)) ]]
  if hero:GetOwner()==cmdPlayer then
    if PLAYER_CONFIG=="no config" or PLAYER_CONFIG==nil then
      getConfigData(steam)
    end
  end
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  if hero:IsOwnedByAnyPlayer() then

    
    hero:SetAbilityPoints(0)

  end

end


function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")



end

function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  timingCalc=Time()
  LinkLuaModifier("modifier_no_health_bar", "libraries/modifiers/modifier_no_health_bar.lua", LUA_MODIFIER_MOTION_NONE)

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand("tp_test", Dynamic_Wrap(GameMode, 'TestCommand1'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand("tp_test2", Dynamic_Wrap(GameMode,'TestCommand2'),"petuch",FCVAR_CHEAT) 
  Convars:RegisterCommand("tp_hide_menu", Dynamic_Wrap(GameMode,'HideMenu'),"petuch",FCVAR_CHEAT) 
  Convars:RegisterCommand("tp_show_menu", Dynamic_Wrap(GameMode,'ShowMenu'),"petuch",FCVAR_CHEAT) 
  Convars:RegisterCommand("tp_print_place", Dynamic_Wrap(GameMode,'cmdPrintPlace'),"petuch",FCVAR_CHEAT) 
  Convars:RegisterCommand("tp_start_glimpse", Dynamic_Wrap(GameMode,'cmdStartGlimpse'),"petuch",FCVAR_CHEAT) 
  Convars:RegisterConvar("tp_delay", "0", "Force delay", 0)
  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
  GameRules:GetGameModeEntity():SetTrackingProjectileFilter(Dynamic_Wrap(GameMode, "TrackingProjectileFilter"), self)
  GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(GameMode, "AbilityTuning"), self)
  GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierGained"), self)
  GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ExpFilter"), self)
  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "GoldFilter"), self)

end


function GameMode:cmdPrintPlace()
  local cmdPlayer=PlayerResource:GetPlayer(0)
  --DeepPrintTable(cmdPlayer)
  active_hero = cmdPlayer:GetAssignedHero()
  local respawn_place = active_hero:GetAbsOrigin()
  print('respawn_place:',respawn_place)
  print('Vector('..respawn_place.x..','..respawn_place.y..','..respawn_place.z..')')
  local hero_direction=active_hero:GetForwardVector()
  print('hero_direction',hero_direction)
  print('hero_direction_angle',math.floor(VectorToAngles(hero_direction).y))
  local color1=Vector(255,255,0)
  DebugDrawCircle(active_hero:GetAbsOrigin(), color1, 20, 20, true, 60)

end


function GameMode:HideMenu()
  CustomGameEventManager:Send_ServerToAllClients("hide_main_menu", {})
  CustomGameEventManager:Send_ServerToAllClients("cmd_hide_menu", {})
end

function GameMode:ShowMenu()
  CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
  CustomGameEventManager:Send_ServerToAllClients("cmd_show_menu", {})
end

function custom_manta_training( eventSourceIndex, args )


  DODGE_HEROES={
                 "npc_dota_hero_antimage",
                 "npc_dota_hero_ember_spirit",
                 "npc_dota_hero_puck",
                 "npc_dota_hero_storm_spirit",
                 "npc_dota_hero_bane",
                 "npc_dota_hero_naga_siren",
                 "npc_dota_hero_monkey_king",
                 "npc_dota_hero_nyx_assassin",
                 "npc_dota_hero_void_spirit"
                }
  DODGE_TYPE=args["dodge_type"]
  local hero_name=DODGE_HEROES[DODGE_TYPE]
  CustomGameState=1
  MANTA_SKILL_ID=0
  MANTA_CURRENT_SKILL=""
  MANTA_SKILL_CASTED=0
  MANTA_SKILL_CASTED_TIME=0
  MANTA_HERO_HURT=0
  MANTA_HERO_HURT_TIME=0
  MANTA_CASTED=0
  MANTA_CASTED_TIME=0
  MANTA_MODIFIER_GAINED=0
  MANTA_POMOSHNIK=nil
  TimebarState=args['timebar']
  ShuffleMode=args['shuffle']
  BlinkBehavior=args['blink']
  CustomGameEventManager:Send_ServerToAllClients("custom_training_start",{timebar=TimebarState,blink=BlinkBehavior})
  local castTime=0
  local player=PlayerResource:GetPlayer(args.PlayerID)

  active_hero=player:GetAssignedHero()
  if active_hero:GetName()~=hero_name then
    --active_hero:RemoveSelf()
    -- PlayerResource:ReplaceHeroWith(args.PlayerID,hero_name,0,1)
    replaceHero(active_hero,hero_name)
    active_hero=player:GetAssignedHero()
  end
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  active_hero:SetBaseHealthRegen(25)
  active_hero:SetBaseStrength(200)
  active_hero:SetAbilityPoints(0)
  active_hero:SetBaseManaRegen(0)
  active_hero:SetMoveCapability(0)
  if hero_name=="npc_dota_hero_storm_spirit" then
    active_hero:SetMoveCapability(1)
    active_hero:SetBaseMoveSpeed(0)
    active_hero:SetMaxMana(0)
    active_hero:SetBaseManaRegen(20)
    active_hero:SetBaseIntellect(-10)
    active_hero:SetBaseAgility(0)
--[[    active_hero:AddNewModifier(active_hero, nil, "modifier_bristleback_viscous_nasal_goo", {})
    active_hero:SetModifierStackCount("modifier_bristleback_viscous_nasal_goo", unit, 20)--]]
  end
  
  active_hero:SetBaseHealthRegen(0)
  active_hero:SetBaseStrength(100)
  active_hero:SetAttackCapability(0)
  
  if BlinkBehavior==1 then
    active_hero:SetDayTimeVisionRange(675)
  else
    active_hero:SetDayTimeVisionRange(2000)
  end
  --active_hero:SetBaseMaxHealth(2000)
  for i=0,14 do
    local itemFind=active_hero:GetItemInSlot(i)
    --print(itemFind)
    if itemFind~=nil then
      active_hero:RemoveItem(itemFind)
    end
  end
  if DODGE_TYPE==1 then
    local item = CreateItem("item_manta",active_hero,active_hero)
    active_hero:AddItem(item)
  end
  if DODGE_TYPE==2 then
    local fist=active_hero:FindAbilityByName("ember_spirit_sleight_of_fist")
    fist:SetLevel(1)
    local target="npc_dota_creep_badguys_melee"
    pomoshnik=CreateUnitByName(target, randomCirclePosition(200,active_hero), true, nil, nil, DOTA_TEAM_BADGUYS)
    pomoshnik:SetMoveCapability(0)
    pomoshnik:SetIdleAcquire(false)
    pomoshnik:SetBaseHealthRegen(200)
    pomoshnik:SetMaximumGoldBounty(0)
    pomoshnik:SetMinimumGoldBounty(0)
    pomoshnik:SetDeathXP(0)
    MANTA_POMOSHNIK=pomoshnik
  end
  if DODGE_TYPE==3 then
    local shift=active_hero:FindAbilityByName("puck_phase_shift")
    shift:SetLevel(1)
  end
  if DODGE_TYPE==4 then
    local shift=active_hero:FindAbilityByName("storm_spirit_ball_lightning") --0.3
    shift:SetLevel(1)
  end
  if DODGE_TYPE==5 then
    local shift=active_hero:FindAbilityByName("bane_nightmare")--0.4
    shift:SetLevel(1)
  end
  if DODGE_TYPE==6 then
    local shift=active_hero:FindAbilityByName("naga_siren_mirror_image")--0.65
    shift:SetLevel(1)
  end
  if DODGE_TYPE==7 then
--[[    active_hero:AddAbility("monkey_king_mischief")--]]
    local shift=active_hero:FindAbilityByName("monkey_king_mischief")--0.2
    shift:SetLevel(1)
  end
  if DODGE_TYPE==8 then
--[[    active_hero:AddAbility("monkey_king_mischief")--]]
    local shift=active_hero:FindAbilityByName("nyx_assassin_spiked_carapace")--хуй знает
    shift:SetLevel(1)
  end
  if DODGE_TYPE==9 then
--[[    active_hero:AddAbility("monkey_king_mischief")--]]
    local shift=active_hero:FindAbilityByName("void_spirit_dissimilate")--хуй знает
    shift:SetLevel(1)
  end
  --monkey_king_mischief
  local id=0
  local castDelay=3
  local deathDelay=2
  local ids = {}
  allowed_skills=args['skills']
  local i=0
  while allowed_skills[tostring(i)] do
    table.insert(ids, allowed_skills[tostring(i)])
    i=i+1
  end
  if ShuffleMode==1 or BlinkBehavior==1 then
    shake(ids)
  end
  local ids_count=#ids
  local id_counter=1
  Timers:CreateTimer("manta_training_timer", {
    useOldStyle = true,
    endTime = GameRules:GetGameTime() + 1,
    callback = function()
      local randomDelay=0
      if BlinkBehavior==1 then
        randomDelay=RandomFloat(0, 1.2)
      end
      MANTA_SKILL_ID=ids[id_counter]
      --print("######ID CHANGED:",MANTA_SKILL_ID)
      refreshSkills(active_hero)
      castTime=castSpellById(ids[id_counter],active_hero,castDelay,deathDelay)
      local nextCast=castDelay+castTime+1
      id_counter=id_counter+1
      
      if id_counter>ids_count then
        if ShuffleMode==1 or BlinkBehavior==1 then
          shake(ids)
        end
        id_counter=1
      end
      if CustomGameState==1 then
        return GameRules:GetGameTime() + nextCast+randomDelay
      else
        CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
        return nil
      end



      --print ("Hello. I'm running after 5 seconds and then every second thereafter.")
      return GameRules:GetGameTime() + 1
    end
  })
end

function swap(array, index1, index2)
  array[index1], array[index2] = array[index2], array[index1]
end

function shake(array)
  local counter = #array

  while counter > 1 do
    local index = math.random(counter)

    swap(array, index, counter)   
    counter = counter - 1
  end
end

function custom_manta_training_end( eventSourceIndex, args )
  if MANTA_POMOSHNIK~=nil then
    if not MANTA_POMOSHNIK:IsNull() then
      MANTA_POMOSHNIK:RemoveSelf()
    end
  end
  CustomGameState=0
  Timers:RemoveTimer("manta_training_timer")
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})

end

function euls_training_end( eventSourceIndex, args )
  eulsGameState=0
  if not pizduk:IsNull() then
    pizduk:RemoveSelf()
  end
  if pizduki then
    for i=1,#pizduki, 1 do
      pizduki[1]:RemoveSelf()
      table.remove(pizduki,1)
      print("pizduk removed:",i)
    end
  end
  if TIMING_TYPE==3 or TIMING_TYPE==4 then
    Timers:RemoveTimer("timing_bratan_casting")
  end
  if TIMING_TYPE==1 or TIMING_TYPE==2 or TIMING_TYPE==6 then
    Timers:RemoveTimer("timing_bratan_casting")
    Timers:CreateTimer("timing_bratan_destroy", {
      useGameTime=true,
      endTime=1,
      callback=function()
      print(bratan_hero[TIMING_TYPE])
        local pizdatebe=Entities:FindByName(nil, bratan_hero[TIMING_TYPE])
        pizdatebe:RemoveSelf()
      end
    })
    
  end
  if TIMING_TYPE==5 then
    tower:RemoveSelf()
  end
  
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end
function timing_training_start( eventSourceIndex, args )

  print('timing training started')
  TIMING_TRASH={}
  TIMING_TRAINING=0
  TIMING_PRIMARY_SKILL_ID=args['timingType']+1
  TIMING_SECONDARY_SKILL_ID=args['skillId']
  TIMING_RUBICK_MODE=args['rubick_mode']
  TIMING_TARGET_UNIT=nil
  TIMING_BRATAN=nil
  TIMING_BRATAN_ABILITY=nil
  TIMING_ABILITY=nil
  TIMING_ABILITY_H=nil
  local player
  secondary_skills_table={{"item_meteor_hammer", "npc_dota_hero_naga_siren" , "modifier_stunned"},
                          {"axe_berserkers_call",  "npc_dota_hero_axe", "modifier_axe_berserkers_call"},
                          {"centaur_hoof_stomp", "npc_dota_hero_centaur", "modifier_stunned"},
                          {"earth_spirit_boulder_smash", "npc_dota_hero_earth_spirit" , "modifier_stunned"},
                          {"earthshaker_fissure",  "npc_dota_hero_earthshaker", "modifier_earthshaker_fissure_stun"},
                          {"earthshaker_enchant_totem",  "npc_dota_hero_earthshaker", "modifier_stunned"},
                          {"earthshaker_enchant_totem",  "npc_dota_hero_earthshaker", "modifier_stunned"},
                          {"earthshaker_echo_slam",  "npc_dota_hero_earthshaker", "modifier_stunned"},
                          {"elder_titan_echo_stomp", "npc_dota_hero_elder_titan", "modifier_elder_titan_echo_stomp"},
                          {"ember_spirit_searing_chains",  "npc_dota_hero_ember_spirit" , "modifier_ember_spirit_searing_chains"},
                          {"gyrocopter_call_down", "npc_dota_hero_gyrocopter" , "modifier_gyrocopter_call_down_slow"},
                          {"kunkka_torrent", "npc_dota_hero_kunkka" , "modifier_kunkka_torrent"},
                          {"kunkka_ghostship", "npc_dota_hero_kunkka" , "modifier_stunned"},
                          {"kunkka_ghostship", "npc_dota_hero_kunkka" , "modifier_kunkka_ghost_ship_knockback"},
                          {"magnataur_skewer", "npc_dota_hero_magnataur", "modifier_magnataur_skewer_impact"},
                          {"magnataur_reverse_polarity", "npc_dota_hero_magnataur", "modifier_stunned"},
                          {"pudge_meat_hook",  "npc_dota_hero_pudge", "modifier_pudge_meat_hook"},
                          {"sandking_burrowstrike",  "npc_dota_hero_sand_king", "modifier_sandking_impale"},
                          {"slardar_slithereen_crush", "npc_dota_hero_slardar", "modifier_stunned"},
                          {"spirit_breaker_charge_of_darkness",  "npc_dota_hero_spirit_breaker" , "modifier_knockback"},
                          {"tidehunter_ravage",  "npc_dota_hero_tidehunter" , "modifier_tidehunter_ravage"},
                          {"tusk_snowball",  "npc_dota_hero_tusk" , "modifier_stunned"},
                          {"bloodseeker_blood_bath", "npc_dota_hero_bloodseeker", "modifier_silence"},
                          {"lone_druid_savage_roar", "npc_dota_hero_lone_druid" , "modifier_lone_druid_savage_roar"},
                          {"meepo_poof", "npc_dota_hero_meepo", "dmg"},
                          {"mirana_arrow", "npc_dota_hero_mirana" , "modifier_stunned"},
                          {"monkey_king_boundless_strike", "npc_dota_hero_monkey_king", "modifier_monkey_king_boundless_strike_stun"},
                          {"nyx_assassin_impale",  "npc_dota_hero_nyx_assassin" , "modifier_nyx_assassin_impale"},
                          {"pangolier_shield_crash", "npc_dota_hero_pangolier", "dmg"},
                          {"nevermore_shadowraze1",  "npc_dota_hero_nevermore", "dmg"},
                          {"nevermore_shadowraze2",  "npc_dota_hero_nevermore", "dmg"},
                          {"nevermore_shadowraze3",  "npc_dota_hero_nevermore", "dmg"},
                          {"nevermore_requiem",  "npc_dota_hero_nevermore", "dmg"},
                          --{"slark_pounce", "npc_dota_hero_slark", "modifier_slark_pounce_leash"},
                          {"ancient_apparition_cold_feet", "npc_dota_hero_ancient_apparition" , "modifier_ancientapparition_coldfeet_freeze"},
                          {"ancient_apparition_ice_blast", "npc_dota_hero_ancient_apparition" , "modifier_ice_blast"},
                          {"dark_seer_vacuum", "npc_dota_hero_dark_seer", "modifier_dark_seer_vacuum"},
                          {"dark_willow_cursed_crown", "npc_dota_hero_dark_willow", "modifier_stunned"},
                          {"death_prophet_silence",  "npc_dota_hero_death_prophet", "modifier_silence"},
                          --{"invoker_tornado",  "npc_dota_hero_invoker", "modifier_invoker_tornado"},
                          {"invoker_emp",  "npc_dota_hero_invoker", "dmg"},
                          {"invoker_chaos_meteor", "npc_dota_hero_invoker", "modifier_invoker_chaos_meteor_burn"},
                          {"invoker_sun_strike", "npc_dota_hero_invoker", "dmg"},
                          --{"invoker_deafening_blast",  "npc_dota_hero_invoker", "modifier_invoker_deafening_blast_disarm"},
                          {"leshrac_split_earth",  "npc_dota_hero_leshrac", "modifier_stunned"},
                          {"lina_light_strike_array",  "npc_dota_hero_lina" , "modifier_stunned"},
                          {"lion_impale",  "npc_dota_hero_lion" , "modifier_lion_impale"},
                          {"puck_waning_rift", "npc_dota_hero_puck" , "modifier_silence"},
                          {"pugna_nether_blast", "npc_dota_hero_pugna", "dmg"},
                          {"visage_summon_familiars", "npc_dota_hero_visage" , "modifier_stunned"},
                          {"warlock_rain_of_chaos",  "npc_dota_hero_warlock", "modifier_stunned"},
                          {"windrunner_shackleshot", "npc_dota_hero_windrunner" , "modifier_windrunner_shackle_shot"}
                          }
  primary_skills_table={
                        {"item_cyclone",  "npc_dota_hero_shadow_demon"},
                        {"shadow_demon_disruption", "npc_dota_hero_shadow_demon"},
                        {"obsidian_destroyer_astral_imprisonment",  "npc_dota_hero_obsidian_destroyer"},
                        {"item_aegis",  "npc_dota_hero_antimage"},
                        {"skeleton_king_reincarnation", "npc_dota_hero_skeleton_king"},
                        {"item_travel_boots",  "npc_dota_hero_storm_spirit"},
                        {"naga_siren_song_of_the_siren",  "npc_dota_hero_naga_siren"},
                        {"disruptor_glimpse",  "npc_dota_hero_disruptor"},
                        {"kunkka_return",  "npc_dota_hero_kunkka"},
                        {"brewmaster_storm_dispel_magic",  "npc_dota_hero_brewmaster"}
                      }
  print('prim_id',TIMING_PRIMARY_SKILL_ID)
  print('sec_id',TIMING_SECONDARY_SKILL_ID)
  local skill_calculator=CreateUnitByName("npc_dummy_unit", TRAINING_PLACE, true, nil, nil, DOTA_TEAM_GOODGUYS)
  local primary_name=primary_skills_table[TIMING_PRIMARY_SKILL_ID][1]
  local primary_values=getAbilityCastpoint(primary_name,skill_calculator)
  local primary_castpoint=primary_values[1]
  local primary_delay=primary_values[2]
  

  local secondary_name=secondary_skills_table[TIMING_SECONDARY_SKILL_ID][1]
  local secondary_values=getAbilityCastpoint(secondary_name,skill_calculator)
  local secondary_castpoint=secondary_values[1]
  local secondary_delay=secondary_values[2]
  

  skill_calculator:RemoveSelf()
--dispay_delays
  CustomGameEventManager:Send_ServerToAllClients("dispay_delays",{primary=primary_delay,primary_img=primary_name, secondary=secondary_delay,secondary_img=secondary_name,prim_cp=primary_castpoint,sec_cp=secondary_castpoint})
  TIMING_START=args['start']
  local respawn_place=TRAINING_PLACE+Vector(0,400,0)
  local respawn_place2=randomCirclePositionVector(300,respawn_place)
  if TIMING_START==1 then
    TIMING_TRAINING=1
    
    if TIMING_PRIMARY_SKILL_ID~=5 then
      TIMING_TARGET_UNIT=CreateUnitByName("npc_dota_hero_tiny", respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)
    else
      TIMING_TARGET_UNIT=CreateUnitByName("npc_dota_hero_skeleton_king", respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)
    end
    TIMING_TARGET_UNIT:SetAttackCapability(0)
    TIMING_TARGET_UNIT:ModifyStrength(300)
    TIMING_TARGET_UNIT:SetBaseHealthRegen(10)
    if TIMING_PRIMARY_SKILL_ID~=4 or TIMING_PRIMARY_SKILL_ID~=5 or TIMING_PRIMARY_SKILL_ID~=6 then
      if secondary_delay+secondary_castpoint<primary_delay+primary_castpoint then
        TIMING_BRATAN=CreateUnitByName(primary_skills_table[TIMING_PRIMARY_SKILL_ID][2], respawn_place2, true, nil, nil, DOTA_TEAM_GOODGUYS)
        TIMING_BRATAN:SetAttackCapability(0)

        TIMING_BRATAN_ABILITY=primary_skills_table[TIMING_PRIMARY_SKILL_ID][1]
        TIMING_BRATAN_ABILITY_H=timingAddAbility(TIMING_BRATAN,TIMING_BRATAN_ABILITY)
        TIMING_TARGET_UNIT:SetAttackCapability(0)
        player=PlayerResource:GetPlayer(args.PlayerID)
        active_hero=player:GetAssignedHero()
        active_hero=replaceHero(active_hero,secondary_skills_table[TIMING_SECONDARY_SKILL_ID][2])
        active_hero:SetAbsOrigin(TRAINING_PLACE)
        GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
        TIMING_ABILITY=secondary_skills_table[TIMING_SECONDARY_SKILL_ID][1]
        TIMING_ABILITY_H=timingAddAbility(active_hero,TIMING_ABILITY)
        timingAutocastAI(TIMING_BRATAN,TIMING_BRATAN_ABILITY_H,primary_delay+primary_castpoint,TIMING_TARGET_UNIT)
        CustomGameEventManager:Send_ServerToAllClients("timing_started",{barTime=primary_delay,castpoint=secondary_castpoint,delay=secondary_delay,user_abil=TIMING_ABILITY,bot_abil=TIMING_BRATAN_ABILITY,formula_prim=primary_values[3],formula_sec=secondary_values[3],target_name=TIMING_TARGET_UNIT:GetUnitName()})
      else
        TIMING_BRATAN=CreateUnitByName(secondary_skills_table[TIMING_SECONDARY_SKILL_ID][2], respawn_place2, true, nil, nil, DOTA_TEAM_GOODGUYS)
        TIMING_BRATAN:SetAttackCapability(0)
        TIMING_BRATAN_ABILITY=secondary_skills_table[TIMING_SECONDARY_SKILL_ID][1]
        TIMING_BRATAN_ABILITY_H=timingAddAbility(TIMING_BRATAN,TIMING_BRATAN_ABILITY)
        TIMING_TARGET_UNIT:SetAttackCapability(0)
        player=PlayerResource:GetPlayer(args.PlayerID)
        active_hero=player:GetAssignedHero()
        active_hero=replaceHero(active_hero,primary_skills_table[TIMING_PRIMARY_SKILL_ID][2])
        active_hero:SetAbsOrigin(TRAINING_PLACE)
        GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
        TIMING_ABILITY=primary_skills_table[TIMING_PRIMARY_SKILL_ID][1]
        TIMING_ABILITY_H=timingAddAbility(active_hero,TIMING_ABILITY)
        timingAutocastAI(TIMING_BRATAN,TIMING_BRATAN_ABILITY_H,secondary_delay+secondary_castpoint,TIMING_TARGET_UNIT)
        CustomGameEventManager:Send_ServerToAllClients("timing_started",{barTime=secondary_delay,castpoint=primary_castpoint,delay=primary_delay,user_abil=TIMING_ABILITY,bot_abil=TIMING_BRATAN_ABILITY,formula_prim=primary_values[3],formula_sec=secondary_values[3],target_name=TIMING_TARGET_UNIT:GetUnitName()})
      end


    else
      


    end
    
  end
  table.insert(TIMING_TRASH,TIMING_BRATAN)
  table.insert(TIMING_TRASH,TIMING_TARGET_UNIT)
end
function timing_training_end( eventSourceIndex, args )
  TIMING_TRAINING=0
  for k,v in pairs(TIMING_TRASH) do
    if not v:IsNull() then
      v:RemoveSelf()
    end
  end
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end
function euls_training_start( eventSourceIndex, args )
  --hidden challange
  EUL_TRAINING_START_TIME=Time()

  eulsGameState=1
  local skill_id=args['skillId']
  eulTimebar=args['timebar']
  local eulLense=args['lense']
  local eulBlink=args['blink']
  TIMING_TYPE=args['timingType']
  --skill->hero
  eul_skills={"kunkka_torrent",--id=1
              "nevermore_requiem",--id=2
              "invoker_sun_strike",--id=3
              "elder_titan_echo_stomp",--id=4
              "techies_suicide",--id=5
              "death_prophet_silence",--id=6
              "lina_light_strike_array",--id=7
              "earthshaker_fissure",--id=8 lvlc
              "earthshaker_enchant_totem",--id=9
              "leshrac_split_earth",--id=10
              "slardar_slithereen_crush",--id=11
              "centaur_hoof_stomp",--id=12
              "bloodseeker_blood_bath",--id=13
              "earthshaker_enchant_totem",--id=14 with AGHS
              "windrunner_powershot",
              "lion_impale",--id=15
              "nyx_assassin_impale",--id=16
              "phoenix_fire_spirits",--id=17
              "pudge_meat_hook",--id=18 lvlc
              "earth_spirit_boulder_smash",--id=19
              "mirana_arrow",--id=20
              "sandking_burrowstrike",--id=21 lvlc
              "spirit_breaker_greater_bash",--id=22
              "spirit_breaker_greater_bash",--id=23 with talent
              "sandking_burrowstrike",--id 24 AGHS lvlc
              "nyx_assassin_spiked_carapace",--id 25 AGHS
              "earthshaker_echo_slam",
              "item_meteor_hammer"
            }

  eul_heroes={"npc_dota_hero_kunkka",--id=1
              "npc_dota_hero_nevermore",--id=2
              "npc_dota_hero_invoker",--id=3
              "npc_dota_hero_elder_titan",--id=4
              "npc_dota_hero_techies",--id=5
              "npc_dota_hero_death_prophet",--id=6
              "npc_dota_hero_lina",--id=7
              "npc_dota_hero_earthshaker",--id=8
              "npc_dota_hero_earthshaker",--id=9
              "npc_dota_hero_leshrac",--id=10
              "npc_dota_hero_slardar",--id=11
              "npc_dota_hero_centaur",--id=12
              "npc_dota_hero_bloodseeker",--id=13
              "npc_dota_hero_earthshaker",--id=14 AGHS
              "npc_dota_hero_windrunner",
              "npc_dota_hero_lion",--id=15
              "npc_dota_hero_nyx_assassin",--id=16
              "npc_dota_hero_phoenix",--id=17
              "npc_dota_hero_pudge",--id=18
              "npc_dota_hero_earth_spirit",--id=19
              "npc_dota_hero_mirana",--id=20
              "npc_dota_hero_sand_king",--id=21
              "npc_dota_hero_spirit_breaker",--id=22
              "npc_dota_hero_spirit_breaker",--id=23 with talent
              "npc_dota_hero_sand_king",--id=24 with AGHS
              "npc_dota_hero_nyx_assassin",--id=25 AGHS
              "npc_dota_hero_earthshaker",
              "npc_dota_hero_riki"
            }

  eul_castpoints={2,--id=1
                  1.67,--id=2
                  1.75,--id=3
                  1.7,--id=4
                  1.75,--id=5
                  0.5,--id=6
                  0.95,--id=7
                  0.69,--id=8
                  0.69,--id=9
                  1.05,--id=10
                  0.35,--id=11
                  0.5,--id=12
                  2.6,--id=13
                  1,--id=14 AGHS
                  1,
                  0,--id=15
                  0,--id=16
                  0,--id=17
                  0,--id=18
                  0,--id=19
                  0,--id=20
                  0,--id=21
                  0,--id=22
                  0,--id=23 with talent
                  0,--id=24 AGHS
                  0,
                  0,--id=25 AGHS
                  3
                }
  timing_bartime={2.5,--id=0
                  2.5,--id=1
                  4,--id=2
                  5,--id=3
                  3,--id=4
                  3
                }        

  if eul_castpoints[skill_id]==0 then
    eulTimebar=0
  end
  TIMING_SR_ENABLED=0
  barTime=2.5
  if TIMING_TYPE==1 then
    TIMING_SR_ENABLED=1
  end
  if TIMING_TYPE==2 then
    TIMING_SR_ENABLED=1
    barTime=4
  end
  if TIMING_TYPE==3 then
    barTime=5
  end
  if TIMING_TYPE==4 then
    barTime=3
  end
  if TIMING_TYPE==5 then
    barTime=3
  end
  if TIMING_TYPE==6 then
    TIMING_SR_ENABLED=1
    barTime=8.5
  end
  if skill_id==13 and TIMING_TYPE==0 then
    barTime=2.6
    CustomGameEventManager:Send_ServerToAllClients("eul_training_started",{castpoint=2.5, timebar=eulTimebar, id=skill_id, bartime=eul_castpoints[skill_id],srSettings=TIMING_SR_ENABLED})
  else
    CustomGameEventManager:Send_ServerToAllClients("eul_training_started",{castpoint=eul_castpoints[skill_id], timebar=eulTimebar, id=skill_id, bartime=barTime,srSettings=TIMING_SR_ENABLED})
  end
  bratan_hero={"npc_dota_hero_shadow_demon",--id=1
            "npc_dota_hero_obsidian_destroyer",--id=2
            "",
            "",
            "",
            "npc_dota_hero_shadow_demon"
          }

  bratan_skill={"shadow_demon_disruption",--id=1
            "obsidian_destroyer_astral_imprisonment",--id=2
            "",
            "",
            "",
            "shadow_demon_disruption"
          }

  EUL_SKILL=eul_skills[skill_id]
  TIMING_CASTPOINT=eul_castpoints[skill_id]
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  hero=replaceHero(hero,eul_heroes[skill_id])
  hero:SetMoveCapability(1)
  hero:SetAttackCapability(0)
  hero:SetDayTimeVisionRange(4000)
  hero:SetAbsOrigin(TRAINING_PLACE)
  removeItems(hero)
  local respawn_place = randomRingPosition(300,500,hero)--respawn place for cm
  if EUL_SKILL=="spirit_breaker_greater_bash" then
    local passivka = hero:FindAbilityByName("spirit_breaker_charge_of_darkness")
    passivka:SetLevel(4)
    pizduki={}
    local direction = (hero:GetAbsOrigin()-respawn_place):Normalized()
    local target="npc_dota_creep_badguys_melee"
    for i=1,6, 1 do
      local target_point_vector = respawn_place + 600 * direction*i
      local pizduk3=CreateUnitByName(target, target_point_vector, true, nil, nil, DOTA_TEAM_BADGUYS)
      pizduk3:SetBaseHealthRegen(1000)
      pizduk3:SetIdleAcquire(false)
      pizduk3:SetMoveCapability(0)
      pizduk3:SetAttackCapability(0)
      pizduki[i]=pizduk3
      print("inserted:",i)
    end
    if skill_id==23 then
      local passivka2 = hero:FindAbilityByName("special_bonus_unique_spirit_breaker_2")
      passivka2:SetLevel(1)
    end
  end
  if skill_id==14 or skill_id==25 or skill_id==26 then
    local scepter = CreateItem("item_ultimate_scepter",hero,hero)
    hero:AddItem(scepter)
  end
  if EUL_SKILL=="nevermore_requiem" then
    local passivka = hero:FindAbilityByName("nevermore_necromastery")
    passivka:SetLevel(4)
    hero:SetModifierStackCount("modifier_nevermore_necromastery", hero, 36)
  end
  if eul_heroes[skill_id]=="npc_dota_hero_earthshaker" then
    local passivka = hero:FindAbilityByName("earthshaker_aftershock")
    passivka:SetLevel(4)
    local spell=hero:FindAbilityByName(eul_skills[skill_id])
    spell:SetLevel(1)
    EUL_SKILL="earthshaker_aftershock"
  end
  if eulLense==1 then
    local lense = CreateItem("item_aether_lens",hero,hero)
    hero:AddItem(lense)
  end
  if eulBlink==1 then
    local DAGGER = CreateItem("item_blink",hero,hero)
    hero:AddItem(DAGGER)
  end
  if EUL_SKILL=="invoker_sun_strike" then
    local spell=hero:FindAbilityByName("invoker_exort")
    spell:SetLevel(5)
  else
    if EUL_SKILL=="item_meteor_hammer" then
      ability=CreateItem("item_meteor_hammer",hero,hero)
      hero:AddItem(ability)
    else

      local spell=hero:FindAbilityByName(EUL_SKILL)
      spell:SetLevel(1)
    end
  end

  --print(EUL_SKILL)
  if TIMING_TYPE==0 then
    local item = CreateItem("item_cyclone",hero,hero)
    hero:AddItem(item)
  end
  TIMING_TARGET=""
  pizduk=nil
  --creating target
  if TIMING_TYPE==4 then
    TIMING_TARGET="npc_dota_hero_skeleton_king"
    pizduk=CreateUnitByName(TIMING_TARGET, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)
    
    local ultaWk=pizduk:FindAbilityByName("skeleton_king_reincarnation")
    ultaWk:SetLevel(1)
  else
    TIMING_TARGET="npc_dota_hero_tiny"
    pizduk=CreateUnitByName(TIMING_TARGET, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)

  end
  
  pizduk:SetMoveCapability(1)
  pizduk:SetBaseHealthRegen(100)
  removeItems(pizduk)
  local heart=CreateItem("item_heart",pizduk,pizduk)
  pizduk:AddItem(heart)
  local heart=CreateItem("item_heart",pizduk,pizduk)
  pizduk:AddItem(heart)
--[[  local heart=CreateItem("item_heart",pizduk,pizduk)
  pizduk:AddItem(heart)--]]
  local shroud=CreateItem("item_eternal_shroud",pizduk,pizduk)
  pizduk:AddItem(shroud)
  local item_pipe=CreateItem("item_pipe",pizduk,pizduk)
  pizduk:AddItem(item_pipe)
  local item_assault=CreateItem("item_assault",pizduk,pizduk)
  pizduk:AddItem(item_assault)
  pizduk:SetBaseStrength(0)
  Timers:CreateTimer({
    endTime = FrameTime(),
    callback = function()
    local strength=pizduk:GetBaseStrength()
    local statusResist=strength*0.15
    CustomGameEventManager:Send_ServerToAllClients("str_tracker",{str=strength, sr=statusResist})
    end
  })
  pizduk:SetAttackCapability(0)
  if TIMING_TYPE==3 then
    local aegis = CreateItem("item_aegis",pizduk,pizduk)
    pizduk:AddItem(aegis)
  end
  if TIMING_TYPE==3 or TIMING_TYPE==4 then
--[[    print('timing type correct')--]]
    Timers:CreateTimer("timing_bratan_casting", {
      useGameTime=true,
      endTime=1.5,
      callback=function()
          if pizduk:IsNull()~=true then
--[[            print('pizduk not null')--]]
            if TIMING_TYPE==3 then
              
              local aegis = CreateItem("item_aegis",pizduk,pizduk)
              pizduk:AddItem(aegis)
            end  
            refreshSkills(pizduk)
            pizduk:Kill(nil,hero)
          end   
        return barTime+3
      end
    })
  end
  if TIMING_TYPE==5 then
    tower_position=randomCirclePosition(300,hero)
    tower=CreateUnitByName("npc_dota_goodguys_tower1_mid",tower_position , true, nil, nil, DOTA_TEAM_BADGUYS)
    tower:SetAbsOrigin(tower_position)
    tower:SetAttackCapability(0)
    local item = CreateItem("item_travel_boots",pizduk,pizduk)
    pizduk:AddItem(item)
    local item2=pizduk:GetItemInSlot(15)
    item2:SetCurrentCharges(322)
    refreshItems2(pizduk)
    pizduk:SetAbsOrigin(Vector(-7901,7845,128))
    pizduk:SetMaxMana(3000)
    pizduk:SetMana(3000)
    --pizduk:SetControllableByPlayer(hero:GetPlayerID(),false)
    for i=1,10 do
      pizduk:HeroLevelUp(false)
    end
    Timers:CreateTimer("travel_boots_timer", {
      useGameTime = false,
      endTime = 2,
      callback = function()
        if not pizduk:IsNull() then
          pizduk:Purge(false,true,false,true,false)
          pizduk:SetAbsOrigin(Vector(-7901,7845,128))
          --item2=CreateItem("item_tpscroll",pizduk,pizduk)
          item2:EndCooldown()
          item2:RefundManaCost()
          
          pizduk:SetContextThink(DoUniqueString("pizduk_tp"),
          function()
            ExecuteOrderFromTable({
              UnitIndex = pizduk:entindex(),
              OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
              Position = randomCirclePosition(300,tower),
              AbilityIndex = item2:entindex()
            })
          end,
          0) 
          return barTime+3
        else
          return nil
        end
      end
    })
  end

  local bratan_respawn=randomRingPosition(200,201,pizduk)
  if TIMING_TYPE==1 or TIMING_TYPE==2 or TIMING_TYPE==6 then
    bratan = CreateUnitByNameAsync(bratan_hero[TIMING_TYPE], bratan_respawn, true, nil, nil, DOTA_TEAM_GOODGUYS, function(unit)
      unit:SetAttackCapability(0)
      unit:SetForwardVector((pizduk:GetOrigin() - bratan_respawn):Normalized())
      local ability = unit:FindAbilityByName(bratan_skill[TIMING_TYPE])
      if TIMING_TYPE==2 then 
        ability:SetLevel(4)
      else
        ability:SetLevel(1)
      end
      if TIMING_TYPE==6 then
        local talent=unit:FindAbilityByName("special_bonus_unique_shadow_demon_5")
        talent:SetLevel(1)
      end
      Timers:CreateTimer("timing_bratan_casting", {
        useGameTime=true,
        endTime=1.5,
        callback=function()
          ability:EndCooldown()
          ability:RefundManaCost()
          unit:SetContextThink(DoUniqueString("cast_ability"),function()  unit:CastAbilityOnTarget(pizduk,ability,DOTA_TEAM_GOODGUYS) end, 0)
          return barTime+1
        end
      })
      return unit
    end)
  end
end



function euls_change_abil_lvl( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  local spell
  if KUNNKA_TRAINING==1 then
    spell=hero:FindAbilityByName("kunkka_x_marks_the_spot")
  else
    spell=hero:FindAbilityByName(EUL_SKILL)
  end
  local lvl=spell:GetLevel()
  if args['plus']==1 then
    if lvl<4 then
      spell:SetLevel(lvl+1)
    end
  else
    if lvl>1 then
      spell:SetLevel(lvl-1)
    end
  end
end

function euls_change_str( eventSourceIndex, args )
  local increment=args['plus']
  if args['type']=='sr' then
    increment=increment*20
  end
  local tiny_arr=Entities:FindAllByName(TIMING_TARGET)
  local tiny
  for k,v in pairs(tiny_arr) do
    tiny=v
  end
  local kek=tiny:GetBaseStrength()
  local new_value=kek+increment
  if eulsGameState==1 then
    if eulTimebar==1 then
      local sR=new_value*0.15
      local max_time=TIMING_CASTPOINT+0.05
      local now_time=(1-(sR/100))*barTime
      if now_time<max_time then
        new_value=-1
      end
    end
  end
  if KUNNKA_TYPE==2 then
    local sR=new_value*0.15
    if sR>15 then
      new_value=-1
    end
  end
  if new_value>=0 and new_value<650 then
    tiny:SetBaseStrength(new_value)
    Timers:CreateTimer({
      endTime = FrameTime(),
      callback = function()
      local strength=tiny:GetBaseStrength()
      local statusResist=strength*0.15
      CustomGameEventManager:Send_ServerToAllClients("str_tracker",{str=strength, sr=statusResist})
      end
    })
  end
end

function alchemist_banka_training( eventSourceIndex, args )
  AlchemistTrainingState=1
  local TimebarState=args['timebar']
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  active_hero=replaceHero(hero,"npc_dota_hero_alchemist")
  active_hero:SetMoveCapability(1)
  active_hero:SetBaseHealthRegen(100)
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  removeItems(active_hero)
  local item = CreateItem("item_manta",active_hero,active_hero)
  active_hero:AddItem(item)
  local ability_name = "alchemist_unstable_concoction"
  local ability = active_hero:FindAbilityByName(ability_name)
  ability:SetLevel(1)
  CustomGameEventManager:Send_ServerToAllClients("eul_training_started",{castpoint=0.1, timebar=TimebarState, id=420, bartime=5.5})
end

function alchemist_banka_training_end( eventSourceIndex, args )
  AlchemistTrainingState=0
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function bodyblock_start( eventSourceIndex, args )
  AlchemistTrainingState=1
  local TimebarState=args['timebar']
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  active_hero=replaceHero(hero,"npc_dota_hero_alchemist")
  active_hero:SetMoveCapability(1)
  active_hero:SetBaseHealthRegen(100)
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  removeItems(active_hero)
  local item = CreateItem("item_manta",active_hero,active_hero)
  active_hero:AddItem(item)
  local ability_name = "alchemist_unstable_concoction"
  local ability = active_hero:FindAbilityByName(ability_name)
  ability:SetLevel(1)
  CustomGameEventManager:Send_ServerToAllClients("eul_training_started",{castpoint=0.1, timebar=TimebarState, id=420, bartime=5.5})
end

function bodyblock_end( eventSourceIndex, args )
  AlchemistTrainingState=0
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end


function morph_training_start( eventSourceIndex, args )
  CustomGameEventManager:Send_ServerToAllClients("morph_start",{type='aim'})
  MORPH_TRAINING=1
  if MORPHLING_TARGET~=nil then
    if not MORPHLING_TARGET:IsNull() then
      MORPHLING_TARGET:RemoveSelf()
    end
  end
  MORPH_TRASH_CAN={}
  MORPHLING_START_TIME=nil
  MORPHLING_ENT=nil
  MORPH_HERO_LIST={"npc_dota_hero_abaddon",
                    "npc_dota_hero_abyssal_underlord",
                    "npc_dota_hero_alchemist",
                    "npc_dota_hero_ancient_apparition",
                    "npc_dota_hero_antimage",
                    "npc_dota_hero_arc_warden",
                    "npc_dota_hero_axe",
                    "npc_dota_hero_bane",
                    "npc_dota_hero_batrider",
                    --[["npc_dota_hero_beastmaster",--]]
                    "npc_dota_hero_bloodseeker",
                    "npc_dota_hero_bounty_hunter",
                    "npc_dota_hero_brewmaster",
                    "npc_dota_hero_bristleback",
                    "npc_dota_hero_broodmother",
                    "npc_dota_hero_centaur",
                    "npc_dota_hero_chaos_knight",
                    "npc_dota_hero_chen",
                    "npc_dota_hero_clinkz",
                    "npc_dota_hero_crystal_maiden",
                    "npc_dota_hero_dark_seer",
                    "npc_dota_hero_dark_willow",
                    "npc_dota_hero_dazzle",
                    "npc_dota_hero_death_prophet",
                    "npc_dota_hero_disruptor",
                    "npc_dota_hero_doom_bringer",
                    "npc_dota_hero_dragon_knight",
                    "npc_dota_hero_drow_ranger",
                    "npc_dota_hero_earth_spirit",
                    "npc_dota_hero_earthshaker",
                    "npc_dota_hero_elder_titan",
                    "npc_dota_hero_ember_spirit",
                    "npc_dota_hero_enchantress",
                    "npc_dota_hero_enigma",
                    "npc_dota_hero_faceless_void",
                    "npc_dota_hero_furion",
                    "npc_dota_hero_grimstroke",
                    "npc_dota_hero_gyrocopter",
                    "npc_dota_hero_huskar",
                    --[["npc_dota_hero_invoker",--]]
                    "npc_dota_hero_jakiro",
                    "npc_dota_hero_juggernaut",
                    "npc_dota_hero_keeper_of_the_light",
                    "npc_dota_hero_kunkka",
                    "npc_dota_hero_legion_commander",
                    "npc_dota_hero_leshrac",
                    "npc_dota_hero_lich",
                    "npc_dota_hero_life_stealer",
                    "npc_dota_hero_lina",
                    "npc_dota_hero_lion",
                    "npc_dota_hero_lone_druid",
                    "npc_dota_hero_luna",
                    "npc_dota_hero_lycan",
                    "npc_dota_hero_magnataur",
                    "npc_dota_hero_marci",
                    "npc_dota_hero_mars",
                    "npc_dota_hero_medusa",
                    "npc_dota_hero_meepo",
                    "npc_dota_hero_mirana",
                    "npc_dota_hero_monkey_king",
                    --[["npc_dota_hero_morphling",--]]
                    "npc_dota_hero_naga_siren",
                    "npc_dota_hero_necrolyte",
                    "npc_dota_hero_nevermore",
                    "npc_dota_hero_night_stalker",
                    "npc_dota_hero_nyx_assassin",
                    "npc_dota_hero_obsidian_destroyer",
                    "npc_dota_hero_ogre_magi",
                    "npc_dota_hero_omniknight",
                    "npc_dota_hero_oracle",
                    "npc_dota_hero_pangolier",
                    "npc_dota_hero_phantom_assassin",
                    "npc_dota_hero_phantom_lancer",
                    "npc_dota_hero_phoenix",
                    "npc_dota_hero_primal_beast",
                    "npc_dota_hero_puck",
                    "npc_dota_hero_pudge",
                    "npc_dota_hero_pugna",
                    "npc_dota_hero_queenofpain",
                    "npc_dota_hero_rattletrap",
                    "npc_dota_hero_razor",
                    "npc_dota_hero_riki",
                    "npc_dota_hero_rubick",
                    "npc_dota_hero_sand_king",
                    "npc_dota_hero_shadow_demon",
                    "npc_dota_hero_shadow_shaman",
                    "npc_dota_hero_shredder",
                    "npc_dota_hero_silencer",
                    "npc_dota_hero_skeleton_king",
                    "npc_dota_hero_skywrath_mage",
                    "npc_dota_hero_slardar",
                    "npc_dota_hero_slark",
                    "npc_dota_hero_snapfire",
                    "npc_dota_hero_sniper",
                    "npc_dota_hero_spectre",
                    "npc_dota_hero_spirit_breaker",
                    "npc_dota_hero_storm_spirit",
                    "npc_dota_hero_sven",
                    "npc_dota_hero_techies",
                    "npc_dota_hero_templar_assassin",
                    "npc_dota_hero_terrorblade",
                    "npc_dota_hero_tidehunter",
                    "npc_dota_hero_tinker",
                    "npc_dota_hero_tiny",
                    "npc_dota_hero_treant",
                    "npc_dota_hero_troll_warlord",
                    "npc_dota_hero_tusk",
                    "npc_dota_hero_undying",
                    "npc_dota_hero_ursa",
                    "npc_dota_hero_vengefulspirit",
                    "npc_dota_hero_venomancer",
                    "npc_dota_hero_viper",
                    "npc_dota_hero_visage",
                    "npc_dota_hero_void_spirit",
                    "npc_dota_hero_warlock",
                    "npc_dota_hero_weaver",
                    "npc_dota_hero_windrunner",
                    "npc_dota_hero_winter_wyvern",
                    "npc_dota_hero_wisp",
                    "npc_dota_hero_witch_doctor",
                    "npc_dota_hero_zuus",
                    "npc_dota_hero_hoodwink",
                    "npc_dota_hero_dawnbreaker",}
  MORPH_WAIT_FOR={}
  MORPH_INDEX_COUNTER=1
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  hero=replaceHero(hero,"npc_dota_hero_morphling")
  MORPHLING_ENT=hero
  
  local bloodstone=CreateItem("item_sheepstick",hero,hero)
  hero:AddItem(bloodstone)

  local bloodstone=CreateItem("item_sheepstick",hero,hero)
  hero:AddItem(bloodstone)

  local bloodstone=CreateItem("item_sheepstick",hero,hero)
  hero:AddItem(bloodstone)

  local bloodstone=CreateItem("item_sheepstick",hero,hero)
  hero:AddItem(bloodstone)

  local bloodstone=CreateItem("item_sheepstick",hero,hero)
  hero:AddItem(bloodstone)

  local bloodstone=CreateItem("item_sheepstick",hero,hero)
  hero:AddItem(bloodstone)
  MORPHLING_TARGET=nil
  hero:SetAbsOrigin(TRAINING_PLACE)
  --[[for i=1,6 do
    hero:HeroLevelUp(true)
  end--]]
  local replicate=MORPHLING_ENT:FindAbilityByName('morphling_replicate')
  replicate:SetLevel(1)
  Timers:CreateTimer("morph_start_delay", {
    useGameTime=true,
    endTime=4,
    callback=function()
      print('morph training starts')
      morphHeroIteration()
      MORPHLING_START_TIME=Time()
      return nil
    end
  })
  
  --[[test_hero = CreateUnitByName("npc_dota_hero_axe", hero:GetAbsOrigin()+Vector(0,100,0), true, nil, nil, DOTA_TEAM_BADGUYS)
  test_hero:SetIdleAcquire(false)
  for i=1,29 do
    test_hero:HeroLevelUp(false)
  end--]]

end

function morph_training_end( eventSourceIndex, args )
  MORPH_TRAINING=0
  Timers:RemoveTimer("morph_start_delay")
  if MORPHLING_TARGET then
    if not MORPHLING_TARGET:IsNull() then
      MORPHLING_TARGET:RemoveSelf()
    end
  end
  --local trash=Entities:FindByName("")
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end


function armlet_training_start( eventSourceIndex, args )
  ArmletTratiningState=1
  ArmletAttackerName=args['unitName']
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  ARMLET_DAMAGE_BONUS=0
  active_hero=replaceHero(hero,"npc_dota_hero_life_stealer")
  active_hero:SetMoveCapability(1)
  active_hero:SetAttackCapability(0)
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  active_hero:SetDayTimeVisionRange(4000)
  removeItems(active_hero)
  local item = CreateItem("item_armlet",active_hero,active_hero)
  active_hero:AddItem(item)
  local aegis = CreateItem("item_aegis",active_hero,active_hero)
  active_hero:AddItem(aegis)
  local position=randomCirclePosition(500,active_hero)

  ARMLET_FAKE_MOD=0
  ArmletAttacker = CreateUnitByName(ArmletAttackerName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
  ArmletAttacker:SetBaseHealthRegen(0)
  if ArmletAttacker:GetUnitName()=="npc_dota_hero_invoker" then
    ArmletAttacker:RemoveAbility("invoker_quas")
  end
  if ArmletAttackerName=="npc_dota_goodguys_tower1_mid" or ArmletAttackerName=="npc_dota_goodguys_tower2_mid" then
    ArmletAttacker:SetAbsOrigin(position)
  end
  local boots = CreateItem("item_travel_boots",ArmletAttacker,ArmletAttacker)
  ArmletAttacker:AddItem(boots)
  ArmletAttacker:AddNewModifier(ArmletAttacker, nil, "modifier_razor_static_link_buff", {})
  ArmletAttacker:AddAbility("huskar_berserkers_blood")
  local abilka=ArmletAttacker:FindAbilityByName("huskar_berserkers_blood")
  abilka:SetLevel(4)
  ArmletAttacker:SetBaseHealthRegen(-(ArmletAttacker:GetHealthRegen()))
  ArmletAttacker:SetContextThink(DoUniqueString("attack_hero"),
    function()
      --print("ga casted:",Time())
      ArmletAttacker:MoveToTargetToAttack(active_hero)
    end,
  0)
  Timers:CreateTimer("armlet_fakemod_thinker", {
    useGameTime=true,
    endTime=math.random(100,200)/100,
    callback=function()
      if ARMLET_FAKE_MOD==1 then
        --print("perfoming fake")
        ArmletAttacker:Stop()
        -- unit:SetContextThink(DoUniqueString("fake_attack_hero"),
        --   function()
        --     local position=unit:GetAbsOrigin()
        --     unit:MoveToPosition(position+Vector(50,50,0))
        --     unit:MoveToTargetToAttack(active_hero)
        --   end,
        -- 0)
      end
      return math.random(100,200)/100
    end
  })
  CustomGameEventManager:Send_ServerToAllClients("armlet_training_start",{attacker=ArmletAttacker:entindex()})
  --CustomGameEventManager:Send_ServerToAllClients("armlet_training_started",{castpoint=0.1, timebar=TimebarState, id=420, bartime=5.5})
end

function armlet_training_end( eventSourceIndex, args )
  ArmletTratiningState=0
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
  --[[local trash=Entities:FindAllByName(ArmletAttackerName)
  for k,v in pairs(trash) do
    v:RemoveSelf()
  end--]]
  ArmletAttacker:RemoveSelf()
  Timers:RemoveTimer("armlet_fakemod_thinker")
end

function armlet_mod_attacker( eventSourceIndex, args )
  print(args['target'],args['type'],args['value'])
  ArmletAttacker=EntIndexToHScript(args['target'])
  if args['type']=="fm" then
    if ARMLET_FAKE_MOD==1 then
      ARMLET_FAKE_MOD=0
    else
      ARMLET_FAKE_MOD=1
    end
  end
  if args['type']=="as" then
    changeAttackSpeed(args['value'],ArmletAttacker)
  end
  if args['type']=="ad" then
    changeAttackDamage(args['value'],ArmletAttacker)
  end
  --CustomGameEventManager:Send_ServerToAllClients("armlet_update_stats",{attacker=ArmletAttacker:entindex()})
end

function changeAttackSpeed(asPoints,unit)
  local oldHealth=unit:GetHealth()

  local maxHealth=unit:GetMaxHealth()
  local affHealth=maxHealth/100*90
  local changeHealth=affHealth/340*asPoints
  print(oldHealth+changeHealth)
  unit:ModifyHealth(oldHealth-changeHealth,nil,false,0)
end

function changeAttackDamage(asPoints,unit)
  --local oldDmg=GetModifierStackCount("modifier_razor_static_link_buff", unit)
  ARMLET_DAMAGE_BONUS=ARMLET_DAMAGE_BONUS+asPoints
  unit:SetModifierStackCount("modifier_razor_static_link_buff", unit, ARMLET_DAMAGE_BONUS)
end


function glimpse_training_start_v2( eventSourceIndex, args )
  glimpse_v2_training_state=1
  glimpse_waypoints={Vector(-2422.0070800781,-6116.193359375,256),
                    Vector(-1245.2333984375,-5999.974609375,384),
                    Vector(-523.8134765625,-4384.990234375,384),
                    Vector(-1919.7176513672,-3609.423828125,256),
                    Vector(-1273.9571533203,-2425.5952148438,256),
                    Vector(35.000591278076,-1060.0407714844,256),
                    Vector(1147.3959960938,-1847.8355712891,256),
                    Vector(691.61309814453,-2819.6413574219,384),
                    Vector(723.65277099609,-4053.6479492188,384),
                    Vector(1570.8024902344,-4984.0229492188,384),
                    Vector(2667.7573242188,-5132.1625976563,384),
                    Vector(3861.2648925781,-5158.1889648438,384),
                    Vector(5179.169921875,-4856.3383789063,384),
                    Vector(5271.4018554688,-3861.2421875,384),
                    Vector(5396.7553710938,-2860.8701171875,384),
                    Vector(5129.8325195313,-2041.44921875,384),
                    Vector(4077.0581054688,-1604.6007080078,384),
                    Vector(3281.0180664063,-888.32843017578,256),
                    Vector(3281.0180664063,-888.32843017578,256),
                    Vector(4346.693359375,22.2731590271,384),
                    Vector(5282.4716796875,672.21722412109,384),
                    Vector(4417.5463867188,1227.9084472656,384),
                    Vector(3652.0944824219,1581.8403320313,256),
                    Vector(3527.0017089844,2614.1696777344,256),
                    Vector(2845.4792480469,3421.9670410156,256),
                    Vector(2314.8090820313,4295.359375,256),
                    Vector(2039.2075195313,5222.751953125,256),
                    Vector(948.45263671875,5136.0849609375,384),
                    Vector(452.47994995117,4112.833984375,384),
                    Vector(609.46936035156,3086.9895019531,384),
                    Vector(414.80996704102,2117.0197753906,384),
                    Vector(-301.26800537109,1506.2410888672,256.02474975586),
                    Vector(-1959.6530761719,2545.1110839844,128),
                    Vector(-2821.8513183594,2927.8200683594,128),
                    Vector(-2426.0090332031,4094.8806152344,256),
                    Vector(-1476.6145019531,4158.3193359375,256),
                    Vector(-1373.2416992188,4893.0297851563,384),
                    Vector(-2400.1525878906,5208.2377929688,384),
                    Vector(-3428.3908691406,5190.1240234375,384),
                    Vector(-4283.6787109375,4876.1513671875,384),
                    Vector(-5196.1884765625,4631.7353515625,384),
                    Vector(-5734.626953125,4176.001953125,384),
                    Vector(-5719.9614257813,3208.0983886719,384),
                    Vector(-5268.61328125,2390.7734375,384),
                    Vector(-4544.7924804688,1842.5246582031,384),
                    Vector(-5277.8725585938,1178.6042480469,384),
                    Vector(-5357.44140625,354.87521362305,374.92572021484),
                    Vector(-4431.1108398438,510.9345703125,256),
                    Vector(-3980.4260253906,-658.8173828125,381.55383300781),
                    Vector(-5021.8823242188,-1252.4880371094,384),
                    Vector(-4139.744140625,-1509.6024169922,384),
                    Vector(-3342.08984375,-1498.1889648438,384),
                    Vector(-2660.8186035156,-2102.166015625,256),
                    Vector(-2015.6926269531,-2976.1520996094,256),
                    Vector(-2560.7744140625,-3872,256),
                    Vector(-2918.8156738281,-5037.1137695313,256)}

  GLIMPSE_POS_COUNTER=1
  glimpse_level=args['level']
  burrow_range={350,450,550,650}
  burrow_speed=2000
  chain_speed={1600,2000,2400,2800}
  chain_range={850,1050,1250,1450}

  glimpse_type={"item_manta",
                "phantom_lancer_doppelwalk",
                "naga_siren_mirror_image",
                "ember_spirit_sleight_of_fist",
                "chaos_knight_phantasm",
                "sandking_burrowstrike",
                "shredder_timber_chain"
                }
  glimpse_hero={"npc_dota_hero_antimage",
                "npc_dota_hero_phantom_lancer",
                "npc_dota_hero_naga_siren",
                "npc_dota_hero_ember_spirit",
                "npc_dota_hero_chaos_knight",
                "npc_dota_hero_sand_king",
                "npc_dota_hero_shredder"
                }
  glimpse_castpoint={0,
                    0.1,
                    0.65,
                    0,
                    0.4,
                    0,
                    0.3}
  glimpse_duration={0.1,
                    1,
                    0.3,
                    0.2,
                    0.5,
                    0.175,
                    0}


  local skill_id=args['skillId']
  local TimebarState=args['timebar']                
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  active_hero=replaceHero(active_hero,glimpse_hero[skill_id])
  removeItems(active_hero)
  active_hero:SetAbsOrigin(glimpse_waypoints[GLIMPSE_POS_COUNTER])
  
  if skill_id==1 then
    local item = CreateItem("item_manta",active_hero,active_hero)
    active_hero:AddItem(item)    
  else
    local spell=active_hero:FindAbilityByName(glimpse_type[skill_id])
    if skill_id==6 or skill_id==7 then
      spell:SetLevel(glimpse_level)
    else
      spell:SetLevel(1)
    end
    
  end
  local boots = CreateItem("item_travel_boots",active_hero,active_hero)
  active_hero:AddItem(boots) 
  active_hero:SetAttackCapability(1)
  active_hero:SetMoveCapability(1)
  hero_pos_table = {}
  refreshItems2(active_hero)
  TRY_TO_DODGE=nil
  GLIMPSE_TP_MODE=args['tpMode']
  GLIMPLSE_SKILL=glimpse_type[skill_id]
  DISRUPTOR_KILLED=0
  PIZDUK_ALIVE=0
  PIZDUK2_ALIVE=0
  GLIMPSE_SAFETIME=glimpse_castpoint[skill_id]+glimpse_duration[skill_id]/2
  GLIMPSE_MINTIME=glimpse_castpoint[skill_id]+0.4
  CustomGameEventManager:Send_ServerToAllClients("glimpse_training_started",{timebar=TimebarState,castpoint=glimpse_castpoint[skill_id],duration=glimpse_duration[skill_id]})
  GLIMPSE_POS_COUNTER=GLIMPSE_POS_COUNTER+1
  createFlask(active_hero,glimpse_waypoints[GLIMPSE_POS_COUNTER])
  Timers:CreateTimer(5,function()
      glimpseHero(active_hero)
      
      if glimpse_v2_training_state==1 then
        return 5
      else
        return nil
      end
    end
  )

end

function glimpse_training_start( eventSourceIndex, args )
  glimpse_training_state=1
  glimpse_waypoints={Vector(-2422.0070800781,-6116.193359375,256),
                    Vector(-1245.2333984375,-5999.974609375,384),
                    Vector(-523.8134765625,-4384.990234375,384),
                    Vector(-1919.7176513672,-3609.423828125,256),
                    Vector(-1273.9571533203,-2425.5952148438,256),
                    Vector(35.000591278076,-1060.0407714844,256),
                    Vector(1147.3959960938,-1847.8355712891,256),
                    Vector(691.61309814453,-2819.6413574219,384),
                    Vector(723.65277099609,-4053.6479492188,384),
                    Vector(1570.8024902344,-4984.0229492188,384),
                    Vector(2667.7573242188,-5132.1625976563,384),
                    Vector(3861.2648925781,-5158.1889648438,384),
                    Vector(5179.169921875,-4856.3383789063,384),
                    Vector(5271.4018554688,-3861.2421875,384),
                    Vector(5396.7553710938,-2860.8701171875,384),
                    Vector(5129.8325195313,-2041.44921875,384),
                    Vector(4077.0581054688,-1604.6007080078,384),
                    Vector(3281.0180664063,-888.32843017578,256),
                    Vector(3281.0180664063,-888.32843017578,256),
                    Vector(4346.693359375,22.2731590271,384),
                    Vector(5282.4716796875,672.21722412109,384),
                    Vector(4417.5463867188,1227.9084472656,384),
                    Vector(3652.0944824219,1581.8403320313,256),
                    Vector(3527.0017089844,2614.1696777344,256),
                    Vector(2845.4792480469,3421.9670410156,256),
                    Vector(2314.8090820313,4295.359375,256),
                    Vector(2039.2075195313,5222.751953125,256),
                    Vector(948.45263671875,5136.0849609375,384),
                    Vector(452.47994995117,4112.833984375,384),
                    Vector(609.46936035156,3086.9895019531,384),
                    Vector(414.80996704102,2117.0197753906,384),
                    Vector(-301.26800537109,1506.2410888672,256.02474975586),
                    Vector(-1959.6530761719,2545.1110839844,128),
                    Vector(-2821.8513183594,2927.8200683594,128),
                    Vector(-2426.0090332031,4094.8806152344,256),
                    Vector(-1476.6145019531,4158.3193359375,256),
                    Vector(-1373.2416992188,4893.0297851563,384),
                    Vector(-2400.1525878906,5208.2377929688,384),
                    Vector(-3428.3908691406,5190.1240234375,384),
                    Vector(-4283.6787109375,4876.1513671875,384),
                    Vector(-5196.1884765625,4631.7353515625,384),
                    Vector(-5734.626953125,4176.001953125,384),
                    Vector(-5719.9614257813,3208.0983886719,384),
                    Vector(-5268.61328125,2390.7734375,384),
                    Vector(-4544.7924804688,1842.5246582031,384),
                    Vector(-5277.8725585938,1178.6042480469,384),
                    Vector(-5357.44140625,354.87521362305,374.92572021484),
                    Vector(-4431.1108398438,510.9345703125,256),
                    Vector(-3980.4260253906,-658.8173828125,381.55383300781),
                    Vector(-5021.8823242188,-1252.4880371094,384),
                    Vector(-4139.744140625,-1509.6024169922,384),
                    Vector(-3342.08984375,-1498.1889648438,384),
                    Vector(-2660.8186035156,-2102.166015625,256),
                    Vector(-2015.6926269531,-2976.1520996094,256),
                    Vector(-2560.7744140625,-3872,256),
                    Vector(-2918.8156738281,-5037.1137695313,256)}
  if GetMapName() == "dota" then
  
  end


  glimpse_level=args['level']
  burrow_range={350,450,550,650}
  burrow_speed=2000
  chain_speed={1600,2000,2400,2800}
  chain_range={850,1050,1250,1450}

  glimpse_type={"item_manta",
                "phantom_lancer_doppelwalk",
                "naga_siren_mirror_image",
                "ember_spirit_sleight_of_fist",
                "chaos_knight_phantasm",
                "sandking_burrowstrike",
                "shredder_timber_chain"
                }
  glimpse_hero={"npc_dota_hero_antimage",
                "npc_dota_hero_phantom_lancer",
                "npc_dota_hero_naga_siren",
                "npc_dota_hero_ember_spirit",
                "npc_dota_hero_chaos_knight",
                "npc_dota_hero_sand_king",
                "npc_dota_hero_shredder"
                }
  glimpse_castpoint={0,
                    0.1,
                    0.65,
                    0,
                    0.4,
                    0,
                    0.3}
  glimpse_duration={0.1,
                    1,
                    0.3,
                    0.2,
                    0.5,
                    0.175,
                    0}


  local skill_id=args['skillId']
  local TimebarState=args['timebar']                
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  active_hero=replaceHero(active_hero,glimpse_hero[skill_id])
  removeItems(active_hero)
  if GetMapName() == "dota" then
    active_hero:SetAbsOrigin(glimpse_waypoints[1])
  else
    active_hero:SetAbsOrigin(TRAINING_PLACE)
  end
  
  if skill_id==1 then
    local item = CreateItem("item_manta",active_hero,active_hero)
    active_hero:AddItem(item)    
  else
    local spell=active_hero:FindAbilityByName(glimpse_type[skill_id])
    if skill_id==6 or skill_id==7 then
      spell:SetLevel(glimpse_level)
    else
      spell:SetLevel(1)
    end
    
  end
  local boots = CreateItem("item_travel_boots",active_hero,active_hero)
  active_hero:AddItem(boots) 
  active_hero:SetAttackCapability(1)
  active_hero:SetBaseAgility(1000)
  active_hero:SetMoveCapability(1)
  active_hero:SetDayTimeVisionRange(4000)
  hero_pos_table = {}
  refreshItems2(active_hero)
  GLIMPSE_TP_MODE=args['tpMode']
  GLIMPLSE_SKILL=glimpse_type[skill_id]
  DISRUPTOR_KILLED=0
  PIZDUK_ALIVE=0
  PIZDUK2_ALIVE=0
  GLIMPSE_SAFETIME=glimpse_castpoint[skill_id]+glimpse_duration[skill_id]/2
  GLIMPSE_MINTIME=glimpse_castpoint[skill_id]+0.4
  CustomGameEventManager:Send_ServerToAllClients("glimpse_training_started",{timebar=TimebarState,castpoint=glimpse_castpoint[skill_id],duration=glimpse_duration[skill_id]})
  
  local backtrack_time=4.5
  local interval=0.05
  local max_index=backtrack_time/interval
  SAD_DISRUPTOR=nil
  if GLIMPSE_TP_MODE=="tpMode2" then
    CustomGameEventManager:Send_ServerToAllClients("travel_reminder",{})
    disruptor_position=randomDisruptorPosition(4000,active_hero)
    createSadDisruptor(disruptor_position,active_hero,1500)
    local distance = (disruptor_position - active_hero:GetAbsOrigin()):Length2D() 
    local direction = (disruptor_position - active_hero:GetAbsOrigin()):Normalized()
    local target_point = 0.92 * distance
    local target_point_vector = active_hero:GetAbsOrigin() + direction * target_point
    local target="npc_dota_creep_goodguys_melee"
    pizduk2=CreateUnitByName(target, target_point_vector, true, nil, nil, active_hero:GetTeam())
    pizduk2:SetMoveCapability(1)
    pizduk2:SetIdleAcquire(false)
    pizduk2:SetBaseHealthRegen(150)
    pizduk2:SetMaximumGoldBounty(0)
    pizduk2:SetMinimumGoldBounty(0)
    pizduk2:SetDeathXP(0)
    PIZDUK2_ALIVE=1
  else
    disruptor_position=randomDisruptorPosition(2000,active_hero)
    createSadDisruptor(disruptor_position,active_hero,1500)
  end

  
  --GLIMPSE POSITION THINKER

  Timers:CreateTimer("glimpse_position_thinker", {
    useGameTime=true,
    endTime=0,
    callback=function()
      table.insert(hero_pos_table,1,active_hero:GetAbsOrigin())
      if #hero_pos_table>=max_index then
        table.remove(hero_pos_table,#hero_pos_table)
      end
      -- local color=Vector(255,0,0)
      -- local ztest=true
      -- for i, v in ipairs(hero_pos_table) do 
      -- DebugDrawCircle(v, color, 20, 20, ztest, interval)

      -- end
      return FrameTime()
    end
  })

end

function glimpse_training_end( eventSourceIndex, args )
  glimpse_v2_training_state=0
--[[  if not SAD_DISRUPTOR:IsNull() then
    SAD_DISRUPTOR:RemoveSelf()
  end--]]
  if GLIMPLSE_SKILL=="ember_spirit_sleight_of_fist" and PIZDUK_ALIVE==1 then
    if not pizduk:IsNull() then
      pizduk:RemoveSelf()
    end
  end
  if PIZDUK2_ALIVE==1 then
    pizduk2:RemoveSelf()
  end
  --[[Timers:RemoveTimer("glimpse_position_thinker")--]]
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end


function GameMode:cmdStartGlimpse()
  
  CustomGameEventManager:Send_ServerToAllClients("glimpse_training_started",{castpoint=0.1})
  local cmdPlayer = Convars:GetCommandClient()
  active_hero = cmdPlayer:GetAssignedHero()
  disruptor_position=randomDisruptorPosition(2000,active_hero)
  print(disruptor_position)
  sadDisruptor=createSadDisruptor(disruptor_position,active_hero,1500)
  
  local item = CreateItem("item_manta",active_hero,active_hero)
  active_hero:AddItem(item)
  active_hero:SetAttackCapability(1)
  active_hero:SetBaseAgility(1000)
  hero_pos_table = {}
  --glimpsePositionThinker(active_hero)

end

function createSadDisruptor(position,hero,castRange)
  SadDisruptor = CreateUnitByNameAsync("npc_dota_hero_disruptor", position, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
    --unit:AddAbility(abilityName)
    CustomGameEventManager:Send_ServerToAllClients("ping_on_minimap",{respawn_place=position})
    if GLIMPLSE_SKILL=="ember_spirit_sleight_of_fist" then
      unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
    end
    unit:SetBaseHealthRegen(0)
    unit:SetBaseStrength(0)
    unit:SetMaxHealth(1)
    unit:SetBaseMaxHealth(1)
    unit:SetMoveCapability(0)
    unit:SetMaximumGoldBounty(0)
    unit:SetMinimumGoldBounty(0)
    unit:SetDeathXP(0)
    unit:SetForwardVector((hero:GetOrigin() - position):Normalized())
    unit:SetIdleAcquire(false)
    local ability = unit:FindAbilityByName("disruptor_glimpse")
    ability:SetLevel(4)
    --------------making ga
    unit:AddAbility("omniknight_guardian_angel")
    local guardian=unit:FindAbilityByName("omniknight_guardian_angel")
    guardian:SetLevel(1)
    guardian:SetOverrideCastPoint(0)
    unit:SetContextThink(DoUniqueString("cast_ability"),
        function()
          --print("ga casted:",Time())
          unit:CastAbilityNoTarget(guardian, -1)
        end,
      0)

    local backtrack_time=4.5
    local interval=0.05
    local max_index=backtrack_time/interval
    local ability_casted=0

    Timers:CreateTimer(function()
      if hero:IsNull() or unit:IsNull() then
        print('someone is null')
        return nil

      else
        if hero_pos_table[#hero_pos_table] then
          local lenght=(hero:GetAbsOrigin()-position):Length()
          local lenght2=(active_hero:GetAbsOrigin()-hero_pos_table[#hero_pos_table]):Length()
          local calc_time=lenght2/600
          if lenght2/600>1.8 then
            calc_time=1.8
          end
          if lenght<=castRange and calc_time>GLIMPSE_MINTIME then
            if ability:IsCooldownReady() then

              if hero:IsOutOfGame() then
                print('hero out of game')
                return interval*3
              else
                if not ability:IsInAbilityPhase() then
                  print('trying to glimpse:',Time())
                  unit:SetContextThink(DoUniqueString("cast_ability"),
                  function()
                    print('dis casting:',Time())
                    unit:CastAbilityOnTarget(hero,ability,-1)
                    
                    unit:SetIdleAcquire(false)
                  end,
                  0)
                  return interval*3
                end
              end
            else
              print('ability is on cooldown')
              return nil
            end 
          else
            --print('calc time too big')
            return interval
          end
        else
          return interval
        end
      end
      
    end)
    return unit
  end)

end
--idk why is it here

function aim_training_start_3( eventSourceIndex, args )
  print('aim training new started')
  CustomGameEventManager:Send_ServerToAllClients("reaction_start",{type='aim3'})

  local aim_retry=args['retry']
  if aim_retry==1 then
    print("RETRY")
    aimClear()
  end

  REACTION_TRAINING=1
  REACTION_NORMAL=1
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  AIM_MAX_COMBO=1
  AIM_AVG_TIME=0
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  if aim_retry==0 then
    active_hero=replaceHero(active_hero,"npc_dota_hero_pangolier")
  end

  hero = active_hero
  if aim_retry==0 then
    removeItems(hero)
  end
  hero:SetMoveCapability(0)
  hero:SetAttackCapability(0)
  hero:SetDayTimeVisionRange(1200)
  hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  hero:SetBaseHealthRegen(10)
  if aim_retry==0 then
    local topor = CreateItem("item_topor",hero,hero)
    hero:AddItem(topor)
    local topor2 = CreateItem("item_topor2",hero,hero)
    hero:AddItem(topor2)
    local topor3 = CreateItem("item_quelling_blade",hero,hero)
    hero:AddItem(topor3)
    local gem = CreateItem("item_gem",hero,hero)
    hero:AddItem(gem) 
    getConfigAndApply(hero,'aim3')
  end
  
  WARD_TIMER=60
  AIM_TRASH={}
  --[[ action_logging:StartLogging() ]]
  Timers:CreateTimer("time_display", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        CustomGameEventManager:Send_ServerToAllClients("reaction_timer",{time=WARD_TIMER})
        WARD_TIMER=WARD_TIMER-1
        if WARD_TIMER==-1 then
          local log_result_id=generateRandomString(10)
          local steam=PlayerResource:GetSteamID(player:GetPlayerID())
          local other={combo=AIM_MAX_COMBO,avg=math.floor(AIM_AVG_TIME*1000)/1000}
          local ping=ping_reader:GetPing()
          print(steam,AIM_SCORE)
          setItemConfig(hero,'aim3')

          sendResult_v2('aim3',tostring(steam),AIM_SCORE,other,log_result_id,ping)
          --[[ action_logging:SetID(log_result_id)
          action_logging:SetSteam(tostring(steam))
          action_logging:SetMode('aim3')
          action_logging:StopLogging()
          action_logging:SaveLog() ]]
          print("wards_destroyed:", #RESULTS_TABLE)
          Timers:RemoveTimer("tree_cycle")
          return nil
        else
          if WARD_TIMER==2 then
            hero:EmitSound("drums")
          end
          return 1
        end
      else
        return nil
      end
    end
  })
  local start_interval=2
  local wards_count=0
  Timers:CreateTimer("ward_cycle", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        if start_interval>0.4 then
          start_interval=start_interval-0.08
        end
        local obs_or_sentry=RollPercentage(50)
        local ward
        if obs_or_sentry then
          ward=CreateUnitByName("npc_dota_observer_wards", randomSquarePositionAim(750,350,750,650,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
        else
          ward=CreateUnitByName("npc_dota_sentry_wards", randomSquarePositionAim(750,350,750,650,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
          ward:SetRenderColor(0, 89, 255)
        end
        ward:SetDeathXP(0)
        ward:SetMaxHealth(200)
        ward:SetHealth(200)
        table.insert(AIM_TRASH,ward)
        wards_count=wards_count+1
        if wards_count==107 then
          return nil
        else
          return start_interval
        end
      else
        return nil
      end
    end
  })
  Timers:CreateTimer("tree_cycle", {
    useGameTime=true,
    endTime=7,
    callback=function()
      if REACTION_TRAINING==1 then
        local interval=RandomInt(5,8)
          createTreeInRandomRadius(TRAINING_PLACE,200,10)

        return interval
      else
        return nil
      end
    end
  })
  print('starting tree timer')
  
  -- local hex=hero:FindAbilityByName("lion_voodoo")  
  -- hex:SetLevel(4)
  -- bara1=chargingBara(hero,'1',0)
  -- bara2=chargingBara(hero,'2',4)
  
  local minVec=hero:GetAbsOrigin()-Vector(750,350,0)
  local maxVec=hero:GetAbsOrigin()+Vector(750,650,0)
  AIM_BOX=CreateParticleBox(minVec, maxVec, "particles/custom/range_display_line_red.vpcf", player)
end

function aim_training_start_2( eventSourceIndex, args )
  print('aim training new started')
  CustomGameEventManager:Send_ServerToAllClients("reaction_start",{type='aim2'})

  local aim_retry=args['retry']
  if aim_retry==1 then
    print("RETRY")
    aimClear()
  end
  REACTION_TRAINING=1
  REACTION_NORMAL=1
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  AIM_MAX_COMBO=1
  AIM_AVG_TIME=0
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  if aim_retry==0 then
    active_hero=replaceHero(active_hero,"npc_dota_hero_pangolier")
  end

  hero = active_hero
  if aim_retry==0 then
    removeItems(hero)
  end
  hero:SetMoveCapability(0)
  hero:SetAttackCapability(0)
  hero:SetDayTimeVisionRange(1200)
  hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  hero:SetBaseHealthRegen(10)
  if aim_retry==0 then
    local topor = CreateItem("item_topor",hero,hero)
    hero:AddItem(topor)
    local topor2 = CreateItem("item_topor2",hero,hero)
    hero:AddItem(topor2)
    local gem = CreateItem("item_gem",hero,hero)
    hero:AddItem(gem) 
    getConfigAndApply(hero,'aim2')
  end

  WARD_TIMER=60
  AIM_TRASH={}
  --[[ action_logging:StartLogging() ]]
  Timers:CreateTimer("time_display", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        CustomGameEventManager:Send_ServerToAllClients("reaction_timer",{time=WARD_TIMER})
        WARD_TIMER=WARD_TIMER-1
        if WARD_TIMER==-1 then
          local log_result_id=generateRandomString(10)
          local steam=PlayerResource:GetSteamID(player:GetPlayerID())
          local other={combo=AIM_MAX_COMBO,avg=math.floor(AIM_AVG_TIME*1000)/1000}
          local ping=ping_reader:GetPing()
          print(steam,AIM_SCORE)
          setItemConfig(hero,'aim2')
          sendResult_v2('aim2',tostring(steam),AIM_SCORE,other,log_result_id,ping)
          --[[ action_logging:SetID(log_result_id)
          action_logging:SetSteam(tostring(steam))
          action_logging:SetMode('aim2')
          action_logging:StopLogging()
          action_logging:SaveLog() ]]
          print("wards_destroyed:", #RESULTS_TABLE)
          return nil
        else
          if WARD_TIMER==2 then
            hero:EmitSound("drums")
          end
          return 1
        end
      else
        return nil
      end
    end
  })
  local start_interval=2
  local wards_count=0
  Timers:CreateTimer("ward_cycle", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        if start_interval>0.4 then
          start_interval=start_interval-0.08
        end
        local obs_or_sentry=RollPercentage(50)
        local ward
        if obs_or_sentry then
          ward=CreateUnitByName("npc_dota_observer_wards", randomSquarePositionAim(750,350,750,650,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
        else
          ward=CreateUnitByName("npc_dota_sentry_wards", randomSquarePositionAim(750,350,750,650,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
          ward:SetRenderColor(0, 89, 255)
        end
        ward:SetDeathXP(0)
        ward:SetMaxHealth(200)
        ward:SetHealth(200)
        table.insert(AIM_TRASH,ward)
        wards_count=wards_count+1
        if wards_count==107 then
          return nil
        else
          return start_interval
        end
      else
        return nil
      end
    end
  })
  print('starting tree timer')
  
  -- local hex=hero:FindAbilityByName("lion_voodoo")  
  -- hex:SetLevel(4)
  -- bara1=chargingBara(hero,'1',0)
  -- bara2=chargingBara(hero,'2',4)
  
  local minVec=hero:GetAbsOrigin()-Vector(750,350,0)
  local maxVec=hero:GetAbsOrigin()+Vector(750,650,0)
  AIM_BOX=CreateParticleBox(minVec, maxVec, "particles/custom/range_display_line_red.vpcf", player)
end



function aim_training_start( eventSourceIndex, args )
  CustomGameEventManager:Send_ServerToAllClients("reaction_start",{type='aim'})

  local aim_retry=args['retry']
  if aim_retry==1 then
    print("RETRY")
    aimClear()
  end
  REACTION_TRAINING=1
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  AIM_MAX_COMBO=1
  AIM_AVG_TIME=0
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  if aim_retry==0 then
    active_hero=replaceHero(active_hero,"npc_dota_hero_pangolier")
  end

  hero = active_hero
  if aim_retry==0 then
    removeItems(hero)
  end
  hero:SetMoveCapability(0)
  hero:SetAttackCapability(0)
  hero:SetDayTimeVisionRange(1200)
  hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  hero:SetBaseHealthRegen(10)
  if aim_retry==0 then
    local topor = CreateItem("item_topor",hero,hero)
    hero:AddItem(topor)
    local gem = CreateItem("item_gem",hero,hero)
    hero:AddItem(gem) 
    getConfigAndApply(hero,'aim')
  end

  WARD_TIMER=60
  AIM_TRASH={}
  --[[ action_logging:StartLogging() ]]
  Timers:CreateTimer("time_display", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        CustomGameEventManager:Send_ServerToAllClients("reaction_timer",{time=WARD_TIMER})
        WARD_TIMER=WARD_TIMER-1
        if WARD_TIMER==-1 then

          local steam=PlayerResource:GetSteamID(player:GetPlayerID())
          local other={combo=AIM_MAX_COMBO,avg=math.floor(AIM_AVG_TIME*1000)/1000}
          print(steam,AIM_SCORE)
          setItemConfig(hero,'aim')
          local log_result_id=generateRandomString(10)
          local ping=ping_reader:GetPing()
          print('log_id=',log_result_id)
          sendResult_v2('aim',tostring(steam),AIM_SCORE,other,log_result_id,ping)
          --[[ action_logging:SetID(log_result_id)
          action_logging:SetSteam(tostring(steam))
          action_logging:SetMode('aim')
          action_logging:StopLogging()
          action_logging:SaveLog() ]]
          --local log=action_logging:GetLog()
          --print('log:',log)
          print("wards_destroyed:", #RESULTS_TABLE)
          return nil
        else
          if WARD_TIMER==2 then
            hero:EmitSound("drums")
          end
          return 1
        end
      else
        return nil
      end
    end
  })
  local start_interval=2
  local wards_count=0
  Timers:CreateTimer("ward_cycle", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        if start_interval>0.4 then
          start_interval=start_interval-0.08
        end
        local ward=CreateUnitByName("npc_dota_observer_wards", randomSquarePositionAim(750,350,750,650,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
        ward:SetDeathXP(0)
        ward:SetMaxHealth(200)
        ward:SetHealth(200)
        table.insert(AIM_TRASH,ward)
        wards_count=wards_count+1
        if wards_count==107 then
          return nil
        else
          return start_interval
        end
      else
        return nil
      end
    end
  })
  --[[Timers:CreateTimer("surprise_tree_cycle", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if REACTION_TRAINING==1 then
        --local interval=RandomInt(4,10)
        local tree_pos=randomRingPosition(100,120,hero)
        createGGTree(tree_pos,10)

        local interval=3
        return interval
      else
        return nil
      end
    end
  })--]]
  -- local hex=hero:FindAbilityByName("lion_voodoo")  
  -- hex:SetLevel(4)
  -- bara1=chargingBara(hero,'1',0)
  -- bara2=chargingBara(hero,'2',4)
  
  local minVec=hero:GetAbsOrigin()-Vector(750,350,0)
  local maxVec=hero:GetAbsOrigin()+Vector(750,650,0)
  AIM_BOX=CreateParticleBox(minVec, maxVec, "particles/custom/range_display_line_red.vpcf", player)
end

function map_aim_training_end( eventSourceIndex, args )
  MAP_AIM_TRAINING=0
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  for k,v in pairs(AIM_TRASH) do
    if not v:IsNull() then
      v:RemoveSelf()
    end
  end
  Timers:RemoveTimer("ward_cycle")
  Timers:RemoveTimer("time_display")
  Timers:RemoveTimer("tree_cycle")
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function map_aim_training_start( eventSourceIndex, args )
  CustomGameEventManager:Send_ServerToAllClients("reaction_start",{type='map_aim'})

  local aim_retry=args['retry']
  if aim_retry==1 then
    print("RETRY")
    --aimClear()
  end
  MAP_AIM_TRAINING=1
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  AIM_MAX_COMBO=1
  AIM_AVG_TIME=0

  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  if aim_retry==0 then
    active_hero=replaceHero(active_hero,"npc_dota_hero_pangolier")

  end
  
  
  



  hero = active_hero
  if aim_retry==0 then
    removeItems(hero)
  
    for i=0,6 do
      local ability=hero:GetAbilityByIndex(i)
      print(ability:GetAbilityName())
      hero:RemoveAbility(ability:GetAbilityName())
    end
    local sunstrike=hero:AddAbility("invoker_sun_strike")
    sunstrike:SetLevel(1)
    sunstrike:SetOverrideCastPoint(0)
    sunstrike:SetAbilityIndex(0)
    sunstrike:SetHidden(false)
    hero:SetMoveCapability(0)
    hero:SetAttackCapability(0)
    hero:SetDayTimeVisionRange(600)
    if GetMapName() == "dota" then
      hero:SetAbsOrigin(Vector(-553.37341308594,-387.48187255859,128))
    else
      hero:SetAbsOrigin(Vector(0,0,128))
    end
    
  end

  WARD_TIMER=60
  AIM_TRASH={}
  --[[ action_logging:StartLogging() ]]
  Timers:CreateTimer("time_display", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if MAP_AIM_TRAINING==1 then
        CustomGameEventManager:Send_ServerToAllClients("reaction_timer",{time=WARD_TIMER})
        WARD_TIMER=WARD_TIMER-1
        if WARD_TIMER==-1 then
          local log_result_id=generateRandomString(10)
          local steam=PlayerResource:GetSteamID(player:GetPlayerID())
          local other={combo=AIM_MAX_COMBO,avg=math.floor(AIM_AVG_TIME*1000)/1000}
          local ping=ping_reader:GetPing()
          print(steam,AIM_SCORE)
          sendResult_v2('map_aim',tostring(steam),AIM_SCORE,other,log_result_id,ping)
          --[[ action_logging:SetID(log_result_id)
          action_logging:SetSteam(tostring(steam))
          action_logging:SetMode('map_aim')
          action_logging:StopLogging()
          action_logging:SaveLog() ]]
          print("wards_destroyed:", #RESULTS_TABLE)
          MAP_AIM_TRAINING=0
          return nil
        else
          return 1
        end
      else
        return nil
      end
    end
  })
  local start_interval=2.5
  local wards_count=0
  Timers:CreateTimer("creep_cycle", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if MAP_AIM_TRAINING==1 then
        if start_interval>1.14 then
          start_interval=start_interval-0.08
        end
        local ward=CreateUnitByName("npc_dota_creep_badguys_melee", randomSquarePositionAim(6000,6000,6000,6000,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
        ward:AddNewModifier(ward, nil, "modifier_pugna_decrepify", {})
        ward:SetAttackCapability(0)
        table.insert(AIM_TRASH,ward)
        wards_count=wards_count+1
        if wards_count==40 then
          return nil
        else
          return start_interval
        end
        --return start_interval
      else
        return nil
      end
    end
  })

  -- local hex=hero:FindAbilityByName("lion_voodoo")  
  -- hex:SetLevel(4)
  -- bara1=chargingBara(hero,'1',0)
  -- bara2=chargingBara(hero,'2',4)
  
  
end

------MOVING AIM START
function moving_aim_training_end( eventSourceIndex, args )
  MOVING_AIM_TRAINING=0
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  for k,v in pairs(AIM_TRASH) do
    if not v:IsNull() then
      v:RemoveSelf()
    end
  end
  Timers:RemoveTimer("ward_cycle")
  Timers:RemoveTimer("time_display")
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function moving_aim_training_start( eventSourceIndex, args )
  CustomGameEventManager:Send_ServerToAllClients("reaction_start",{type='move_aim'})

  local aim_retry=args['retry']
  if aim_retry==1 then
    print("RETRY")
    MOVING_AIM_TRAINING=0
    RESULTS_TABLE={}
    WARD_POOL={}
    AIM_SCORE=0
    AIM_COMBO=1
    for k,v in pairs(AIM_TRASH) do
      if not v:IsNull() then
        v:RemoveSelf()
      end
    end
    Timers:RemoveTimer("ward_cycle")
    Timers:RemoveTimer("time_display")
    for k,v in pairs(AIM_BOX) do
      ParticleManager:DestroyParticle(v, true)
      ParticleManager:ReleaseParticleIndex(v)
    end
  end
  MOVING_AIM_TRAINING=1
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  AIM_MAX_COMBO=1
  AIM_AVG_TIME=0
  MA_MAX_MS=1500
  MA_MIN_MS=600
  MA_SCALE_START=1
  MA_SCALE_END=0.4
  MA_SCALE=1
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  if aim_retry==0 then
    active_hero=replaceHero(active_hero,"npc_dota_hero_pangolier")
  end

  hero = active_hero
  if aim_retry==0 then
    removeItems(hero)
  end
  hero:SetMoveCapability(0)
  hero:SetAttackCapability(0)
  hero:SetDayTimeVisionRange(1200)
  hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  hero:SetBaseHealthRegen(10)
  if aim_retry==0 then
    local topor = CreateItem("item_topor",hero,hero)
    hero:AddItem(topor)
    local gem = CreateItem("item_gem",hero,hero)
    hero:AddItem(gem) 
    getConfigAndApply(hero,'move_aim')
  end
  

  WARD_TIMER=60
  AIM_TRASH={}
  local kek=0
  local KENT_MS=MA_MIN_MS
  --[[ action_logging:StartLogging() ]]
  Timers:CreateTimer("time_display", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if MOVING_AIM_TRAINING==1 then
        CustomGameEventManager:Send_ServerToAllClients("reaction_timer",{time=WARD_TIMER})
        WARD_TIMER=WARD_TIMER-1
        if WARD_TIMER==-1 then
          local log_result_id=generateRandomString(10)
          local steam=PlayerResource:GetSteamID(player:GetPlayerID())
          local other={combo=AIM_MAX_COMBO,avg=math.floor(AIM_AVG_TIME*1000)/1000}
          print(steam,AIM_SCORE)
          local ping=ping_reader:GetPing()
          setItemConfig(hero,'move_aim')
          sendResult_v2('move_aim',tostring(steam),AIM_SCORE,other,log_result_id,ping)
          --[[ action_logging:SetID(log_result_id)
          action_logging:SetSteam(tostring(steam))
          action_logging:SetMode('move_aim')
          action_logging:StopLogging()
          action_logging:SaveLog() ]]
          print("wards_destroyed:",kek)
          MOVING_AIM_TRAINING=0
          return nil
        else
          if WARD_TIMER==2 then
            hero:EmitSound("drums")
          end
          if MA_SCALE>0.5 then
            MA_SCALE=MA_SCALE-0.015
          end
          return 1
        end
      else
        return nil
      end
    end
  })
  local start_interval=2
  local wards_count=0
  Timers:CreateTimer("ward_cycle", {
    useGameTime=true,
    endTime=4,
    callback=function()
      if MOVING_AIM_TRAINING==1 then
        if start_interval>1.5 then
          start_interval=start_interval-0.08
        end
        kek=kek+1
        local ward=CreateUnitByName("npc_dota_neutral_centaur_khan", randomSquarePositionAim(750,350,750,650,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
        --ward:AddNewModifier(ward, nil, "modifier_pugna_decrepify", {})
        ward:SetModelScale(MA_SCALE)
        ward:SetDeathXP(0)
        ward:SetMoveCapability(1)
        ward:SetAttackCapability(0)
        KENT_MS=RandomInt(MA_MIN_MS,MA_MAX_MS)
        

        if MA_MAX_MS<1800 then
          MA_MAX_MS=MA_MAX_MS+100
        end
        table.insert(AIM_TRASH,ward)
        wards_count=wards_count+1
        --ward:AddNewModifier(ward, nil, "modifier_bloodseeker_thirst_speed", {})
        ward:AddNewModifier(ward, nil, "modifier_item_force_boots", {})
        ward:SetBaseMoveSpeed(KENT_MS)
        local ward_waypoints={}
        for i=1,10 do
          ward_waypoints[i]=randomSquarePositionAim(750,350,750,650,hero)
        end
        for i=1,10 do
          --[[DebugDrawCircle(ward_waypoints[i], Vector(0,0,255), 20, 20, true, 10)
          DebugDrawText(ward_waypoints[i], 'waypoint '..tostring(i), true, 20)--]]
          ExecuteOrderFromTable({
            UnitIndex = ward:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = ward_waypoints[i],
            Queue = i-1
          })
        end
        if wards_count==40 then
          return nil
        else
          return start_interval
        end
      else
        return nil
      end
    end
  })
  local minVec=hero:GetAbsOrigin()-Vector(750,350,0)
  local maxVec=hero:GetAbsOrigin()+Vector(750,650,0)
  AIM_BOX=CreateParticleBox(minVec, maxVec, "particles/custom/range_display_line_red.vpcf", player)
  -- local hex=hero:FindAbilityByName("lion_voodoo")  
  -- hex:SetLevel(4)
  -- bara1=chargingBara(hero,'1',0)
  -- bara2=chargingBara(hero,'2',4)
  
  
end





---MOVING AIM END
function manta_challenge_start( eventSourceIndex, args )
  CustomGameEventManager:Send_ServerToAllClients("manta_challenge_start",{})
  MANTA_CHALLENGE=1
  MANTA_CUSTOM_COOLDOWN=3
  MANTA_END_INTERVAL=1
  MANTA_DAMAGE_TIME=0
  MANTA_CAST_TIME=0
  MANTA_LIVES=4200
  MANTA_FAIL_DECREMENT=200
  MANTA_HEALT_DRAIN=1
  MANTA_GOOD_INCREMENT=100
  MANTA_COMBO=1
  MANTA_SCORE=0
  MANTA_SCORE_GROW=1
  MANTA_SCORE_NOW=0
  
  local player=PlayerResource:GetPlayer(args.PlayerID)
  active_hero = player:GetAssignedHero()
  removeItems(active_hero)
  active_hero=replaceHero(active_hero,"npc_dota_hero_antimage")

  hero = active_hero
  removeItems(hero)
  hero:SetMoveCapability(0)
  hero:SetAttackCapability(0)
  hero:SetBaseStrength(200)
  hero:SetBaseHealthRegen(0)
  hero:SetBaseManaRegen(100)
  hero:SetDayTimeVisionRange(400)
  hero:AddNewModifier(hero, nil, "modifier_phased", {})
  --hero:SetDayTimeVisionRange(1200)
  hero:SetAbsOrigin(TRAINING_PLACE)
  local manta = CreateItem("item_manta",hero,hero)
  hero:AddItem(manta)
  local dummy=CreateUnitByName("npc_dummy_unit", TRAINING_PLACE, true, nil, nil, DOTA_TEAM_GOODGUYS)
  dummy:SetMaxHealth(10000)
  dummy:SetHealth(10000)
  dummy:AddNewModifier(dummy, nil, "modifier_phased", {})
  dummy:AddNewModifier(unit, nil, "modifier_no_health_bar", {})
  dummy:SetBaseHealthRegen(200)
  dummy:SetAttackCapability(0)
  MANTA_ENEMY_TABLE={{"npc_dota_hero_axe","axe_berserkers_call",0.4,"notarget",300},
                    {"npc_dota_hero_invoker","invoker_emp",2.95,"pos",675},
                    {"npc_dota_hero_magnataur","magnataur_reverse_polarity",0.3,"notarget",290},
                    {"npc_dota_hero_centaur","centaur_hoof_stomp",0.5,"notarget",315},
                    {"npc_dota_hero_slardar","slardar_slithereen_crush",0.35,"notarget",350}}
  local totalSchedule=generateSkillSchedule(MANTA_ENEMY_TABLE)
  personalSchedule={}
  --for i=1,5 do
    --local schedule={}
    --local elaplsedTime=0
    --local castpoint=MANTA_ENEMY_TABLE[i][3]
    --for k,v in pairs(totalSchedule) do
      --elaplsedTime=elaplsedTime+v[2]
      --if v[1]==i then
        --table.insert(schedule,elaplsedTime-castpoint)
        --elaplsedTime=0
      --end
      --if k==table.getn(totalSchedule) then
        --personalSchedule[MANTA_ENEMY_TABLE[i][1]]=schedule
      --end
    --end
  --end
  for i=1,5 do
    personalSchedule[MANTA_ENEMY_TABLE[i][1]]={}
  end
  local totalTime=0
  for k,v in pairs(totalSchedule) do
    totalTime=totalTime+v[2]
    local castpoint=MANTA_ENEMY_TABLE[v[1]][3]
    local unitname=MANTA_ENEMY_TABLE[v[1]][1]
    if #personalSchedule[unitname]==0 then
      table.insert(personalSchedule[unitname],totalTime-castpoint)
    else
      local lastSum=0
      for i=1,#personalSchedule[unitname] do
        lastSum=lastSum+personalSchedule[unitname][i]
      end
      table.insert(personalSchedule[unitname],totalTime-castpoint-lastSum)
    end
    

  end

  print('PERSONAL SCHEDULE')
  print('N','axe','inv','mag','cent','slardar')
  for k,v in pairs(personalSchedule["npc_dota_hero_invoker"]) do
    print(k,personalSchedule["npc_dota_hero_axe"][k],v,personalSchedule["npc_dota_hero_magnataur"][k],personalSchedule["npc_dota_hero_centaur"][k],personalSchedule["npc_dota_hero_slardar"][k])
  end


  
  
  Timers:CreateTimer({
    endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()

      --[[for i=1,1 do
        if MANTA_ENEMY_TABLE[i][4]=="notarget" then
          notargetMantaEnemyAI(hero,MANTA_ENEMY_TABLE[i][1],MANTA_ENEMY_TABLE[i][2],MANTA_ENEMY_TABLE[i][5],800)
        end
        if MANTA_ENEMY_TABLE[i][4]=="pos" then
          positionMantaEnemyAI(hero,MANTA_ENEMY_TABLE[i][1],MANTA_ENEMY_TABLE[i][2],MANTA_ENEMY_TABLE[i][5],800)
        end
      end--]]
      local k=1
      Timers:CreateTimer(function() --COOLDOWN CONTROLLER
          --moving dummy to hero:
          local color5=Vector(0,0,0)
          local ztest=true

          dummy:SetAbsOrigin(hero:GetAbsOrigin())
          DebugDrawCircle(dummy:GetAbsOrigin(), color5, 20, 20, ztest, 2)
          MANTA_CUSTOM_COOLDOWN=totalSchedule[k][2]-0.4
          print('setting cooldown to:',MANTA_CUSTOM_COOLDOWN)
          print('k=',k)
          k=k+1
          if k==#totalSchedule then
            return nil
          else
            return totalSchedule[k][2]
          end
        end
      )
      Timers:CreateTimer(function() --HP CONTROLLER

          MANTA_LIVES=MANTA_LIVES-MANTA_HEALT_DRAIN*(math.modf(MANTA_SCORE_NOW/10)+1)
          hero:SetHealth(MANTA_LIVES)


          if MANTA_LIVES<=0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='You died!',icon='axe_berserkers_call'})
            return nil
          else
            return FrameTime()
          end
        end
      )
      MANTA_DAMAGE_TIME=Time()
      MANTA_CAST_TIME=Time()
      notargetMantaEnemyAI(hero,MANTA_ENEMY_TABLE[1][1],MANTA_ENEMY_TABLE[1][2],MANTA_ENEMY_TABLE[1][5],900)
      positionMantaEnemyAI(hero,MANTA_ENEMY_TABLE[2][1],MANTA_ENEMY_TABLE[2][2],MANTA_ENEMY_TABLE[2][5],900)
      notargetMantaEnemyAI(hero,MANTA_ENEMY_TABLE[3][1],MANTA_ENEMY_TABLE[3][2],MANTA_ENEMY_TABLE[3][5],900)
      notargetMantaEnemyAI(hero,MANTA_ENEMY_TABLE[4][1],MANTA_ENEMY_TABLE[4][2],MANTA_ENEMY_TABLE[4][5],900)
      notargetMantaEnemyAI(hero,MANTA_ENEMY_TABLE[5][1],MANTA_ENEMY_TABLE[5][2],MANTA_ENEMY_TABLE[5][5],900)

    end
  })
  
--[[  for i=1,5 do
    local respawn_place=randomCirclePositionVector(800,Vector(0,0,128))
    mantaEnemies[i]=CreateUnitByName(MANTA_ENEMY_TABLE[i][1], respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)
    local unit=mantaEnemies[i]
    unit:SetAttackCapability(0)
    local ability
    if MANTA_ENEMY_TABLE[i][2]=="invoker_emp" then
      local ability_name = "invoker_emp"
      local invoke_name="invoker_invoke"
      local wex_name="invoker_wex"
      local invoke = unit:FindAbilityByName(invoke_name)
      invoke:SetLevel(1)
      local wex=unit:FindAbilityByName(wex_name)
      wex:SetLevel(3)
      unit:CastAbilityNoTarget(wex,-1)
      unit:CastAbilityNoTarget(wex,-1)
      unit:CastAbilityNoTarget(wex,-1)
      unit:CastAbilityNoTarget(invoke,-1)
      ability=unit:FindAbilityByName("invoker_emp")
    else
      ability = unit:FindAbilityByName(MANTA_ENEMY_TABLE[i][2])
      ability:SetLevel(1)
    end
    local blink_dagger=CreateItem("item_blink",unit,unit)
    unit:AddItem(blink_dagger)
    unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
    local k=1--]]
    --[[Timers:CreateTimer("mantaCastSchedule_"..i, {
      useGameTime = true,
      endTime = personalSchedule[i][k],
      callback = function()
      --setting up vars
      local first_blink_casted=0
      local skill_casted=0
      local second_blink_casted=0
      local blinkDir=(hero:GetOrigin() - respawn_place):Normalized()
      local lenght=hero:GetAbsOrigin()-respawn_place
      local distanceToHero=lenght:Length()
      --casting blink->skill->blink
        Timers:CreateTimer(0, function()
            if first_blink_casted==0 then
              local radius
              if MANTA_ENEMY_TABLE[i][4]=='notarget' then
                radius=RandomInt(60,MANTA_ENEMY_TABLE[i][5]-60)
              else
                radius=RandomInt(300,600)
              end
              local blinkPoint=respawn_place+(blinkDir*(distanceToHero-radius))

              unit:CastAbilityOnPosition(blinkPoint,blink_dagger,-1)
            end
            if blink_dagger:IsCooldownReady()==false and ability:IsCooldownReady()==true then
              first_blink_casted=1
            end
            if first_blink_casted==1 and skill_casted==0 and ability:IsInAbilityPhase()==false then
              if MANTA_ENEMY_TABLE[i][4]=='notarget' then
                unit:CastAbilityNoTarget(ability,-1)
              else
                unit:CastAbilityOnPosition(randomCirclePosition(RandomInt(20,MANTA_ENEMY_TABLE[i][5]),hero),ability,-1)
              end
            end
            if first_blink_casted==1 and ability:IsCooldownReady()==false then

              skill_casted=1
            end
            if first_blink_casted==1 and skill_casted==1 and second_blink_casted==0 then
              print('trying to blink out')

              local lenght=hero:GetAbsOrigin()-unit:GetAbsOrigin()
              local distanceToHero=lenght:Length()
              local forwardDistance=800-distanceToHero
              local blinkDir=(hero:GetOrigin() - unit:GetAbsOrigin()):Normalized()
              local blinkOutPoint=unit:GetAbsOrigin()+(blinkDir*forwardDistance)
              unit:CastAbilityOnPosition(blinkOutPoint,blink_dagger,-1)
            end
            if first_blink_casted==1 and skill_casted==1 and blink_dagger:IsCooldownReady()==false then
              second_blink_casted=1
            end
            if first_blink_casted==1 and skill_casted==1 and second_blink_casted==1 then
              return nil
            else
              return FrameTime()
            end
          end
        )


        k=k+1
        if k>table.getn(personalSchedule[i]) then
          return nil
        else
          return personalSchedule[i][k]
        end
      end
    })
  end--]]
  
  



  
  --[[dummy:SetBaseMaxHealth(1)--]]

end

function SendResult(Mode,steam,Score,other)

  
  if CHEAT_MODE~=1 then
    local req = CreateHTTPRequestScriptVM("POST",CMB_SERVER)
    req:SetHTTPRequestGetOrPostParameter("key",SECURE_KEY)
    req:SetHTTPRequestGetOrPostParameter("request",'sentResult')
    req:SetHTTPRequestGetOrPostParameter("Mode",Mode)
    CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes="mode:"..Mode})
    req:SetHTTPRequestGetOrPostParameter("steam",tostring(steam))
    CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes="steam:"..steam})
    req:SetHTTPRequestGetOrPostParameter("Score",tostring(Score))
    CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes="Score:"..Score})
    
    if other~=nil then
      local json='{'
      for k,v in pairs(other) do
        json=json..'"'..k..'":'..'"'..v..'",'
      end
      json=string.sub(json,1,string.len(json)-1)
      json=json..'}'
      req:SetHTTPRequestGetOrPostParameter("other",json)
      CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes="json:"..json})
    end
    req:Send(
        function(result)
            local res_table={}
            print(result['Body'])
            string.gsub(result['Body'],"{(.-)}",function(c) table.insert(res_table,c) end)
            for k,v in pairs(res_table) do
              print(k,v)
              CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes=k..":"..v})
            end
            if res_table[1]=="highscore" then
              CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=1,mod=Mode,score=res_table[2],place=res_table[3],total=res_table[4]})
            else
              CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=0,mod=Mode,score=res_table[2]})
            end
        end
    )
  else
    CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes="cheats detected"})
  end
end
function aimClear()
  REACTION_TRAINING=0
  RESULTS_TABLE={}
  WARD_POOL={}
  AIM_SCORE=0
  AIM_COMBO=1
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  if AIM_BOX~=nil then
    for k,v in pairs(AIM_BOX) do
      ParticleManager:DestroyParticle(v, true)
      ParticleManager:ReleaseParticleIndex(v)
    end
  end
  for k,v in pairs(AIM_TRASH) do
    if not v:IsNull() then
      v:RemoveSelf()
    end
  end
  Timers:RemoveTimer("ward_cycle")
  Timers:RemoveTimer("time_display")
end
function aim_training_end( eventSourceIndex, args )
  aimClear()
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function invoker_randomize_spheres( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  local spheres={"quas","wex","exort"}
  for k,sphere in pairs(spheres) do
    local spell_name="invoker_"..sphere
    local spell=hero:FindAbilityByName(spell_name)
    local lvl
    if sphere=="quas" then
      if INV_PROCAST_TYPE==3 or INV_PROCAST_TYPE==4 then
        lvl=RandomInt(3, 7)
      else
        if INV_PROCAST_TYPE==5 then
          lvl=RandomInt(4, 7)
        else
          lvl=RandomInt(1, 7)
        end
      end
    else
      lvl=RandomInt(1, 7)
    end

    
    spell:SetLevel(lvl)
    if sphere=="quas" then
      CustomGameEventManager:Send_ServerToAllClients("invoker_quas_tracker",{quas=lvl+INV_AGSH})
    end
  end
  hero=replaceHero(hero,"npc_dota_hero_invoker")
  hero:SetBaseIntellect(300)
  hero:SetAttackCapability(0)
end

function invoker_change_abil_lvl( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  local spell_name="invoker_"..args['sphere']
  local spell=hero:FindAbilityByName(spell_name)
  local lvl=spell:GetLevel()
  if args['plus']==1 then
    if lvl<7 then
      spell:SetLevel(lvl+1)
      CustomGameEventManager:Send_ServerToAllClients("invoker_quas_tracker",{quas=lvl+1+INV_AGSH})
    end
  else
    if lvl>1 then
      if lvl==3 then
        if INV_PROCAST_TYPE==3 or INV_PROCAST_TYPE==4 then
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Minimal quas lvl is 3.',icon='invoker_quas'})
        else
          spell:SetLevel(lvl-1)
          hero=replaceHero(hero,"npc_dota_hero_invoker")
          hero:SetBaseIntellect(300)
          hero:SetAttackCapability(0)
          CustomGameEventManager:Send_ServerToAllClients("invoker_quas_tracker",{quas=lvl-1+INV_AGSH})
        end
      else
        if lvl==4 and INV_PROCAST_TYPE==5 then
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Minimal quas lvl is 4.',icon='invoker_quas'})
        else
          spell:SetLevel(lvl-1)
          hero=replaceHero(hero,"npc_dota_hero_invoker")
          hero:SetBaseIntellect(300)
          hero:SetAttackCapability(0)
          CustomGameEventManager:Send_ServerToAllClients("invoker_quas_tracker",{quas=lvl-1+INV_AGSH})
        end

      end
      
    end
  end
end

function invoker_invoke_training( eventSourceIndex, args )
  player=PlayerResource:GetPlayer(args.PlayerID)
  local active_hero = player:GetAssignedHero()
  hero=replaceHero(active_hero,"npc_dota_hero_invoker")
  hero:SetBaseIntellect(100)
  hero:SetAttackCapability(0)
  hero:SetAbsOrigin(TRAINING_PLACE)
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  INV_SPHERES={"quas","wex","exort"}
  for k,v in pairs(INV_SPHERES) do
    local ability=hero:FindAbilityByName("invoker_"..v)
    ability:SetLevel(1)
  end
  INV_SINGLE_TARGET=0
  INV_ONE_SPHERE=0
  INV_BASIC_MODE=args['basicMode']
  if INV_BASIC_MODE==1 then
    INV_SINGLE_TARGET=args['oneTarget']
    INV_ONE_SPHERE=args['oneSphere']
  end
  INV_CHALLENGE=0
  if INV_BASIC_MODE==0 then 
    INV_CHALLENGE=args['challenge']
  end



  local hero_pos=hero:GetAbsOrigin()
  local a=700
  local h=(a*math.sqrt(3))/2
  inv_pos1=Vector(hero_pos.x-(a/2),hero_pos.y-(h/3),hero_pos.z)
  inv_pos2=Vector(hero_pos.x,hero_pos.y+(2*h/3),hero_pos.z)
  inv_pos3=Vector(hero_pos.x+a/2,hero_pos.y-(h/3),hero_pos.z)
  if INV_SINGLE_TARGET==0 then
    inv_earth=CreateUnitByName("npc_dota_hero_earth_spirit", inv_pos1, true, nil, nil, DOTA_TEAM_BADGUYS)
    inv_earth:SetIdleAcquire(false)
    inv_earth:SetBaseStrength(200)
    inv_earth:SetBaseHealthRegen(200)
    inv_fire=CreateUnitByName("npc_dota_hero_ember_spirit", inv_pos2, true, nil, nil, DOTA_TEAM_BADGUYS)
    inv_fire:SetIdleAcquire(false)
    inv_fire:SetBaseStrength(200)
    inv_fire:SetBaseHealthRegen(200)
  end
  inv_storm=CreateUnitByName("npc_dota_hero_storm_spirit", inv_pos3, true, nil, nil, DOTA_TEAM_BADGUYS)
  inv_storm:SetIdleAcquire(false)
  inv_storm:SetBaseStrength(200)
  inv_storm:SetBaseHealthRegen(200)
  inv_storm:SetBaseManaRegen(100)
  INV_SKILLS={{"invoker_cold_snap",{"invoker_quas","invoker_quas","invoker_quas"}},
              {"invoker_ghost_walk",{"invoker_quas","invoker_quas","invoker_wex"}},
              {"invoker_tornado",{"invoker_quas","invoker_wex","invoker_wex"}},
              {"invoker_emp",{"invoker_wex","invoker_wex","invoker_wex"}},
              {"invoker_alacrity",{"invoker_wex","invoker_wex","invoker_exort"}},
              {"invoker_chaos_meteor",{"invoker_exort","invoker_exort","invoker_wex"}},
              {"invoker_sun_strike",{"invoker_exort","invoker_exort","invoker_exort"}},
              {"invoker_forge_spirit",{"invoker_exort","invoker_exort","invoker_quas"}},
              {"invoker_ice_wall",{"invoker_quas","invoker_quas","invoker_exort"}},
              {"invoker_deafening_blast",{"invoker_exort","invoker_quas","invoker_wex"}}}
  INV_SPHERES={"invoker_quas",
              "invoker_wex",
              "invoker_exort"}
  INV_FILLER="invoker_filler"
  local skill_interval=2
  INV_SPHERES_BENCHMARK={}
  INV_SPHERES_COUNTER=0
  INV_SPHERE_CONTAINER={}
  INV_INVOKE_MODE=1
  INV_E_QUE={}
  INV_F_QUE={}
  INV_S_QUE={}
  if INV_BASIC_MODE==1 then
    invPUshSkill(nil)
  end
  CustomGameEventManager:Send_ServerToAllClients("invok_start",{single_mode=INV_SINGLE_TARGET})
  if INV_CHALLENGE==1 then
    for i=1,6 do
      invChallangeSKill()
    end
    
  end

end

function invoker_invoke_end( eventSourceIndex, args )
  INV_INVOKE_MODE=0
  if INV_SINGLE_TARGET==0 then
    inv_earth:RemoveSelf()
    inv_fire:RemoveSelf()
  end
  inv_storm:RemoveSelf()
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end


function invoker_scepter_toggle( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()


  local scepter=0
  for i=0,14 do
    local itemFind=hero:GetItemInSlot(i)
    --print(itemFind)
    if itemFind~=nil then
      if itemFind:GetName()=="item_ultimate_scepter" then
        hero:RemoveItem(itemFind)
        CustomGameEventManager:Send_ServerToAllClients("invoker_quas_tracker",{scepter=0})
        INV_AGSH=0
        scepter=1
      end
    end
  end
  if scepter==0 then
    local item = CreateItem("item_ultimate_scepter",hero,hero)
    hero:AddItem(item)
    CustomGameEventManager:Send_ServerToAllClients("invoker_quas_tracker",{scepter=1})
    INV_AGSH=1
  end
end

function invoker_talent_toggle( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  --special_bonus_unique_invoker_8
  --[[local talent=hero:FindAbilityByName("special_bonus_unique_invoker_8")
  
  if talent:GetLevel()==0 then
    talent:SetLevel(1)
    CustomGameEventManager:Send_ServerToAllClients("invok_talent_change",{talent=1})
  else
    talent:SetLevel(0)
    CustomGameEventManager:Send_ServerToAllClients("invok_talent_change",{talent=0})
  end--]]

  --invok_talent_change

end
function invoker_procast_start( eventSourceIndex, args )
  INVOKER_TRAINING=1
  INV_PROCAST_TYPE=args['procast']
  INV_CAST_POINT=0.05
  INV_TORNADO_DUR={0.8,1.1,1.4,1.7,2.0,2.3,2.6,2.9}
  INV_TORNADO_SPEED=1000
  INV_TORNADO_RADIUS=200
  INV_AGSH=0
  INV_TORNADO_CASTED=0
  INV_TORNADO_DONE=0
  INV_EMP_CASTED=0
  INV_EMP_DONE=0
  INV_EMP_DONE_TIME=0
  INV_TINY_MOVE=0
  INV_TINY_BLAST_ESCAPE=0
  INV_TINY_MEGA_FAST=0
  INV_BURN_COUNT=0
  INV_TOTAL_DAMAGE=0
  INV_METEOR_LANDED_TIME=0
  INV_EUL_DMG_TIME=0

--[[  INV_ALLOWED1={"invoker_emp","invoker_tornado"}
  INV_ALLOWED2={"invoker_sun_strike","invoker_chaos_meteor","invoker_deafening_blast"}
  INV_ALLOWED3={"invoker_tornado","invoker_chaos_meteor","invoker_deafening_blast"}
  INV_ALLOWED4={"invoker_tornado","invoker_emp","invoker_ice_wall"}
  INV_ALLOWED5={"invoker_tornado","invoker_emp","invoker_chaos_meteor","invoker_deafening_blast"}
  INV_ALLOWED6={"invoker_tornado","invoker_ice_wall","invoker_chaos_meteor","invoker_deafening_blast"}--]]

  local player=PlayerResource:GetPlayer(args.PlayerID)
  local active_hero = player:GetAssignedHero()
  removeItems(active_hero)
  hero=replaceHero(active_hero,"npc_dota_hero_invoker")
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 1500, true)
  removeItems(hero)
  hero:SetBaseIntellect(100)
  hero:SetAttackCapability(0)
  if args['procast']==3 or args['procast']==4 then
    local quas=hero:FindAbilityByName('invoker_quas')
    if quas:GetLevel()<3 then
      quas:SetLevel(3)
    end
  end
  if args['procast']==5 then
    local quas=hero:FindAbilityByName('invoker_quas')
    if quas:GetLevel()<4 then
      quas:SetLevel(4)
    end
  end
  TIMING_TARGET="npc_dota_hero_tiny"
  pizduk=CreateUnitByName(TIMING_TARGET, randomCirclePosition(200,hero), true, nil, nil, DOTA_TEAM_BADGUYS)
  for i=1,5 do
    local booster=CreateItem("item_soul_booster",pizduk,pizduk)
    pizduk:AddItem(booster)
  end
  pizduk:SetBaseStrength(0)
  Timers:CreateTimer({
    endTime = FrameTime(),
    callback = function()
      if not pizduk:IsNull() then
        local strength=pizduk:GetBaseStrength()
        local statusResist=strength*0.15
        CustomGameEventManager:Send_ServerToAllClients("str_tracker",{str=strength, sr=statusResist})
      end
    end
  })
  pizduk:SetBaseHealthRegen(100)
  pizduk:SetAttackCapability(0)
  pizduk:SetBaseManaRegen(50)
  --modifier_abaddon_borrowed_time
  
  for i=0,14 do
    local itemFind=hero:GetItemInSlot(i)
    --print(itemFind)
    if itemFind~=nil then
      hero:RemoveItem(itemFind)
    end
  end
  if INV_PROCAST_TYPE==2 then
    local eul=CreateItem("item_cyclone",hero,hero)
    hero:AddItem(eul)
  end

  CustomGameEventManager:Send_ServerToAllClients("invoker_training_start",{invoker=hero,procast=INV_PROCAST_TYPE})
end

function invoker_procast_end( eventSourceIndex, args )
  local trash=Entities:FindAllByName("npc_dota_hero_tiny")
  for k,v in pairs(trash) do
    v:RemoveSelf()
  end
  INVOKER_TRAINING=0
  CustomGameEventManager:Send_ServerToAllClients("invoker_procast_end_2",{})
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function invoker_procast_move_tiny( eventSourceIndex, args )
  if INV_TINY_MOVE==0 then
    INV_TINY_MOVE=1
    local center=randomCirclePosition(500,pizduk)
    local time=0
    local hero_coords=pizduk:GetAbsOrigin()
    local x=500
    local y=0
    local radius=500

    Timers:CreateTimer({
      useGameTime = false,
      endTime = 0, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      callback = function()

        x=radius*math.cos(time)
        y=radius*math.sin(time)
        if INV_TINY_MOVE==1 and INV_TINY_BLAST_ESCAPE==0 then
          pizduk:SetContextThink(DoUniqueString("cast_ability"),
          function()
            ExecuteOrderFromTable({
              UnitIndex = pizduk:entindex(),
              OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
              Position = Vector(x,y,0)
            })
          end,
          0) 
          time=time+0.2
        end
        if INV_TINY_MOVE==0 then
          return nil
        else
          return 0.2
        end  
      end
    })
  else
    pizduk:SetContextThink(DoUniqueString("cast_ability"),
    function()
      ExecuteOrderFromTable({
        UnitIndex = pizduk:entindex(),
        OrderType = DOTA_UNIT_ORDER_STOP
      })
    end,
    0) 
    INV_TINY_MOVE=0
  end
end

function invoker_procast_move_tiny_extremely_fast( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  if INV_TINY_MEGA_FAST==0 then
    INV_TINY_MEGA_FAST=1
    pizduk:SetBaseMoveSpeed(600)
  else
    INV_TINY_MEGA_FAST=0
    pizduk:SetBaseMoveSpeed(285)
  end
end

function sheep(hero)
  hero:AddNewModifier(unit, nil, "modifier_sheepstick_debuff", {})
  Timers:CreateTimer({
    useGameTime = false,
    endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      hero:RemoveModifierByName("modifier_sheepstick_debuff")
    end
  })
  --modifier_sheepstick_debuff RemoveModifierByName invoker_invoke_training

end

function skillshot_training( eventSourceIndex, args )
  SS_TRAINING=1
  SS_SF_CROSS=0
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
    --[[local passivka = hero:FindAbilityByName("datadriven_range_cd")
  passivka:SetLevel(1)
  hero:SetModifierStackCount("modifier_datadriven_range_cd", hero, 50)--]]
  SS_MINVEC=TRAINING_PLACE-Vector(300,300,128)
  SS_MAXVEC=TRAINING_PLACE+Vector(300,300,128)
  SS_PLACE=CreateParticleBox(SS_MINVEC, SS_MAXVEC, "particles/custom/range_display_line_red.vpcf", player)
  SS_SKILLS={"rattletrap_hookshot",--lvl
              "earth_spirit_boulder_smash",--
              "ember_spirit_searing_chains",--
              "invoker_sun_strike",--
              "meepo_earthbind",--lvl
              "mirana_arrow",--
              "nyx_assassin_impale",--
              "pudge_meat_hook",--lvl
              "puck_illusory_orb",--talent
              "phoenix_fire_spirits",--
              "nevermore_shadowraze",--
              "windrunner_powershot",
              "windrunner_shackleshot",
              "wisp_spirits",
              "ancient_apparition_ice_blast",
              "furion_sprout",
              "invoker_ice_wall",
              "leshrac_split_earth",
              "kunkka_torrent",
              "mars_spear",
              "earth_spirit_rolling_boulder"}--

  SS_HEROES={"npc_dota_hero_rattletrap",--id=1
              "npc_dota_hero_earth_spirit",--id=2
              "npc_dota_hero_ember_spirit",--id=3
              "npc_dota_hero_invoker",--id=4
              "npc_dota_hero_meepo",--id=5
              "npc_dota_hero_mirana",--id=6
              "npc_dota_hero_nyx_assassin",--id=7
              "npc_dota_hero_pudge",--id=8
              "npc_dota_hero_puck",--id=9
              "npc_dota_hero_phoenix",--id=10
              "npc_dota_hero_nevermore",--id=11
              "npc_dota_hero_windrunner",
              "npc_dota_hero_windrunner",
              "npc_dota_hero_wisp",
              "npc_dota_hero_ancient_apparition",
              "npc_dota_hero_furion",
              "npc_dota_hero_invoker",
              "npc_dota_hero_leshrac",
              "npc_dota_hero_kunkka",
              "npc_dota_hero_mars",
              "npc_dota_hero_earth_spirit"
            }
  SS_MAXRANGE=1500
  SS_MINRANGE=600
  SS_MAXSPEED=3000
  SS_MINSPEED=200
  SS_MAXRANGE_EVER=6000
  SS_MINRANGE_EVER=450
  SS_MAXSPEED_EVER=3000
  SS_MINSPEED_EVER=100
  SS_TREE_LEVEL=0
  SS_AGHS=0
  SS_LENS=0
  SS_SHACKLE_COUNT=0
  SS_CHAINS_COUNT=0
  CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='minRField',value='Lvl '..SS_TREE_LEVEL})
  CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='minRField',value=SS_MINRANGE})
  CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='maxRField',value=SS_MAXRANGE})
  CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='minMSField',value=SS_MINSPEED})
  CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='maxMSField',value=SS_MAXSPEED})
  SS_TARGETS={}
  SS_TARGET_MOVE_RADIUS={}
  SS_MOVE_DIR={}
  SS_MOVE_SPEED={}
  SS_SKILL_ID=args['skill_id']
  SS_MAX_UNITS=6
  hero=replaceHero(hero,SS_HEROES[SS_SKILL_ID])
  hero:SetAbsOrigin(TRAINING_PLACE)
  --[[hero:SetDayTimeVisionRange(SS_MAXRANGE+200)--]]
  hero:SetDayTimeVisionRange(8000)
  SS_ABILITIES={}
  if SS_SKILLS[SS_SKILL_ID]=="earth_spirit_boulder_smash" then
    local kick=hero:FindAbilityByName("earth_spirit_boulder_smash")
    local stone=hero:FindAbilityByName("earth_spirit_stone_caller")
    table.insert(SS_ABILITIES,kick)
    table.insert(SS_ABILITIES,stone)
  end
  if SS_SKILLS[SS_SKILL_ID]=="ember_spirit_searing_chains" then
    local chains=hero:FindAbilityByName("ember_spirit_searing_chains")
    local fist=hero:FindAbilityByName("ember_spirit_sleight_of_fist")
    table.insert(SS_ABILITIES,chains)
    table.insert(SS_ABILITIES,fist)
  end
  if SS_SKILLS[SS_SKILL_ID]=="invoker_sun_strike" then
    local exort=hero:FindAbilityByName("invoker_exort")
    table.insert(SS_ABILITIES,exort)
  end
  if SS_SKILLS[SS_SKILL_ID]=="invoker_ice_wall" then
    local exort=hero:FindAbilityByName("invoker_exort")
    local quas=hero:FindAbilityByName("invoker_quas")
    table.insert(SS_ABILITIES,exort)
    table.insert(SS_ABILITIES,quas)
  end
  if SS_SKILLS[SS_SKILL_ID]=="meepo_earthbind" then
    --[[local setka=hero:FindAbilityByName("meepo_earthbind")
    local clones=hero:FindAbilityByName("meepo_divided_we_stand")
    table.insert(SS_ABILITIES,setka)
    table.insert(SS_ABILITIES,clones)--]]
  end
  if SS_SKILLS[SS_SKILL_ID]=="pudge_meat_hook" then
    local hook=hero:FindAbilityByName("pudge_meat_hook")
--[[    local dismember=hero:FindAbilityByName("pudge_dismember")--]]
    table.insert(SS_ABILITIES,hook)
--[[    table.insert(SS_ABILITIES,dismember)--]]
  end
  if SS_SKILLS[SS_SKILL_ID]=="nevermore_shadowraze" then
    local coil1=hero:FindAbilityByName("nevermore_shadowraze1")
    local coil2=hero:FindAbilityByName("nevermore_shadowraze2")
    local coil3=hero:FindAbilityByName("nevermore_shadowraze3")
    table.insert(SS_ABILITIES,coil1)
    table.insert(SS_ABILITIES,coil2)
    table.insert(SS_ABILITIES,coil3)
  end
  if #SS_ABILITIES==0 then
    local ability=hero:FindAbilityByName(SS_SKILLS[SS_SKILL_ID])
    table.insert(SS_ABILITIES,ability)
  end
  
  for k,skill in pairs(SS_ABILITIES) do
    skill:SetLevel(1)
  end
  if SS_SKILLS[SS_SKILL_ID]=="rattletrap_hookshot" or SS_SKILLS[SS_SKILL_ID]=="pudge_meat_hook" then
    local ability=hero:FindAbilityByName(SS_SKILLS[SS_SKILL_ID])
    addLvlChanger(ability)
  end
  if SS_SKILLS[SS_SKILL_ID]=="meepo_earthbind" then
    local ability=hero:FindAbilityByName(SS_SKILLS[SS_SKILL_ID])
    addLvlChanger(ability)
    local ability2=hero:FindAbilityByName("meepo_divided_we_stand")
    ability2:SetLevel(2)
    ability2:SetLevel(3)
  end
  if SS_SKILLS[SS_SKILL_ID]=="ember_spirit_searing_chains" then
    local ability2=hero:FindAbilityByName("ember_spirit_sleight_of_fist")
    addLvlChanger(ability2)
  end
  SS_HERO=player:GetAssignedHero()
  CustomGameEventManager:Send_ServerToAllClients("skillshot_training_start",{hero_name=SS_HEROES[SS_SKILL_ID]})
  --[[hero:AddAbility("datadriven_range_cd")
  local pass=hero:FindAbilityByName("datadriven_range_cd")
  pass:SetLevel(1)
  hero:SetModifierStackCount("modifier_datadriven_range_cd", hero, 30)--]]
  ssAddUnitNew("npc_dota_hero_juggernaut",1000,600,nil)
end

function skillshot_training_v2( eventSourceIndex, args )
  CATCH_TRAINING=1

  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()


  SS_ENEMIES={"npc_dota_hero_nevermore",
  "npc_dota_hero_earthshaker",
  "npc_dota_hero_windrunner",
  "npc_dota_hero_tusk",
  "npc_dota_hero_meepo",
  "npc_dota_hero_riki"
}

  SS_SKILLS={"rattletrap_hookshot",--lvl
              "earth_spirit_boulder_smash",--
              "ember_spirit_searing_chains",--
              "invoker_sun_strike",--
              "meepo_earthbind",--lvl
              "mirana_arrow",--
              "nyx_assassin_impale",--
              "pudge_meat_hook",--lvl
              "puck_illusory_orb",--talent
              "phoenix_fire_spirits",--
              "nevermore_shadowraze",--
              "windrunner_powershot",
              "windrunner_shackleshot",
              "wisp_spirits",
              "ancient_apparition_ice_blast",
              "furion_sprout",
              "invoker_ice_wall",
              "leshrac_split_earth",
              "kunkka_torrent"}--

  SS_HEROES={"npc_dota_hero_rattletrap",--id=1
              "npc_dota_hero_earth_spirit",--id=2
              "npc_dota_hero_ember_spirit",--id=3
              "npc_dota_hero_invoker",--id=4
              "npc_dota_hero_meepo",--id=5
              "npc_dota_hero_mirana",--id=6
              "npc_dota_hero_nyx_assassin",--id=7
              "npc_dota_hero_pudge",--id=8
              "npc_dota_hero_puck",--id=9
              "npc_dota_hero_phoenix",--id=10
              "npc_dota_hero_nevermore",--id=11
              "npc_dota_hero_windrunner",
              "npc_dota_hero_windrunner",
              "npc_dota_hero_wisp",
              "npc_dota_hero_ancient_apparition",
              "npc_dota_hero_furion",
              "npc_dota_hero_invoker",
              "npc_dota_hero_leshrac",
              "npc_dota_hero_kunkka"
            }
  
--[[  if string.sub(ability_name,1,4)=='item' then
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
  end--]]

--SMOKETIME



  SS_TARGETS={}
  SS_TARGET_MOVE_RADIUS={}
  SS_MOVE_DIR={}
  SS_MOVE_SPEED={}
  SS_SKILL_ID=args['skill_id']
  SS_MAX_UNITS=6
  SS_PLAYER=nil
  hero=replaceHero(hero,SS_HEROES[SS_SKILL_ID])
  SS_PLAYER=hero
  hero:SetBaseManaRegen(100)
--[[  local item = CreateItem("item_ultimate_scepter", hero, hero)  
  hero:AddItem(item)--]]
  local travel = CreateItem("item_travel_boots", hero, hero)  
  hero:AddItem(travel)
  local blink = CreateItem("item_blink", hero, hero)  
  hero:AddItem(blink)
  refreshItems2(hero)
  if GetMapName()=='dota' then
    hero:SetAbsOrigin(Vector(732.22778320313,-4061.9580078125,384))
  else
    hero:SetAbsOrigin(TRAINING_PLACE)
  end
  
  --[[hero:SetDayTimeVisionRange(SS_MAXRANGE+200)--]]

  SS_ABILITIES={}
  if SS_SKILLS[SS_SKILL_ID]=="earth_spirit_boulder_smash" then
    local kick=hero:FindAbilityByName("earth_spirit_boulder_smash")
    local stone=hero:FindAbilityByName("earth_spirit_stone_caller")
    table.insert(SS_ABILITIES,kick)
    table.insert(SS_ABILITIES,stone)
  end
  if SS_SKILLS[SS_SKILL_ID]=="ember_spirit_searing_chains" then
    local chains=hero:FindAbilityByName("ember_spirit_searing_chains")
    local fist=hero:FindAbilityByName("ember_spirit_sleight_of_fist")
    table.insert(SS_ABILITIES,chains)
    table.insert(SS_ABILITIES,fist)
  end
  if SS_SKILLS[SS_SKILL_ID]=="invoker_sun_strike" then
    local exort=hero:FindAbilityByName("invoker_exort")
    table.insert(SS_ABILITIES,exort)
  end
  if SS_SKILLS[SS_SKILL_ID]=="invoker_ice_wall" then
    local exort=hero:FindAbilityByName("invoker_exort")
    local quas=hero:FindAbilityByName("invoker_quas")
    table.insert(SS_ABILITIES,exort)
    table.insert(SS_ABILITIES,quas)
  end
  if SS_SKILLS[SS_SKILL_ID]=="meepo_earthbind" then
    --[[local setka=hero:FindAbilityByName("meepo_earthbind")
    local clones=hero:FindAbilityByName("meepo_divided_we_stand")
    table.insert(SS_ABILITIES,setka)
    table.insert(SS_ABILITIES,clones)--]]
  end
  if SS_SKILLS[SS_SKILL_ID]=="pudge_meat_hook" then
    local hook=hero:FindAbilityByName("pudge_meat_hook")
--[[    local dismember=hero:FindAbilityByName("pudge_dismember")--]]
    table.insert(SS_ABILITIES,hook)
--[[    table.insert(SS_ABILITIES,dismember)--]]
  end
  if SS_SKILLS[SS_SKILL_ID]=="nevermore_shadowraze" then
    local coil1=hero:FindAbilityByName("nevermore_shadowraze1")
    local coil2=hero:FindAbilityByName("nevermore_shadowraze2")
    local coil3=hero:FindAbilityByName("nevermore_shadowraze3")
    table.insert(SS_ABILITIES,coil1)
    table.insert(SS_ABILITIES,coil2)
    table.insert(SS_ABILITIES,coil3)
  end
  if #SS_ABILITIES==0 then
    local ability=hero:FindAbilityByName(SS_SKILLS[SS_SKILL_ID])
    table.insert(SS_ABILITIES,ability)
  end
  
  for k,skill in pairs(SS_ABILITIES) do
    skill:SetLevel(1)
  end
  if SS_SKILLS[SS_SKILL_ID]=="rattletrap_hookshot" or SS_SKILLS[SS_SKILL_ID]=="pudge_meat_hook" then
    local ability=hero:FindAbilityByName(SS_SKILLS[SS_SKILL_ID])
    addLvlChanger(ability)
  end
  if SS_SKILLS[SS_SKILL_ID]=="meepo_earthbind" then
    local ability=hero:FindAbilityByName(SS_SKILLS[SS_SKILL_ID])
    addLvlChanger(ability)
    local ability2=hero:FindAbilityByName("meepo_divided_we_stand")
    ability2:SetLevel(2)
    ability2:SetLevel(3)
  end
  if SS_SKILLS[SS_SKILL_ID]=="ember_spirit_searing_chains" then
    local ability2=hero:FindAbilityByName("ember_spirit_sleight_of_fist")
    addLvlChanger(ability2)
  end
  SS_HERO=player:GetAssignedHero()
  CustomGameEventManager:Send_ServerToAllClients("skillshot_training_start_v2",{hero_name=SS_HEROES[SS_SKILL_ID]})
  
--3,4->1-4   1,2->4-7
  

  ss_beglec(SS_PLAYER)


end

function ss_scepter_toggle( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  local scepter=0
  for i=0,14 do
    local itemFind=hero:GetItemInSlot(i)
    --print(itemFind)
    if itemFind~=nil then
      if itemFind:GetName()=="item_ultimate_scepter" then
        hero:RemoveItem(itemFind)
        SS_AGHS=0
        scepter=1
      end
    end
  end
  if scepter==0 then
    local item = CreateItem("item_ultimate_scepter",hero,hero)
    hero:AddItem(item)
    SS_AGHS=1
  end
end

function ss_lense_toggle( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  local scepter=0
  for i=0,14 do
    local itemFind=hero:GetItemInSlot(i)
    --print(itemFind)
    if itemFind~=nil then
      if itemFind:GetName()=="item_aether_lens" then
        hero:RemoveItem(itemFind)
        SS_LENS=0
        scepter=1
      end
    end
  end
  if scepter==0 then
    local item = CreateItem("item_aether_lens",hero,hero)
    hero:AddItem(item)
    SS_LENS=1
  end
end

function ss_blink_toggle( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  local scepter=0
  for i=0,14 do
    local itemFind=hero:GetItemInSlot(i)
    --print(itemFind)
    if itemFind~=nil then
      if itemFind:GetName()=="item_blink" then
        hero:RemoveItem(itemFind)
        SS_LENS=0
        scepter=1
      end
    end
  end
  if scepter==0 then
    local item = CreateItem("item_blink",hero,hero)
    hero:AddItem(item)
    SS_LENS=1
  end
end

function ss_crosshair_toggle( eventSourceIndex, args )
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  if SS_SF_CROSS==1 then
    removeSFCrosshair()
    SS_SF_CROSS=0
  else
    createSFCrosshair(hero)
    SS_SF_CROSS=1
  end
end

function ss_remove_target( eventSourceIndex, args )
  local index=args['ind']
  SS_TARGETS[index]:RemoveSelf()
  SS_TARGETS[index]=nil
  SS_TARGET_MOVE_RADIUS[index]=nil
  SS_MOVE_DIR[index]=nil
  SS_MOVE_SPEED[index]=nil
  
end

function ss_add_target( eventSourceIndex, args )
  local name=args['name']
  ssAddUnitNew(name,RandomInt(SS_MINRANGE,SS_MAXRANGE),RandomInt(SS_MINSPEED,SS_MAXSPEED),nil)
  
end

function ss_training_end( eventSourceIndex, args )
  SS_TRAINING=0
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 800, true)
  for k,v in pairs(SS_TARGETS) do
    if not v:IsNull() then
      v:RemoveSelf()
    end
  end
  for k,v in pairs(SS_PLACE) do
    ParticleManager:DestroyParticle(v, true)
    ParticleManager:ReleaseParticleIndex(v)
  end
  if SS_HEROES[SS_SKILL_ID]=="npc_dota_hero_meepo" then
    local trash=Entities:FindAllByName("npc_dota_hero_meepo")
    for k,v in pairs(trash) do
      if v:IsClone() then
        v:RemoveSelf()
      end
    end
  end
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end


function ss_training_v2_end( eventSourceIndex, args )
  SS_TRAINING=0
  GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 800, true)
  for k,v in pairs(SS_TARGETS) do
    if not v:IsNull() then
      v:RemoveSelf()
    end
  end
  for k,v in pairs(SS_PLACE) do
    ParticleManager:DestroyParticle(v, true)
    ParticleManager:ReleaseParticleIndex(v)
  end
  if SS_HEROES[SS_SKILL_ID]=="npc_dota_hero_meepo" then
    local trash=Entities:FindAllByName("npc_dota_hero_meepo")
    for k,v in pairs(trash) do
      if v:IsClone() then
        v:RemoveSelf()
      end
    end
  end
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function change_tree_lvl( eventSourceIndex, args )
  local tree_inc=args['plus']
  local new_tree_lvl=SS_TREE_LEVEL+tree_inc
  if new_tree_lvl>=0 and new_tree_lvl<=4 then
    GridNav:DestroyTreesAroundPoint(TRAINING_PLACE, 800, true)
    SS_TREE_LEVEL=new_tree_lvl
    CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='treeField',value='Lvl '..SS_TREE_LEVEL})
    local tree_count=4*SS_TREE_LEVEL
    for i=1,tree_count do
      local tree_respawn=RotatePosition(TRAINING_PLACE,QAngle(0,360/tree_count*i,0),SS_MINVEC)
      CreateTempTree(tree_respawn, 9999999)
    end
  end
  
end

function change_skill_lvl( eventSourceIndex, args )
  local lvl_inc=args['plus']
  local ability=EntIndexToHScript(args['index'])
  local currentLvl=ability:GetLevel()
  local new_skill_lvl=currentLvl+lvl_inc
  if new_skill_lvl>=1 and new_skill_lvl<=ability:GetMaxLevel() then
    if ability:GetAbilityName()=="meepo_earthbind" then
      local trash=Entities:FindAllByName("npc_dota_hero_meepo")
      for k,v in pairs(trash) do
        local kek=v:FindAbilityByName("meepo_earthbind")
        kek:SetLevel(new_skill_lvl)
      end
    end
    ability:SetLevel(new_skill_lvl)
  end
end

--[[SS_MAXRANGE=1500 ss_lense_toggle
  SS_MINRANGE=600
  SS_MAXSPEED=700
  SS_MINSPEED=200
  SS_MAXRANGE_EVER=3000
  SS_MINRANGE_EVER=450--]]



function change_global_settings( eventSourceIndex, args )
  local value=args['value']
  local var_inc=args['plus']
  if value=="minR" then
    local new_value=SS_MINRANGE+var_inc*50
    if new_value>=SS_MINRANGE_EVER and new_value<=SS_MAXRANGE then
      SS_MINRANGE=new_value
      CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='minRField',value=SS_MINRANGE})
      RemakeTargetsRadius()
    end
  end
  if value=="maxR" then
    local new_value=SS_MAXRANGE+var_inc*50
    if new_value>=SS_MINRANGE and new_value<=SS_MAXRANGE_EVER then
      SS_MAXRANGE=new_value
      CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='maxRField',value=SS_MAXRANGE})
      --[[SS_HERO:SetDayTimeVisionRange(SS_MAXRANGE+200)--]]
      RemakeTargetsRadius()
    end
  end
  if value=="minMs" then
    local new_value=SS_MINSPEED+var_inc*50
    if new_value>=SS_MINSPEED_EVER and new_value<=SS_MAXSPEED then
      SS_MINSPEED=new_value
      CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='minMSField',value=SS_MINSPEED})
      RemakeTargetsSpeed()
    end
  end
  if value=="maxMs" then
    local new_value=SS_MAXSPEED+var_inc*50
    if new_value>=SS_MINSPEED and new_value<=SS_MAXSPEED_EVER then
      SS_MAXSPEED=new_value
      CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='maxMSField',value=SS_MAXSPEED})
      RemakeTargetsSpeed()
    end
  end

end

function training_polygon_end( eventSourceIndex, args )
  GameRules:SetCustomVictoryMessageDuration(1)
  GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
  Timers:CreateTimer({
    useGameTime = false,
    endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      SendToConsole("disconnect")
    end
  })
  
end

function change_max_speed( eventSourceIndex, args )
  local pidor
  for k,v in pairs(SS_TARGET_MOVE_RADIUS) do
    pidor=k
  end
  local speed_inc=args['plus']
  SS_MOVE_SPEED[pidor]=SS_MOVE_SPEED[pidor]+speed_inc*50
  SS_TARGETS[pidor]:SetBaseMoveSpeed(SS_MOVE_SPEED[pidor])
  
  CustomGameEventManager:Send_ServerToAllClients("update_settings_field",{field='minMSField',value=SS_MOVE_SPEED[pidor]})

end



function GameMode:TestCommand2()
  parseQuadroValue("2.1",nil)
  --TESTING=1
  local cmdPlayer = Convars:GetCommandClient()
  local old_hero = cmdPlayer:GetAssignedHero()
  active_hero=replaceHero(old_hero,"npc_dota_hero_nyx_assassin")
  active_hero:SetAbsOrigin(Vector(732.22778320313,-4061.9580078125,384))
  active_hero:SetBaseManaRegen(100)
  local item = CreateItem("item_ultimate_scepter", active_hero, active_hero)  
  active_hero:AddItem(item)
  local hook=active_hero:FindAbilityByName("nyx_assassin_impale")
  hook:SetLevel(1)
  local travel = CreateItem("item_travel_boots", active_hero, active_hero)  
  active_hero:AddItem(travel)
  local blink = CreateItem("item_blink", active_hero, active_hero)  
  active_hero:AddItem(blink)
  refreshItems2(active_hero)
--[[  if string.sub(ability_name,1,4)=='item' then
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
  end--]]
  SS_ENEMIES={"npc_dota_hero_nevermore",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_tusk",
    "npc_dota_hero_meepo",
    "npc_dota_hero_riki"
  }
--3,4->1-4   1,2->4-7
  waypoints1={
    Vector(-3592.6506347656,-1018.6044311523,384),
    Vector(-4850.9174804688,-1396.0091552734,384),
    Vector(-869.45404052734,-4010.3049316406,384),
    Vector(1785.5065917969,-5665.6801757813,384),
    }

  waypoints2={
    Vector(5400.4326171875,-3155.8054199219,384),
    Vector(3625.8869628906,-3315.4985351563,249.88737487793),
    Vector(2004.5510253906,-2399.7614746094,256),
    Vector(-478.88110351563,-319.41876220703,128),
    Vector(-2099.2329101563,544.71551513672,239.99560546875),
    Vector(-4149.7709960938,1769.2938232422,384),
    Vector(-5404.5649414063,2585.34765625,384),
    }

  waypoint3=Vector(5323, 4788, 384)
  for k,v in pairs(waypoints1) do
    DebugDrawCircle(v, Vector(255,255,0), 25, 25, true, 100)
    DebugDrawText(v+Vector(100,0,0), tostring(k), true, 100)

  end
  for k,v in pairs(waypoints2) do
    DebugDrawCircle(v, Vector(255,0,255), 25, 25, true, 100)
    DebugDrawText(v+Vector(100,0,0), tostring(k), true, 100)
  end

  local waypoint1_ind=RandomInt(1,4)
  local waypoint2_ind
  if waypoint1_ind>2 then
    waypoint2_ind=RandomInt(1,4)
  elseif waypoint1_ind<2 then
    waypoint2_ind=RandomInt(5,7)
  else
    waypoint2_ind=RandomInt(6,5)
  end
  beglec=SS_ENEMIES[RandomInt(1,6)]
  ss_beglec(beglec,waypoints1[waypoint1_ind],waypoints2[waypoint2_ind],waypoint3)
--[[  TEST_TABLE={
  {"axe_berserkers_call", "npc_dota_hero_axe"},
  {"centaur_hoof_stomp", "npc_dota_hero_centaur"},
  {"rattletrap_power_cogs", "npc_dota_hero_rattletrap"},
  {"earth_spirit_boulder_smash", "npc_dota_hero_earth_spirit"},
  {"earthshaker_fissure", "npc_dota_hero_earthshaker"},
  {"earthshaker_enchant_totem", "npc_dota_hero_earthshaker"},
  {"earthshaker_enchant_totem", "npc_dota_hero_earthshaker"},
  {"earthshaker_echo_slam", "npc_dota_hero_earthshaker"},
  {"elder_titan_echo_stomp", "npc_dota_hero_elder_titan"},
  {"ember_spirit_searing_chains", "npc_dota_hero_ember_spirit"},
  {"gyrocopter_call_down", "npc_dota_hero_gyrocopter"},
  {"kunkka_torrent", "npc_dota_hero_kunkka"},
  {"kunkka_ghostship", "npc_dota_hero_kunkka"},
  {"kunkka_ghostship", "npc_dota_hero_kunkka"},
  {"magnataur_skewer", "npc_dota_hero_magnataur"},
  {"magnataur_reverse_polarity", "npc_dota_hero_magnataur"},
  {"pudge_meat_hook", "npc_dota_hero_pudge"},
  {"sandking_burrowstrike", "npc_dota_hero_sand_king"},
  {"slardar_slithereen_crush", "npc_dota_hero_slardar"},
  {"spirit_breaker_charge_of_darkness", "npc_dota_hero_spirit_breaker"},
  {"tidehunter_ravage", "npc_dota_hero_tidehunter"},
  {"tusk_snowball", "npc_dota_hero_tusk"},
  {"bloodseeker_blood_bath", "npc_dota_hero_bloodseeker"},
  {"lone_druid_savage_roar", "npc_dota_hero_lone_druid"},
  {"meepo_poof", "npc_dota_hero_meepo"},
  {"mirana_arrow", "npc_dota_hero_mirana"},
  {"monkey_king_boundless_strike", "npc_dota_hero_monkey_king"},
  {"nyx_assassin_impale", "npc_dota_hero_nyx_assassin"},
  {"pangolier_shield_crash", "npc_dota_hero_pangolier"},
  {"nevermore_shadowraze1", "npc_dota_hero_nevermore"},
  {"nevermore_shadowraze2", "npc_dota_hero_nevermore"},
  {"nevermore_shadowraze3", "npc_dota_hero_nevermore"},
  {"nevermore_requiem", "npc_dota_hero_nevermore"},
  {"slark_pounce", "npc_dota_hero_slark"},
  {"ancient_apparition_cold_feet", "npc_dota_hero_ancient_apparition"},
  {"ancient_apparition_ice_blast", "npc_dota_hero_ancient_apparition"},
  {"dark_seer_vacuum", "npc_dota_hero_dark_seer"},
  {"dark_willow_cursed_crown", "npc_dota_hero_dark_willow"},
  {"death_prophet_silence", "npc_dota_hero_death_prophet"},
  {"invoker_tornado", "npc_dota_hero_invoker"},
  {"invoker_emp", "npc_dota_hero_invoker"},
  {"invoker_chaos_meteor", "npc_dota_hero_invoker"},
  {"invoker_sun_strike", "npc_dota_hero_invoker"},
  {"invoker_deafening_blast", "npc_dota_hero_invoker"},
  {"leshrac_split_earth", "npc_dota_hero_leshrac"},
  {"lina_light_strike_array", "npc_dota_hero_lina"},
  {"lion_impale", "npc_dota_hero_lion"},
  {"puck_waning_rift", "npc_dota_hero_puck"},
  {"pugna_nether_blast", "npc_dota_hero_pugna"},
  {"visage_summon_familiars",  "npc_dota_hero_visage"},
  {"warlock_rain_of_chaos", "npc_dota_hero_warlock"},
  {"windrunner_shackleshot", "npc_dota_hero_windrunner"}
  }

  if TEST_ID==1 then
    ebalai=CreateUnitByName("npc_dota_hero_storm_spirit", Vector(0,0,128), true, nil, nil, DOTA_TEAM_BADGUYS)
    ebalai:SetAttackCapability(0)
    for i=1,4 do
      local booster=CreateItem("item_heart",ebalai,ebalai)
      ebalai:AddItem(booster)
    end
  end
  print(TEST_TABLE[TEST_ID][2])
  local old_hero = cmdPlayer:GetAssignedHero()
  active_hero=replaceHero(old_hero,TEST_TABLE[TEST_ID][2])
  local ability=active_hero:FindAbilityByName(TEST_TABLE[TEST_ID][1])
  ability:SetLevel(1)
  TEST_ID=TEST_ID+1--]]
  
  --[[for i=-5,5 do
    for j=-5,5 do
      local ward=CreateUnitByName("npc_dota_observer_wards", Vector(1600*i,1600*j,128), true, nil, nil, DOTA_TEAM_GOODGUYS)
    end
  end--]]

  --8000
  --print("hidden:",sunstrike:IsHidden())
--[[
  local cmdPlayer = Convars:GetCommandClient()
  local active_hero = cmdPlayer:GetAssignedHero()
  local radius=1200

  local kekus=CreateUnitByNameAsync("npc_dota_hero_antimage", randomCirclePositionVector(radius,Vector(0,0,128)), true, nil, nil, DOTA_TEAM_BADGUYS, function(targetUnit) 

    local speed=targetUnit:GetBaseMoveSpeed()
    targetUnit:SetMoveCapability(1)
    targetUnit:SetAttackCapability(0)
    local direction_seed=RandomInt(-100,100)
    local direction
    if direction_seed<0 then
      direction=-1
    else
      direction=1
    end
    local target_index=targetUnit:entindex()
    SS_MOVE_DIR[target_index]=direction
    SS_TARGETS[target_index]=targetUnit
    SS_TARGET_MOVE_RADIUS[target_index]=radius
    SS_MOVE_DIR[target_index]=direction
    SS_MOVE_SPEED[target_index]=speed
    local unit_pos=targetUnit:GetAbsOrigin()
    local move_dir=(Vector(0,0,128)-unit_pos):Normalized()
    local move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
    if direction>0 then
      new_dir=Vector(move_dir.y,-move_dir.x,0)
    else
      new_dir=Vector(-move_dir.y,move_dir.x,0)
    end
    targetUnit:SetForwardVector(new_dir)
    CustomGameEventManager:Send_ServerToAllClients("skillshot_new_target",{index=target_index,name="npc_dota_hero_antimage"})
    ssAmBlinking(target_index,true)
  end)--]]

end

function kunnka_training_start( eventSourceIndex, args )
  KUNNKA_TRAINING=1
  MARKS_CASTED=0
  KUNNKA_TORRENT=0
  KUNNKA_TORRENT_TIME=0
  KUNNKA_RETURN=0
  KUNNKA_RETURN_TIME=0
  local TimebarState=args['timebar']
  KUNNKA_TYPE=args['procast']
  print('KUNNKA_TYPE',KUNNKA_TYPE)
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  active_hero=replaceHero(hero,"npc_dota_hero_kunkka")
  active_hero:SetMoveCapability(1)
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  removeItems(active_hero)
  local ability_name = "kunkka_torrent"
  local ability = active_hero:FindAbilityByName(ability_name)
  ability:SetLevel(1)
  local ability_name3 = "kunkka_x_marks_the_spot"
  local ability3 = active_hero:FindAbilityByName(ability_name3)
  ability3:SetLevel(1)
  if KUNNKA_TYPE==2 then
    local ability_name2 = "kunkka_ghostship"
    local ability2 = active_hero:FindAbilityByName(ability_name2)
    ability2:SetLevel(1)
  end
  TIMING_TARGET="npc_dota_hero_tiny"
  pizduk=CreateUnitByName(TIMING_TARGET, randomCirclePosition(500,active_hero), true, nil, nil, DOTA_TEAM_BADGUYS)
  for i=1,5 do
    local booster=CreateItem("item_soul_booster",pizduk,pizduk)
    pizduk:AddItem(booster)
  end
  pizduk:SetBaseStrength(0)
  Timers:CreateTimer({
    endTime = FrameTime(),
    callback = function()
    local strength=pizduk:GetBaseStrength()
    local statusResist=strength*0.15
    CustomGameEventManager:Send_ServerToAllClients("str_tracker",{str=strength, sr=statusResist})
    end
  })
  pizduk:SetBaseHealthRegen(100)
  pizduk:SetAttackCapability(0)
  pizduk:SetBaseManaRegen(50)
  pizduk:SetBaseMoveSpeed(700)
  CustomGameEventManager:Send_ServerToAllClients("kun_start",{timebar=TimebarState, procast=KUNNKA_TYPE})
end

function kunnka_training_end( eventSourceIndex, args )
  local trash=Entities:FindAllByName("npc_dota_hero_tiny")
  for k,v in pairs(trash) do
    v:RemoveSelf()
  end
  KUNNKA_TRAINING=0
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function deam_coil_escape( eventSourceIndex, args )
  DREAM_COIL_ESCAPE=1
 
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  active_hero=replaceHero(hero,"npc_dota_hero_antimage")
  active_hero:SetMoveCapability(1)
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  removeItems(active_hero)
  local manta=CreateItem("item_manta",active_hero,active_hero)
  active_hero:AddItem(manta)
  TIMING_TARGET="npc_dota_hero_puck"
  pizduk=CreateUnitByName(TIMING_TARGET, randomCirclePosition(500,active_hero), true, nil, nil, DOTA_TEAM_BADGUYS)
  local dream_coil=pizduk:FindAbilityByName("puck_dream_coil")
  dream_coil:SetLevel(1)
  for i=1,3 do
    local booster=CreateItem("item_heart",pizduk,pizduk)
    pizduk:AddItem(booster)
  end
  for i=1,3 do
    local booster=CreateItem("item_sheepstick",pizduk,pizduk)
    pizduk:AddItem(booster)
  end
  Timers:CreateTimer("dream_coil_spam", {
    useGameTime=true,
    endTime=1.5,
    callback=function()
      refreshItems2(active_hero)
      healHero(active_hero)
      dream_coil:EndCooldown()
      dream_coil:RefundManaCost()
      pizduk:SetContextThink(DoUniqueString("cast_ability"),function()  pizduk:CastAbilityOnPosition(active_hero:GetAbsOrigin(),dream_coil,-1) end, 0)
      return 7
    end
  })

  Timers:CreateTimer("last_hit_waves", {
      useGameTime = false,
      endTime = 1,
      callback = function()
        if DREAM_COIL_ESCAPE==1 then
           
          return 7
          --return FrameTime()
        else
          return nil
        end
      end
  })  
  pizduk:SetBaseHealthRegen(100)
  pizduk:SetAttackCapability(0)
  pizduk:SetBaseManaRegen(50)
  pizduk:SetBaseMoveSpeed(700)
  CustomGameEventManager:Send_ServerToAllClients("dreamcoil_start",{})
end

function deam_coil_escape_end( eventSourceIndex, args )
  local trash=Entities:FindAllByName("npc_dota_hero_puck")
  for k,v in pairs(trash) do
    v:RemoveSelf()
  end
  Timers:RemoveTimer("dream_coil_spam")
  DREAM_COIL_ESCAPE=0
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end

function naga_sleep_hammer_start( eventSourceIndex, args )
  NAGA_TRAINING=1
  SLEEP_CASTED=0
  KUNNKA_TORRENT=0
  KUNNKA_TORRENT_TIME=0
  KUNNKA_RETURN=0
  KUNNKA_RETURN_TIME=0
  local TimebarState=args['timebar']
  KUNNKA_TYPE=args['procast']
  print('KUNNKA_TYPE',KUNNKA_TYPE)
  local player=PlayerResource:GetPlayer(args.PlayerID)
  local hero=player:GetAssignedHero()
  active_hero=replaceHero(hero,"npc_dota_hero_kunkka")
  active_hero:SetMoveCapability(1)
  active_hero:SetAbsOrigin(TRAINING_PLACE)
  removeItems(active_hero)
  local ability_name = "kunkka_torrent"
  local ability = active_hero:FindAbilityByName(ability_name)
  ability:SetLevel(1)
  local ability_name3 = "kunkka_x_marks_the_spot"
  local ability3 = active_hero:FindAbilityByName(ability_name3)
  ability3:SetLevel(1)
  if KUNNKA_TYPE==2 then
    local ability_name2 = "kunkka_ghostship"
    local ability2 = active_hero:FindAbilityByName(ability_name2)
    ability2:SetLevel(1)
  end
  TIMING_TARGET="npc_dota_hero_tiny"
  pizduk=CreateUnitByName(TIMING_TARGET, randomCirclePosition(500,active_hero), true, nil, nil, DOTA_TEAM_BADGUYS)
  for i=1,5 do
    local booster=CreateItem("item_soul_booster",pizduk,pizduk)
    pizduk:AddItem(booster)
  end
  pizduk:SetBaseStrength(0)
  Timers:CreateTimer({
    endTime = FrameTime(),
    callback = function()
    local strength=pizduk:GetBaseStrength()
    local statusResist=strength*0.15
    CustomGameEventManager:Send_ServerToAllClients("str_tracker",{str=strength, sr=statusResist})
    end
  })
  pizduk:SetBaseHealthRegen(100)
  pizduk:SetAttackCapability(0)
  pizduk:SetBaseManaRegen(50)
  pizduk:SetBaseMoveSpeed(700)
  CustomGameEventManager:Send_ServerToAllClients("kun_start",{timebar=TimebarState, procast=KUNNKA_TYPE})
end

function naga_sleep_hammer_end( eventSourceIndex, args )
  local trash=Entities:FindAllByName("npc_dota_hero_tiny")
  for k,v in pairs(trash) do
    v:RemoveSelf()
  end
  KUNNKA_TRAINING=0
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end
function lasthit_start( eventSourceIndex, args )
  PrecacheUnitByNameAsync(args['hero'],function() lasthit_start_fix( eventSourceIndex, args ) end,args.PlayerID)

end
function lasthit_start_fix( eventSourceIndex, args )
  --middle point Vector(-498.22644042969,-296.97790527344,128)
  lh_middle_point=Vector(-498.22644042969,-296.97790527344,128)
  lh_dire_tower_spawn=lh_middle_point+Vector(1,1,0)*1000

  local bot_left=Vector(-1893.4349365234,-1761.212890625,128)
  local top_right=Vector(961.759765625,1132.8590087891,128)
  AIM_BOX=CreateParticleBox(bot_left, top_right, "particles/custom/range_display_line_red.vpcf", player)
  lh_radiant_tower_spawn=lh_middle_point+Vector(-1,-1,0)*1000
  LH_DIRE_TOWER=CreateUnitByName("npc_dota_badguys_tower1_mid", lh_dire_tower_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
  LH_DIRE_TOWER:SetAbsOrigin(lh_dire_tower_spawn)
  LH_RADIANT_TOWER=CreateUnitByName("npc_dota_goodguys_tower1_mid", lh_radiant_tower_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
  LH_RADIANT_TOWER:SetAbsOrigin(lh_radiant_tower_spawn)
  LASTHIT_TRAINING=1
  LH_CREEPS={}
  LH_AVG_TIMES={}
  LH_GOOD_HITS=0
  LH_BAD_HITS=0
  CustomGameEventManager:Send_ServerToAllClients("lh_start",{})
  local hero=args['hero']
  local lane=args['lane']
  local items=args['items']
  local side=args['side']
  player_side=0
  local hero_respawn
  local enemy_side
  if side==0 then
    --hero_respawn=Vector(-3968.054443, -3462.106689, 264.750000)
    hero_respawn=Vector(-930.81896972656,157.91223144531,128)
    player_side=DOTA_TEAM_GOODGUYS
    enemy_side=DOTA_TEAM_BADGUYS
    --radiant
  else
    player_side=DOTA_TEAM_BADGUYS
    enemy_side=DOTA_TEAM_GOODGUYS
    --hero_respawn=Vector(3450.819824, 2937.588135, 264.000000)
    hero_respawn=Vector(-930.81896972656,157.91223144531,128)
    --dire
  end
  local player=PlayerResource:GetPlayer(args.PlayerID)
  print("PLAYER ID:", args.PlayerID)
  local old_hero=player:GetAssignedHero()
  PlayerResource:SetCustomTeamAssignment(args.PlayerID,player_side)
  active_hero=replaceHero(old_hero,hero)
  --active_hero:SetAbsOrigin(hero_respawn)
  active_hero:SetAbsOrigin(Vector(-2717.9250488281,-1176.9210205078,128))
  active_hero:SetMoveCapability(1)
  if active_hero:GetUnitName()=="npc_dota_hero_morphling" then
    local ability1=active_hero:FindAbilityByName("morphling_morph_agi")
    active_hero:UpgradeAbility(ability1)
    --[[local ability2=active_hero:FindAbilityByName("morphling_morph_str")
    active_hero:UpgradeAbility(ability2)--]]
  end
  if active_hero:GetUnitName()=="npc_dota_hero_invoker" then
    local ability1=active_hero:FindAbilityByName("invoker_exort")
    active_hero:UpgradeAbility(ability1)
    --[[local ability2=active_hero:FindAbilityByName("morphling_morph_str")
    active_hero:UpgradeAbility(ability2)--]]
  end
  if active_hero:GetUnitName()=="npc_dota_hero_lone_druid" then
    local ability1=active_hero:FindAbilityByName("lone_druid_spirit_bear")
    active_hero:UpgradeAbility(ability1)
    --[[local ability2=active_hero:FindAbilityByName("morphling_morph_str")
    active_hero:UpgradeAbility(ability2)--]]
  end
  removeItems(active_hero)
  --item choice validation:
  local total_cost=0
  for k,v in pairs(items) do
    total_cost=total_cost+GetItemCost(v)

  end
  print('items cost:',total_cost)
  if total_cost>600 then
    print('ERROR')
  else
    for k,v in pairs(items) do
      local item = CreateItem(v,active_hero,active_hero)
      active_hero:AddItem(item)
    end
  end
  AGGRO_ENEMY=CreateUnitByName("npc_dota_hero_axe", Vector(-1187.919312, 388.352478, 128.000000), true, nil, nil, enemy_side)
  AGGRO_ENEMY:SetIdleAcquire(false)
  AGGRO_ENEMY:SetAttackCapability(0)
  AGGRO_ENEMY:AddNewModifier(AGGRO_ENEMY, nil, "modifier_elder_titan_echo_stomp", {})
  --respawn_place:  Vector 00000000002528F0 [-986.967834 76.127319 128.000000]
  Timers:CreateTimer("last_hit_waves", {
      useGameTime = false,
      endTime = 0,
      callback = function()
        if LASTHIT_TRAINING==1 then
          sendDireMidCreepwave()
          sendRadiantMidCreepwave()
          return 30
        else
          return nil
        end
      end
    })
  LASTHIT_MIN_DMG=active_hero:GetBaseDamageMin()
  --sniper enemy
  if args['sniper']==1 then
    sniper=CreateUnitByName("npc_dota_hero_sniper",lh_dire_tower_spawn+Vector(200,0,0) , true, nil, nil, DOTA_TEAM_BADGUYS)
    activateShiperAI(sniper)
    --sniperAIv2(sniper)
    --naiSniper(sniper)
    sniper:SetControllableByPlayer(active_hero:GetPlayerID(),false)
  end
end
function lasthit_end( eventSourceIndex, args )
  LASTHIT_TRAINING=0
  --PlayerResource:SetCustomTeamAssignment(args.PlayerID,DOTA_TEAM_GOODGUYS)
  local trash=Entities:FindAllByName("npc_dota_creep_lane")
  for k,v in pairs(trash) do
    v:RemoveSelf()
  end
  AGGRO_ENEMY:RemoveSelf()
  LH_DIRE_TOWER:RemoveSelf()
  LH_RADIANT_TOWER:RemoveSelf()
  if not SN_AI_SNIPER:IsNull()then
    SN_AI_SNIPER:RemoveSelf()
  end
  Timers:RemoveTimer("ai_thinker_for_sniper")
  Timers:RemoveTimer("ai_thinker_for_sniper_reposition")
  Timers:RemoveTimer("last_hit_waves")
  CustomGameEventManager:Send_ServerToAllClients("custom_training_ends",{})
end
--invoker_invoke_end euls_change_str manta_challenge_start
--ss_scepter_toggle ss_training_end training_polygon_end change_skill_lvl invoker_procast_end ss_blink_toggle

--invoker_talent_toggle ss_crosshair_toggle

function tp_precache( eventSourceIndex, args )
  local jsArgs=args['jsArgs']
  precache_v2(jsArgs)

end

function saveJson(json)
  local key=GetDedicatedServerKeyV2('dick')
  local req1 = CreateHTTPRequestScriptVM('POST', 'https://c0mb1ne.ru/nai/test.php')
  req1:SetHTTPRequestHeaderValue("Auth-Token", key)
  req1:SetHTTPRequestGetOrPostParameter("request","save_json")
  req1:SetHTTPRequestGetOrPostParameter("json",json)
  req1:Send(function(res)
    print('json sent',res.StatusCode,res.Body)
  end)

end

function user_init( eventSourceIndex, args )

    local key=GetDedicatedServerKeyV2('dick')
    local type=args['type']
    local data=args['data']
    local url="http://vh184007.eurodir.ru/tpserver/"
    --DeepPrintTable(args)
    local req = CreateHTTPRequestScriptVM(type, url)
    req:SetHTTPRequestHeaderValue("Auth-Token", key)
    for k,v in pairs(args['data']) do
      print(k,v)
      req:SetHTTPRequestGetOrPostParameter(tostring(k),tostring(v))
    end
    --req:SetHTTPRequestHeaderValue("Accept", "application/json")
    --req:SetHTTPRequestGetOrPostParameter("request","sendResult_v2")

    req:Send(function(res)

      if res.StatusCode ~= 200 then

        my_output("Failed to contact server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
        my_output("Body:".. (res.Body or "nil"))
        
        
      else
        if string.find(res.Body,"opendns") then
          my_output("looks like opendns shit happened. attempt to resend data after 0.5 sec.")
          
        else
          --res_table=json.decode(res.Body)
          --[[if res_table["msg"]=="highscore" then
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=1,mod=mode,score=res_table['score'],place=res_table['place'],total=res_table['total']})
          else
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=0,mod=mode,score=res_table['score']})
          end--]]
          my_output("Connected to leaderboard server "..res.StatusCode)
          my_output("Body:".. (res.Body or "nil"))
          CustomGameEventManager:Send_ServerToAllClients("user_init_answer",{data=res.Body})
        end
      end

      if not res.Body then
        my_output("No result returned from server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
      end

    end)
end

function web_req_from_client( eventSourceIndex, args )

    local key=GetDedicatedServerKeyV2('dick')
    local type=args['type']
    local data=args['data']
    local url="http://vh184007.eurodir.ru/tpserver/"
    --DeepPrintTable(args)
    local req = CreateHTTPRequestScriptVM(type, url)
    req:SetHTTPRequestHeaderValue("Auth-Token", key)
    for k,v in pairs(args['data']) do
      print(k,v)
      req:SetHTTPRequestGetOrPostParameter(tostring(k),tostring(v))
    end
    --req:SetHTTPRequestHeaderValue("Accept", "application/json")
    --req:SetHTTPRequestGetOrPostParameter("request","sendResult_v2")

    req:Send(function(res)

      if res.StatusCode ~= 200 then

        my_output("Failed to contact server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
        my_output("Body:".. (res.Body or "nil"))
        
        
      else
        if string.find(res.Body,"opendns") then
          my_output("looks like opendns shit happened. attempt to resend data after 0.5 sec.")
          
        else
          --res_table=json.decode(res.Body)
          --[[if res_table["msg"]=="highscore" then
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=1,mod=mode,score=res_table['score'],place=res_table['place'],total=res_table['total']})
          else
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=0,mod=mode,score=res_table['score']})
          end--]]
          my_output("Connected to leaderboard server "..res.StatusCode)
          my_output("Body:".. (res.Body or "nil"))
          CustomGameEventManager:Send_ServerToAllClients("web_client_recieve",{data=res.Body})
        end
      end

      if not res.Body then
        my_output("No result returned from server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
      end

    end)
end

function getConfigData(steam)
    local answer=nil
    local key=GetDedicatedServerKeyV2('dick')

    local req = CreateHTTPRequestScriptVM('POST', CMB_SERVER)
    req:SetHTTPRequestHeaderValue("Auth-Token", key)
    req:SetHTTPRequestGetOrPostParameter('request','get_config')
    req:SetHTTPRequestGetOrPostParameter('steam',tostring(steam))
    --req:SetHTTPRequestHeaderValue("Accept", "application/json")
    --req:SetHTTPRequestGetOrPostParameter("request","sendResult_v2")

    req:Send(function(res)

      if res.StatusCode ~= 200 then

        my_output("Failed to contact server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
        my_output("Body:".. (res.Body or "nil"))
        
        
      else
        if string.find(res.Body,"opendns") then
          my_output("looks like opendns shit happened. attempt to resend data after 0.5 sec.")
          
        else
          --res_table=json.decode(res.Body)
          --[[if res_table["msg"]=="highscore" then
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=1,mod=mode,score=res_table['score'],place=res_table['place'],total=res_table['total']})
          else
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=0,mod=mode,score=res_table['score']})
          end--]]
          my_output("Connected to leaderboard server "..res.StatusCode)
          my_output("Body:".. (res.Body or "nil"))
          if res.Body=="no config" or res.Body==nil then
            PLAYER_CONFIG="no config"
          else
            PLAYER_CONFIG=json.decode(res.Body)
          end
          
        end
      end

      if not res.Body then
        my_output("No result returned from server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
      end

    end)

end

function sendNewConfigData()

    local answer=nil
    local key=GetDedicatedServerKeyV2('dick')
    local encoded_config=json.encode(PLAYER_CONFIG)
    local cmdPlayer=PlayerResource:GetPlayer(0)
    local steam=PlayerResource:GetSteamID(cmdPlayer:GetPlayerID())
    print('sending new config',encoded_config)
    local req = CreateHTTPRequestScriptVM('POST', CMB_SERVER)
    req:SetHTTPRequestHeaderValue("Auth-Token", key)
    req:SetHTTPRequestGetOrPostParameter('request','refresh_config')
    req:SetHTTPRequestGetOrPostParameter('config',encoded_config)
    req:SetHTTPRequestGetOrPostParameter('steam',tostring(steam))
    --req:SetHTTPRequestHeaderValue("Accept", "application/json")
    --req:SetHTTPRequestGetOrPostParameter("request","sendResult_v2")

    req:Send(function(res)

      if res.StatusCode ~= 200 then

        my_output("Failed to contact server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
        my_output("Body:".. (res.Body or "nil"))
       
        
      else
        if string.find(res.Body,"opendns") then
          my_output("looks like opendns shit happened. attempt to resend data after 0.5 sec.")
          
        else
          --res_table=json.decode(res.Body)
          --[[if res_table["msg"]=="highscore" then
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=1,mod=mode,score=res_table['score'],place=res_table['place'],total=res_table['total']})
          else
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=0,mod=mode,score=res_table['score']})
          end--]]
          my_output("Connected to leaderboard server "..res.StatusCode)
          my_output("Body:".. (res.Body or "nil"))

        end
      end

      if not res.Body then
        my_output("No result returned from server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
      end

    end)
end

function ai_test_action( eventSourceIndex, args )
  aiDoAction(args['action'])
end

CustomGameEventManager:RegisterListener( "ai_test_action", ai_test_action )

CustomGameEventManager:RegisterListener( "tp_precache", tp_precache )

CustomGameEventManager:RegisterListener( "ss_crosshair_toggle", ss_crosshair_toggle )

CustomGameEventManager:RegisterListener( "invoker_talent", invoker_talent_toggle )

CustomGameEventManager:RegisterListener( "manta_challenge_start", manta_challenge_start )

CustomGameEventManager:RegisterListener( "euls_change_str", euls_change_str )

CustomGameEventManager:RegisterListener( "invoker_invoke_end", invoker_invoke_end )

CustomGameEventManager:RegisterListener( "ss_blink_toggle", ss_blink_toggle )

CustomGameEventManager:RegisterListener( "invoker_procast_end", invoker_procast_end )

CustomGameEventManager:RegisterListener( "change_skill_lvl", change_skill_lvl )

CustomGameEventManager:RegisterListener( "kunnka_training_end", kunnka_training_end )

CustomGameEventManager:RegisterListener( "kunnka_training_start", kunnka_training_start )

CustomGameEventManager:RegisterListener( "deam_coil_escape", deam_coil_escape)

CustomGameEventManager:RegisterListener( "deam_coil_escape_end", deam_coil_escape_end)

CustomGameEventManager:RegisterListener( "training_polygon_end", training_polygon_end )

CustomGameEventManager:RegisterListener( "ss_training_end", ss_training_end )

CustomGameEventManager:RegisterListener( "ss_training_v2_end", ss_training_v2_end )

CustomGameEventManager:RegisterListener( "ss_lense_toggle", ss_lense_toggle )

CustomGameEventManager:RegisterListener( "ss_scepter_toggle", ss_scepter_toggle )

CustomGameEventManager:RegisterListener( "change_max_speed", change_max_speed )

CustomGameEventManager:RegisterListener( "change_global_settings", change_global_settings )

CustomGameEventManager:RegisterListener( "ss_add_target", ss_add_target )

CustomGameEventManager:RegisterListener( "ss_remove_target", ss_remove_target )

CustomGameEventManager:RegisterListener( "skillshot_training", skillshot_training )

CustomGameEventManager:RegisterListener( "skillshot_training_v2", skillshot_training_v2 )

CustomGameEventManager:RegisterListener( "change_tree_lvl", change_tree_lvl )

CustomGameEventManager:RegisterListener( "invoker_invoke_training", invoker_invoke_training )

CustomGameEventManager:RegisterListener( "invoker_procast_move_tiny_extremely_fast", invoker_procast_move_tiny_extremely_fast )

CustomGameEventManager:RegisterListener( "invoker_procast_move_tiny", invoker_procast_move_tiny )

CustomGameEventManager:RegisterListener( "invoker_procast_start", invoker_procast_start )

CustomGameEventManager:RegisterListener( "invoker_sphere_rnd", invoker_randomize_spheres )

CustomGameEventManager:RegisterListener( "invoker_lvl", invoker_change_abil_lvl )

CustomGameEventManager:RegisterListener( "invoker_scepter", invoker_scepter_toggle )

CustomGameEventManager:RegisterListener( "euls_change_ability_lvl", euls_change_abil_lvl )

CustomGameEventManager:RegisterListener( "custom_manta_training_end", custom_manta_training_end )

CustomGameEventManager:RegisterListener( "custom_manta_training_start", custom_manta_training )

CustomGameEventManager:RegisterListener( "euls_training", timing_training_start )

CustomGameEventManager:RegisterListener( "euls_end", timing_training_end )

CustomGameEventManager:RegisterListener( "alche_end", alchemist_banka_training_end )

CustomGameEventManager:RegisterListener( "alche_start", alchemist_banka_training )

CustomGameEventManager:RegisterListener( "start_glimpse", glimpse_training_start_v2 )

CustomGameEventManager:RegisterListener( "end_glimpse", glimpse_training_end )

CustomGameEventManager:RegisterListener( "armlet_training_end", armlet_training_end )

CustomGameEventManager:RegisterListener( "armlet_training_start", armlet_training_start )

CustomGameEventManager:RegisterListener( "armlet_mod_attacker", armlet_mod_attacker )

CustomGameEventManager:RegisterListener( "aim_start", aim_training_start )

CustomGameEventManager:RegisterListener( "aim_end", aim_training_end )

CustomGameEventManager:RegisterListener( "map_aim_start", map_aim_training_start )

CustomGameEventManager:RegisterListener( "map_aim_end", map_aim_training_end )

CustomGameEventManager:RegisterListener( "lasthit_start", lasthit_start )

CustomGameEventManager:RegisterListener( "lasthit_end", lasthit_end )

CustomGameEventManager:RegisterListener( "old_timing_start", euls_training_start )
CustomGameEventManager:RegisterListener( "old_timing_end", euls_training_end )

CustomGameEventManager:RegisterListener( "moving_aim_training_start", moving_aim_training_start )
CustomGameEventManager:RegisterListener( "moving_aim_training_end", moving_aim_training_end )

CustomGameEventManager:RegisterListener( "morph_training_start", morph_training_start )
CustomGameEventManager:RegisterListener( "morph_training_end", morph_training_end )

CustomGameEventManager:RegisterListener( "aim_start2", aim_training_start_2 )

CustomGameEventManager:RegisterListener( "aim_end2", aim_training_end_2 )


CustomGameEventManager:RegisterListener( "aim_start3", aim_training_start_3 )

CustomGameEventManager:RegisterListener( "aim_end3", aim_training_end_3 )

CustomGameEventManager:RegisterListener( "web_req_from_client", web_req_from_client )

CustomGameEventManager:RegisterListener( "user_init", user_init )
--morph_training_start
-- CustomGameEventManager:RegisterListener( "ping_setting", setPing ) invoker_scepter_toggle moving_aim_training_start

LAST_NPCSpawnedKeys=nil
function GameMode:OnNPCSpawned(keys)

  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)
  
  local npc = EntIndexToHScript(keys.entindex)
  --print(npc:GetUnitName(),Time(),npc:GetAbsOrigin())
  glimpseOnUnitSpawned(npc)
  if eulsGameState==1 then
    Timers:CreateTimer(0.1, function()
      if not npc:IsNull() then
        if npc:IsIllusion() then
          npc:RemoveSelf()
        end
      end
    end
    )

  end
  if AlchemistTrainingState==1 then
    Timers:CreateTimer(0.1, function()
      if not npc:IsNull() then
        if npc:IsIllusion() then
          local player=PlayerResource:GetPlayer(npc:GetPlayerOwnerID())
          local hero=player:GetAssignedHero()
          npc:RemoveSelf()
          refreshItems2(hero)
          hero:GiveMana(500)
        end
      end
    end
    )
    --refreshItems2(active_hero)

  end
   if DREAM_COIL_ESCAPE==1 then
    if npc:GetUnitName()=="npc_dota_thinker" then
      CustomGameEventManager:Send_ServerToAllClients("dreamcoilLaunched",{dreamcoil=npc})
      local cmdPlayer=PlayerResource:GetPlayer(0)
      CreateParticleCircle(npc, 600, "particles/custom/range_display_red.vpcf", cmdPlayer)
    end

    Timers:CreateTimer(1, function()
      if not npc:IsNull() then
        if npc:IsIllusion() then
          npc:RemoveSelf()
        end
      end
    end
    )

  end
  if glimpse_v2_training_state==1 then
    Timers:CreateTimer(0.1, function()
      if not npc:IsNull() then
        if npc:IsIllusion() then
          npc:RemoveSelf()
        end
      end
    end
    )

  end
  if MORPH_TRAINING==1 then
    print(npc:GetUnitName())
    Timers:CreateTimer(0.1, function()
      if not npc:IsNull() then
        if npc:IsIllusion() then
          npc:RemoveSelf()
        end
      end
    end
    )
    if npc:GetUnitName()=="npc_dota_furion_treant_4" or npc:GetUnitName()=="npc_dota_lycan_wolf4" or npc:GetUnitName()=="npc_dota_unit_tombstone4" or npc:GetUnitName()=="npc_dota_venomancer_plague_ward_4" or npc:GetUnitName()=="npc_dota_weaver_swarm" or npc:GetUnitName()=="npc_dota_unit_undying_zombie_torso" or npc:GetUnitName()=="npc_dota_unit_undying_zombie" then
      Timers:CreateTimer(1, function()
        if not npc:IsNull() then
          npc:RemoveSelf()
        end
      end
      )
    end
  end
  if CustomGameState==1 then
    if npc:IsIllusion() then
      Timers:CreateTimer({
        endTime = FrameTime(), 
        callback = function()
          npc:RemoveSelf()
        end
      })
    end

  end


  if npc:GetUnitName()=="npc_dota_warlock_golem" then
    npc:SetAttackCapability(0)
    
    Timers:CreateTimer({
      endTime = FrameTime(),
      callback = function()
        npc:RemoveSelf()
      end
    })
  end
  if TIMING_START==1 then
    if npc:IsIllusion() then
      Timers:CreateTimer({
      endTime = FrameTime(),
      callback = function()
        npc:RemoveSelf()
      end
    })
      

    end

  end
  if MAP_AIM_TRAINING==1 then

    Timers:CreateTimer({
      endTime = FrameTime(),
      callback = function()
        if not npc:IsNull() then
          if npc:GetUnitName()=="npc_dota_creep_badguys_melee" then
            AddFOWViewer(DOTA_TEAM_GOODGUYS, npc:GetAbsOrigin(), 400, 5.5, true)
            --CustomGameEventManager:Send_ServerToAllClients("ping_on_minimap",{respawn_place=npc:GetAbsOrigin()})
          end
          if npc:GetUnitName()=="npc_dota_thinker" and npc:FindModifierByName("modifier_invoker_sun_strike") then
            checkSunstrikeHit(npc:GetAbsOrigin())

          end
        end
      end
    })
    if npc:GetUnitName()=="npc_dota_creep_badguys_melee" then
      local ward_info={keys.entindex,Time()}
      table.insert(WARD_POOL,ward_info)
      
        Timers:CreateTimer({
          useGameTime = false,
          endTime = 0.1,
          callback = function()
            if not npc:IsNull() then
              local new_hp=npc:GetHealth()
              if new_hp-20<=0 then
                CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=npc:GetAbsOrigin().x,bady=npc:GetAbsOrigin().y})
                npc:RemoveSelf()
                EmitGlobalSound('sproing')
                hero:EmitSound("sproing")
                AIM_COMBO=1

              else
                npc:ModifyHealth(new_hp-20, nil, true, 0)
              end
              return 0.1
            else
              return nil
            end
          end
        })
    end
  end
  if SS_TRAINING==1 then
    if npc:GetUnitName()=="npc_dota_hero_meepo" then
        Timers:CreateTimer({
          endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
          callback = function()
            npc:SetAbsOrigin(randomCirclePositionVector(600,TRAINING_PLACE))
          end
        })
      
    end
  end
  if REACTION_TRAINING==1 then
    if npc:GetUnitName()=="npc_dota_observer_wards" then
        Timers:CreateTimer({
          useGameTime = false,
          endTime = 0.1,
          callback = function()
            if not npc:IsNull() then
              local new_hp=npc:GetHealth()
              if new_hp-10<=0 then
                --[[CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=npc:GetAbsOrigin().x,bady=npc:GetAbsOrigin().y})
                npc:RemoveSelf()
                EmitGlobalSound('sproing')
                hero:EmitSound("sproing")
                AIM_COMBO=1
                print('Ward died by own death')--]]
                npc:ForceKill(false)
              else
                npc:ModifyHealth(new_hp-10, nil, true, 0)
              end
              return 0.1
            else
              return nil
            end
          end
        })
    end
    if npc:GetUnitName()=="npc_dota_sentry_wards" then
        Timers:CreateTimer({
          useGameTime = false,
          endTime = 0.1,
          callback = function()
            if not npc:IsNull() then
              local new_hp=npc:GetHealth()
              if new_hp-10<=0 then
                --[[CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=npc:GetAbsOrigin().x,bady=npc:GetAbsOrigin().y})
                npc:RemoveSelf()
                EmitGlobalSound('sproing')
                hero:EmitSound("sproing")
                AIM_COMBO=1
                print('Ward died by own death')--]]
                npc:ForceKill(false)
              else
                npc:ModifyHealth(new_hp-10, nil, true, 0)
              end
              return 0.1
            else
              return nil
            end
          end
        })
    end
  end
  if MOVING_AIM_TRAINING==1 then

    if npc:GetUnitName()=="npc_dota_neutral_centaur_khan" then
        Timers:CreateTimer({
          useGameTime = false,
          endTime = 0.1,
          callback = function()
            if not npc:IsNull() then
              local new_hp=npc:GetHealth()
              if new_hp-55<=0 then
                --[[CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=npc:GetAbsOrigin().x,bady=npc:GetAbsOrigin().y})
                npc:RemoveSelf()
                EmitGlobalSound('sproing')
                hero:EmitSound("sproing")
                AIM_COMBO=1--]]
                npc:ForceKill(false)
              else
                npc:ModifyHealth(new_hp-55, nil, true, 0)
              end
              return 0.1
            else
              return nil
            end
          end
        })
    end
  end
  -- if npc:GetUnitName()=="npc_dota_earth_spirit_stone" then
  --   stones_list[keys.entindex]=npc
  -- end
  -- print(npc:GetUnitName())
  if INV_INVOKE_MODE==1 then
    local color=Vector(255,0,0)
    local ztest=true
    --print(npc:GetName())
    --DebugDrawCircle(npc:GetAbsOrigin(), color, 20, 20, ztest, 10)
    Timers:CreateTimer({
      endTime = 0.03, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      callback = function()
        if npc:FindModifierByName("modifier_invoker_sun_strike") then
          local containers=checkInvokeContainers("invoker_sun_strike")

          if #containers>0 then
            local target=checkSkillshotHitSpirits(npc:GetAbsOrigin(),175)
            --[[inokeDebug(containers,target)--]]
            if #target>0 then
              local victimFound=0
              for k,container in pairs(containers) do
                if container==target[1] then
                  victimFound=1

                  
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_sun_strike'})
                  if INV_BASIC_MODE==1 then
                    invokeSpellCasted()
                    invPUshSkill(nil)
                  end
                  if INV_CHALLENGE==1 then
                    removeFormInvokeContainer(inv_earth)
                    removeFormInvokeContainer(inv_fire)
                    removeFormInvokeContainer(inv_storm)
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                    invChallangeSKill()
                  else
                    removeFormInvokeContainer(container)
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(container)})
                  end
                end
              end
              if victimFound==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Wrong target.',icon='invoker_sun_strike'})
              end
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill missed.',icon='invoker_sun_strike'})
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_sun_strike'})
          end
        end
        if npc:FindModifierByName("modifier_invoker_emp") then
          local targets=checkSkillshotHitSpirits(npc:GetAbsOrigin(),675)
          local containers=checkInvokeContainers("invoker_emp")
          local challengeTrash={}
          inokeDebug(containers,targets)
          if #containers>0 then
            if #targets>0 then
              local validVictims=0
              for key1,container in pairs(containers) do
                for key2,target in pairs(targets) do
                  if container==target then
                    table.insert(challengeTrash,container)
                    removeFormInvokeContainer(container)
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(container)})
                    validVictims=validVictims+1
                    if INV_BASIC_MODE==1 then
                      invokeSpellCasted()
                      invPUshSkill(nil)
                    end
                  end
                end
              end
              if INV_CHALLENGE==1 then
                invClearLine(challengeTrash)
                invChallangeSKill()
              end
              if validVictims==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Wrong target.',icon='invoker_emp'})
              else
                if validVictims==#targets then
                  if validVictims==#containers then
                    --good
                    if validVictims==3 then
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect! x'..validVictims,icon='pogchamp'})
                    end
                    if validVictims==2 then
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! x'..validVictims,icon='invoker_emp'})
                    end
                    if validVictims==1 then
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_emp'})
                    end
                  else
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Wrong target.',icon='invoker_emp'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You hited unnecessary target.',icon='invoker_emp'})
                end
              end
              --[[if validVictims~=0 then
                if validVictims>1 then
                  if validVictims==3 then
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect! x'..validVictims,icon='pogchamp'})
                  else
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! x'..validVictims,icon='invoker_emp'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_emp'})
                end
                
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Wrong target.',icon='invoker_emp'})
              end--]]
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill missed.',icon='invoker_emp'})
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_emp'})
          end

        end
        if npc:FindModifierByName("modifier_invoker_chaos_meteor_land") then
          local containers=checkInvokeContainers("invoker_chaos_meteor")
          if #containers>0 then
            local target=checkSkillshotHitSpirits(npc:GetAbsOrigin(),275)
            --[[inokeDebug(containers,target)--]]
            if #target>0 then
              local victimFound=0
              for k,container in pairs(containers) do
                if container==target[1] then
                  victimFound=1
                  
                  if INV_CHALLENGE==1 then
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                    
                    removeFormInvokeContainer(inv_earth)
                    removeFormInvokeContainer(inv_storm)
                    removeFormInvokeContainer(inv_fire)
                    invChallangeSKill()
                  else
                    removeFormInvokeContainer(container)
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(container)})
                  end

                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_chaos_meteor'})
                  if INV_BASIC_MODE==1 then
                    invokeSpellCasted()
                    invPUshSkill(nil)
                  end
                end
              end
              if victimFound==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Wrong target.',icon='invoker_chaos_meteor'})
              end
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill missed.',icon='invoker_chaos_meteor'})
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_chaos_meteor'})
          end
        end
      end
    })
  end
  if INVOKER_TRAINING==1 then
    -- local color=Vector(255,0,0)
    -- local ztest=true
    -- print(npc:GetName())
    -- if npc:GetUnitName()~='npc_dota_thinker' and npc:GetUnitName()~="npc_dota_invoker_forged_spirit" then
    --   DebugDrawCircle(npc:GetAbsOrigin(), color, 20, 20, ztest, 10)
    --   INV_METEOR_POINT=npc:GetAbsOrigin()
    -- end
    

    
  end
  if REACTION_TRAINING==1 then
    if npc:GetUnitName()=="npc_dota_observer_wards" then
      local ward_info={keys.entindex,Time()}
      table.insert(WARD_POOL,ward_info)
    end
    if npc:GetUnitName()=="npc_dota_sentry_wards" then
      local ward_info={keys.entindex,Time()}
      table.insert(WARD_POOL,ward_info)
    end
  end
  if MOVING_AIM_TRAINING==1 then
    if npc:GetUnitName()=="npc_dota_neutral_centaur_khan" then
      local ward_info={keys.entindex,Time()}
      table.insert(WARD_POOL,ward_info)
    end
  end
  if eulsGameState==1 then
    if TIMING_TYPE==3 or TIMING_TYPE==4 then
      if EUL_CASTED==1 then
        if (npc==pizduk) then
          EUL_DAMAGE_TIME=Time()  
          EUL_DMG_DONE=1
        end
      end
    end
  end
  if ArmletTratiningState==1 and npc:GetUnitName()==ArmletAttackerName then
    CustomGameEventManager:Send_ServerToAllClients("armlet_update_stats",{attacker=keys.entindex})
    --print("keklokl")
  end
  ------------------------------------GLIMPSE LOGIC---------------------------------------
  if npc:GetUnitName()=="npc_dota_thinker" and glimpse_training_state==1 then
    local lenght=(active_hero:GetAbsOrigin()-npc:GetAbsOrigin()):Length()
    local lenght2=(active_hero:GetAbsOrigin()-hero_pos_table[#hero_pos_table]):Length()
    local glimpse_time=lenght/600
    if lenght/600>1.8 then
      glimpse_time=1.8
    end
    CustomGameEventManager:Send_ServerToAllClients("glimpse_casted",{bartime=glimpse_time,castpoint=GLIMPSE_SAFETIME})
    local calc_time=lenght2/600
    if lenght2/600>1.8 then
      calc_time=1.8
    end
    if GLIMPLSE_SKILL=="ember_spirit_sleight_of_fist" then
      local distance = (SAD_DISRUPTOR:GetAbsOrigin() - active_hero:GetAbsOrigin()):Length2D() 
      local direction = (SAD_DISRUPTOR:GetAbsOrigin() - active_hero:GetAbsOrigin()):Normalized()
      local target_point = 0.5 * distance
      local target_point_vector = active_hero:GetAbsOrigin() + direction * target_point
      local target="npc_dota_creep_badguys_melee"
      pizduk=CreateUnitByName(target, target_point_vector, true, nil, nil, DOTA_TEAM_BADGUYS)
      pizduk:SetMoveCapability(1)
      pizduk:SetIdleAcquire(false)
      pizduk:SetBaseHealthRegen(150)
      pizduk:SetMaximumGoldBounty(0)
      pizduk:SetMinimumGoldBounty(0)
      pizduk:SetDeathXP(0)
      PIZDUK_ALIVE=1
    end
    if GLIMPLSE_SKILL=="shredder_timber_chain" then
      local tree_point = randomRingPosition(chain_range[glimpse_level]-400,chain_range[glimpse_level],active_hero)
      local distance = (SAD_DISRUPTOR:GetAbsOrigin() - active_hero:GetAbsOrigin()):Length2D() 
      local direction = (SAD_DISRUPTOR:GetAbsOrigin() - active_hero:GetAbsOrigin()):Normalized()
      local target_point = 0.5 * distance
      local target_point_vector = active_hero:GetAbsOrigin() + direction * target_point
      CreateTempTree(target_point_vector,5)
    end
    Timers:CreateTimer({
      useGameTime = false,
      endTime = glimpse_time, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      callback = function()
        if not SAD_DISRUPTOR:IsNull() then
          SAD_DISRUPTOR:Purge(true,true,false,true,false)
          -- print("purging:",Time())
        end
      end
    })
    local glimpse_pos=npc:GetAbsOrigin()
    Timers:CreateTimer("uniqueTimerString3", {
      useGameTime = false,
      endTime = 0,
      callback = function()
        if npc:IsNull() then
          --[[print('thinker not exist',Time())
          print('glimpse_pos:',glimpse_pos)
          print('hero_pos:',active_hero:GetAbsOrigin())--]]
          --[[if glimpse_pos==active_hero:GetAbsOrigin() then
            if GLIMPLSE_SKILL=="ember_spirit_sleight_of_fist" or GLIMPLSE_SKILL=="sandking_burrowstrike" then
              if active_hero:IsMagicImmune() then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='disruptor_glimpse'})
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='disruptor_glimpse'})
              end
            else
              if active_hero:IsOutOfGame() then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='disruptor_glimpse'})
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='disruptor_glimpse'})
              end
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='disruptor_glimpse'})
          end--]]
          return nil
        else
          return FrameTime()
        end
        
      end
    })
    -- print("thinker_spawn:",npc:GetAbsOrigin())
    -- print("calc_spawn",hero_pos_table[#hero_pos_table])
    -- print("glimpse time:",glimpse_time)
    -- print("calc time:",calc_time)

  end
  if npc:GetUnitName()=="npc_dota_hero_disruptor" then

    SAD_DISRUPTOR=npc
  end


  local respawn_place = npc:GetAbsOrigin()
  --print(respawn_place.x,respawn_place.y)
  LAST_NPCSpawnedKeys=keys
end

function GameMode:_OnEntityKilled( keys )


  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then 
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( killerEntity:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
    end
  end

  GameMode._reentrantCheck = true
  GameMode:OnEntityKilled( keys )
  GameMode._reentrantCheck = false
  --hidden challange--
  if eulsGameState==1 then
    if killedUnit==pizduk then
      if pizduk:GetUnitName()=="npc_dota_hero_tiny" then
        --print('time to kill:',Time()-EUL_TRAINING_START_TIME)

      end
    end
  end
  -------------------------------ARMLET LOGIC---------------------------
  if ArmletTratiningState==1 then
    if killedUnit==active_hero then
      local aegis = CreateItem("item_aegis",active_hero,active_hero)
      active_hero:AddItem(aegis)
    end
  end
  -------------------------------GLIMPSE LOGIC---------------------------
  if glimpse_training_state==1 and killedUnit:GetName()=="npc_dota_hero_disruptor" then
    DISRUPTOR_KILLED=DISRUPTOR_KILLED+1
    if PIZDUK2_ALIVE==1 then
      if not pizduk2:IsNull() then
        pizduk2:RemoveSelf()
        PIZDUK2_ALIVE=0
      end
    end
    
    
    if GLIMPLSE_SKILL=="ember_spirit_sleight_of_fist" then
      if not pizduk:IsNull() then
        pizduk:RemoveSelf()
      end
    end
    
    if GLIMPSE_TP_MODE=="tpMode1" then
      --print(DISRUPTOR_KILLED)
      if (DISRUPTOR_KILLED+1)%5==0 then
        CustomGameEventManager:Send_ServerToAllClients("travel_reminder",{})
        disruptor_position=randomDisruptorPosition(4000,killerEntity)
        createSadDisruptor(disruptor_position,active_hero,1500)
        local distance = (disruptor_position - active_hero:GetAbsOrigin()):Length2D() 
        local direction = (disruptor_position - active_hero:GetAbsOrigin()):Normalized()
        local target_point = 0.90 * distance
        local target_point_vector = active_hero:GetAbsOrigin() + direction * target_point
        local target="npc_dota_creep_goodguys_melee"
        pizduk2=CreateUnitByName(target, target_point_vector, true, nil, nil, active_hero:GetTeam())
        pizduk2:SetMoveCapability(1)
        pizduk2:SetIdleAcquire(false)
        pizduk2:SetBaseHealthRegen(150)
        pizduk2:SetMaximumGoldBounty(0)
        pizduk2:SetMinimumGoldBounty(0)
        pizduk2:SetDeathXP(0)
        PIZDUK2_ALIVE=1
      else
        disruptor_position=randomDisruptorPosition(2000,killerEntity)
        createSadDisruptor(disruptor_position,active_hero,1500)
      end
    elseif GLIMPSE_TP_MODE=="tpMode2" then
      CustomGameEventManager:Send_ServerToAllClients("travel_reminder",{})
      disruptor_position=randomDisruptorPosition(4000,killerEntity)
      createSadDisruptor(disruptor_position,active_hero,1500)
      local distance = (disruptor_position - active_hero:GetAbsOrigin()):Length2D() 
      local direction = (disruptor_position - active_hero:GetAbsOrigin()):Normalized()
      local target_point = 0.90 * distance
      local target_point_vector = active_hero:GetAbsOrigin() + direction * target_point
      local target="npc_dota_creep_goodguys_melee"
      pizduk2=CreateUnitByName(target, target_point_vector, true, nil, nil, active_hero:GetTeam())
      pizduk2:SetMoveCapability(1)
      pizduk2:SetIdleAcquire(false)
      pizduk2:SetBaseHealthRegen(150)
      pizduk2:SetMaximumGoldBounty(0)
      pizduk2:SetMinimumGoldBounty(0)
      pizduk2:SetDeathXP(0)
      PIZDUK2_ALIVE=1
    else
      disruptor_position=randomDisruptorPosition(2000,killerEntity)
      createSadDisruptor(disruptor_position,active_hero,1500)
    end
    killedUnit:RemoveSelf() --Removing died dusruptor from game
  end
  -----timing logic
  

end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )
  

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- The ability/item used to kill, or nil if not killed by an item/ability
  local killerAbility = nil

  if keys.entindex_inflictor ~= nil then
    killerAbility = EntIndexToHScript( keys.entindex_inflictor )
  end
  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if LASTHIT_TRAINING==1 then
    sniperAIonUnitDead(killedUnit,killerEntity)
    if killedUnit:GetName()=="npc_dota_creep_lane" then
      local owner=killerEntity:GetOwner()
      --print("OWNER OF KILLER:",killerEntity:GetOwner():GetName())
      if killerEntity==active_hero or owner==active_hero then
        
        displayLHResult(1,killedUnit)
        
      else
        displayLHResult(0,killedUnit)
        
      end
      
    end
    


  end
  if eulsGameState==1 then
    if TIMING_TYPE==3 then
      Timers:CreateTimer(2, function()
        if pizduk:IsNull()~=true then
          pizduk:EmitSound("string1")
        end
      end)
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=5})
      EUL_CASTED=1
      EUL_SKILL_DMG_DONE=0
      EUL_CASTED_TIME=Time()
      EUL_DMG_DONE=0
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 5.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})
            --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=true, time=420})
            EUL_CASTED=0
          end
        end
      })
    end
    if TIMING_TYPE==4 then
      --[[pizduk:EmitSound("wk_reinc")
      Timers:CreateTimer(3, function()
        if pizduk:IsNull()~=true then
          pizduk:EmitSound("string2")
        end
      end)--]]
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=3})
      EUL_CASTED=1
      EUL_SKILL_DMG_DONE=0
      EUL_CASTED_TIME=Time()
      EUL_DMG_DONE=0
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 3.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
            --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=true, time=420})
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})
            EUL_CASTED=0
          end
        end
      })
    end
  end
  -- Put code here to handle when an entity gets killed
  -- if killedUnit:GetUnitName()=="npc_dota_earth_spirit_stone" then
  --   stones_list[keys.entindex_killed]=nil
  -- end
  if MAP_AIM_TRAINING==1 then
    if killedUnit:GetName()=="npc_dota_creep_lane" then
      --print('creep died')
      if killerEntity==nil then
        --print('because he was old')
        EmitGlobalSound('sproing')
        hero:EmitSound("sproing")
        AIM_COMBO=1
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=killedUnit:GetAbsOrigin().x,bady=killedUnit:GetAbsOrigin().y})
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_sun_strike'})
      end
    end
  end
  if REACTION_TRAINING==1 then
    print("killed:",killedUnit:GetName())
    if killedUnit:GetName()=="npc_dota_ward_base" or killedUnit:GetName()=="npc_dota_ward_base_truesight" then
      print('killer:',killerEntity:GetName())
      if killerEntity:GetName()=="npc_dota_ward_base" or killerEntity:GetName()=="npc_dota_ward_base_truesight" then
        print("ward killed himself")
        EmitGlobalSound('sproing')
        hero:EmitSound("sproing")
        AIM_COMBO=1
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=killedUnit:GetAbsOrigin().x,bady=killedUnit:GetAbsOrigin().y})
      else
        print('ward was killed by player')
        local mouse_pos=killerEntity:GetCursorPosition()
        local ward_pos=killedUnit:GetAbsOrigin()
        local lenght=(ward_pos-mouse_pos):Length()
        print('ward:',ward_pos)
        print('mouse:',mouse_pos)
        print('len: ',lenght)
        local aim_time
        local score
        local index_found
        --finding ward in pool
        for k,v in pairs(WARD_POOL) do
          if v[1]==keys.entindex_killed then
            index_found=k

            break
          end
        end
        aim_time=WARD_POOL[index_found][2]
        table.remove(WARD_POOL,index_found)
        AIM_COMBO=AIM_COMBO+1
        if AIM_COMBO>AIM_MAX_COMBO then
          AIM_MAX_COMBO=AIM_COMBO
        end
        score=math.ceil(100/(Time()-aim_time))*AIM_COMBO
        --calc avg
        table.insert(RESULTS_TABLE,Time()-aim_time)
        local avg_time=0
        for k,v in pairs(RESULTS_TABLE) do
          avg_time=avg_time+v
        end
        avg_time=avg_time/#RESULTS_TABLE
        AIM_AVG_TIME=avg_time
        AIM_SCORE=AIM_SCORE+score
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=Time()-aim_time,score=score,avg=avg_time,totalscore=AIM_SCORE,combo=AIM_COMBO})
        hero:EmitSound("frog")
        EmitGlobalSound("frog")
      end
      killedUnit:RemoveSelf()
    end
  end
  if MOVING_AIM_TRAINING==1 then
    print("killedUnit",killedUnit:GetUnitName())
    --if killedUnit:GetName()=="npc_dota_neutral_centaur_khan" then
      print("POGCHAMP")
      if killerEntity:GetUnitName()=="npc_dota_neutral_centaur_khan" then
        print("PEPEGA")
        EmitGlobalSound('sproing')
        hero:EmitSound("sproing")
        AIM_COMBO=1
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=killedUnit:GetAbsOrigin().x,bady=killedUnit:GetAbsOrigin().y})
      else
        print("EZY")
        local mouse_pos=killerEntity:GetCursorPosition()
        local ward_pos=killedUnit:GetAbsOrigin()
        local lenght=(ward_pos-mouse_pos):Length()
        print('ward:',ward_pos)
        print('mouse:',mouse_pos)
        print('len: ',lenght)
        local aim_time
        local score
        local index_found
        --finding ward in pool
        for k,v in pairs(WARD_POOL) do
          if v[1]==keys.entindex_killed then
            index_found=k

            break
          end
        end
        aim_time=WARD_POOL[index_found][2]
        table.remove(WARD_POOL,index_found)
        AIM_COMBO=AIM_COMBO+1
        if AIM_COMBO>AIM_MAX_COMBO then
          AIM_MAX_COMBO=AIM_COMBO
        end
        score=math.ceil(100/(Time()-aim_time))*AIM_COMBO
        --calc avg
        table.insert(RESULTS_TABLE,Time()-aim_time)
        local avg_time=0
        for k,v in pairs(RESULTS_TABLE) do
          avg_time=avg_time+v
        end
        avg_time=avg_time/#RESULTS_TABLE
        AIM_AVG_TIME=avg_time
        AIM_SCORE=AIM_SCORE+score
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=Time()-aim_time,score=score,avg=avg_time,totalscore=AIM_SCORE,combo=AIM_COMBO})
        hero:EmitSound("frog")
        EmitGlobalSound("frog")
      end
    --end
  end
end

function GameMode:OnPlayerChat(keys)
  local teamonly = keys.teamonly
  local userID = keys.userid
  --local playerID = self.vUserIds[userID]:GetPlayerID()

  --local text = keys.text
  --hero = self.vUserIds[userID]:GetAssignedHero()
  --medusaSnake(active_hero,3,2,)
  -- local castDelay=3
  -- local deathDelay=2
  -- local respawn_place = randomCirclePosition(tonumber(text),hero)
  -- local lenght=hero:GetAbsOrigin()-respawn_place
  -- local range=lenght:Length()
  -- local castpoint=0.1
  -- local castTime=(range-50)/500+castpoint
  -- local calcTime=(range-48)/500
  -- print("=======TEST=========")
  -- print("calculated range:", range)
  -- print("calculated castTime:",calcTime)
  -- local ability_name = "skywrath_mage_arcane_bolt"
  -- local caster_name = "npc_dota_hero_skywrath_mage"
  -- casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
end
--===============EVASION CHECK===============   npc_dota_observer_wards


--[[function markOrShip(enemy)
  local statusResistReduc=1-((enemy:GetBaseStrength()*0.15)/100)
  local x_mark_dur=4*statusResistReduc
  local ship_marker=(xmark_dur-ship_castpoint-ship_delay)*100
  if ship_marker>0 then
    return true
  else
    return false
  end
end--]]

function my_output(text)
  CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes=text})
end

function GameMode:TestCommand1()
  --local cmdPlayer = Convars:GetCommandClient()
  local cmdPlayer=PlayerResource:GetPlayer(0)
  --DeepPrintTable(cmdPlayer)
  active_hero = cmdPlayer:GetAssignedHero()
  local newHero=replaceHero(active_hero,"npc_dota_hero_antimage")
  --PlayerResource:ReplaceHeroWith(cmdPlayer:GetPlayerID(),"npc_dota_hero_pudge",0,1)
  --[[ for playerId = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      if PlayerResource:IsValidPlayerID(playerId) then
          -- This is your player's ID
          print("Player ID:", playerId)
          return playerId
      end
  end ]]
  --dodge:castSpellOnHero("npc_dota_hero_lina", "lina_light_strike_array")

  --[[ local kek=DotaDB:GetHeroByAbility("oracle_purifying_flames")
  print(kek) ]]
  --[[ DotaDB:GetAllHeroes() ]]
  --[[MORPH_INDEX_COUNTER=MORPH_INDEX_COUNTER+103
  morphHeroIteration()--]]
  --pos=active_hero:GetAbsOrigin()
  --[[local steam=PlayerResource:GetSteamID(cmdPlayer:GetPlayerID())
  print(tostring(steam))
  local item_config={}
  print(active_hero:GetItemInSlot(4))--]]
  --setItemConfig(active_hero,'aim3')
  --[[local config=getItemConfig(active_hero,'aim3')
  for k,v in pairs(config) do
    print(k,v)
  end--]]
  --print(config)
  --print('is it dedic',IsDedicatedServer())
  --DeepPrintTable(hidden_layer)
  --DeepPrintTable(abilityKV)
  --local kekus=DotaDB
  --kekus:test()
  
  --[[ward1=CreateUnitByName("npc_dota_observer_wards", pos+Vector(0,60,0), true, nil, nil, DOTA_TEAM_BADGUYS)
  ward1:SetRenderColor(0, 89, 255)
  ward2=CreateUnitByName("npc_dota_sentry_wards", pos+Vector(60,0,0), true, nil, nil, DOTA_TEAM_BADGUYS)--]]
  --[[MORPH_INDEX_COUNTER=MORPH_INDEX_COUNTER+1
  morphHeroIteration()
  DeepPrintTable(MORPH_HERO_LIST)--]]
  --[[local steam=PlayerResource:GetSteamID(cmdPlayer:GetPlayerID())
  local other={combo=11,avg=0.420}
  
  sendResult_v2('aim',tostring(steam),13370000000,other)--]]


  --ti8_taunt
  --[[print('animation:',active_hero:GetSequence())
  active_hero:StartGesture( ACT_DOTA_VICTORY )
  print('trying to play animation')
  CreateTempTreeWithModel(active_hero:GetAbsOrigin()+Vector(0,100,0), 5,"models/props_tree/ti7/ggbranch.vmdl")--]]


  --[[local mode = GameRules:GetGameModeEntity()
  local sign = ParticleManager:CreateParticle("particles/econ/events/ti8/msg_deny_ti8.vpcf", PATTACH_CUSTOMORIGIN, mode)
  ParticleManager:SetParticleControl(sign, 0, active_hero:GetAbsOrigin())
  ParticleManager:SetParticleControl(sign, 3, Vector(138, 43, 226))
  ParticleManager:SetParticleControl(sign, 4, Vector(30,0,0))
  ParticleManager:ReleaseParticleIndex(sign)--]]

--[[  Timers:CreateTimer(function()
      GameRules:SendCustomMessage('lol',DOTA_TEAM_GOODGUYS,1)
      return 1.0
    end
  )--]]
  --[[PlayerResource:ReplaceHeroWith(cmdPlayer:GetPlayerID(),"npc_dota_hero_pudge",0,1)
  active_hero = cmdPlayer:GetAssignedHero()
  active_hero:SetAbsOrigin(Vector(732.22778320313,-4061.9580078125,384))
  active_hero:SetBaseManaRegen(100)
  local item = CreateItem("item_ultimate_scepter", active_hero, active_hero)  
  active_hero:AddItem(item)
  local hook=active_hero:FindAbilityByName("pudge_meat_hook")
  hook:SetLevel(1)
  escapeUnit=CreateUnitByName("npc_dota_hero_earthshaker", Vector(1111.2917480469,-3905.3483886719,384), true, nil, nil, DOTA_TEAM_BADGUYS)
  escapeUnit:AddNewModifier(active_hero, nil, "modifier_bounty_hunter_track", {})
  escapeUnit:SetAttackCapability(0)
  escapeUnit:SetBaseHealthRegen(25)
  escapeUnit:SetBaseStrength(200)
  local travel = CreateItem("item_travel_boots", escapeUnit, escapeUnit)  
  escapeUnit:AddItem(travel)
  local ability_casted=0--]]

  
  --[[Timers:CreateTimer({
    useGameTime = false,
    endTime = 0,
    callback = function()
      if not escapeUnit:IsNull() then
          if hook:IsCooldownReady() and not hook:IsInAbilityPhase() then
            print('stop dodging')
            escapeUnit:Stop()
          end
          
        return FrameTime()
      else
        return nil
      end
    end
  })--]]






end

function sendResult_v2(mode,steam,score,other,log_id,ping)
  if CHEAT_MODE~=1 then
    local key=GetDedicatedServerKeyV2('dick')
    local result={}
    result['mode']=mode
    result['steam']=tostring(steam)
    result['score']=score
    result['other']=other
    local result_to_send=json.encode(result)
    my_output("data:"..result_to_send)
    local req = CreateHTTPRequestScriptVM('POST', CMB_SERVER)
    req:SetHTTPRequestHeaderValue("Auth-Token", key)
    --req:SetHTTPRequestHeaderValue("Accept", "application/json")
    req:SetHTTPRequestGetOrPostParameter("request","sendResult_v2")
    req:SetHTTPRequestGetOrPostParameter("data",result_to_send)
    if log_id~=nil then
      req:SetHTTPRequestGetOrPostParameter("log_id",log_id)
    end
    req:SetHTTPRequestGetOrPostParameter("ping",tostring(ping))
    req:Send(function(res)

      if res.StatusCode ~= 200 then

        my_output("Failed to contact server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
        my_output("Body:".. (res.Body or "nil"))
        if string.find(res.Body,"opendns") then
          my_output("looks like opendns shit happened. attempt to resend data after 0.5 sec.")
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 3,
            callback = function()
              sendResult_v2(mode,steam,score,other,log_id,ping)
            end
          })
        end
        
      else
        if string.find(res.Body,"opendns") then
          my_output("looks like opendns shit happened. attempt to resend data after 0.5 sec.")
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 3,
            callback = function()
              sendResult_v2(mode,steam,score,other,log_id,ping)
            end
          })
        else
          res_table=json.decode(res.Body)
          if res_table["msg"]=="highscore" then
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=1,mod=mode,score=res_table['score'],place=res_table['place'],total=res_table['total']})
          else
            CustomGameEventManager:Send_ServerToAllClients("result_popup",{highscore=0,mod=mode,score=res_table['score']})
          end
          my_output("Connected to leaderboard server "..res.StatusCode)
          my_output("Body:".. (res.Body or "nil"))
        end
      end

      if not res.Body then
        my_output("No result returned from server")
        my_output("Status Code:".. (res.StatusCode or "nil"))
      end

    end)
  else
    my_output("No requests in cheat mode")
  end
end




function empOrTornado(hero,enemy)
  local quas=hero:FindAbilityByName("invoker_quas")
  --[[local talent=hero:FindAbilityByName("special_bonus_unique_invoker_8")
  local talent_inc=1.25*talent:GetLevel()--]]
  local talent=nil
  local talent_inc=0
  local quasLvl=quas:GetLevel()
  local statusResistReduc=1-((enemy:GetBaseStrength()*0.15)/100)
  local distance=(hero:GetAbsOrigin()-enemy:GetAbsOrigin()):Length()
  local fullTornadoTime=INV_TORNADO_DUR[quasLvl]*statusResistReduc+((distance-INV_TORNADO_RADIUS)/INV_TORNADO_SPEED)+INV_CAST_POINT+talent_inc
  return fullTornadoTime
end

function CreateParticleCircle(ent, radius, particle_name, hPlayer)
  local particle
    if hPlayer == nil then
        particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, ent)
    else
        particle = ParticleManager:CreateParticleForPlayer(particle_name, PATTACH_ABSORIGIN_FOLLOW, ent, hPlayer)
    end


  ParticleManager:SetParticleControl(particle, 1, Vector(radius, 100, 100))
  
  return particle
end




function CreateParticleBox(min_a, max_a, particle_name, hPlayer)
  local particles = {}
  local particle
  particle = CreateParticleLine(Vector(min_a.x, min_a.y, 0), Vector(min_a.x, max_a.y, 0), particle_name, hPlayer)
  table.insert(particles, particle)
  particle = CreateParticleLine(Vector(min_a.x, min_a.y, 0), Vector(max_a.x, min_a.y, 0), particle_name, hPlayer)
  table.insert(particles, particle)
  particle = CreateParticleLine(Vector(max_a.x, min_a.y, 0), Vector(max_a.x, max_a.y, 0), particle_name, hPlayer)
  table.insert(particles, particle)
  particle = CreateParticleLine(Vector(max_a.x, max_a.y, 0), Vector(min_a.x, max_a.y, 0), particle_name, hPlayer)
  table.insert(particles, particle)
  return particles
end

function CreateParticleLine(a, b, particle_name, hPlayer)
  local particle
  if hPlayer == nil then
      particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, nil)
  else
      particle = ParticleManager:CreateParticleForPlayer(particle_name, PATTACH_WORLDORIGIN, nil, hPlayer)
  end
  ParticleManager:SetParticleControl(particle, 0, a)
  ParticleManager:SetParticleControl(particle, 1, b)
  return particle
end

function chargingBara(hero,id_string,delay,start_interval)
  local start_interval=5
  local bara_resp=randomCirclePosition(1200,hero)
  bara = CreateUnitByNameAsync("npc_dota_hero_spirit_breaker", bara_resp, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
    --unit:AddAbility(abilityName)
    unit:SetForwardVector((hero:GetOrigin() - bara_resp):Normalized())
    unit:SetIdleAcquire(false)
    unit:SetAttackCapability(0)
    unit:SetBaseHealthRegen(200)
    unit:SetBaseMagicalResistanceValue(60)
    local ability = unit:FindAbilityByName("spirit_breaker_charge_of_darkness")
    ability:SetLevel(4)
    local ability2 = unit:FindAbilityByName("spirit_breaker_greater_bash")
    ability2:SetLevel(4)
    -- local passivka2 = unit:FindAbilityByName("special_bonus_unique_spirit_breaker_2")
    -- passivka2:SetLevel(1)
    Timers:CreateTimer("bara_cycle_"..id_string, {
      useGameTime=true,
      endTime=delay,
      callback=function()
        if start_interval>2.5 then
          start_interval=start_interval-0.2
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
          function()
              unit:CastAbilityOnTarget(hero,ability,-1)
            end,
          0)
        unit:SetContextThink(DoUniqueString("move_to_resp"),function()  unit:SetAbsOrigin(randomCirclePosition(1200,hero)) end, 4)
        return start_interval
      end
    })
    
    return unit
  end)
  return bara
end


function ResetEvasionVars()
  MANTA_CURRENT_SKILL=""
  MANTA_HERO_HURT=0
  MANTA_HERO_HURT_TIME=0
  MANTA_CASTED=0
  MANTA_CASTED_TIME=0
  MANTA_SKILL_CASTED=0
  MANTA_HERO_HURT=0
end


function GameMode:OrderFilter(event)
  action_logging:OrderExecuted(event)
    --Check if the order is the glyph type
--[[    print("POSTUPIL PRIKAZ:",Time())
    DeepPrintTable( event )
    local tpscroll=EntIndexToHScript(event['entindex_ability'])--]]
--[[    print('is it item?',tpscroll:IsItem())
    print('it placed in slot number:',tpscroll:GetItemSlot())--]]
--[[    if event['order_type']==5 then
      local ability_index=event['entindex_ability']
      local ability=EntIndexToHScript(ability_index)
      local abilityname=ability:GetAbilityName()
      local cast_pos=Vector(event['position_x'],event['position_y'],event['position_z'])
      local caster=EntIndexToHScript(event['units']['0'])
      

    end--]]
    if CATCH_TRAINING==1 then
      skillshotOnSkillUsed(abilityname,caster,cast_pos)
      if event['order_type']==10 or event['order_type']==21 then
        if event['units']['0']~=escapeUnit:entindex() then
          skillshotNotUsing()
        end

      end
    end
    if event['order_type']==24 or event['order_type']==31 or event['order_type']==12 or event['order_type']==16 or event['order_type']==17 then 
      return false
    end
    if Convars:GetInt("tp_delay")>0 then
      local delay=Convars:GetInt("tp_delay")/1000
      local order_table=nil
      --position orders no ability
      if event['order_type']==1 or event['order_type']==3 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type'],
                    Position = Vector(event['position_x'],event['position_y'],event['position_z'])
                    }

      end
      --target orders no ability
      if event['order_type']==2 or event['order_type']==4 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type'],
                    TargetIndex = event['entindex_target']
                    }

      end
      --ability pos
      if event['order_type']==5 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type'],
                    Position = Vector(event['position_x'],event['position_y'],event['position_z']),
                    AbilityIndex = event['entindex_ability']
                    }

      end
      --ability target
      if event['order_type']==6 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type'],
                    TargetIndex = event['entindex_target'],
                    AbilityIndex = event['entindex_ability']
                    }

      end
      --ability no target
      if event['order_type']==8 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type'],
                    AbilityIndex = event['entindex_ability']
                    }
      end
      --ability toggle
      if event['order_type']==9 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type'],
                    AbilityIndex = event['entindex_ability']
                    }
      end
      --hold or stop
      if event['order_type']==10 or event['order_type']==21 then
        order_table={
                    UnitIndex = event['units']['0'],
                    OrderType = event['order_type']
                    }
      end
      --[[DeepPrintTable(order_table)--]]
      if order_table~=nil and event['issuer_player_id_const']~=-1 then
        Timers:CreateTimer({
          endTime = delay,
          callback = function()
            ExecuteOrderFromTable(order_table)
          end
        })
      end
      if event['issuer_player_id_const']==-1 then
        return true
      else
        return false
      end

    end

    --[[if INV_INVOKE_MODE==1 and event['order_type']==4 then
      local entCause=EntIndexToHScript(event['units']['0'])
      local entVictim=EntIndexToHScript(event['entindex_target'])
      if entCause:GetName()=="npc_dota_invoker_forged_spirit" then
        local containers=checkInvokeContainers("invoker_forge_spirit")
        if #containers>0 then
          local victimFound=0
          for k,v in pairs(containers) do
            if entVictim==v then
              victimFound=1
              removeFormInvokeContainer(v)
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Nice!',icon='invoker_forge_spirit'})
              CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
              if INV_BASIC_MODE==1 then
                invokeSpellCasted()
                invPUshSkill(nil)
              end
            end
          end
          if victimFound==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_forge_spirit'})
          end
        else
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_forge_spirit'})
        end
        if #containers==1 then
          entCause:ForceKill(false)
        end
      end
      if entCause:GetName()=="npc_dota_hero_invoker" and entCause:FindModifierByName("modifier_invoker_alacrity") then
        local containers=checkInvokeContainers("invoker_alacrity")
        if #containers>0 then
          local victimFound=0
          for k,v in pairs(containers) do
            if entVictim==v then
              victimFound=1
              removeFormInvokeContainer(v)
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_alacrity'})
              CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
              if INV_BASIC_MODE==1 then
                invokeSpellCasted()
                invPUshSkill(nil)
              end
            end
          end
          if victimFound==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_alacrity'})
          end
        else
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_alacrity'})
        end
        if #containers==1 then
          entCause:RemoveModifierByName("modifier_invoker_alacrity")
          entCause:SetAttackCapability(0)
          entCause:Stop()
        end
      end
    end--]]

--[[    if SS_TRAINING==1 and SS_HERO~=nil then

      for k,unit in pairs(event['units']) do

        local hUnit=EntIndexToHScript(unit)

        if hUnit==SS_HERO then

          if event['order_type']==1 or event['order_type']==2 or event['order_type']==3 or event['order_type']==29 then

            local checkPlace=isPointInSquare(SS_MINVEC,SS_MAXVEC,Vector(event['position_x'],event['position_y'],128))

            if checkPlace then
              return true
            else
              return false
            end
          end
          if event['order_type']==4 then 
            return false
          end
        end
      end
      


    end--]]
    --Return true by default to keep all other orders the same
      ----------------------------Manta training evasion check logic-------------------------------------
    if CustomGameState==1 then
      if event['entindex_ability']~=0 then
        local ability=EntIndexToHScript(event['entindex_ability'])
        local manta_skills={"item_manta","ember_spirit_sleight_of_fist","puck_phase_shift","storm_spirit_ball_lightning","bane_nightmare","naga_siren_mirror_image","monkey_king_mischief"}
        local abilityname
        if ability~=nil then
          abilityname=ability:GetAbilityName()
        end
        
        local ability_found=0
        for k,v in pairs(manta_skills) do
          if v==abilityname then
            ability_found=1
          end
        end
        if ability_found==1 then---------------PLAYER PRESSED MANTA
          --print("AAAAAAAA SUKA")
          MANTA_CASTED_TIME=Time()
          --print("MANTA_CASTED_TIME",MANTA_CASTED_TIME)
          if MANTA_HERO_HURT==1 then

          else
            --MANTA_CASTED=1
            
          end
          
        end
      end
    end
    if AlchemistTrainingState==1 then
      if event['entindex_ability']~=0 then
        local ability=EntIndexToHScript(event['entindex_ability'])
        if ability:GetAbilityName()=="item_manta" then---------------PLAYER PRESSED MANTA
          --print("AAAAAAAA SUKA")

          MANTA_CASTED_TIME=Time()
          --print("MANTA_CASTED_TIME",MANTA_CASTED_TIME)
          if ALCHE_HERO_HURT==1 then
            
            --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=true, time=420})
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})
          else
            --MANTA_CASTED=1
            --refreshItems2(active_hero)
          end
          
        end
      end
    end
    return true
end
function GameMode:AbilityTuning(event)
    --Check if the order is the glyph type
    --[[print("------------AbilityTuning:",Time())
    DeepPrintTable( event )--]]
    if SS_TRAINING==1 then
      if SS_SKILL_ID==17 then
        if event["value_name_const"]=="duration" then
          event["value"]=0.5
          --print('replaced!')
        end
      end
    end

    return true
end
function GameMode:ModifierGained(event)
    --[[print("------------ModCreated:",Time(),event['name_const'])
    DeepPrintTable( event )--]]
    if event['name_const']=="modifier_morphling_replicate_manager" then
      Timers:CreateTimer({
        endTime = 2,
        callback = function()
          local hero=EntIndexToHScript(event['entindex_parent_const'])
          --[[hero:RemoveModifierByName("modifier_morphling_replicate_manager")
          hero:RemoveModifierByName("modifier_morphling_replicate")
          print('removing replicate from',hero:GetUnitName())--]]
          --removeReplicateFromHero(hero)
        end
      })
    end
    if TESTING==1 then
      if event['entindex_parent_const']==ebalai:entindex() then
        print('time of mod:',Time())
        print(event['name_const'])

      end

    end
    if MANTA_CHALLENGE==1 then
      if event['name_const']=="modifier_axe_berserkers_call" then
        local victim=EntIndexToHScript(event['entindex_parent_const'])
        if victim:GetUnitName()=="npc_dummy_unit" then
          print('mod created:',event['name_const'],Time()-MANTA_DAMAGE_TIME)
          --CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='unit hurt: '..(Time()-MANTA_DAMAGE_TIME),icon='axe_berserkers_call'})
          MANTA_DAMAGE_TIME=Time()
          MANTA_SCORE_NOW=MANTA_SCORE_NOW+MANTA_SCORE_GROW
          print("MANTA_SCORE_NOW",MANTA_SCORE_NOW)
          if hero:FindModifierByName("modifier_manta_phase") then
            
            MANTA_SCORE=MANTA_SCORE+MANTA_SCORE_NOW*MANTA_COMBO
            MANTA_COMBO=MANTA_COMBO+1
            MANTA_LIVES=MANTA_LIVES+MANTA_GOOD_INCREMENT*MANTA_COMBO
            if MANTA_LIVES>4200 then
              MANTA_LIVES=4200
            end
            hero:SetHealth(MANTA_LIVES)
            CustomGameEventManager:Send_ServerToAllClients("upd_manta_values",{score=MANTA_SCORE,combo=MANTA_COMBO})
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='axe_berserkers_call'})
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='axe_berserkers_call'})
            MANTA_COMBO=1
            CustomGameEventManager:Send_ServerToAllClients("upd_manta_values",{score=MANTA_SCORE,combo=MANTA_COMBO})
            Timers:CreateTimer({
              endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
              callback = function()
                MANTA_LIVES=MANTA_LIVES-MANTA_FAIL_DECREMENT
                hero:SetHealth(MANTA_LIVES)
                hero:RemoveModifierByName("modifier_axe_berserkers_call")
                victim:RemoveModifierByName("modifier_axe_berserkers_call")
              end
            })
          end
        end
      end


    end
    
    if KUNNKA_TRAINING==1 then
      if event['name_const']=="modifier_kunkka_x_marks_the_spot" then
        MARKS_CASTED=1
        KUNNKA_TORRENT=0
        KUNNKA_TORRENT_TIME=0
        KUNNKA_RETURN=0
        KUNNKA_RETURN_TIME=0
        local pizduk=EntIndexToHScript(event['entindex_parent_const'])
        pizduk:SetContextThink(DoUniqueString("move_order"),
        function()
          ExecuteOrderFromTable({
            UnitIndex = pizduk:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = randomCirclePosition(2000,pizduk)
          })
        end,
        0) 

      end
      if KUNNKA_TYPE==1 then
        if event['name_const']=="modifier_kunkka_torrent" then
          KUNNKA_TORRENT=1
          if KUNNKA_RETURN==1 then
            local delay=Time()-KUNNKA_RETURN_TIME
            local displayDelay=math.floor(delay*1000)/1000
            if delay<0.25 then
              if delay==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect! Delay: '..displayDelay..' sec.',icon='pogchamp'})
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! Delay: '..displayDelay..' sec.',icon='kunkka_torrent'})
              end
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Delay: '..displayDelay..' sec.',icon='kunkka_torrent'})
            end
              KUNNKA_RETURN=0
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='kunkka_x_marks_the_spot'})
          end
        end
      end
      if KUNNKA_TYPE==2 then
        local targetUnit=EntIndexToHScript(event['entindex_parent_const'])
        if event['name_const']=="modifier_kunkka_x_marks_the_spot" then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          KUNNKA_SHIP_HIT=0
          KUNNKA_TORRENT_HIT=0
          KUNNKA_RETURN_END=0
          Timers:CreateTimer("uniqueTimerString389089", {
            useGameTime = false,
            endTime = FrameTime(),
            callback = function()
              if not targetUnit:IsNull() then
                if targetUnit:FindModifierByName("modifier_kunkka_x_marks_the_spot") then
                  KUNNKA_RETURN_END=Time()
                  return FrameTime()
                else
                  return nil
                end
              else
                return nil
              end
            end
          })
        end
        if event['name_const']=="modifier_stunned" then
          KUNNKA_SHIP_HIT=1
          KUNNKA_SHIP_END=0
          KUNNKA_SHIP_START=Time()
          Timers:CreateTimer("uniqueTimerString345343", {
            useGameTime = false,
            endTime = FrameTime(),
            callback = function()
              if not targetUnit:IsNull() then
                if targetUnit:FindModifierByName("modifier_stunned") then
                  KUNNKA_SHIP_END=Time()
                  return FrameTime()
                else
                  return nil
                end
              else
                return nil
              end
            end
          })
        end
        if event['name_const']=="modifier_kunkka_torrent" then
          KUNNKA_TORRENT_HIT=1
          KUNNKA_TORRENT_END=0
          KUNNKA_TORRENT_START=Time()
          Timers:CreateTimer("uniqueTimerString312312", {
            useGameTime = false,
            endTime = FrameTime(),
            callback = function()
              if not targetUnit:IsNull() then
                if targetUnit:FindModifierByName("modifier_kunkka_torrent") then
                  KUNNKA_TORRENT_END=Time()
                  return FrameTime()
                else
                  if KUNNKA_SHIP_HIT==1 then
                    local mark_ship_time=KUNNKA_SHIP_START-KUNNKA_RETURN_END
                    local ship_torrent_time=KUNNKA_TORRENT_START-KUNNKA_SHIP_END
                    local displayDelay1=math.floor(mark_ship_time*1000)/1000
                    local displayDelay2=math.floor(ship_torrent_time*1000)/1000
                    if mark_ship_time==0 and ship_torrent_time==0 then
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect! Delay: '..displayDelay1..' sec.',icon='pogchamp'})
                    else
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! Delay: '..displayDelay1..' sec.',icon='kunkka_ghostship'})
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! Delay: '..displayDelay2..' sec.',icon='kunkka_torrent'})
                    end

                  end
                  return nil
                end
              else
                return nil
              end
            end
          })
        end
      end
    end
    if CustomGameState==1 then
      if event['name_const']=="modifier_warlock_golem_permanent_immolation_debuff" then
        return false
      end
    end
    if SS_TRAINING==1 then
      --[[if event['name_const']=="modifier_pudge_meat_hook" then
        Timers:CreateTimer("uniqueTimerString3", {
          useGameTime = false,
          endTime = 0,
          callback = function()
            if EntIndexToHScript(event['entindex_parent_const']):FindModifierByName("modifier_pudge_meat_hook") then
              hook_end_time=Time()
              return FrameTime()
            else
              return nil
            end    
          end
        })
      end
      if event['name_const']=="modifier_pudge_dismember" then
        if hook_end_time~=nil then
          local result=Time()-hook_end_time
          print('time between mods:',result)
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Time:'..result,icon='pudge_dismember'})
        end
      end--]]
      local targetUnit=SS_TARGETS[event['entindex_parent_const']]
      if event['name_const']=="modifier_pudge_meat_hook" then
        Timers:CreateTimer("uniqueTimerString3", {
          useGameTime = false,
          endTime = 0,
          callback = function()
            if EntIndexToHScript(event['entindex_parent_const']):FindModifierByName("modifier_pudge_meat_hook") then
              return FrameTime()
            else
              
              RemakeTarget(targetUnit)
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='pudge_meat_hook'})
              return nil
            end    
          end
        })
        
      end
      if event['name_const']=="modifier_meepo_earthbind" then
        RemakeTarget(targetUnit)
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='meepo_earthbind'})
      end
      if event['name_const']=="modifier_invoker_ice_wall_slow_debuff" then
        RemakeTarget(targetUnit)
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_ice_wall'})
      end
      if event['name_const']=="modifier_windrunner_shackle_shot" then
        SS_SHACKLE_COUNT=SS_SHACKLE_COUNT+1
        if SS_SHACKLE_COUNT==2 then
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect!',icon='pogchamp'})
          SS_SHACKLE_COUNT=0
        end
        Timers:CreateTimer({
          endTime = 0.5,
          callback = function()
            RemakeTarget(targetUnit)
          end
        })
      end
      if event['name_const']=="modifier_phoenix_fire_spirit_burn" then
        RemakeTarget(targetUnit)
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='phoenix_fire_spirits'})
      end
      if event['name_const']=="modifier_stunned" then
        if EntIndexToHScript(event['entindex_ability_const']):GetAbilityName()=="windrunner_shackleshot" then
          Timers:CreateTimer({
            endTime = 0.5,
            callback = function()
              RemakeTarget(targetUnit)
            end
          })
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='windrunner_shackleshot'})
        end
      end
      if event['name_const']=="modifier_ember_spirit_searing_chains" then
        SS_CHAINS_COUNT=SS_CHAINS_COUNT+1
        if SS_CHAINS_COUNT==1 then
          Timers:CreateTimer({
            endTime = FrameTime(),
            callback = function()
              if SS_CHAINS_COUNT==2 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect!',icon='pogchamp'})
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='ember_spirit_searing_chains'})
              end
              SS_CHAINS_COUNT=0
            end
          })
        end
        Timers:CreateTimer({
          endTime = 0.5,
          callback = function()
            RemakeTarget(targetUnit)
          end
        })
      end
    end
--[[    if event['name_const']=="modifier_teleporting" then modifier_invoker_tornado
      event['duration']=2
    end--]]
    if INV_INVOKE_MODE==1 then
      if event['name_const']=="modifier_invoker_alacrity" and event['entindex_parent_const']==event['entindex_caster_const'] then
        local eroha=EntIndexToHScript(event['entindex_caster_const'])
        eroha:SetAttackCapability(1)
      end
      if event['name_const']=="modifier_invoker_deafening_blast_knockback" then
        local modOwner=EntIndexToHScript(event['entindex_parent_const'])
        --[[print(modOwner:GetName())--]]
        local pizduk=EntIndexToHScript(event['entindex_parent_const'])
        local move_pos
        if pizduk:GetUnitName()=="npc_dota_hero_earth_spirit" then
          move_pos=inv_pos1
        end
        if pizduk:GetUnitName()=="npc_dota_hero_ember_spirit" then
          move_pos=inv_pos2
        end
        if pizduk:GetUnitName()=="npc_dota_hero_storm_spirit" then
          move_pos=inv_pos3
        end
        pizduk:SetContextThink(DoUniqueString("move_order"),
        function()
          ExecuteOrderFromTable({
            UnitIndex = pizduk:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = move_pos
          })
        end,
        0) 
        local containers=checkInvokeContainers("invoker_deafening_blast")
        if #containers>0 then
          local victimFound=0
          for k,v in pairs(containers) do
            if modOwner==v then
              victimFound=1
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_deafening_blast'})
              if INV_CHALLENGE==1 then
                removeFormInvokeContainer(inv_earth)
                removeFormInvokeContainer(inv_fire)
                removeFormInvokeContainer(inv_storm)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                invChallangeSKill()
              else
                removeFormInvokeContainer(v)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
              end
              if INV_BASIC_MODE==1 then
                invokeSpellCasted()
                invPUshSkill(nil)
              end
            end
          end
          if victimFound==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_deafening_blast'})
          end
        else
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_deafening_blast'})
        end
      end
      if event['name_const']=="modifier_invoker_tornado" then
        local modOwner=EntIndexToHScript(event['entindex_parent_const'])
        --[[print(modOwner:GetName())--]]
        local containers=checkInvokeContainers("invoker_tornado")
        if #containers>0 then
          local victimFound=0
          for k,v in pairs(containers) do
            if modOwner==v then
              victimFound=1
              
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_tornado'})
              if INV_CHALLENGE==1 then
                removeFormInvokeContainer(inv_earth)
                removeFormInvokeContainer(inv_fire)
                removeFormInvokeContainer(inv_storm)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                invChallangeSKill()
              else
                removeFormInvokeContainer(v)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
              end
              if INV_BASIC_MODE==1 then
                invokeSpellCasted()
                invPUshSkill(nil)
              end
            end
          end
          if victimFound==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_tornado'})
          end
        else
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_tornado'})
        end
      end
    end

    if INVOKER_TRAINING==1 then
      if INV_PROCAST_TYPE==2 then
        if event['name_const']=="modifier_invoker_chaos_meteor_burn" then
          INV_BURN_COUNT=INV_BURN_COUNT+1
        end
        if event['name_const']=="modifier_invoker_deafening_blast_knockback" then
          INV_BLAST_CASTED=1
        end
        if event['name_const']=="modifier_projectile_vision" then
          INV_METEOR_LANDED_TIME=Time()
        end
      end
      if INV_PROCAST_TYPE==4 or INV_PROCAST_TYPE==5 then
        if event['name_const']=="modifier_invoker_chaos_meteor_burn" then
          INV_BURN_COUNT=INV_BURN_COUNT+1
        end
        if event['name_const']=="modifier_invoker_deafening_blast_knockback" then
          INV_BLAST_CASTED=1
        end
        if event['name_const']=="modifier_projectile_vision" then
          INV_METEOR_LANDED_TIME=Time()
        end
      end
      if INV_PROCAST_TYPE==3 then
        if event['name_const']=="modifier_invoker_deafening_blast_knockback" then
          INV_BLAST_CASTED=1
        end
        if event['name_const']=="modifier_invoker_chaos_meteor_burn" then
          INV_BURN_COUNT=INV_BURN_COUNT+1
        end
      end
    end
    if CustomGameState==1 then
      if event['name_const']=="modifier_medusa_stone_gaze_stone" then
        MANTA_MODIFIER_GAINED=Time()
      end
      if event['name_const']=="modifier_stunned" then
        MANTA_MODIFIER_GAINED=Time()
      end
      if event['name_const']=="modifier_axe_berserkers_call" then
        MANTA_MODIFIER_GAINED=Time()
      end
    end
    if eulsGameState==1 and EUL_CASTED==1 then
      if EUL_SKILL=="lion_impale" and event['name_const']=="modifier_lion_impale" then
        EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
        EUL_SKILL_DMG_DONE=1
        EUL_CASTED=0
        --print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
        --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
        local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})


      end
      if EUL_SKILL=="death_prophet_silence" and event['name_const']=="modifier_silence" then
        EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
        EUL_SKILL_DMG_DONE=1
        EUL_CASTED=0
        --print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
        --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
        local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
      end
      if EUL_SKILL=="nyx_assassin_spiked_carapace" and event['name_const']=="modifier_stunned" then
        EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
        EUL_SKILL_DMG_DONE=1
        EUL_CASTED=0
        --print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
        --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
        local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
      end
      if EUL_SKILL=="sandking_burrowstrike" and event['name_const']=="modifier_sandking_impale" then
        EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
        EUL_SKILL_DMG_DONE=1
        EUL_CASTED=0
        --print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
        --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
        local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
      end
      if EUL_SKILL=="kunkka_torrent" and event['name_const']=="modifier_kunkka_torrent" then
        EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
        EUL_SKILL_DMG_DONE=1
        EUL_CASTED=0
        --print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
        --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
        local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
      end
      if EUL_SKILL=="nyx_assassin_impale" and event['name_const']=="modifier_nyx_assassin_impale" then
        EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
        EUL_SKILL_DMG_DONE=1
        EUL_CASTED=0
        --print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
        local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
        --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
      end
    end
      ----------------------------Manta training evasion check logic-------------------------------------

    return true
end
function GameMode:TrackingProjectileFilter(event)

    --[[DeepPrintTable( event )--]]

    return true
end
function GameMode:GoldFilter(event)
 --[[   print("####gold filter####")
    DeepPrintTable( event )--]]

    --[[if LASTHIT_TRAINING==1 then
      return false
    else

      return true
    end--]]
    if LASTHIT_TRAINING==1 then
      return true
    else
      event['gold']=0
      print('TRY TO MOD GOLD')
      return true
    end
    
end
function GameMode:ExpFilter(event)
--[[    print("####exp filter####")
    DeepPrintTable( event )--]]
    event['experience']=0

    return true

end
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  --print("TIME BETWEEN CAST AND ILLUSIONS:",Time()-KEK_TIME)
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
  ---------------------manta training evasion logic----------------------

  if CustomGameState==2 then

  end
  if eulsGameState==1 then
    if TIMING_TYPE==1 or TIMING_TYPE==6 then
      if EUL_CASTED==1 then
        if (EntIndexToHScript(keys.original_entindex)==pizduk) then
          EUL_DAMAGE_TIME=Time()  
          EUL_DMG_DONE=1
        end
      end
    end
  end
end
 


function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  --print("OnNonPlayerUsedAbility time:",Time())
  DebugPrintTable(keys)
  local abilityname=  keys.abilityname
  if TIMING_START==1 then

    if abilityname==TIMING_BRATAN_ABILITY then
      print('trying to start timer')
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{})


    end



  end
  ----------------------------Manta training evasion check logic-------------------------------------
  if CustomGameState==2 then
    MANTA_SKILL_CASTED=1
    MANTA_SKILL_CASTED_TIME=Time()
    --print("######NON PLAYA USED ABULUTU ID=",MANTA_CURRENT_ID)
  end
  if eulsGameState==1 then
    --[[Timers:CreateTimer(3, function()
      if not pizduk:IsNull() then
        for i=0, 5, 1 do
        local current_item = pizduk:GetAbilityByIndex(i)
        if current_item ~= nil then
          current_item:EndCooldown()
          current_item:RefundManaCost()
      end
    end
    end
    end
    )--]]
    --refreshSkills(pizduk)

    if TIMING_TYPE==1 or TIMING_TYPE==6 then
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=barTime})
      EUL_CASTED=1
      EUL_SKILL_DMG_DONE=0
      EUL_CASTED_TIME=Time()
      EUL_DMG_DONE=0
      Timers:CreateTimer({
        useGameTime = false,
        endTime = barTime+0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
            
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})

            EUL_CASTED=0
          end
        end
      })
    end
    if TIMING_TYPE==2 then
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=4})
      EUL_CASTED=1
      EUL_SKILL_DMG_DONE=0
      EUL_CASTED_TIME=Time()
      EUL_DMG_DONE=0
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 4.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})

            EUL_CASTED=0
          end
        end
      })
    end
     if TIMING_TYPE==5 then
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=3})
      EUL_CASTED=1
      EUL_SKILL_DMG_DONE=0
      EUL_CASTED_TIME=Time()
      EUL_DMG_DONE=0
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 4.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})

            EUL_CASTED=0
          end
        end
      })
    end
  end
end

function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  -- DebugPrintTable(keys)
  print("ability used:",Time(),keys.abilityname)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
  glimpseOnSkillUsed(abilityname)
  if MORPH_TRAINING==1 then
    if abilityname=="morphling_morph_replicate" then
      if MORPHLING_ENT:FindModifierByName("modifier_morphling_replicate") then
        --removeReplicateFromHero(MORPHLING_ENT)
        Timers:CreateTimer({
        endTime = FrameTime(),
        callback = function()
          --local hero=EntIndexToHScript(event['entindex_parent_const'])
          --[[hero:RemoveModifierByName("modifier_morphling_replicate_manager")
          hero:RemoveModifierByName("modifier_morphling_replicate")
          print('removing replicate from',hero:GetUnitName())--]]
          removeReplicateFromHero(MORPHLING_ENT)
          local replicate=MORPHLING_ENT:FindAbilityByName('morphling_replicate')
          replicate:EndCooldown()
          replicate:RefundManaCost()
        end
      })
      end
    else
      local abil=MORPHLING_ENT:FindAbilityByName(abilityname)
      if not abil:IsNull() then
        abil:RefundManaCost()
      end
    end
    morphCheckForWaiting(abilityname)
  end
  if SS_TRAINING==1 then
    customCooldownController(keys)

  end
  if TIMING_TRAINING==1 then
    --if abilityname==TIMING_ABILITY then
      Timers:CreateTimer(2, function()
        if not TIMING_ABILITY_H:IsNull() then
          TIMING_ABILITY_H:EndCooldown()
          TIMING_ABILITY_H:RefundManaCost()
        end
      end
      )
    --end
  end
  if INVOKER_TRAINING==1 then

    local cooldown
    if abilityname=="invoker_invoke" then
      cooldown=2
    else
      cooldown=4
    end
    local hero=player:GetAssignedHero()
    local ss=hero:FindAbilityByName(abilityname)
    print('try to refresh after 1sec:',abilityname)
    Timers:CreateTimer(2, function()
      if not hero:IsNull() then
        print('actual try:',abilityname)
        ss:EndCooldown()
        ss:RefundManaCost()
      end
    end
    )
    
  end
  if INV_INVOKE_MODE==1 then
    local cooldown=1
    local hero=player:GetAssignedHero()
    local ss=hero:FindAbilityByName(abilityname)
    print('try to refresh after 1sec:',abilityname)
    Timers:CreateTimer(0.1, function()
      if not hero:IsNull() then
        print('actual try:',abilityname)
        ss:EndCooldown()
        ss:RefundManaCost()
      end
    end
    )

  end
  if MAP_AIM_TRAINING==1 then
    if abilityname=='invoker_sun_strike' then
      local hero=player:GetAssignedHero()
      local ss=hero:FindAbilityByName("invoker_sun_strike")
      ss:EndCooldown()
      ss:RefundManaCost()
    end
  end
  if MANTA_CHALLENGE==1 then
    if abilityname=="item_manta" then
      --StartCooldown(float flCooldown)
      --finding manta

      for i=0, 5, 1 do
        local item = hero:GetItemInSlot(i)
        if item~=nil then
          if item:GetAbilityName() == "item_manta" then
            item:StartCooldown(MANTA_CUSTOM_COOLDOWN)
          end
        end
      end

    end

  end
  if CustomGameState==1 then
    if abilityname=="item_manta" then
      --StartCooldown(float flCooldown)
      --finding manta
      local hero = player:GetAssignedHero()
      
        Timers:CreateTimer(3, function()
        if not hero:IsNull() then
          refreshItems2(hero)
          healHero(hero)
        end
      end
      )

    end

  end
  if abilityname=="item_manta" then
    KEK_TIME=Time()
  end
  if INV_INVOKE_MODE==1 then
    if INV_BASIC_MODE==1 then
      if abilityname=="invoker_quas" or abilityname=="invoker_wex" or abilityname=="invoker_exort" then
        INV_SPHERES_COUNTER=INV_SPHERES_COUNTER+1
        if #INV_SPHERE_CONTAINER<3 then
          table.insert(INV_SPHERE_CONTAINER,abilityname)
        else
          table.remove(INV_SPHERE_CONTAINER,1)
          table.insert(INV_SPHERE_CONTAINER,abilityname)
        end
      end
      
    end
  end
  if KUNNKA_TRAINING==1 then
    customCooldownController(keys)
    print('kunnka_type:',KUNNKA_TYPE)
    if KUNNKA_TYPE==1 then
      if abilityname=="kunkka_torrent" then
        if MARKS_CASTED==1 then
          CustomGameEventManager:Send_ServerToAllClients("glimpse_casted",{bartime=1.6,castpoint=0.3})

          Timers:CreateTimer({
            endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if KUNNKA_TORRENT==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='kunkka_torrent'})
              end
              --check for torrent hit
            end
          })
        end
      end
      if abilityname=="kunkka_return" then
        KUNNKA_RETURN=1
        KUNNKA_RETURN_TIME=Time()
      end
    end
    if KUNNKA_TYPE==2 then

    end
  end
  if INV_INVOKE_MODE==1 then
    if abilityname=="invoker_ghost_walk" then
      Timers:CreateTimer({
        endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          local victim_table=checkSpiritsForModifier("modifier_invoker_ghost_walk_enemy")
          local invoke_conatiners=checkInvokeContainers("invoker_ghost_walk")
          local challengeTrash={}
          local correct_victims=0
          for key,victim in pairs(victim_table) do
            print('victim #'..key,victim:GetUnitName())
            for key2,container in pairs(invoke_conatiners) do
              print('container #'..key2,container:GetUnitName())
              if container==victim then
                table.insert(challengeTrash,container)
                correct_victims=correct_victims+1
                removeFormInvokeContainer(victim)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(victim)})
                if INV_BASIC_MODE==1 then
                  invPUshSkill(nil)
                end
              end
            end
          end
          if INV_CHALLENGE==1 then
                invClearLine(challengeTrash)
                invChallangeSKill()
          end
          if #victim_table==correct_victims then
            if INV_BASIC_MODE==1 then
              invokeSpellCasted()
            end
            if correct_victims>1 then
              if correct_victims==3 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect cast! x'..correct_victims,icon='pogchamp'})
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! x'..correct_victims,icon='invoker_ghost_walk'})
              end
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_ghost_walk'})
            end
            
          else
            if correct_victims==0 then
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_ghost_walk'})
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You hit wrong target.',icon='invoker_ghost_walk'})
            end
          end
          --CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Unit count under ghost walk:'..#result,icon='pogchamp'})
        end
      })
    end
    if abilityname=="invoker_ice_wall" then
      Timers:CreateTimer({
        endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          --[[local victim_table=checkSpiritsForModifier("modifier_invoker_ice_wall_slow_debuff")
          local invoke_conatiners=checkInvokeContainers("invoker_ice_wall")
          local correct_victims=0
          local uncorrent_victims=0
          for key,victim in pairs(victim_table) do
            print('victim #'..key,victim)
            for key2,container in pairs(invoke_conatiners) do
              print('container #'..key2,container)
              if container==victim then
                correct_victims=correct_victims+1
                removeFormInvokeContainer(victim)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(victim)})
              else

              end
            end
          end
          if correct_victims==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_ice_wall'})
          end--]]
          --code from emp
          local targets=checkSpiritsForModifier("modifier_invoker_ice_wall_slow_debuff")
          local containers=checkInvokeContainers("invoker_ice_wall")
          local challengeTrash={}
          if #containers>0 then
            if #targets>0 then
              local validVictims=0
              for key1,container in pairs(containers) do
                for key2,target in pairs(targets) do
                  if container==target then
                    table.insert(challengeTrash,container)
                    removeFormInvokeContainer(container)
                    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(container)})
                    if INV_BASIC_MODE==1 then
                      invPUshSkill(nil)
                    end
                    validVictims=validVictims+1
                  end
                end
              end
              if INV_CHALLENGE==1 then
                invClearLine(challengeTrash)
                invChallangeSKill()
              end
              if validVictims~=0 then
                if INV_BASIC_MODE==1 then
                  invokeSpellCasted()
                end
                if validVictims>1 then
                  if validVictims==3 then
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect! x'..validVictims,icon='pogchamp'})
                  else
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect! x'..validVictims,icon='pogchamp'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_ice_wall'})
                end
                
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Wrong target.',icon='invoker_ice_wall'})
              end
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill missed.',icon='invoker_ice_wall'})
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_ice_wall'})
          end




          --[[if #victim_table==correct_victims then
            if correct_victims>1 then
              if correct_victims==3 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Perfect cast! x'..correct_victims,icon='pogchamp'})
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! x'..correct_victims,icon='invoker_ice_wall'})
              end
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_ice_wall'})
            end
            if INV_BASIC_MODE==1 then
              invPUshSkill(nil)
            end
          else
            if correct_victims==0 then
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='invoker_ice_wall'})
            else
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You hit wrong target.',icon='invoker_ice_wall'})
            end
          end--]]
          --CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Unit count under ghost walk:'..#result,icon='pogchamp'})
        end
      })
    end
  end
  if INVOKER_TRAINING==1 then
    --blast escaping
    if abilityname=="invoker_chaos_meteor" then
      INV_TINY_BLAST_ESCAPE=1
      hero = player:GetAssignedHero()
      local hero_dir=hero:GetForwardVector()
      local hero_pos=hero:GetAbsOrigin()
      local new_dir
      local time=0
      local color1=Vector(255,0,0)
      local color2=Vector(0,0,255)
      local color3=Vector(255,0,255)
      local ztest=true
      -- for i, v in ipairs(hero_pos_table) do 
      -- DebugDrawCircle(v, color, 20, 20, ztest, interval)
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 0, 
        callback = function()
          
          local pizduk_pos=pizduk:GetAbsOrigin()
          local pos1=(pizduk_pos-hero_pos):Normalized()
          local angle = (RotationDelta((VectorToAngles(pos1)), VectorToAngles(hero_dir)).y)
          if angle>0 then
            new_dir=Vector(hero_dir.y,-hero_dir.x,0)
          else
            new_dir=Vector(-hero_dir.y,hero_dir.x,0)
          end
          local move_point=pizduk_pos+new_dir*100
          --[[DebugDrawCircle(move_point, color2, 20, 20, ztest, 0.1)--]]
          pizduk:SetContextThink(DoUniqueString("cast_ability"),
          function()
            ExecuteOrderFromTable({
              UnitIndex = pizduk:entindex(),
              OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
              Position = move_point
            })
          end,
          0) 
          time=time+0.1
          if INV_TINY_BLAST_ESCAPE==0 then
            return nil
          else
            return 0.1
          end  
        end
      })
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          INV_TINY_BLAST_ESCAPE=0
        end
      })
    end

    if INV_PROCAST_TYPE==4 then
      hero=player:GetAssignedHero()
      if abilityname=="invoker_emp" then
        INV_EMP_DONE=0
        INV_EMP_CASTED=1
        local trndTime=empOrTornado(hero,pizduk)
        if trndTime<=2.9 then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 7, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_TORNADO_DONE==1 then
                if INV_EMP_DONE==1 then
                  local empDelay=INV_EMP_DONE_TIME - INV_TORNADO_DONE_TIME
                  if empDelay<0.25 then
                    if INV_BLAST_CASTED==1 then
                      local hero = player:GetAssignedHero()
                      local quas=hero:FindAbilityByName('invoker_quas')
                      local quas_lvl=quas:GetLevel()
                      if INV_AGSH==1 then
                        quas_lvl=quas_lvl+1
                      end
                      local max_burns=2+math.ceil(quas_lvl/2)
                      if INV_BURN_COUNT==0 then
                        local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Meteor missed!',icon='invoker_chaos_meteor'})
                      else
--[[                        if INV_BURN_COUNT<max_burns-1 then
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Small meteor damage: '..INV_BURN_COUNT..' Burn stacks.',icon='invoker_chaos_meteor'})
                        else--]]
                          local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! DMG:'..dispDmg..'. Burn stacks:'..INV_BURN_COUNT,icon='invoker_chaos_meteor'})
--[[                        end--]]
                      end
                    else
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You forgot blast!',icon='invoker_deafening_blast'})
                    end
                  else
                    local displayDelay=math.floor(empDelay*1000)/1000
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! EMP delay is:'..displayDelay..'sec.',icon='invoker_emp'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! EMP missed!',icon='invoker_emp'})
                end
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Tornado missed!',icon='invoker_tornado'})
              end
              INV_TORNADO_DONE=0
              INV_TORNADO_DONE_TIME=0
              INV_EMP_DONE=0
              INV_EMP_DONE_TIME=0
              INV_BLAST_CASTED=0
              INV_BURN_COUNT=0
              INV_TOTAL_DAMAGE=0
            end
          })
        end
      end
      if abilityname=="invoker_tornado" then
        INV_TORNADO_DONE=0
        INV_TORNADO_CASTED=1
        local trndTime=empOrTornado(hero,pizduk)
        if trndTime>2.9 then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 7, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_TORNADO_DONE==1 then
                if INV_EMP_DONE==1 then
                  local empDelay=INV_EMP_DONE_TIME - INV_TORNADO_DONE_TIME
                  if empDelay<0.25 then
                    if INV_BLAST_CASTED==1 then
                      local hero = player:GetAssignedHero()
                      local quas=hero:FindAbilityByName('invoker_quas')
                      local quas_lvl=quas:GetLevel()
                      if INV_AGSH==1 then
                        quas_lvl=quas_lvl+1
                      end
                      local max_burns=2+math.ceil(quas_lvl/2)
                      if INV_BURN_COUNT==0 then
                        local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Meteor missed!',icon='invoker_chaos_meteor'})
                      else
   --[[                     if INV_BURN_COUNT<max_burns-1 then
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Small meteor damage: '..INV_BURN_COUNT..' Burn stacks.',icon='invoker_chaos_meteor'})
                        else--]]
                          local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! DMG:'..dispDmg..'. Burn stacks:'..INV_BURN_COUNT,icon='invoker_chaos_meteor'})
--[[                        end--]]
                      end
                    else
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You forgot blast!',icon='invoker_deafening_blast'})
                    end
                  else
                    local displayDelay=math.floor(empDelay*1000)/1000
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! EMP delay is:'..displayDelay..'sec.',icon='invoker_emp'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! EMP missed!',icon='invoker_emp'})
                end
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Tornado missed!',icon='invoker_tornado'})
              end
              INV_TORNADO_DONE=0
              INV_TORNADO_DONE_TIME=0
              INV_EMP_DONE=0
              INV_EMP_DONE_TIME=0
              INV_BLAST_CASTED=0
              INV_BURN_COUNT=0
              INV_TOTAL_DAMAGE=0
            end
          })
        end
      end

    end
    if INV_PROCAST_TYPE==5 then
      hero=player:GetAssignedHero()
      if abilityname=="invoker_sun_strike" then
        INV_EMP_DONE=0
        INV_EMP_CASTED=1
        local trndTime=empOrTornado(hero,pizduk)
        if trndTime<=1.75 then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 7, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_TORNADO_DONE==1 then
                if INV_SUNSTRIKE_DONE==1 then
                  local empDelay=INV_SUNSTRIKE_TIME - INV_TORNADO_DONE_TIME
                  if empDelay<0.25 then
                    if INV_BLAST_CASTED==1 then
                      local hero = player:GetAssignedHero()
                      local quas=hero:FindAbilityByName('invoker_quas')
                      local quas_lvl=quas:GetLevel()
                      if INV_AGSH==1 then
                        quas_lvl=quas_lvl+1
                      end
                      local max_burns=2+math.ceil(quas_lvl/2)
                      if INV_BURN_COUNT==0 then
                        local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Meteor missed!',icon='invoker_chaos_meteor'})
                      else
--[[                        if INV_BURN_COUNT<max_burns-1 then
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Small meteor damage: '..INV_BURN_COUNT..' Burn stacks.',icon='invoker_chaos_meteor'})
                        else--]]
                          local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! DMG:'..dispDmg..'. Burn stacks:'..INV_BURN_COUNT,icon='invoker_chaos_meteor'})
--[[                        end--]]
                      end
                    else
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You forgot blast!',icon='invoker_deafening_blast'})
                    end
                  else
                    local displayDelay=math.floor(empDelay*1000)/1000
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Sunstrike delay is:'..displayDelay..'sec.',icon='invoker_sun_strike'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Sunstrike missed!',icon='invoker_sun_strike'})
                end
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Tornado missed!',icon='invoker_tornado'})
              end
              INV_TORNADO_DONE=0
              INV_TORNADO_DONE_TIME=0
              INV_EMP_DONE=0
              INV_EMP_DONE_TIME=0
              INV_BLAST_CASTED=0
              INV_BURN_COUNT=0
              INV_TOTAL_DAMAGE=0
            end
          })
        end
      end
      if abilityname=="invoker_tornado" then
        INV_TORNADO_DONE=0
        INV_TORNADO_CASTED=1
        local trndTime=empOrTornado(hero,pizduk)
        if trndTime>1.75 then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 7, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_TORNADO_DONE==1 then
                if INV_SUNSTRIKE_DONE==1 then
                  local empDelay=INV_SUNSTRIKE_TIME - INV_TORNADO_DONE_TIME
                  if empDelay<0.25 then
                    if INV_BLAST_CASTED==1 then
                      local hero = player:GetAssignedHero()
                      local quas=hero:FindAbilityByName('invoker_quas')
                      local quas_lvl=quas:GetLevel()
                      if INV_AGSH==1 then
                        quas_lvl=quas_lvl+1
                      end
                      local max_burns=2+math.ceil(quas_lvl/2)
                      if INV_BURN_COUNT==0 then
                        local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Meteor missed!',icon='invoker_chaos_meteor'})
                      else
--[[                        if INV_BURN_COUNT<max_burns-1 then
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Small meteor damage: '..INV_BURN_COUNT..' Burn stacks.',icon='invoker_chaos_meteor'})
                        else--]]
                          local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! DMG:'..dispDmg..'. Burn stacks:'..INV_BURN_COUNT,icon='invoker_chaos_meteor'})
--[[                        end--]]
                      end
                    else
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You forgot blast!',icon='invoker_deafening_blast'})
                    end
                  else
                    local displayDelay=math.floor(empDelay*1000)/1000
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Sunstrike delay is:'..displayDelay..'sec.',icon='invoker_sun_strike'})
                  end
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Sunstrike missed!',icon='invoker_sun_strike'})
                end
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Tornado missed!',icon='invoker_tornado'})
              end
              INV_TORNADO_DONE=0
              INV_TORNADO_DONE_TIME=0
              INV_EMP_DONE=0
              INV_EMP_DONE_TIME=0
              INV_BLAST_CASTED=0
              INV_BURN_COUNT=0
              INV_TOTAL_DAMAGE=0
            end
          })
        end
      end

    end

    if INV_PROCAST_TYPE==3 then
      if abilityname=="invoker_tornado" then
        CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
        INV_BURN_COUNT=0
        INV_TOTAL_DAMAGE=0
        INV_BLAST_CASTED=0
        Timers:CreateTimer({
        useGameTime = false,
        endTime = 6, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if INV_BLAST_CASTED==1 then
            local hero = player:GetAssignedHero()
            local quas=hero:FindAbilityByName('invoker_quas')
            local quas_lvl=quas:GetLevel()
            if INV_AGSH==1 then
              quas_lvl=quas_lvl+1
            end
            local max_burns=2+math.ceil(quas_lvl/2)
            if INV_BURN_COUNT==0 then
              local dispDmg=math.floor(INV_TOTAL_DAMAGE)
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Meteor missed!',icon='invoker_chaos_meteor'})
            else
--[[              if INV_BURN_COUNT<max_burns-1 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Small meteor damage: '..INV_BURN_COUNT..' Burn stacks.',icon='invoker_chaos_meteor'})
              else--]]
                local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! DMG:'..dispDmg..'. Burn stacks:'..INV_BURN_COUNT,icon='invoker_chaos_meteor'})
--[[              end--]]
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You forgot Blast.',icon='invoker_deafening_blast'})
          end

        end
      })
      end
    end

    if INV_PROCAST_TYPE==2 then
      if abilityname=="item_cyclone" then
        CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
        INV_EUL_CASTED=1
        INV_EUL_DONE=0
        INV_BURN_COUNT=0
        INV_TOTAL_DAMAGE=0
        INV_METEOR_LANDED_TIME=0
        INV_SUNSTRIKE_DONE=0
        INV_BLAST_CASTED=0
        Timers:CreateTimer({
            useGameTime = false,
            endTime = 6, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_SUNSTRIKE_DONE==1 then
                if INV_SUNSTRIKE_TIME-INV_EUL_DMG_TIME<=0.25 then
                  if INV_BLAST_CASTED==1 then
                    local hero = player:GetAssignedHero()
                    local quas=hero:FindAbilityByName('invoker_quas')
                    local quas_lvl=quas:GetLevel()
                    if INV_AGSH==1 then
                      quas_lvl=quas_lvl+1
                    end
                    local max_burns=2+math.ceil(quas_lvl/2)
                    if INV_BURN_COUNT==0 then
                      local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                      CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Meteor missed!',icon='invoker_chaos_meteor'})
                    else
--[[                      if INV_BURN_COUNT<max_burns-1 then
                        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Small meteor damage: '..INV_BURN_COUNT..' Burn stacks.',icon='invoker_chaos_meteor'})
                      else--]]
                        local dispDmg=math.floor(INV_TOTAL_DAMAGE)
                        CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! DMG:'..dispDmg..'. Burn stacks:'..INV_BURN_COUNT,icon='invoker_chaos_meteor'})
--[[                      end--]]
                    end
                  else
                    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Blast missed!',icon='invoker_deafening_blast'})
                  end
                else
                  local dispDelay=math.floor((INV_SUNSTRIKE_TIME-INV_EUL_DMG_TIME)*1000)/1000
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Sunstrike late: '..dispDelay..' sec.',icon='invoker_sun_strike'})
                end
              else
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Sunstrike missed!',icon='invoker_sun_strike'})
              end
              INV_SUNSTRIKE_DONE=0
              INV_BURN_COUNT=0
              INV_TOTAL_DAMAGE=0
              INV_METEOR_LANDED_TIME=0
              INV_EUL_DMG_TIME=0 
              INV_BLAST_CASTED=0
            end
          })
      end
    end
    if INV_PROCAST_TYPE==1 then
      hero=player:GetAssignedHero()
      if abilityname=="invoker_emp" then
        INV_EMP_DONE=0
        INV_EMP_CASTED=1
        local trndTime=empOrTornado(hero,pizduk)
        if trndTime<=2.9 then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 3.2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_EMP_CASTED==1 and INV_EMP_DONE==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! EMP missed.',icon='invoker_emp'})
                INV_TORNADO_DONE=0
                INV_EMP_DONE=0
                INV_TORNADO_CASTED=0
                INV_EMP_CASTED=0
              end
              --asdasdasdasdasdasdasd
            end
          })
        end
      end
      if abilityname=="invoker_tornado" then
        INV_TORNADO_DONE=0
        INV_TORNADO_CASTED=1
        local trndTime=empOrTornado(hero,pizduk)
        if trndTime>2.9 then
          CustomGameEventManager:Send_ServerToAllClients("invoker_timer_start",{})
          Timers:CreateTimer({
            useGameTime = false,
            endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if INV_EMP_CASTED==1 and INV_EMP_DONE==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! EMP missed.',icon='invoker_emp'})
                INV_TORNADO_DONE=0
                INV_EMP_DONE=0
                INV_TORNADO_CASTED=0
                INV_EMP_CASTED=0
              end
              --asdasdasdasdasdasdasd
            end
          })
        end
      end
    end
  end
  if AlchemistTrainingState==1 then
    if abilityname=="alchemist_unstable_concoction" then
      --customCooldownController(keys)
      
      CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=5.5})
      ALCHE_ABILITY_TIME=Time()
      ALCHE_BANKA_USED=1
      ALCHE_HERO_HURT=0
      Timers:CreateTimer({
        useGameTime = false,
        endTime = 6, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          if ALCHE_HERO_HURT==0 then

            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='pepega'})
          end
        end
      })
    end
  end

  if eulsGameState==1 then

    customCooldownController(keys)
    --------------------------------------------------------------------------------bloodbath logic
    if EUL_SKILL=="bloodseeker_blood_bath" and TIMING_TYPE==0 then
      if abilityname=="bloodseeker_blood_bath" then
        CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=2.6})
      end
      if abilityname=="item_cyclone" then
        EUL_CASTED=1
        EUL_SKILL_DMG_DONE=0
        EUL_CASTED_TIME=Time()
        EUL_DMG_DONE=0
        Timers:CreateTimer({
            useGameTime = false,
            endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
              if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})
                EUL_CASTED=0
              end
            end
          })
      end
      --------------------------------------------------------------------------------bloodbath logic end
    else
      if abilityname=="item_cyclone" then
        EUL_CASTED=1
        EUL_SKILL_DMG_DONE=0
        EUL_CASTED_TIME=Time()
        EUL_DMG_DONE=0
        CustomGameEventManager:Send_ServerToAllClients("eul_casted",{time=2.5})
        Timers:CreateTimer({
          useGameTime = false,
          endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
          callback = function()
            if EUL_SKILL_DMG_DONE==0 and EUL_CASTED==1 then
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})
              EUL_CASTED=0
            end
          end
        })
      end
      -- if abilityname=="death_prophet_silence" and EUL_CASTED==1 then
      --   if EUL_DMG_DONE==1 then
      --     EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
      --     EUL_SKILL_DMG_DONE=1
      --     EUL_CASTED=0
      --     CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
      --   else
      --     CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=true, time=420})
      --   end
      -- end
    end
  end
  -----------------------------------------Manta evasion checker logic
  if CustomGameState==2 then


  end
  if glimpse_v2_training_state==1 then
    if abilityname=="item_manta" then
      local hero = player:GetAssignedHero()
      Timers:CreateTimer(3, function()
          refreshItems2(active_hero)
          healHero(active_hero)
        end
        )
      
    end
  end
end


function GameMode:OnEntityHurt(keys)
  DebugPrint("[BAREBONES] Entity Hurt")
  DebugPrintTable(keys)
  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)
    if CustomGameState==1 then
      if entVictim==active_hero then
        MANTA_HERO_HURT_TIME=Time()
      end
    end
    local damagingAbility = nil
    if LASTHIT_TRAINING==1 then
      sniperAIonUnitHurt(entCause,entVictim,victim_hp)

      local victim_hp=entVictim:GetHealth()
      local victim_armor=entVictim:GetPhysicalArmorValue(false)
      --print('victim armor:',victim_armor)
      local dmg_multiplier=1-(0.05*victim_armor/(1+0.05*math.abs(victim_armor)))
      if victim_hp<=LASTHIT_MIN_DMG*dmg_multiplier then
        addLHCreepToTable(entVictim)
        
      end
--[[      if entCause==SN_AI_SNIPER then
        SN_AI_SNIPER:Stop()
      end--]]

      if entVictim==SN_AI_SNIPER then
        --print(entCause:GetUnitName())
        if entCause:GetUnitName()=="npc_dota_creep_goodguys_melee" or entCause:GetUnitName()=="npc_dota_creep_goodguys_ranged" or entCause:GetUnitName()=="npc_dota_goodguys_tower1_mid" then
          BOT_REWARD=0
        end
      end 
    end
    if eulsGameState==1 then
      if entVictim==pizduk then
        --[[local attackSkill=EntIndexToHScript(keys.entindex_inflictor)
        print ('pizda ot:',attackSkill:GetAbilityName())--]]
        Timers:CreateTimer(FrameTime(), function()
          if not pizduk:IsNull() then
            pizduk:AddNewModifier(pizduk, nil, "modifier_treant_living_armor", {})

          end
        end
        )
      end

    end
    if INV_INVOKE_MODE==1 then
      if entCause:GetName()=="npc_dota_invoker_forged_spirit" then
        local containers=checkInvokeContainers("invoker_forge_spirit")
        local challengeTrash={}
        if #containers>0 then
          local victimFound=0
          for k,v in pairs(containers) do
            if entVictim==v then
              table.insert(challengeTrash,container)
              victimFound=1
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Nice!',icon='invoker_forge_spirit'})
              if INV_CHALLENGE==1 then
                removeFormInvokeContainer(inv_earth)
                removeFormInvokeContainer(inv_fire)
                removeFormInvokeContainer(inv_storm)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                invChallangeSKill()
              else
                removeFormInvokeContainer(v)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
              end
              if INV_BASIC_MODE==1 then
                invokeSpellCasted()
                invPUshSkill(nil)
              end
            end
          end
--[[          if INV_CHALLENGE==1 then
            invClearLine(challengeTrash)
          end--]]
          if victimFound==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_forge_spirit'})
          end
        else
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_forge_spirit'})
        end
        if #containers==1 then
          entCause:ForceKill(false)
        end
      end
      if entCause:GetName()=="npc_dota_hero_invoker" and keys.entindex_inflictor == nil then
        local containers=checkInvokeContainers("invoker_alacrity")
        if #containers>0 then
          local victimFound=0
          for k,v in pairs(containers) do
            if entVictim==v then
              victimFound=1

              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_alacrity'})
              if INV_CHALLENGE==1 then
                removeFormInvokeContainer(inv_earth)
                removeFormInvokeContainer(inv_fire)
                removeFormInvokeContainer(inv_storm)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                invChallangeSKill()
              else
                removeFormInvokeContainer(v)
                CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
              end
              if INV_BASIC_MODE==1 then
                invokeSpellCasted()
                invPUshSkill(nil)
              end
            end
          end
          if victimFound==0 then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_alacrity'})
          end
        else
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_alacrity'})
        end
        if #containers==1 then
          entCause:RemoveModifierByName("modifier_invoker_alacrity")
          entCause:SetAttackCapability(0)
          entCause:Stop()
        end
      end
    end
    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
      --print(damagingAbility:GetAbilityName(),Time(),EUL_CASTED)
      --print("hero hurt:",Time(),damagingAbility:GetAbilityName())
      if MANTA_CHALLENGE==1 then
        --print("unit hurt:",entVictim:GetUnitName(),damagingAbility:GetAbilityName(),Time())
        if entVictim:GetUnitName()=="npc_dummy_unit" then
          print('unit hurt:',damagingAbility:GetAbilityName(),Time()-MANTA_DAMAGE_TIME)
          --CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='unit hurt: '..(Time()-MANTA_DAMAGE_TIME),icon=damagingAbility:GetAbilityName()})
          MANTA_DAMAGE_TIME=Time()
          MANTA_SCORE_NOW=MANTA_SCORE_NOW+MANTA_SCORE_GROW
          print("MANTA_SCORE_NOW",MANTA_SCORE_NOW)
          if hero:FindModifierByName("modifier_manta_phase") then
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon=damagingAbility:GetAbilityName()})
            
            MANTA_SCORE=MANTA_SCORE+MANTA_SCORE_NOW*MANTA_COMBO
            MANTA_COMBO=MANTA_COMBO+1
            MANTA_LIVES=MANTA_LIVES+MANTA_GOOD_INCREMENT*MANTA_COMBO
            if MANTA_LIVES>4200 then
              MANTA_LIVES=4200
            end
            hero:SetHealth(MANTA_LIVES)
            CustomGameEventManager:Send_ServerToAllClients("upd_manta_values",{score=MANTA_SCORE,combo=MANTA_COMBO})
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon=damagingAbility:GetAbilityName()})
            MANTA_COMBO=1
            CustomGameEventManager:Send_ServerToAllClients("upd_manta_values",{score=MANTA_SCORE,combo=MANTA_COMBO})
            Timers:CreateTimer({
              endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
              callback = function()
                MANTA_LIVES=MANTA_LIVES-MANTA_FAIL_DECREMENT
                hero:SetHealth(MANTA_LIVES)
                hero:Purge(false,true,false,true,false)
                entVictim:Purge(false,true,false,true,false)
              end
            })
          end
        end

      end
      if SS_TRAINING==1 then
        if damagingAbility:GetAbilityName()=="ancient_apparition_ice_blast" then
          if keys.damage>100 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='ancient_apparition_ice_blast'})
          end
        end
        if damagingAbility:GetAbilityName()=="rattletrap_hookshot" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='rattletrap_hookshot'})
          end
        end
        if damagingAbility:GetAbilityName()=="earth_spirit_boulder_smash" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='earth_spirit_boulder_smash'})
          end
        end
        if damagingAbility:GetAbilityName()=="invoker_sun_strike" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='invoker_sun_strike'})
          end
        end
        if damagingAbility:GetAbilityName()=="mirana_arrow" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='mirana_arrow'})
          end
        end
        if damagingAbility:GetAbilityName()=="nyx_assassin_impale" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='nyx_assassin_impale'})
          end
        end
        if damagingAbility:GetAbilityName()=="nyx_impale" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='nyx_impale'})
          end
        end
        if damagingAbility:GetAbilityName()=="nevermore_shadowraze1" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='nevermore_shadowraze1'})
          end
        end
        if damagingAbility:GetAbilityName()=="nevermore_shadowraze2" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='nevermore_shadowraze2'})
          end
        end
        if damagingAbility:GetAbilityName()=="nevermore_shadowraze3" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='nevermore_shadowraze3'})
          end
        end
        if damagingAbility:GetAbilityName()=="windrunner_powershot" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='windrunner_powershot'})
          end
        end
        if damagingAbility:GetAbilityName()=="wisp_spirits" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='wisp_spirits'})
          end
        end
        if damagingAbility:GetAbilityName()=="puck_illusory_orb" then
          if keys.damage>10 then
            RemakeTarget(entVictim)
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='wisp_spirits'})
          end
        end
      end
      if INV_INVOKE_MODE==1 then

        
        if damagingAbility:GetAbilityName()=="invoker_cold_snap" then
          local containers=checkInvokeContainers("invoker_cold_snap")
          local challengeTrash={}
          if #containers>0 then
            local victimFound=0
            for k,v in pairs(containers) do
              if entVictim==v then
                table.insert(challengeTrash,container)
                victimFound=1
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Nice!',icon='invoker_cold_snap'})
                if INV_CHALLENGE==1 then
                  removeFormInvokeContainer(inv_earth)
                  removeFormInvokeContainer(inv_fire)
                  removeFormInvokeContainer(inv_storm)
                  CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=0})
                  CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=1})
                  CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=2})
                  invChallangeSKill()
                else
                  removeFormInvokeContainer(v)
                  CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=convertSpiritToJSRow(v)})
                end
                if INV_BASIC_MODE==1 then
                  invokeSpellCasted()
                  invPUshSkill(nil)
                end
              end
            end
            if victimFound==0 then
              CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Skill was casted on wrong target!',icon='invoker_cold_snap'})
            end
          else
            CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You should not use this skill right now!',icon='invoker_cold_snap'})
          end
          entVictim:RemoveModifierByName("modifier_invoker_cold_snap")
        end
      end
      if INVOKER_TRAINING==1 then
        if INV_PROCAST_TYPE==4 then
          INV_TOTAL_DAMAGE=INV_TOTAL_DAMAGE+keys.damage
          if damagingAbility:GetAbilityName()=="invoker_tornado" then
            INV_TORNADO_DONE=1
            INV_TORNADO_DONE_TIME=Time()
          end
          if damagingAbility:GetAbilityName()=="invoker_emp" then
            INV_EMP_DONE=1
            INV_EMP_DONE_TIME=Time()
          end
        end
        if INV_PROCAST_TYPE==5 then
          INV_TOTAL_DAMAGE=INV_TOTAL_DAMAGE+keys.damage
          if damagingAbility:GetAbilityName()=="invoker_tornado" then
            INV_TORNADO_DONE=1
            INV_TORNADO_DONE_TIME=Time()
          end
          if damagingAbility:GetAbilityName()=="invoker_sun_strike" then
            INV_SUNSTRIKE_DONE=1
            INV_SUNSTRIKE_TIME=Time()
          end
        end
        if INV_PROCAST_TYPE==3 then
          INV_TOTAL_DAMAGE=INV_TOTAL_DAMAGE+keys.damage
        end
        if INV_PROCAST_TYPE==2 then
          INV_TOTAL_DAMAGE=INV_TOTAL_DAMAGE+keys.damage
          if damagingAbility:GetAbilityName()=="item_cyclone" then
            INV_EUL_DMG_TIME=Time()
            INV_EUL_DONE=1
          end
          if damagingAbility:GetAbilityName()=="invoker_sun_strike" then
            INV_SUNSTRIKE_DONE=1
            INV_SUNSTRIKE_TIME=Time()
          end
        end
        if INV_PROCAST_TYPE==1 then
          if damagingAbility:GetAbilityName()=="invoker_tornado" then
            INV_TORNADO_DONE=1
            INV_TORNADO_DONE_TIME=Time()
          end
          if damagingAbility:GetAbilityName()=="invoker_emp" then
            if INV_TORNADO_DONE==0 then
              if INV_TORNADO_CASTED==0 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! You forgot Tornado.',icon='invoker_tornado'})
                INV_TORNADO_DONE=0
                INV_EMP_DONE=0
                INV_TORNADO_CASTED=0
                INV_EMP_CASTED=0
                --BAD!
              end 
            else

              INV_EMP_DONE=1
              local damageDelay=Time()-INV_TORNADO_DONE_TIME
              local displayDelay=math.floor(damageDelay*1000)/1000
              print('dispdel',dispayDelay)
              print('damageDelay',damageDelay)
              if damageDelay>0.25 then
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red', text='Bad! '..displayDelay..' sec. between skills dmg.', icon='invoker_emp'})
                INV_TORNADO_DONE=0
                INV_EMP_DONE=0
                INV_TORNADO_CASTED=0
                INV_EMP_CASTED=0
                --BAD!
              else
                if damageDelay==0 then
                  --PERFECT!
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green', text='Perfect! '..displayDelay..' sec. between skills dmg.', icon='pogchamp'})
                  INV_TORNADO_DONE=0
                  INV_EMP_DONE=0
                  INV_TORNADO_CASTED=0
                  INV_EMP_CASTED=0
                else
                  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green', text='Good! '..displayDelay..' sec. between skills dmg.', icon='invoker_emp'})
                  INV_TORNADO_DONE=0
                  INV_EMP_DONE=0
                  INV_TORNADO_CASTED=0
                  INV_EMP_CASTED=0
                  --GOOD!
                end
              end
            end
          end
        end
        entVictim:Heal(keys.damage,nil)
      end
      if REACTION_TRAINING==1 and entVictim==hero then
        hero:EmitSound("sproing")
        EmitGlobalSound('sproing')
        AIM_COMBO=1
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO})
        print("Hero took damage")
      end
      if MOVING_AIM_TRAINING==1 and entVictim==hero then
        hero:EmitSound("sproing")
        EmitGlobalSound('sproing')
        AIM_COMBO=1
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO})
      end
      if eulsGameState==1 and entVictim==pizduk then
        if TIMING_TYPE==2 then
          if EUL_CASTED==1 then
            if (damagingAbility:GetAbilityName()=="obsidian_destroyer_astral_imprisonment") then
              EUL_DAMAGE_TIME=Time()  
              EUL_DMG_DONE=1
            end
          end
        end
        if EUL_SKILL=="bloodseeker_blood_bath" and TIMING_TYPE==0 then
          --------------------------------------------------------------------------------bloodbath logic
          if EUL_CASTED==1 then
            if (damagingAbility:GetAbilityName()=="item_cyclone") then
              EUL_DAMAGE_TIME=Time()  
              EUL_DMG_DONE=1
            end
            if (damagingAbility:GetAbilityName()==EUL_SKILL) then
                EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
                EUL_SKILL_DMG_DONE=1
                EUL_CASTED=0
                --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
                local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
            end
          end
          --------------------------------------------------------------------------------bloodbath logic
        else
          if EUL_CASTED==1 then
            if (damagingAbility:GetAbilityName()=="item_cyclone") then
              EUL_DAMAGE_TIME=Time()  
              EUL_DMG_DONE=1
            end
            if (damagingAbility:GetAbilityName()==EUL_SKILL) then
                EUL_COMPLETE_TIME=Time()-EUL_DAMAGE_TIME
                EUL_SKILL_DMG_DONE=1
                EUL_CASTED=0
                print("EUL_COMPLETE_TIME",EUL_COMPLETE_TIME)
--[[                local displayDelay=math.floor(EUL_COMPLETE_TIME*1000)/1000
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red', text='Bad! '..displayDelay..' sec. between skills dmg.', icon=EUL_SKILL})--]]

                --CustomGameEventManager:Send_ServerToAllClients("eul_result",{bad=false, time=EUL_COMPLETE_TIME})
                local dispayTime=math.floor(EUL_COMPLETE_TIME*1000)/1000
                CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! '..dispayTime..' sec.',icon='pepega'})
            end
          end
        end      
      end
      -----------------------------------------Manta evasion checker logic
      --print("alo nahui")
      
      if AlchemistTrainingState==1 then
        if entVictim==active_hero then
          ALCHE_HERO_HURT=1
          ALCHE_HERO_HURT_TIME=Time()
          
          CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='pepega'})
        end
      end

    end
  end
end

function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

  local unitEntity = nil
  if keys.UnitEntitIndex then
    unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
  elseif keys.HeroEntityIndex then
    unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
  end

  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
  glimpseOnFlaskPickup(unitEntity)
end



function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  --print("time:",Time())
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
  --skillshotOnSkillUsed(abilityName)
end

function GameMode:OnPlayerChat(keys)
  --PrintTable(keys)
  --medusaSnake(active_hero,3,2,tonumber(text))
  if keys.text=="testui" then
    CustomGameEventManager:Send_ServerToAllClients("show_test_ui",{})   
  end
end