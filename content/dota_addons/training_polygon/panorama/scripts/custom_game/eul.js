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

 

rootpanel = $("#btnEnd").GetParent()
var timebar=$("#eulTimer")
var castpoint
rootpanel.style['visibility'] = 'collapse'; 
rootpanel.style['opacity'] = '0';  
/*$("#eulTimer").style['visibility'] = 'collapse'; 
$("#eulTimer").style['opacity'] = '0';  */
$("#SRSettings").style['visibility'] = 'collapse'; 
$("#SRSettings").style['opacity'] = '0';
$("#invokerBenchmark").style['visibility'] = 'collapse'; 
$("#invokerBenchmark").style['opacity'] = '0';
function createInvokeSkill(name,row){
	var parentPanel=$('#skillContainer')
	var invSkill=$.CreatePanel('DOTAAbilityImage', parentPanel, 'invoke_skill')
	invSkill.AddClass('invokeSkill')
	invSkill.AddClass('invokeCol'+row)
	invSkill.abilityname=name
	invSkill.AddClass("invokeSkillShow")
	return invSkill
}

var inv_grid=[]
for(var i=0; i<3; i++){
	inv_grid[i] = [];
/*	for(var j=0; j<6; j++){
	  inv_grid[i][j] = null; 
	}*/
}

function addInvokeSkill(name,row){
	var skill=createInvokeSkill(name,row)
	inv_grid[row].push(skill)
	refreshRowPos(row)
}
function removeInvokeSkill(row){
	inv_grid[row][0].RemoveClass('invokeSkillShow')
	inv_grid[row][0].AddClass('invokeSkillDisappear')
	inv_grid[row][0].DeleteAsync(0.5)
	inv_grid[row].shift()
	refreshRowPos(row)
}
function refreshRowPos(row){

	for (var i in inv_grid[row]){
		var y_pos=510-(80*i)-80-(5*i)
		inv_grid[row][i].style['position']='0px '+y_pos+'px 0px;'
	}
}
/*addInvokeSkill("invoker_emp",0)
	addInvokeSkill("invoker_ice_wall",0)
	addInvokeSkill("invoker_sun_strike",0)
	addInvokeSkill("invoker_sun_strike",0)
	addInvokeSkill("invoker_sun_strike",0)
	addInvokeSkill("invoker_sun_strike",0)*/
function test(){
	/*removeInvokeSkill(0)*/
	/*refreshRowPos(0)*/
	
}
function InvokePush(data){
	if (data.request=='push'){
		addInvokeSkill(data.skill,parseInt(data.row))
	}
	if (data.request=='remove'){
		removeInvokeSkill(data.row)
	}

}



function createProcastMarker(id,color,icon_name,pos){
	var Marker=$.CreatePanel('Panel', timebar, id+'_marker')
	Marker.AddClass('Marker')
	Marker.style['background-color']=color
	Marker.style['width']='2px'
	Marker.style['margin-left']=pos+'px'
	if (icon_name=='pepega'){
		var Icon=$.CreatePanel('Panel', timebar, id+'_icon')
		Icon.AddClass('pepega')
		Icon.style['margin-left']=(pos-15)+'px'
	}else{
		var Icon=$.CreatePanel('DOTAAbilityImage', timebar, id+'_icon')
		Icon.abilityname=icon_name
		if (icon_name.substring(0,4)=='item'){
			Icon.AddClass('itemIcon')
		}else{
			Icon.AddClass('Icon')
		}
		Icon.style['margin-left']=pos+'px'
	}
	
}
function moveProcastMarker(id,margin){
	var marker=$('#'+id+'_marker')
	var icon=$('#'+id+'_icon')
	marker.style["margin-left"] = margin + "px"
	marker.style["margin-top"] = "42px"
	icon.style["margin-left"] = margin + "px"
	icon.style["margin-top"] = "58px"
}

//def   of skill icons 
//ivoker UI '#237F6E'        
      
//условия пиздатого прокаста
//время между приземлением еула и санстрайка <0.25
//1 1 1 - max 3 burns
//2 1 1 -max 3 
//3 x x - max 4 
//4 x x - max 4   
//5 x x - max 5  
//6 x x - max 5
//7 x x - max 6 
//8 x x - max 6 
//бласт вешается сразу после еула
 

var barTime=4
var invCP=0.05
var tornado_dur=[0.8,1.1,1.4,1.7,2.0,2.3,2.6,2.9]
var tornado_speed=1000
var tornado_radius=200
var blast_radius=175
var blast_speed=1100
var blast_radius2=225

var global_quas 
var procast_type
var eul=-1
var tornado_talent=0


/*createProcastMarker('tornado','#B241BD','invoker_tornado',0)
createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',100) 
createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',200)

InvStartCalc(global_quas) */
/*createProcastMarker('eul','#237F6E','item_cyclone',0)
createProcastMarker('sunstrike','#FFE500','invoker_sun_strike',75)
createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',115)
createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',150)
InvBlastCalc()*/
  


