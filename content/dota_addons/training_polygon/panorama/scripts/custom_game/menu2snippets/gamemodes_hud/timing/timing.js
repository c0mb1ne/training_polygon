$.Msg('timing menu loaded')
GameEvents.SendCustomGameEventToServer (
	"get_timing_spell_table",
	{
	}
);
let spells_to_pick
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
	let typesPanel=$('#timingTypes')

	for (let type in spells_to_pick){
		drawType(typesPanel,type)
	}
}
function drawType(parent,name){
	var modePanel=$.CreatePanel('RadioButton',parent,name)
	modePanel.SetAttributeString("name",name)
	modePanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/gamemodes_hud/timing/timing_type.xml", false, false)
	modePanel.SetPanelEvent(
		"onactivate",
		function() {
			drawSpellTable(name)
			$.Msg(name)
			//if there is castpoint type of dodge, draw yasha kaya toggle
			
		}
	)

}
function clearSpellTable(){
	$.Each($('#timingSpellContainer').Children(), function( oPanel )
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
				drawSkill($('#timingSpellContainer'), key, skill_info)
			}
		}
	}
}
function drawSkill(parent, key, skillInfo){
	let spellName = skillInfo.spell_name || ""
	var skillPanel=$.CreatePanel('RadioButton',parent,'skillC_' + key)
	skillPanel.SetAttributeString("name",spellName)
	skillPanel.SetAttributeInt("key", parseInt(key))
	skillPanel.SetAttributeString("spell_name", spellName)
	skillPanel.SetAttributeString("hero_name", skillInfo.hero_name || "")
	skillPanel.SetAttributeInt("level", skillInfo.level || 1)
	skillPanel.SetAttributeInt("aghs", skillInfo.aghs ? 1 : 0)
	skillPanel.SetAttributeInt("shard", skillInfo.shard ? 1 : 0)
	skillPanel.SetAttributeInt("is_ability", skillInfo.is_ability ? 1 : 0)
	skillPanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/gamemodes_hud/timing/timing_entry.xml", false, false)
}

function getTimingType(){
	var timingName=""
	var typesPanel=$('#timingTypes')
	$.Each((typesPanel).Children(), function( oPanel )
	{
		if (oPanel.checked){
			timingName=oPanel.id
		}
	});
	return timingName
}

function getSelectedSkills() {
    let selectedSkills = {};
    let skillContainer = $('#timingSpellContainer');

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

function startGame() {
    // getting selected mode and spells
    var timingType = getTimingType();
    var selected = getSelectedSkills();
	var errorMsg=$('#errorMsg')
    if (!timingType) {
        errorMsg.text='Error: No dodge type selected.';
        return;
    }

    if (Object.keys(selected).length === 0) {
        errorMsg.text='Error: No skills selected.';
        return;
    }

    $.Msg(timingType);
    $.Msg(JSON.stringify(selected));
	var rubickMode=false
	if ($('#rubickMode').checked){
		rubickMode=true
	}
	var helperMode=false
	if ($('#helperMode').checked){
		helperMode=true
	}
	
    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "timing",
			timingType: timingType,
			selectedSpell: selected,
			rubickMode: rubickMode,
			helperMode: helperMode,
	 	});
}

GameEvents.Subscribe("timing_spell_table", saveData);