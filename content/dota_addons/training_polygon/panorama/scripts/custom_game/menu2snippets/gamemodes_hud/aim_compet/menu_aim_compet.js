$.Msg('aim_compet menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_aim_compet_spell_table",
	{
	}
);

var ITEM_NAME = "item_topor";
var EMPTY = "empty";

var ABILITY_SLOT_COUNT = 4;
var ITEM_SLOT_ROWS = 2;
var ITEM_SLOT_COLS = 3;

// Slot state: ITEM_NAME = busy with item, null = empty.
// Default: first inventory slot is busy.
var abilitySlots = [null, null, null, null];
var itemSlots = [ITEM_NAME, null, null, null, null, null];

function buildGrids() {
    var abilitiesGrid = $('#aim_abilities_grid');
    abilitiesGrid.RemoveAndDeleteChildren();
    for (var i = 0; i < ABILITY_SLOT_COUNT; i++) {
        createSlotCell(abilitiesGrid, abilitySlots, i);
    }

    var itemsGrid = $('#aim_items_grid');
    itemsGrid.RemoveAndDeleteChildren();
    for (var row = 0; row < ITEM_SLOT_ROWS; row++) {
        var rowPanel = $.CreatePanel('Panel', itemsGrid, 'aim_items_row_' + row);
        rowPanel.AddClass('RowNoFill');
        for (var col = 0; col < ITEM_SLOT_COLS; col++) {
            createSlotCell(rowPanel, itemSlots, row * ITEM_SLOT_COLS + col);
        }
    }
}

function createSlotCell(parent, state, index) {
    var cell = $.CreatePanel('Button', parent, '');
    cell.AddClass('AimSlot');
    cell.SetPanelEvent('onactivate', function () { onSlotClicked(state, index); });
    renderSlot(cell, state[index]);
    cell.SetAttributeString('slot_state', state[index] === ITEM_NAME ? ITEM_NAME : EMPTY);
    return cell;
}

function renderSlot(cell, value) {
    cell.RemoveAndDeleteChildren();
    if (value === ITEM_NAME) {
        cell.AddClass('AimSlotFilled');
        var img = $.CreatePanel('DOTAItemImage', cell, '');
        img.itemname = ITEM_NAME;
        img.AddClass('AimSlotItemImage');
    } else {
        cell.RemoveClass('AimSlotFilled');
    }
}

function countBusy() {
    var busy = 0;
    for (var i = 0; i < abilitySlots.length; i++) {
        if (abilitySlots[i] === ITEM_NAME) busy++;
    }
    for (var j = 0; j < itemSlots.length; j++) {
        if (itemSlots[j] === ITEM_NAME) busy++;
    }
    return busy;
}

function onSlotClicked(state, index) {
    var errorMsg = $('#errorMsg');
    errorMsg.text = '';

    if (state[index] === ITEM_NAME) {
        // Clicking a busy slot empties it, but at least one slot must stay busy.
        if (countBusy() <= 1) {
            errorMsg.text = 'At least one slot must have the item';
            return;
        }
        state[index] = null;
    } else {
        state[index] = ITEM_NAME;
    }
    buildGrids();
}

function slotsToSend(state) {
    var result = [];
    for (var i = 0; i < state.length; i++) {
        result.push(state[i] === ITEM_NAME ? ITEM_NAME : EMPTY);
    }
    return result;
}

// ---------------------------------------------------------------------------
// Round settings: duration + spawn-speed curve with live graph preview.
// The curve math below mirrors aim_compet.lua (ComputeSpawnSchedule) exactly -
// keep WARD_CAP, CLASSIC_DECAY and the formulas in sync with the server.
// ---------------------------------------------------------------------------

var WARD_CAP = 500;      // keep in sync with aim_compet.lua
var CLASSIC_DECAY = 0.08; // keep in sync with aim_compet.lua
var GRAPH_SAMPLES = 100;

// legacy (old hardcoded) values - used on load and by the "default" button
var LEGACY_DEFAULTS = { roundTime: 60, type: 'classic', startInterval: 2.0, endInterval: 0.4, exponent: 2, wardLifetime: 2.0 };

function makeSwitcher(parentId, id, min, max, step, placeholder, x10) {
    var parent = $(parentId);
    parent.RemoveAndDeleteChildren();
    var sw = $.CreatePanel('Panel', parent, id);
    sw.SetAttributeString("min", String(min));
    sw.SetAttributeString("max", String(max));
    sw.SetAttributeString("step", String(step));
    sw.SetAttributeString("placeholder", String(placeholder));
    if (x10) sw.SetAttributeString("x10control", "1");
    sw.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml", false, false);
    return sw;
}

var sw = {};
function buildSwitchers(d) {
    sw.roundTime = makeSwitcher('#roundTimeSwitcher', 'round_time_sw', 10, 600, 10, d.roundTime, true);
    sw.startInterval = makeSwitcher('#startIntervalSwitcher', 'start_interval_sw', 0.1, 3, 0.1, d.startInterval, true);
    sw.endInterval = makeSwitcher('#endIntervalSwitcher', 'end_interval_sw', 0.1, 3, 0.1, d.endInterval, true);
    sw.exponent = makeSwitcher('#exponentSwitcher', 'exponent_sw', 0.2, 5, 0.2, d.exponent, false);
    sw.wardLifetime = makeSwitcher('#wardLifetimeSwitcher', 'ward_lifetime_sw', 0.5, 5, 0.1, d.wardLifetime, true);
}

// "default" button: back to the legacy round settings
function resetDefaults() {
    $('#curveClassic').checked = true;
    buildSwitchers(LEGACY_DEFAULTS);
    GameEvents.SendCustomGameEventToServer("aim_compet_area_reset", {});
    updateCurve(true);
}

