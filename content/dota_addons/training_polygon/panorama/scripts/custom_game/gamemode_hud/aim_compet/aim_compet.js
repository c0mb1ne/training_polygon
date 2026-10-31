$.Msg('aim_compet gameplay hud loaded')
function stopTraining(){
    GameEvents.SendCustomGameEventToServer("aim_compet_training_end", {});
}
function retryTraining(){
    GameEvents.SendCustomGameEventToServer("aim_compet_training_retry", {});
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
    $("#combo").text = "x" + data.maxCombo;
    $("#hits").text = data.hits;
    $("#misses").text = data.misses;
    $("#hitRate").text = data.hitRate + "%";
    $("#avgTime").text = Number(data.avgTime).toFixed(3) + "s";
    $("#timeLeft").text = formatTime(data.timeLeft);
}
var countdownToken = 0;

var countdownToken = 0;

// one entry per step: what to show and which sound to play
// empty text = no number (GO)
var COUNTDOWN_STEPS = [
    { text: "3", sound: "countdown3" },
    { text: "2", sound: "countdown2" },
    { text: "1", sound: "countdown1" },
    { text: "",  sound: "countdownGo" }
];
var COUNTDOWN_STEP_DURATION = 1.0; // seconds between steps

function playCountdownStep(step, token) {
    if (token !== countdownToken) return;

    var label = $("#countdownLabel");
    label.RemoveClass("countdown_center");
    label.RemoveClass("countdown_exit");
    label.text = step.text;
    Game.EmitSound(step.sound);

    // GO: sound only, nothing to animate
    if (step.text === "") return;

    // next frame: slide to the center
    $.Schedule(0.03, function () {
        if (token !== countdownToken) return;
        label.AddClass("countdown_center");
    });
    // hold in the center, then slide out to the right
    $.Schedule(0.65, function () {
        if (token !== countdownToken) return;
        label.RemoveClass("countdown_center");
        label.AddClass("countdown_exit");
    });
}

function startCountdown(data) {
    countdownToken++;
    var token = countdownToken;
    var label = $("#countdownLabel");
    label.RemoveClass("countdown_center");
    label.RemoveClass("countdown_exit");
    label.text = "";

    COUNTDOWN_STEPS.forEach(function (step, i) {
        $.Schedule(i * COUNTDOWN_STEP_DURATION, function () {
            playCountdownStep(step, token);
        });
    });

    // tell the server the round can start right when GO plays
    $.Schedule((COUNTDOWN_STEPS.length - 1) * COUNTDOWN_STEP_DURATION, function () {
        if (token !== countdownToken) return;
        GameEvents.SendCustomGameEventToServer("aim_compet_countdown_finished", {});
    });
}

function cancelCountdown() {
    countdownToken++; // invalidates all pending schedules
    $("#countdownLabel").text = "";
}

//Game.ScreenXYToWorld( integer nX, integer nY )
function sendMousePos(){
    let mousepos=$.MousePosition()
    let worldPos=Game.ScreenXYToWorld(mousepos.x,mousepos.y)
    GameEvents.SendCustomGameEventToServer("aim_compet_show_miss", {position:worldPos})
    /* $.Msg("mousepos:",Game.ScreenXYToWorld(mousepos.x,mousepos.y)) */
}
GameEvents.Subscribe("aim_compet_where_mouse", sendMousePos);
GameEvents.Subscribe("aim_compet_countdown_start", startCountdown);
GameEvents.Subscribe("aim_compet_refresh_counters", refreshCounters);
