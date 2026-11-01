$.Msg('armlet menu loaded')

var towerUnits = ["npc_dota_goodguys_tower1_mid", "npc_dota_goodguys_tower2_mid"]
var towerNames = ["Tier 1 tower", "Tier 2-4 tower. Their damage and attack speed are same."]
var selectedUnit = "npc_dota_hero_abaddon"

GameEvents.SendCustomGameEventToServer("dotadb_get_hero_list", {});

function saveHeroList(data) {
    let heroList = data.hero_list

    // sort by hero name, same approach as dodge hero picker
    let keys = []
    for (let key in heroList) {
        keys[keys.length] = key
    }
    for (let i = 0; i < keys.length - 1; i++) {
        for (let j = i + 1; j < keys.length; j++) {
            let nameA = heroList[keys[i]].replace("npc_dota_hero_", "")
            let nameB = heroList[keys[j]].replace("npc_dota_hero_", "")
            if (nameA > nameB) {
                let tmp = keys[i]
                keys[i] = keys[j]
                keys[j] = tmp
            }
        }
    }

    let picker = $('#armletUnitPicker')
    for (let i = 0; i < towerUnits.length; i++) {
        drawUnitButton(picker, towerUnits[i], towerNames[i])
    }
    for (let i = 0; i < keys.length; i++) {
        drawUnitButton(picker, heroList[keys[i]], null)
    }
}

function drawUnitButton(parent, unitName, tooltipText) {
    var btn = $.CreatePanel('Panel', parent, 'unit_' + unitName)
    btn.AddClass('armletUnitSelector')
    btn.SetAttributeString('unit', unitName)
    if (unitName.indexOf('tower') !== -1) {
        var thumb = $.CreatePanel('Panel', btn, '')
        thumb.AddClass('armletTowerThumb')
    } else {
        var heroThumb = $.CreatePanel('DOTAHeroImage', btn, '')
        heroThumb.heroimagestyle = 'icon'
        heroThumb.heroname = unitName
    }
    if (unitName === selectedUnit) {
        btn.AddClass('armletUnitSelected')
    }
    btn.SetPanelEvent('onactivate', function() {
        selectUnit(unitName)
    })
    if (tooltipText) {
        btn.SetPanelEvent('onmouseover', function() {
            $.DispatchEvent('DOTAShowTextTooltip', btn, tooltipText)
        })
        btn.SetPanelEvent('onmouseout', function() {
            $.DispatchEvent('DOTAHideTextTooltip', btn)
        })
    }
}

function selectUnit(unitName) {
    selectedUnit = unitName
    $.Each($('#armletUnitPicker').Children(), function(panel) {
        if (panel.GetAttributeString('unit', '') === unitName) {
            panel.AddClass('armletUnitSelected')
        } else {
            panel.RemoveClass('armletUnitSelected')
        }
    })
}

function startGame() {
    if (!selectedUnit) {
        $('#errorMsg').text = 'Error: no unit selected.'
        return
    }
    GameEvents.SendCustomGameEventToServer('activate_game_mode', {
        gameModeName: 'armlet',
        unitName: selectedUnit
    })
}

GameEvents.Subscribe('dotadb_get_hero_list_answer', saveHeroList)