// "set area" button: hides the menu (server side) and opens the area picker overlay
function pickArea() {
    GameEvents.SendCustomGameEventToServer("aim_compet_area_pick_start", {});
}

// server sends the current area offsets; the row shows width × height
GameEvents.Subscribe("aim_compet_area_result", function (data) {
    $('#areaSizeValue').text = Math.round(data.maxX - data.minX) + ' × ' + Math.round(data.maxY - data.minY);
});

function switcherValue(sw, fallback) {
    var v = parseFloat(sw.GetAttributeString("value", ""));
    return isNaN(v) ? fallback : v;
}

function getCurveType() {
    if ($('#curveConstant').checked) return 'constant';
    if ($('#curveLinear').checked) return 'linear';
    if ($('#curvePower').checked) return 'power';
    return 'classic';
}

function currentSettings() {
    return {
        roundTime: switcherValue(sw.roundTime, 60),
        type: getCurveType(),
        startInterval: switcherValue(sw.startInterval, 2.0),
        endInterval: switcherValue(sw.endInterval, 0.4),
        exponent: switcherValue(sw.exponent, 2),
        wardLifetime: switcherValue(sw.wardLifetime, 2.0)
    };
}

// Same algorithm as aim_compet:ComputeSpawnSchedule - spawn times in seconds from round start
function computeSchedule(cfg) {
    var times = [0];
    var t = 0;
    var classicInterval = cfg.startInterval;
    while (times.length < WARD_CAP) {
        var dt;
        if (cfg.type === 'classic') {
            dt = classicInterval;
            classicInterval = Math.max(cfg.endInterval, classicInterval - CLASSIC_DECAY);
        } else {
            var progress = Math.min(1, t / cfg.roundTime);
            if (cfg.type === 'constant') {
                dt = cfg.startInterval;
            } else if (cfg.type === 'power') {
                dt = cfg.startInterval + (cfg.endInterval - cfg.startInterval) * Math.pow(progress, cfg.exponent);
            } else { // linear
                dt = cfg.startInterval + (cfg.endInterval - cfg.startInterval) * progress;
            }
        }
        dt = Math.max(0.05, dt);
        t += dt;
        // a ward needs its whole lifetime inside the round (mirrors the server)
        if (t > cfg.roundTime - cfg.wardLifetime) break;
        times.push(t);
    }
    return times;
}

// interval between wards at time t, derived from the schedule
function intervalAt(times, fallback, t) {
    if (times.length < 2) return fallback;
    var i = 0;
    while (i < times.length - 1 && times[i + 1] <= t) i++;
    if (i >= times.length - 1) return times[times.length - 1] - times[times.length - 2];
    return times[i + 1] - times[i];
}

var curveGraph = CreateGraph($('#curveGraphContainer'), {
    title: '#aimCurveGraphTitle',
    plotWidth: 520,
    plotHeight: 200,
    yMin: 0,
    yMax: 'auto',
    yUnit: 's',
    yTicks: 4,
    xStart: 0,
    xStep: 1,
    formatX: function (v) { return Math.round(v) + 's'; },
    showLegend: false,
    series: [{ id: 'interval', name: 'interval', color: '#9CDBEE', thickness: 2 }]
});

var lastSettingsKey = '';

function updateCurve(force) {
    var cfg = currentSettings();
    var key = [cfg.roundTime, cfg.type, cfg.startInterval, cfg.endInterval, cfg.exponent, cfg.wardLifetime].join('|');
    if (!force && key === lastSettingsKey) return;
    lastSettingsKey = key;

    // constant ignores the end interval, only power uses the exponent
    $('#endIntervalRow').SetHasClass('Hidden', cfg.type === 'constant');
    $('#exponentRow').SetHasClass('Hidden', cfg.type !== 'power');

    var times = computeSchedule(cfg);
    var data = [];
    for (var k = 0; k < GRAPH_SAMPLES; k++) {
        var t = cfg.roundTime * k / (GRAPH_SAMPLES - 1);
        data.push(intervalAt(times, cfg.startInterval, t));
    }
    curveGraph.SetOption('xStep', cfg.roundTime / (GRAPH_SAMPLES - 1));
    curveGraph.SetData({ interval: data });
    $('#wardEstimateValue').text = times.length;
}

// number_switcher has no change callback, so poll the attributes while the page is alive
function pollSettings() {
    if (!$.GetContextPanel().IsValid()) return;
    updateCurve(false);
    $.Schedule(0.25, pollSettings);
}

function startGame() {
    var errorMsg = $('#errorMsg')
    errorMsg.text = '';
    var cfg = currentSettings();

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
        {
            gameModeName: "aim_compet",
            // Two separate arrays: busy slots hold the item name, empty ones hold "empty".
            aimAbilitySlots: slotsToSend(abilitySlots),
            aimItemSlots: slotsToSend(itemSlots),
            // round settings, validated and clamped again server-side (ReadRoundSettings)
            roundTime: cfg.roundTime,
            spawnCurveType: cfg.type,
            spawnStartInterval: cfg.startInterval,
            spawnEndInterval: cfg.endInterval,
            spawnExponent: cfg.exponent,
            wardLifetime: cfg.wardLifetime,
        });
}

function saveData(data) {
    $.Msg(JSON.stringify(data));
}

GameEvents.Subscribe("aim_compet_spell_table", saveData);

buildGrids();
buildSwitchers(LEGACY_DEFAULTS);
updateCurve(true);
pollSettings();
GameEvents.SendCustomGameEventToServer("get_aim_compet_area", {});
