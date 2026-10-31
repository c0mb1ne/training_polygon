// ---------------------------------------------------------------------------
// Combo tracker panel
// Lua owns the number, this script owns what is drawn.
// States: 'hidden' -> 'shown' -> 'breaking' -> 'hidden' (-> 'shown' if a combo >= x2 was queued)
// ---------------------------------------------------------------------------

const DEBUG = false;            // shows the +1 / break / move buttons
const MIN_VISIBLE = 2;         // keep in sync with ComboTracker.MIN_VISIBLE in Lua
const SHATTER_TIME = 2.6;      // seconds; a bit longer than the 2.5s transform in .ShatterPiece
const BUMP_IN_TIME = 0.07;     // seconds the "pop" holds before it springs back
const SHARD_COUNT = 48;
const MAX_TIERS = 8;           // keep in sync with ComboTracker.MAX_TIERS in Lua

const anchor = $('#ComboAnchor');
const shardsContainer = $('#ShardsContainer');
const textContainer = $('#ComboTextContainer');
const textLabel = $('#ComboDisplay');
const shade = $('#ComboShade');

let active = true;
let tierThresholds = [5, 10, 20];   // replaced by whatever Lua sends
let state = 'hidden';
let shownValue = 0;
let pendingValue = 0;          // combo reached while shattering, shown after the shatter ends
let token = 0;                 // invalidates scheduled callbacks when the state is forced
let bumpSeq = 0;
let bumpToggle = false;
let breakId = 0;

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

// Thresholds come from Lua (ComboTracker config `tiers` / SetTiers). Tier 1 is the base look,
// each threshold reached adds one tier. The look of tier N is the .ComboTierN rule in the css.
function tierFor(v) {
    let tier = 1;
    for (const threshold of tierThresholds) {
        if (v >= threshold) tier++;
    }
    return tier;
}

function parseTiers(str) {
    if (typeof str !== 'string' || str.length === 0) return [];
    return str.split(',').map(Number).filter(function (n) { return !isNaN(n); })
        .sort(function (a, b) { return a - b; });
}

function applyTier(panel, tier) {
    for (let t = 1; t <= MAX_TIERS; t++) {
        panel.SetHasClass('ComboTier' + t, t === tier);
    }
}

function moveTo(x, y, time) {
    if (x === undefined || y === undefined) return;
    anchor.style['transition-duration'] = (time || 0) + 's';
    anchor.style.position = x + '% ' + y + '% 0px';
}

// ---------------------------------------------------------------------------
// shatter
// ---------------------------------------------------------------------------

function createShatter(index, container, text, tier, id) {
    const piece = $.CreatePanel('Panel', container, 'shard_' + id + '_' + index);
    piece.AddClass('LabelContainer');
    piece.AddClass('ComboTier' + tier);
    const label = $.CreatePanel('Label', piece, 'shard_label_' + id + '_' + index);
    label.AddClass('ComboLabel');
    label.text = text;
    piece.AddClass('piece' + index);
    piece.AddClass('ShatterPiece');
    return piece;
}

function createShatters(container, text, tier) {
    const id = ++breakId;
    const pieces = [];
    for (let i = 1; i <= SHARD_COUNT; i++) {
        pieces.push(createShatter(i, container, text, tier, id));
    }
    return pieces;
}

function clearShards() {
    $.Each(shardsContainer.Children(), function (p) {
        p.DeleteAsync(0);
    });
}

// ---------------------------------------------------------------------------
// show / bump / hide / break
// ---------------------------------------------------------------------------

function showCombo(value) {
    state = 'shown';
    shownValue = value;
    const myToken = ++token;
    shade.AddClass('ComboShadeVisible');

    textLabel.text = 'x' + value;
    applyTier(textContainer, tierFor(value));

    // snap to the hidden pose, then let it spring in
    textContainer.AddClass('ComboInstant');
    textContainer.AddClass('ComboHidden');
    $.Schedule(0.03, function () {
        if (token !== myToken) return;
        textContainer.RemoveClass('ComboInstant');
        textContainer.RemoveClass('ComboHidden');
    });
}

