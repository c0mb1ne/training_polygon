/* $.Msg('settings page loaded') */
GameEvents.SendCustomGameEventToServer (
	"notifications_get_sounds",
	{
	}
);//asks notifications.lua
GameEvents.SendCustomGameEventToServer (
	"get_gamemodes_for_menu",
	{
	}
);//asks gamemode_manager for the mode selector
let notification_sounds
let currentScope = "general" //"general" or a gamemode name

function saveSounds(data){
    notification_sounds=data.data;
    drawSounds()
}
function drawModes(data){
    let container=$('#modeSelector')
    container.RemoveAndDeleteChildren()
    let modes=data.data
    let first=true
    for (let key in modes){
        let modeName=modes[key].name
        if (first){
            //no general scope in the ui, start from the first gamemode
            currentScope=modeName
            first=false
        }
        addScopeButton(container,modeName,modeName)
    }
    markScopeButtons()
    restoreChecked()
}
//returns the localized text for a token, or the token itself if it has no translation
function localizeToken(token){
    let localized=$.Localize("#"+token)
    if (localized==="#"+token || localized===""){
        return token
    }
    return localized
}
function addScopeButton(parent,scope,label){
    let btn=$.CreatePanel('ToggleButton',parent,"scope_"+scope)
    btn.AddClass('radioRowButton')
    let btnLabel=$.CreatePanel('Label',btn,"")
    btnLabel.text=label
    btn.SetPanelEvent(
        "onactivate",
        function(){
            currentScope=scope
            markScopeButtons()
            restoreChecked()
        }
    )
}
function markScopeButtons(){
    $.Each($('#modeSelector').Children(), function(btn){
        btn.checked=(btn.id==="scope_"+currentScope)
    })
}
function drawSounds(){
    let goodPanel=$('#goodSounds')
    let badPanel=$('#badSounds')
    for (let sound in notification_sounds){
        let entry=notification_sounds[sound]
        let displayName=localizeToken(entry.displayName)
        let sounds=entry.sounds
        drawSoundEntry("good",sound,displayName,goodPanel,sounds)
        drawSoundEntry("bad",sound,displayName,badPanel,sounds)
    }
    //panels were just (re)created, apply the checked state for the current scope
    restoreChecked()
}
function drawSoundEntry(type,id,displayName,parentPanel,sounds){
    let soundPanel=$.CreatePanel('ToggleButton',parentPanel,type+" "+id)
    soundPanel.AddClass('soundSettingsEntry')
    let soundPanelLabel=$.CreatePanel('Label',soundPanel,"label"+type+" "+id)
    soundPanelLabel.text=displayName
    soundPanel.SetPanelEvent(
        "onactivate",
        function(){
            let previewSound=getRandomSound(sounds)
            if (previewSound!==null){
                Game.EmitSound(previewSound)
            }
            notificationSoundSet(id,type)
            deselectOthers(soundPanel)
        }
    )
}
function getRandomSound(sounds) {
    let values = Object.values(sounds)
    if (values.length===0){
        return null //the "no sound" option previews as silence
    }
    let randomIndex = Math.floor(Math.random() * values.length)
    return values[randomIndex]
}
function notificationSoundSet(id,type){
    //goes through UserConfig: validated, debounce-saved and pushed to the backend
    UserConfigClient.Set(currentScope, type === "good" ? "notif_good_sound" : "notif_bad_sound", id);
}
//restore the checked state once the saved config arrives from the server
UserConfigClient.OnLoad(function(){
    restoreChecked()
});
function restoreChecked(){
    restoreCheckedFor("good", UserConfigClient.Get(currentScope,"notif_good_sound"))
    restoreCheckedFor("bad", UserConfigClient.Get(currentScope,"notif_bad_sound"))
}
function restoreCheckedFor(type, selectedId){
    let parent = $(type === "good" ? "#goodSounds" : "#badSounds");
    $.Each(parent.Children(), function(oPanel){
        oPanel.checked = (oPanel.id === type + " " + selectedId);
    });
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
GameEvents.Subscribe("gamemodes_to_draw", drawModes);
