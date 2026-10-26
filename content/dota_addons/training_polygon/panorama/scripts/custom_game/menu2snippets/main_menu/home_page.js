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
GameEvents.SendCustomGameEventToServer (
	"get_login_url",
	{
	}
);
function setLoginLink(data){
	/* JSON.stringify(data) */
	let link=data.link
	if (link){
		/* $.Msg('setting login link ',link) */
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
function hideLoginWindow(){
	$('#loginWindow').DeleteAsync(0)
}
function openInternal(url){
	$.DispatchEvent("DOTADisplayURL", url);
}
function openExternal(url){
	$.DispatchEvent("ExternalBrowserGoToURL", url)
}
GameEvents.Subscribe("login_link_set", setLoginLink);
GameEvents.Subscribe("login_done", hideLoginWindow);