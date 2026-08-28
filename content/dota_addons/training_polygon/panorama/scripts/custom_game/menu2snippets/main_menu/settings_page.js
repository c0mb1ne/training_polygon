/* $.Msg('settings page loaded') */
GameEvents.SendCustomGameEventToServer (
	"notifications_get_sounds",
	{
	}
);
let notification_sounds

function saveSounds(data){
    notification_sounds=data.data;
    $.Msg(JSON.stringify(notification_sounds));
    drawSounds()
}
function drawSounds(){
    let goodPanel=$('#goodSounds')
    let badPanel=$('#badSounds')
    for (let sound in notification_sounds){
        let entry=notification_sounds[sound]
        let displayName=entry.displayName
        let sounds=entry.sounds
        drawSoundEntry("good",sound,displayName,goodPanel,sounds)
        drawSoundEntry("bad",sound,displayName,badPanel,sounds)
    }
}
function drawSoundEntry(type,id,displayName,parentPanel,sounds){
    let soundPanel=$.CreatePanel('ToggleButton',parentPanel,type+" "+id)
    soundPanel.AddClass('soundSettingsEntry')
    let soundPanelLabel=$.CreatePanel('Label',soundPanel,"label"+type+" "+id)
    soundPanelLabel.text=displayName
    soundPanel.SetPanelEvent(
        "onactivate",
        function(){
            Game.EmitSound(getRandomSound(sounds))
            notificationSoundSet(id,type)
            deselectOthers(soundPanel)
        }
    )
}
function getRandomSound(sounds) {
    let values = Object.values(sounds)
    let randomIndex = Math.floor(Math.random() * values.length)
    return values[randomIndex]
}
function notificationSoundSet(id,type){
    GameEvents.SendCustomGameEventToServer (
	"notifications_set_sound",
        {
            id: id,
            type: type
        }
    );
}
function deselectOthers(panel){
    let parent=panel.GetParent()
    $.Each(parent.Children(), function(oPanel){
        if (oPanel!==panel){
            oPanel.checked=false;
        }
    })
}
GameEvents.Subscribe("notifications_send_sounds", saveSounds);