function InvBlastCalc(){
	var barw = 400
	var entTable=Entities.GetAllEntitiesByName("npc_dota_hero_tiny")
	if (entTable[0]) {
		$.Msg('good')
		var hero=Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
		var enemy=entTable[0]
		var blastMarker=$('#blast_marker')
		var blastIcon=$('#blast_icon')
		getDistanceB()
		function getDistanceB(){
			var enemyPos=Entities.GetAbsOrigin(enemy)
			var heroPos=Entities.GetAbsOrigin(hero)
			if (heroPos && enemyPos){
				var distance=Math.sqrt(Math.pow((heroPos[0]-enemyPos[0]),2)+Math.pow((heroPos[1]-enemyPos[1]),2))
				var blast_timing=2.5-((distance-blast_radius)/blast_speed)-invCP
				var markerMargin = Math.floor(blast_timing*100)
				moveProcastMarker('blast',markerMargin)
			}
			
/*			if (procast_type==2){*/
				$.Schedule(0.05, getDistanceB)
/*			}*/
		}
	}else{
		$.Msg('bad')
	}
}


function InvStartCalc(quasLvl){

	var barw = 400
	var entTable=Entities.GetAllEntitiesByName("npc_dota_hero_tiny")
	if (entTable[0]) {
		$.Msg('good')
		getDistance()
		function getDistance(){
			var hero=Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
			var enemy=entTable[0]
			var enemyPos=Entities.GetAbsOrigin(enemy)
			var heroPos=Entities.GetAbsOrigin(hero)
			if (heroPos && enemyPos){
				var distance=Math.sqrt(Math.pow((heroPos[0]-enemyPos[0]),2)+Math.pow((heroPos[1]-enemyPos[1]),2))
				var tornado_timing=TargetStatusResistance*tornado_dur[quasLvl-1]+((distance-tornado_radius)/tornado_speed)+invCP+tornado_talent
	/*			$('#timerText').text=tornado_timing*/
				if (procast_type==1){
					var markerMargin = 290-Math.floor(tornado_timing*100)
					if (markerMargin<0){
						moveProcastMarker('emp',-markerMargin)
						moveProcastMarker('tornado',0)
					}else{
						moveProcastMarker('emp',0)
						moveProcastMarker('tornado',markerMargin)
					}
				}
				if (procast_type==2){
					var blast_timing=2.5-((distance-blast_radius)/blast_speed)-invCP
					var markerMargin = Math.floor(blast_timing*100)
					moveProcastMarker('blast',markerMargin)
				}
				if (procast_type==4){
					var markerMargin = 290-Math.floor(tornado_timing*100)
					if (markerMargin<0){
						var blast_timing=tornado_timing-((distance-blast_radius)/blast_speed)-invCP
						var blastMargin = Math.floor(blast_timing*100)
						moveProcastMarker('meteor',((-markerMargin)+120))
						moveProcastMarker('emp',-markerMargin)
						moveProcastMarker('tornado',0)
						moveProcastMarker('blast',blastMargin)
					}else{
						var blast_timing=2.9-((distance-blast_radius)/blast_speed)-invCP
						var blastMargin = Math.floor(blast_timing*100)
						moveProcastMarker('emp',0)
						moveProcastMarker('tornado',markerMargin)
						moveProcastMarker('meteor',120)
						moveProcastMarker('blast',blastMargin)
					}
				}
				if (procast_type==5){
					var markerMargin = 170-Math.floor(tornado_timing*100)
					if (markerMargin<0){
						var blast_timing=tornado_timing-((distance-blast_radius)/blast_speed)-invCP
						var blastMargin = Math.floor(blast_timing*100)
						moveProcastMarker('meteor',((-markerMargin)+50))
						moveProcastMarker('sunstrike',-markerMargin)
						moveProcastMarker('tornado',0)
						moveProcastMarker('blast',blastMargin)
					}else{
						var blast_timing=1.7-((distance-blast_radius)/blast_speed)-invCP
						var blastMargin = Math.floor(blast_timing*100)
						moveProcastMarker('sunstrike',0)
						moveProcastMarker('tornado',markerMargin)
						moveProcastMarker('meteor',50)
						moveProcastMarker('blast',blastMargin)
					}
				}
				if (procast_type==3){
					var markerMargin = 130-Math.floor(tornado_timing*100)
					/*var blast_timing=((distance+(blast_radius+blast_radius2/2))/blast_speed)-invCP*/
					var blast_timing=((distance-blast_radius)/blast_speed)-invCP
					var blastMargin=Math.floor(tornado_timing*100)-Math.floor(blast_timing*100)
					/*$('#timerText').text='Met:'+markerMargin+'Blst:'+blastMargin*/
					if (markerMargin<0){
						moveProcastMarker('blast',(blastMargin))
						moveProcastMarker('meteor',-markerMargin)
						moveProcastMarker('tornado',0)
					}else{
						moveProcastMarker('blast',blastMargin)
						moveProcastMarker('meteor',0)
						moveProcastMarker('tornado',markerMargin)
					}
				}
				if (procast_type==6){
					var markerMargin = 130-Math.floor(tornado_timing*100)
					var blast_timing=((distance+(blast_radius+blast_radius2/2))/blast_speed)-invCP
					var blastMargin=Math.floor(blast_timing*100)
					/*$('#timerText').text='Met:'+markerMargin+'Blst:'+blastMargin*/
					if (markerMargin<0){
						moveProcastMarker('blast',(blastMargin-markerMargin))
						moveProcastMarker('meteor',-markerMargin)
						moveProcastMarker('tornado',0)
					}else{
						moveProcastMarker('blast',blastMargin)
						moveProcastMarker('meteor',0)
						moveProcastMarker('tornado',markerMargin)
					}
				}
			}
			if (quasLvl==global_quas){
				$.Schedule(0.05, getDistance)
			}
		}
	}else{
		$.Msg('bad')
	}
}

