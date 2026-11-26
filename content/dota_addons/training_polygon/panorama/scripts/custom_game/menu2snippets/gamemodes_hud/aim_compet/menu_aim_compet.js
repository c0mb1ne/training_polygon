$.Msg('aim_compet menu hud loaded');

var ITEM_NAMES = ['item_aim_topor', 'item_aim_topor2', 'item_aim_topor3', 'item_aim_topor4'];
var EMPTY = 'empty';
var ABILITY_SLOT_COUNT = 4;
var ITEM_SLOT_ROWS = 2;
var ITEM_SLOT_COLS = 3;
var DEFAULT_TARGET_UNIT = 'npc_dota_observer_wards';
var DEFAULT_TARGET_HERO = 'npc_dota_hero_axe';

var abilitySlots = [null, null, null, null];
var itemSlots = [ITEM_NAMES[0], null, null, null, null, null];
var itemCount = 1;
var selectedItemColor = 0;
var unitCatalogue = [];
var heroTargetPicker = null;
var unitTargetPicker = null;
var syncingBladeUI = false;
var colorTargetsPreference = true;
var colorTargetsForced = false;
var sw = {};

function createBladeSettings(overrides) {
    var blade = {
        targetType: 'unit',
        unitName: DEFAULT_TARGET_UNIT,
        heroName: DEFAULT_TARGET_HERO,
        moving: false,
        moveSpeedMin: 600,
        moveSpeedMax: 1500,
        moveSpeedRamp: 0,
        modelScaleStart: 1.0,
        modelScaleEnd: 1.0
    };
    if (overrides) {
        for (var key in overrides) blade[key] = overrides[key];
    }
    return blade;
}

function defaultBladeSet() {
    return [
        createBladeSettings(),
        createBladeSettings(),
        createBladeSettings(),
        createBladeSettings()
    ];
}

function cloneBlades(blades) {
    var result = [];
    for (var i = 0; i < blades.length; i++) result.push(createBladeSettings(blades[i]));
    return result;
}

function presetBlades(firstBlade) {
    var blades = defaultBladeSet();
    blades[0] = createBladeSettings(firstBlade);
    return blades;
}

var bladeSettings = defaultBladeSet();

// ---------------------------------------------------------------------------
// Blade ability/item slots
// ---------------------------------------------------------------------------

function buildGrids() {
    var abilitiesGrid = $('#aim_abilities_grid');
    abilitiesGrid.RemoveAndDeleteChildren();
    for (var i = 0; i < ABILITY_SLOT_COUNT; i++) createSlotCell(abilitiesGrid, abilitySlots, i);

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
    cell.SetAttributeString('slot_state', state[index] === null ? EMPTY : state[index]);
    return cell;
}

function renderSlot(cell, value) {
    cell.RemoveAndDeleteChildren();
    cell.RemoveClass('AimSlotFilled');
    if (value !== null) {
        cell.AddClass('AimSlotFilled');
        var img = $.CreatePanel('DOTAItemImage', cell, '');
        img.itemname = value;
        img.AddClass('AimSlotItemImage');
    }
}

function countBusy() {
    var busy = 0;
    var i;
    for (i = 0; i < abilitySlots.length; i++) if (abilitySlots[i] !== null) busy++;
    for (i = 0; i < itemSlots.length; i++) if (itemSlots[i] !== null) busy++;
    return busy;
}

function nextItem(value) {
    if (value === null) return ITEM_NAMES[0];
    var index = ITEM_NAMES.indexOf(value);
    if (index < 0 || index >= itemCount - 1) return null;
    return ITEM_NAMES[index + 1];
}

function onSlotClicked(state, index) {
    var errorMsg = $('#errorMsg');
    errorMsg.text = '';
    var next = nextItem(state[index]);
    if (next === null && countBusy() <= 1) {
        errorMsg.text = 'At least one slot must have an axe';
        return;
    }
    state[index] = next;
    buildGrids();
}

function slotsToSend(state) {
    var result = [];
    for (var i = 0; i < state.length; i++) result.push(state[i] === null ? EMPTY : state[i]);
    return result;
}

