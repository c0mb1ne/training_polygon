$.Msg('template_mode gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("template_mode_training_end", {});
}