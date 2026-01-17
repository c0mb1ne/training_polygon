

var VERSION="beta_0.2"
var DEFAULT_DURATION = "300.0ms";
var DEFAULT_EASE = "linear";
var publish_url = "http://combine.pro.host1530666.serv66.hostland.pro/training.php";
var dev_url = 'http://training/training.php';
/* AnimatePanel
 * Animates a panel
 * 
 * Params:
 * 		panel 		- Panel to animate
 *		values 		- Dictionary containing the properties and values to animate.
 *					  Example: { "transform": "translateX(100);", "opacity": "0.5" }
 *		duration 	- The animation duration in seconds
 *		ease 		- Easing function to use. Example: "linear" or "ease-in"
 *		delay		- Time to wait before starting the animation in seconds
 */
function AnimatePanel(panel, values, duration, ease, delay) {
	// generate transition string
	var durationString = (duration != null ? parseInt(duration * 1000) + ".0ms" : DEFAULT_DURATION);
	var easeString = (ease != null ? ease : DEFAULT_EASE);
	var delayString = (delay != null ? parseInt(delay * 1000) + ".0ms" : "0.0ms"); 
	var transitionString = durationString + " " + easeString + " " + delayString;

	var i = 0;
	var finalTransition = ""
	for (var property in values) {
		// add property to transition
		finalTransition = finalTransition + (i > 0 ? ", " : "") + property + " " + transitionString;
		i++;
	}

	// apply transition
	panel.style.transition = finalTransition + ";";

	// apply values
	for (var property in values)
		panel.style[property] = values[property];
}


var castpoint = 0.95;
var manta = 0.1;
var screenW = Game.GetScreenWidth();
var barW = Math.floor(screenW*0.8*0.6);
var TimeBar = $("#TimeBar")
var TimingBar = $("#Timing")
TimeBar.style.width = barW + "px";

var cursorPos = barW / 2 - 29;
$("#cursor").style.marginLeft = cursorPos + "px";
var barTime = 3.0;
var castbarW = barW / barTime * castpoint;
var mantaBarW = barW / barTime * manta;
var spellIconW = 65;
var mainBarW = Math.floor(screenW * 0.8);
var spellIconEnd = (mainBarW-barW) / 2 - spellIconW;
var spellIconStart = (mainBarW - barW) / 2 + barW + spellIconW;
var spellIcon = $("#myability");
changeSpellIcon("monkey_king_boundless_strike")
//spellIcon.style.marginLeft = spellIconStart + "px";
var pixelTime = barW / barTime;
var spellDelay = pixelTime * spellIconW;
var showBar = true;
hideNotify();
$("#testskill").style['visibility']='visible'
rootpanel = $("#btnTest").GetParent()
rootpanel.style['visibility'] = 'collapse';
rootpanel.style['opacity'] = '0';
$("#btnRetry").style['visibility']='collapse'
//aim bot
$("#morphTimer").style['visibility']='collapse'
$('#morphHelperText').style['visibility']='collapse'
$('#morphSpellContainer').style['visibility']='collapse'

function LHTrainingStarted(data){
	//aimBot()
	var type=data.type
	
	ShowUI();
	$("#morphTimer").style['visibility']='collapse'
	$('#morphHelperText').style['visibility']='collapse'
	$('#Timing').style['visibility']='collapse'
	$("#avgTime").style['visibility']='visible'
	$("#livesLeft").style['visibility']='visible'
	$("#aimCombo").style['visibility']='collapse'
	$("#btnRetry").style['visibility']='collapse'
	$("#btnTest").SetPanelEvent("onactivate", endLHTraining)
	$('#textTest').text='Average delay: '
	$('#avgTime').text='Killed: '
	$('#livesLeft').text='Missed: '
	/*$.Schedule(4, function() {
		$("#btnRetry").style['visibility']='visible'
	});*/
	/*showCountdownNumber()*/
	barChangeVisibleState(0)
}

