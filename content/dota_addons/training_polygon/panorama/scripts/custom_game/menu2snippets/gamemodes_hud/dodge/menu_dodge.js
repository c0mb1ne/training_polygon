$.Msg('dodge loaded')
GameEvents.SendCustomGameEventToServer (
	"get_dodge_spell_table",
	{
	}
);
let spells_to_pick

function getSelectedType(){
	let type="none"


	return type
}
function saveData(data){
	spells_to_pick=data.data
	drawTypes()
	for (let type in spells_to_pick){
		//drawSpellTable(type)
		//drawSpellTable(type)
		break
	}
}
function drawTypes(){
	let typesPanel=$('#dodgeTypes')

	for (let type in spells_to_pick){
		drawType(typesPanel,type)
	}
	

}
function clearSpellTable(){
	$.Each($('#dodgeSpellContainer').Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});

}
function drawSpellTable(typeToDraw){
	clearSpellTable()
	$.Msg('drawing spell table')

	for (let type in spells_to_pick){
		if (type==typeToDraw){
			for (let key in spells_to_pick[type]){
				let skill_info = spells_to_pick[type][key]
				// key is the numeric index, skill_info contains spell_name, hero_name, etc.
				drawSkill($('#dodgeSpellContainer'), key, skill_info)
			}
		}
	}
}
//$('#mantaThumb').ClearPanelEvent("onmouseover")
//$('#dtype_0').checked=true
function drawSkill(parent, key, skillInfo){
	// key is the numeric index from Lua table
	// skillInfo format: {spell_name, hero_name, level, aghs, shard, is_ability}
	var container = $.CreatePanel('ToggleButton', parent, 'skillC_' + key)
	container.AddClass('timingType')

	let spellName = skillInfo.spell_name || ""

	// Store the key and skill info as panel attributes
	container.SetAttributeInt("key", parseInt(key))
	container.SetAttributeString("spell_name", spellName)
	container.SetAttributeString("hero_name", skillInfo.hero_name || "")
	container.SetAttributeInt("level", skillInfo.level || 1)
	container.SetAttributeInt("aghs", skillInfo.aghs ? 1 : 0)
	container.SetAttributeInt("shard", skillInfo.shard ? 1 : 0)
	container.SetAttributeInt("is_ability", skillInfo.is_ability ? 1 : 0)
	
	let SkillImage = $.CreatePanel('DOTAAbilityImage', container, 'skillI_' + key)
	SkillImage.abilityname = spellName
	if (skillInfo.level>1){
		var lvlLabel=$.CreatePanel("Label",container,'lvl_'+key)
		lvlLabel.text="lvl. "+skillInfo.level
		lvlLabel.AddClass("lvlLabel")
	}
	container.SetPanelEvent(
		"onmouseover",
		function() {
			$.DispatchEvent("DOTAShowAbilityTooltip", container, spellName);
		}
	)
	container.SetPanelEvent(
		"onmouseout",
		function() {
			$.DispatchEvent("DOTAHideAbilityTooltip", container);
		}
	)
}

function drawType(parent,name){
	
	var modePanel=$.CreatePanel('RadioButton',parent,name)
	modePanel.SetAttributeString("name",name)
	modePanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/gamemodes_hud/dodge/dodge_type.xml", false, false)
	modePanel.SetPanelEvent(
		"onactivate",
		function() {
			drawSpellTable(name)
			$.Msg(name)
			//if there is castpoint type of dodge, draw yasha kaya toggle
			if (name=="storm_spirit_ball_lightning" || name=="bane_nightmare" || name=="void_spirit_dissimilate" || name=="riki_tricks_of_the_trade"){
				$("#yashaKayaPlayerToggle").RemoveClass("Hidden")
			}
			else{
				$("#yashaKayaPlayerToggle").AddClass("Hidden")
			}
			if (name=="storm_spirit_ball_lightning"){
				$('#stormTimeSetting').RemoveClass("Hidden")
			}else{
				$('#stormTimeSetting').AddClass("Hidden")
			}
			if (name=="item_manta"){
				$('#heroPickerContainer').RemoveClass("Hidden")
			}else{
				$('#heroPickerContainer').AddClass("Hidden")
			}
		}
	)
	if (name=="item_manta"){
		modePanel.checked=true
		drawSpellTable(name)
	}
}