function bumpCombo(value) {
    const tierUp = tierFor(value) > tierFor(shownValue);
    shownValue = value;
    textLabel.text = 'x' + value;
    applyTier(textContainer, tierFor(value));

    bumpToggle = !bumpToggle;
    textContainer.RemoveClass('ComboBumpA');
    textContainer.RemoveClass('ComboBumpB');
    textContainer.RemoveClass('ComboBumpBig');
    textContainer.AddClass(tierUp ? 'ComboBumpBig' : (bumpToggle ? 'ComboBumpA' : 'ComboBumpB'));

    const seq = ++bumpSeq;
    $.Schedule(BUMP_IN_TIME, function () {
        if (seq !== bumpSeq) return;
        textContainer.RemoveClass('ComboBumpA');
        textContainer.RemoveClass('ComboBumpB');
        textContainer.RemoveClass('ComboBumpBig');
    });
}

function hideCombo(instant) {
    token++;
    state = 'hidden';
    shade.RemoveClass('ComboShadeVisible');
    if (instant) textContainer.AddClass('ComboInstant');
    textContainer.AddClass('ComboHidden');
}

function breakCombo(lastValue) {
    if (!active || state === 'breaking') return;
    const value = lastValue || shownValue;
    if (value < MIN_VISIBLE) return;

    state = 'breaking';
    shade.RemoveClass('ComboShadeVisible'); // fades out slowly while the shards fly
    pendingValue = 0;
    const myToken = ++token;

    // swap the solid label for the shards in the same frame
    textContainer.AddClass('ComboInstant');
    textContainer.AddClass('ComboHidden');

    clearShards();
    const pieces = createShatters(shardsContainer, 'x' + value, tierFor(value));

    // let the pieces lay out in their start pose first so the transition runs
    $.Schedule(0.05, function () {
        if (token !== myToken) return;
        for (const piece of pieces) piece.AddClass('Shattered');
    });

    $.Schedule(SHATTER_TIME, function () {
        if (token !== myToken) return;
        clearShards();
        state = 'hidden';
        if (active && pendingValue >= MIN_VISIBLE) {
            const v = pendingValue;
            pendingValue = 0;
            showCombo(v);
        }
    });
}

// ---------------------------------------------------------------------------
// events from Lua
// ---------------------------------------------------------------------------

function onUpdate(data) {
    if (!active) return;
    const value = Math.floor(data.value);

    if (state === 'breaking') {
        // not shown until the shatter ends AND the player is back at >= x2
        pendingValue = value >= MIN_VISIBLE ? value : 0;
        return;
    }

    if (value < MIN_VISIBLE) {
        if (state === 'shown') hideCombo(false);
        return;
    }

    if (state === 'hidden') showCombo(value);
    else if (value !== shownValue) bumpCombo(value);
}

function onBreak(data) {
    breakCombo(Math.floor(data.last));
}

function onMove(data) {
    moveTo(data.x, data.y, data.time);
}

function onTiers(data) {
    tierThresholds = parseTiers(data.tiers);
    // restyle what is on screen right now, no animation
    if (state === 'shown') applyTier(textContainer, tierFor(shownValue));
}

// full sync: construction, Activate/Deactivate, UI reload
function onState(data) {
    active = !!data.active;
    if (data.tiers !== undefined) tierThresholds = parseTiers(data.tiers);
    token++;
    pendingValue = 0;
    clearShards();
    moveTo(data.x, data.y, 0);

    const value = Math.floor(data.value || 0);
    if (!active || value < MIN_VISIBLE) {
        hideCombo(true);
        return;
    }
    showCombo(value);
}

GameEvents.Subscribe('combo_tracker_state', onState);
GameEvents.Subscribe('combo_tracker_update', onUpdate);
GameEvents.Subscribe('combo_tracker_break', onBreak);
GameEvents.Subscribe('combo_tracker_move', onMove);
GameEvents.Subscribe('combo_tracker_tiers', onTiers);

// ---------------------------------------------------------------------------
// debug buttons (local only, no Lua involved)
// ---------------------------------------------------------------------------

let dbgValue = 0;
let dbgAnchorIndex = 0;
const DBG_ANCHORS = [
    [9, 68], [50, 68], [91, 68], [91, 24], [50, 24], [9, 24], [50, 50],
];

function dbgAdd() {
    dbgValue++;
    onUpdate({ value: dbgValue });
}

function dbgBreak() {
    const last = dbgValue;
    dbgValue = 0;
    onBreak({ last: last });
}

function dbgMove() {
    dbgAnchorIndex = (dbgAnchorIndex + 1) % DBG_ANCHORS.length;
    const a = DBG_ANCHORS[dbgAnchorIndex];
    moveTo(a[0], a[1], 0.6);
}

$('#debug').visible = DEBUG;

// start hidden, then ask the server for the current state
hideCombo(true);
GameEvents.SendCustomGameEventToServer('combo_tracker_ready', {});