function getItemCount() {
    for (var i = 1; i <= 4; i++) if ($('#itemCount' + i).checked) return i;
    return 1;
}

function normalizeSlotsForCount() {
    var states = [abilitySlots, itemSlots];
    for (var s = 0; s < states.length; s++) {
        for (var i = 0; i < states[s].length; i++) {
            var colorIndex = ITEM_NAMES.indexOf(states[s][i]);
            if (colorIndex >= itemCount) states[s][i] = null;
        }
    }
    if (countBusy() === 0) itemSlots[0] = ITEM_NAMES[0];
}

function getUnboundBlades() {
    var bound = [false, false, false, false];
    var states = [abilitySlots, itemSlots];
    for (var s = 0; s < states.length; s++) {
        for (var i = 0; i < states[s].length; i++) {
            var colorIndex = ITEM_NAMES.indexOf(states[s][i]);
            if (colorIndex >= 0 && colorIndex < itemCount) bound[colorIndex] = true;
        }
    }

    var missing = [];
    for (var color = 0; color < itemCount; color++) {
        if (!bound[color]) missing.push(color);
    }
    return missing;
}

function hasDuplicateTargets() {
    var seen = {};
    for (var i = 0; i < itemCount; i++) {
        var blade = bladeSettings[i];
        var targetName = blade.targetType === 'hero' ? blade.heroName : blade.unitName;
        if (seen[targetName]) return true;
        seen[targetName] = true;
    }
    return false;
}

function updateColorTargetsOption() {
    var forced = hasDuplicateTargets();
    var toggle = $('#colorTargetsToggle');
    if (forced) {
        colorTargetsForced = true;
        toggle.enabled = false;
        toggle.checked = true;
    } else {
        if (colorTargetsForced) toggle.checked = colorTargetsPreference;
        colorTargetsForced = false;
        toggle.enabled = true;
        colorTargetsPreference = toggle.checked;
    }
    $('#colorTargetsForcedHint').SetHasClass('Hidden', !forced);
}

// ---------------------------------------------------------------------------
// Per-blade target settings and pickers
// ---------------------------------------------------------------------------

function switcherValue(switcher, fallback) {
    var value = parseFloat(switcher.GetAttributeString('value', ''));
    return isNaN(value) ? fallback : value;
}

function makeSwitcher(parentId, id, min, max, step, placeholder, x10) {
    var parent = $(parentId);
    parent.RemoveAndDeleteChildren();
    var switcher = $.CreatePanel('Panel', parent, id);
    switcher.SetAttributeString('min', String(min));
    switcher.SetAttributeString('max', String(max));
    switcher.SetAttributeString('step', String(step));
    switcher.SetAttributeString('placeholder', String(placeholder));
    if (x10) switcher.SetAttributeString('x10control', '1');
    switcher.BLoadLayout('file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml', false, false);
    return switcher;
}

function buildRoundSwitchers(d) {
    sw.roundTime = makeSwitcher('#roundTimeSwitcher', 'round_time_sw', 10, 600, 10, d.roundTime, true);
    sw.startInterval = makeSwitcher('#startIntervalSwitcher', 'start_interval_sw', 0.1, 3, 0.1, d.startInterval, true);
    sw.endInterval = makeSwitcher('#endIntervalSwitcher', 'end_interval_sw', 0.1, 3, 0.1, d.endInterval, true);
    sw.exponent = makeSwitcher('#exponentSwitcher', 'exponent_sw', 0.2, 5, 0.2, d.exponent, false);
    sw.targetLifetime = makeSwitcher('#targetLifetimeSwitcher', 'target_lifetime_sw', 0.5, 5, 0.1, d.targetLifetime, true);
}