//aim training functions
function aimTrainingStarted(data){
	//aimBot()
	var type=data.type
	if (type=='aim'){
		$("#btnRetry").SetPanelEvent("onactivate", retryAimTraining)
		$("#btnTest").SetPanelEvent("onactivate", endAimTraining)
	}
	if (type=='aim2'){
		$("#btnRetry").SetPanelEvent("onactivate", retryAimTraining2)
		$("#btnTest").SetPanelEvent("onactivate", endAimTraining2)
	}
	if (type=='aim3'){
		$("#btnRetry").SetPanelEvent("onactivate", retryAimTraining3)
		$("#btnTest").SetPanelEvent("onactivate", endAimTraining3)
	}
	if (type=='map_aim'){
		$("#btnRetry").SetPanelEvent("onactivate", retryMapAimTraining)
		$("#btnTest").SetPanelEvent("onactivate", endMapAimTraining)
	}
	if (type=='move_aim'){
		$("#btnRetry").SetPanelEvent("onactivate", retryMoveAimTraining)
		$("#btnTest").SetPanelEvent("onactivate", endMapAimTraining)
	}
	ShowUI();
	$("#morphTimer").style['visibility']='collapse'
	$('#morphHelperText').style['visibility']='collapse'
	$('#Timing').style['visibility']='collapse'
	$("#avgTime").style['visibility']='visible'
	$("#livesLeft").style['visibility']='visible'
	$("#aimCombo").style['visibility']='visible'
	$("#btnRetry").style['visibility']='collapse'
	
	
	$.Schedule(4, function() {
		$("#btnRetry").style['visibility']='visible'
	});
	showCountdownNumber()
	barChangeVisibleState(0)
}


function mantaChallengeStarted(data){
	ShowUI();
	$("#morphTimer").style['visibility']='collapse'
	$('#morphHelperText').style['visibility']='collapse'
	$('#Timing').style['visibility']='collapse'
	$("#avgTime").style['visibility']='collapse'
	$("#livesLeft").style['visibility']='collapse'
	$("#aimCombo").style['visibility']='visible'
	$("#btnTest").SetPanelEvent("onactivate", endAimTraining)
	showCountdownNumber()
	barChangeVisibleState(0)
}
function updateTimer(data){
	if (data.time==40){
		$('#livesLeft').AddClass('wardTimer')
	}
	if (data.time==0){
		$('#livesLeft').RemoveClass('wardTimer')
	}
	$('#livesLeft').text="Time: "+data.time
}

var click_count=0
function clickResult(data){
	var pos=false
	$('#textTest').text="Score: "+data.totalscore
	if (data.avg){
		$('#avgTime').text="Avg. time: "+data.avg.toFixed(3)
	}
	$('#aimCombo').text=data.combo+"x"
	if (data.badx){
		pos=[Game.WorldToScreenX( data.badx,data.bady, 128 ),Game.WorldToScreenY( data.badx,data.bady, 128 )]
	}
	createClickPanel(click_count,data.time,data.score,pos)
	click_count=click_count+1
}
function showCountdownNumber(){
	var parentPanel=$("#btnTest").GetParent()
	var countdown=$.CreatePanel('Label',parentPanel,'countdown')
	$.Schedule(1, function() {
		countdown.text="3"
		countdown.AddClass('timerAnimate')
		countdown.AddClass('countdown')
		Game.EmitSound("drums")
	});
	$.Schedule(2, function() {
		countdown.text="2"
	});
	$.Schedule(3, function() {
		countdown.text="1"
		countdown.DeleteAsync(1)
	});

}
function createClickPanel(id,time,score,pos){
	var parentPanel=$("#btnTest").GetParent()
	var clickResultPanel=$.CreatePanel('Panel', parentPanel, 'clickPanel_'+id)
	clickResultPanel.AddClass("clickPanel")
	clickResultPanel.AddClass("clickGood")
	var cursorPosition
	if (pos==false){
		cursorPosition = GameUI.GetCursorPosition();
	}else{
		cursorPosition=pos
	}
	clickResultPanel.style["margin-left"] = cursorPosition[0] + 'px'
	clickResultPanel.style["margin-top"] = cursorPosition[1] + 'px'
	var scoreLabel=$.CreatePanel('Label',clickResultPanel,'score_label_'+id)
	var timeLabel=$.CreatePanel('Label',clickResultPanel,'time_label_'+id)
	if (time==0 && score=='Bad!'){
		scoreLabel.text='Miss!'
		scoreLabel.AddClass("clickInfoBad")
	}else{
		scoreLabel.text='S: '+score
		timeLabel.text='T: '+time.toFixed(3)
		scoreLabel.AddClass("clickInfo")
		timeLabel.AddClass("clickInfo")
	}
	
	AnimatePanel(clickResultPanel,{ "opacity": "0;" }, 1, "ease-in")
	clickResultPanel.DeleteAsync(1)
}

//aim end
function changeSpellIcon(spell) {
	var panel=$("#myability");
	panel.abilityname = spell;
}

