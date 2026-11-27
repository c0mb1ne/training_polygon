$.Msg('glimpse_dodge gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("glimpse_dodge_training_end", {});
}