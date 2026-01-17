//$.Msg('snippet loaded')
var menuContainer = $.GetContextPanel().GetParent();
var competitive_mods=["aim_ez","aim_med","aim_hard","map_aim","aim_move"]
var sandbox_mods=["dodge","timing","glimpse","armlet","invoker","other","lasthit","dreamcoil"]
var competitive_container=$('#compMenu')
var sandbox_container=$('#sndbxMenu')
// here we can collect favourites of user, popularity of gamemodes, their update date
for (var i =  0; i < competitive_mods.length; i++) {
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
	
}

function clearMenuContent(){
	$.Each(menuContainer.Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});
}

$.Msg(menuContainer.id)