function iconAnimation2(spell, time) {
	var panel=$("#myability");
	var distance=(barW + spellIconW);
	changeSpellIcon(spell)
	panel.style.marginLeft = distance + "px";
	AnimatePanel(panel, {"opacity": "1;"}, 1, "ease-in")
	AnimatePanel (
		panel,
		{
			"transform": "translateX(-" + distance + "px);"
		},
		time,
		"cubic-bezier(0,1,1,0)"
	);
	$.Schedule(time - 1, function() {
		AnimatePanel(panel, {"opacity": "0;"}, 1);
	});
	$.Schedule(time, function() {
		AnimatePanel(panel, {"transform": "translateX(0px);"}, 0.1);
	});
}

function HideUI() {
	$("#morphTimer").style['visibility']='collapse'
	$('#morphHelperText').style['visibility']='collapse'
	$('#morphSpellContainer').style['visibility']='collapse'
	var rootpanel=$("#btnTest").GetParent()
	AnimatePanel(rootpanel,{ "opacity": "0;" }, 0.5, "ease-in")
	$.Schedule(0.5, function(){rootpanel.style['visibility']='collapse';})
}

function ShowUI() {
	var rootpanel = $("#btnTest").GetParent()
	rootpanel.style['visibility'] = 'visible'
	$.Schedule(0.5, function() {
		AnimatePanel(rootpanel, {"opacity": "1;"}, 0.5, "ease-in");
	})
}

function onBtnTestClick(event) {
	var player = Game.GetLocalPlayerID()
	$.Msg(player)
	var hero = Players.GetPlayerHeroEntityIndex(player);
	panel = $("#btnTest")
	AnimatePanel(panel, {"opacity": "0;"}, 0.5, "ease-in")
	$.Schedule(0.5, function() {
		panel.visible=false;
		panel.enabled=false;
	})
	GameEvents.SendCustomGameEventToServer (
		"simple_game_start",
		{
			"player": player,
			"key2" : "value2"
		}
	);
}

function onBtnTestClick2(event) {
	iconAnimation2("queenofpain_scream_of_pain", barTime)
}

function onBtnTestClick3(event) {
	//Game.EmitSound("good1")
	 Good()
}

function endCustomTraining(event) {
	GameEvents.SendCustomGameEventToServer("custom_manta_training_end", {});
	HideUI()
}
function endAimTraining(event) {
	$("#btnRetry").style['visibility']='collapse'
	GameEvents.SendCustomGameEventToServer("aim_end", {});
	HideUI()
}
function endAimTraining2(event) {
	$("#btnRetry").style['visibility']='collapse'
	GameEvents.SendCustomGameEventToServer("aim_end", {});
	HideUI()
}
function endAimTraining3(event) {
	$("#btnRetry").style['visibility']='collapse'
	GameEvents.SendCustomGameEventToServer("aim_end", {});
	HideUI()
}
function endLHTraining(event) {
/*	$("#btnRetry").style['visibility']='collapse'*/
	GameEvents.SendCustomGameEventToServer("lasthit_end", {});
	HideUI()
}
function endMapAimTraining(event) {
	$("#btnRetry").style['visibility']='collapse'
	GameEvents.SendCustomGameEventToServer("map_aim_end", {});
	HideUI()
}
function retryAimTraining(event) {
	var player=Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer("aim_start",{"player": player, "retry" : 1})

}
function retryAimTraining2(event) {
	var player=Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer("aim_start2",{"player": player, "retry" : 1})

}
function retryAimTraining3(event) {
	var player=Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer("aim_start3",{"player": player, "retry" : 1})

}
function retryMapAimTraining(event) {
	var player=Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer("map_aim_start",{"player": player, "retry" : 1})

}
function retryMoveAimTraining(event) {
	var player=Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer("moving_aim_training_start",{"player": player, "retry" : 1})

}
function retryMorphTraining(event){
	var player=Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer("morph_training_start",{"player": player, "retry" : 1})
}
function getRandomInt(min, max) {
	return Math.floor(Math.random() * (max - min)) + min;
}

function voiceAnnounce(result) {
	if(result === 1)
		Game.EmitSound("good" + getRandomInt(1,5))
	else
		Game.EmitSound("bad" + getRandomInt(1,12))
}

function showNotify() {
	$("#mantaNotify").RemoveClass("FadeOut");
	$("#mantaNotify").AddClass("FadeIn");
}

