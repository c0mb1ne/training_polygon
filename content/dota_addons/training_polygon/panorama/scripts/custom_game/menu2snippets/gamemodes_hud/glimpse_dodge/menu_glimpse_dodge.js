$.Msg('glimpse_dodge menu hud loaded')

let glimpseDodgeSpells = {};
let glimpseDodgeDefaultHero = 'npc_dota_hero_antimage';

function getGlimpseDodgeType() {
    let timingName = 'item_manta';
    $.Each($('#glimpseDodgeTypes').Children(), function(panel) {
        if (panel.checked) {
            timingName = panel.id;
        }
    });
    return timingName;
}

function updateGlimpseDodgeHeroPicker(type) {
    $('#heroPickerContainer').style.visibility = type === 'item_manta' ? 'visible' : 'collapse';
}

function drawGlimpseDodgeType(parent, name) {
    let modePanel = $.CreatePanel('RadioButton', parent, name);
    modePanel.SetAttributeString('name', name);
    modePanel.SetPanelEvent('onactivate', function() {
        updateGlimpseDodgeHeroPicker(name);
    });
    modePanel.BLoadLayout('file://{resources}/layout/custom_game/menu2snippets/gamemodes_hud/timing/timing_type.xml', false, false);
    if (name === 'item_manta') {
        modePanel.checked = true;
    }
}

function saveGlimpseDodgeData(data) {
    glimpseDodgeSpells = data.data;
    let typesPanel = $('#glimpseDodgeTypes');
    typesPanel.RemoveAndDeleteChildren();
    for (let type in glimpseDodgeSpells) {
        drawGlimpseDodgeType(typesPanel, type);
    }
    updateGlimpseDodgeHeroPicker(getGlimpseDodgeType());
}

function startGame() {
    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'glimpse_dodge',
        timingType: getGlimpseDodgeType(),
        defaultHero: glimpseDodgeDefaultHero,
        travelBoots: $('#travelBootsToggle').checked
    });
}

CreateHeroPicker($('#heroPickerContainer'), {
    defaultHero: glimpseDodgeDefaultHero,
    onSelect: function(hero) {
        glimpseDodgeDefaultHero = hero;
    }
});

CreateSoundSettings($('#soundSettingsContainer'), {
    scope: 'glimpse_dodge'
});

GameEvents.Subscribe('glimpse_dodge_spell_table', saveGlimpseDodgeData);
GameEvents.SendCustomGameEventToServer('get_glimpse_dodge_spell_table', {});
