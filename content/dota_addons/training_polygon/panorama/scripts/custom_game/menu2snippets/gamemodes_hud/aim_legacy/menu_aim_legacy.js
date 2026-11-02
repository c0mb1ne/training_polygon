$.Msg('aim_legacy menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_aim_legacy_spell_table",
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

function startGame() {
    var errorMsg = $('#errorMsg')
    errorMsg.text = '';

    GameEvents.SendCustomGameEventToServer("activate_game_mode",
        {
            gameModeName: "aim_legacy",
            // Two separate arrays: busy slots hold the item name, empty ones hold "empty".
            aimAbilitySlots: slotsToSend(abilitySlots),
            aimItemSlots: slotsToSend(itemSlots),
        });
}

function saveData(data) {
    $.Msg(JSON.stringify(data));
}

GameEvents.Subscribe("aim_legacy_spell_table", saveData);

buildGrids();
