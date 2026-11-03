$.Msg('home page loaded')
function openPatreon(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://www.patreon.com/c0mb1ne")
}
function openBoosty(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://boosty.to/combine")
}
function openTg(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://t.me/cumbine")
}
$('#boosty').SetPanelEvent(
	"onactivate",
	function() {
		openBoosty()
	}
)
$('#patreon').SetPanelEvent(
	"onactivate",
	function() {
		openPatreon()
	}
)
$('#telegram').SetPanelEvent(
	"onactivate",
	function() {
		openTg()
	}
)
$('#loginForm').style['visibility']='collapse'
$('#loginRequest').style['visibility']='collapse'
GameEvents.SendCustomGameEventToServer (
	"get_login_state",
	{
	}
);
function loginStateRefresh(data){
	let state=data.state
	if (state=="server_alive"){
		$('#loginPlaceHolder').style['visibility']='collapse'
		$('#loginRequest').style['visibility']='visible'
	}else if(state=="server_unreachable"){
		showServerUnreachable()
	}else if(state=="link_ready"){
		GameEvents.SendCustomGameEventToServer ("get_login_link",{});
	}else if(state=="login_done"){
		hideLoginWindow()
	}else{
		//nothing
	}
}
//======= TEST: html panel login ============================================
//revert: set USE_HTML_LOGIN_PANEL to false; full removal = this block + login_popup.xml/css/js + its line in custom_ui_manifest.xml + the listener in main_menu_communicator.lua
var USE_HTML_LOGIN_PANEL = true
function openLoginInPanel(url){
	//popup lives in its own hud layout (login_popup.xml); game events reach every ui root
	GameEvents.SendCustomGameEventToServer("open_login_popup_request", {link: url})
	$.Msg('[LoginPanel] requested: ', url)
}
//===========================================================================
function setLoginLink(data){
	/* JSON.stringify(data) */
	let link=data.link
	if (link){
		/* $.Msg('setting login link ',link) */
		$('#loginRequest').style['visibility']='collapse'
		$('#loginPlaceHolder').style['visibility']='collapse'
		$('#loginForm').style['visibility']='visible'
		$('#loginInGame').SetPanelEvent(
			"onactivate",
			function() {
				if (USE_HTML_LOGIN_PANEL){
					openLoginInPanel(link)
				}else{
					openInternal(link)
				}
			}
		)
		$('#loginExternal').SetPanelEvent(
			"onactivate",
			function() {
				openExternal(link)
			}
		)
		//loginInGame
		//loginExternal

	}
	
}
function playerWantsLogin(){
	GameEvents.SendCustomGameEventToServer ("start_login",{});
}
function showLoginRequest(){
	$('#loginPlaceHolder').style['visibility']='collapse'
	$('#loginRequest').style['visibility']='visible'
}
function showServerUnreachable(){
	//server-side http is unavailable (local non-tools game): keep the placeholder visible and swap its text
	$('#loginRequest').style['visibility']='collapse'
	$('#loginForm').style['visibility']='collapse'
	$('#loginPlaceHolder').style['visibility']='visible'
	let label=$('#loginPlaceHolder').FindChildTraverse('connectDescLabel')
	if (label){
		label.text=$.Localize('#serverUnreachable')
	}
}
function hideLoginWindow(){
	$('#loginWindow').DeleteAsync(0)
}
function openInternal(url){
	$.DispatchEvent("DOTADisplayURL", url);
}
function openExternal(url){
	$.DispatchEvent("ExternalBrowserGoToURL", url)
}
GameEvents.Subscribe("login_state", loginStateRefresh);
GameEvents.Subscribe("server_alive", showLoginRequest);
GameEvents.Subscribe("server_unreachable", showServerUnreachable);
GameEvents.Subscribe("login_link_set", setLoginLink);
GameEvents.Subscribe("login_done", hideLoginWindow);