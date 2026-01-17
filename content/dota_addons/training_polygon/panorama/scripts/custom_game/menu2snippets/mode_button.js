

var mode=$.GetContextPanel().GetAttributeString("mode", "")
var type=$.GetContextPanel().GetAttributeString("type", "")
var menuContent = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().GetParent();
var leftMenu = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().GetParent().GetParent().GetParent().FindChild("menu_left_bar");
var playButton=leftMenu.FindChild("menu_button_container").FindChild("menu_play")
//$.Msg(playButton.id)
var image=$('#gmImage')
if (type=="comp"){
	//image.style['background-image']='url("file://{resources}/videos/15503461349800.webm");'
}else{
	//image.style['background-image']='url("file://{resources}/videos/test2.webm");'
}
/*image.style['background-image']='url("s2r://panorama/images/custom_game/test_png.vtex")'*/
/*var videoPanel=$('#mode_video')
videoPanel.SetMovie('file://{resources}/videos/15503461349800.webm')
videoPanel.Play()
videoPanel.Stop()*/
var modeName=$('#mode_name')
modeName.text=mode
videoPanel=$('#mode_video')
videoPanel.ClearPanelEvent("onactivate")
videoPanel.ClearPanelEvent("onload")
videoPanel.SetMovie('file://{resources}/videos/15503461349800.webm')
videoPanel.Play()
$.Schedule(0.1, function() {
	videoPanel.Pause()
})
$.GetContextPanel().SetPanelEvent(
	"onactivate", 
	function() {
		$.Msg('clicked')
		clearMenuContentAndDrawModePanel()
		var mode_menu = $.CreatePanel( "Panel", menuContent, mode+"_menu" );
		mode_menu.BLoadLayout( "file://{resources}/layout/custom_game/menu2snippets/"+mode+".xml", false, false );
	}
)
$.GetContextPanel().SetPanelEvent(
	"onmouseover", 
	function() {
		videoPanel.Play()
	}
)
$.GetContextPanel().SetPanelEvent(
	"onmouseout", 
	function() {
		videoPanel.Pause()
	}
)


function clearMenuContentAndDrawModePanel(){
	playButton.checked=false
	$.Each(menuContent.Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});
}