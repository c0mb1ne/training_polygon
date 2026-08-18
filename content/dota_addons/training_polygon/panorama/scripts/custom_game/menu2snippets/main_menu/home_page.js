$.Msg('home page loaded')
function openPatreon(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://www.patreon.com/c0mb1ne")
}
function openBoosty(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://boosty.to/combine")
}
function openTg(){
	$.DispatchEvent("ExternalBrowserGoToURL", "https://t.me/c0mb1ne")
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