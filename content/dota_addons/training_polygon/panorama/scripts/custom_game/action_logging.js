$.Msg('logger loaded')
let logger_active=false
let logger_fps=60
let screen_w=Game.GetScreenWidth()
let screen_h=Game.GetScreenHeight()
$.Msg('screen_W:',screen_w)
$.Msg('screen_H:',screen_h)
let log=[]
let log_sting=""
function normalizeScreenCoords(x,y){
	let result=[((x+1)/screen_w).toFixed(4),((y+1)/screen_h).toFixed(4)]
	return result
}
function loggerStart(){
	$.Msg('logger activated')

	logger_active=true
	loggingMouse()
}

function clearLog(){
	log=[]
	let log_sting=""
}

function loggerOrderRecieved(data){
	let pos=GameUI.WorldToScreenXYClamped(data.position)
	let pos_norm=[1,pos[0].toFixed(4),pos[1].toFixed(4)]
	let pos_sting=String(pos_norm)
	//$.Msg('o',pos_norm)
	if (logger_active){
		//log.push([1,pos_norm[0],pos_norm[1]])
		log_sting=log_sting+","+pos_sting
		//$.Msg(log_sting) 
	}
}

function loggerStop(){
	$.Msg('logger stopped')
	logger_active=false
}

function loggingMouse(){

	let mouse_pos=GameUI.GetCursorPosition()
	let mouse_pos_normalized=normalizeScreenCoords(mouse_pos[0],mouse_pos[1])
	//$.Msg('m',mouse_pos_normalized)
	//$.Msg(mouse_pos)
	if (logger_active){
		let mouse_pos_arr=[0,mouse_pos_normalized[0],mouse_pos_normalized[1]]
		//log.push([0,mouse_pos_normalized[0],mouse_pos_normalized[1]])
		log_sting=log_sting+","+String(mouse_pos_arr)
		$.Schedule(1/logger_fps, loggingMouse)
	}
}

function loggerSendLog(){
	GameEvents.SendCustomGameEventToServer (
		"logger_send_log",
		{
			"log":log_sting
		}
	);
	clearLog()
}
GameEvents.Subscribe("logger_get_log", loggerSendLog);
GameEvents.Subscribe("logger_start", loggerStart);
GameEvents.Subscribe("logger_stop", loggerStop);
GameEvents.Subscribe("logger_order_pos", loggerOrderRecieved);