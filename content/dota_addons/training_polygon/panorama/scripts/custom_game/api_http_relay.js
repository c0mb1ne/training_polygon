"use strict";

/**
 * =========================================================================================
 * TRAINING POLYGON - CLIENT PANORAMA HTTP RELAY BRIDGE
 * =========================================================================================
 * Relays HTTP requests from the server Lua environment via invisible
 * DOTAHTMLPanels to https://combine.isgood.host/bridge and returns responses.
 * Used when CreateHTTPRequestScriptVM is unavailable (lobby-hosted games).
 * Protocol adapted from RANDOM FARM TD's http relay.
 * =========================================================================================
 */

var BRIDGE_BASES = [
    "https://combine.isgood.host"
];
var bridgeBaseIndex = 0;

function bridgeRoot() {
    return BRIDGE_BASES[Math.min(bridgeBaseIndex, BRIDGE_BASES.length - 1)];
}

function bridgeUrl() {
    return bridgeRoot() + "/bridge";
}

var SLOT_COUNT = 4;
var URL_BODY_LIMIT = 1200;
var RESULT_CHUNK = 700;
var OUTBOX_CHUNK = 800;
var SLOT_TIMEOUT_SEC = 14;

var queue = [];
var slots = [];
var incoming = {};

function panelIsValid(panel) {
    try {
        return !!panel && (typeof panel.IsValid !== "function" || panel.IsValid());
    } catch (e) {
        return false;
    }
}

function sendAck(requestId) {
    GameEvents.SendCustomGameEventToServer("api_http_relay_ack", {
        request_id: requestId,
        PlayerID: Players.GetLocalPlayer()
    });
}

function sendResultChunks(requestId, status, body) {
    var text = body || "";
    var total = Math.max(1, Math.ceil(text.length / RESULT_CHUNK));
    for (var i = 0; i < total; i++) {
        var chunk = text.substring(i * RESULT_CHUNK, (i + 1) * RESULT_CHUNK);
        GameEvents.SendCustomGameEventToServer("api_http_relay_result", {
            request_id: requestId,
            status: status,
            chunk: chunk,
            chunk_index: i,
            chunk_total: total,
            PlayerID: Players.GetLocalPlayer()
        });
    }
}

function takeOwner() {
    var cfg = GameUI.CustomUIConfig();
    var ctx = $.GetContextPanel();
    if (!ctx) return false;
    if (!cfg._apiHtmlOwner || !panelIsValid(cfg._apiHtmlOwner)) {
        cfg._apiHtmlOwner = ctx;
    }
    return cfg._apiHtmlOwner === ctx;
}

function claimRequest(requestId) {
    var cfg = GameUI.CustomUIConfig();
    if (!cfg._apiHtmlClaimed) {
        cfg._apiHtmlClaimed = {};
    }
    var prev = cfg._apiHtmlClaimed[requestId];
    if (prev && panelIsValid(prev.panel)) {
        return false;
    }
    cfg._apiHtmlClaimed[requestId] = { panel: $.GetContextPanel() };
    return true;
}

function decodePacked(packed) {
    if (!packed) return null;
    try {
        var parsed = JSON.parse(decodeURIComponent(packed));
        return {
            id: Math.floor(Number(parsed.id) || 0),
            status: Math.floor(Number(parsed.status) || 0),
            body: parsed.body !== undefined && parsed.body !== null ? String(parsed.body) : ""
        };
    } catch (e) {
        try {
            var rawParsed = JSON.parse(packed);
            return {
                id: Math.floor(Number(rawParsed.id) || 0),
                status: Math.floor(Number(rawParsed.status) || 0),
                body: rawParsed.body !== undefined && rawParsed.body !== null ? String(rawParsed.body) : ""
            };
        } catch (e2) {
            return null;
        }
    }
}

