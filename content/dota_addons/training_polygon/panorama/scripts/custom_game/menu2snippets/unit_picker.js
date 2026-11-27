//=============================================================================
// Reusable picker for the server-provided Aim Competition unit catalogue.
//=============================================================================

const UNIT_PICKER_XML = 'file://{resources}/layout/custom_game/menu2snippets/unit_picker.xml';
var _unitPickerInstanceCount = 0;

function CreateUnitPicker(parentPanel, opts) {
    opts = opts || {};
    const instanceId = 'unit_picker_' + (_unitPickerInstanceCount++);
    const onSelect = opts.onSelect || function () {};
    let units = opts.units || [];
    let selectedUnit = opts.defaultUnit || (units[0] && units[0].name) || '';

    const widgetRoot = $.CreatePanel('Panel', parentPanel, instanceId);
    widgetRoot.BLoadLayout(UNIT_PICKER_XML, false, false);

    const button = widgetRoot.FindChildrenWithClassTraverse('UnitPickerButton')[0];
    const icon = widgetRoot.FindChildrenWithClassTraverse('unitPickerIcon')[0];
    const nameLabel = widgetRoot.FindChildrenWithClassTraverse('unitPickerName')[0];
    nameLabel.style['visibility']="collapse;"
    let popupPanel = null;

    function getEntry(unitName) {
        for (let i = 0; i < units.length; i++) {
            if (units[i].name === unitName) return units[i];
        }
        return null;
    }

    function unitIconSource(entry) {
        const iconName = (entry && (entry.icon || entry.name)) || 'npc_dota_observer_wards';
        return iconName;
    }
//file://{images}/heroes/npc_dota_neutral_eimermole.png
    function renderSelection() {
        const entry = getEntry(selectedUnit);
        /* icon.src = unitIconSource(entry); */
        icon.SetImage(unitIconSource(entry));
        nameLabel.text = entry ? $.Localize(entry.label) : '';
    }

    function closePopup() {
        if (popupPanel) {
            popupPanel.DeleteAsync(0);
            popupPanel = null;
        }
    }

    function buildPopup() {
        const root = $.GetContextPanel();
        popupPanel = $.CreatePanel('Panel', root, instanceId + '_overlay');
        popupPanel.AddClass('unit_picker_overlay');
        popupPanel.SetPanelEvent('onactivate', closePopup);

        const grid = $.CreatePanel('Panel', popupPanel, instanceId + '_grid');
        grid.AddClass('unitPickerPopup');

        for (let i = 0; i < units.length; i++) {
            const entry = units[i];
            const option = $.CreatePanel('Button', grid, instanceId + '_unit_' + i);
            option.AddClass('unitPickerOption');
            option.SetHasClass('unitPickerSelected', entry.name === selectedUnit);

            const optionIcon = $.CreatePanel('Image', option, instanceId + '_icon_' + i);
            optionIcon.AddClass('unitPickerIcon');
            optionIcon.SetImage(unitIconSource(entry));

            const optionName = $.CreatePanel('Label', option, instanceId + '_name_' + i);
            optionName.AddClass('unitPickerName');
            optionName.text = $.Localize(entry.label);
            optionName.style['visibility']="collapse;"
            option.SetPanelEvent('onactivate', function () {
                selectedUnit = entry.name;
                renderSelection();
                onSelect(selectedUnit);
                closePopup();
            });
        }
    }

    function openPopup() {
        if (popupPanel) {
            closePopup();
        } else if (units.length > 0) {
            buildPopup();
        }
    }

    button.SetPanelEvent('onactivate', openPopup);
    renderSelection();

    return {
        GetPanel: function () { return widgetRoot; },
        GetSelectedUnit: function () { return selectedUnit; },
        SetSelectedUnit: function (unitName) {
            selectedUnit = unitName;
            renderSelection();
        },
        SetUnits: function (unitList) {
            units = unitList || [];
            if (!getEntry(selectedUnit) && units.length > 0) selectedUnit = units[0].name;
            renderSelection();
        }
    };
}
