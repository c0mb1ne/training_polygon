$.Msg('dream_coil_escape gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("dream_coil_escape_training_end", {});
}
//msControl
let msControl=$.CreatePanel('Panel',$('#msControl'),"movespeed_switcher")
msControl.SetAttributeString("min","0")
msControl.SetAttributeString("max","1000")
msControl.SetAttributeString("step","1")
msControl.SetAttributeString("placeholder","0")
msControl.SetAttributeString("x10control","1")
msControl.SetAttributeString("x100control","1")
msControl.SetAttributeString("onClickEvent","dream_coil_escape_ms_change")
msControl.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 