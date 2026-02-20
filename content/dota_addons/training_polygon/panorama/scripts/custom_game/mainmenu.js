 /*AnimatePanel
 * Animates a panel
 *  
 * Params:
 * 		panel 		- Panel to animate
 *		values 		- Dictionary containing the properties and values to animate.
 *					  Example: { "transform": "translateX(100);", "opacity": "0.5" }
 *		duration 	- The animation duration in seconds
 *		ease 		- Easing function to use. Example: "linear" or "ease-in"
 *		delay		- Time to wait before starting the animation in seconds   
 */
function AnimatePanel(panel, values, duration, ease, delay) {
	// generate transition string
	var durationString = (duration != null ? parseInt(duration * 1000) + ".0ms" : DEFAULT_DURATION);
	var easeString = (ease != null ? ease : DEFAULT_EASE);
	var delayString = (delay != null ? parseInt(delay * 1000) + ".0ms" : "0.0ms"); 
	var transitionString = durationString + " " + easeString + " " + delayString;

	var i = 0;
	var finalTransition = ""
	for (var property in values) {
		// add property to transition
		finalTransition = finalTransition + (i > 0 ? ", " : "") + property + " " + transitionString;
		i++;
	}

	// apply transition
	panel.style.transition = finalTransition + ";";

	// apply values
	for (var property in values)
		panel.style[property] = values[property];
}
function makeTranslatorPanel(steam){
	var parentPanel=$('#translatorsContainer')
	var translatorContainer=$.CreatePanel('Panel',parentPanel,'ts_cont')
	translatorContainer.AddClass('tsContainer')
	var playerAvatar=$.CreatePanel('DOTAAvatarImage',translatorContainer,'ts_avatar')
	playerAvatar.steamid=steam
	playerAvatar.style['width']='50px;'
	playerAvatar.style['height']='50px;'
	var playerNickname=$.CreatePanel('DOTAUserName',translatorContainer,'ts_name')
	playerNickname.AddClass('leaderboardLabel')
	playerNickname.steamid=steam
}
$.Msg($.Language())
/*if ($.Language()=='english'){
	$("#welcomeText1").style['visibility']='collapse'; 
	$("#welcomeText2").style['visibility']='collapse'; 
	$("#welcomeLink").style['visibility']='collapse'; 
}else{
	$('#sponsorMessage').style['visibility']='collapse';
}*/
/*$('#sponsorMessage').style['visibility']='collapse';*/
/*$('#fdContainer').style['visibility']='collapse'; */
/*var langs={} 
langs["german"]='76561198064411261'
langs["romanian"]='76561198047012850'
langs["turkish"]='76561198453632849'
if (langs[$.Language()]){
	$('#translatorsContainer').style['visibility']='visible'
	makeTranslatorPanel(langs[$.Language()])
}*/
const client_lang = $.Language()
/*if (client_lang=="russian"){
	$.Msg("changing shit")
	$("#enImpMsg").style['visibility']='collapse';
	$("#enGuideLabel").style['visibility']='collapse';
	$("#enGuideLink").style['visibility']='collapse';
}else{
	$("#ruImpMsg").style['visibility']='collapse';
	$("#ruGuideLabel").style['visibility']='collapse';
	$("#ruGuideLink").style['visibility']='collapse';
}*/

var MAP_INFO=Game.GetMapInfo()
var MAP_NAME=MAP_INFO.map_display_name

/*setPlayerName()*/

var skills = [
	"item_meteor_hammer",
	"item_meteor_hammer",
	"dark_willow_terrorize",
	"pangolier_shield_crash",
	"warlock_rain_of_chaos",
	"leshrac_split_earth",
	"invoker_sun_strike",
	"kunkka_torrent",
	"kunkka_tidebringer",
	"elder_titan_earth_splitter",
	"roshan_slam",
	"lina_light_strike_array",
	"kunkka_ghostship",
	"lina_laguna_blade",
	"bloodseeker_blood_bath",
	"pugna_nether_blast",
	"meepo_poof",
	"necrolyte_death_pulse",
	"mirana_starfall",
	"nevermore_shadowraze1",
	"nevermore_shadowraze2",
	"nevermore_shadowraze3",
	"zuus_lightning_bolt",
	"zuus_thundergods_wrath",
	"tidehunter_anchor_smash",
	"ursa_earthshock",
	"omniknight_purification",
	"alchemist_unstable_concoction",
	"skywrath_mage_arcane_bolt",
	"medusa_mystic_snake",
	"techies_suicide",
	"monkey_king_boundless_strike",
	"shadow_demon_demonic_purge",
	"earthshaker_fissure",
	"earthshaker_enchant_totem",
	"earthshaker_enchant_totem",
	"invoker_emp",
	"obsidian_destroyer_sanity_eclipse",
	"undying_decay",
	"elder_titan_echo_stomp",
	"rattletrap_rocket_flare",
	"rattletrap_hookshot",
	"rattletrap_hookshot",
	"rattletrap_hookshot",
	"windrunner_powershot",
	"huskar_life_break",
	"gyrocopter_homing_missile",
	"tiny_toss",
	"phoenix_supernova",
	"legion_commander_overwhelming_odds",
	"magnataur_reverse_polarity",
	"slardar_slithereen_crush",
	"axe_berserkers_call",
	"brewmaster_thunder_clap",
	"centaur_hoof_stomp",
	"lion_finger_of_death",
	"queenofpain_scream_of_pain",
	"monkey_king_primal_spring",
	"visage_summon_familiars_stone_form",
	"polar_furbolg_ursa_warrior_thunder_clap",
	"centaur_khan_war_stomp",
	"spawnlord_master_stomp",
	"obsidian_destroyer_astral_imprisonment"
]
var ids = [66,65,64,63,62,61,57,58,59,60,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]
var creeps_ids = [49,50,51,52,54]
var skillPanel = $('#skillList')
var skillCount = ids.length


var eul_skills_old=["kunkka_torrent",
              "nevermore_requiem",
              "invoker_sun_strike",
              "elder_titan_echo_stomp",
              "techies_suicide",
              "death_prophet_silence",
              "lina_light_strike_array",
              "earthshaker_fissure",
              "earthshaker_enchant_totem",
              "leshrac_split_earth",
              "slardar_slithereen_crush",
              "centaur_hoof_stomp",
              "bloodseeker_blood_bath",
              "earthshaker_enchant_totem",
              "windrunner_powershot",
              "lion_impale",
              "nyx_assassin_impale", 
              "phoenix_fire_spirits",
              "pudge_meat_hook",
              "earth_spirit_boulder_smash",
              "mirana_arrow",
              "sandking_burrowstrike",
              "spirit_breaker_greater_bash",
              "spirit_breaker_greater_bash",
              "sandking_burrowstrike",
              "nyx_assassin_spiked_carapace",
              "earthshaker_echo_slam",
              "item_meteor_hammer"
            ]

var eul_skills = [
				"item_meteor_hammer",
				"axe_berserkers_call", 
				"centaur_hoof_stomp",
				"earth_spirit_boulder_smash", 
				"earthshaker_fissure", 
				"earthshaker_enchant_totem", 
				"earthshaker_enchant_totem", 
				"earthshaker_echo_slam", 
				"elder_titan_echo_stomp",
				"ember_spirit_searing_chains",  
				"gyrocopter_call_down", 
				"kunkka_torrent", 
				"kunkka_ghostship", 
				"kunkka_ghostship", 
				"magnataur_skewer",
				"magnataur_reverse_polarity",
				"pudge_meat_hook", 
				"sandking_burrowstrike", 
				"slardar_slithereen_crush",
				"spirit_breaker_charge_of_darkness",  
				"tidehunter_ravage",  
				"tusk_snowball",  
				"bloodseeker_blood_bath",
				"lone_druid_savage_roar", 
				"meepo_poof",
				"mirana_arrow", 
				"monkey_king_boundless_strike",
				"nyx_assassin_impale",  
				"pangolier_shield_crash",
				"nevermore_shadowraze1", 
				"nevermore_shadowraze2", 
				"nevermore_shadowraze3", 
				"nevermore_requiem", 
				//"slark_pounce",
				"ancient_apparition_cold_feet", 
				"ancient_apparition_ice_blast", 
				"dark_seer_vacuum",
				"dark_willow_cursed_crown",
				"death_prophet_silence", 
				//"invoker_tornado", 
				"invoker_emp", 
				"invoker_chaos_meteor",
				"invoker_sun_strike",
				//"invoker_deafening_blast", 
				"leshrac_split_earth", 
				"lina_light_strike_array",  
				"lion_impale",  
				"puck_waning_rift", 
				"pugna_nether_blast",
				"visage_summon_familiars", 
				"warlock_rain_of_chaos", 
				"windrunner_shackleshot"
]
var eul_primary=[
				"item_cyclone", 
				"shadow_demon_disruption", 
				"obsidian_destroyer_astral_imprisonment",  
				"item_aegis",  
				"skeleton_king_reincarnation", 
				"item_travel_boots"/*,  
				"naga_siren_song_of_the_siren",  
				"disruptor_glimpse",  
				"kunkka_x_marks_the_spot",  
				"brewmaster_storm_cyclone"*/
]
drawEulPrimarySkills()
var armlet_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114]
var armlet_heroes = [
	"npc_dota_goodguys_tower1_mid",
	"npc_dota_goodguys_tower2_mid",
	"npc_dota_hero_abaddon",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_axe",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
	"npc_dota_hero_beastmaster",
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
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_huskar",
	"npc_dota_hero_invoker",
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
	"npc_dota_hero_medusa",
	"npc_dota_hero_meepo",
	"npc_dota_hero_mirana",
	"npc_dota_hero_morphling",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_oracle",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_phoenix",
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
	"npc_dota_hero_warlock",
	"npc_dota_hero_weaver",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_wisp",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_zuus",
	"npc_dota_hero_mars",
	"npc_dota_hero_muerta"
] 
var lasthit_heroes=[
"npc_dota_hero_abaddon",
"npc_dota_hero_alchemist",
"npc_dota_hero_antimage",
"npc_dota_hero_ancient_apparition",
"npc_dota_hero_arc_warden",
"npc_dota_hero_axe",
"npc_dota_hero_bane",
"npc_dota_hero_batrider",
"npc_dota_hero_beastmaster",
"npc_dota_hero_bloodseeker",
"npc_dota_hero_bounty_hunter",
"npc_dota_hero_brewmaster",
"npc_dota_hero_bristleback",
"npc_dota_hero_broodmother",
"npc_dota_hero_centaur",
"npc_dota_hero_chaos_knight",
"npc_dota_hero_chen",
"npc_dota_hero_clinkz",
"npc_dota_hero_rattletrap",
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
"npc_dota_hero_gyrocopter",
"npc_dota_hero_huskar",
"npc_dota_hero_invoker",
"npc_dota_hero_wisp",
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
"npc_dota_hero_medusa",
"npc_dota_hero_meepo",
"npc_dota_hero_mirana",
"npc_dota_hero_morphling",
"npc_dota_hero_monkey_king",
"npc_dota_hero_naga_siren",
"npc_dota_hero_furion",
"npc_dota_hero_necrolyte",
"npc_dota_hero_night_stalker",
"npc_dota_hero_nyx_assassin",
"npc_dota_hero_ogre_magi",
"npc_dota_hero_omniknight",
"npc_dota_hero_oracle",
"npc_dota_hero_obsidian_destroyer",
"npc_dota_hero_pangolier",
"npc_dota_hero_phantom_assassin",
"npc_dota_hero_phantom_lancer",
"npc_dota_hero_phoenix",
"npc_dota_hero_puck",
"npc_dota_hero_pudge",
"npc_dota_hero_pugna",
"npc_dota_hero_queenofpain",
"npc_dota_hero_razor",
"npc_dota_hero_riki",
"npc_dota_hero_rubick",
"npc_dota_hero_sand_king",
"npc_dota_hero_shadow_demon",
"npc_dota_hero_nevermore",
"npc_dota_hero_shadow_shaman",
"npc_dota_hero_silencer",
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
"npc_dota_hero_shredder",
"npc_dota_hero_tinker",
"npc_dota_hero_tiny",
"npc_dota_hero_treant",
"npc_dota_hero_troll_warlord",
"npc_dota_hero_tusk",
"npc_dota_hero_abyssal_underlord",
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
"npc_dota_hero_witch_doctor",
"npc_dota_hero_skeleton_king",
"npc_dota_hero_zuus",
"npc_dota_hero_mars",
"npc_dota_hero_grimstroke",
"npc_dota_hero_hoodwink",
"npc_dota_hero_dawnbreaker",
"npc_dota_hero_marci",
"npc_dota_hero_primal_beast",
"npc_dota_hero_muerta",
"npc_dota_hero_ringmaster",
"npc_dota_hero_kez",
"npc_dota_hero_largo"]
var eulSkillPanel = $('#eulSkillList')