$('#stormTimeSetting').AddClass("Hidden")
/* $('#heroPickerContainer').AddClass("Hidden") */
function selectAllSkills(){
	$.Each($('#dodgeSpellContainer').Children(), function(oPanel) {
		oPanel.checked=true
	});
}
function unmarkAllSkills(){
	$.Each($('#dodgeSpellContainer').Children(), function(oPanel) {
		oPanel.checked=false
	});
}
function startGame() {
    // getting selected mode and spells
    var dodgeName = getDodgeType();
    var selected = getSelectedSkills();
	var errorMsg=$('#errorMsg')
    if (!dodgeName) {
        errorMsg.text='Error: No dodge type selected.';
        return;
    }

    if (Object.keys(selected).length === 0) {
        errorMsg.text='Error: No skills selected.';
        return;
    }

    $.Msg(dodgeName);
    $.Msg(JSON.stringify(selected));
	var yashaKaya=false
	var yashaKayaPlayer=false
	var hardcoreMode=false
	var destroyTrees=false
	if ($('#yashaKayaToggle').checked){
		yashaKaya=true
	}
	if ($('#yashaKayaPlayerToggle').checked){
		yashaKayaPlayer=true
	}
	if ($('#hardcoreMode').checked){
		hardcoreMode=true
	}
	if ($('#treesToggle').checked){
		destroyTrees=true
	}
	var stormTime=""
	stormTime=numberSwitcher.GetAttributeString("value", "")
	var selectedHero=defaultHero
    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "dodge",
			dodgeName: dodgeName,
			dodgeSpells: selected,
			yashaKaya: yashaKaya,
			stormTime: stormTime,
			yashaKayaPlayer: yashaKayaPlayer,
			hardcoreMode: hardcoreMode,
			selectedHero: selectedHero,
			respawnPos: respawnPos,
			destroyTrees: destroyTrees
	 	});
}
function getDodgeType(){
	var dodgeName=""
	var typesPanel=$('#dodgeTypes')
	$.Each((typesPanel).Children(), function( oPanel )
	{
		if (oPanel.checked){
			dodgeName=oPanel.id
		}
	});
	return dodgeName
}
function getSelectedSkills() {
    let selectedSkills = {};
    let skillContainer = $('#dodgeSpellContainer');

    $.Each(skillContainer.Children(), function(oPanel) {
        if (oPanel.checked) {
            // Use the numeric key to identify the spell entry
            let key = oPanel.GetAttributeInt("key", 0);
            selectedSkills[key] = {
                spell_name: oPanel.GetAttributeString("spell_name", ""),
                hero_name: oPanel.GetAttributeString("hero_name", ""),
                level: oPanel.GetAttributeInt("level", 1),
                aghs: oPanel.GetAttributeInt("aghs", 0) === 1,
                shard: oPanel.GetAttributeInt("shard", 0) === 1,
                is_ability: oPanel.GetAttributeInt("is_ability", 1) === 1
            };
        }
    });

    return selectedSkills;
}
GameEvents.SendCustomGameEventToServer ("get_dodge_respawn_pos",{});
let wait_for_place=false
let respawnPos
function placePickerStart(){
	wait_for_place=true
	GameEvents.SendCustomGameEventToServer (
	"place_picker_start",
		{
		}
	);
}
function placePicked(data){
	if (wait_for_place){
		$.Msg('picked place:',data)
		$('#respawnPosSetting').text=data.pos[0].toFixed(0)+","+data.pos[1].toFixed(0)+","+data.pos[2].toFixed(0)
		respawnPos=[data.pos[0],data.pos[1],data.pos[2]]
		wait_for_place=false
	}
}
function setRespawn(data){
	/* $.Msg('default respawn:',data) */
	$('#respawnPosSetting').text=data.pos[1].toFixed(0)+","+data.pos[2].toFixed(0)+","+data.pos[3].toFixed(0)
	respawnPos=[data.pos[1],data.pos[2],data.pos[3]]
}
function resetRespawnPlace(data){
	GameEvents.SendCustomGameEventToServer("dodge_reset_respawn_pos",{});
}
$('#treesToggle').checked=true
$('#cancelAnimToggle').AddClass("Hidden")
$("#yashaKayaPlayerToggle").AddClass("Hidden")
//making number field for storm type
let numberSwitcher=$.CreatePanel('Panel',$('#stormEvadeNumberSwitcher'),"storm_time_switcher")
numberSwitcher.SetAttributeString("min","0.1")
numberSwitcher.SetAttributeString("max","1")
numberSwitcher.SetAttributeString("step","0.1")
numberSwitcher.SetAttributeString("placeholder","0.1")
numberSwitcher.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 