function InvQuasTrack(data){
	if (data.quas){
		global_quas=data.quas
		InvStartCalc(global_quas)
	}
	if (data.scepter){
		if (data.scepter==1){
			global_quas+=1
			InvStartCalc(global_quas)
		}else{
			global_quas-=1
			InvStartCalc(global_quas)
		}
	}
}

function InvStartTimer(){
	var barw = 400
	animateOnTimeAppear($("#barDynamic"), barw, 60, 4)
}
function CustomStartTimer(info){
	var barw = 400
	animateOnTimeAppear($("#barDynamic"), barw, 60, info.time)
}
function endInvTraining(){
	$("#SRSettings").style['visibility'] = 'collapse'; 
	$("#SRSettings").style['opacity'] = '0';
	global_quas=0
	HideUI()
	$.Each(timebar.Children(), function( oPanel )
		{
			if (oPanel.id.indexOf('_icon')!==-1){
				oPanel.DeleteAsync(0)
			}
			if (oPanel.id.indexOf('_marker')!==-1){
				oPanel.DeleteAsync(0)
			}
		});
	//GameEvents.SendCustomGameEventToServer("invoker_procast_end", {});
	$("#btnEnd").style['visibility']='visible'
}
function endInvokeTraining(){
	$("#invokerBenchmark").style['visibility'] = 'collapse'; 
	$("#invokerBenchmark").style['opacity'] = '0';
	$("#invokerDance").style['visibility'] = 'collapse';
	HideUI()
	inv_grid=[]
	for(var i=0; i<3; i++){
		inv_grid[i] = [];
	/*	for(var j=0; j<6; j++){
		  inv_grid[i][j] = null; 
		}*/
	}
	GameEvents.SendCustomGameEventToServer("invoker_invoke_end", {});
	$.Each($("#skillContainer").Children(), function( oPanel )
		{
			if (oPanel.id=="invoke_skill"){
				/*$.Msg('alo nahyu')*/
				oPanel.DeleteAsync(0)
			}
		});
}
function InvokeTrainingStart(data){
	$("#invokerBenchmark").style['visibility'] = 'visible'; 
	$("#invokerBenchmark").style['opacity'] = '1';
	$("#invokerDance").style['visibility'] = 'visible';

	if (data.single_mode==1){
		$("#invokerDance").AddClass('singleTarget')

	}else{
		$("#invokerDance").RemoveClass('singleTarget')

	}
	$("#eulTimer").style['visibility'] = 'collapse';
	ShowUI()
	$("#btnEnd").SetPanelEvent("onactivate", endInvokeTraining)
}
function InvTrainingStart(data){
	//$("#btnEnd").SetPanelEvent("onactivate", endInvTraining)
	$("#btnEnd").style['visibility']='collapse'
	$("#eulTimer").style['visibility'] = 'visible';
	$("#eulTimer").style['opacity'] = '1';
	$("#description").style['visibility']='collapse'
	$("#barMarker").style['visibility']='collapse'
	$("#SRSettings").style['visibility'] = 'visible'; 
	$("#SRSettings").style['opacity'] = '1';
	var timebar=$("#eulTimer")
	$.Each(timebar.Children(), function( oPanel )
	{
		if (oPanel.id.indexOf('_icon')!==-1){
			oPanel.DeleteAsync(0)
		}
		if (oPanel.id.indexOf('_marker')!==-1){
			oPanel.DeleteAsync(0)
		}
	});
	timebar.style['width']='400px'
	ShowUI()
	procast_type=data.procast
	var hero=Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
	var hero_quas=Entities.GetAbilityByName(hero,'invoker_quas')
	var quas_lvl=Abilities.GetLevel(hero_quas)
	global_quas=quas_lvl
	if (procast_type==1){
		//ivoker UI
		var timebar=$("#eulTimer")
		timebar.style['width']='400px'

		//making EMP marker
		createProcastMarker('emp','#B241BD','invoker_emp',0)
		//making tornado marker
		createProcastMarker('tornado','#6441BD','invoker_tornado',0)
		InvStartCalc(global_quas)
	}
	if (procast_type==2){
		createProcastMarker('eul','#237F6E','item_cyclone',0)
		createProcastMarker('sunstrike','#FFE500','invoker_sun_strike',75)
		createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',115)
		createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',150)
		InvStartCalc(global_quas)
	}
	if (procast_type==3){
		createProcastMarker('tornado','#B241BD','invoker_tornado',0)
		createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',100)
		createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',200)
		InvStartCalc(global_quas)
	}
	if (procast_type==4){
		createProcastMarker('tornado','#B241BD','invoker_tornado',0)
		createProcastMarker('emp','#B241BD','invoker_emp',100)
		createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',150) 
		createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',200) 
		InvStartCalc(global_quas)  
	}
	if (procast_type==5){
		createProcastMarker('tornado','#B241BD','invoker_tornado',0)
		createProcastMarker('sunstrike','#FFE500','invoker_sun_strike',75)
		createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',115)
		createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',150) 
		InvStartCalc(global_quas)  
	}
	if (procast_type==6){
		createProcastMarker('tornado','#B241BD','invoker_tornado',0)
		createProcastMarker('meteor','#D39B2B','invoker_chaos_meteor',50)
		createProcastMarker('blast','#F6A6D3','invoker_deafening_blast',100)
		createProcastMarker('refresher','#1E720F','item_refresher',150)
		createProcastMarker('meteor2','#D39B2B','invoker_chaos_meteor',200)
		createProcastMarker('blast2','#F6A6D3','invoker_deafening_blast',250)
		InvStartCalc(global_quas)
	}

}