$('#side_0').checked=true
$('#botToggle').checked=true
drawEulSkillList()
//$('#timing_cont_8').style['visibility']='collapse'
var glimpse_ids=[1, 2, 3, 4, 5, 6, 7]
var glimpse_skills = [
	"item_manta",
	"phantom_lancer_doppelwalk",
	"naga_siren_mirror_image",
	"ember_spirit_sleight_of_fist",
	"chaos_knight_phantasm",
	"sandking_burrowstrike",
	"shredder_timber_chain"
]
var glimpseSkillPanel = $('#glimpseSkillList')
var glimpseSkillCount = 7 
drawGlimpseSkillList(0, 7, 6)
$('#glimpse_level_1').checked=true
$('#glimpseLvl').style['visibility']='collapse'	
$('#glimpse_level_1').SetPanelEvent (
	"onactivate", 
	function() {
		$('#glimpse_level_1').checked=true
		$('#glimpse_level_2').checked=false
		$('#glimpse_level_3').checked=false
		$('#glimpse_level_4').checked=false
	}
)
$('#glimpse_level_2').SetPanelEvent (
	"onactivate", 
	function() {
		$('#glimpse_level_1').checked=true
		$('#glimpse_level_2').checked=true
		$('#glimpse_level_3').checked=false
		$('#glimpse_level_4').checked=false
	}
)
$('#glimpse_level_3').SetPanelEvent (
	"onactivate", 
	function() {
		$('#glimpse_level_1').checked=true
		$('#glimpse_level_2').checked=true
		$('#glimpse_level_3').checked=true
		$('#glimpse_level_4').checked=false
	}
)

$('#glimpse_level_4').SetPanelEvent (
	"onactivate", 
	function() {
		$('#glimpse_level_1').checked=true
		$('#glimpse_level_2').checked=true
		$('#glimpse_level_3').checked=true
		$('#glimpse_level_4').checked=true
	}
)

drawArmletHeroList(10)
 
var ss_ids=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ,17,18,19,20,21]
var ss_skills = [
		"rattletrap_hookshot",
		"earth_spirit_boulder_smash",
		"ember_spirit_searing_chains",
		"invoker_sun_strike",
		"meepo_earthbind",
		"mirana_arrow",
		"nyx_assassin_impale",
		"pudge_meat_hook",
		"puck_illusory_orb",
		"phoenix_fire_spirits",
		"nevermore_shadowraze1",
		"windrunner_powershot",
		"windrunner_shackleshot",
	    "wisp_spirits",
	    "ancient_apparition_ice_blast",
	    "furion_sprout",
	    "invoker_ice_wall",
	    "leshrac_split_earth",
	    "kunkka_torrent",
	    "mars_spear",
	    "earth_spirit_rolling_boulder"
]
var ssSkillPanel = $('#ssSkillList')
var ssSkillCount = ss_skills.length
drawSsSkillList(0, ssSkillCount, 6)


$('#mantaBlink').SetPanelEvent (
	"onselect", 
	function() {
		$('#timebarToggle').checked=false
		for(var creep in creeps_ids){
			$('#skill_check_'+creeps_ids[creep]).enabled=false
			$('#skill_check_'+creeps_ids[creep]).checked=false
		}
	}
)
$('#mantaBlink').SetPanelEvent (
	"ondeselect", 
	function() {
		for(var creep in creeps_ids){
			$('#skill_check_'+creeps_ids[creep]).enabled=true
		}
	}
)
$('#timebarToggle').SetPanelEvent (
	"onselect", 
	function() {
		$('#mantaBlink').checked=false
	} 
)
showPanel($('#welcomeWindow'))
hidePanel($('#mainFrame'))
hidePanel($('#eulSettings'))
hidePanel($('#eulsInfo'))
hidePanel($('#glimpseSettings'))
hidePanel($('#glimpseInfo'))
hidePanel($('#armletSettings'))
hidePanel($('#armletInfo'))
hidePanel($('#aimSettings'))
hidePanel($('#aimInfo'))
hidePanel($('#invSettings'))
hidePanel($('#invInfo'))
hidePanel($('#skillshotSettings'))
hidePanel($('#skillshotInfo'))
hidePanel($('#challangeSettings'))
hidePanel($('#challangeInfo'))
hidePanel($('#otherInfo'))
hidePanel($('#otherSettings'))
hidePanel($('#lastHitInfo'))
hidePanel($('#lastHitSettings'))
$('#manta').checked = true
//$('#challangeMode').checked = true
rootPanel = $('#mainWindow').GetParent()
drawSkillList()
rootPanel.hittest = false
//hidePanel($('#customSettings'))

$('#timebarToggle').checked = true
/*$('#timebarToggleEul').checked = true*/
$('#timebarToggleGlimpse').checked = true
$('#timebarToggle2').checked = true
$('#dtype_0').checked = true
$('#other_1').checked = true
$('#aim_challenge').checked = true
var mantaMode = 1
hidePanel($('#errorMsg'))
hidePanel($('#glimpseErrorMsg'))
hidePanel($('#eulErrorMsg'))
$('#eul_skill_check_1').checked = true
function closeBobRoss() {

	hidePanel($('#welcomeWindow'))
	showPanel($('#mainFrame'))
}
//$('#welcomeWindow').DeleteAsync(0)
//closeBobRoss()
/*function closeBobRoss() {

	hidePanel($('#welcomeWindow'))
	showPanel($('#mainFrame'))
}*/
//------------------------------MAKING DONATION PAGE 
var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID())
var steamID64 = playerInfo.player_steamid
var donationData
var session_id
$.Msg(steamID64)

/*$('#welcomeButton').enabled = false
var enableTime = 10*/

if (Game.IsInToolsMode()){
	$('#welcomeButton').enabled = true
}else{
	$('#welcomeButton').enabled = false
}


if (steamID64=="76561198010703166"){
	enableTime=1
}
/*function enableStartButton() {
	if (enableTime === 0 || $('#welcomeButton').enabled == true) {
		$('#welcomeButtonText').text = "ok"
		$('#welcomeButton').enabled = true
	} else {
		$('#welcomeButtonText').text = "ok" + ' (' + enableTime.toString() + ')'
		enableTime = enableTime - 1
		$.Schedule(1, enableStartButton)
	}
}
enableStartButton()*/
 
var url = "http://vh184007.eurodir.ru/tpserver/"     
//var url = "http://tpsite/"
//var url = "http://vh184007.eurodir.ru/dev/"



GameEvents.SendCustomGameEventToServer (
	"user_init",
	{
		url: url,
		type: 'POST',
        data: {
			request: 'initUser',
			steam: steamID64,
			language: client_lang
		}
	}
);
//$("#tTitle").text="Offline"
function userInitRecieve(data){
	$.Msg(data)
	var twitchData=JSON.parse(data.data)
	if (twitchData['stream_status']==0){
		$.Msg("offline")
		//$("#tLiveStatus").text="Offline"

		//$("#tGame").text=""
	}else{
		var info=twitchData['stream']
		$.Msg("online")
		//$("#twitchInfoContainer").AddClass("twitchContainerLive")
		//$("#tLiveStatus").AddClass('labelLive')
		//$("#tLiveStatus").text="LIVE"
		//$("#tGame").text='Playing '+twitchData['game_name'] 
	}	
}
/*function GetDonationsData() {
    $.Msg("Getting donations data...")
    $.AsyncWebRequest(url,
        {
            type: 'POST',
            data: {
				request: 'getDonations',
				steam: steamID64,
				language: client_lang
			},
            success: function (data) {*/
            	/*$.Msg(data)
                serverResponse=JSON.parse(data)
                session_id=serverResponse['session_id']
                if (serverResponse['level']!=0){
                	$.Msg("donater confirmed")
                	$('#welcomeButton').enabled = true
                }else{

                }
                var donationData=serverResponse['donations']
                var tableCount=1
                for(var tableName in donationData){
                	//$.Msg(tableName)  
                	if (tableName!='playersLastMonth'){
                		var donaterCount=1
	                	for (var donater in donationData[tableName]){
	                		//$.Msg(donater)
	                		var name
	                		var money
	                		var level=0
	                		for (var donaterAttr in donationData[tableName][donater]){
	                			if (donaterAttr=="name"){
	                				name=donationData[tableName][donater][donaterAttr]
	                			}
	                			if (donaterAttr=="money"){
	                				money=donationData[tableName][donater][donaterAttr]
	                			}
	                			if (tableName!="firstDon"){
	                				if (donaterAttr=="level"){
		                				level=donationData[tableName][donater][donaterAttr]
		                			}
	                			}else{
	                				level=0
	                			}
	                			

	                		}
	                		var id=Number(tableCount.toString()+donaterCount.toString())

	                		ReplaceDonation(id, name, money, level)
	                		donaterCount += 1
	                	}
	                	tableCount += 1
                	}else{
                		$('#uniquePlayers').text=donationData[tableName]
                	}   
                	
                }
            }
        });
}*/
/*function GetTwitchData() {
    $.Msg("Getting twitch data...")
    $.AsyncWebRequest(url+'twitch_check.php',
        {
            type: 'GET',
            success: function (data) {
            	twitchData=JSON.parse(data)
            	if (twitchData['stream']==null){
            		$.Msg("offline")
            		$("#tLiveStatus").text="Offline"
            		$("#tGame").text=""
            	}else{
            		var info=twitchData['stream']
            		$.Msg("online")
            		$("#twitchInfoContainer").AddClass("twitchContainerLive")
            		$("#tLiveStatus").AddClass('labelLive')
            		$("#tLiveStatus").text="LIVE"
            		$("#tGame").text='Playing '+info['game']
            	}	
            }
        });
}*/
var liveList={}
//GetTwitchData()
/*function GetTwitchData2() {
    $.Msg("Getting twitch data for leaderboard...")
    $.AsyncWebRequest(url,
        {
            type: 'POST',
            data: {
				request: 'getLeaderboardTwitchData'
			},
            success: function (data) {
            	liveList=JSON.parse(data)
            }
        });
}*/
//GetTwitchData2()
function ReplaceDonation(panelId,name,money,level) {
	var defaultPanel = $('#don_e_' + panelId)
	var defaultAvatar = $('#don_a_' + panelId)
	var defaultNickname = $('#don_n_' + panelId)
	var defaultAmmount = $('#don_m_' + panelId)
	var lvlRange=[0,1,5,10,50,100]
	var userLevel
/*	for (var i = 0; i < lvlRange.length; i++) {
		if (Math.max(money,lvlRange[i])!=lvlRange[i]){
			userLevel+=1; 
		}
	}*/
	if (level>0){
		defaultPanel.AddClass('donLevel'+level)
	}
	/*$.Msg(panelId,level)*/
	if(Number(name)) {
		defaultAvatar.steamid = name
		defaultNickname.steamid = name
		defaultAmmount.text = money.replace(".", ",") + " $"
	} else {
		var avatarParent = defaultAvatar.GetParent()	
		defaultAvatar.DeleteAsync(0)
		var newAvatar = $.CreatePanel('Panel', avatarParent, 'don_a_'+panelId.toString())
		newAvatar.SetHasClass('donatorNoAvatar',true)
		avatarParent.MoveChildBefore(newAvatar,avatarParent.GetChild(1))
		var nicknameParent = defaultNickname.GetParent()
		defaultNickname.DeleteAsync(0)
		var newNickName = $.CreatePanel('Label', nicknameParent, 'don_n_'+panelId.toString())
		nicknameParent.MoveChildBefore(newNickName,nicknameParent.GetChild(0))
		newNickName.AddClass('donatorNameCustom')
		newNickName.text = name
		defaultAmmount.text = money.replace(".",",")+" $"
		
	}
	$('#don_e_' + panelId.toString()).RemoveClass('donatorPanelHidden')
}
//GetDonationsData()
 
//trying to find focused panel
var dotaui=$.GetContextPanel().GetParent().GetParent().GetParent().GetParent()


function printIdEveryChild(panel){
	//$.Msg('type: ',panel.paneltype,' id: ',panel.id,' focus')type: SlottedSlider id: undefined focus
	if (panel.paneltype!="Slider" && panel.paneltype!="CircularProgressBar" && panel.paneltype!="SlottedSlider"){
		panel.SetPanelEvent(
		  "onfocus", 
		  function(){
		  	$.Msg('type: ',panel.paneltype,' id: ',panel.id,' focus')
		  }
		)
		panel.SetPanelEvent(
		  "onblur", 
		  function(){
		  	$.Msg('type: ',panel.paneltype,' id: ',panel.id,' blur')
		  }
		)
		$.Each(panel.Children(), function( oPanel )
			{
				printIdEveryChild(oPanel)
			});
	}
}
/*printIdEveryChild(dotaui)*/




//$('#welcomeTwo').text="&lt;a href=&quot;http://steamcommunity.com/sharedfiles/filedetails/?id=813598504&quot;&gt;"+$.Localize("#welcomeTwo")+"&lt;a&gt;"




