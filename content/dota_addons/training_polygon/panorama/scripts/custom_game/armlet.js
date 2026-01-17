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
var enemyUnit
var enemyUnitInd
HideUI()
$('#sfCrosshair').style['visibility'] = 'collapse'

function HideUI() {
	rootpanel = $("#settingsPanel").GetParent()
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
	rootpanel = $("#settingsPanel").GetParent()
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

function UpdateStats(info){
	var unitInd=info.attacker
	var attackSpeed=Entities.GetAttackSpeed(unitInd)
	var minDmg=Entities.GetDamageMin(unitInd)
	var maxDmg=Entities.GetDamageMax(unitInd)
	var bonusDmg=Entities.GetDamageBonus(unitInd)
	$("#asField").text=attackSpeed.toFixed(3)*100
	$('#dmgField').text=(minDmg+maxDmg)/2+bonusDmg
	if (Entities.IsAlive(unitInd)){
		$.Schedule(0.1, function() {
			UpdateStats(info);
		});
	}
}
function ToggleFakeMod(){
	GameEvents.SendCustomGameEventToServer("armlet_mod_attacker", {"type" : "fm", "target" : enemyUnitInd});
}
function ChangeAttackSpeed(ASvalue){
	GameEvents.SendCustomGameEventToServer("armlet_mod_attacker", {"type" : "as", "value" : ASvalue, "target" : enemyUnitInd});
}
function ChangeAttackDamage(ADvalue){
	GameEvents.SendCustomGameEventToServer("armlet_mod_attacker", {"type" : "ad", "value" : ADvalue, "target" : enemyUnitInd});
}
function ChangeTreeLevel(inc){
	GameEvents.SendCustomGameEventToServer("change_tree_lvl", {"plus" : inc});
}
function ChangeSettings(inc,val){
	GameEvents.SendCustomGameEventToServer("change_global_settings", {"plus" : inc, "value" : val});
}
function ChangeMaxSpeed(inc){
	GameEvents.SendCustomGameEventToServer("change_max_speed", {"plus" : inc});
}
function ssToggleScepter(){
	GameEvents.SendCustomGameEventToServer("ss_scepter_toggle", {});
}
function ssToggleLense(){
	GameEvents.SendCustomGameEventToServer("ss_lense_toggle", {});
}
function ssToggleBlink(){
	GameEvents.SendCustomGameEventToServer("ss_blink_toggle", {});
}
function ArmTrainingStart(info){
	ShowUI()
	$('#armletCategory').style['visibility'] = 'visible'
	$('#invSettings').style['visibility'] = 'collapse'
	$('#skillShotCategory').style['visibility'] = 'collapse'
	$('#timingCategory').style['visibility'] = 'collapse'
	enemyUnitInd=info.attacker
	$("#quitButton").SetPanelEvent (
		"onactivate", 
		function() {
			ArmletEnd()
		}
	)
/*	UpdateStats(enemyUnitInd)
	$.Msg(enemyUnit)*/
}
function ssCrosshair(){
	GameEvents.SendCustomGameEventToServer("ss_crosshair_toggle", {});
}

function SsEnd(){
	$('#sfCrosshair').style['visibility'] = 'collapse'
	HideUI()
	GameEvents.SendCustomGameEventToServer("ss_training_end", {});
	$('#lvl_row').DeleteAsync(0)
}
function ArmletEnd(){
	HideUI()
	GameEvents.SendCustomGameEventToServer("armlet_training_end", {});
}
function InvEnd(){
	HideUI() 
	
	GameEvents.SendCustomGameEventToServer("invoker_procast_end", {});
}
function InvTrainingStart(info){
	//quitButton
	ShowUI()
	$('#armletCategory').style['visibility'] = 'collapse'
	$('#invSettings').style['visibility'] = 'visible'
	$('#skillShotCategory').style['visibility'] = 'collapse'
	$('#timingCategory').style['visibility'] = 'collapse'
	$("#quitButton").SetPanelEvent (
		"onactivate", 
		function() {
			InvEnd()
		}
	)

}
function TimingStart(info){
	//quitButton
	ShowUI()
	$('#armletCategory').style['visibility'] = 'collapse'
	$('#timingCategory').style['visibility'] = 'visible'
	$('#invSettings').style['visibility'] = 'collapse'
	$('#skillShotCategory').style['visibility'] = 'collapse'

	$("#quitButton").SetPanelEvent (
		"onactivate", 
		function() {
			InvEnd()
		}
	)

}
function SsTrainingStart(info){
	target_container=[]
	ShowUI()
	$('#invScepter').checked=false
	$('#invLens').checked=false
	$('#armletCategory').style['visibility'] = 'collapse'
	$('#invSettings').style['visibility'] = 'collapse'
	$('#skillShotCategory').style['visibility'] = 'visible'
	$('#timingCategory').style['visibility'] = 'collapse'
	if (info.hero_name=="npc_dota_hero_nevermore"){
		$('#sfCrosshair').style['visibility'] = 'visible'
	}
	$("#quitButton").SetPanelEvent (
		"onactivate", 
		function() {
			SsEnd()
		}
	)

}
function changeSphereLevel(sphere,value){
	GameEvents.SendCustomGameEventToServer("invoker_lvl", {"sphere" : sphere, "plus" : value});
	$.Schedule(0.1, refreshSpheres)
}

function toggleAghanim(){
	GameEvents.SendCustomGameEventToServer("invoker_scepter", {});
}
function toggleTalentTornado(){
	GameEvents.SendCustomGameEventToServer("invoker_talent", {});
}
function refreshSpheres(){
	var invoker=Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
	var quas=Entities.GetAbilityByName(invoker,"invoker_quas")
	var wex=Entities.GetAbilityByName(invoker,"invoker_wex")
	var exort=Entities.GetAbilityByName(invoker,"invoker_exort")
	var quasLvl=Abilities.GetLevel(quas)
	var wexLvl=Abilities.GetLevel(wex)
	var exortLvl=Abilities.GetLevel(exort)
	$('#quasField').text=quasLvl
	$('#wexField').text=wexLvl
	$('#exortField').text=exortLvl
}
function randomSpheres(){
	GameEvents.SendCustomGameEventToServer("invoker_sphere_rnd", {});
	$.Schedule(0.1, refreshSpheres)
}

function toggleTinyMove(){
	GameEvents.SendCustomGameEventToServer("invoker_procast_move_tiny", {});
}
function toggleTinyFast(){
	GameEvents.SendCustomGameEventToServer("invoker_procast_move_tiny_extremely_fast", {});
}
var target_container=[]
function reDrawTargets(){
	$.Each($('#remover_1').Children(), function(oPanel)
	{
		if (oPanel.paneltype=='DOTAHeroImage'){
			oPanel.DeleteAsync(0)
		}
	});
	$.Each($('#remover_2').Children(), function(oPanel)
	{
		if (oPanel.paneltype=='DOTAHeroImage'){
			oPanel.DeleteAsync(0)
		}
	});

	var counter=0
	for (var i in target_container){
		counter+=1
		var rowsCount
		var lastRow = counter % 4
		if (lastRow > 0){
			rowsCount = (counter - lastRow) / 4 + 1
		}
		else{
			rowsCount = counter / 4
		}

		createTargetThumb(target_container[i]['name'],target_container[i]['ind'],rowsCount)
		$.Msg('ind:',target_container[i]['ind'])
		$.Msg('name:',target_container[i]['name'])
	}
}
function targetRemove(id){
	/*$.Msg('id to find:',id)*/
	var i_to_delete
	var ind_to_delete
	for (var i in target_container){
		$.Msg('i:',i)
		$.Msg('tc[i]:',target_container[i]['ind'])
		if (target_container[i]['ind']==id){
			i_to_delete=i
			ind_to_delete=id
		}
	}
	GameEvents.SendCustomGameEventToServer("ss_remove_target", {"ind":ind_to_delete});
	target_container.splice(i_to_delete,1)
	$('#target_'+ind_to_delete).DeleteAsync(0)
	reDrawTargets()
	//fruits.splice(0, 1); 
}
function targetReplace(info){
	$.Msg('targetReplace')
	var old_index=info.old
	var new_index=info.new
	for (var i in target_container){
		if (target_container[i]['ind']==old_index){
			target_container[i]['ind']=new_index
			$.Msg('old index:',old_index)
			$.Msg('new index:',target_container[i]['ind'])
		}
	}
	reDrawTargets()
}
function ssTargetAdded(info){
	var target={'ind' : info.index,'name':info.name}
	target_container.push(target)
	reDrawTargets()
/*	var container_l=target_container.length
	var lastRow=container_l % 4
	var row=1
	if (lastRow>0) {
		row=2
	}*/
}
function ssNewTarget(unitname){
	$.Msg(unitname)
	GameEvents.SendCustomGameEventToServer("ss_add_target", {"name":unitname});
}
function createTargetThumb(name,id,row){
	var rowPanel=$('#remover_'+row)
	var HeroThumb = $.CreatePanel('DOTAHeroImage', rowPanel, 'target_' + id)
	HeroThumb.heroimagestyle="icon"
	HeroThumb.heroname=name
	HeroThumb.AddClass("targetToRemove")
	HeroThumb.SetPanelEvent (
		"onmouseactivate", 
		function() {
			targetRemove(id)
		}
	)
}

var events = [
		"onload",
		"onactivate",
		"onmouseactivate",
		"oncontextmenu",
		"onfocus",
		"ondescendantfocus",
		"onblur",
		"ondescendantblur",
		"oncancel",
		"onmouseover",
		"onmouseout",
		"ondblclick",
		"onmoveup",
		"onmovedown",
		"onmoveleft",
		"onmoveright",
		"ontabforward",
		"ontabbackward",
		"onselect",
		"ondeselect",
		"onscrolledtobottom",
		"onscrolledtorightedge"
]


function settingsFieldUpdater(info){
	// treeField minRField  maxRField minMSField maxMSField abLvlField
	var panel_name=info.field
	var panel_value=info.value
	$('#'+panel_name).text=panel_value
	$.Msg('#'+panel_name)
	$.Msg(panel_value)
}

function unitTesto(){
/*	var kek=Players.GetSelectedEntities(Players.GetLocalPlayer())
	for (var i in kek){
		var pos=Entities.GetAbsOrigin(kek[i])
		$.Msg('position:',pos)
	}*/
	$.Msg('testo')
	var parent=$('#skillShotCategory')
	var child1=$('#skillchanger')
	var child2=$('#cheburek')
	parent.MoveChildAfter(child1, child2);	
}


function createLevelChanger(info){
	var index=info.index
	var ability_name=Abilities.GetAbilityName(index)
	var parentPanel=$('#skillShotCategory')
	var rowContainer=$.CreatePanel('Panel', parentPanel, 'lvl_row')
	rowContainer.AddClass("Row")
	var buttonMinus=$.CreatePanel('Button', rowContainer, 'mbutton_'+index)
	buttonMinus.AddClass("DemoButton")
	buttonMinus.AddClass("Small")
	var mButtonText=$.CreatePanel('Label', buttonMinus, 'mbuttonl_'+index)
	mButtonText.text="-"
	var abilityThumb=$.CreatePanel('DOTAAbilityImage', rowContainer, 'abi_thumb_'+index)
	abilityThumb.abilityname=ability_name
	abilityThumb.AddClass("lvlChangerIcon")
	var buttonPlus=$.CreatePanel('Button', rowContainer, 'pbutton_'+index)
	buttonPlus.AddClass("DemoButton")
	buttonPlus.AddClass("Small")
	var pButtonText=$.CreatePanel('Label', buttonPlus, 'pbuttonl_'+index)
	pButtonText.text="+"
	parentPanel.MoveChildAfter(rowContainer, $("#skillchangerTitle"));	
	buttonPlus.SetPanelEvent (
		"onmouseactivate", 
		function() {
			GameEvents.SendCustomGameEventToServer("change_skill_lvl", {"plus":1,"index":index});
		}
	)
	buttonMinus.SetPanelEvent (
		"onmouseactivate", 
		function() {
			GameEvents.SendCustomGameEventToServer("change_skill_lvl", {"plus":-1,"index":index});
		}
	)
	
}

GameEvents.Subscribe("create_lvl_changer", createLevelChanger);
GameEvents.Subscribe("skillshot_replace", targetReplace);
GameEvents.Subscribe("invoker_training_start", InvTrainingStart);
GameEvents.Subscribe("timimng_started", TimingStart);
GameEvents.Subscribe("skillshot_training_start", SsTrainingStart);
GameEvents.Subscribe("armlet_training_start", ArmTrainingStart);
GameEvents.Subscribe("armlet_update_stats", UpdateStats);
GameEvents.Subscribe("skillshot_new_target", ssTargetAdded);
GameEvents.Subscribe("update_settings_field", settingsFieldUpdater);

//DOTAShowProfileCardTooltip(76561198010703166, true) targetReplace