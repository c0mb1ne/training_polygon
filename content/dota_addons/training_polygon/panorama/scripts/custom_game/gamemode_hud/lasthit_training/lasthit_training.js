$.Msg('lasthit_training gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("lasthit_training_training_end", {});
}


function formatTime(totalSeconds) {
    totalSeconds = Math.floor(totalSeconds);
    var h = Math.floor(totalSeconds / 3600);
    var m = Math.floor((totalSeconds % 3600) / 60);
    var s = totalSeconds % 60;

    function pad(n) { return n < 10 ? "0" + n : "" + n; }

    return pad(h) + ":" + pad(m) + ":" + pad(s);
}

function refreshCounters(data) {
    /* $.Msg(JSON.stringify(data)); */
    for (var key in data) {
        var label = $("#" + key);
        if (!label) continue; // no label with this id, skip

        var value = data[key];

        if (key === "sessionTime") {
            value = formatTime(value);
        }
        if (key === "lasthitToMissPrecent") {
            value = value.toFixed(1) + "%";
        }
        if (key === "avgDelayCounter") {
            value = value.toFixed(3);
        }
        label.text = value;
    }
}

//msControl
let msControl=$.CreatePanel('Panel',$('#msControl'),"movespeed_switcher")
msControl.SetAttributeString("min","0")
msControl.SetAttributeString("max","1000")
msControl.SetAttributeString("step","1")
msControl.SetAttributeString("placeholder","0")
msControl.SetAttributeString("x10control","1")
msControl.SetAttributeString("x100control","1")
msControl.SetAttributeString("onClickEvent","lasthit_training_bot_ms_change")
msControl.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 

//asControl
let asControl=$.CreatePanel('Panel',$('#asControl'),"movespeed_switcher")
asControl.SetAttributeString("min","0")
asControl.SetAttributeString("max","1000")
asControl.SetAttributeString("step","1")
asControl.SetAttributeString("placeholder","0")
asControl.SetAttributeString("x10control","1")
asControl.SetAttributeString("x100control","1")
asControl.SetAttributeString("onClickEvent","lasthit_training_bot_as_change")
asControl.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 

//adControl
let adControl=$.CreatePanel('Panel',$('#adControl'),"movespeed_switcher")
adControl.SetAttributeString("min","0")
adControl.SetAttributeString("max","1000")
adControl.SetAttributeString("step","1")
adControl.SetAttributeString("placeholder","0")
adControl.SetAttributeString("x10control","1")
adControl.SetAttributeString("x100control","1")
adControl.SetAttributeString("onClickEvent","lasthit_training_bot_ad_change")
adControl.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false) 

$('#unHideSettings').style.visibility="collapse"
function tempHide(){
    $('#unHideSettings').style.visibility="visible"
    $('#additionalSettings').style.visibility="collapse"
    $('#unHideSettings').AddClass('attentionAnimation')
    $.Schedule(1.5, function(){$('#unHideSettings').RemoveClass('attentionAnimation')})
}
function tempShow(){
    $('#unHideSettings').style.visibility="collapse"
    $('#additionalSettings').style.visibility="visible"
}
$('#HideButton').SetPanelEvent(
    "onactivate",
    function(){
        tempHide();
    }
)
function botStatsRefresh(data){
    /* $.Msg(JSON.stringify(data)) */

    // movespeed
    $("#botActualMS").text = Math.round(data.ms)

    // attack speed: shown value + real attacks per second
    $("#botActualAS").text = Math.round(data.attackSpeed) + " (" + Number(data.aps).toFixed(3) + "/s)"

    // damage range
    $("#botActualAD").text = Math.round(data.minDmg) + "-" + Math.round(data.maxDmg)
}
$('#additionalSettings').style.visibility="collapse"

function showSettings(){
    $('#additionalSettings').style.visibility="visible"
}
GameEvents.Subscribe("lasthit_show_settings", showSettings);
GameEvents.Subscribe("lasthit_training_bot_stats", botStatsRefresh);
GameEvents.Subscribe("lasthit_refresh_counters", refreshCounters);