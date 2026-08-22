$.Msg('dream_coil_escape gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("dream_coil_escape_training_end", {});
}