$("#lvlChanger").style['visibility'] = 'collapse';
$("#lvlChanger").style['opacity'] = '0';

function ChangeAbilityLvl(param) {
	if(param === 1)
		GameEvents.SendCustomGameEventToServer("euls_change_ability_lvl", {plus : 1});
	else
		GameEvents.SendCustomGameEventToServer("euls_change_ability_lvl", {plus : 0});
}

function HideUI() {
	rootpanel = $("#btnEnd").GetParent()
	AnimatePanel (
		rootpanel,
		{
			"opacity": "0;"
		},
		0.5,
		"ease-in"
	)
	$.Schedule(0.5, function() {
		rootpanel.style['visibility'] = 'collapse';
	})
}

function ShowUI() {
	rootpanel = $("#btnEnd").GetParent()
	rootpanel.style['visibility'] = 'visible'
	$.Schedule(0.5, function() {
		AnimatePanel (
			rootpanel,
			{
				"opacity": "1;"
			},
			0.5,
			"ease-in"
		);
	})
}

function voiceAnnounce(type) {
	if(type=="good")
		Game.EmitSound("eul_good_" + getRandomInt(1,23))
	if(type=="bad")
		Game.EmitSound("eul_bad_" + getRandomInt(1,5))
	if(type=="start_lina")
		Game.EmitSound("eul_start_game_5")
	if(type=="start_techies")
		Game.EmitSound("eul_start_game_6")
	if(type=="start")
		Game.EmitSound("eul_start_game_" + getRandomInt(1,4))
}

