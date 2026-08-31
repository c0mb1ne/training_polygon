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

$('#stunDur2').checked=true
$('#rgbZone').checked=true
$('#zoneDisplay').checked=true
$('#stunDur3').SetPanelEvent(
    "onactivate",
    function(){
        GameEvents.SendCustomGameEventToServer (
            "dream_coil_escape_stun_dispel_toggle",
            {
                value:$('#stunDur3').id
            }
        );
    }
)
$('#stunDur2').SetPanelEvent(
    "onactivate",
    function(){
        GameEvents.SendCustomGameEventToServer (
            "dream_coil_escape_stun_dispel_toggle",
            {
                value:$('#stunDur2').id
            }
        );
    }
)
$('#stunDur1').SetPanelEvent(
    "onactivate",
    function(){
        GameEvents.SendCustomGameEventToServer (
            "dream_coil_escape_stun_dispel_toggle",
            {
                value:$('#stunDur1').id
            }
        );
    }
)
$('#rgbZone').SetPanelEvent(
    "onactivate",
    function(){
        GameEvents.SendCustomGameEventToServer (
            "dream_coil_escape_rgb",
            {
                value:$('#rgbZone').checked
            }
        );
    }
)
$('#zoneDisplay').SetPanelEvent(
    "onactivate",
    function(){
        GameEvents.SendCustomGameEventToServer (
            "dream_coil_escape_zone_display",
            {
                value:$('#zoneDisplay').checked
            }
        );
    }
)

function minRangeChange(value){
     GameEvents.SendCustomGameEventToServer (
        "dream_coil_escape_zone_min_range_changed",
        {
            value:value
        }
    );
}
function maxRangeChange(value){
     GameEvents.SendCustomGameEventToServer (
        "dream_coil_escape_zone_max_range_changed",
        {
            value:value
        }
    );
}
function maxRangeUpdateValue(data){
    $('#maxRangeValue').text=data.value
    let radius=(data.value/break_radius)*100
    $.Msg(radius)
    $('#MaxRangeCircle').style['width']=radius+"%"
    $('#MaxRangeCircle').style['height']=radius+"%"
}
function minRangeUpdateValue(data){
    $('#minRangeValue').text=data.value
    let radius=(data.value/break_radius)*100
    $.Msg(radius)
    $('#MinRangeCircle').style['width']=radius+"%"
    $('#MinRangeCircle').style['height']=radius+"%"
}

let break_radius=375//it would be nice to get it from lua but im lazy

GameEvents.Subscribe("dream_coil_escape_max_range_update_values", maxRangeUpdateValue);

GameEvents.Subscribe("dream_coil_escape_min_range_update_values", minRangeUpdateValue);