function parsePackedFromText(text) {
    if (!text) return null;
    var marker = "DOTA_HTTP|";
    var markerAt = text.indexOf(marker);
    if (markerAt >= 0) {
        return decodePacked(text.substring(markerAt + marker.length));
    }
    var qIdx = text.indexOf("?");
    if (qIdx < 0) return null;
    var query = text.substring(qIdx + 1).split("#")[0];
    var parts = query.split("&");
    for (var i = 0; i < parts.length; i++) {
        var eq = parts[i].indexOf("=");
        if (eq <= 0) continue;
        var key = decodeURIComponent(parts[i].substring(0, eq));
        var val = decodeURIComponent(parts[i].substring(eq + 1));
        if (key === "p") {
            return decodePacked(val);
        }
    }
    return null;
}

function parseAck(text) {
    var marker = "DOTA_HTTP_ACK_";
    var at = text.indexOf(marker);
    if (at < 0) return null;
    var rest = text.substring(at + marker.length);
    var bits = rest.split("_");
    if (bits.length < 2) return null;
    return {
        id: Math.floor(Number(bits[0]) || 0),
        index: Math.floor(Number(bits[1]) || 0)
    };
}

function wantsInbox(text) {
    return text.indexOf("inbox=1") >= 0 || text.indexOf("DOTA_HTTP_DONE_") >= 0;
}

function parseDone(text) {
    var marker = "DOTA_HTTP_DONE_";
    var at = text.indexOf(marker);
    if (at < 0) return null;
    var bits = text.substring(at + marker.length).split("_");
    if (bits.length < 2) return null;
    return {
        id: Math.floor(Number(bits[0]) || 0),
        status: Math.floor(Number(bits[1]) || 0),
        total: Math.max(0, Math.floor(Number(bits[2]) || 0))
    };
}

function parsePart(text) {
    var marker = "DOTA_HTTP_PART_";
    var at = text.indexOf(marker);
    if (at < 0) return null;
    var rest = text.substring(at + marker.length);
    var bar = rest.indexOf("|");
    if (bar < 0) return null;
    var bits = rest.substring(0, bar).split("_");
    if (bits.length < 4) return null;
    var chunk = rest.substring(bar + 1);
    try {
        chunk = decodeURIComponent(chunk);
    } catch (e) {}
    return {
        id: Math.floor(Number(bits[0]) || 0),
        status: Math.floor(Number(bits[1]) || 0),
        index: Math.floor(Number(bits[2]) || 0),
        total: Math.max(1, Math.floor(Number(bits[3]) || 1)),
        chunk: chunk
    };
}

function apiPathFromUrl(fullUrl) {
    if (!fullUrl) return "/";
    var marker = "combine.isgood.host";
    var idx = fullUrl.indexOf(marker);
    if (idx >= 0) {
        return fullUrl.substring(idx + marker.length);
    }
    if (fullUrl.charAt(0) === "/") {
        return fullUrl;
    }
    return "/" + fullUrl;
}

function encodedTooLong(body) {
    return body && encodeURIComponent(body).length > URL_BODY_LIMIT;
}

function headerParams(headers) {
    if (!headers) return "";
    var out = "";
    for (var name in headers) {
        if (Object.prototype.hasOwnProperty.call(headers, name)) {
            out += "&h_" + encodeURIComponent(name) + "=" + encodeURIComponent(String(headers[name]));
        }
    }
    return out;
}

function execHref(item, body, fromOutbox) {
    var destPath = apiPathFromUrl(item.url);
    return (
        bridgeUrl() +
        "?id=" + item.requestId +
        "&method=" + encodeURIComponent(item.method) +
        "&path=" + encodeURIComponent(destPath) +
        headerParams(item.headers) +
        (fromOutbox ? "&outbox=1" : (body ? "&body=" + encodeURIComponent(body) : ""))
    );
}

function outboxHref(item, index, total, chunk) {
    return (
        bridgeUrl() +
        "?action=outbox&id=" + item.requestId +
        "&i=" + index +
        "&n=" + total +
        "&d=" + encodeURIComponent(chunk)
    );
}

