$.Msg('timing hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("timing_training_end", {});
}