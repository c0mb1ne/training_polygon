"use strict";

/**
 * TEST: html panel login popup (revert: delete this file + login_popup.xml/css + its line in custom_ui_manifest.xml)
 * Owns the login DOTAHTMLPanel popup. Other ui calls GameUI.CustomUIConfig().OpenLoginPopup(url).
 * Auto-closes on the login_done game event.
 */

function loginPopupPanels() {
    var overlay = $.GetContextPanel();
    var htmlPanel = $("#LoginPopupHtml");
    if (!overlay || !htmlPanel) {
        return null;
    }
    return { overlay: overlay, htmlPanel: htmlPanel };
}

function openLoginPopup(url) {
    var p = loginPopupPanels();
    if (!p) {
        $.Msg("[LoginPopup] ERROR: popup panels missing (login_popup.xml not loaded?)");
        return;
    }
    p.htmlPanel.SetIgnoreCursor(false);
    p.htmlPanel.SetURL(url);
    p.overlay.style.visibility = "visible";
    p.overlay.style.opacity = "1";
}

function closeLoginPopup() {
    var p = loginPopupPanels();
    if (!p) {
        return;
    }
    p.overlay.style.visibility = "collapse";
    p.overlay.style.opacity = "0";
}

(function () {
    var cfg = GameUI.CustomUIConfig();
    cfg.OpenLoginPopup = openLoginPopup;
    cfg.CloseLoginPopup = closeLoginPopup;

    if ($("#LoginPopupClose")) {
        $("#LoginPopupClose").SetPanelEvent("onactivate", closeLoginPopup);
    }

    //home_page asks the server (open_login_popup_request), server echoes this to all ui
    GameEvents.Subscribe("open_login_popup", function (ev) {
        if (ev && ev.link) {
            openLoginPopup(String(ev.link));
        }
    });

    GameEvents.Subscribe("login_done", function () {
        closeLoginPopup();
    });
})();
