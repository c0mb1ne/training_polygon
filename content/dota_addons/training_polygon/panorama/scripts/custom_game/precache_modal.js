// Precache Modal - shows loading progress when starting a gamemode

var overlay = $.GetContextPanel();
var titleLabel = $('#precache_title');
var itemLabel = $('#precache_item');
var progressBar = $('#precache_progress_bar');
var counterLabel = $('#precache_counter');

var totalItems = 0;
var currentItem = 0;

function showModal() {
    $.Msg('[PrecacheModal] Showing modal');
    overlay.AddClass('visible');
}

function hideModal() {
    $.Msg('[PrecacheModal] Hiding modal');
    overlay.RemoveClass('visible');
}

function resetModal() {
    totalItems = 0;
    currentItem = 0;
    progressBar.style.width = '0%';
    counterLabel.text = '0/0';
    itemLabel.text = '';
    titleLabel.text = 'Loading...';
}

function onPrecacheStart(data) {
    $.Msg('[PrecacheModal] Precache started, total: ' + data.total);
    resetModal();
    totalItems = data.total;
    counterLabel.text = '0/' + totalItems;
    showModal();
}

function onPrecacheProgress(data) {
    currentItem = data.current || (currentItem + 1);
    totalItems = data.total || totalItems;

    var itemName = data.item || data.hero || '';

    // Clean up the item name for display
    var displayName = itemName.replace('npc_dota_hero_', '').replace('npc_dota_', '').replace(/_/g, ' ');

    $.Msg('[PrecacheModal] Progress: ' + currentItem + '/' + totalItems + ' - ' + displayName);

    // Update UI
    itemLabel.text = displayName;
    counterLabel.text = currentItem + '/' + totalItems;

    // Update progress bar
    var percent = totalItems > 0 ? (currentItem / totalItems) * 100 : 0;
    progressBar.style.width = percent + '%';
}

function onPrecacheComplete(data) {
    $.Msg('[PrecacheModal] Precache complete');

    // Show completion briefly
    titleLabel.text = 'Ready!';
    itemLabel.text = '';
    progressBar.style.width = '100%';

    // Hide after a short delay
    $.Schedule(0.5, function() {
        hideModal();
        resetModal();
    });
}

// Subscribe to events
GameEvents.Subscribe('precache_start', onPrecacheStart);
GameEvents.Subscribe('precache_progress', onPrecacheProgress);
GameEvents.Subscribe('precache_complete', onPrecacheComplete);

$.Msg('[PrecacheModal] Initialized');