function getRandomInt(min, max) {
	return Math.floor(Math.random() * (max - min)) + min;
}
var kunkka_mode=0
function kunnkaTrainingStarted(info){
	$("#eulTimer").style['visibility'] = 'visible';
	$("#eulTimer").style['opacity'] = '1';
	$("#description").style['visibility']='collapse'
	$("#SRSettings").style['visibility'] = 'visible'; 
	$("#SRSettings").style['opacity'] = '1';
	$("#lvlChanger").style['visibility'] = 'visible';
	$("#lvlChanger").style['opacity'] = '1';
	if(info.timebar === 0) {
		$("#eulTimer").style['visibility'] = 'collapse';
		$("#eulTimer").style['opacity'] = '0';
	} else {
		$("#eulTimer").style['visibility'] = 'visible';
		$("#eulTimer").style['opacity'] = '1';
	}
	var timebar=$("#eulTimer")
	
	ShowUI()
	procast_type=info.procast
	if (procast_type==1){
		timebar.style['width']='300px'
		$("#barMarker").style['visibility']='visible'
		$("#barMarker").style['background-color']='#F33E3E'

	} 
	if (procast_type==2){
		kunkka_mode=1
		timebar.style['width']='400px'
		$("#barMarker").style['visibility']='collapse'
		createProcastMarker('xmarks','#D5292F','kunkka_x_marks_the_spot',0)
		createProcastMarker('ghostship','#3141BD','kunkka_ghostship',60)
		createProcastMarker('torrent','#3141BD','kunkka_torrent',340)
	}
	$("#btnEnd").SetPanelEvent (
		"onactivate", 
		function() {
			kunkka_mode=0
			$("#barMarker").style['background-color']='#7af442'
			$("#SRSettings").style['visibility'] = 'collapse'; 
			$("#SRSettings").style['opacity'] = '0';
			$("#lvlChanger").style['visibility'] = 'collapse';
			$("#lvlChanger").style['opacity'] = '0';
			HideUI()
			$.Each(timebar.Children(), function( oPanel )
			{
				if (oPanel.id.indexOf('_icon')!==-1){
					oPanel.DeleteAsync(0)
				}
				if (oPanel.id.indexOf('_marker')!==-1){
					oPanel.DeleteAsync(0)
				}
			});
			GameEvents.SendCustomGameEventToServer("kunnka_training_end", {});
		}
	)
}
function dreamcoilTrainingStarted(info){
	$("#eulTimer").style['visibility'] = 'visible';
	$("#eulTimer").style['opacity'] = '1';
	$("#description").style['visibility']='collapse'

	var timebar=$("#eulTimer")
	
	ShowUI()
	timebar.style['width']='700px'

	$("#barMarker").style['visibility']='visible'
	$("#barMarker").style['background-color']='#F33E3E'

	$("#barMarker").style['margin-left']='600px'
	$("#btnEnd").SetPanelEvent (
		"onactivate", 
		function() {
			kunkka_mode=0
			$("#barMarker").style['background-color']='#7af442'
			$("#SRSettings").style['visibility'] = 'collapse'; 
			$("#SRSettings").style['opacity'] = '0';
			$("#lvlChanger").style['visibility'] = 'collapse';
			$("#lvlChanger").style['opacity'] = '0';
			$("#barDynamic").style['visibility'] = 'visible';
			$("#barDynamic").style['opacity'] = '1';
			HideUI()
			$.Each(timebar.Children(), function( oPanel )
			{
				if (oPanel.id.indexOf('_icon')!==-1){
					oPanel.DeleteAsync(0)
				}
				if (oPanel.id.indexOf('_marker')!==-1){
					oPanel.DeleteAsync(0)
				}
			});
			GameEvents.SendCustomGameEventToServer("deam_coil_escape_end", {});
		}
	)
}
var timing_bar_w
var timing_bar_t
var timing_dynamic_mark=0

function dreamcoilLaunched(args){
	
	timing_dynamic_mark=1
	var entTable=Entities.GetAllEntitiesByName("npc_dota_thinker")
	if (entTable[0]) {
		$.Msg('good')
		getDistance()
		function getDistance(){
			var hero=Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
			var enemy=entTable[0]
			var enemyPos=Entities.GetAbsOrigin(enemy)
			var heroPos=Entities.GetAbsOrigin(hero)
			if (heroPos && enemyPos){

				var distance=Math.sqrt(Math.pow((heroPos[0]-enemyPos[0]),2)+Math.pow((heroPos[1]-enemyPos[1]),2))
				
				$("#barDynamic").style["width"]=distance.toString()+'px'
				$("#timerText").text=distance.toFixed(0)
			}
			if (timing_dynamic_mark==1){
				$.Schedule(0.05, getDistance)
			}
		}
	}else{
		$.Msg('bad')
	}
}

/*$("#eulTimer").style['visibility'] = 'visible';
	$("#eulTimer").style['opacity'] = '1';*/
