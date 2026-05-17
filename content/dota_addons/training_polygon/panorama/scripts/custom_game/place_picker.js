

function placePickerShow(data){
    $.GetContextPanel().RemoveClass('Hidden')
}
function pickPlace(){
    let screenW=Game.GetScreenWidth()
    let screenH=Game.GetScreenHeight()
    let centerX=screenW/2
    let centerY=screenH/2
    let pos=Game.ScreenXYToWorld(centerX,centerY)
    GameEvents.SendCustomGameEventToServer (
	"place_picker_picked",
		{
            pos:pos
		}
	);
    $.GetContextPanel().AddClass('Hidden')
}


GameEvents.Subscribe('place_picker_show', placePickerShow);