/*	var Skill=$.CreatePanel('Panel', parentPanel, 'glimpse_skill_'+id)
	Skill.AddClass("skill")
	var SkillImage=$.CreatePanel('DOTAAbilityImage', Skill, 'glimpse_skillImg_'+id)
	SkillImage.abilityname=skill
	var SkillCheck=$.CreatePanel('RadioButton', Skill, 'glimpse_skill_check_'+id)
	SkillCheck.AddClass("volvoRadioButton")
	SkillCheck.AddClass("skillCheckbox")
	SkillCheck.group="glimpse_skill_group"

*/

/*function testo(){
	$.AsyncWebRequest('',
        {
            type: 'GET',
            success: function (data) {
            	var start=data.indexOf("<body>");
                $.Msg(data.substring(start))
            }
        }); 
}*/
/*testo()*/
function trainingEnds() {
	$.Schedule (1, function() {
		$('#mainWindow').RemoveClass("Hidden")
	})
}

/*function setPlayerName() {
	var playerID = Players.GetLocalPlayer()
	var nickname = Players.GetPlayerName(playerID)
	var kek = "%username%"
	var str = $('#welcomeText1').text
	var newstr = str.replace(kek,nickname)
	$('#welcomeText1').text = newstr 
}*/

function startGame() {

	var player=Game.GetLocalPlayerID()
	var timebar=0
	var shuffle=0
	var blinkMode=0
	var skills = getEnabledSkills();
	var dodgeType = 0
	for (var i = 0; i < 9; i++)
		if ($('#dtype_'+i).checked)
			dodgeType=i
			$.Msg('dodge type:',dodgeType)
	if (skills.length > 0) {
		//if (mantaMode==0){
		if ($('#timebarToggle').checked)
			timebar=1
		if ($('#mantaShuffle').checked)
			shuffle=1
		if ($('#mantaBlink').checked)
			blinkMode=1
		if (skills[0] === 420){
			var trainingArgs={
				"alche_start":
				{
					"player": player,
					"timebar" : timebar,
					"skillId": 420
				}
			}
			GameEvents.SendCustomGameEventToServer (
				"tp_precache",
				{
					"jsArgs": trainingArgs
				}
			);
		}
		else{
			var trainingArgs={
				"custom_manta_training_start":
				{
					"player": player,
					"timebar": timebar,
					"skills" : getEnabledSkills(),
					"shuffle" : shuffle,
					"blink" : blinkMode,
					"dodge_type" : dodgeType+1
				}
			}
			GameEvents.SendCustomGameEventToServer (
				"tp_precache",
				{
					"jsArgs": trainingArgs
				}
			);
			/*GameEvents.SendCustomGameEventToServer (
				"custom_manta_training_start",
				{
					"player": player,
					"timebar": timebar,
					"skills" : getEnabledSkills(),
					"shuffle" : shuffle,
					"blink" : blinkMode,
					"dodge_type" : dodgeType+1
				}
			);*/
		}
		//}else{
			//GameEvents.SendCustomGameEventToServer( "simple_game_start", { "player" : player, "timebar" : timebar } );
		//}
		showLoading()
		$('#mainWindow').AddClass("Hidden")
		

		//$.Schedule(0.5, function(){$('#mainWindow').style['visibility']='collapse';})
	}else
		showPanel($('#errorMsg'))
}
function startArmletTraining() {
	var player=Game.GetLocalPlayerID()
	var unit = getEnabledArmletUnit();
	if (unit) {
		var trainingArgs={
			"armlet_training_start":
			{
				"player": player,
				"unitName": unit
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
		$('#mainWindow').AddClass("Hidden")
		//$.Schedule(0.5, function(){$('#mainWindow').style['visibility']='collapse';})
	}else
		showPanel($('#errorMsg'))
}
function startAimTraining() {
	var player=Game.GetLocalPlayerID()
	var trainingArgs={
		"aim_start":
		{
			"player": player,
			"retry": 0
		}
	}
	GameEvents.SendCustomGameEventToServer (
		"tp_precache",
		{
			"jsArgs": trainingArgs
		}
	);
	$('#mainWindow').AddClass("Hidden")

}
function startAimTraining2() {
	var player=Game.GetLocalPlayerID()
	var trainingArgs={
		"aim_start2":
		{
			"player": player,
			"retry": 0
		}
	}
	GameEvents.SendCustomGameEventToServer (
		"tp_precache",
		{
			"jsArgs": trainingArgs
		}
	);
	$('#mainWindow').AddClass("Hidden")

}
function startAimTraining3() {
	var player=Game.GetLocalPlayerID()
	var trainingArgs={
		"aim_start3":
		{
			"player": player,
			"retry": 0
		}
	}
	GameEvents.SendCustomGameEventToServer (
		"tp_precache",
		{
			"jsArgs": trainingArgs
		}
	);
	$('#mainWindow').AddClass("Hidden")

}
function startMapAimTraining() {
	var player=Game.GetLocalPlayerID()
	var trainingArgs={
		"map_aim_start":
		{
			"player": player,
			"retry": 0
		}
	}
	GameEvents.SendCustomGameEventToServer (
		"tp_precache",
		{
			"jsArgs": trainingArgs
		}
	);
	$('#mainWindow').AddClass("Hidden")

}
function startMoveAimTraining() {
	var player=Game.GetLocalPlayerID()
	var trainingArgs={
		"moving_aim_training_start":
		{
			"player": player,
			"retry": 0
		}
	}
	GameEvents.SendCustomGameEventToServer (
		"tp_precache",
		{
			"jsArgs": trainingArgs
		}
	);
	$('#mainWindow').AddClass("Hidden")

}

function startMorphTraining() {
	var player=Game.GetLocalPlayerID()
	var trainingArgs={
		"morph_training_start":
		{
			"player": player,
			"retry": 0
		}
	}
	GameEvents.SendCustomGameEventToServer (
		"tp_precache",
		{
			"jsArgs": trainingArgs
		}
	);
	$('#mainWindow').AddClass("Hidden")

}

function startMantaChallenge(){
	GameEvents.SendCustomGameEventToServer("manta_challenge_start",{})
	$('#mainWindow').AddClass("Hidden")
}
function startSkillshotTraining() {
	var selectedSkill=getSsSkill()
	if (selectedSkill){
		var player=Game.GetLocalPlayerID()
		var trainingArgs

		if (MAP_NAME=="dota"){
			trainingArgs={
			"skillshot_training_v2":
				{
					"player": player,
					"skill_id": selectedSkill
				}
			}
		}else{
			trainingArgs={
			"skillshot_training":
				{
					"player": player,
					"skill_id": selectedSkill
				}
			}
		
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
		/*GameEvents.SendCustomGameEventToServer (
			"skillshot_training",
			{
				"player": player,
				"skill_id": selectedSkill
			})*/
		$('#mainWindow').AddClass("Hidden")
	}
	

}
function getTimingInfo() {
	var rubick_mode = 0

	for (var i = 0; i < eul_primary.length; i++)
		if ($('#timing_prim_check'+i).checked)
			timingType=i
	var eulSkillId = getEnabledEulSkill()
	if ($('#timingRubick').checked)
		rubick_mode = 1
	$.Msg('primSKill',timingType)
	$.Msg('secSkill',eulSkillId)
	
	if (eulSkillId) {
		GameEvents.SendCustomGameEventToServer (
			"euls_training",
			{
				"rubick_mode" : rubick_mode,
				"skillId": eulSkillId,
				"timingType" : timingType
			}
		);
		//$('#mainWindow').AddClass("Hidden")
	} else
		showPanel($('#eulErrorMsg'))
}
function TimingStart() {
	var rubick_mode = 0

	for (var i = 0; i < eul_primary.length; i++)
		if ($('#timing_prim_check'+i).checked)
			timingType=i
	if ($('#timingRubick').checked)
		rubick_mode = 1
	var eulSkillId = getEnabledEulSkill()
	$.Msg('primSKill',timingType)
	$.Msg('secSkill',eulSkillId)
	
	if (eulSkillId) {
		/*var trainingArgs={
			"euls_training":
			{
				"skillId": eulSkillId,
				"timingType" : timingType,
				"rubick_mode" : rubick_mode,
				"start":1
			}
		}*/
		var trainingArgs={
			"old_timing_start":
			{
				"skillId": eulSkillId,
				"timingType" : timingType,
				"timebar" : rubick_mode,
				"lense":1,
				"blink":1
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
		$('#mainWindow').AddClass("Hidden")
	} else
		showPanel($('#eulErrorMsg'))
}
$('#tpMode1').AddClass("Activated")
$('#tpMode1').checked = true
function StartGlimpseTraining() {
	var player = Game.GetLocalPlayerID()
	var timebar = 0
	var level=0
	for (var i = 1; i < 5; i++) {
		if ($('#glimpse_level_'+i).checked==true){
			level=i
		}
	}
	if ($('#timebarToggleGlimpse').checked)
		timebar=1
	var tpMode
	$.Each($("#TPmodButtons").Children(), function(oPanel) {
		if(oPanel.checked)
			tpMode=oPanel.id
	});
	var glimpseSkillId=getEnabledGlimpseSkill()
	if (glimpseSkillId) {
		var trainingArgs={
			"start_glimpse":
			{
				"player": player,
				"timebar": timebar,
				"skillId": glimpseSkillId,
				"tpMode":tpMode,
				"level":level
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
		$('#mainWindow').AddClass("Hidden")
	} else
		showPanel($('#glimpseErrorMsg'))
	
}

function startOtherTraining(){
	var timebar = 0
	if ($('#timebarToggle2').checked)
		timebar=1
	var procast=getSelectedOther()
	if (procast==1){
		var trainingArgs={
			"alche_start":
			{
				"timebar" : timebar,
				"skillId": 420
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
	}
	if (procast==2){
		var trainingArgs={
			"kunnka_training_start":
			{
				"procast": procast-1,
				"timebar": timebar
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
	}
	if (procast==3){
		var trainingArgs={
			"kunnka_training_start":
			{
				"procast": procast-1,
				"timebar": timebar
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
	}
	if (procast==4){
		var trainingArgs={
			"deam_coil_escape":
			{
				"procast": procast-1,
				"timebar": timebar
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
	}
	
	$('#mainWindow').AddClass("Hidden")
}

function getSelectedOther(){
	var selectedProcast=0
	for (var i = 1; i < 5; i++) {
		if ($('#other_'+i).checked==true){
			selectedProcast=i
		}
	}
	return selectedProcast
}

function getSelectedProcast(){
	var selectedProcast=0
	for (var i = 0; i < 6; i++) {
		if ($('#combo_'+i).checked==true){
			selectedProcast=i
		}
	}
	return selectedProcast
}

function startProcastTraining(basicMode){
	$.Msg('Invoker training started!')

	var procast=getSelectedProcast()
	$.Msg('procast:',procast)
	var invokeOneSphere=0
	var invokeOneTarget=0
	if (procast==0){
		if ($('#singleTarget').checked==true){
			invokeOneTarget=1
		}else{
			invokeOneTarget=0
		}
		if ($('#oneSphere').checked==true){
			invokeOneSphere=1
		}else{
			invokeOneSphere=0
		}
		$.Msg('invokeOneTarget',invokeOneTarget)
		$.Msg('invokeOneSphere',invokeOneSphere)
		$.Msg('basicMode',basicMode)
		var trainingArgs={
			"invoker_invoke_training":
			{
				"procast": procast,
				"oneTarget": invokeOneTarget,
				"oneSphere": invokeOneSphere,
				"basicMode": basicMode
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
	}else{
		var trainingArgs={
			"invoker_procast_start":
			{
				"procast": procast
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);
	}
	
	$('#mainWindow').AddClass("Hidden")
}
function startInvokerChallenge(){
	GameEvents.SendCustomGameEventToServer (
		"invoker_invoke_training",
		{
			"oneTarget": 0,
			"oneSphere": 0,
			"basicMode": 0,
			"challenge": 1
		}
	);
	$('#mainWindow').AddClass("Hidden")
}
function openMainMenu() {
	var welcomeMenu = $('#welcomeWindow')
	welcomeMenu.style['visibility'] = 'collapse'
}
function hidePanel(panel) {
	AnimatePanel(panel, {"opacity": "0;"}, 0.5, "ease-in")
	$.Schedule(0.5, function() {
		panel.style['visibility']='collapse';
	})
}
function showPanel(panel) {
	panel.style['visibility'] = 'visible'
	$.Schedule(0.5, function() {
		AnimatePanel(panel, {"opacity": "1;"}, 0.5, "ease-in");
	})
}

function getEnabledSkills() {
	var skills_arr = []
	for (var i = 0; i < skillCount; i++)
		if ($('#skill_check_'+ids[i]).checked)
			skills_arr.push(ids[i])
	return skills_arr
}

function selectAllSkills() {
	for (var i = 0; i < skillCount; i++) {
		//$('#skill_check_'+i).AddClass("Activated")
		if (ids[i] !== 420)
			if ($('#mantaBlink').checked==true){
				if (creeps_ids.indexOf(ids[i])==-1){
					$('#skill_check_'+ids[i]).checked=true;
				}
			}else{
				$('#skill_check_'+ids[i]).checked=true;
			}
	};
}
function unmarkAllSkills() {
	for (var i = 0; i < skillCount; i++) {
		//$('#skill_check_'+i).AddClass("Activated")
		if (ids[i] !== 420)
			$('#skill_check_'+ids[i]).checked=false;
	};
}


function drawSkillList() {
	var skillsInRow = 6

	var lastRow = skillCount % skillsInRow
	var rowsCount
	if (lastRow > 0)
		rowsCount = (skillCount - lastRow) / skillsInRow + 1
	else
		rowsCount=skillCount/skillsInRow

	for (var i = 0; i < rowsCount; i++) {
		var currentRow = drawSkillRow(skillPanel, i)

		for (var j = 0; j < skillsInRow; j++) {
			arrayID = i * skillsInRow + j
			if (arrayID<skillCount)
				drawSkill(currentRow,skills[arrayID],ids[arrayID])
		};
	};
}


function drawSkill(parentPanel, skill, id) {
	var Skill = $.CreatePanel('Panel', parentPanel, 'skill_' + id)
	Skill.AddClass("skill")
	var SkillImage = $.CreatePanel('DOTAAbilityImage', Skill, 'skillImg_' + id)
	SkillImage.abilityname = skill
	var SkillCheck = $.CreatePanel('ToggleButton', Skill, 'skill_check_' + id)
	SkillCheck.AddClass("volvoCheckbox")
	SkillCheck.AddClass("skillCheckbox")
	//excludes:
	//hookshot lvl
	var SkillExt=$.CreatePanel('Label', Skill, 'skill_ext_' + id)
	if (id === 32 || id === 20) {
		SkillExt.AddClass("skillExtension")
		SkillExt.text="Lvl 1"
	}
	if (id === 33 || id === 55){
		SkillExt.AddClass("skillExtension")
		SkillExt.text = "Lvl 2"
	}
	if (id === 34 || id === 56){
		SkillExt.AddClass("skillExtension")
		SkillExt.text = "Lvl 3"
	}
	//shaker totem scepter
	if (id === 26) {
		SkillExt.AddClass("skillExtension")
		SkillExt.text = "Aghanim"
	}
	if (id === 66) {
		SkillExt.AddClass("skillExtension")
		SkillExt.text = "Invis"
	}

}

function drawSkillRow(parentPanel, id) {
	var Row = $.CreatePanel('Panel', parentPanel, 'row_' + id)
	Row.AddClass("skillRow")
	return Row
}

//---------------------------------------------------------------------------------------------------draw eul skills
function drawEulPrimarySkills() {
	for (var i = 0; i < eul_primary.length; i++) {
		var currentRow = drawEulPrimarySkill(i)
	};
}
function drawEulPrimarySkill(id) {
	var parentPanel=$('#timingType')
	var container=$.CreatePanel('Panel', parentPanel, 'timing_cont_' + id)
	container.AddClass('timingEntry')
	var SkillImage = $.CreatePanel('DOTAAbilityImage', container, 'timing_prim_img_' + id)
	SkillImage.abilityname = eul_primary[id]

	var SkillCheck = $.CreatePanel('ToggleButton', container, 'timing_prim_check' + id)
	SkillCheck.AddClass("volvoCheckbox") 
	if (id==0){
		SkillCheck.checked=true
	}
	SkillCheck.SetPanelEvent (
	"onactivate", 
		function() {
			SkillCheck.checked=true
			unmarkAllPrimarySkills(id)
			getTimingInfo()
		}
	)
}
function unmarkAllPrimarySkills(exclude) {
	for (var i = 0; i < eul_primary.length; i++) {
		//$('#skill_check_'+i).AddClass("Activated")
		if (i !== exclude)
			$('#timing_prim_check'+i).checked=false;
	};
}
function drawEulSkillList() {

	//var eul_array=eul_skills
	var eul_array=eul_skills_old
	var id_counter=1
	var start=0
	var rowW=6
	var count=eul_array.length
	var skillsInRow = rowW

	var lastRow = count % skillsInRow
	var rowsCount
	if (lastRow > 0)
		rowsCount = (count - lastRow) / skillsInRow + 1
	else
		rowsCount = count / skillsInRow

	for (var i = 0; i < count; i++) {
		drawEulSkill(eulSkillPanel, eul_array[i], i)
	}
	/*for (var i = 0; i < rowsCount; i++) {
		var currentRow = drawEulSkillRow(eulSkillPanel,i)

		for (var j = 0; j <skillsInRow; j++) {
			arrayID = i * skillsInRow + j
			if (arrayID < count)
				drawEulSkill(currentRow, eul_skills[arrayID + start], id_counter)
				id_counter+=1 
		};
	};*/
}

function drawEulSkill(parentPanel, skill, id) {
	var Skill = $.CreatePanel('Panel', parentPanel, 'eul_skill_' + id)
	Skill.AddClass("skill")
	var SkillImage = $.CreatePanel('DOTAAbilityImage', Skill, 'eul_skillImg_' + id)
	SkillImage.abilityname = skill
	var SkillCheck = $.CreatePanel('RadioButton', Skill, 'eul_skill_check_' + id)
	SkillCheck.AddClass("volvoRadioButton")
	SkillCheck.AddClass("skillCheckbox")
	SkillCheck.group="eul_skill_group"
	//excludes:
/*	if (id==28){
		SkillCheck.enabled=false
	}*/
	if (id === 6 || id === 13 ) {
		var SkillExt = $.CreatePanel('Label', Skill, 'skill_ext_' + id)
		SkillExt.AddClass("skillExtension")
		SkillExt.text="Aghanim"
		
	}
	SkillCheck.SetPanelEvent (
	"onactivate", 
		function() {
			getTimingInfo()
		}
	)
}
function drawEulSkillRow(parentPanel, id){
	var Row = $.CreatePanel('Panel', parentPanel, 'row_' + id)
	Row.AddClass("skillRow")
	return Row
}

function drawEulSkillLabel(parentPanel, id, text, info) {
	var container = $.CreatePanel('Panel', parentPanel, 'row_' + id)
	container.style['flow-children'] = "right"
	if (info) {
		var tooltipIcon = $.CreatePanel('Panel', container, 'row_tt_' + id)
		tooltipIcon.AddClass("skillToolTip")
		makeTooltip(tooltipIcon, info)
	}
	
	var label = $.CreatePanel('Label', container, 'row_'+id)
	label.AddClass("skillGroupTitle")
	label.text = text
	return label
}

function getEnabledEulSkill() {
	//var eul_array=eul_skills
	var eul_array=eul_skills_old
	var skill
	//$.Msg('eul_array len:',eul_array.length)
	for (var i = 1; i <= eul_array.length-1; i++)
		//$.Msg('#eul_skill_check_' + i)
		if($('#eul_skill_check_' + i).checked)
			skill=i
	return skill+1
}

//------------------------------------------------------------------------------------------------------draw glimpse skills

function drawGlimpseSkillList(start, count, skillsInRow) {
	var lastRow = count % skillsInRow
	var rowsCount
	if (lastRow > 0)
		rowsCount = (count - lastRow) / skillsInRow + 1
	else
		rowsCount = count / skillsInRow

	for (var i = 0; i <rowsCount; i++) {
		var currentRow=drawGlimpseSkillRow(glimpseSkillPanel,i)

		for (var j = 0; j < skillsInRow; j++) {
			arrayID=i*skillsInRow + j
			if (arrayID<count)
				drawGlimpseSkill(currentRow,glimpse_skills[arrayID+start],glimpse_ids[arrayID+start])
		};
	};
}

function drawGlimpseSkill(parentPanel, skill, id, info) {
	var Skill = $.CreatePanel('Panel', parentPanel, 'glimpse_skill_' + id)
	Skill.AddClass("skill")
	var SkillImage = $.CreatePanel('DOTAAbilityImage', Skill, 'glimpse_skillImg_' + id)
	SkillImage.abilityname = skill
	var SkillCheck = $.CreatePanel('RadioButton', Skill, 'glimpse_skill_check_' + id)
	SkillCheck.AddClass("volvoRadioButton")
	SkillCheck.AddClass("skillCheckbox")
	SkillCheck.group = "glimpse_skill_group"
	if (id==6 || id==7){
		SkillCheck.SetPanelEvent (
			"onselect", 
			function() {
				$('#glimpseLvl').style['visibility']='visible'	
			}
		)
	}else{
		SkillCheck.SetPanelEvent (
			"onselect", 
			function() {
				$('#glimpseLvl').style['visibility']='collapse'	
			}
		)
	}
}

function drawGlimpseSkillRow(parentPanel, id) {
	var Row = $.CreatePanel('Panel', parentPanel, 'row_' + id)
	Row.AddClass("skillRow")
	return Row
}

function getEnabledGlimpseSkill() {
	var skill
	for (var i = 0; i < glimpseSkillCount; i++)
		if ($('#glimpse_skill_check_'+glimpse_ids[i]).checked)
			skill=glimpse_ids[i]
	return skill
}
//------------------------------------------------------------------------------------------------------draw armlet heroes

function drawArmletHeroList(heroes_in_row) {
	var drawPanel=$('#armletHeroPool')
	var arm_count=armlet_heroes.length
	var lastRow = arm_count % heroes_in_row
	var rowsCount
	if (lastRow > 0)
		rowsCount = (arm_count - lastRow) / heroes_in_row + 1
	else
		rowsCount = arm_count / heroes_in_row
	for (var i = 0; i <rowsCount; i++) {
		var currentRow=drawArmletHeroRow(drawPanel,i)

		for (var j = 0; j < heroes_in_row; j++) {
			arrayID=i*heroes_in_row + j
			if (arrayID<arm_count)
				drawArmletHero(currentRow,armlet_heroes[arrayID],armlet_ids[arrayID])
		};
	};
}

function drawArmletHero(parentPanel, hero, id, info) {
	var Selector = $.CreatePanel('Panel', parentPanel, 'armlet_hero_' + id)
	Selector.AddClass("armletHeroSelector")
	Selector.SetPanelEvent (
	"onactivate", 
		function() {
			Selector.AddClass("armletHeroSelected")
			unmarkAllHeroes(id)
		}
	)
	if (hero=="npc_dota_goodguys_tower1_mid" || hero=="npc_dota_goodguys_tower2_mid"){
		var HeroThumb = $.CreatePanel('Panel', Selector, 'armlet_unit_Img_' + id)
		HeroThumb.AddClass("armletTowerThumb")
		HeroThumb.AddClass("armletThumb")
		if (hero=="npc_dota_goodguys_tower1_mid"){
			makeTooltip(Selector, "Tier 1 tower")
		}else{
			makeTooltip(Selector, "Tier 2-4 tower. Their damage and attack speed are same.")
		}
	}else{
		var HeroThumb = $.CreatePanel('DOTAHeroImage', Selector, 'armlet_unit_Img_' + id)
		HeroThumb.heroimagestyle="icon"
		HeroThumb.heroname=hero
		HeroThumb.AddClass("armletThumb")
	}
	
}

function drawArmletHeroRow(parentPanel, id) {
	var Row = $.CreatePanel('Panel', parentPanel, 'armlet_row_' + id)
	Row.AddClass("skillRow")
	return Row
}
function unmarkAllHeroes(exclude) {
	var arm_count=armlet_heroes.length
	for (var i = 0; i < arm_count; i++) {
		//$('#skill_check_'+i).AddClass("Activated")
		if (armlet_ids[i] !== exclude)
			$('#armlet_hero_'+armlet_ids[i]).RemoveClass('armletHeroSelected');
	};
}

function getEnabledArmletUnit() {
	var unit
	for (var i = 0; i < armlet_heroes.length; i++)
		if ($('#armlet_hero_'+armlet_ids[i]).BHasClass("armletHeroSelected"))
			unit=armlet_heroes[i]
	return unit
}
//------------------------------------------------------------------------------------------------------draw glimpse skills
//------------------------------------------------------------------------------------------------------draw armlet heroes
drawLastHitHeroList(10)
function drawLastHitHeroList(heroes_in_row) {
	var drawPanel=$('#lhHeroPicker')
	var arm_count=lasthit_heroes.length
	var lastRow = arm_count % heroes_in_row
	var counter=0
	var rowsCount
	if (lastRow > 0)
		rowsCount = (arm_count - lastRow) / heroes_in_row + 1
	else
		rowsCount = arm_count / heroes_in_row
	for (var i = 0; i <rowsCount; i++) {
		var currentRow=drawLastHitHeroRow(drawPanel,i)

		for (var j = 0; j < heroes_in_row; j++) {
			arrayID=i*heroes_in_row + j
			if (arrayID<arm_count)
				drawLastHitHero(currentRow,lasthit_heroes[arrayID],counter)
				counter+=1
		};
	};
}

function drawLastHitHero(parentPanel, hero, id, info) {
	var Selector = $.CreatePanel('Panel', parentPanel, 'lh_hero_' + hero)
	Selector.AddClass("armletHeroSelector")
	if (hero=="npc_dota_hero_abaddon"){
		Selector.AddClass("armletHeroSelected")
	}
	Selector.SetPanelEvent (
	"onactivate", 
		function() {
			Selector.AddClass("armletHeroSelected")
			unmarkAllLasthit(hero)
			$.Msg(Selector.id)
		}
	)

	var HeroThumb = $.CreatePanel('DOTAHeroImage', Selector, 'armlet_unit_Img_' + id)
	HeroThumb.heroimagestyle="icon"
	HeroThumb.heroname=hero
	HeroThumb.AddClass("armletThumb")

	
}

function drawLastHitHeroRow(parentPanel, id) {
	var Row = $.CreatePanel('Panel', parentPanel, 'armlet_row_' + id)
	Row.AddClass("skillRow")
	return Row
}
function unmarkAllLasthit(exclude) {
	$.Each($("#lhHeroPicker").Children(), function( oPanel )
	{	
		$.Each(oPanel.Children(), function( oPanel )
		{
			if (oPanel.id!='lh_hero_' + exclude){
				
				oPanel.RemoveClass('armletHeroSelected')
			}
		});
		
	});
}
 
function getEnabledLastHitUnit() {
	var unit=null
	for (var i = 0; i < lasthit_heroes.length; i++)
		if ($('#lh_hero_'+lasthit_heroes[i]).BHasClass("armletHeroSelected"))
			unit=lasthit_heroes[i]
	return unit
}
//------------------------------------------------------------------------------------------------------draw glimpse skills

function drawSsSkillList(start, count, skillsInRow) {
	var lastRow = count % skillsInRow
	var rowsCount
	if (lastRow > 0)
		rowsCount = (count - lastRow) / skillsInRow + 1
	else
		rowsCount = count / skillsInRow

	for (var i = 0; i <rowsCount; i++) {
		var currentRow=drawSsSkillRow(ssSkillPanel,i)

		for (var j = 0; j < skillsInRow; j++) {
			arrayID=i*skillsInRow + j
			if (arrayID<count)
				drawSsSkill(currentRow,ss_skills[arrayID+start],ss_ids[arrayID+start])
		};
	};
}

function drawSsSkill(parentPanel, skill, id, info) {
	var Skill = $.CreatePanel('Panel', parentPanel, 'ss_skill_' + id)
	Skill.AddClass("skill")
	var SkillImage = $.CreatePanel('DOTAAbilityImage', Skill, 'ss_skillImg_' + id)
	SkillImage.abilityname = skill
	var SkillCheck = $.CreatePanel('RadioButton', Skill, 'ss_skill_check_' + id)
	if (id==1){
		SkillCheck.checked=true
	}
	SkillCheck.AddClass("volvoRadioButton")
	SkillCheck.AddClass("skillCheckbox")
	SkillCheck.group = "ss_skill_group"
}

function drawSsSkillRow(parentPanel, id) {
	var Row = $.CreatePanel('Panel', parentPanel, 'row_' + id)
	Row.AddClass("skillRow")
	return Row
}

function getSsSkill() {
	var skill
	for (var i = 0; i < ssSkillCount; i++)
		if ($('#ss_skill_check_'+ss_ids[i]).checked)
			skill=ss_ids[i]
	return skill
}
//---------------------------------------------------------------------------------------------------------

makeTooltip($('#timebarToggle'), $.Localize("#timebarTooltip"))
//makeTooltip($('#customMode'),"Custom mode allows you train skills that you select.")


function makeTooltip(panel, tooltip) {
	panel.SetPanelEvent(
		"onmouseover", 
		function() {
			$.DispatchEvent("DOTAShowTextTooltip", panel, tooltip);
		}
	)
	panel.SetPanelEvent(
		"onmouseout", 
		function() {
			$.DispatchEvent("DOTAHideTextTooltip", panel);
		}
	)
}
$('#euls').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#eulsInfo'));
			showPanel($('#eulSettings'))
		})
	}
)
$('#euls').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#eulsInfo'))
		hidePanel($('#eulSettings'))
	}
)
$('#manta').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#mantaInfo'));
			showPanel($('#mantaSettings'))
		})
	}
)
$('#manta').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#mantaInfo'))
		hidePanel($('#mantaSettings'))
	}
)
$('#glimpse').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#glimpseInfo'));
			showPanel($('#glimpseSettings'))
		})
	}
)
$('#glimpse').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#glimpseInfo'))
		hidePanel($('#glimpseSettings'))
	}
)
$('#armlet').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#armletInfo'));
			showPanel($('#armletSettings'))
		})
	}
)
$('#armlet').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#armletInfo'))
		hidePanel($('#armletSettings'))
	}
)
$('#aim').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#aimInfo'));
			showPanel($('#aimSettings'))
		})
	}
)
$('#aim').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#aimInfo'))
		hidePanel($('#aimSettings'))
	}
)
$('#invoker').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#invInfo'));
			showPanel($('#invSettings'))
		})
	}
)
$('#invoker').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#invInfo'))
		hidePanel($('#invSettings'))
	}
)
$('#challange').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			$('#centerInfo').style['width']='60%;'
			$('#rightSettings').style['width']='20%;'
			showPanel($('#challangeInfo'));
			showPanel($('#challangeSettings'))
			clearLeaderboard()
			getLeaderboard('aim',false)
		})
	}
)
$('#challange').SetPanelEvent (
	"ondeselect", 
	function() {
		clearLeaderboard()
		$('#centerInfo').style['width']='40%;'
		$('#rightSettings').style['width']='40%;'
		hidePanel($('#challangeInfo'))
		hidePanel($('#challangeSettings'))
	}
)
$('#skillshot').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#skillshotInfo'));
			showPanel($('#skillshotSettings'))
		})
	}
)
$('#skillshot').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#skillshotInfo'))
		hidePanel($('#skillshotSettings'))
	}
)
$('#last_hit_training').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#lastHitInfo'));
			showPanel($('#lastHitSettings'))
		})
	}
)
$('#last_hit_training').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#lastHitInfo'))
		hidePanel($('#lastHitSettings'))
	}
)
$('#other_stuff').SetPanelEvent (
	"ondeselect", 
	function() {
		hidePanel($('#otherInfo'))
		hidePanel($('#otherSettings'))
	}
)
$('#other_stuff').SetPanelEvent (
	"onselect", 
	function() {
		$.Schedule(0.6, function() {
			showPanel($('#otherInfo'));
			showPanel($('#otherSettings'))
		})
	}
)
$('#aim_challenge').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('aim',false)
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startAimTraining();
			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"ondeselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('aim',false)

			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"onselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('aim',true)
			}
		)

	}
)
$('#aim_challenge2').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('aim2',false)
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startAimTraining2();
			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"ondeselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('aim2',false)

			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"onselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('aim2',true)
			}
		)

	}
)
$('#aim_challenge3').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('aim3',false)
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startAimTraining3();
			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"ondeselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('aim3',false)

			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"onselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('aim3',true)
			}
		)

	}
)
$('#map_aim_challenge').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('map_aim',false)
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startMapAimTraining();
			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"ondeselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('map_aim',false)

			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"onselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('map_aim',true)

			}
		)

	}
)
$('#move_aim_challenge').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('move_aim',false)
		$.Msg('Kek')
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startMoveAimTraining();
			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"ondeselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('move_aim',false)

			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"onselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('move_aim',true)

			}
		)

	}
)
$('#morph').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('morph',false)
		$.Msg('Kek')
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startMorphTraining();
			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"ondeselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('morph',false)

			}
		)
		$('#leaderboardFriends').SetPanelEvent (
			"onselect", 
			function() {
				clearLeaderboard()
				getLeaderboard('morph',true)

			}
		)

	}
)
$('#manta_challenge').SetPanelEvent (
	"ondeselect", 
	function() {
		
	}
)
$('#manta_challenge').SetPanelEvent (
	"onselect", 
	function() {
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startMantaChallenge();
			}
		)
		$.Schedule(0.6, function() {
			
		})
	}
)
$('#invoker_challenge').SetPanelEvent (
	"onselect", 
	function() {
		clearLeaderboard()
		getLeaderboard('inv_sur',false)
		$("#startChallenge").SetPanelEvent (
			"onactivate", 
			function() {
				startInvokerChallenge();
			}
		)

	}
)

