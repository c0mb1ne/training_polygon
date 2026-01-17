//menu
//	play
//		any mode
//	settings
//	profile
//	sub
//	discord 

//hiding scoreboard button
var DotaHud=$.GetContextPanel().GetParent().GetParent().GetParent().GetParent()
var Hud=DotaHud.FindChild("Hud")
var HUDElements=Hud.FindChild("HUDElements")
var MenuButtons=HUDElements.FindChild("MenuButtons")
var ButtonBar=MenuButtons.FindChild("ButtonBar")
var ToggleScoreboardButton=ButtonBar.FindChild("ToggleScoreboardButton")
ToggleScoreboardButton.style['visibility']='collapse'

$('#menu_button_avatar').ClearPanelEvent("onmouseover")
$('#menu_button_avatar').ClearPanelEvent("onactivate")
/*var playerAvatar=$.CreatePanel('DOTAAvatarImage',$('#menu_avatar_container'),'ts_avatar')
playerAvatar.steamid='76561198010703166'*/
var menuContent=$('#menu_content')
function clearMenuContent(){
	$.Each(menuContent.Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});
}

var parentPanel = $('#testPan'); // the root panel of the current XML context
var newChildPanel = $.CreatePanel( "Panel", parentPanel, "ASDASD" );
newChildPanel.BLoadLayout( "file://{resources}/layout/custom_game/menu2snippets/test_snippet.xml", false, false );
function testgovna(){
	$.Msg('testgovna proiden')
}

$('#menu_play').SetPanelEvent (
"onactivate", 
	function() {
		clearMenuContent()
		var play_menu = $.CreatePanel( "Panel", menuContent, "play_menu" );
		play_menu.BLoadLayout( "file://{resources}/layout/custom_game/menu2snippets/play_menu.xml", false, false );
	}
)
function showTestUI(){
	$.Msg('showing new ui')
	$.GetContextPanel().style['visibility']="visible"
	$.GetContextPanel().style['opacity']="1"
}
function hideMainMenu() {
    $.GetContextPanel().style['visibility'] = "collapse";
    $.Msg('Main menu hidden');
}
function showMainMenu() {
    $.GetContextPanel().style['visibility'] = "visible";
    $.Msg('Main menu shown');
}

function setCameraOnEnt(data){
	GameUI.MoveCameraToEntity(data.ent)
}
GameEvents.Subscribe("set_camera_on_ent", setCameraOnEnt);
GameEvents.Subscribe("show_test_ui", showTestUI);
GameEvents.Subscribe("hide_main_menu", hideMainMenu);
GameEvents.Subscribe("show_main_menu", showMainMenu);