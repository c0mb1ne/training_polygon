$.Msg('kunkka gameplay hud loaded')

function stopTraining() {
    GameEvents.SendCustomGameEventToServer('kunkka_mode_end', {})
}

function StrTracker(info) {
    $('#strField').text = info.str.toFixed(1)
    $('#srField').text = info.sr.toFixed(1) + '%'
}

GameEvents.Subscribe('kunkka_mode_str', StrTracker)
