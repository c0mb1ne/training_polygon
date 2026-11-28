$.Msg('invoke_training menu hud loaded');

var invokeQueueSwitcher = null;
var invokeLastMode = null;
var invokeQueueDepthByMode = {practice: 1, challenge: 6};
var invokeToolsMode = Game.IsInToolsMode();
var invokeSpellNames = [
    'invoker_cold_snap',
    'invoker_ghost_walk',
    'invoker_tornado',
    'invoker_emp',
    'invoker_alacrity',
    'invoker_chaos_meteor',
    'invoker_sun_strike',
    'invoker_forge_spirit',
    'invoker_ice_wall',
    'invoker_deafening_blast'
];

function invokeEnabledSpells() {
    var enabled = [];
    if (!invokeToolsMode) return enabled;
    for (var i = 0; i < invokeSpellNames.length; i++) {
        var toggle = $('#invokeSpellPool' + i);
        if (toggle && toggle.checked) enabled.push(invokeSpellNames[i]);
    }
    return enabled;
}

function invokeUpdateSpellPoolState() {
    var empty = invokeToolsMode && invokeEnabledSpells().length === 0;
    $('#menu_play').enabled = !empty;
    $('#invokeSpellPoolHint').SetHasClass('InvokeSpellPoolEmpty', empty);
    $('#invokeSpellPoolHint').text = $.Localize(empty ? '#invokeSpellPoolEmpty' : '#invokeSpellPoolHint');
}

function invokeSetAllSpells(checked) {
    for (var i = 0; i < invokeSpellNames.length; i++) {
        var toggle = $('#invokeSpellPool' + i);
        if (toggle) toggle.checked = checked;
    }
    invokeUpdateSpellPoolState();
}

function invokeBuildSpellPool() {
    var container = $('#invokeSpellPoolList');
    container.RemoveAndDeleteChildren();
    for (var i = 0; i < invokeSpellNames.length; i++) {
        var spellName = invokeSpellNames[i];
        var toggle = $.CreatePanel('ToggleButton', container, 'invokeSpellPool' + i);
        toggle.AddClass('customCheckbox');
        toggle.AddClass('InvokeSpellToggle');
        toggle.checked = true;
        toggle.SetPanelEvent('onactivate', invokeUpdateSpellPoolState);

        var icon = $.CreatePanel('DOTAAbilityImage', toggle, 'invokeSpellPoolIcon' + i);
        icon.abilityname = spellName;
        var label = $.CreatePanel('Label', toggle, 'invokeSpellPoolLabel' + i);
        label.text = $.Localize('#DOTA_Tooltip_ability_' + spellName);
    }
    $('#invokeToolsSettings').SetHasClass('InvokeToolsVisible', invokeToolsMode);
    $('#invokeDebugDrawToggle').checked = false;
    invokeUpdateSpellPoolState();
}

function invokeSelectedMode() {
    return $('#invokeModeChallenge').checked ? 'challenge' : 'practice';
}

function invokeTargetCount() {
    for (var i = 1; i <= 4; i++) {
        if ($('#invokeTargets' + i).checked) return i;
    }
    return 3;
}

function invokeCreateQueueSwitcher(value) {
    var container = $('#invokeQueueDepthSwitcher');
    container.RemoveAndDeleteChildren();
    invokeQueueSwitcher = $.CreatePanel('Panel', container, 'invoke_queue_depth');
    invokeQueueSwitcher.SetAttributeString('min', '1');
    invokeQueueSwitcher.SetAttributeString('max', '6');
    invokeQueueSwitcher.SetAttributeString('step', '1');
    invokeQueueSwitcher.SetAttributeString('placeholder', String(value));
    invokeQueueSwitcher.BLoadLayout('file://{resources}/layout/custom_game/menu2snippets/number_switcher.xml', false, false);
}

function invokeQueueDepth() {
    if (!invokeQueueSwitcher) return 1;
    var value = parseInt(invokeQueueSwitcher.GetAttributeString('value', '1'), 10);
    return isNaN(value) ? 1 : value;
}

function invokeUpdateModeUI(force) {
    var mode = invokeSelectedMode();
    if (force || mode !== invokeLastMode) {
        if (!force && invokeLastMode !== null) {
            invokeQueueDepthByMode[invokeLastMode] = invokeQueueDepth();
        }
        invokeCreateQueueSwitcher(invokeQueueDepthByMode[mode]);
        invokeLastMode = mode;
    }

    var practice = mode === 'practice';
    $('#invokeOneSphereToggle').enabled = practice;
    $('#invokeOneSphereHint').SetHasClass('InvokeSettingHintDisabled', !practice);
}

function invokePollSettings() {
    if (!$.GetContextPanel().IsValid()) return;
    invokeUpdateModeUI(false);
    $.Schedule(0.1, invokePollSettings);
}

function startGame() {
    invokeUpdateModeUI(false);
    var enabledSpells = invokeEnabledSpells();
    if (invokeToolsMode && enabledSpells.length === 0) return;
    var mode = invokeSelectedMode();
    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'invoke_training',
        mode: mode,
        targetCount: invokeTargetCount(),
        queueDepth: invokeQueueDepth(),
        oneSphere: mode === 'practice' && $('#invokeOneSphereToggle').checked ? 1 : 0,
        debugDraw: invokeToolsMode && $('#invokeDebugDrawToggle').checked ? 1 : 0,
        enabledSpells: enabledSpells
    });
}

var invokeSoundSettings = CreateSoundSettings($('#soundSettingsContainer'), {
    scope: 'invoke_training',
    onChange: function(type, soundId, scope) {}
});

// XML checked attributes alone are not consistently applied when this snippet loads.
$('#invokeModePractice').checked = true;
$('#invokeModeChallenge').checked = false;
$('#invokeTargets1').checked = false;
$('#invokeTargets2').checked = false;
$('#invokeTargets3').checked = true;
$('#invokeTargets4').checked = false;
invokeBuildSpellPool();
invokeUpdateModeUI(true);
invokePollSettings();
