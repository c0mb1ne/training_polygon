$.Msg('lasthit_training gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("lasthit_training_training_end", {});
}