$.Msg('aim_compet gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("aim_compet_training_end", {});
}