//otherSettings
/*$('#challangeMode').SetPanelEvent(
  "onselect", 
  function(){
    hidePanel($('#customSettings'))
    mantaMode=1
  }
)
$('#customMode').SetPanelEvent(
  "onselect", 
  function(){
    showPanel($('#customSettings'))
    mantaMode=0
  }
)*/
/*function cheatsOn(){
	showPanel($('#pingSetup'))
	$.Msg("kek")
}
function checkPing(){
	var clientTime=Game.Time()
	GameEvents.SendCustomGameEventToServer( "ping_setting", {"client_time" : clientTime} );
}*/

function CmdHideMenu() {
	$('#mainWindow').AddClass("Hidden")
}

function CmdShowMenu() {
	$('#mainWindow').RemoveClass("Hidden")
}
function QuitGame() {
	//ContinueButton -> GameEnd -> GameEndContainer -> Hud
	GameEvents.SendCustomGameEventToServer( "training_polygon_end", {} );

	

/*	var Hud=dotaui.FindChild("Hud")
	$.Msg(Hud.id)
	var GameEndContainer=Hud.FindChild('GameEndContainer')
	$.Msg(GameEndContainer.id)*/ 

}
function loadingUpdate(info){
	if (info.current==1){
		showLoading()
	}
	var width=(info.current/info.total)*100
	$('#loadingBar').style['width']=width+'%;'
	$('#loading_name').text=info.name
	$('#loadingBar').style['visibility']='visible;'
}
var leaderboard
var leaderboard_width=890
function getLeaderboard(tableMode,friends){
	GameEvents.SendCustomGameEventToServer (
		"web_req_from_client",
		{
			url: url,
			type: 'POST',
            data: {
				request: 'getLeaderboard',
				Mode: tableMode,
				friend_mode: friends,
				steamid: steamID64
			}
		}
	);
    
} 
function drawLeaderboard(table){
	$.Msg(table)
	$.Schedule(0.2, function() {
		drawLeaderboardHeader(table[0]['other'])
		var row_counter=0
		$.Msg('table len:',table.length)
		drawLeaderboardRows(table,1)
	})
	
/*	for (var i = 0; i < table.length; i++) {
		drawLeaderboardRow(table[i],i+1)
	}*/
	/*$.Msg(table[0]['other']['avg'])*/
	for (var row in table){
		/*$.Msg('row:',table[row]) */
		for (var col in table[row]){
			/*$.Msg(col,table[row][col])*/
		}
		/*$.Msg(rowEncoded.steam)*/   
		
	}
}
var col_to_draw

