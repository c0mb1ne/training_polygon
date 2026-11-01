$.Msg('kunkka menu loaded')

function startGame() {
    var procast = 1
    if ($('#kunkkaProcast2').checked) {
        procast = 2
    }
    var timebar = 0
    if ($('#timebarToggle').checked) {
        timebar = 1
    }
    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'kunkka',
        procast: procast,
        timebar: timebar
    })
}