function inboxHref(requestId, part) {
    return bridgeUrl() + "?action=inbox&id=" + requestId + "&part=" + part;
}

function isPanelDead(text) {
    if (!text) return false;
    var lower = text.toLowerCase();
    return lower.indexOf("http://error") >= 0 || lower.indexOf("chrome-error") >= 0 || lower.indexOf("net::err") >= 0;
}

function markSlotWarm(slot, text) {
    if (!text) return;
    var lower = text.toLowerCase();
    if (isPanelDead(text)) {
        slot.warm = false;
        return;
    }
    if (
        lower.indexOf("dota-http-bridge") >= 0 ||
        lower.indexOf("dota_http|") >= 0 ||
        lower.indexOf("dota_http_done") >= 0 ||
        lower.indexOf("dota_http_part") >= 0 ||
        lower.indexOf("warm_ok") >= 0
    ) {
        if (!slot.warm) {
            slot.warm = true;
        }
    }
}

function runBridgeJs(slot, source) {
    var panel = slot.panel;
    if (!panel || typeof panel.RunJavascript !== "function") return false;
    try {
        panel.RunJavascript(source);
        return true;
    } catch (e) {
        return false;
    }
}

function execViaWarmJs(slot, item) {
    if (!slot.warm || encodedTooLong(item.body)) return false;
    var href = execHref(item, item.body, false);
    var script =
        "(function(){try{fetch(" +
        JSON.stringify(href) +
        ",{credentials:'omit'}).then(function(r){return r.text();}).then(function(html){var m=html.match(/<title>([\\s\\S]*?)<\\/title>/i);if(m){document.title=m[1];}}).catch(function(){document.title='DOTA_HTTP_JS_FAIL';});}catch(e){document.title='DOTA_HTTP_JS_FAIL';}})();";
    if (!runBridgeJs(slot, script)) return false;
    return true;
}

function setPanelUrl(slot, href) {
    if (!slot.panel || typeof slot.panel.SetURL !== "function") return;
    if (typeof slot.panel.SetIgnoreCursor === "function") {
        slot.panel.SetIgnoreCursor(true);
    }
    slot.panel.SetURL(href);
}

function collectStrings(args) {
    var out = [];
    if (!args) return out;
    for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (typeof arg === "string" && arg.length > 0) {
            out.push(arg);
        }
    }
    return out;
}

function collectPanelTexts(slot) {
    var texts = [];
    var panel = slot.panel;
    if (!panel) return texts;
    for (var n = 0; n < 2; n++) {
        var name = n === 0 ? "GetTitle" : "GetURL";
        try {
            if (typeof panel[name] === "function") {
                var val = panel[name]();
                if (typeof val === "string" && val.length > 0) {
                    texts.push(val);
                }
            }
        } catch (e) {}
    }
    return texts;
}

function collectAllTexts(slot, args) {
    var out = collectStrings(args);
    var pTexts = collectPanelTexts(slot);
    for (var i = 0; i < pTexts.length; i++) {
        if (out.indexOf(pTexts[i]) < 0) {
            out.push(pTexts[i]);
        }
    }
    return out;
}

function acceptParsed(slot, parsed) {
    var item = slot.item;
    if (!item) return false;
    if (parsed.id !== item.requestId && parsed.id !== 0) return false;
    finishSlot(slot, parsed.status, parsed.body);
    return true;
}

function handleAck(slot, ack) {
    var item = slot.item;
    if (!item || slot.phase !== "outbox") return false;
    if (ack.id !== item.requestId && ack.id !== 0) return false;
    if (ack.index !== slot.outboxIndex) return false;

    slot.outboxIndex += 1;
    if (slot.outboxIndex >= slot.outboxTotal) {
        slot.phase = "exec";
        setPanelUrl(slot, execHref(item, "", true));
        return true;
    }
    loadOutboxChunk(slot);
    return true;
}

