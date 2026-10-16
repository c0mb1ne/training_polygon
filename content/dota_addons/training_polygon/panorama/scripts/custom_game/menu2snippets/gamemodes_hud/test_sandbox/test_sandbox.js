$.Msg('test_sandbox menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_test_sandbox_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "test_sandbox",
	 	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
}


GameEvents.Subscribe("test_sandbox_spell_table", saveData);