function eulTrainingStarted(info) {
	ShowUI()
	$.Msg(info.timebar)
	var timebar=$("#eulTimer")

	$("#description").style['visibility']='collapse'
	$("#barMarker").style['visibility']='visible'
	if (info.timebar==1){
		$("#eulTimer").style['visibility'] = 'visible';
		$("#eulTimer").style['opacity'] = '1';
	}else{
		$("#eulTimer").style['visibility'] = 'collapse';
		$("#eulTimer").style['opacity'] = '0';
	}
	
	$("#btnEnd").style['visibility'] = 'visible';
	$("#SRSettings").style['visibility'] = 'collapse'; 
	$("#SRSettings").style['opacity'] = '0';
	$.Msg("POEEEEEHALI")
/*	castpoint = info.castpoint
	eul = info.bartime
	barw = 300*/
	$.Msg('bartime:',info.bartime)
	$.Msg('castpoint:',info.castpoint)
	timing_bar_w=(1+info.bartime)*100
	$.Msg('timing_bar_w:',timing_bar_w)
	timebar.style['width']=timing_bar_w+'px'
	timing_bar_t=1+info.bartime
	$.Msg('timing_bar_t:',timing_bar_t)
	
	//var user_skill_offset=(info.bartime-(info.castpoint))*100
	var user_skill_offset=(info.bartime-(info.castpoint))*100
	$.Msg('user_skill_offset:',user_skill_offset)
	var user_skill_name='pepega'
	createProcastMarker('timing_mark','#000',user_skill_name,user_skill_offset)
/*	markerMargin = Math.floor(barw - (barw * castpoint) / eul)
	$("#barMarker").style["margin-top"] = "42px"
	$("#barMarker").style["margin-left"] = markerMargin + "px"
	//$("#barMarker").style["width"] = epsW + "px"
	$("#barMarker").style["width"]="100%"*/
	//ShowUI()
	/*
	if (info.id!=4 && info.id!=6)
		voiceAnnounce("start")
	if (info.id==4)
		voiceAnnounce("start_techies")
	if (info.id==6)
		voiceAnnounce("start_lina")
	*/
	$("#btnEnd").SetPanelEvent("onactivate", endEulTraining)
	if (info.id === 420)
		$("#btnEnd").SetPanelEvent("onactivate", endAlcheTraining)
	if ([8,18,21,24].indexOf(info.id) !== -1) {
		$("#lvlChanger").style['visibility'] = 'visible';
		$("#lvlChanger").style['opacity'] = '1';
	} else {
		$("#lvlChanger").style['visibility'] = 'collapse';
		$("#lvlChanger").style['opacity'] = '0';
	}
	/*if(info.timebar === 0) {
		$("#eulTimer").style['visibility'] = 'collapse';
		$("#eulTimer").style['opacity'] = '0';
	} else {
		$("#eulTimer").style['visibility'] = 'visible';
		$("#eulTimer").style['opacity'] = '1';
	}*/
}
/*function eulTrainingStarted(info) {
	ShowUI()
	$("#eulTimer").style['visibility'] = 'visible';
	$("#eulTimer").style['opacity'] = '1';
	$("#description").style['visibility']='collapse'
	$("#barMarker").style['visibility']='collapse'
	$.Msg('bartime:',info.barTime)
	$.Msg('castpoint:',info.castpoint)
	timing_bar_w=(1+info.barTime)*100
	timing_bar_t=1+info.barTime
	timebar.style['width']=timing_bar_w+'px'
	var user_skill_offset=(info.barTime-(info.castpoint+info.delay))*100
	var user_skill_name=info.user_abil
	createProcastMarker('timing_mark','#3141BD',user_skill_name,user_skill_offset)
	if (info.formula_sec){
		$.Msg('sec formula recieved',info.formula_sec)
		dynamicMarkActivate(info.formula_sec,info.user_abil,info.target_name,info.castpoint)
	}
	if (info.formula_prim){
		$.Msg('prim formula recieved',info.formula_prim)
		dynamicMarkActivate(info.formula_prim,info.user_abil,info.target_name,info.castpoint)
	}
	
	$("#btnEnd").SetPanelEvent (
		"onactivate", 
		function() {
			HideUI()
			$.Each(timebar.Children(), function( oPanel )
			{
				if (oPanel.id.indexOf('_icon')!==-1){
					oPanel.DeleteAsync(0)
				}
				if (oPanel.id.indexOf('_marker')!==-1){
					oPanel.DeleteAsync(0)
				}
			});
			GameEvents.SendCustomGameEventToServer("euls_end", {});
		}
	)
}*/

function dynamicMarkActivate(vars,ability_name,target_name,castpoint){
	$.Msg('dma name:',ability_name )
	timing_dynamic_mark=1
	var entTable=Entities.GetAllEntitiesByName(target_name)
	if (entTable[0]) {
		$.Msg('good')
		getDistance()
		function getDistance(){
			var hero=Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
			var enemy=entTable[0]
			var enemyPos=Entities.GetAbsOrigin(enemy)
			var heroPos=Entities.GetAbsOrigin(hero)
			if (heroPos && enemyPos){
				var distance=Math.sqrt(Math.pow((heroPos[0]-enemyPos[0]),2)+Math.pow((heroPos[1]-enemyPos[1]),2))
				var projectile_time
				if (ability_name=="ancient_apparition_ice_blast"){
					var first_projectile_time=(distance-(vars.width/2))/vars.speed
					var second_projectile_time
					if ((distance-(vars.width/2))/750>2){
						second_projectile_time=2
					}else{
						second_projectile_time=(distance-(vars.width/2))/750
					}
					projectile_time=first_projectile_time+second_projectile_time
				}else{
					projectile_time=(distance-(vars.width/2))/vars.speed
				}
				var offset=timing_bar_w-100-castpoint*100-projectile_time*100
				moveProcastMarker('timing_mark',offset)
			}
			if (timing_dynamic_mark==1){
				$.Schedule(0.05, getDistance)
			}
		}
	}else{
		$.Msg('bad')
	}
}

function startTimer(info) {
	$.Msg('kek')
	animateOnTimeAppear($("#barDynamic"), timing_bar_w, 60, timing_bar_t)
}
function endEulTraining() {
	$("#SRSettings").style['visibility'] = 'collapse'; 
	$("#SRSettings").style['opacity'] = '0';
	eul=-1
	$.Each(timebar.Children(), function( oPanel )
		{
			if (oPanel.id.indexOf('_icon')!==-1){
				oPanel.DeleteAsync(0)
			}
			if (oPanel.id.indexOf('_marker')!==-1){
				oPanel.DeleteAsync(0)
			}
		});
	HideUI()
	GameEvents.SendCustomGameEventToServer("old_timing_end", {});
}
//----------------------------------------------------------------------------------------------------glimpse training