function hideNotify() {
	$("#mantaNotify").RemoveClass("FadeIn");
	$("#mantaNotify").AddClass("FadeOut");
}

function updateStreak(streak) {
	$("#textTest").text = $.Localize("#InARow") + streak;
}

function updateTopScore(info) {
	streak = info.score
	//$("#bestScore").text="Best score: "+streak.toString();
}
function updateMantaScore(info) {
	score = info.score
	combo=info.combo
	$("#textTest").text="Score: "+score.toString();
	$("#aimCombo").text=combo.toString()+"x";
}
function evasionControl(info) {
	var success = info.how
	var streak = info.dodgestreak
	var skill = info.skillId
	var lives = info.lives
	var time = info.time
	var result = 0
	updateStreak(streak)
	if(success === "good") {
		Good();
		result=1
	} else {
		/*
		if (lives === 0)
			Lost();
		else {
		*/
			if (time)
				Bad(time);
			else
				Bad();
		//}
	}
	
	//addSkillData(skill,result)
}

function Good(){
	$("#notify").text = $.Localize("#mantaGood");
	$("#notify").style.color = "#02ff06";
	$("#desc").text = ""
	showNotify();
	//voiceAnnounce(1)
	$.Schedule(1, hideNotify);
}

function Bad(time) {
	$("#notify").text = $.Localize("#mantaBad");
	if (time)
		$("#desc").text = time.toFixed(3) + " s"
	else
		$("#desc").text = ""
	$("#notify").style.color="#ff0202";
	showNotify();
	//voiceAnnounce(0)
	$.Schedule(1, hideNotify);
}

function Lost() {
	$("#notify").text = "You lost";
	$("#notify").style.color = "#ff0202";
	showNotify();
	$.Schedule(4, hideNotify);
}

function spellCasted(castpoint) {
	var mantaBar = $("#manta");
	var spell = $("#spellBar");
	var castbarW = barW / barTime * castpoint;
	//$.Msg("***********animation starts*************");

	var epsilon = 0.05

	startBarAnimation(spell, castpoint);
	$.Schedule(castpoint - manta + epsilon, function() {
		startBarAnimation(mantaBar, manta);
	});
}


function startBarAnimation(panel, time) {	
	if (time >= barTime){
		var panelW = barW;
		animateOnTimeAppear(panel, barW, panelW, 60, barTime);
		$.Schedule(time, function() {
			animeOnTimeDisappear(panel, barW, panelW, 60, barTime);
		});
	} else {
		var panelW = barW / barTime * time;
		animateOnTimeAppear(panel,barW,panelW,60,time);
		$.Schedule(time, function() {
			animeOnTimeMove(panel, barW, panelW, 60, barTime - time);
		});
		$.Schedule(barTime, function() {
			animeOnTimeDisappear(panel, barW, panelW, 60, time);
		});	
	}
}

function scheduleCast(table) {
	delay = table.delay;
	castpoint = table.castpoint;
	spell = table.abil
	if (showBar)
		$.Schedule(delay - barTime / 2, function() {
			spellCasted(castpoint)
		});
	$.Schedule(delay - barTime / 2, function() {
		iconAnimation2(spell,barTime)
	});
}

function animateOnTimeAppear(panel, barW, castbarW, fps, duration){
	var startTime = Date.now();
	var endTime = duration * 1000 + startTime;
	var interval = 1/fps;
	var start = 0;
	var inc = 0;
	var timeNow = 0;
	var razn = startTime - endTime;
	var razn2 = 0;
	animate();
	function animate() {
		timeNow = Date.now();
		//$.Msg("starttime+timenow:")
		//$.Msg(startTime+timeNow)
		if (timeNow <= endTime){
			razn2 = startTime - timeNow;
			inc = castbarW / (razn / razn2);
			draw(inc);
			$.Schedule(interval, animate)
		} else {
			var end2 = Date.now();
			//$.Msg(panel.id.toString()+" app end in:");
			//$.Msg(end2-startTime);
		}
	}
	function draw(inc) {
		panel.style["margin-left"] = (barW-inc) + "px";
		panel.style["width"] = inc + "px";
	}
}