function startInbox(slot, totalHint, statusHint) {
    if (!slot.item || typeof slot.panel.SetURL !== "function") return false;
    if (slot.phase === "inbox" && slot.inboxTried) return false;

    slot.inboxTried = true;
    slot.phase = "inbox";
    slot.inboxIndex = 0;
    slot.inboxTotal = totalHint;
    slot.inboxStatus = statusHint;
    slot.inboxParts = {};
    slot.age = 0;

    setPanelUrl(slot, inboxHref(slot.item.requestId, 0));
    return true;
}

function acceptPart(slot, part) {
    var item = slot.item;
    if (!item) return false;
    if (part.id !== item.requestId && part.id !== 0) return false;

    // If this specific part chunk was already accepted and stored, ignore repeat poll events
    // while the next chunk is in-flight loading over the network.
    if (slot.inboxParts && slot.inboxParts[part.index] !== undefined) {
        return true;
    }

    slot.phase = "inbox";
    slot.inboxTried = true;
    slot.inboxStatus = part.status;
    slot.inboxTotal = part.total;
    slot.inboxParts[part.index] = part.chunk;
    slot.age = 0;

    var have = 0;
    for (var i = 0; i < part.total; i++) {
        if (slot.inboxParts[i] !== undefined) have++;
    }

    if (have < part.total) {
        var nextTarget = -1;
        var next = part.index + 1;
        if (next < part.total && slot.inboxParts[next] === undefined) {
            nextTarget = next;
        } else {
            for (var j = 0; j < part.total; j++) {
                if (slot.inboxParts[j] === undefined) {
                    nextTarget = j;
                    break;
                }
            }
        }
        if (nextTarget >= 0) {
            slot.inboxIndex = nextTarget;
            slot.inboxRequested = nextTarget;
            setPanelUrl(slot, inboxHref(item.requestId, nextTarget));
        }
        return true;
    }

    var fullBody = "";
    for (var k = 0; k < part.total; k++) {
        fullBody += (slot.inboxParts[k] || "");
    }
    finishSlot(slot, part.status, fullBody);
    return true;
}

function retrySlotOnNextBase(slot) {
    var item = slot.item;
    if (!item) return;
    if (bridgeBaseIndex + 1 < BRIDGE_BASES.length) {
        bridgeBaseIndex++;
        slot.age = 0;
        slot.inboxTried = false;
        slot.inboxParts = {};
        slot.phase = "idle";
        startOnSlot(slot, item);
        return;
    }
    finishSlot(slot, 0, "net_panel_error");
}

function finishSlot(slot, status, body) {
    var item = slot.item;
    slot.item = null;
    slot.inboxTried = false;
    slot.inboxParts = {};
    slot.phase = "idle";
    slot.outboxIndex = 0;
    slot.outboxTotal = 0;
    slot.age = 0;
    slot.usedJs = false;

    if (item) {
        sendResultChunks(item.requestId, status, body);
    }
    if (slot.warm) {
        runBridgeJs(slot, "document.title='dota-http-bridge';");
    }
    $.Schedule(0.02, kick);
}

function handlePanelEvent(slot, kind, args) {
    var texts = collectAllTexts(slot, args);
    for (var i = 0; i < texts.length; i++) {
        markSlotWarm(slot, texts[i]);
    }

    if (!slot.item) return;

    for (var j = 0; j < texts.length; j++) {
        var text = texts[j];
        if (text.indexOf("DOTA_HTTP_JS_FAIL") >= 0) {
            slot.warm = false;
            slot.usedJs = false;
            setPanelUrl(slot, execHref(slot.item, slot.item.body, encodedTooLong(slot.item.body)));
            return;
        }
        if (isPanelDead(text)) {
            retrySlotOnNextBase(slot);
            return;
        }
        var ack = parseAck(text);
        if (ack && handleAck(slot, ack)) return;

        var part = parsePart(text);
        if (part && acceptPart(slot, part)) return;

        var parsed = parsePackedFromText(text);
        if (parsed && acceptParsed(slot, parsed)) return;

        var done = parseDone(text);
        if (done && startInbox(slot, done.total, done.status)) return;
        if (wantsInbox(text) && startInbox(slot, 0, 0)) return;
    }
}

