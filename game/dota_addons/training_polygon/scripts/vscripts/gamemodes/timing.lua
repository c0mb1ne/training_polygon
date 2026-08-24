--TODO: add feature for skills that kinda cool to cast before eul, like dark_willow_cursed_crown
--should be easy but right know not sure how much important it is
--when i 80% done i start thinking that this whole thing need to be redone, with timings being calculated before even drawn on ui, so it would be easier to filter them
if timing == nil then
  timing = class({})
end
require('gamemodes/timing_timebar_skills')--setup for each skills here
function timing:Init()
    self.type="sandbox" -- Define the type of mode
    self.name="timing" -- Name of the gamemode
    self.activated=false -- Whether the mode is activated
    self.Player=nil -- Reference to the player
    self.playerHero=nil -- Reference to the player's hero
    self.trainingPlaceDefault=Vector(-6040.6640625,4100.78564453125,128) -- Location for training
    self.trainingPlace=self.trainingPlaceDefault
    self.spellTable=
    {
        item_cyclone=
        {
            [1]={spell_name="item_meteor_hammer",hero_name="npc_dota_hero_riki",level=1,aghs=false,shard=false,is_ability=false,need_helper=false},
            [2]={spell_name="axe_berserkers_call",hero_name="npc_dota_hero_axe",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [3]={spell_name="centaur_hoof_stomp",hero_name="npc_dota_hero_centaur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            --[[ [4]={spell_name="earth_spirit_boulder_smash",hero_name="npc_dota_hero_earth_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},--it doesnt stun anymore ]]
            [50]={spell_name="earth_spirit_rolling_boulder",hero_name="npc_dota_hero_earth_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [5]={spell_name="earthshaker_fissure",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [6]={spell_name="earthshaker_enchant_totem",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [8]={spell_name="earthshaker_echo_slam",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [9]={spell_name="elder_titan_echo_stomp",hero_name="npc_dota_hero_elder_titan",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [10]={spell_name="ember_spirit_searing_chains",hero_name="npc_dota_hero_ember_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [11]={spell_name="gyrocopter_call_down",hero_name="npc_dota_hero_gyrocopter",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [12]={spell_name="kunkka_torrent",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            --[13]={spell_name="kunkka_ghostship",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true,need_helper=false}, unable to time except in aegis
            [15]={spell_name="magnataur_skewer",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [16]={spell_name="magnataur_reverse_polarity",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [17]={spell_name="pudge_meat_hook",hero_name="npc_dota_hero_pudge",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [18]={spell_name="sandking_burrowstrike",hero_name="npc_dota_hero_sand_king",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [19]={spell_name="slardar_slithereen_crush",hero_name="npc_dota_hero_slardar",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [20]={spell_name="spirit_breaker_charge_of_darkness",hero_name="npc_dota_hero_spirit_breaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [21]={spell_name="tidehunter_ravage",hero_name="npc_dota_hero_tidehunter",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [22]={spell_name="tusk_snowball",hero_name="npc_dota_hero_tusk",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [23]={spell_name="bloodseeker_blood_bath",hero_name="npc_dota_hero_bloodseeker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [24]={spell_name="lone_druid_savage_roar",hero_name="npc_dota_hero_lone_druid",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [25]={spell_name="meepo_poof",hero_name="npc_dota_hero_meepo",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [26]={spell_name="mirana_arrow",hero_name="npc_dota_hero_mirana",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [27]={spell_name="monkey_king_boundless_strike",hero_name="npc_dota_hero_monkey_king",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [28]={spell_name="nyx_assassin_impale",hero_name="npc_dota_hero_nyx_assassin",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [29]={spell_name="pangolier_shield_crash",hero_name="npc_dota_hero_pangolier",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [30]={spell_name="nevermore_shadowraze1",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [31]={spell_name="nevermore_shadowraze2",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [32]={spell_name="nevermore_shadowraze3",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [33]={spell_name="nevermore_requiem",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [35]={spell_name="ancient_apparition_ice_blast",hero_name="npc_dota_hero_ancient_apparition",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [36]={spell_name="dark_seer_vacuum",hero_name="npc_dota_hero_dark_seer",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            --[[ [37]={spell_name="dark_willow_cursed_crown",hero_name="npc_dota_hero_dark_willow",level=1,aghs=false,shard=false,is_ability=true,need_helper=false}, later]]
            [38]={spell_name="death_prophet_silence",hero_name="npc_dota_hero_death_prophet",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [39]={spell_name="invoker_emp",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            --[[ [40]={spell_name="invoker_chaos_meteor",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},--idk why is it here tbh ]]
            [41]={spell_name="invoker_sun_strike",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [42]={spell_name="leshrac_split_earth",hero_name="npc_dota_hero_leshrac",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [43]={spell_name="lina_light_strike_array",hero_name="npc_dota_hero_lina",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [44]={spell_name="lion_impale",hero_name="npc_dota_hero_lion",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [45]={spell_name="puck_waning_rift",hero_name="npc_dota_hero_puck",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [46]={spell_name="pugna_nether_blast",hero_name="npc_dota_hero_pugna",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [47]={spell_name="visage_summon_familiars",hero_name="npc_dota_hero_visage",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [48]={spell_name="warlock_rain_of_chaos",hero_name="npc_dota_hero_warlock",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [49]={spell_name="windrunner_shackleshot",hero_name="npc_dota_hero_windrunner",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [50]={spell_name="snapfire_firesnap_cookie",hero_name="npc_dota_hero_snapfire",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},--just saw someone missed timing on TI
        }
    }
    self.spellTable.shadow_demon_disruption = self.spellTable.item_cyclone
    self.spellTable.obsidian_destroyer_astral_imprisonment = self.spellTable.item_cyclone
    self.spellTable.item_aegis = 
    {
        [1]={spell_name="item_meteor_hammer",hero_name="npc_dota_hero_riki",level=1,aghs=false,shard=false,is_ability=false,need_helper=false},
        [2]={spell_name="axe_berserkers_call",hero_name="npc_dota_hero_axe",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [3]={spell_name="centaur_hoof_stomp",hero_name="npc_dota_hero_centaur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        --[[ [4]={spell_name="earth_spirit_boulder_smash",hero_name="npc_dota_hero_earth_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},--it doesnt stun anymore ]]
        [50]={spell_name="earth_spirit_rolling_boulder",hero_name="npc_dota_hero_earth_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [5]={spell_name="earthshaker_fissure",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [6]={spell_name="earthshaker_enchant_totem",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [8]={spell_name="earthshaker_echo_slam",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [9]={spell_name="elder_titan_echo_stomp",hero_name="npc_dota_hero_elder_titan",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [10]={spell_name="ember_spirit_searing_chains",hero_name="npc_dota_hero_ember_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [11]={spell_name="gyrocopter_call_down",hero_name="npc_dota_hero_gyrocopter",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [12]={spell_name="kunkka_torrent",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [13]={spell_name="kunkka_ghostship",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [15]={spell_name="magnataur_skewer",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [16]={spell_name="magnataur_reverse_polarity",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [17]={spell_name="pudge_meat_hook",hero_name="npc_dota_hero_pudge",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [18]={spell_name="sandking_burrowstrike",hero_name="npc_dota_hero_sandking",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [19]={spell_name="slardar_slithereen_crush",hero_name="npc_dota_hero_slardar",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [20]={spell_name="spirit_breaker_charge_of_darkness",hero_name="npc_dota_hero_spirit_breaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [21]={spell_name="tidehunter_ravage",hero_name="npc_dota_hero_tidehunter",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [22]={spell_name="tusk_snowball",hero_name="npc_dota_hero_tusk",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [23]={spell_name="bloodseeker_blood_bath",hero_name="npc_dota_hero_bloodseeker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [24]={spell_name="lone_druid_savage_roar",hero_name="npc_dota_hero_lone_druid",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [25]={spell_name="meepo_poof",hero_name="npc_dota_hero_meepo",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [26]={spell_name="mirana_arrow",hero_name="npc_dota_hero_mirana",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [27]={spell_name="monkey_king_boundless_strike",hero_name="npc_dota_hero_monkey_king",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [28]={spell_name="nyx_assassin_impale",hero_name="npc_dota_hero_nyx_assassin",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [29]={spell_name="pangolier_shield_crash",hero_name="npc_dota_hero_pangolier",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [30]={spell_name="nevermore_shadowraze1",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [31]={spell_name="nevermore_shadowraze2",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [32]={spell_name="nevermore_shadowraze3",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [33]={spell_name="nevermore_requiem",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [35]={spell_name="ancient_apparition_ice_blast",hero_name="npc_dota_hero_ancient_apparition",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [36]={spell_name="dark_seer_vacuum",hero_name="npc_dota_hero_dark_seer",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        --[[ [37]={spell_name="dark_willow_cursed_crown",hero_name="npc_dota_hero_dark_willow",level=1,aghs=false,shard=false,is_ability=true,need_helper=false}, ]]
        [38]={spell_name="death_prophet_silence",hero_name="npc_dota_hero_death_prophet",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [39]={spell_name="invoker_emp",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        --[[ [40]={spell_name="invoker_chaos_meteor",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false}, ]]
        [41]={spell_name="invoker_sun_strike",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [42]={spell_name="leshrac_split_earth",hero_name="npc_dota_hero_leshrac",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [43]={spell_name="lina_light_strike_array",hero_name="npc_dota_hero_lina",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [44]={spell_name="lion_impale",hero_name="npc_dota_hero_lion",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [45]={spell_name="puck_waning_rift",hero_name="npc_dota_hero_puck",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [46]={spell_name="pugna_nether_blast",hero_name="npc_dota_hero_pugna",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [47]={spell_name="visage_summon_familiars",hero_name="npc_dota_hero_visage",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [48]={spell_name="warlock_rain_of_chaos",hero_name="npc_dota_hero_warlock",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [49]={spell_name="windrunner_shackleshot",hero_name="npc_dota_hero_windrunner",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
        [50]={spell_name="snapfire_firesnap_cookie",hero_name="npc_dota_hero_snapfire",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
    }
    self.spellTable.skeleton_king_reincarnation = self.spellTable.item_cyclone
    --declaring spells this way, so we can declare different lists of spells to different types of timings
    --for now let them be the same
    --bot npcs for types:
    self.unitTable = {
        item_cyclone = "npc_dota_hero_lion",
        shadow_demon_disruption = "npc_dota_hero_shadow_demon",
        obsidian_destroyer_astral_imprisonment = "npc_dota_hero_obsidian_destroyer",
        item_aegis = "npc_dota_hero_ursa",
        skeleton_king_reincarnation = "npc_dota_hero_skeleton_king",
    }
    --delays calculations
    local cycloneKV=DotaDB:GetItemKV("item_cyclone")
    local cycloneCastpoint=parseQuadroValue(cycloneKV['AbilityCastPoint'])
    local cycloneDuration=parseQuadroValue(cycloneKV['AbilityValues']['cyclone_duration'])
    local disruptionKV=DotaDB:GetAbilityKV("shadow_demon_disruption")
    local disruptionCastpoint=parseQuadroValue(disruptionKV['AbilityCastPoint'])
    local disruptionDuration=parseQuadroValue(disruptionKV['AbilityValues']['disruption_duration']['value'])
    --for od astral we taking menu value cuz level change duration
    local aegisKV=DotaDB:GetItemKV("item_aegis")
    local aegisDuration=parseQuadroValue(aegisKV["AbilityValues"]["reincarnate_time"])
    local wkResKV=DotaDB:GetAbilityKV("skeleton_king_reincarnation")
    local wkResKVDuration=parseQuadroValue(wkResKV['AbilityValues']['reincarnate_time'])
    self.delayTable={
        item_cyclone = cycloneCastpoint+cycloneDuration,
        shadow_demon_disruption = disruptionCastpoint+disruptionDuration,
        obsidian_destroyer_astral_imprisonment = 0, --has different duration depends on level, need exceptional approach
        item_aegis = aegisDuration,
        skeleton_king_reincarnation = wkResKVDuration,
    }
    self.actionsTable={
        item_cyclone = "item_cyclone_cycle",
        shadow_demon_disruption = "shadow_demon_disruption_cycle",
        obsidian_destroyer_astral_imprisonment = "obsidian_destroyer_astral_imprisonment_cycle",
        item_aegis = "item_aegis_cycle",
        skeleton_king_reincarnation = "skeleton_king_reincarnation_cycle",
    }
    self.hurtModifiers={
        "modifier_axe_berserkers_call",
        "modifier_item_meteor_hammer_burn",
        "modifier_stunned",
        "modifier_earth_spirit_boulder_smash_debuff",--idk if needed
        "modifier_earthshaker_fissure_stun",
        "modifier_pudge_meat_hook",
        "modifier_elder_titan_echo_stomp",
        "modifier_ember_spirit_searing_chains",
        "modifier_gyrocopter_call_down_slow",
        "modifier_kunkka_torrent",
        "modifier_magnataur_skewer_impact",
        "modifier_sandking_impale",
        "modifier_spiritbreaker_greater_bash_knockback",
        "modifier_tidehunter_ravage",
        "modifier_silence",
        "modifier_lone_druid_savage_roar",
        "modifier_nevermore_requiem_fear",
        "modifier_nevermore_requiem_slow",
        "modifier_dark_seer_vacuum",
        "modifier_death_prophet_silence",
        "modifier_lion_impale",
        "modifier_windrunner_shackle_shot"
        --"modifier_ice_blast" lets block this from applying and count damage as success, cuz iceblast debuff works through eul
    }
    self.invulModifiers={
        "modifier_eul_cyclone",
        "modifier_shadow_demon_disruption",
        "modifier_obsidian_destroyer_astral_imprisonment_prison"
    }
    self.invertedCast={--table for spells, that should be casted before eul
        "dark_willow_cursed_crown",
    }
    --register listeners here
    CustomGameEventManager:RegisterListener("get_timing_spell_table", function(_, event)
        timing:SendSpellTable()
    end)
    CustomGameEventManager:RegisterListener("get_timing_respawn_pos", function(_, event)
        timing:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("timing_training_end", function(_, event)
        timing:PrepareDeactivate()
    end)
    CustomGameEventManager:RegisterListener("timing_ms_change", function(eventSourceIndex, args)
        timing:MoveSpeedChange(args)
    end)
    CustomGameEventManager:RegisterListener("timing_sb_charge_change", function(eventSourceIndex, args)
        timing:spiritBreakerCharge(args)
    end)
    CustomGameEventManager:RegisterListener("timing_sb_bulldoze_change", function(eventSourceIndex, args)
        timing:spiritBreakerBulldoze(args)
    end)
    CustomGameEventManager:RegisterListener("timing_snowball_change", function(eventSourceIndex, args)
        timing:tuskSnowballChange(args)
    end)
    self.currentTimingType=nil
    self.selectedSpell=nil
    self.playerHero=nil
    self.enemyHeroName=nil
    self.enemyHero=nil
    self.treeCutTimer=nil
    self.cycleCooldown=2
    self.trainingItem=nil
    self.trainingSpell=nil
    self.eulBotCast=nil
    self.enemyActionTimer=nil
    self.timebarExtraTime=1
    self.castDelay=1
    self.yashaKaya=false
    self.yashaKayaModifier=0.75
    self.cycleCastDuration=0
    self.timebarGreenZone=0.1
    self.enemyGotHurt=false
    self.enemyHurtTime=0
    self.invulOutTime=0
    self.deactivateCalled=false
    self.firstCycle=true
    self.manualEul=nil
    self.tempVision=nil
    self.esStoneTrashCan={}--put earth spirit stones here, so they wont stay after deactivate
    self.yashaKayaEnt=nil
    self.spiritBreakerHelper=nil
    self.spiritBreakerSpeedModifier=nil
    self.spiritBreakerSkill1=nil
    self.spiritBreakerSkill2=nil
    self.visageBirds={}--store birds to refresh cd on them, and remove them on deactivate
    self.rubickMode=false
    self.rubickStealTarget=nil
end
function timing:Prepare(args)
    print("[Timing] Preparing gamemode")
    precache:clearTable()
    --[[ print("[Timing] Selected type:",args.timingType)
    print("[Timing] Selected spell:",args.selectedSpell) ]]
    local timingType = args.timingType or "item_cyclone"
    local selectedSpells = args.selectedSpell or {}
    print("[Timing] Selected type:",timingType)
    DeepPrintTable(args.selectedSpell)
    local enemyHero = self.unitTable[timingType]
    local playerHero
    for k,v in pairs(args.selectedSpell) do
        playerHero=v.hero_name
    end
    if args.rubickMode==1 then
        precache:PrecacheAddPlayerUnitToList({playerHero})
        playerHero="npc_dota_hero_rubick"
    end
    print("[Timing] Player hero:",playerHero)
    print("[Timing] Enemy hero:",enemyHero)
    precache:PrecacheAddPlayerUnitToList({playerHero})
    precache:PrecacheAddUnitToList({enemyHero})
    precache:doPrecache(function()
        timing:StartGame(args)
    end)
end
function timing:StartGame(args)
    print("[Timing] Starting game after precache")
    self.activated = true
    if args.rubickMode==1 then
        self.rubickMode=true
    else
        self.rubickMode=false
    end
    local playerHero
    for k,v in pairs(args.selectedSpell) do
        playerHero=v.hero_name
        self.selectedSpell=v
    end
    if self.rubickMode then
        playerHero="npc_dota_hero_rubick"
    end
    self.deactivateCalled=false
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    Timebar:Show()
    self.Player=PlayerResource:GetPlayer(0)
    self.currentTimingType=args.timingType or "item_cyclone"
    self.cycleCastDuration=self.delayTable[self.currentTimingType]
    --exception for durations depending on skill level
    self.cycleSpellLevel=tonumber(args['abilityLevel'])
    if self.currentTimingType=="obsidian_destroyer_astral_imprisonment" then
        local astralKV=DotaDB:GetAbilityKV("obsidian_destroyer_astral_imprisonment")
        local astralCastpoint=parseQuadroValue(astralKV["AbilityCastPoint"])
        local astralDuration=parseQuadroValue(astralKV["AbilityValues"]["prison_duration"]["value"],self.cycleSpellLevel)
        self.cycleCastDuration=astralCastpoint+astralDuration
    end
    if args.helperMode==1 then
        self.eulBotCast=true
    else
        self.eulBotCast=false
    end
    
    self.castDelay=tonumber(args['customDelay'])
    self.enemyHeroName = self.unitTable[self.currentTimingType]
    local old_hero=self.Player:GetAssignedHero()
    local new_hero=playerHero
    self.playerHero=replaceHero(old_hero,new_hero)
    local pos = args.respawnPos
    self.trainingPlace = Vector(
        tonumber(pos["0"]),
        tonumber(pos["1"]),
        tonumber(pos["2"])
    )
    if args.yashaKaya==1 then
        self.yashaKaya=true
        self.yashaKayaEnt=CreateItem("item_yasha_and_kaya",self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.yashaKayaEnt)
    else
        self.yashaKaya=false
    end
    self.treeCutTimer=Timers:CreateTimer(0, function()
        if args['destroyTrees']==1 then
            GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
        end
        return 4
    end)
    self.firstCycle=true
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    local enemyRespawnPlace=randomCirclePosition(400,self.playerHero)
    local enemyCaster=CreateUnitByNameAsync(self.enemyHeroName,enemyRespawnPlace,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetAttackCapability(0)
        unit:SetBaseManaRegen(100)
        unit:SetBaseHealthRegen(100)
        self[self.actionsTable[self.currentTimingType]](self,unit)
        self.enemyHero=unit
        --preparing timebar here
        self['timebar_'..self.selectedSpell.spell_name](self)
        return unit
    end)
    --[[ print('self.selectedSpell.is_ability',self.selectedSpell.is_ability) ]]
    if self.selectedSpell.is_ability==0 then
        self.trainingItem=CreateItem(self.selectedSpell.spell_name,self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.trainingItem)
    else
        --[[ if self.rubickMode then
            self:RubickPrepareSteal()
        else
            self.trainingSpell=self.playerHero:FindAbilityByName(self.selectedSpell.spell_name)
            self.trainingSpell:SetLevel(self.selectedSpell.level)
        end ]]
        if self.rubickMode then
            self:SpellSteal(self.playerHero,self.selectedSpell.spell_name)
        end
        self.trainingSpell=self.playerHero:FindAbilityByName(self.selectedSpell.spell_name)
        self.trainingSpell:SetLevel(self.selectedSpell.level)
    end
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    self.playerHero:SetAttackCapability(0)
    --[[ self.tempVision = createTempVision(500,DOTA_TEAM_GOODGUYS,self.trainingPlace,true) ]]
end

function timing:OnStartOfCycle()
    --can do result check here
    if self.deactivateCalled then
        self:Deactivate()
        return true
    end
    if self.firstCycle==false then
        if self.enemyGotHurt then
            print('enemyHurtTime',self.enemyHurtTime)
            print('invulOutTime',self.invulOutTime)
            local delay=self.enemyHurtTime-self.invulOutTime
            delay=math.floor(delay*1000)/1000
            Notifications:Show('green','good, delay:'..delay,self.selectedSpell.spell_name)
        else
            Notifications:Show('red','bad',self.selectedSpell.spell_name)
        end
        if self.trainingItem~=nil then
            self.trainingItem:EndCooldown()
        end
        if self.trainingSpell~=nil then
            self.trainingSpell:EndCooldown()
        end
        if self.manualEul~=nil then
            self.manualEul:EndCooldown()
        end
        if self.selectedSpell.spell_name=="visage_summon_familiars" then
            for k,v in pairs(self.visageBirds) do
                if IsValidEntity(v) then
                    local spell=v:FindAbilityByName("visage_summon_familiars_stone_form")
                    spell:EndCooldown()
                    print("[Timing] Resetting bird cooldown")
                end
            end
        end
        self.enemyGotHurt=false
    end
    self.firstCycle=false
    --sf ult want souls
    if self.selectedSpell.spell_name=="nevermore_requiem" then
        local necromastery=self.playerHero:FindModifierByName("modifier_nevermore_necromastery")
        necromastery:SetStackCount(20)
    end
end

function timing:item_cyclone_cycle(unit)
    if self.eulBotCast then
        local eul=CreateItem("item_cyclone",unit,unit)
        unit:AddItem(eul)
        self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
            self:OnStartOfCycle()
            if IsValidEntity(unit) then
                eul:EndCooldown()
                unit:SetContextThink(DoUniqueString("cast_ability"), function()
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                        AbilityIndex = eul:entindex(),
                        TargetIndex = unit:entindex(),
                        Queue = 1
                    })
                end,0)
                return self.castDelay+self.cycleCastDuration
            else
                return nil
            end
        end)
    else
        self.manualEul=CreateItem("item_cyclone",self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.manualEul)
    end
    --[[ print('item cyclone cycle called') ]]
end
function timing:shadow_demon_disruption_cycle(unit)
    local disruption=unit:FindAbilityByName(self.currentTimingType)
    disruption:SetLevel(1)
    self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
        self:OnStartOfCycle()
        if IsValidEntity(unit) then
            disruption:EndCooldown()
            unit:SetContextThink(DoUniqueString("cast_ability"), function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = disruption:entindex(),
                    TargetIndex = unit:entindex(),
                    Queue = 1
                })
            end,0)
            return self.castDelay+self.cycleCastDuration
        else
            return nil
        end
    end)
    --print('shadow_demon_disruption_cycle called')
end
function timing:obsidian_destroyer_astral_imprisonment_cycle(unit)
    local prison=unit:FindAbilityByName(self.currentTimingType)
    prison:SetLevel(self.cycleSpellLevel)
    self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
        self:OnStartOfCycle()
        if IsValidEntity(unit) then
            prison:EndCooldown()
            unit:SetContextThink(DoUniqueString("cast_ability"), function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = prison:entindex(),
                    TargetIndex = unit:entindex(),
                    Queue = 1
                })
            end,0)
            return self.castDelay+self.cycleCastDuration
        else
            return nil
        end
    end)
end
function timing:item_aegis_cycle(unit)
    --[[ print('item_aegis_cycle called') ]]
    self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
        self:OnStartOfCycle()
        if IsValidEntity(unit) then
            local aegis=CreateItem("item_aegis",unit,unit)
            unit:AddItem(aegis)
            unit:ForceKill(false)
            Timers:CreateTimer(2, function()
                if unit:IsNull()~=true then
                    unit:EmitSound("DOTAMusic_Hero.Reincarnate")
                end
            end)
            Timebar:Start()
            return self.castDelay+self.cycleCastDuration
        else
            return nil
        end
    end)
end
function timing:skeleton_king_reincarnation_cycle(unit)
    local ultimate=unit:FindAbilityByName("skeleton_king_reincarnation")
    ultimate:SetLevel(3)
    self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
        self:OnStartOfCycle()
        if IsValidEntity(unit) then
            ultimate:EndCooldown()
            --[[ local aegis=CreateItem("item_aegis",unit,unit)
            unit:AddItem(aegis) ]]
            unit:ForceKill(false)
            --[[ Timers:CreateTimer(2, function()
                if unit:IsNull()~=true then
                    unit:EmitSound("DOTAMusic_Hero.Reincarnate")
                end
            end) ]]
            Timebar:Start()
            return self.castDelay+self.cycleCastDuration
        else
            return nil
        end
    end)
end
function timing:item_travel_boots_cycle(unit)--i dont wanna spend time on this, maybe it deserves different gamemode, since we moved to dota map
    print('item_travel_boots_cycle called')
end
function timing:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    print("[Timing] NPC spawned:",npc:GetUnitName())
    if npc:GetUnitName()=="npc_dota_visage_familiar1" then
        npc:SetAttackCapability(0)
        table.insert(self.visageBirds,npc)
    end
    if npc:GetUnitName()=="npc_dota_warlock_golem" then
        Timers:CreateTimer({
            endTime = FrameTime(), 
            callback = function()
                npc:RemoveSelf()
            end
        })
    end
    if npc:IsIllusion() then
        Timers:CreateTimer({
            endTime = FrameTime(), 
            callback = function()
                npc:RemoveSelf()
            end
        })
    end
    if npc:GetUnitName()=="npc_dota_earth_spirit_stone" then
        self:timebar_earth_spirit_rolling_boulder_stone()
        table.insert(self.esStoneTrashCan,npc)
    end
    if self.currentTimingType=="item_aegis" then
        self.invulOutTime=Time()
    end
    if self.currentTimingType=="skeleton_king_reincarnation" then
        self.invulOutTime=Time()
    end
end
function timing:OrderFilter(event)
    --[[ DeepPrintTable(event) ]]
    if event['issuer_player_id_const']==-1 then
        --bot order
        if event['entindex_ability']~=0 then
            local ability=EntIndexToHScript(event['entindex_ability'])
            if ability~=nil then
                local unitIndex=event.units["0"]
                local unit=EntIndexToHScript(unitIndex)
                if IsValidEntity(unit) then
                    if unit:GetUnitName()~="npc_dota_visage_familiar1" then
                        Timebar:Start()
                    end
                end
            end
        end
    else
        --player order
        local ability=EntIndexToHScript(event['entindex_ability'])
        if ability~=nil then
            if ability==self.trainingSpell or ability==self.trainingItem then
                Timebar:PlayerAction()
            end
        end
    end
    return true
end

function timing:ModifierGained(event)
    
    --[[ if event.name_const=="modifier_earth_spirit_stone_caller_innate" then
        local owner=EntIndexToHScript(event.entindex_parent_const)
        local startingCount=0
        Timers:CreateTimer(0,function()
            if IsValidEntity(owner) then
                print(owner:GetModifierStackCount(event.name_const,owner))
                return FrameTime()
            else
                return nil
            end
        end)
    end ]]
    if event.name_const=="modifier_visage_summon_familiars_stone_form_buff" or event.name_const=="modifier_visage_summonfamiliars_timer" then
        event.duration=1
    end
    if event.name_const=="modifier_ancient_apparition_bone_chill_debuff" or event.name_const=="modifier_ice_blast" then
        return false
    end
    if event.name_const=="modifier_earth_spirit_stone_thinker" then
        local npc=EntIndexToHScript(event.entindex_parent_const)
        Timers:CreateTimer(0,function()
            if IsValidEntity(npc) then
                if npc:HasModifier(event.name_const) then
                    return FrameTime()
                else
                    print('stone gone')
                    if self.activated and self.selectedSpell.spell_name=="earth_spirit_rolling_boulder" then
                        self:timebar_earth_spirit_rolling_boulder()
                    end
                    return nil
                end
            else
                return nil
            end
        end)
    end
    if string_in_array(event.name_const,self.hurtModifiers) and EntIndexToHScript(event.entindex_parent_const)==self.enemyHero then
        event.duration=0.2 --for some reason doesnt work for elder titan stomp
        Timers:CreateTimer(0.2,function()--thank you elder titan
            local npc=EntIndexToHScript(event.entindex_parent_const)
            if IsValidEntity(npc) then
                --[[ print("[Timing] Removing modifier:",event.name_const) ]]
                npc:RemoveModifierByName(event.name_const)
            end
        end)
        if self.enemyGotHurt==false then
            self.enemyGotHurt=true
            print('[Timing] enemy hurt by modifier',event.name_const)
            self.enemyHurtTime=Time()
            Timebar:BlueLine()
        end
        
        --[[ return true ]]
    end
    --catching frame where enemy became able to get hit
    if string_in_array(event.name_const,self.invulModifiers) then
        self.enemyGotHurt=false
        self.enemyHurtTime=0
        Timers:CreateTimer(FrameTime(),function()
            if IsValidEntity(self.enemyHero) then
                if self.enemyHero:HasModifier(event.name_const) then
                    return FrameTime()
                else
                    --print('modifier expired')
                    if self.eulBotCast==false then
                        self.firstCycle=false
                        if event.name_const=="modifier_eul_cyclone" then
                            Timers:CreateTimer(self.castDelay,function()
                                self:OnStartOfCycle()
                            end)
                        end
                    end
                    self.invulOutTime=Time()
                    return nil
                end
            else
                return nil
            end
        end)
        
        --[[ return true ]]
    end
    debugModifier(event)
    return true
end
function timing:OnEntityHurt(keys)
    --[[ DeepPrintTable(keys) ]]
    local entCause=nil
    local entVictim=nil
    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        entCause = EntIndexToHScript(keys.entindex_attacker)
        entVictim = EntIndexToHScript(keys.entindex_killed)
    end
    if entVictim~=nil then
        if keys.damage~=0 and entVictim==self.enemyHero then
            if self.enemyGotHurt==false then
                self.enemyGotHurt=true
                print('[Timing] player hurt by damage')
                self.enemyHurtTime=Time()
                Timebar:BlueLine()
            end
        end
    end
end

function timing:OnAbilityUsed(keys)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local abilityname = keys.abilityname
    --[[ print("abilityname",abilityname) ]]
    if abilityname=="item_cyclone" and self.eulBotCast==false then
        Timebar:Start()
    end
end
function timing:DamageFilter(event)
    --[[ DeepPrintTable(event) ]]
    local damager=nil
    if event.entindex_attacker_const then
        damager=EntIndexToHScript(event.entindex_attacker_const)
    end
    local ability=nil
    if event.entindex_inflictor_const then
        ability=EntIndexToHScript(event.entindex_inflictor_const)
        if ability~=nil then
            if ability:GetAbilityName()=="item_cyclone" then
                return false
            end
        end
    end
    
    return true
end
function timing:SendSpellTable()
    CustomGameEventManager:Send_ServerToAllClients("timing_spell_table",{data=self.spellTable})
end
function timing:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("timing_respawn_pos",{pos={self.trainingPlace.x,self.trainingPlace.y,self.trainingPlace.z}})
end

function timing:PrepareDeactivate()
    self.activated=false
    self.deactivateCalled=true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud",{})
    if self.eulBotCast==false and self.currentTimingType=="item_cyclone" then
        self:Deactivate()
        announcer:Hide()
    else
        announcer:Show({message="#waitingForCastEnd"})
    end
end

function timing:MoveSpeedChange(args)
    --[[ print(args.value) ]]
    if self.spiritBreakerSpeedModifier then
        self.spiritBreakerSpeedModifier:SetStackCount(tonumber(args.value))
        --[[ self:timebar_spirit_breaker_charge_of_darkness() ]]
    end
end
function timing:spiritBreakerCharge(args)
    if self.spiritBreakerSkill1 then
        self.spiritBreakerSkill1:SetLevel(tonumber(args.value))
    end
end
function timing:spiritBreakerBulldoze(args)
    if self.spiritBreakerSkill2 then
        self.spiritBreakerSkill2:SetLevel(tonumber(args.value))
    end
end
function timing:tuskSnowballChange(args)
    local ability=self.playerHero:FindAbilityByName("tusk_snowball")
    if ability then
        ability:SetLevel(tonumber(args.value))
        --recalculate timebar
        self:timebar_tusk_snowball(true)
    end
end
function timing:Deactivate()
    announcer:Hide()
    if self.enemyActionTimer~=nil then
        Timers:RemoveTimer(self.enemyActionTimer)
    end
    for k,v in pairs(self.esStoneTrashCan) do
        if IsValidEntity(v) then
            v:RemoveSelf()
        end
    end
    self.esStoneTrashCan={}
    for k,v in pairs(self.visageBirds) do
        if IsValidEntity(v) then
            v:RemoveSelf()
        end
    end
    self.visageBirds={}
    if self.yashaKaya then
        self.yashaKayaEnt:RemoveSelf()
    end
    if IsValidEntity(self.spiritBreakerHelper) then
        self.spiritBreakerHelper:RemoveSelf()
    end
    self.spiritBreakerSkill1=nil
    self.spiritBreakerSkill2=nil
    self.spiritBreakerSpeedModifier=nil
    self.spiritBreakerHelper=nil
    self.yashaKaya=false
    self.trainingItem=nil
    self.trainingSpell=nil
    --[[ Timers:RemoveTimer(self.tempVision) ]]
    self.enemyHero:RemoveSelf()
    self.manualEul=nil
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("clear_hud",{})
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu",{})
end

function timing:RubickPrepareSteal()
    local dummyRespawnPlace=self.trainingPlace+Vector(-200,0,0)
    local spellStealDummy=CreateUnitByNameAsync(self.selectedSpell.hero_name,dummyRespawnPlace,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        local abilityName=self.selectedSpell.spell_name
        local hAbility=unit:FindAbilityByName(abilityname)
        hAbility:SetLevel(1)
        
        self.rubickStealTarget=unit
        return unit
    end)

end

function timing:SpellSteal(hRubick,abilityname)
    local old = hRubick:FindAbilityByName("rubick_empty1") 
    if old then
        hRubick:RemoveAbility(old:GetAbilityName())
    end
    local newAbility = hRubick:AddAbility(abilityname)
    newAbility:SetLevel(1)
    local castpoint=newAbility:GetCastPoint()
    print('[Timing] newAbility old castpoint:',castpoint)
    if castpoint>0.15 then
        newAbility:SetOverrideCastPoint(0.15)
    end
    print('[Timing] newAbility new castpoint:',newAbility:GetCastPoint())
    --[[ hRubick:SwapAbilities(abilityname, "empty1", true, true) ]]
end

timing:Init()
GamemodeManager:RegisterMode(timing.name,timing,timing.type)