function buildBladeSwitchers(d) {
    sw.moveSpeedMin = makeSwitcher('#moveSpeedMinSwitcher', 'move_speed_min_sw', 50, 2000, 50, d.moveSpeedMin, false);
    sw.moveSpeedMax = makeSwitcher('#moveSpeedMaxSwitcher', 'move_speed_max_sw', 50, 2000, 50, d.moveSpeedMax, false);
    sw.moveSpeedRamp = makeSwitcher('#moveSpeedRampSwitcher', 'move_speed_ramp_sw', 0, 1000, 50, d.moveSpeedRamp, false);
    sw.modelScaleStart = makeSwitcher('#modelScaleStartSwitcher', 'model_scale_start_sw', 0.2, 2, 0.1, d.modelScaleStart, true);
    sw.modelScaleEnd = makeSwitcher('#modelScaleEndSwitcher', 'model_scale_end_sw', 0.2, 2, 0.1, d.modelScaleEnd, true);
}

function saveSelectedBladeSettings() {
    if (syncingBladeUI || !heroTargetPicker || !unitTargetPicker || !sw.modelScaleEnd) return;
    var blade = bladeSettings[selectedItemColor];
    blade.targetType = $('#targetCategoryHero').checked ? 'hero' : 'unit';
    blade.heroName = heroTargetPicker.GetSelectedHero();
    blade.unitName = unitTargetPicker.GetSelectedUnit() || DEFAULT_TARGET_UNIT;
    blade.moving = $('#movingTargetsToggle').checked;
    blade.moveSpeedMin = switcherValue(sw.moveSpeedMin, 600);
    blade.moveSpeedMax = switcherValue(sw.moveSpeedMax, 1500);
    blade.moveSpeedRamp = switcherValue(sw.moveSpeedRamp, 0);
    blade.modelScaleStart = switcherValue(sw.modelScaleStart, 1.0);
    blade.modelScaleEnd = switcherValue(sw.modelScaleEnd, 1.0);
}

function updateTargetRows(blade) {
    var heroSelected = blade.targetType === 'hero';
    $('#heroTargetPicker').SetHasClass('Hidden', !heroSelected);
    $('#unitTargetPicker').SetHasClass('Hidden', heroSelected);
    $('#moveSpeedMinRow').SetHasClass('Hidden', !blade.moving);
    $('#moveSpeedMaxRow').SetHasClass('Hidden', !blade.moving);
    $('#moveSpeedRampRow').SetHasClass('Hidden', !blade.moving);
}

function syncBladeUI() {
    if (!heroTargetPicker || !unitTargetPicker) return;
    syncingBladeUI = true;
    var blade = bladeSettings[selectedItemColor];
    $('#targetCategoryHero').checked = blade.targetType === 'hero';
    $('#targetCategoryUnit').checked = blade.targetType !== 'hero';
    heroTargetPicker.SetSelectedHero(blade.heroName);
    unitTargetPicker.SetSelectedUnit(blade.unitName);
    $('#movingTargetsToggle').checked = blade.moving;
    buildBladeSwitchers(blade);
    updateTargetRows(blade);
    syncingBladeUI = false;
}

function buildItemTargetTabs() {
    var tabs = $('#itemTargetTabs');
    tabs.RemoveAndDeleteChildren();
    for (var i = 0; i < itemCount; i++) {
        (function (colorIndex) {
            var button = $.CreatePanel('Button', tabs, '');
            button.AddClass('AimColorButton');
            button.SetHasClass('AimColorButtonSelected', colorIndex === selectedItemColor);
            button.SetPanelEvent('onactivate', function () {
                saveSelectedBladeSettings();
                selectedItemColor = colorIndex;
                buildItemTargetTabs();
            });
            var img = $.CreatePanel('DOTAItemImage', button, '');
            img.itemname = ITEM_NAMES[colorIndex];
            img.AddClass('AimSlotItemImage');
        })(i);
    }
    syncBladeUI();
}

function updateItemConfiguration() {
    var newCount = getItemCount();
    if (newCount !== itemCount) {
        saveSelectedBladeSettings();
        itemCount = newCount;
        if (selectedItemColor >= itemCount) selectedItemColor = itemCount - 1;
        normalizeSlotsForCount();
        buildGrids();
        buildItemTargetTabs();
    }
}