//making hero picker for manta 

let defaultHero="npc_dota_hero_antimage"
let heroPicker=$('#hero_picker')
let popupContainer=$('#dodge_popup_container')
let heroPickerIcon=$('#hero_picker_selected')
heroPickerIcon.heroname=defaultHero
let heroList=[]
GameEvents.SendCustomGameEventToServer (
	"dotadb_get_hero_list",
		{
		}
);
function saveHeroList(data) {
    heroList = data.hero_list;

   /*  $.Msg(heroList); */

    // Extract keys into an array manually
    let keys = [];
    for (let key in heroList) {
        keys[keys.length] = key;
    }

    // Simple sort by hero name string
    for (let i = 0; i < keys.length - 1; i++) {
        for (let j = i + 1; j < keys.length; j++) {
            let nameA = heroList[keys[i]].replace("npc_dota_hero_", "");
            let nameB = heroList[keys[j]].replace("npc_dota_hero_", "");
            if (nameA > nameB) {
                let tmp = keys[i];
                keys[i] = keys[j];
                keys[j] = tmp;
            }
        }
    }

    // Iterate in sorted order
    for (let i = 0; i < keys.length; i++) {
        let key = keys[i];
        let heroButton = $.CreatePanel('Button', $('#manta_hero_picker_popup'),  heroList[key]);
        heroButton.AddClass('heroPickerButton');
        let heroIcon = $.CreatePanel('DOTAHeroImage', heroButton, "hero_icon_" + key);
        heroIcon.heroimagestyle = "icon";
        heroIcon.heroname = heroList[key];
        /* if (heroList[key] == heroPickerIcon.heroname) {
            heroButton.AddClass('heroPickerSelected');
        } */
	   	if (heroList[key] == defaultHero) {
			/* $.Msg(heroPickerIcon.heroname) */
            heroButton.AddClass('heroPickerSelected');
        }
		heroButton.SetPanelEvent(
			"onactivate",
			function() {
				$('#'+defaultHero).RemoveClass('heroPickerSelected')
				defaultHero=heroButton.id
				heroPickerIcon.heroname=defaultHero
				heroButton.AddClass('heroPickerSelected');
				popupContainer.style['opacity']="0"
				popupContainer.style['visibility']="collapse"

			}
		)
    }
}

heroPicker.SetPanelEvent(
	"onactivate",
	function() {
		/* heroPickerPopup=$.CreatePanel('Panel',popupContainer,"manta_hero_picker_popup")
		heroPickerPopup.AddClass('heroPickerPopup') */
		popupContainer.style['opacity']="1"
		popupContainer.style['visibility']="visible"
	}
)
popupContainer.SetPanelEvent(
	"onactivate",
	function() {
		/* heroPickerPopup=$.CreatePanel('Panel',popupContainer,"manta_hero_picker_popup")
		heroPickerPopup.AddClass('heroPickerPopup') */
		popupContainer.style['opacity']="0"
		popupContainer.style['visibility']="collapse"
	}
)



// Precache progress is now handled by precache_modal.js
GameEvents.Subscribe("dodge_respawn_pos", setRespawn);
GameEvents.Subscribe("dotadb_get_hero_list_answer", saveHeroList);
GameEvents.Subscribe("place_picker_result", placePicked);
GameEvents.Subscribe("dodge_spell_table", saveData);

