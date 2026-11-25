//=============================================================================
// sound_settings.js
// Reusable per-gamemode good/bad notification sound picker.
//
// Include user_config_client.js before this file in the host layout, then:
//   var soundSettings = CreateSoundSettings($('#soundSettingsContainer'), {
//       scope: 'dodge',
//       onChange: function(type, soundId, scope) { ... } // optional
//   });
//
//   soundSettings.GetSelectedSounds()       -> { good: "frog", bad: "sproing" }
//   soundSettings.SetScope('timing')        -> switch to another mode's settings
//   soundSettings.GetPanel()                -> the widget root
//   soundSettings.ClosePopup()              -> close its popup, if open
//
// scope is "general" or a registered gamemode name. Selections are applied via
// UserConfigClient for the current session; this snippet does not require a
// separate settings page or a gamemode selector. sound_settings.xml and its CSS
// are loaded automatically. Children are found by class inside each instance.
//=============================================================================

var SOUND_SETTINGS_XML = 'file://{resources}/layout/custom_game/menu2snippets/sound_settings.xml';

// The sound catalogue is shared by every instance and fetched only once.
var SoundSettingsData;
if (typeof SoundSettingsData === 'undefined') {
	SoundSettingsData = {
		entries: {},
		loaded: false,
		pending: []
	};

	GameEvents.Subscribe('notifications_send_sounds', function (data) {
		SoundSettingsData.entries = data.data || {};
		SoundSettingsData.loaded = true;

		var pending = SoundSettingsData.pending;
		SoundSettingsData.pending = [];
		for (var i = 0; i < pending.length; i++) {
			pending[i]();
		}
	});
	GameEvents.SendCustomGameEventToServer('notifications_get_sounds', {});
}

function LocalizeSoundSettingToken(token) {
	var localized = $.Localize('#' + token);
	if (localized === '#' + token || localized === '') {
		return token;
	}
	return localized;
}

var _soundSettingsInstanceCount;
if (typeof _soundSettingsInstanceCount === 'undefined') {
	_soundSettingsInstanceCount = 0;
}

