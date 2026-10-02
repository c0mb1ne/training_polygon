$.Msg('lasthit_training gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("lasthit_training_training_end", {});
}


function formatTime(totalSeconds) {
    totalSeconds = Math.floor(totalSeconds);
    var h = Math.floor(totalSeconds / 3600);
    var m = Math.floor((totalSeconds % 3600) / 60);
    var s = totalSeconds % 60;

    function pad(n) { return n < 10 ? "0" + n : "" + n; }

    return pad(h) + ":" + pad(m) + ":" + pad(s);
}

function refreshCounters(data) {
    $.Msg(JSON.stringify(data));
    for (var key in data) {
        var label = $("#" + key);
        if (!label) continue; // no label with this id, skip

        var value = data[key];

        if (key === "sessionTime") {
            value = formatTime(value);
        }
        if (key === "lasthitToMissPrecent") {
            value = value.toFixed(1) + "%";
        }
        if (key === "avgDelayCounter") {
            value = value.toFixed(3);
        }
        label.text = value;
    }
}
GameEvents.Subscribe("lasthit_refresh_counters", refreshCounters);