function bindPanelEvents(slot) {
    var panel = slot.panel;
    var eventNames = ["HTMLFinishRequest", "HTMLURLChanged", "HTMLTitle"];
    for (var i = 0; i < eventNames.length; i++) {
        (function (name) {
            try {
                $.RegisterEventHandler(name, panel, function () {
                    var argsArray = [];
                    for (var a = 0; a < arguments.length; a++) {
                        argsArray.push(arguments[a]);
                    }
                    handlePanelEvent(slot, name, argsArray);
                });
            } catch (e) {}
        })(eventNames[i]);
    }
}

function pollSlot(slot, token) {
    if (!slot.item || slot.token !== token) return;
    slot.age += 0.08;

    handlePanelEvent(slot, "poll", collectPanelTexts(slot));
    if (!slot.item || slot.token !== token) return;

    if (slot.age > SLOT_TIMEOUT_SEC) {
        retrySlotOnNextBase(slot);
        return;
    }

    $.Schedule(0.08, function () {
        pollSlot(slot, token);
    });
}

function loadOutboxChunk(slot) {
    var item = slot.item;
    if (!item) return;
    var index = slot.outboxIndex;
    var total = slot.outboxTotal;
    var chunk = item.body.substring(index * OUTBOX_CHUNK, (index + 1) * OUTBOX_CHUNK);
    setPanelUrl(slot, outboxHref(item, index, total, chunk));
}

function startOnSlot(slot, item) {
    if (!slot.panel || typeof slot.panel.SetURL !== "function") {
        sendResultChunks(item.requestId, 0, "no_html_panel");
        $.Schedule(0.02, kick);
        return;
    }

    slot.item = item;
    slot.age = 0;
    slot.inboxTried = false;
    slot.inboxParts = {};
    slot.outboxIndex = 0;
    slot.outboxTotal = 0;
    slot.usedJs = false;
    slot.token += 1;

    if (encodedTooLong(item.body)) {
        slot.phase = "outbox";
        slot.warm = false;
        slot.outboxTotal = Math.max(1, Math.ceil(item.body.length / OUTBOX_CHUNK));
        loadOutboxChunk(slot);
        $.Schedule(0.08, function () { pollSlot(slot, slot.token); });
        return;
    }

    slot.phase = "exec";
    if (execViaWarmJs(slot, item)) {
        $.Schedule(0.08, function () { pollSlot(slot, slot.token); });
        return;
    }

    slot.warm = false;
    var dest = execHref(item, item.body, false);
    setPanelUrl(slot, dest);
    $.Schedule(0.08, function () { pollSlot(slot, slot.token); });
}

function kick() {
    for (var i = 0; i < slots.length; i++) {
        var slot = slots[i];
        if (slot.item || queue.length === 0) continue;
        var item = queue.shift();
        if (!item) return;
        startOnSlot(slot, item);
    }
}

function enqueueAssembled(meta, body) {
    var requestId = Math.floor(Number(meta.request_id) || 0);
    var url = String(meta.url || "");
    if (requestId <= 0 || url.length === 0) return;

    sendAck(requestId);
    if (!claimRequest(requestId)) return;

    var headers = {};
    try {
        if (meta.headers_json) {
            headers = JSON.parse(String(meta.headers_json)) || {};
        }
    } catch (e) {
        headers = {};
    }

    var item = {
        requestId: requestId,
        method: String(meta.method || "GET").toUpperCase(),
        url: url,
        body: body || "",
        headers: headers
    };

    queue.push(item);
    kick();
}