function CreateSoundSettings(parentPanel, opts) {
	opts = opts || {};
	if (!parentPanel) {
		$.Msg('[SoundSettings] CreateSoundSettings requires a parent panel');
		return null;
	}

	var instanceId = 'sound_settings_' + (_soundSettingsInstanceCount++);
	var scope = opts.scope || 'general';
	var selectedSounds = {
		good: opts.defaultGood || 'frog',
		bad: opts.defaultBad || 'sproing'
	};
	var onChange = opts.onChange || function () {};

	var widgetRoot = $.CreatePanel('Panel', parentPanel, instanceId);
	widgetRoot.BLoadLayout(SOUND_SETTINGS_XML, false, false);

	var button = widgetRoot.FindChildrenWithClassTraverse('SoundSettingsButton')[0];
	var goodValue = widgetRoot.FindChildrenWithClassTraverse('SoundSettingsGoodValue')[0];
	var badValue = widgetRoot.FindChildrenWithClassTraverse('SoundSettingsBadValue')[0];
	var popupLayer = null;
	var optionContainers = { good: null, bad: null };
	var waitingForSounds = false;

	function getDisplayName(soundId) {
		var entry = SoundSettingsData.entries[soundId];
		return LocalizeSoundSettingToken(entry && entry.displayName ? entry.displayName : soundId);
	}

	function updateButton() {
		goodValue.text = getDisplayName(selectedSounds.good);
		badValue.text = getDisplayName(selectedSounds.bad);
	}

	function updateChecked() {
		if (!popupLayer) {
			return;
		}
		var types = ['good', 'bad'];
		for (var i = 0; i < types.length; i++) {
			var type = types[i];
			var container = optionContainers[type];
			if (!container) {
				continue;
			}
			$.Each(container.Children(), function (entryButton) {
				entryButton.checked = entryButton.GetAttributeString('sound_id', '') === selectedSounds[type];
			});
		}
	}

	function restoreFromConfig() {
		var good = UserConfigClient.Get(scope, 'notif_good_sound');
		var bad = UserConfigClient.Get(scope, 'notif_bad_sound');
		if (good !== undefined && good !== null) {
			selectedSounds.good = good;
		}
		if (bad !== undefined && bad !== null) {
			selectedSounds.bad = bad;
		}
		updateButton();
		updateChecked();
	}

	function getRandomSound(sounds) {
		var values = Object.values(sounds || {});
		if (values.length === 0) {
			return null; // the "no sound" option previews as silence
		}
		return values[Math.floor(Math.random() * values.length)];
	}

	function selectSound(type, soundId) {
		selectedSounds[type] = soundId;
		UserConfigClient.Set(scope, type === 'good' ? 'notif_good_sound' : 'notif_bad_sound', soundId);
		updateButton();
		updateChecked();
		onChange(type, soundId, scope);
	}

	function closePopup() {
		if (popupLayer) {
			popupLayer.DeleteAsync(0);
			popupLayer = null;
			optionContainers.good = null;
			optionContainers.bad = null;
		}
	}

	function drawSoundEntry(parent, type, soundId, entry) {
		var entryButton = $.CreatePanel('ToggleButton', parent, instanceId + '_' + type + '_' + soundId);
		entryButton.AddClass('SoundSettingsEntry');
		entryButton.SetAttributeString('sound_id', soundId);
		entryButton.checked = selectedSounds[type] === soundId;

		var label = $.CreatePanel('Label', entryButton, instanceId + '_label_' + type + '_' + soundId);
		label.text = LocalizeSoundSettingToken(entry.displayName);

		entryButton.SetPanelEvent('onactivate', function () {
			var previewSound = getRandomSound(entry.sounds);
			if (previewSound !== null) {
				Game.EmitSound(previewSound);
			}
			selectSound(type, soundId);
		});
	}

	function buildPopup() {
		if (popupLayer) {
			return;
		}

		var root = $.GetContextPanel();
		popupLayer = $.CreatePanel('Panel', root, instanceId + '_popup_layer');
		popupLayer.AddClass('SoundSettingsPopupLayer');

		var overlay = $.CreatePanel('Button', popupLayer, instanceId + '_overlay');
		overlay.AddClass('SoundSettingsOverlay');
		overlay.SetPanelEvent('onactivate', closePopup);

		var popup = $.CreatePanel('Panel', popupLayer, instanceId + '_popup');
		popup.AddClass('SoundSettingsPopup');

		var header = $.CreatePanel('Panel', popup, instanceId + '_header');
		header.AddClass('SoundSettingsPopupHeader');
		var title = $.CreatePanel('Label', header, instanceId + '_title');
		title.AddClass('SoundSettingsPopupTitle');
		title.text = $.Localize('#settingsNotifications');
		var closeButton = $.CreatePanel('Button', header, instanceId + '_close');
		closeButton.AddClass('SoundSettingsCloseButton');
		closeButton.SetPanelEvent('onactivate', closePopup);
		var closeLabel = $.CreatePanel('Label', closeButton, instanceId + '_close_label');
		closeLabel.text = '×';

		var content = $.CreatePanel('Panel', popup, instanceId + '_content');
		content.AddClass('SoundSettingsPopupContent');
		var types = ['good', 'bad'];
		for (var i = 0; i < types.length; i++) {
			var type = types[i];
			var section = $.CreatePanel('Panel', content, instanceId + '_' + type + '_section');
			section.AddClass('SoundSettingsSection');
			var sectionLabel = $.CreatePanel('Label', section, instanceId + '_' + type + '_label');
			sectionLabel.AddClass('SoundSettingsSectionLabel');
			sectionLabel.text = $.Localize(type === 'good' ? '#settingsGoodSound' : '#settingsBadSound');
			var options = $.CreatePanel('Panel', section, instanceId + '_' + type + '_options');
			options.AddClass('SoundSettingsOptions');
			optionContainers[type] = options;

			for (var soundId in SoundSettingsData.entries) {
				drawSoundEntry(options, type, soundId, SoundSettingsData.entries[soundId]);
			}
		}
	}

	function openPopup() {
		if (popupLayer) {
			closePopup();
			return;
		}
		if (SoundSettingsData.loaded) {
			buildPopup();
		} else if (!waitingForSounds) {
			waitingForSounds = true;
			SoundSettingsData.pending.push(function () {
				waitingForSounds = false;
				buildPopup();
			});
		}
	}

	button.SetPanelEvent('onactivate', openPopup);
	UserConfigClient.OnLoad(restoreFromConfig);
	if (SoundSettingsData.loaded) {
		updateButton();
	} else {
		SoundSettingsData.pending.push(updateButton);
	}

	return {
		GetPanel: function () {
			return widgetRoot;
		},
		GetSelectedSounds: function () {
			return { good: selectedSounds.good, bad: selectedSounds.bad };
		},
		GetScope: function () {
			return scope;
		},
		SetScope: function (newScope) {
			if (!newScope) {
				return;
			}
			closePopup();
			scope = newScope;
			restoreFromConfig();
		},
		ClosePopup: closePopup
	};
}
