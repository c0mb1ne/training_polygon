$.Msg('lasthit_training menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_lasthit_training_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "lasthit_training",
	 	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
}
$('#midLane').checked=true; 
let defaultHero="npc_dota_hero_antimage"
let HeroPicker = CreateHeroPicker($('#heroPickerContainer'), {
	defaultHero: defaultHero,
	onSelect: function(hero) { defaultHero = hero }
})

GameEvents.Subscribe("lasthit_training_spell_table", saveData);
