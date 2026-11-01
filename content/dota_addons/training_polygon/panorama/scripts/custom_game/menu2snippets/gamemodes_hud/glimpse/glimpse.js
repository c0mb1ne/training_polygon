$.Msg('glimpse menu loaded')

var escapeTypes = ["item_manta", "phantom_lancer_doppelwalk", "naga_siren_mirror_image",
    "ember_spirit_sleight_of_fist", "chaos_knight_phantasm", "sandking_burrowstrike", "shredder_timber_chain"]
var escapeHeroes = ["npc_dota_hero_antimage", "npc_dota_hero_phantom_lancer", "npc_dota_hero_naga_siren",
    "npc_dota_hero_ember_spirit", "npc_dota_hero_chaos_knight", "npc_dota_hero_sand_king", "npc_dota_hero_shredder"]
var escapeLabels = ["Manta Style", "Doppelganger", "Mirror Image", "Sleight of Fist", "Phantasm", "Burrowstrike", "Timber Chain"]
var selectedIndex = 0

for (var i = 0; i < escapeTypes.length; i++) {
    drawEscapeButton($('#glimpseTypePicker'), i)
}
$('#glimpseTypePicker').Children()[0].AddClass('glimpseTypeSelected')
updateLevelVisibility()

function drawEscapeButton(parent, index) {
    var btn = $.CreatePanel('Panel', parent, 'escape_' + index)
    btn.AddClass('glimpseTypeButton')
    if (escapeHeroes[index] === 'npc_dota_hero_antimage') {
        var icon = $.CreatePanel('Panel', btn, '')
        icon.AddClass('glimpseMantaIcon')
    } else {
        var heroThumb = $.CreatePanel('DOTAHeroImage', btn, '')
        heroThumb.heroimagestyle = 'icon'
        heroThumb.heroname = escapeHeroes[index]
    }
    var label = $.CreatePanel('Label', btn, '')
    label.AddClass('glimpseTypeLabel')
    label.text = escapeLabels[index]
    btn.SetPanelEvent('onactivate', function() {
        selectedIndex = index
        $.Each(parent.Children(), function(panel) {
            panel.RemoveClass('glimpseTypeSelected')
        })
        btn.AddClass('glimpseTypeSelected')
        updateLevelVisibility()
    })
}

function updateLevelVisibility() {
    // burrowstrike and timber chain take a level argument
    if (selectedIndex === 5 || selectedIndex === 6) {
        $('#glimpseLevelRow').RemoveClass('Hidden')
    } else {
        $('#glimpseLevelRow').AddClass('Hidden')
    }
}

function getSelectedLevel() {
    for (var i = 1; i <= 4; i++) {
        if ($('#glimpseLvl' + i).checked) {
            return i
        }
    }
    return 3
}

function startGame() {
    var timebar = 0
    if ($('#timebarToggle').checked) {
        timebar = 1
    }
    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'glimpse',
        skillId: selectedIndex + 1,
        level: getSelectedLevel(),
        timebar: timebar
    })
}
