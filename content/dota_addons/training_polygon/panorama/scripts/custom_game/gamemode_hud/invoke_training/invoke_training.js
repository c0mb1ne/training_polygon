$.Msg('invoke_training gameplay hud loaded');

function stopTraining() {
    GameEvents.SendCustomGameEventToServer('invoke_training_training_end', {});
}

function retryTraining() {
    GameEvents.SendCustomGameEventToServer('invoke_training_training_retry', {});
}

function hideInvokeStats() {
    $('#invokePerformanceHud').style.visibility = 'collapse';
    $('#invokeShowStats').style.visibility = 'visible';
}

function showInvokeStats() {
    $('#invokePerformanceHud').style.visibility = 'visible';
    $('#invokeShowStats').style.visibility = 'collapse';
}

function invokeToArray(table) {
    var result = [];
    if (table === null || table === undefined) return result;
    if (Array.isArray(table)) return table;
    var keys = [];
    for (var key in table) {
        var numericKey = Number(key);
        if (!isNaN(numericKey)) keys.push(numericKey);
    }
    keys.sort(function(a, b) { return a - b; });
    keys.forEach(function(key) { result.push(table[key]); });
    return result;
}

function invokeFormatTime(seconds) {
    seconds = Math.max(0, Math.floor(Number(seconds) || 0));
    var minutes = Math.floor(seconds / 60);
    var remainder = seconds % 60;
    return (minutes < 10 ? '0' : '') + minutes + ':' + (remainder < 10 ? '0' : '') + remainder;
}

function updateInvokeQueue(data) {
    var targets = invokeToArray(data.targets);
    $('#invokeQueuePanel').style.width = Math.max(1, targets.length) * 74 + 'px';

    var container = $('#invokeTargetQueue');
    container.RemoveAndDeleteChildren();
    targets.forEach(function(targetData) {
        var column = $.CreatePanel('Panel', container, '');
        column.AddClass('InvokeTargetColumn');
        var queue = $.CreatePanel('Panel', column, '');
        queue.AddClass('InvokeTargetSpells');

        var requests = invokeToArray(targetData.queue);
        // Reverse creation puts the active request directly above the portrait.
        for (var index = requests.length - 1; index >= 0; index--) {
            var spellName = requests[index];
            var slot = $.CreatePanel('Panel', queue, '');
            slot.AddClass('InvokeSpellSlot');
            slot.SetHasClass('InvokeCurrentSpell', index === 0);
            slot.SetHasClass('InvokeFillerSpell', spellName === 'invoker_filler');

            if (spellName === 'invoker_filler') {
                var filler = $.CreatePanel('Label', slot, '');
                filler.text = '-';
            } else {
                var image = $.CreatePanel('DOTAAbilityImage', slot, '');
                image.abilityname = spellName;
            }
        }

        var portrait = $.CreatePanel('DOTAHeroImage', column, '');
        portrait.heroname = targetData.heroName;
        portrait.heroimagestyle = 'landscape';
        portrait.AddClass('InvokeTargetPortrait');
    });
}

function updateInvokeStats(data) {
    $('#invokeSuccessesValue').text = data.successes;
    $('#invokeMistakesValue').text = data.mistakes;
    $('#invokeAccuracyValue').text = Number(data.accuracy || 0).toFixed(1) + '%';
    $('#invokeStreakValue').text = data.streak;
    $('#invokeBestStreakValue').text = data.bestStreak;
    $('#invokeSpmValue').text = Number(data.spellsPerMinute || 0).toFixed(1);
    $('#invokeAvgTimeValue').text = Number(data.avgTime || 0).toFixed(3) + 's';
    $('#invokeOrbsValue').text = Number(data.orbsPerSpell || 0).toFixed(2);
    $('#invokeElapsedValue').text = invokeFormatTime(data.elapsed);
}

GameEvents.Subscribe('invoke_training_queue', updateInvokeQueue);
GameEvents.Subscribe('invoke_training_stats', updateInvokeStats);
GameEvents.SendCustomGameEventToServer('get_invoke_training_state', {});