function buildTargetPickers() {
    var blade = bladeSettings[selectedItemColor];
    heroTargetPicker = CreateHeroPicker($('#heroTargetPicker'), {
        defaultHero: blade.heroName,
        onSelect: function (heroName) {
            if (!syncingBladeUI) bladeSettings[selectedItemColor].heroName = heroName;
        }
    });
    unitTargetPicker = CreateUnitPicker($('#unitTargetPicker'), {
        units: unitCatalogue,
        defaultUnit: blade.unitName,
        onSelect: function (unitName) {
            if (!syncingBladeUI) bladeSettings[selectedItemColor].unitName = unitName;
        }
    });
}

GameEvents.Subscribe('aim_compet_unit_table', function (data) {
    var list = [];
    var table = data.data || {};
    for (var key in table) list.push(table[key]);
    unitCatalogue = list;
    if (unitTargetPicker) unitTargetPicker.SetUnits(unitCatalogue);
});

// ---------------------------------------------------------------------------
// Legacy configurations
// ---------------------------------------------------------------------------

var LEGACY_PRESETS = {
    'default': {
        roundTime: 60, type: 'classic', startInterval: 2.0, endInterval: 0.4, exponent: 2,
        targetLifetime: 2.0, spawnArea: 'classic', itemCount: 1,
        blades: presetBlades({})
    },
    'hard': {
        roundTime: 60, type: 'classic', startInterval: 2.0, endInterval: 0.4, exponent: 2,
        targetLifetime: 2.0, spawnArea: 'classic', itemCount: 2,
        blades: presetBlades({})
    },
    'moving': {
        roundTime: 60, type: 'classic', startInterval: 2.0, endInterval: 1.5, exponent: 2,
        targetLifetime: 2.0, spawnArea: 'classic', itemCount: 1,
        blades: presetBlades({
            unitName: 'npc_dota_neutral_centaur_khan_custom', moving: true,
            moveSpeedMin: 600, moveSpeedMax: 1500, moveSpeedRamp: 300,
            modelScaleStart: 1.0, modelScaleEnd: 0.4
        })
    },
    'map': {
        roundTime: 60, type: 'classic', startInterval: 2.5, endInterval: 1.14, exponent: 2,
        targetLifetime: 2.0, spawnArea: 'all_map', itemCount: 1,
        blades: presetBlades({unitName: 'npc_dota_creep_badguys_melee'})
    }
};

function setCurveType(type) {
    var ids = {classic: '#curveClassic', constant: '#curveConstant', linear: '#curveLinear', power: '#curvePower'};
    $(ids[type] || ids.classic).checked = true;
}

function applyPreset(name) {
    var cfg = LEGACY_PRESETS[name] || LEGACY_PRESETS['default'];
    setCurveType(cfg.type);
    $('#zoneAllMap').checked = cfg.spawnArea === 'all_map';
    $('#zoneClassic').checked = cfg.spawnArea !== 'all_map';

    itemCount = cfg.itemCount;
    $('#itemCount' + itemCount).checked = true;
    selectedItemColor = 0;
    bladeSettings = cloneBlades(cfg.blades);
    abilitySlots = [null, null, null, null];
    itemSlots = [null, null, null, null, null, null];
    for (var i = 0; i < itemCount; i++) itemSlots[i] = ITEM_NAMES[i];

    colorTargetsPreference = true;
    colorTargetsForced = false;
    $('#colorTargetsToggle').enabled = true;
    $('#colorTargetsToggle').checked = true;
    buildRoundSwitchers(cfg);
    buildGrids();
    buildItemTargetTabs();
    updateColorTargetsOption();
    updateCurve(true);
    $('#errorMsg').text = '';
}

// ---------------------------------------------------------------------------
// Round settings and spawn graph
// ---------------------------------------------------------------------------

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
        targetLifetime: switcherValue(sw.targetLifetime, 2.0),
        spawnArea: $('#zoneAllMap').checked ? 'all_map' : 'classic',
        colorTargets: colorTargetsForced || colorTargetsPreference,
        itemCount: itemCount,
        blades: cloneBlades(bladeSettings)
    };
}

var TARGET_CAP = 500;
var CLASSIC_DECAY = 0.08;
var GRAPH_SAMPLES = 100;

