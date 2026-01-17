$.Msg('ping reader loaded')
let Hud=$.GetContextPanel().GetParent().GetParent().GetParent()
let ping_panel=Hud.FindChild('HUDElements').FindChild('NetGraph')
let ping_right_col=ping_panel.FindChild('RightColumn_2')
let ping_right_col1=ping_panel.FindChild('RightColumn_1')
let ping_label=ping_right_col.FindChild('NetGraph_PING')
let fps_label=ping_right_col1.FindChild('NetGraph_FPS')
$.Msg(ping_label.text)
let avg_ping=0
let init_run=1
startCountingPing()
function startCountingPing(){
	//$.Msg('ping from ui:')
	//$.Msg(ping_label.text)//ADD MIN MAX AND SHOW AVG
	let pingFromUI=ping_label.text
	
	//$.Msg('ping:',avg_ping)
	GameEvents.SendCustomGameEventToServer (
		"store_ping",
		{
			"ping":pingFromUI
		}
	);
	$.Schedule(5, startCountingPing)
}