$.Msg('glimpse_dodge menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_glimpse_dodge_spell_table",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	// TODO: gather any mode-specific toggle/setting values here, like dodge.js's
	// yashaKaya/hardcoreMode or timing.js's rubickMode/helperMode/abilityLevel

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
		{
			gameModeName: "glimpse_dodge",
	 	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
}
var soundSettings = CreateSoundSettings($('#soundSettingsContainer'), {
    scope: 'glimpse_dodge',
    onChange: function(type, soundId, scope) {
        // Optional callback
    }
});

GameEvents.Subscribe("glimpse_dodge_spell_table", saveData);