function computeSchedule(cfg) {
    var times = [0];
    var t = 0;
    var classicInterval = cfg.startInterval;
    while (times.length < TARGET_CAP) {
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
            } else {
                dt = cfg.startInterval + (cfg.endInterval - cfg.startInterval) * progress;
            }
        }
        dt = Math.max(0.05, dt);
        t += dt;
        if (t > cfg.roundTime - cfg.targetLifetime) break;
        times.push(t);
    }
    return times;
}

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
    series: [{id: 'interval', name: 'interval', color: '#9CDBEE', thickness: 2}]
});

var lastSettingsKey = '';

function updateCurve(force) {
    var cfg = currentSettings();
    var key = [cfg.roundTime, cfg.type, cfg.startInterval, cfg.endInterval, cfg.exponent, cfg.targetLifetime].join('|');
    if (!force && key === lastSettingsKey) return;
    lastSettingsKey = key;

    $('#endIntervalRow').SetHasClass('Hidden', cfg.type === 'constant');
    $('#exponentRow').SetHasClass('Hidden', cfg.type !== 'power');

    var times = computeSchedule(cfg);
    var data = [];
    for (var k = 0; k < GRAPH_SAMPLES; k++) {
        var t = cfg.roundTime * k / (GRAPH_SAMPLES - 1);
        data.push(intervalAt(times, cfg.startInterval, t));
    }
    curveGraph.SetOption('xStep', cfg.roundTime / (GRAPH_SAMPLES - 1));
    curveGraph.SetData({interval: data});
    $('#targetEstimateValue').text = times.length;
}

function pollSettings() {
    if (!$.GetContextPanel().IsValid()) return;
    updateItemConfiguration();
    saveSelectedBladeSettings();
    updateTargetRows(bladeSettings[selectedItemColor]);
    updateColorTargetsOption();
    updateCurve(false);
    $.Schedule(0.1, pollSettings);
}

function startGame() {
    updateItemConfiguration();
    saveSelectedBladeSettings();
    updateColorTargetsOption();
    $('#errorMsg').text = '';

    var unboundBlades = getUnboundBlades();
    if (unboundBlades.length > 0) {
        $('#errorMsg').text = $.Localize('#aimBladeBindingError');
        return;
    }

    var cfg = currentSettings();
    var bladesToSend = [];
    for (var i = 0; i < cfg.blades.length; i++) {
        var blade = cfg.blades[i];
        bladesToSend.push({
            targetType: blade.targetType,
            targetName: blade.targetType === 'hero' ? blade.heroName : blade.unitName,
            moving: blade.moving ? 1 : 0,
            moveSpeedMin: blade.moveSpeedMin,
            moveSpeedMax: blade.moveSpeedMax,
            moveSpeedRamp: blade.moveSpeedRamp,
            modelScaleStart: blade.modelScaleStart,
            modelScaleEnd: blade.modelScaleEnd
        });
    }

    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'aim_compet',
        aimAbilitySlots: slotsToSend(abilitySlots),
        aimItemSlots: slotsToSend(itemSlots),
        roundTime: cfg.roundTime,
        spawnCurveType: cfg.type,
        spawnStartInterval: cfg.startInterval,
        spawnEndInterval: cfg.endInterval,
        spawnExponent: cfg.exponent,
        targetLifetime: cfg.targetLifetime,
        spawnArea: cfg.spawnArea,
        colorTargets: cfg.colorTargets ? 1 : 0,
        itemCount: cfg.itemCount,
        aimBladeSettings: bladesToSend
    });
}

GameEvents.Subscribe('aim_compet_config_error', function (data) {
    $('#errorMsg').text = $.Localize(data.message || '#aimBladeBindingError');
});

var soundSettings = null;
var soundSettingsContainer = $('#soundSettingsContainer');
if (soundSettingsContainer) {
    soundSettings = CreateSoundSettings(soundSettingsContainer, {
        scope: 'timing',
        onChange: function (type, soundId, scope) {}
    });
}

buildGrids();
buildRoundSwitchers(LEGACY_PRESETS['default']);
buildTargetPickers();
buildItemTargetTabs();
updateColorTargetsOption();
updateCurve(true);
GameEvents.SendCustomGameEventToServer('get_aim_compet_unit_table', {});
pollSettings();
