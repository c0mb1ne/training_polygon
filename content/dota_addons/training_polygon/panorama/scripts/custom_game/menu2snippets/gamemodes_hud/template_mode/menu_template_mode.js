$.Msg('template_mode menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_template_mode_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "template_mode",
	 	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
}


GameEvents.Subscribe("template_mode_spell_table", saveData);
