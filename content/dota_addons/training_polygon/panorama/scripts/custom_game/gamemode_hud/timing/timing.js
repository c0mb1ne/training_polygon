/* $.Msg('timing hud loaded') */
$('#spiritBrakerSettings').style['visibility']="collapse;"
$('#tuskarSettings').style['visibility']="collapse;"
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("timing_training_end", {});
}
function ShowSpiritBreakerSettings(){
    $('#additionalSettings').style['visibility']="visible;"
    $('#spiritBrakerSettings').style['visibility']="visible;"
    //msControl
    let msControl=$.CreatePanel('Panel',$('#msControl'),"movespeed_switcher")
    msControl.SetAttributeString("min","0")
    msControl.SetAttributeString("max","1000")
    msControl.SetAttributeString("step","1")
    msControl.SetAttributeString("placeholder","0")
    msControl.SetAttributeString("x10control","1")
    msControl.SetAttributeString("x100control","1")
    msControl.SetAttributeString("onClickEvent","timing_ms_change")
    msControl.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 

    let skill1Control=$.CreatePanel('Panel',$('#spell1Control'),"skill1_switcher")
    skill1Control.SetAttributeString("min","1")
    skill1Control.SetAttributeString("max","4")
    skill1Control.SetAttributeString("step","1")
    skill1Control.SetAttributeString("placeholder","1")
    skill1Control.SetAttributeString("onClickEvent","timing_sb_charge_change")
    skill1Control.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 

    let skill2Control=$.CreatePanel('Panel',$('#spell2Control'),"skill2_switcher")
    skill2Control.SetAttributeString("min","1")
    skill2Control.SetAttributeString("max","4")
    skill2Control.SetAttributeString("step","1")
    skill2Control.SetAttributeString("placeholder","1")
    skill2Control.SetAttributeString("onClickEvent","timing_sb_bulldoze_change")
    skill2Control.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 
}
function ShowTuskarSettings(){
    $('#additionalSettings').style['visibility']="visible;"
    $('#tuskarSettings').style['visibility']="visible;"
    let snowballControl=$.CreatePanel('Panel',$('#snowballControl'),"snowball_switcher")
    snowballControl.SetAttributeString("min","1")
    snowballControl.SetAttributeString("max","4")
    snowballControl.SetAttributeString("step","1")
    snowballControl.SetAttributeString("placeholder","1")
    snowballControl.SetAttributeString("onClickEvent","timing_snowball_change")
    snowballControl.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 
}

GameEvents.Subscribe("show_spirit_braker_settings", ShowSpiritBreakerSettings);
GameEvents.Subscribe("show_tuskar_settings", ShowTuskarSettings);