function animeOnTimeMove(panel, barW, castbarW, fps, duration){
	var startTime = Date.now();
	var endTime  = duration * 1000 + startTime;
	var interval = 1 / fps;
	var start = barW - castbarW;
	var inc = 0;
	var timeNow = 0;
	var razn = startTime - endTime;
	var razn2 = 0;
	animate();
	function animate() {
		timeNow = Date.now();
		//$.Msg("starttime+timenow:")
		//$.Msg(startTime+timeNow)
		if (timeNow <= endTime){
			razn2 = startTime - timeNow;
			inc = (start) / (razn / razn2);
			draw(inc);
			$.Schedule(interval, animate)
		} else {
			draw(start);
			var end2=Date.now();
			//$.Msg(panel.id.toString()+" move end in:");
			//$.Msg(end2-startTime);
			//$.Msg("start:");
			//$.Msg(start);
			//$.Msg("last inc:");
			//$.Msg(inc);
		}
	}
	function draw(inc) {
		panel.style["margin-left"] = (start-inc) + "px";
		if(start - inc <= cursorPos && start - inc + castbarW >= cursorPos){
			
		} else {
			
		}
		//panel.style["width"]=inc.toString()+"px";
	}
}
function animeOnTimeDisappear(panel, barW, castbarW, fps, duration){
	var startTime = Date.now();
	var endTime = duration * 1000 + startTime;
	var interval = 1 / fps;
	var start = 0;
	var inc = 0;
	var timeNow = 0;
	var razn = startTime - endTime;
	var razn2 = 0;
	animate();
	function animate() {
		timeNow = Date.now();
		//$.Msg("starttime+timenow:")
		//$.Msg(startTime+timeNow)
		if (timeNow <= endTime){
			razn2 = startTime - timeNow;
			inc = castbarW / (razn / razn2);
			draw(inc);
			$.Schedule(interval, animate)
		} else {
			draw(castbarW);
			var end2 = Date.now();
			//$.Msg(panel.id.toString()+" disapp end in:");
			//$.Msg(end2-startTime);
		}
	}
	function draw(inc) {
		//panel.style["margin-left"] = (barW - inc) + "px";
		panel.style["width"] = (castbarW - inc) + "px";
	}
}
function barChangeVisibleState(state) {
	var panel = $("#Timing");
	if(!state) {
		AnimatePanel(panel, {"opacity": "0;"}, 0.5, "ease-in")
		$.Schedule(0.5, function() {
			panel.visible=false;
			panel.enabled=false;
		})
	} else {
		panel.visible = true
		panel.enabled = true
		AnimatePanel(panel, {"opacity": "1;"}, 0.5, "ease-in")
	}
}




/*function addSkillData(skill,result){
	skills_arr.push(skill)
	result_arr.push(result)
	timebar_arr.push(showBar)
}*/
/*function endEvasionGame(info){
	Lost();
	score=info.score
	sendEvadeResult(score)
	panel=$("#btnTest")
	panel.visible=true
	panel.enabled=true
	AnimatePanel(panel,{ "opacity": "1;" }, 0.5, "ease-in")
}*/


/*function sendEvadeResult(score){
	var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID())
	var steamID64 = playerInfo.player_steamid
	var info={
		skill_name: skills_arr,
		result: result_arr,
		steam: steamID64.toString(),
		version: VERSION,
		timebar: timebar_arr,
		score: score,
		lang: $.Language()
	};

	$.AsyncWebRequest(publish_url,
        {
            type: 'POST',
            data: {info: JSON.stringify(info)},
            success: function (data) {
                $.Msg('cmb Reply: ', data)
            }
        });
}*/
function updateLives(info) {
	lives = info.lives
	$("#livesLeft").text = "Lives left: " + lives;
}

function trainingStart(info) {
	$("#btnTest").SetPanelEvent("onactivate", endCustomTraining)
	barChangeVisibleState(info.timebar === 1)
	ShowUI();
	$("#avgTime").style['visibility']='collapse'
	$("#livesLeft").style['visibility']='collapse'
	$("#aimCombo").style['visibility']='collapse'
	if (info.blink == 1){
		$("#testskill").style['visibility']='collapse'
	}

}


function lasthitDispay(data){
	$('#textTest').text='Average delay: '+data.avg.toFixed(3)
	$('#avgTime').text='Killed: '+data.killed
	$('#livesLeft').text='Missed: '+data.missed
}