function drawLeaderboardHeader(other){
	var leaderboard=$('#leaderboardContainer')
	var freeSpace=1100-50-600
	var col_count=3
	var col_name_alias={
		"num" : "№",
		"player" : "Player",
		"score" : "Score",
		"avg" : "Avg. time",
		"combo" : "Max combo",
		"ping" : "Ping"
	}
	col_to_draw=["num","player","score","ping"]
	if (other!=null){
		for (var col in other){
			col_to_draw.push(col)
		}
	} 
	var col_count=col_to_draw.length
	var other_col_w=freeSpace/(col_count-2)
	for (var i in col_to_draw){
		var col=$.CreatePanel('Panel', leaderboard, 'col_'+col_to_draw[i])
		col.AddClass("col")
		if (i>1){
			col.style['width']=other_col_w+'px;'
		}
		var label=$.CreatePanel('Label',col,'head_'+col_to_draw[i])
		label.AddClass('leaderboardLabel')
		label.text=col_name_alias[col_to_draw[i]]
	}

}
 
function drawLeaderboardRows(table,place){
 	var data=table[place-1]
	var placeRow=$.CreatePanel('Panel',$('#col_num'),'num_row_'+place)
	placeRow.AddClass('row')
	placeRow.AddClass('rowCenter')
	var placeLabel=$.CreatePanel('Label',placeRow,'num_'+place)
	placeLabel.AddClass('leaderboardLabel')
	placeLabel.text=place
	var playerContainer=$.CreatePanel('Panel',$('#col_player'),'player_row_'+place)
	playerContainer.AddClass('playerContainer')
	playerContainer.AddClass('row')
	var playerAvatar=$.CreatePanel('DOTAAvatarImage',playerContainer,'player_avatar_'+place)
	playerAvatar.steamid=data['steam']
	playerAvatar.style['width']='50px;'
	playerAvatar.style['height']='50px;'
	var nicknameContainer=$.CreatePanel('Panel',playerContainer,'name_container_'+place)
	nicknameContainer.AddClass('nicknameContainer')
	var nickname=$.CreatePanel('Panel',nicknameContainer,'name_'+place)
	nickname.AddClass('nicknameRow')
	var playerNickname=$.CreatePanel('DOTAUserName',nickname,'player_name_'+place)
	playerNickname.AddClass('leaderboardLabel')
	playerNickname.steamid=data['steam']
	if (data['trophy']!='' && data['trophy']!=null){
		
		for (var i = 0; i < data['trophy'].length; i++) {

			var playerTrophy=$.CreatePanel('Panel',nickname,'trophy_'+place)
			playerTrophy.AddClass(data['trophy'][i]['r'])
			if (data['trophy'][i]['q']>1){
				quantityLabel=$.CreatePanel('Label',nickname,'trophy_q_'+place)
				quantityLabel.AddClass('leaderboardLabel')
				quantityLabel.text="x"+data['trophy'][i]['q']
			}
			var tooltip_localed=$.Localize('#'+data['trophy'][i]['r'])
			makeTooltip(playerTrophy,tooltip_localed)
			
				
			
		}
		
		
	}
	

	var scoreRow=$.CreatePanel('Panel',$('#col_score'),'score_'+place)
	scoreRow.AddClass("row")
	scoreLabel=$.CreatePanel('Label',scoreRow,'score_l_'+place)
	scoreLabel.AddClass('leaderboardLabel')
	if ($('#morph').checked){
		scoreLabel.text=data['score']/1000
	}else{
		scoreLabel.text=data['score']
	}
	var pingRow=$.CreatePanel('Panel',$('#col_ping'),'ping_'+place)
	pingRow.AddClass("row")
	pingLabel=$.CreatePanel('Label',pingRow,'ping_l_'+place)
	pingLabel.AddClass('leaderboardLabel')
	pingLabel.text=data['ping']
	if (data['lvl']>0){
		$.Msg('lvl:',data['lvl'])
		var classLevel='leaderboardLevel'+data['lvl']
		placeRow.AddClass(classLevel)
		playerContainer.AddClass(classLevel)
		scoreRow.AddClass(classLevel)
	}
	if (data['other']!=null){
		for (var col in data['other']){
			var otherRow=$.CreatePanel('Panel',$('#col_'+col),col+'_'+place)
			otherRow.AddClass("row")
			if (data['lvl']>0){
				var classLevel='leaderboardLevel'+data['lvl']
				otherRow.AddClass(classLevel)
			}
			otherLabel=$.CreatePanel('Label',otherRow,col+'_l_'+place)
			otherLabel.AddClass('leaderboardLabel')
			otherLabel.text=data['other'][col]
		}
	}
	if (place<table.length){
		drawLeaderboardRows(table,place+1)
	}
} 
function clearLeaderboard(){
	var leaderboard=$('#leaderboardContainer')
	$.Each(leaderboard.Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});
}
$('#popup').style['opacity']='0'
$('#popup').style['visibility']='collapse'
function resultPopup(info){

	if (info.highscore==1){
		$('#popupTitle').text=$.Localize("#lb_highscore")
		$('#lb_good').style['visibility']='visible'
		$('#lb_bad').style['visibility']='collapse'
		$("#lb_good").SetDialogVariable( "score", info.score )
		$("#lb_good").SetDialogVariable( "place", info.place )
		$("#lb_good").SetDialogVariable( "total", info.total )
	}else{
		$('#popupTitle').text=$.Localize("#lb_nothighscore")
		$('#lb_bad').style['visibility']='visible'
		$('#lb_good').style['visibility']='collapse'
		$("#lb_bad").SetDialogVariable( "last_result", info.score )
	}
	showPanel($('#popup'))
	if (info.mod=='aim'){
		$('#lb_restart').SetPanelEvent (
		"onactivate", 
			function() {
				startAimTraining()
				hidePanel($('#popup'))
				
			}
		)
		$('#lb_exit').SetPanelEvent (
		"onactivate", 
			function() {
				trainingEnds()
				hidePanel($('#popup'))
				GameEvents.SendCustomGameEventToServer("aim_end", {});
			}
		)
	}
	if (info.mod=='aim2'){
		$('#lb_restart').SetPanelEvent (
		"onactivate", 
			function() {
				startAimTraining2()
				hidePanel($('#popup'))
				
			}
		)
		$('#lb_exit').SetPanelEvent (
		"onactivate", 
			function() {
				trainingEnds()
				hidePanel($('#popup'))
				GameEvents.SendCustomGameEventToServer("aim_end2", {});
			}
		)
	}
	if (info.mod=='aim3'){
		$('#lb_restart').SetPanelEvent (
		"onactivate", 
			function() {
				startAimTraining3()
				hidePanel($('#popup'))
				
			}
		)
		$('#lb_exit').SetPanelEvent (
		"onactivate", 
			function() {
				trainingEnds()
				hidePanel($('#popup'))
				GameEvents.SendCustomGameEventToServer("aim_end3", {});
			}
		)
	}
	if (info.mod=='map_aim'){
		$('#lb_restart').SetPanelEvent (
		"onactivate", 
			function() {
				startMapAimTraining()
				hidePanel($('#popup'))
				
			}
		)
		$('#lb_exit').SetPanelEvent (
		"onactivate", 
			function() {
				trainingEnds()
				hidePanel($('#popup'))
				GameEvents.SendCustomGameEventToServer("map_aim_end", {});
			}
		)
	}
	if (info.mod=='move_aim'){
		$('#lb_restart').SetPanelEvent (
		"onactivate", 
			function() {
				startMoveAimTraining()
				hidePanel($('#popup'))
				
			}
		)
		$('#lb_exit').SetPanelEvent (
		"onactivate", 
			function() {
				trainingEnds()
				hidePanel($('#popup'))
				GameEvents.SendCustomGameEventToServer("map_aim_end", {});
			}
		)
	}
	if (info.mod=='morph'){
		$('#lb_restart').SetPanelEvent (
		"onactivate", 
			function() {
				startMorphTraining()
				hidePanel($('#popup'))
				
			}
		)
		$('#lb_exit').SetPanelEvent (
		"onactivate", 
			function() {
				trainingEnds()
				hidePanel($('#popup'))
				GameEvents.SendCustomGameEventToServer("morph_training_end", {});
			}
		)
	}

}









