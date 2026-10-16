$.Msg('test_sandbox gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("test_sandbox_training_end", {});
}