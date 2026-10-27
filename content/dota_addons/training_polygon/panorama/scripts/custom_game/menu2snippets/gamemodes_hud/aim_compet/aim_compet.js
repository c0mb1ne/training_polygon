$.Msg('aim_compet menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_aim_compet_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "aim_compet",
	 	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
}


GameEvents.Subscribe("aim_compet_spell_table", saveData);