function onRelayEvent(ev) {
    var requestId = Math.floor(Number(ev.request_id) || 0);
    if (requestId <= 0) return;

    var chunkTotal = Math.max(1, Math.floor(Number(ev.chunk_total) || 1));
    var chunkIndex = Math.max(0, Math.floor(Number(ev.chunk_index) || 0));
    var piece = String(ev.chunk !== undefined && ev.chunk !== null ? ev.chunk : (ev.body || ""));

    if (chunkTotal <= 1) {
        enqueueAssembled(ev, piece);
        return;
    }

    var row = incoming[requestId];
    if (!row) {
        row = { parts: {}, total: chunkTotal, meta: ev };
        incoming[requestId] = row;
    }
    if (ev.method || ev.url || ev.headers_json) {
        row.meta = ev;
    }
    row.parts[chunkIndex] = piece;

    var have = 0;
    for (var i = 0; i < row.total; i++) {
        if (row.parts[i] !== undefined) have++;
    }

    if (have < row.total) return;

    var fullBody = "";
    for (var j = 0; j < row.total; j++) {
        fullBody += (row.parts[j] || "");
    }
    delete incoming[requestId];
    enqueueAssembled(row.meta, fullBody);
}

function ensureSlots() {
    if (slots.length > 0) return;
    var root = $.GetContextPanel();
    if (!root) return;

    var host = root.FindChildTraverse("ApiHttpBridgeHost") || root;

    for (var i = 0; i < SLOT_COUNT; i++) {
        var panel = root.FindChildTraverse("ApiHttpBridgeHtml" + i);
        if (!panel) {
            panel = $.CreatePanel("DOTAHTMLPanel", host, "ApiHttpBridgeHtml" + i);
        }
        if (!panel) continue;

        panel.style.width = "48px";
        panel.style.height = "48px";
        panel.style.opacity = "0.04";

        var slot = {
            index: i,
            panel: panel,
            item: null,
            token: 0,
            age: 0,
            inboxTried: false,
            inboxParts: {},
            outboxIndex: 0,
            outboxTotal: 0,
            phase: "idle",
            warm: false,
            usedJs: false
        };

        bindPanelEvents(slot);
        slots.push(slot);
    }
}

function sendHello(remaining) {
    GameEvents.SendCustomGameEventToServer("api_http_relay_hello", {
        PlayerID: Players.GetLocalPlayer()
    });
    if (remaining > 0) {
        $.Schedule(1.2, function () { sendHello(remaining - 1); });
    }
}

function preloadBridge() {
    ensureSlots();
    var href = bridgeUrl() + "?warm=1";
    for (var i = 0; i < slots.length; i++) {
        setPanelUrl(slots[i], href);
    }
}

function bootWork() {
    var cfg = GameUI.CustomUIConfig();
    if (cfg._apiHtmlWorkActivePanel && panelIsValid(cfg._apiHtmlWorkActivePanel)) {
        if (cfg._apiHtmlWorkActivePanel !== $.GetContextPanel()) {
            return;
        }
    }
    cfg._apiHtmlWorkActivePanel = $.GetContextPanel();

    ensureSlots();

    if (!cfg._apiHtmlSubscribed) {
        cfg._apiHtmlSubscribed = true;
        GameEvents.Subscribe("api_http_relay", function (ev) {
            if (!takeOwner()) return;
            try {
                onRelayEvent(ev || {});
            } catch (err) {}
        });
    }

    preloadBridge();
    sendHello(25);
}

function watchOwner(left) {
    if (takeOwner()) {
        bootWork();
        return;
    }
    if (left <= 0) return;
    $.Schedule(1.0, function () { watchOwner(left - 1); });
}

function boot() {
    var ctx = $.GetContextPanel();
    if (!ctx) {
        $.Schedule(0.2, boot);
        return;
    }
    if (ctx._apiHtmlBridgeBooted) return;
    ctx._apiHtmlBridgeBooted = true;

    if (!takeOwner()) {
        watchOwner(60);
        return;
    }
    bootWork();
}

boot();
