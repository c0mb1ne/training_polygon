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
		
		/* $.Msg(type) */
		if (type==typeToDraw){
			for (let skill in spells_to_pick[type]){
				let skill_info=spells_to_pick[type][skill]
				$.Msg(skill)
				let skill_name=skill
				drawSkill($('#dodgeSpellContainer'),skill_name)
			}
		}
		
		//
	}
}
//$('#mantaThumb').ClearPanelEvent("onmouseover")
//$('#dtype_0').checked=true
function drawSkill(parent,name){
	/* $.Msg(name) */
	var container=$.CreatePanel('ToggleButton', parent, 'skillC_' + name)
	container.AddClass('timingType')
	let SkillImage = $.CreatePanel('DOTAAbilityImage', container, 'skillI_' + name)
	SkillImage.abilityname = name
	container.SetPanelEvent(
		"onmouseover", 
		function() {
			$.DispatchEvent("DOTAShowAbilityTooltip", container, name);
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
	//$.Msg(name)
	/*<RadioButton class="timingType" checked="checked" group="dodgeMod" id="dtype_0">
                <DOTAItemImage id="mantaThumb" itemname="item_manta" />
            </RadioButton> */
	var modePanel=$.CreatePanel('RadioButton',parent,name)
	modePanel.SetAttributeString("name",name)
	modePanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/gamemodes_hud/dodge/dodge_type.xml", false, false)
	modePanel.SetPanelEvent(
		"onactivate", 
		function() {
			drawSpellTable(name)
		}
	)
/*	if (name=="item_manta"){
		modePanel.checked=true
		$.Msg('checked')

	}*/
}

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

    if (selected.length === 0) {
        errorMsg.text='Error: No skills selected.';
        return;
    }

    $.Msg(dodgeName);
    $.Msg(selected);

    GameEvents.SendCustomGameEventToServer("activate_game_mode", 
		{ 	
			gameModeName: "dodge",
			dodgeName: dodgeName,
			dodgeSpells: selected
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
    let selectedSkills = [];
    let skillContainer = $('#dodgeSpellContainer');
    
    $.Each(skillContainer.Children(), function(oPanel) {
        if (oPanel.checked) {
            selectedSkills.push(oPanel.id.replace('skillC_', ''));
        }
    });
    
    return selectedSkills;
}
// Precache progress is now handled by precache_modal.js

GameEvents.Subscribe("dodge_spell_table", saveData);
