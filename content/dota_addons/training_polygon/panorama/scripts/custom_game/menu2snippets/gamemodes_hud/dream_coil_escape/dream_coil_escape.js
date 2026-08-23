$.Msg('dream_coil_escape menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_dream_coil_escape_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')
	var timingType = getTimingType();
	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "dream_coil_escape",
			timingType: timingType,
			defaultHero: defaultHero
	 	});
}
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
	let typesPanel=$('#coil_escape_Types')

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
			$.Msg(name)
		}
	)
	//let item_manta be default
	if (name=="item_manta"){
		modePanel.checked=true
	}
}
function getTimingType(){
	var timingName=""
	var typesPanel=$('#coil_escape_Types')
	$.Each((typesPanel).Children(), function( oPanel )
	{
		if (oPanel.checked){
			timingName=oPanel.id
		}
	});
	return timingName
}

let defaultHero = 'npc_dota_hero_antimage'
let HeroPicker = CreateHeroPicker($('#heroPickerContainer'), {
	defaultHero: defaultHero,
	onSelect: function(hero) { defaultHero = hero }
})
GameEvents.Subscribe("dream_coil_escape_spell_table", saveData);