function morphTrainingStarted(data){
	//aimBot()
	var type=data.type
/*	if (type=='aim'){
		$("#btnRetry").SetPanelEvent("onactivate", retryAimTraining)
		$("#btnTest").SetPanelEvent("onactivate", endAimTraining)
	}
	if (type=='map_aim'){
		$("#btnRetry").SetPanelEvent("onactivate", retryMapAimTraining)
		$("#btnTest").SetPanelEvent("onactivate", endMapAimTraining)
	}
	if (type=='move_aim'){
		$("#btnRetry").SetPanelEvent("onactivate", retryMapAimTraining)
		$("#btnTest").SetPanelEvent("onactivate", endMapAimTraining)
	}*/
	$("#btnRetry").SetPanelEvent("onactivate", retryMorphTraining)
	$("#btnTest").SetPanelEvent("onactivate", endMorphTraining)

	ShowUI();
	$('#Timing').style['visibility']='collapse'
	$("#avgTime").style['visibility']='collapse'
	$("#livesLeft").style['visibility']='collapse'
	$("#aimCombo").style['visibility']='collapse'
	$("#btnRetry").style['visibility']='collapse'
	$("#morphTimer").style['visibility']='collapse'
	$('#morphHelperText').text="Use morph on enemy and cast all spells as fast as you can."
	$.Schedule(4, function() {
		$('#morphSpellContainer').style['visibility']='visible'
		$("#btnRetry").style['visibility']='visible'
		$("#morphTimer").style['visibility']='visible'
		$("#morphTimer").text="0.000"
		$('#morphHelperText').text="Cast theese skills:"
		$('#morphHelperText').style['visibility']='visible'
		startMorphTimer()
	});
	showCountdownNumber()
	barChangeVisibleState(0)
}
function endMorphTraining(event) {
	$("#btnRetry").style['visibility']='collapse'
	GameEvents.SendCustomGameEventToServer("morph_training_end", {});
	HideUI()
}
//mantaChallengeStarted
function morphUpdate(data){
	var displayData=data.skills
	var redraw=data.redraw
	var skillContainer=$('#morphSpellContainer')

		//delete children and draw new
		$.Each(skillContainer.Children(), function( oPanel )
		{
			oPanel.DeleteAsync(0)
		});
		for (var skill in displayData){
			var index=skill
			var abilityname=displayData[skill][1]
			var abilitydone=displayData[skill][2]
			if (abilitydone==0){
				var Skill=$.CreatePanel('Panel',skillContainer,'skill_'+index)
				Skill.AddClass('morphSpell')
				var SkillIcon = $.CreatePanel('DOTAAbilityImage', Skill, 'skill_icon_' + index)
				SkillIcon.abilityname = abilityname
				
			}
			$.Msg(abilityname)
			$.Msg(abilitydone)
		}	
}
var morph_timer_enabled=0

function stopMorphTime(){
	morph_timer_enabled=0
}

function startMorphTimer(){
	morph_timer_enabled=1
	var fps=60;
	var startTime = Date.now();
	var interval = 1/fps;
	var inc = 0;
	var timeNow = 0;
	animate();
	function animate() {
		timeNow = Date.now();
		inc=timeNow-startTime
		//$.Msg("starttime+timenow:")
		//$.Msg(startTime+timeNow)
		if (morph_timer_enabled==1){
			draw(inc)
			$.Schedule(interval, animate)
		}
	}
	function draw(inc) {
		$('#morphTimer').text=inc/1000
	}
}
function morphTrainingEnded(data){
	stopMorphTime()
	$("#morphTimer").style['visibility']='collapse'
	$('#morphHelperText').style['visibility']='collapse'
	$('#morphSpellContainer').style['visibility']='collapse'
}


GameEvents.Subscribe("morph_ended", morphTrainingEnded);
GameEvents.Subscribe("morph_start", morphTrainingStarted);
GameEvents.Subscribe("refresh_lasthit_values", lasthitDispay);
GameEvents.Subscribe("manta_challenge_start", mantaChallengeStarted);
GameEvents.Subscribe("custom_training_ends", HideUI);
GameEvents.Subscribe("reaction_start", aimTrainingStarted);
GameEvents.Subscribe("lh_start", LHTrainingStarted);
GameEvents.Subscribe("reaction_timer", updateTimer);
GameEvents.Subscribe("reaction_clicked", clickResult);
GameEvents.Subscribe("spell_casted", scheduleCast);
GameEvents.Subscribe("evasion_check", evasionControl);
GameEvents.Subscribe("top_score", updateTopScore);
GameEvents.Subscribe("upd_manta_values", updateMantaScore);
GameEvents.Subscribe("update_lives", updateLives);
//GameEvents.Subscribe("end_evasion_game", endEvasionGame);
GameEvents.Subscribe("custom_training_start", trainingStart);
GameEvents.Subscribe("update_morph_skills", morphUpdate);