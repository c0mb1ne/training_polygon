if dodge == nil then
  dodge = class({})
end


function dodge:Init()
    self.spellTable=
    { item_manta=
        {
        lina_light_strike_array={"npc_dota_hero_lina",1,false,false,true},
        kunkka_ghostship={"npc_dota_hero_kunkka",1,false,false,true},
        lina_laguna_blade={"npc_dota_hero_lina",1,false,false,true},
        bloodseeker_blood_bath={"npc_dota_hero_bloodseeker",1,false,false,true},
        pugna_nether_blast={"npc_dota_hero_pugna",1,false,false,true},
        meepo_poof={"npc_dota_hero_meepo",1,false,false,true},
        necrolyte_death_pulse={"npc_dota_hero_necrolyte",1,false,false,true},
        mirana_starfall={"npc_dota_hero_mirana",1,false,false,true},
        nevermore_shadowraze2={"npc_dota_hero_nevermore",1,false,false,true},
        zuus_lightning_bolt={"npc_dota_hero_zuus",1,false,false,true},
        zuus_thundergods_wrath={"npc_dota_hero_zuus",1,false,false,true},
        tidehunter_anchor_smash={"npc_dota_hero_tidehunter",1,false,false,true},
        ursa_earthshock={"npc_dota_hero_ursa",1,false,false,true},
        omniknight_purification={"npc_dota_hero_omniknight",1,false,false,true},
        alchemist_unstable_concoction={"npc_dota_hero_alchemist",1,false,false,true},
        skywrath_mage_arcane_bolt={"npc_dota_hero_skywrath_mage",1,false,false,true},
        medusa_mystic_snake={"npc_dota_hero_medusa",1,false,false,true},
        medusa_stone_gaze={"npc_dota_hero_medusa",1,false,false,true},
        shadow_demon_demonic_purge={"npc_dota_hero_shadow_demon",1,false,false,true},
        earthshaker_fissure={"npc_dota_hero_earthshaker",1,false,false,true},
        earthshaker_enchant_totem={"npc_dota_hero_earthshaker",1,false,false,true},
        invoker_emp={"npc_dota_hero_invoker",1,false,false,true},
        obsidian_destroyer_sanity_eclipse={"npc_dota_hero_obsidian_destroyer",1,false,false,true},
        undying_decay={"npc_dota_hero_undying",1,false,false,true},
        elder_titan_echo_stomp={"npc_dota_hero_elder_titan",1,false,false,true},
        rattletrap_rocket_flare={"npc_dota_hero_rattletrap",1,false,false,true},
        rattletrap_hookshot={"npc_dota_hero_rattletrap",1,false,false,true},
        windrunner_powershot={"npc_dota_hero_windrunner",1,false,false,true},
        huskar_life_break={"npc_dota_hero_huskar",1,false,false,true},
        gyrocopter_homing_missile={"npc_dota_hero_gyrocopter",1,false,false,true},
        tiny_toss={"npc_dota_hero_tiny",1,false,false,true},
        phoenix_supernova={"npc_dota_hero_phoenix",1,false,false,true},
        legion_commander_overwhelming_odds={"npc_dota_hero_legion_commander",1,false,false,true},
        magnataur_reverse_polarity={"npc_dota_hero_magnataur",1,false,false,true},
        slardar_slithereen_crush={"npc_dota_hero_slardar",1,false,false,true},
        axe_berserkers_call={"npc_dota_hero_axe",1,false,false,true},
        brewmaster_thunder_clap={"npc_dota_hero_brewmaster",1,false,false,true},
        centaur_hoof_stomp={"npc_dota_hero_centaur",1,false,false,true},
        lion_finger_of_death={"npc_dota_hero_lion",1,false,false,true},
        queenofpain_scream_of_pain={"npc_dota_hero_queenofpain",1,false,false,true},
        visage_summon_familiars_stone_form={"npc_dota_visage_familiar1",1,false,false,true},
        polar_furbolg_ursa_warrior_thunder_clap={"npc_dota_neutral_polar_furbolg_ursa_warrior",1,false,false,true},
        centaur_khan_war_stomp={"npc_dota_neutral_centaur_khan",1,false,false,true},
        techies_suicide={"npc_dota_hero_techies",1,false,false,true},
        obsidian_destroyer_astral_imprisonment={"npc_dota_hero_obsidian_destroyer",1,false,false,true},
        roshan_slam={"npc_dota_roshan",1,false,false,true},
        invoker_sun_strike={"npc_dota_hero_invoker",1,false,false,true},
        kunkka_torrent={"npc_dota_hero_kunkka",1,false,false,true},
        kunkka_tidebringer={"npc_dota_hero_kunkka",1,false,false,true},
        elder_titan_earth_splitter={"npc_dota_hero_elder_titan",1,false,false,true},
        leshrac_split_earth={"npc_dota_hero_leshrac",1,false,false,true},
        warlock_rain_of_chaos={"npc_dota_hero_warlock",1,false,false,true},
        pangolier_shield_crash={"npc_dota_hero_pangolier",1,false,false,true},
        dark_willow_terrorize={"npc_dota_hero_dark_willow",1,false,false,true},
        item_meteor_hammer={"npc_dota_hero_riki",1,false,false,false}
        },
        ember_spirit_sleight_of_fist=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        puck_phase_shift=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        storm_spirit_ball_lightning=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        bane_nightmare=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        monkey_king_mischief=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        void_spirit_dissimilate=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        antimage_counterspell=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        riki_tricks_of_the_trade=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        },
        nyx_assassin_spiked_carapace=
        {
        {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
        {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
        {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
        
        }
    }
    -- Assign the reference of item_manta to other elements if we want them to be same
    self.spellTable.ember_spirit_sleight_of_fist = self.spellTable.item_manta
    self.spellTable.puck_phase_shift = self.spellTable.item_manta
    self.spellTable.storm_spirit_ball_lightning = self.spellTable.item_manta
    self.spellTable.bane_nightmare = self.spellTable.item_manta
    self.spellTable.monkey_king_mischief = self.spellTable.item_manta
    self.spellTable.void_spirit_dissimilate = self.spellTable.item_manta
    self.spellTable.antimage_counterspell = self.spellTable.item_manta
    self.spellTable.riki_tricks_of_the_trade = self.spellTable.item_manta
    self.spellTable.nyx_assassin_spiked_carapace = self.spellTable.item_manta
    -- Define a table mapping abilities to heroes
    self.unitTable = {
        item_manta = "npc_dota_hero_antimage",
        ember_spirit_sleight_of_fist = "npc_dota_hero_ember_spirit",
        puck_phase_shift = "npc_dota_hero_puck",
        storm_spirit_ball_lightning = "npc_dota_hero_storm_spirit",
        bane_nightmare = "npc_dota_hero_bane",
        monkey_king_mischief = "npc_dota_hero_monkey_king",
        void_spirit_dissimilate = "npc_dota_hero_void_spirit",
        antimage_counterspell = "npc_dota_hero_antimage",
        riki_tricks_of_the_trade = "npc_dota_hero_riki",
        nyx_assassin_spiked_carapace = "npc_dota_hero_nyx_assassin",
    }
    self.type="sandbox" -- Define the type of mode
    self.name="dodge" -- Name of the gamemode
    self.activated=false -- Whether the mode is activated
    self.Player=nil -- Reference to the player
    self.playerHero=nil -- Reference to the player's hero
    self.trainingPlace=Vector(879.7060546875,4036.7941894531,128) -- Location for training

    --register listeners here
    CustomGameEventManager:RegisterListener("get_dodge_spell_table", function(_, event)
        dodge:SendSpellTable()
    end)
    print('dodge inited')
end

function dodge:Prepare(args)
    precache:PrecacheAddPlayerUnitToList("npc_dota_hero_antimage")
end
function dodge:SendSpellTable()
    --[[ print(self.spellTable)
    DeepPrintTable(self.spellTable) ]]
    CustomGameEventManager:Send_ServerToAllClients("dodge_spell_table",{data=self.spellTable})
end
function dodge:OnNPCSpawned(keys)

end

function dodge:OrderFilter(event)

end

function dodge:ModifierGained(event)

end

function dodge:OnIllusionsCreated(keys)

end

function dodge:OnNonPlayerUsedAbility(keys)

end

function dodge:OnAbilityUsed(keys)

end

function dodge:OnEntityHurt(keys)

end