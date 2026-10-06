"use strict";

var container = $("#DebugRows");
var valueLabels = {}; // key -> Label panel

function OnDebugVar(data) {
    var key = String(data.key);
    var label = valueLabels[key];

    // first time this key is seen: create a new row
    if (!label) {
        var row = $.CreatePanel("Panel", container, "");
        row.AddClass("DebugRow");

        var keyLabel = $.CreatePanel("Label", row, "");
        keyLabel.AddClass("DebugKey");
        keyLabel.text = key + ":";

        label = $.CreatePanel("Label", row, "");
        label.AddClass("DebugValue");
        valueLabels[key] = label;
    }

    // every time: just update the value
    label.text = String(data.value); 
}
function ShowPanel(){
    $.GetContextPanel().style['visibility']='visible'
    $.GetContextPanel().style['opacity']='1'
}
function HidePanel(){
    $.GetContextPanel().style['visibility']='collapse'
    $.GetContextPanel().style['opacity']='0'
}
HidePanel()
GameEvents.Subscribe("send_debug_var", OnDebugVar);
GameEvents.Subscribe("debug_panel_show", ShowPanel);
GameEvents.Subscribe("debug_panel_hide", HidePanel);