/*$('#HomeFriendList').RemoveClass("Hidden")
$('#HomeFriendList').style['opacity']='0;'
var friends=[]*/


function getFriends(panel){
	//$.Msg('type: ',panel.paneltype,' id: ',panel.id,' focus')type: SlottedSlider id: undefined focus
	if (panel.paneltype=="DOTAAvatarImage"){
		var doubleParent=panel.GetParent().GetParent()
		if (doubleParent.paneltype=="DOTAGroupMemberSlot" && doubleParent.BHasClass("NotFriend")==true){
			/*$.Msg("###NOT FRIEND###")*/
		}else{
			/*$.Msg("###FRIEND###")*/
			if (panel.steamid!=0){
				friends.push(panel.steamid)
			}
			
		}
		/*$.Msg('doubleParent.type: ',doubleParent.paneltype)
		$.Msg('doubleParent.BHasClass("NotFriend")',doubleParent.BHasClass("NotFriend"))
		$.Msg('SteamID: ',panel.steamid)
		$.Msg('###END###')*/
		
		
	}
	$.Each(panel.Children(), function( oPanel )
		{
			if (oPanel.id!='FriendsPending'){
				getFriends(oPanel)
			}
			
		});
}
function checkFriendsWorking(){
	var friend1=$('#HomeFriendList')
	var friend2=friend1.FindChild('FriendPanelMainAreaContainer')
	var friend3=friend2.FindChild('FriendPanelFriendsList')
	var friend4=friend3.FindChild('FriendListEmptyMessage')
	if (friend4.style['visibility']=="collapse"){
		getFriends($('#HomeFriendList'))
		destroyFriendPanel()
	}else{
		$.Schedule(1, checkFriendsWorking) 
	}
}
function destroyFriendPanel(){
	$.Msg('friends len: ', friends.length)
	for (var i in friends){
		$.Msg('friend:',friends[i])
	}
	$('#HomeFriendList').DeleteAsync(3)
}
/*$.Schedule(2, checkFriendsWorking) */

/**/
/*friendList()*/
/*function test1(){ 
	var leaderboard=$('#leaderboardContainer')
	playerAvatar=$.CreatePanel('DOTAUserName',leaderboard, 'kek')
	for (var i in playerAvatar){
		$.Msg(i,playerAvatar[i])
	}
}
test1()*/
/*function ReplaceDonation(panelId,name,money) {
	var defaultAvatar = $('#don_a_' + panelId)
	var defaultNickname = $('#don_n_' + panelId)
	var defaultAmmount = $('#don_m_' + panelId)
	if(Number(name)) {
		defaultAvatar.steamid = name
		defaultNickname.steamid = name 
		defaultAmmount.text = money.replace(".", ",") + " $"
	} else {
		var avatarParent = defaultAvatar.GetParent()	
		defaultAvatar.DeleteAsync(0)
		var newAvatar = $.CreatePanel('Panel', avatarParent, 'don_a_'+panelId.toString())
		newAvatar.SetHasClass('donatorNoAvatar',true)
		avatarParent.MoveChildBefore(newAvatar,avatarParent.GetChild(1))
		var nicknameParent = defaultNickname.GetParent()
		defaultNickname.DeleteAsync(0)
		var newNickName = $.CreatePanel('Label', nicknameParent, 'don_n_'+panelId.toString())
		nicknameParent.MoveChildBefore(newNickName,nicknameParent.GetChild(0))
		newNickName.AddClass('donatorNameCustom')
		newNickName.text = name
		defaultAmmount.text = money.replace(".",",")+" $"
	}
	$('#don_e_' + panelId.toString()).RemoveClass('donatorPanelHidden')
}*/

function delayUpdate(data){
	$('#delayValue').text=data.delay
	if (data.delay==0){
		$('#customDelay').style['opacity']='0;'
	}else{
		$('#customDelay').style['opacity']='1;'
	}

}
function showNudes(data){
	$.Msg('nudes: ',data.nudes)
}


var start_gold=600
$('#nowGold').text=start_gold
var common_items=[
"item_branches",
"item_clarity",
"item_faerie_fire",
"item_gauntlets",
"item_slippers",
"item_mantle",
"item_circlet",
"item_ring_of_protection",
"item_quelling_blade",
"item_blight_stone",
"item_orb_of_venom",
"item_wind_lace",
"item_magic_stick",
"item_sobi_mask",
"item_ring_of_regen",
"item_gloves",
"item_wraith_band",
"item_null_talisman",
"item_bracer",
"item_blades_of_attack",
"item_crown",
"item_boots_of_elves",
"item_robe",
"item_belt_of_strength"]
var common_items_cost=[
50,
50,
70,
140,
140,
140,
155,
175,
100,
300,
275,
250,
200,
175,
175,
450,
505,
505,
505,
450,
450,
450,
450,
450,]
var items_to_play=[]
var item_contrainer=$('#items_to_buy')
function createInvItem(name,slot){
	var parent=$('#inventory_slot_'+slot)
	var ItemImage = $.CreatePanel('DOTAAbilityImage', parent, 'item_i_' + slot)
	ItemImage.abilityname=name
	ItemImage.AddClass('itemInSlot')
	if (name=='item_clarity'){
		var count=$.CreatePanel('Label', parent, 'item_q_' + slot)
		count.text=1
	}
	ItemImage.SetPanelEvent(
		"onmouseactivate", 
		function() {
			sellItem(slot)
		}
	)
}
function buyItem(id){
	$.Msg('buy ',common_items[id])
	var item_bought=0
	if (common_items_cost[id]<=start_gold){
		for (var i = 0; i < 6; i++) {
			if (item_bought==0){
				var slot=$('#inventory_slot_'+i)
				var existed=slot.GetChild(0)
				if (common_items[id]=='item_clarity' && existed.abilityname=='item_clarity'){
					var count=slot.GetChild(1)
					count.text=parseInt(count.text)+1
					start_gold-=common_items_cost[id]
					$('#nowGold').text=start_gold
					item_bought=1
					recalculatePrice()
				}else{
					if (existed.BHasClass('invFiller')){
						existed.DeleteAsync(0)
						createInvItem(common_items[id],i)
						start_gold-=common_items_cost[id]
						$('#nowGold').text=start_gold
						item_bought=1
						recalculatePrice()
					}
				}
				
			}
			
		}
	}
}
function sellItem(slot){
	var slot=$('#inventory_slot_'+slot)
	var item_to_sell=slot.GetChild(0)
	var item_name=item_to_sell.abilityname
	for (var i = 0; i < common_items.length; i++) {
		if (item_name==common_items[i]){
			start_gold+=common_items_cost[i]
			$('#nowGold').text=start_gold
			recalculatePrice()
			if (item_name=='item_clarity'){
				var count=slot.GetChild(1)
				var count_parsed=parseInt(count.text)
				if (count_parsed>1){
					count.text=count_parsed-1
				}else{
					count.DeleteAsync(0)
					item_to_sell.DeleteAsync(0)
					var filler = $.CreatePanel('Panel', slot, 'filler_' + slot)
					filler.AddClass('invFiller')
				}
			}else{
				item_to_sell.DeleteAsync(0)
				var filler = $.CreatePanel('Panel', slot, 'filler_' + slot)
				filler.AddClass('invFiller')
			}
			
		}
		
	}
}
function activateItemTooltip(panel,id){
	var abilityname=common_items[id]
	panel.SetPanelEvent(
		"onmouseover", 
		function() {
			$.DispatchEvent("DOTAShowAbilityTooltip", panel, abilityname);
		}
	)
	panel.SetPanelEvent(
		"onmouseout", 
		function() {
			$.DispatchEvent("DOTAHideAbilityTooltip", panel);
		}
	)
	panel.SetPanelEvent(
		"onmouseactivate", 
		function() {
			buyItem(id)
		}
	)
	
}
function drawItems(){
	for (var i = 0; i < common_items.length; i++) {
		var ItemImage = $.CreatePanel('DOTAAbilityImage', item_contrainer, 'item_' + i)
		ItemImage.abilityname=common_items[i]
		ItemImage.AddClass('itemToBuy')
		ItemImage.AddClass('availableToBuy')
		activateItemTooltip(ItemImage,i)
		//DOTAShowAbilityTooltip(string abilityName)
	}
}
function recalculatePrice(){
	for (var i = common_items.length - 1; i >= 0; i--) {
		var item_panel=$('#item_'+i)
		if (common_items_cost[i]<start_gold){
			if (item_panel.BHasClass('availableToBuy')==false){
				item_panel.AddClass('availableToBuy')
				
			}
		}else{
			if (item_panel.BHasClass('availableToBuy')){
				item_panel.RemoveClass('availableToBuy')
			}
		}
	}
}
drawItems()

