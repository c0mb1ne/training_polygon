if timing == nil then
  timing = class({})
end

function timing:Init()
    self.type="sandbox" -- Define the type of mode
    self.name="timing" -- Name of the gamemode
    self.activated=false -- Whether the mode is activated
    self.Player=nil -- Reference to the player
    self.playerHero=nil -- Reference to the player's hero
    self.trainingPlace=Vector(879.7060546875,4036.7941894531,128) -- Location for training
    self.spellTable=
    {
        item_cyclone=
        {
            [1]={spell_name="item_meteor_hammer",hero_name="npc_dota_hero_riki",level=1,aghs=false,shard=false,is_ability=false},
            [2]={spell_name="axe_berserkers_call",hero_name="npc_dota_hero_axe",level=1,aghs=false,shard=false,is_ability=true},
            [3]={spell_name="centaur_hoof_stomp",hero_name="npc_dota_hero_centaur",level=1,aghs=false,shard=false,is_ability=true},
            [4]={spell_name="earth_spirit_boulder_smash",hero_name="npc_dota_hero_earth_spirit",level=1,aghs=false,shard=false,is_ability=true},
            [5]={spell_name="earthshaker_fissure",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true},
            [6]={spell_name="earthshaker_enchant_totem",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true},
            [8]={spell_name="earthshaker_echo_slam",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true},
            [9]={spell_name="elder_titan_echo_stomp",hero_name="npc_dota_hero_elder_titan",level=1,aghs=false,shard=false,is_ability=true},
            [10]={spell_name="ember_spirit_searing_chains",hero_name="npc_dota_hero_ember_spirit",level=1,aghs=false,shard=false,is_ability=true},
            [11]={spell_name="gyrocopter_call_down",hero_name="npc_dota_hero_gyrocopter",level=1,aghs=false,shard=false,is_ability=true},
            [12]={spell_name="kunkka_torrent",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true},
            [13]={spell_name="kunkka_ghostship",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true},
            [15]={spell_name="magnataur_skewer",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true},
            [16]={spell_name="magnataur_reverse_polarity",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true},
            [17]={spell_name="pudge_meat_hook",hero_name="npc_dota_hero_pudge",level=1,aghs=false,shard=false,is_ability=true},
            [18]={spell_name="sandking_burrowstrike",hero_name="npc_dota_hero_sandking",level=1,aghs=false,shard=false,is_ability=true},
            [19]={spell_name="slardar_slithereen_crush",hero_name="npc_dota_hero_slardar",level=1,aghs=false,shard=false,is_ability=true},
            [20]={spell_name="spirit_breaker_charge_of_darkness",hero_name="npc_dota_hero_spirit_breaker",level=1,aghs=false,shard=false,is_ability=true},
            [21]={spell_name="tidehunter_ravage",hero_name="npc_dota_hero_tidehunter",level=1,aghs=false,shard=false,is_ability=true},
            [22]={spell_name="tusk_snowball",hero_name="npc_dota_hero_tusk",level=1,aghs=false,shard=false,is_ability=true},
            [23]={spell_name="bloodseeker_blood_bath",hero_name="npc_dota_hero_bloodseeker",level=1,aghs=false,shard=false,is_ability=true},
            [24]={spell_name="lone_druid_savage_roar",hero_name="npc_dota_hero_lone_druid",level=1,aghs=false,shard=false,is_ability=true},
            [25]={spell_name="meepo_poof",hero_name="npc_dota_hero_meepo",level=1,aghs=false,shard=false,is_ability=true},
            [26]={spell_name="mirana_arrow",hero_name="npc_dota_hero_mirana",level=1,aghs=false,shard=false,is_ability=true},
            [27]={spell_name="monkey_king_boundless_strike",hero_name="npc_dota_hero_monkey_king",level=1,aghs=false,shard=false,is_ability=true},
            [28]={spell_name="nyx_assassin_impale",hero_name="npc_dota_hero_nyx_assassin",level=1,aghs=false,shard=false,is_ability=true},
            [29]={spell_name="pangolier_shield_crash",hero_name="npc_dota_hero_pangolier",level=1,aghs=false,shard=false,is_ability=true},
            [30]={spell_name="nevermore_shadowraze1",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true},
            [31]={spell_name="nevermore_shadowraze2",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true},
            [32]={spell_name="nevermore_shadowraze3",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true},
            [33]={spell_name="nevermore_requiem",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true},
            [34]={spell_name="ancient_apparition_cold_feet",hero_name="npc_dota_hero_ancient_apparition",level=1,aghs=false,shard=false,is_ability=true},
            [35]={spell_name="ancient_apparition_ice_blast",hero_name="npc_dota_hero_ancient_apparition",level=1,aghs=false,shard=false,is_ability=true},
            [36]={spell_name="dark_seer_vacuum",hero_name="npc_dota_hero_dark_seer",level=1,aghs=false,shard=false,is_ability=true},
            [37]={spell_name="dark_willow_cursed_crown",hero_name="npc_dota_hero_dark_willow",level=1,aghs=false,shard=false,is_ability=true},
            [38]={spell_name="death_prophet_silence",hero_name="npc_dota_hero_death_prophet",level=1,aghs=false,shard=false,is_ability=true},
            [39]={spell_name="invoker_emp",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true},
            [40]={spell_name="invoker_chaos_meteor",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true},
            [41]={spell_name="invoker_sun_strike",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true},
            [42]={spell_name="leshrac_split_earth",hero_name="npc_dota_hero_leshrac",level=1,aghs=false,shard=false,is_ability=true},
            [43]={spell_name="lina_light_strike_array",hero_name="npc_dota_hero_lina",level=1,aghs=false,shard=false,is_ability=true},
            [44]={spell_name="lion_impale",hero_name="npc_dota_hero_lion",level=1,aghs=false,shard=false,is_ability=true},
            [45]={spell_name="puck_waning_rift",hero_name="npc_dota_hero_puck",level=1,aghs=false,shard=false,is_ability=true},
            [46]={spell_name="pugna_nether_blast",hero_name="npc_dota_hero_pugna",level=1,aghs=false,shard=false,is_ability=true},
            [47]={spell_name="visage_summon_familiars",hero_name="npc_dota_hero_visage",level=1,aghs=false,shard=false,is_ability=true},
            [48]={spell_name="warlock_rain_of_chaos",hero_name="npc_dota_hero_warlock",level=1,aghs=false,shard=false,is_ability=true},
            [49]={spell_name="windrunner_shackleshot",hero_name="npc_dota_hero_windrunner",level=1,aghs=false,shard=false,is_ability=true}
        }
    }
    self.spellTable.shadow_demon_disruption = self.spellTable.item_cyclone
    self.spellTable.obsidian_destroyer_astral_imprisonment = self.spellTable.item_cyclone
    self.spellTable.item_aegis = self.spellTable.item_cyclone
    self.spellTable.skeleton_king_reincarnation = self.spellTable.item_cyclone
    self.spellTable.item_travel_boots = self.spellTable.item_cyclone
    --declaring spells this way, so we can declare different lists of spells to different types of timings
    --for now let them be the same
    --bot npcs for types:
    self.unitTable = {
        item_cyclone = "npc_dota_hero_lion",
        shadow_demon_disruption = "npc_dota_hero_ember_spirit",
        obsidian_destroyer_astral_imprisonment = "npc_dota_hero_puck",
        item_aegis = "npc_dota_hero_storm_spirit",
        skeleton_king_reincarnation = "npc_dota_hero_skeleton_king"
    }
    --register listeners here
    CustomGameEventManager:RegisterListener("get_timing_spell_table", function(_, event)
        timing:SendSpellTable()
    end)
end
function timing:Prepare(args)
    print("[Timing] Preparing gamemode")
    precache:clearTable()
    print("[Timing] Selected type:",args.timingType)
    print("[Timing] Selected spell:",args.selectedSpell)
end
function timing:StartGame(args)

end

function timing:SendSpellTable()
    CustomGameEventManager:Send_ServerToAllClients("timing_spell_table",{data=self.spellTable})
end

timing:Init()
GamemodeManager:RegisterMode(timing.name,timing,timing.type)