function glimpseTrainingStarted(info) {
	$("#eulTimer").style['visibility'] = 'visible';
	$("#eulTimer").style['opacity'] = '1';
	$("#description").style['visibility']='visible'
	$("#barMarker").style['visibility']='visible'
	barw = 300
	var timebar=$("#eulTimer")
	timebar.style['width']=barw+'px'
	ShowUI()
	if(info.timebar === 0) {
		$("#eulTimer").style['visibility'] = 'collapse';
		$("#eulTimer").style['opacity'] = '0';
	} else {
		$("#eulTimer").style['visibility'] = 'visible';
		$("#eulTimer").style['opacity'] = '1';
	}
	$("#btnEnd").SetPanelEvent (
		"onactivate", 
		function() {
			HideUI()
			GameEvents.SendCustomGameEventToServer("end_glimpse", {});
		}
	)
}

function startGlimpseTimer(info) {
	castpoint = info.castpoint
	//$.Msg(castpoint)
	travel = info.bartime
	barw = 300
	markerMargin = Math.floor(barw - (barw * castpoint) / travel)
	$("#barMarker").style["margin-left"] = markerMargin + "px"
	$("#barMarker").style["margin-top"] = "42px"
	//$("#barMarker").style["width"] = epsW.toString()+"px"
	$("#barMarker").style["width"] = "100%"
	animateOnTimeAppear($("#barDynamic"), barw, 60, info.bartime)
}
function startWispTimer(info) {
	barw = 600
	var timebar=$("#eulTimer")
	timebar.style['width']=barw+'px'
	castpoint = info.castpoint
	//$.Msg(castpoint)
	travel = info.bartime
	
	markerMargin = Math.floor(barw - (barw * castpoint) / travel)
	$("#barMarker").style["margin-left"] = markerMargin + "px"
	$("#barMarker").style["margin-top"] = "42px"
	//$("#barMarker").style["width"] = epsW.toString()+"px"
	$("#barMarker").style["width"] = "100%"
	animateOnTimeAppear($("#barDynamic"), barw, 60, info.bartime)
}



//----------------------------------------------------------------------------------------------------glimpse training end
hideNotify()
//showNotify()



function endAlcheTraining() {
	HideUI()
	GameEvents.SendCustomGameEventToServer("alche_end", {});
}





function eulResult(info) {
	//$.Msg(Game.Time())
	//$.Msg("infobad: ", info.bad)
	//$.Msg("infotime: ", info.time)
	if (info.bad === 1) {
		$("#desc").text = ""
		if(info.time==420) {
			//$("#desc").text=$.Localize("#mantaBad")
		} else {
			//$("#desc").text=$.Localize("#mantaBad")
		}
		Bad()
	} else {
		if (info.time < 0.25) {
			if (info.time === 0) {
				$("#desc").text = $.Localize("#eulDesc") + info.time.toString().substring(0,5) + " sec."
				Perfect()
			} else {
				$("#desc").text = $.Localize("#eulDesc") + info.time.toString().substring(0,5) + " sec."
				Good()
			}
		} else if(info.time === 420) {
			$("#desc").text = ""
			Good()
		} else {
			$("#desc").text = $.Localize("#eulDesc") + info.time.toString().substring(0,5) + " sec."
			Bad()
		}
	}
}



function showNotify() {
	$("#eulNotification").RemoveClass("FadeOut");
	$("#eulNotification").AddClass("FadeIn");
}
function hideNotify() {
	$("#eulNotification").RemoveClass("FadeIn");
	$("#eulNotification").AddClass("FadeOut");
}
function Good() {
	$("#header").text=$.Localize("#mantaGood");
	$("#eulNotification").style.color = "#02ff06";
	showNotify();
	//voiceAnnounce("good")
	$.Schedule (2, hideNotify);
}
function Bad() {
	$("#header").text = $.Localize( "#mantaBad" );
	$("#eulNotification").style.color="#ff0202";
	showNotify();
	//voiceAnnounce("bad")
	$.Schedule(2, hideNotify);
}
function Perfect() {
	$("#header").text = $.Localize("#notifyPerfect");
	$("#eulNotification").style.color = "#02ff06";
	showNotify();
	//voiceAnnounce("good")
	$.Schedule(2, hideNotify);
}