function getEnabledLane(){
	var lane=0
	for (var i = 0; i < 3; i++) {
		var box=$('#lane_'+i)
		if (box.checked==true){
			lane=i
		}
	}
	return lane
}
function getEnabledSide(){ 
	var side=null
	for (var i = 0; i < 2; i++) {
		var box=$('#side_'+i)
		if (box.checked==true){
			side=i
		}
	}
	return side
}
function getStartBuy(){
	var items=[]
	for (var i=0; i< 6; i++){
		var slot=$('#inventory_slot_'+i)
		var item_maybe_not=slot.GetChild(0)
		if (item_maybe_not.abilityname){
			if (item_maybe_not.abilityname=="item_clarity"){
				count=parseInt(slot.GetChild(1).text)
				for (var j = 0; j< count; j++) {
					items.push(item_maybe_not.abilityname)
				}
			}else{
				items.push(item_maybe_not.abilityname)
			}
		}
	}
	return items
}
function startLasthitTraining(){
	var hero=getEnabledLastHitUnit()
	//var lane=getEnabledLane()
	var items=getStartBuy()
	var side=getEnabledSide()
	var sniper_on=0
	if ($('#botToggle').checked)
		sniper_on = 1
	if (hero!=null && side!=null){
		var trainingArgs={
			"lasthit_start":
			{
				"hero":hero,
				/*"lane":lane,*/
				"items":items,
				"side":side,
				"sniper":sniper_on
			}
		}
		GameEvents.SendCustomGameEventToServer (
			"tp_precache",
			{
				"jsArgs": trainingArgs
			}
		);


	}else{
		showPanel($('#errorMsg'))
	}
	
	$('#mainWindow').AddClass("Hidden")
	//$('#mainWindow').AddClass("Hidden")
}
function displayDelay(info){
	$('#primCP').text=info.prim_cp.toFixed(3)
	$('#secCP').text=info.sec_cp.toFixed(3)
	$('#primImg').abilityname=info.primary_img
	$('#secImg').abilityname=info.secondary_img
	$('#primLabel').text=info.primary.toFixed(3)
	$('#secLabel').text=info.secondary.toFixed(3)
	$('#primLabelType').text=typeof(info.primary)
	$('#secLabelType').text=typeof(info.primary)
}
 
function showLoading(){
	
	$('#loadingContainer').style['opacity']='1'

}
function hideLoading(){
	$('#loadingContainer').style['opacity']='0'
}
function loadingDone(info){
	hideLoading()
	$.Msg(info.callback_args)
	var callback_f=info.callback_args
	var head_function
	for (var header in callback_f){
		head_function=header
	}
	GameEvents.SendCustomGameEventToServer (
		head_function,callback_f[head_function]
		
	);

}




function showTalentChanger(){
	//define columns and rows count
	var tal_cols=5
	var tal_rows=2
	//example data
	talent_icons=["dark_willow_terrorize",
				"pangolier_shield_crash",
				"warlock_rain_of_chaos",
				"leshrac_split_earth",
				"invoker_sun_strike",
				"kunkka_torrent",
				"kunkka_tidebringer",
				"elder_titan_earth_splitter",
				"roshan_slam",
				"lina_light_strike_array"]
	talent_names=["#fourteen",
				"#crawl",
				"#accuse",
				"#farmer",
				"#capable",
				"#our",
				"#according",
				"#majority",
				"#vision",
				"#cactus"]


	var parentPanel=$.GetContextPanel()

	var talent_popup=$.CreatePanel('Panel',parentPanel,'talent_popup')
	talent_popup.AddClass('PopupTaletsPanel')

	function addTalentCol(parent){
		var talent_col=$.CreatePanel('Panel',parent,'talent_col')
		talent_col.AddClass('TalentCol')
		return talent_col
	}

	function addTalentButton(id,iconName,text,parent){
		var talentButton=$.CreatePanel('Panel',parent,'talent_'+id)
		talentButton.AddClass('TalentEntry')
		var talentIcon = $.CreatePanel('DOTAAbilityImage', talentButton, 'talent_icon_' + id)
		talentIcon.abilityname = iconName
		talentIcon.AddClass('TalentImg')
		var talentText = $.CreatePanel('Label', talentButton, 'talent_text_' + id)
		talentText.AddClass("TalentLabel")
		talentText.text=$.Localize(text)
		//tooltip definition
		var tooltip_var='qqqq'
		var tooltip_localed=$.Localize('#'+tooltip_var)
		//tooltip check
		if (tooltip_localed!=tooltip_var) {
			talentButton.SetPanelEvent(
				"onmouseover", 
				function() {
					$.DispatchEvent("DOTAShowTextTooltip", talentButton, tooltip_localed);
				}
			)
			
		}

		//button click code
		talentButton.SetPanelEvent (
			"onactivate", 
			function() {
				talentButton.AddClass("TalentButtonSelected")
				//deselect others
				var parent_col=talentButton.GetParent()
				$.Each(parent_col.Children(), function( oPanel )
				{
					if (oPanel!=talentButton) {
						
						oPanel.RemoveClass('TalentButtonSelected')
					}
				});
				/*$.Msg(talentButton.id,'selected')*/
			}
		)
	}
	function drawCloseButton(parent){
		var closeButton=$.CreatePanel('Panel',parent,'talent_close')
		closeButton.AddClass('TalentCloseButton')
		closeButton.SetPanelEvent (
		"onactivate", 
			function() {
				//CLICK CLOSE BUTTON CODE HERE
				//getting selected talents
				for (var i = 0; i < tal_cols*tal_rows; i++) {
					
					if ($('#talent_'+i).BHasClass('TalentButtonSelected')){
						$.Msg('Talent selected:',i)
					}
				}

				parent.DeleteAsync(0)
			}
		)
	}

	//drawing loops
	var counter=0
	for (var i = 0; i < tal_cols; i++) {
		var test_col=addTalentCol(talent_popup)
		for (var j = 0; j < tal_rows; j++) {
			var test_button=addTalentButton(counter,talent_icons[counter],talent_names[counter],test_col)
			counter+=1;
		}
	}
	/*var test_col=addTalentCol(talent_popup)
	var test_button1=addTalentButton(0,'pudge_meat_hook','hyperhook',test_col)
	var test_button2=addTalentButton(0,'rattletrap_hookshot','ultrahook',test_col)
	var test_col=addTalentCol(talent_popup)
	var test_button1=addTalentButton(0,'pudge_meat_hook','megahook',test_col)
	var test_button2=addTalentButton(0,'rattletrap_hookshot','superhook',test_col)*/
	drawCloseButton(talent_popup) 
}

date = new Date();
m = new Date();
if(date.getDay()){m.setDate(date.getDate() + 8 - date.getDay())} else {m.setDate(date.getDate() + 1)}

//var countDownDate = new Date("July 13, 2020 00:00:00").getTime();
var countDownDate=m
countDownDate.setHours(0,0,0)
$.Msg("timer endpoint : " + countDownDate ); 
//wipeTimer()

var d1 = new Date();

$.Msg("time output : " + d1.toUTCString() ); 
var utcString1=d1.toUTCString()
var dddd= new Date(utcString1)
$.Msg("time output2 : " + dddd );  

function wipeTimer(){
	$.Schedule (1, function() {
		// Get today's date and time
		var now = new Date().getTime();

		// Find the distance between now and the count down date
		var distance = countDownDate - now;

		// Time calculations for days, hours, minutes and seconds
		var days = Math.floor(distance / (1000 * 60 * 60 * 24));
		var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
		var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
		var seconds = Math.floor((distance % (1000 * 60)) / 1000);
		var russian_translation=["До следующего вайпа: ","д","ч","м","с"]
		var eng_translation=["Until next wipe: ","d","h","m","s"]
		//$.Msg(client_lang)
		// Display the result in the element with id="demo"
		if (client_lang=='russian'){
			$('#wipe_timer').text =russian_translation[0] + days + russian_translation[1] + hours +russian_translation[2]+ minutes + russian_translation[3] + seconds + russian_translation[4];
		}
		if (client_lang=='english'){
			$('#wipe_timer').text =eng_translation[0] + days + eng_translation[1] + hours +eng_translation[2]+ minutes + eng_translation[3] + seconds + eng_translation[4];
		}
		wipeTimer()
	})
}
//web request wrap

function webClientRecieve(msg){
	var data=msg.data
	if (data=='private'){

		$.Msg("Steam profile is private")
		scoreLabel=$.CreatePanel('Label',$('#leaderboardContainer'),'private_error')
		scoreLabel.AddClass('leaderboardLabel')
		scoreLabel.text="Steam profile is private. Change privacy settings and try again after 5 minutes."
	}else{
		//$.Msg(data)
		leaderboard=JSON.parse(data)
		
		drawLeaderboard(leaderboard)  
	}
	$.Msg('client recieved data')
}

let asdPanels=[$('#patreon'),$('#discord'),$('#twitter')]
if (client_lang=="russian"){
	asdPanels=[$('#boosty'),$('#discord'),$('#twitter')]
}
//asdPanels=[$('#boosty')]
//adsRoulette($('#discord'),$('#patreon'))
/*hideAdPanel($('#patreon'))
showAdPanel($('#boosty'))*/
function hideAdPanel(panel){
	panel.style['opacity']='0'
	$.Schedule(0.4, function(){panel.style['visibility']='collapse';})
}
function showAdPanel(panel){
	panel.style['visibility']='visible'
	panel.style['opacity']='1'
}
function switchAdPanels(panelToHide,panelToShow){
	hideAdPanel(panelToHide)
	showAdPanel(panelToShow)
}
var current_ad=0
/*adsRoulette()
function adsRoulette(){
	var second_ad=current_ad+1
	if (current_ad==asdPanels.length-1){
		second_ad=0
	}
	$.Schedule(8, function(){
		switchAdPanels(asdPanels[current_ad],asdPanels[second_ad])
		
		current_ad++
		if (current_ad==asdPanels.length){
			current_ad=0
		}
		adsRoulette()
	})
}*/
 
function setDebugOutput(data){
	$('#debugOutputLabel').text=data.msg
}

function aiActionFired(data) {
	var actionInt=data.action
	for (var i = 1; i <=21; i++){
		if (i==actionInt){
			if($('#action'+i).BHasClass("outputFired")==false){
				$('#action'+i).AddClass("outputFired")
			}
		}else{
			if ($('#action'+i).BHasClass("outputFired")){
				$('#action'+i).RemoveClass("outputFired")
			}
		}
		
	}		
}
for (var i = 1; i <=21; i++){
	var panel=$('#action'+i)
	panel.SetPanelEvent (
	"onactivate", 
	function() {
		
	}
)
}
function aiTestAction(actionInt){
	GameEvents.SendCustomGameEventToServer (
			"ai_test_action",
			{
				"action": actionInt
			}
		);
}


