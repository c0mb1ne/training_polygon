$.Msg('glimpse gameplay hud loaded')

function stopTraining() {
    GameEvents.SendCustomGameEventToServer('glimpse_mode_end', {})
}
