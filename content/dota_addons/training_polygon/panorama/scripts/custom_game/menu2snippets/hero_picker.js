//=============================================================================
// hero_picker.js
// Reusable "hero picker" component.
//
// Usage:
//   var picker = CreateHeroPicker($('#someContainer'), {
//       defaultHero: 'npc_dota_hero_antimage',
//       onSelect: function(heroName) { ... }
//   });
//
//   picker.GetSelectedHero()      -> "npc_dota_hero_antimage"
//   picker.SetSelectedHero(name)  -> updates icon + internal state
//   picker.GetPanel()             -> the widget's root panel, if you need to move/hide it
//
// Include this file's <scripts> and hero_picker.css's <styles> once per page
// (e.g. in your top-level layout), then call CreateHeroPicker() as many times
// as you like. Each instance loads hero_picker.xml into its own dynamically
// created container and looks up its children BY CLASS, scoped to that
// container - so there are no id collisions between instances.
//=============================================================================

const HERO_PICKER_XML = 'file://{resources}/layout/custom_game/menu2snippets/hero_picker.xml';

// ---- shared hero list, fetched once and cached for every picker instance ----
var HeroPickerData = {
	list: [],
	loaded: false,
	pending: []
};

GameEvents.SendCustomGameEventToServer('dotadb_get_hero_list', {});
GameEvents.Subscribe('dotadb_get_hero_list_answer', function (data) {
	let heroList = data.hero_list;
	let names = [];
	for (let key in heroList) {
		names.push(heroList[key]);
	}
	names.sort(function (a, b) {
		let na = a.replace('npc_dota_hero_', '');
		let nb = b.replace('npc_dota_hero_', '');
		return na > nb ? 1 : (na < nb ? -1 : 0);
	});

	HeroPickerData.list = names;
	HeroPickerData.loaded = true;

	// resolve anything that opened its popup before the list arrived
	for (let i = 0; i < HeroPickerData.pending.length; i++) {
		HeroPickerData.pending[i]();
	}
	HeroPickerData.pending = [];
});

// ---- factory ----
var _heroPickerInstanceCount = 0;

function CreateHeroPicker(parentPanel, opts) {
	opts = opts || {};
	const instanceId = 'hero_picker_' + (_heroPickerInstanceCount++);

	let selectedHero = opts.defaultHero || 'npc_dota_hero_antimage';
	const onSelect = opts.onSelect || function () {};

	// load the widget markup into its own container
	const widgetRoot = $.CreatePanel('Panel', parentPanel, instanceId);
	widgetRoot.BLoadLayout(HERO_PICKER_XML, false, false);

	// look up children BY CLASS, scoped to this instance -> safe with duplicates
	const iconBtn = widgetRoot.FindChildrenWithClassTraverse('HeroPickerIconContainer')[0];
	const iconImg = widgetRoot.FindChildrenWithClassTraverse('heroPickerIcon')[0];
	iconImg.heroname = selectedHero;

	let popupPanel = null;

	function closePopup() {
		if (popupPanel) {
			popupPanel.DeleteAsync(0);
			popupPanel = null;
		}
	}

	function buildPopup() {
		const root = $.GetContextPanel();
		popupPanel = $.CreatePanel('Panel', root, instanceId + '_overlay');
		popupPanel.AddClass('hero_picker_overlay');
		popupPanel.SetPanelEvent('onactivate', closePopup); // click outside grid closes it

		const grid = $.CreatePanel('Panel', popupPanel, instanceId + '_grid');
		grid.AddClass('heroPickerPopup');

		for (let i = 0; i < HeroPickerData.list.length; i++) {
			const heroName = HeroPickerData.list[i];

			const btn = $.CreatePanel('Button', grid, instanceId + '_hero_' + i);
			btn.AddClass('heroPickerButton');
			if (heroName === selectedHero) {
				btn.AddClass('heroPickerSelected');
			}

			const icon = $.CreatePanel('DOTAHeroImage', btn, instanceId + '_hicon_' + i);
			icon.heroimagestyle = 'icon';
			icon.heroname = heroName;

			btn.SetPanelEvent('onactivate', function () {
				selectedHero = heroName;
				iconImg.heroname = heroName;
				onSelect(heroName);
				closePopup();
			});
		}
	}

	function openPopup() {
		if (popupPanel) {
			closePopup();
			return;
		}
		if (HeroPickerData.loaded) {
			buildPopup();
		} else {
			// hero list not back from the server yet, build as soon as it is
			HeroPickerData.pending.push(buildPopup);
		}
	}

	iconBtn.SetPanelEvent('onactivate', openPopup);

	return {
		GetPanel: function () {
			return widgetRoot;
		},
		GetSelectedHero: function () {
			return selectedHero;
		},
		SetSelectedHero: function (heroName) {
			selectedHero = heroName;
			iconImg.heroname = heroName;
		}
	};
}