var DinoGame = {
    // Panels
    gamePanel: null,
    player: null,
    obstaclesContainer: null,
    scoreText: null,
    ground: null,
    restartButton: null,
    
    // Game state
    isJumping: false,
    isGameOver: false,
    isGameStarted: false,
    score: 0,
    gameSpeed: 5,
    
    // Player properties
    playerY: 0,
    playerX: 50,
    playerWidth: 100,
    playerHeight: 100,
    jumpVelocity: 0,
    gravity: 1.2,
    jumpPower: -20,
    
    // Collision box adjustments (offset from visual box)
    playerCollisionOffsetX: 10,
    playerCollisionOffsetY: 10,
    playerCollisionShrinkWidth: 20,
    playerCollisionShrinkHeight: 20,
    
    obstacleCollisionOffsetX: 5,
    obstacleCollisionOffsetY: 5,
    obstacleCollisionShrinkWidth: 10,
    obstacleCollisionShrinkHeight: 10,
    
    // Ground properties
    groundHeight: 50,
    gameHeight: 300,
    
    // Calculated values
    playerBaseMarginTop: 0,
    
    // Obstacles
    obstacles: [],
    obstacleSpawnTimer: 0,
    obstacleSpawnInterval: 100,
    nextObstacleId: 0,
    obstacleWidth: 30,        // Collision width
    obstacleHeight: 50,       // Collision height
    obstacleVisualWidth: 50,  // Visual width (what you see)
    obstacleVisualHeight: 100, // Visual height (what you see)
    obstacleSpawnX: 800,
    obstacleDeviationMin: -50,
    obstacleDeviationMax: 100,
    
    Init: function() {
        this.gamePanel = $('#DinoGame');
        this.player = $('#DinoPlayer');
        this.obstaclesContainer = $('#DinoObstaclesContainer');
        this.scoreText = $('#DinoScoreText');
        this.ground = $('#DinoGround');
        this.restartButton = $('#DinoRestartButton');
        
        // Calculate base margin-top for player
        this.playerBaseMarginTop = this.gameHeight - this.groundHeight - this.playerHeight;
        
        // Apply initial styles based on settings
        this.player.style.width = this.playerWidth + 'px';
        this.player.style.height = this.playerHeight + 'px';
        this.player.style.marginTop = this.playerBaseMarginTop + 'px';
        this.player.style.marginLeft = this.playerX + 'px';
        
        // Setup click handlers
        this.gamePanel.SetPanelEvent('onactivate', this.OnClick.bind(this));
        this.restartButton.SetPanelEvent('onactivate', this.OnRestartButtonClick.bind(this));
        
        // Show initial message
        this.scoreText.text = 'Click to start!';
        
        $.Msg('Dino game initialized - waiting for click to start');
    },
    
    OnClick: function() {
        if (!this.isGameStarted) {
            this.StartGame();
        } else if (!this.isGameOver && !this.isJumping) {
            // Only allow jumping if game is running and not already jumping
            this.Jump();
        }
        // Don't restart on game panel click when game over - only via button
    },
    
    OnRestartButtonClick: function() {
        if (this.isGameOver) {
            this.RestartGame();
        }
    },
    
    StartGame: function() {
        $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "DinoPlayer", "pig", "SetAnimation", "pig_run");
        this.isGameStarted = true;
        this.scoreText.text = 'Score: 0';
        this.GameLoop();
        $.Msg('Game started!');
    },
    
    Jump: function() {
        if (this.playerY === 0) {
            this.isJumping = true;
            this.jumpVelocity = this.jumpPower;
        }
    },
    
    UpdatePlayer: function() {
        if (this.isJumping || this.playerY > 0) {
            // Apply gravity
            this.jumpVelocity += this.gravity;
            this.playerY += this.jumpVelocity;
            
            // Check if landed
            if (this.playerY >= 0) {
                this.playerY = 0;
                this.jumpVelocity = 0;
                this.isJumping = false;
            }
            
            // Update visual position
            var newMarginTop = this.playerBaseMarginTop + this.playerY;
            this.player.style.marginTop = newMarginTop + 'px';
        }
    },
    
    GetRandomDeviation: function() {
        // Generate random number between deviationMin and deviationMax
        var range = this.obstacleDeviationMax - this.obstacleDeviationMin;
        return this.obstacleDeviationMin + (Math.random() * range);
    },
    
    SpawnObstacle: function() {
		var obstacleId = 'obstacle_' + this.nextObstacleId++;
		
		// Apply random deviation to spawn position
		var deviation = this.GetRandomDeviation();
		var spawnX = this.obstacleSpawnX + deviation;
		
		// Calculate visual offset to center horizontally, but align bottom with ground
		var visualOffsetX = (this.obstacleWidth - this.obstacleVisualWidth) / 2;
		
		var style = 'width:' + this.obstacleVisualWidth + 'px;height:' + this.obstacleVisualHeight + 'px;' +
					'margin-left:' + (spawnX + visualOffsetX) + 'px;' +
					'margin-top:' + (this.gameHeight - this.groundHeight - this.obstacleVisualHeight) + 'px;';
		
		var obstacle = $.CreatePanelWithProperties('DOTAScenePanel', this.obstaclesContainer, obstacleId, {
			style: style,
			map: 'piggy',
			particleonly: 'false',
			light: 'light',
			camera: 'camera2'
		});
		
		var obstacleData = {
			panel: obstacle,
			x: spawnX, // Collision position
			width: this.obstacleWidth,   // Collision width
			height: this.obstacleHeight, // Collision height
			visualOffsetX: visualOffsetX, // Store offset for updates
			id: obstacleId
		};
		
		this.obstacles.push(obstacleData);
		
		$.Msg('Spawned obstacle at X: ' + spawnX + ' (deviation: ' + deviation.toFixed(1) + ')');
	},
    
    UpdateObstacles: function() {
        for (var i = this.obstacles.length - 1; i >= 0; i--) {
            var obstacle = this.obstacles[i];
            
            // Move obstacle left
            obstacle.x -= this.gameSpeed;
            // Update visual position (collision position + offset)
            obstacle.panel.style.marginLeft = (obstacle.x + obstacle.visualOffsetX) + 'px';
            
            // Remove if off screen
            if (obstacle.x < -obstacle.width) {
                obstacle.panel.DeleteAsync(0);
                this.obstacles.splice(i, 1);
                this.score += 10;
                this.scoreText.text = 'Score: ' + this.score;
                continue;
            }
            
            // Check collision
            if (this.CheckCollision(obstacle)) {
                this.GameOver();
            }
        }
    },
    
    CheckCollision: function(obstacle) {
        // Apply collision box adjustments to player
        var playerCollisionLeft = this.playerX + this.playerCollisionOffsetX;
        var playerCollisionRight = this.playerX + this.playerWidth - this.playerCollisionShrinkWidth;
        var playerCollisionBottom = this.playerY + this.playerCollisionOffsetY;
        var playerCollisionTop = this.playerY + this.playerHeight - this.playerCollisionShrinkHeight;
        
        // Apply collision box adjustments to obstacle
        var obstacleCollisionLeft = obstacle.x + this.obstacleCollisionOffsetX;
        var obstacleCollisionRight = obstacle.x + obstacle.width - this.obstacleCollisionShrinkWidth;
        var obstacleCollisionBottom = this.obstacleCollisionOffsetY;
        var obstacleCollisionTop = obstacle.height - this.obstacleCollisionShrinkHeight;
        
        // Check horizontal overlap
        if (playerCollisionRight <= obstacleCollisionLeft || playerCollisionLeft >= obstacleCollisionRight) {
            return false; // No horizontal overlap
        }
        
        // Check vertical - player jumps over if ENTIRE player (including bottom) is above obstacle bottom
        if (playerCollisionTop < obstacleCollisionBottom) {
            return false; // Player completely above obstacle (entire player jumped over)
        }
        
        // Check if player bottom cleared the obstacle top (jumped high enough)
        if (playerCollisionBottom < obstacleCollisionBottom) {
            return false; // Player's bottom is higher than obstacle's bottom, so cleared it
        }
        
        // If we get here, there's a collision
        $.Msg('COLLISION! PlayerY: ' + this.playerY + 
            ' PlayerBottom: ' + playerCollisionBottom + 
            ' PlayerTop: ' + playerCollisionTop +
            ' ObstacleBottom: ' + obstacleCollisionBottom +
            ' ObstacleTop: ' + obstacleCollisionTop);
        
        return true;
    },
    
    GameLoop: function() {
        if (!this.isGameOver) {
            // Update game state
            this.UpdatePlayer();
            this.UpdateObstacles();
            
            // Spawn obstacles
            this.obstacleSpawnTimer++;
            if (this.obstacleSpawnTimer >= this.obstacleSpawnInterval) {
                this.SpawnObstacle();
                this.obstacleSpawnTimer = 0;
            }
            
            // Gradually increase difficulty
            if (this.score > 0 && this.score % 100 === 0) {
                this.gameSpeed += 0.05;
            }
        }
        
        // Continue loop
        $.Schedule(0.016, this.GameLoop.bind(this));
    },
    
    GameOver: function() {
        this.isGameOver = true;
        this.scoreText.text = 'GAME OVER! Score: ' + this.score;
        this.restartButton.style.visibility = 'visible';
        $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "DinoPlayer", "pig", "SetAnimation", "pig_die");
        $.Msg('Game over! Final score: ' + this.score);
    },
    
    RestartGame: function() {
        $.Msg('Restarting game');
        $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "DinoPlayer", "pig", "SetAnimation", "pig_run");
        
        // Hide restart button
        this.restartButton.style.visibility = 'collapse';
        
        // Clear obstacles
        for (var i = 0; i < this.obstacles.length; i++) {
            this.obstacles[i].panel.DeleteAsync(0);
        }
        this.obstacles = [];
        
        // Reset state
        this.isGameOver = false;
        this.isJumping = false;
        this.isGameStarted = true;
        this.score = 0;
        this.gameSpeed = 5;
        this.playerY = 0;
        this.jumpVelocity = 0;
        this.obstacleSpawnTimer = 0;
        
        this.scoreText.text = 'Score: 0';
        this.player.style.marginTop = this.playerBaseMarginTop + 'px';
    }
};

// Initialize the game
/* DinoGame.Init() */

//chat hiding
var dotaui=$.GetContextPanel().GetParent().GetParent().GetParent().GetParent()
$.Msg("ID OF ROOT PANEL:",dotaui.id)
var hud=dotaui.FindChild("Hud")
var hudElems=hud.FindChild("HUDElements")
var chatEbanii=hudElems.FindChild("HudChat")
/*chatEbanii.style['visibility']='collapse'*/
var hueta=hudElems.FindChild("combat_events")
hueta.style['visibility']='collapse'
//showLoading()
 GameEvents.Subscribe("ai_action_done", aiActionFired);
 GameEvents.Subscribe("setDebugOutput", setDebugOutput);
 GameEvents.Subscribe("user_init_answer", userInitRecieve);
 GameEvents.Subscribe("web_client_recieve", webClientRecieve);
 GameEvents.Subscribe("loading_done", loadingDone);
 GameEvents.Subscribe("send_nudes", showNudes);
 GameEvents.Subscribe("delay_update", delayUpdate);
 GameEvents.Subscribe("result_popup", resultPopup);
 GameEvents.Subscribe("loading_progress", loadingUpdate);
 GameEvents.Subscribe("cmd_hide_menu", CmdHideMenu);
 GameEvents.Subscribe("cmd_show_menu", CmdShowMenu);
 GameEvents.Subscribe("custom_training_ends", trainingEnds);
/* GameEvents.Subscribe("dispay_delays", displayDelay); */
/* GameEvents.Subscribe( "cheats_activated", cheatsOn ); */

/* CmdHideMenu() */
// Listen for progress updates

// Detect specific aspect ratios
function getAspectRatioType() {
    var screenWidth = Game.GetScreenWidth();
    var screenHeight = Game.GetScreenHeight();
    var ratio = screenWidth / screenHeight;
    
    // Allow small tolerance for floating point comparison
    var tolerance = 0.01;
    
    if (Math.abs(ratio - 16/9) < tolerance) {
        return "16:9";
    } else if (Math.abs(ratio - 16/10) < tolerance) {
        return "16:10";
    } else if (Math.abs(ratio - 4/3) < tolerance) {
        return "4:3";
    } else if (Math.abs(ratio - 21/9) < tolerance) {
        return "21:9"; // ultrawide
    } else {
        return "unknown";
    }
}
/* $('#supportersList').AddClass('forceHide') */
$('#welcomeButton').enabled = false;
// Hide elements based on aspect ratio
var aspectType = getAspectRatioType();
$.Msg('Aspect ratio: ',aspectType)
if (aspectType === "16:10" || aspectType === "4:3") {

    /* $('#supportersList').AddClass('forceHide') */
	
} else {
    /* $('#supportersList').visible = true; */
}
$('#welcomeButtonText').text = "Loading heroes... 0%" 

GameEvents.Subscribe("precache_progress", function(data) {
    var percent = Math.floor((data.current / data.total) * 100);
    $('#welcomeButtonText').text = "Loading heroes... " + percent + "%";
});

GameEvents.Subscribe("precache_complete", function(data) {
    $('#welcomeButtonText').text = "PLAY";
    $('#welcomeButton').enabled = true;
});