$.Msg('alchemist menu loaded')

function startGame() {
    var timebar = 0
    if ($('#timebarToggle').checked) {
        timebar = 1
    }
    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'alchemist',
        timebar: timebar
    })
}