function animateOnTimeAppear(panel, castbarW, fps, duration) {
	var startTime = Date.now();
	var endTime = duration * 1000 + startTime;
	var interval = 1 / fps;
	var start=0;
	var inc=0;
	var timeNow=0;
	var razn = startTime - endTime;
	var razn2=0;
	animate();
	function animate() {
		timeNow = Date.now();
		//$.Msg("starttime + timenow = " + (startTime + timeNow))
		if (timeNow <= endTime) {
			razn2 = startTime - timeNow;
			inc = castbarW / (razn / razn2);
			draw(inc, razn2);
			$.Schedule(interval, animate)
		} else {
			var end2 = Date.now();
			panel.style["width"] = "0px";
			$("#timerText").text = "0.000";
			//$.Msg(panel.id.toString() + " app end in " + (end2 - startTime));
		}
	}
	function draw(inc) {
		//panel.style["margin-left"] = (barW - inc).toString() + "px";
		panel.style["width"] = inc.toString() + "px";
		$("#timerText").text = ((razn2 + (duration * 1000)) / 1000).toFixed(3);
	}

}
function pingOnMinimap(event) {
	GameUI.PingMinimapAtLocation(event.respawn_place)
}
function travelReminder(event) {
	$("#header").text=$.Localize( "#tpReminder" );
	$("#eulNotification").style.color="#dd833e";
	$("#desc").text=""
	showNotify();
	//voiceAnnounce("bad")
	$.Schedule(2,function(){hideNotify()});
}
function invokeBenchmarkUpdate(data){
	$("#skillsMin").text=data.skillsMin.toFixed(3);
	$("#skillsAvg").text=data.skillsAvg.toFixed(3);
	$("#sphersPerSkill").text=data.sphersPerSkill.toFixed(3);
}
var TargetStatusResistance=0

function StrengthTracker(data){
	TargetStatusResistance=1-(data.sr.toFixed(3)/100)
	$('#SRValue').text=data.sr.toFixed(1)+'%'
	$('#SRStrValue').text=data.str
	//timebar changing
	if (eul!=-1){
		total_time = eul*TargetStatusResistance
		barw = 300
		markerMargin = Math.floor(barw - (barw * castpoint) / total_time)
		$("#barMarker").style["margin-left"] = markerMargin + "px"
		$("#barMarker").style["margin-top"] = "42px"
		//$("#barMarker").style["width"] = epsW.toString()+"px"
		$("#barMarker").style["width"] = "100%"
	}
	if (kunkka_mode==1){

		var xmark_dur=4*TargetStatusResistance


		var ship_castpoint=0.3
		var ship_delay=3.06
		var ship_stun=1.4*TargetStatusResistance
		var torrent_castpoint=0.4
		var torrent_delay=1.6
		var torrent_stun=1.6*TargetStatusResistance
		var ship_marker=Math.floor((xmark_dur-ship_castpoint-ship_delay)*100)
		var torrent_marker=Math.floor((xmark_dur+ship_stun-torrent_castpoint-torrent_delay)*100)
		if (ship_marker<0){
			moveProcastMarker('ghostship',0)
			moveProcastMarker('xmarks',-ship_marker)
		}else{
			moveProcastMarker('ghostship',ship_marker)
			moveProcastMarker('xmarks',0)
		}
		
		moveProcastMarker('torrent',torrent_marker)
		
		
	}
}


function changeStr(value){
	GameEvents.SendCustomGameEventToServer("euls_change_str", {type:'str',plus:value});
}

function changeSR(value){
	GameEvents.SendCustomGameEventToServer("euls_change_str", {type:'sr',plus:value});
}
function InvokeTalentState(info){
	if (info.talent==1){
		tornado_talent=1.25
	}else{ 
		tornado_talent=0
	}
}
//custom_training_ends endInvTraining
 GameEvents.Subscribe("invoker_procast_end_2", endInvTraining);
 GameEvents.Subscribe("invok_talent_change", InvokeTalentState);
 GameEvents.Subscribe("start_custom_timer", CustomStartTimer);
 GameEvents.Subscribe("str_tracker", StrengthTracker);
 GameEvents.Subscribe("invoke_benchmark", invokeBenchmarkUpdate);
 GameEvents.Subscribe("invok_start", InvokeTrainingStart);
 GameEvents.Subscribe("kun_start", kunnkaTrainingStarted);
 GameEvents.Subscribe("invok_push", InvokePush);
 GameEvents.Subscribe("invoker_quas_tracker", InvQuasTrack);
 GameEvents.Subscribe("invoker_timer_start", InvStartTimer);
 GameEvents.Subscribe("invoker_training_start", InvTrainingStart);
 GameEvents.Subscribe("dreamcoil_start", dreamcoilTrainingStarted);
 GameEvents.Subscribe("eul_training_started", eulTrainingStarted);
 GameEvents.Subscribe("eul_casted", startTimer);
 GameEvents.Subscribe("glimpse_training_started", glimpseTrainingStarted);
 GameEvents.Subscribe("glimpse_casted", startGlimpseTimer);
 GameEvents.Subscribe("relocate_timer", startWispTimer);
 GameEvents.Subscribe("eul_result", eulResult);
 GameEvents.Subscribe("ping_on_minimap", pingOnMinimap);
 GameEvents.Subscribe("travel_reminder", travelReminder);
 GameEvents.Subscribe("dreamcoilLaunched", dreamcoilLaunched);
 /*GameEvents.Subscribe("timing_started", eulTrainingStarted);*/
 