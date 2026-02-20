$.Msg('dodge gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("dodge_training_end", {});
}