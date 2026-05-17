//menu
//	play
//		any mode
//	settings
//	profile
//	sub
//	discord 

//hiding scoreboard button
$.GetContextPanel().SetDisableFocusOnMouseDown(false)
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

var home_page = $.CreatePanel( "Panel", menuContent, "home_page" ); 
home_page.BLoadLayout( "file://{resources}/layout/custom_game/menu2snippets/main_menu/home_page.xml", false, false );
$('#menu_home').selected=true

$('#menu_play').SetPanelEvent (
"onactivate", 
	function() {
		clearMenuContent()
		var play_menu = $.CreatePanel( "Panel", menuContent, "play_menu" );
		play_menu.BLoadLayout( "file://{resources}/layout/custom_game/menu2snippets/main_menu/play_menu.xml", false, false );
	}
)
$('#menu_home').SetPanelEvent (
"onactivate", 
	function() {
		$.Msg('trying to load main menu')
		clearMenuContent()
		var home_page = $.CreatePanel( "Panel", menuContent, "home_page" ); 
		home_page.BLoadLayout( "file://{resources}/layout/custom_game/menu2snippets/main_menu/home_page.xml", false, false );
	}
)
function showTestUI(){
	$.Msg('showing new ui')
	$.GetContextPanel().style['visibility']="visible"
	$.GetContextPanel().style['opacity']="1"
}
function hideMainMenu() {
    $.GetContextPanel().style['visibility'] = "collapse";
	$.GetContextPanel().style['opacity'] = "0";
    $.Msg('Main menu hidden');
}
function showMainMenu() {

    $.GetContextPanel().style['visibility'] = "visible";
	$.GetContextPanel().style['opacity'] = "1";
    $.Msg('Main menu shown');
}

function setCameraOnEnt(data){
	GameUI.MoveCameraToEntity(data.ent)
}
function openDiscord(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://discord.gg/9qCAqFH")
}
function openGithub(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://github.com/c0mb1ne/training_polygon")
}
function menuLoadPage(data){
	let page_path=data.page
	$.Msg('trying to load ',page_path)
	clearMenuContent()
	let home_page = $.CreatePanel( "Panel", menuContent, "loaded_page" ); 
	let result=home_page.BLoadLayout( page_path, false, false );
	if (result){
		$.Msg('panel loaded ',page_path)
	}else{
		$.Msg('panel not loaded ',page_path)
	}
	$('#menu_play').checked=false
}

GameEvents.Subscribe("main_menu_load_page", menuLoadPage);
GameEvents.Subscribe("set_camera_on_ent", setCameraOnEnt);
GameEvents.Subscribe("show_test_ui", showTestUI);
GameEvents.Subscribe("hide_main_menu", hideMainMenu);
GameEvents.Subscribe("show_main_menu", showMainMenu);