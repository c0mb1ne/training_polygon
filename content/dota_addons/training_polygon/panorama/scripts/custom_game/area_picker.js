// area_picker.js
// Overlay for defining the aim_compet play area with the camera, place_picker style:
// center the camera on a spot, press "corner 1", move, press "corner 2", then "done".
// All game logic (clamping, validation, preview particles) lives server-side in
// aim_compet.lua - this file is only the buttons and the size readout.

var areaCorner1 = null;
var areaCorner2 = null;
var AREA_MIN_SIDE = 400; // keep in sync with aim_compet.lua

function refreshAreaLabel() {
    $('#areaCorner1Button').SetHasClass('areaCornerSet', areaCorner1 !== null);
    $('#areaCorner2Button').SetHasClass('areaCornerSet', areaCorner2 !== null);

    var label = $('#areaPickerSize');
    if (areaCorner1 !== null && areaCorner2 !== null) {
        var w = Math.abs(areaCorner1[0] - areaCorner2[0]);
        var h = Math.abs(areaCorner1[1] - areaCorner2[1]);
        var text = Math.round(w) + ' × ' + Math.round(h);
        label.SetHasClass('areaPickerSizeBad', w < AREA_MIN_SIDE || h < AREA_MIN_SIDE);
        label.text = (w < AREA_MIN_SIDE || h < AREA_MIN_SIDE) ? (text + ' — ' + $.Localize('#aimAreaTooSmall')) : text;
    } else {
        label.SetHasClass('areaPickerSizeBad', false);
        label.text = '';
    }
}

function setAreaCorner(n) {
    var pos = Game.ScreenXYToWorld(Game.GetScreenWidth() / 2, Game.GetScreenHeight() / 2);
    if (n === 1) {
        areaCorner1 = pos;
    } else {
        areaCorner2 = pos;
    }
    GameEvents.SendCustomGameEventToServer("aim_compet_area_set_corner", { corner: n, pos: pos });
    refreshAreaLabel();
}

function finishAreaPick() {
    GameEvents.SendCustomGameEventToServer("aim_compet_area_done", {});
}

function areaPickerBegin(data) {
    areaCorner1 = null;
    areaCorner2 = null;
    refreshAreaLabel();
    $.GetContextPanel().RemoveClass('Hidden');
    // jump the camera to the training place so the picked box is seen in context
    if (typeof GameUI.SetCameraTargetPosition === 'function') {
        GameUI.SetCameraTargetPosition([data.ax, data.ay, data.az], 0);
    }
}

function areaPickerEnd(data) {
    $.GetContextPanel().AddClass('Hidden');
}

// server rejected the box (too small) - stay open and show why
function areaPickerError(data) {
    var label = $('#areaPickerSize');
    label.SetHasClass('areaPickerSizeBad', true);
    label.text = $.Localize('#aimAreaTooSmall');
}

GameEvents.Subscribe('area_picker_begin', areaPickerBegin);
GameEvents.Subscribe('area_picker_end', areaPickerEnd);
GameEvents.Subscribe('area_picker_error', areaPickerError);
