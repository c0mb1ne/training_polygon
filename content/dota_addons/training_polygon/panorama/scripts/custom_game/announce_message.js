"use strict";
// Place at: content/<addon>/panorama/scripts/custom_game/announcer/announcer.js
// Panel this is attached to must contain #AnnouncerContainer / #AnnouncerBox / #AnnouncerLabel (see announcer.xml)

(function () {

	var container = $.GetContextPanel();
	var label = $("#AnnouncerLabel");

	var hideTimer = null;

	// ---- core display logic -------------------------------------------------

	function ClearTimer() {
		if (hideTimer !== null) {
			$.CancelScheduled(hideTimer);
			hideTimer = null;
		}
	}

	// duration: number of seconds, or <= 0 / undefined for "stays until HideMessage() is called"
	function ShowMessage(message, duration) {
		ClearTimer();

		label.text = $.Localize(message);

		container.RemoveClass("Hidden");
		// one frame delay so the transition from opacity:0 actually plays instead of snapping
		$.Schedule(0, function () {
			container.AddClass("AnnouncerVisible");
		});

		if (typeof duration === "number" && duration > 0) {
			hideTimer = $.Schedule(duration, HideMessage);
		}
	}

	function HideMessage() {
		ClearTimer();
		container.RemoveClass("AnnouncerVisible");
		// wait for the fade-out transition before fully collapsing the panel
		$.Schedule(0.25, function () {
			container.AddClass("Hidden");
		});
	}

	// ---- inbound: server Lua -> this client ----------------------------------
	// Fired by Announcer:ShowMessage()/:HideMessage() on the server via
	// CustomGameEventManager:Send_ServerToAllClients / Send_ServerToPlayer

	GameEvents.Subscribe("announcer_show_message", function (data) {
		ShowMessage(data.message, data.duration);
	});

	GameEvents.Subscribe("announcer_hide_message", function (data) {
		HideMessage();
	});

	// ---- outbound: JS -> server Lua singleton --------------------------------
	// Use these when the trigger originates client-side (e.g. a button in another
	// panel) but you still want the Lua Announcer class to own/broadcast it.

	function RequestShowFromServer(message, duration) {
		GameEvents.SendCustomGameEventToServer("announcer_request_show", {
			message: message,
			duration: (typeof duration === "number") ? duration : -1
		});
	}

	function RequestHideFromServer() {
		GameEvents.SendCustomGameEventToServer("announcer_request_hide", {});
	}

	// ---- public API exposed to any other panel's JS --------------------------
	// e.g. from another script: GameUI.CustomUIConfig().Announcer.ShowMessage("GG", 5);

	GameUI.CustomUIConfig().Announcer = {
		// Goes through the server, so it's consistent/broadcastable and Lua stays authoritative.
		ShowMessage: RequestShowFromServer,
		HideMessage: RequestHideFromServer,

		// Updates only this client's panel directly, no round trip to server.
		// Useful for purely-local UI feedback that shouldn't touch game state.
		ShowMessageLocal: ShowMessage,
		HideMessageLocal: HideMessage
	};

})();