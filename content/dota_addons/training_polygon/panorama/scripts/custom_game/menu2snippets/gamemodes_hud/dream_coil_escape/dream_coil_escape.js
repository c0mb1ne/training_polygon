$.Msg('dream_coil_escape menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_dream_coil_escape_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "dream_coil_escape",
	 	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
}


GameEvents.Subscribe("dream_coil_escape_spell_table", saveData);
