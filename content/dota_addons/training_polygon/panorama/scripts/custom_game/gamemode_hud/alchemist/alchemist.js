$.Msg('alchemist gameplay hud loaded')

function stopTraining() {
    GameEvents.SendCustomGameEventToServer('alchemist_mode_end', {})
}
