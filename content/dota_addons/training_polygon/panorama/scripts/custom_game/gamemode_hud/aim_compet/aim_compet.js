$.Msg('aim_compet gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("aim_compet_training_end", {});
}

function formatTime(totalSeconds) {
    totalSeconds = Math.max(0, Math.floor(totalSeconds));
    var m = Math.floor(totalSeconds / 60);
    var s = totalSeconds % 60;

    function pad(n) { return n < 10 ? "0" + n : "" + n; }

    return pad(m) + ":" + pad(s);
}

// data keys: score, combo, maxCombo, hits, misses, hitRate, avgTime, timeLeft (see aim_compet:SendCounters)
function refreshCounters(data) {
    /* $.Msg(JSON.stringify(data)); */
    $("#score").text = data.score;
    $("#combo").text = "x" + data.combo + " (max x" + data.maxCombo + ")";
    $("#hits").text = data.hits;
    $("#misses").text = data.misses;
    $("#hitRate").text = data.hitRate + "%";
    $("#avgTime").text = Number(data.avgTime).toFixed(3) + "s";
    $("#timeLeft").text = formatTime(data.timeLeft);
}

GameEvents.Subscribe("aim_compet_refresh_counters", refreshCounters);
