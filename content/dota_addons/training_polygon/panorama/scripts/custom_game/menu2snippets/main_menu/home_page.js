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
	}else if(state=="link_ready"){
		GameEvents.SendCustomGameEventToServer ("get_login_link",{});
	}else if(state=="login_done"){
		hideLoginWindow()
	}else{
		//nothing
	}
}
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
				openInternal(link)
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
GameEvents.Subscribe("login_link_set", setLoginLink);
GameEvents.Subscribe("login_done", hideLoginWindow);