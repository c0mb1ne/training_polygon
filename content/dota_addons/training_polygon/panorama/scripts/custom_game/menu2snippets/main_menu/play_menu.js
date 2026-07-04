//$.Msg('snippet loaded')
var menuContainer = $.GetContextPanel().GetParent();
var competitive_mods=["aim_ez","aim_med","aim_hard","map_aim","aim_move"]
var sandbox_mods=["dodge","timing","glimpse","armlet","invoker","other","lasthit","dreamcoil"]
var competitive_container=$('#compMenu')
var sandbox_container=$('#sndbxMenu')
var gameModeList=[]
GameEvents.SendCustomGameEventToServer (
	"get_gamemodes_for_menu",
	{
	}
);


/* for (var i =  0; i < competitive_mods.length; i++) {
	var mode=competitive_mods[i]
	var modePanel=$.CreatePanel('Button',competitive_container,mode)
	modePanel.SetAttributeString("mode",mode)
	modePanel.SetAttributeString("type","comp")
	modePanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/mode_button.xml", false, false)
	
}
for (var i =  0; i < sandbox_mods.length; i++) {
	var mode=sandbox_mods[i]
	var modePanel=$.CreatePanel('Button',sandbox_container,mode)
	modePanel.SetAttributeString("mode",mode)
	modePanel.SetAttributeString("type","sndbx")
	modePanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/mode_button.xml", false, false)
	
} */

function clearMenuContent(){
	$.Msg('clearing content of')
	$.Msg(menuContainer.id)
	$.Each(menuContainer.Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});
}

function drawGameModes(data){
	gameModeList=data.data
	$.Msg(gameModeList)
	for (var key in gameModeList) {
		var mode=gameModeList[key]
		var modeName=mode.name
		var modeType=mode.type
		var parentPanel
		if (modeType=="sandbox"){
			parentPanel=sandbox_container
		}else{
			parentPanel=competitive_container
		}
		var modePanel=$.CreatePanel('Button',parentPanel,modeName)
		modePanel.SetAttributeString("mode",modeName)
		modePanel.SetAttributeString("type",modeType)
		modePanel.BLoadLayout("file://{resources}/layout/custom_game/menu2snippets/mode_button.xml", false, false)
		
	}
}


$.Msg('play menu loaded')


GameEvents.Subscribe("gamemodes_to_draw", drawGameModes);
/* $.Msg(menuContainer.id) */