var rootPanel = $.GetContextPanel();
/* $.Each(rootPanel.Children(), function( oPanel )
{
    oPanel.DeleteAsync(0)
}); */

/* var timebarContainer = $.CreatePanel('Panel', rootPanel, 'TimebarContainer');
timebarContainer.AddClass('TimebarContainer')
var resizeAnchor = $.CreatePanel('Panel', timebarContainer, 'ResizeAnchor');
resizeAnchor.AddClass("ResizeAnchor") */
var timebarContainer = $('#TimebarContainer')
var resizeAnchor =$('#ResizeAnchor')
var lockButton=$('#LockButton')
var dynamicBar=$('#DynamicBar')
var greenZone=$('#GreenZone')
var TimeLabel=$('#TimeLabel')
var RedLine=$('#RedLine') //visualization of player action
var BlueLine=$('#BlueLine') //visualization for debugging
timebarContainer.SetDraggable(true);
var defaultPosition="1434.0px 115.0px 0.0px";
timebarContainer.style.position=defaultPosition;
var minWidth = 400;
var minHeight = 150;
var positionTemp = "";
var timeBarLocked=false;
// Resize state
var isResizing = false;
var resizeStartMouseX = 0;
var resizeStartMouseY = 0;
var resizeStartWidth = 0;
var resizeStartHeight = 0;
var resizeStartOffsetX = 0;
var resizeStartOffsetY = 0;
var mouseOffsetX = 0; // Offset between mouse and anchor at start
var mouseOffsetY = 0;

var isMouseOverAnchor = false;
var wasMouseDown = false;

// Calculate UI scale
var screenScaleX = 1 / rootPanel.actualuiscale_x;
var screenScaleY = 1 / rootPanel.actualuiscale_y;
$.Msg('UI scales:', screenScaleX, " ", screenScaleY);
//animation vars
var fps = 120;
var animationSchedule = null;
var isAnimating = false;
var animationStartTime = 0;
var animationDuration = 0;
var greenZoneStart = 0;
var greenZoneWidth = 0;
var marksTrashCan=[];
var error=0.079;
/* var error=0.075 */
//debug
/* var debugMouse=$.CreatePanel('Panel', rootPanel, 'debugMouse');
debugMouse.style.width="10px"
debugMouse.style.height="10px"
debugMouse.style.backgroundColor = '#00FF00'; */

// Drag handlers
$.RegisterEventHandler('DragStart', timebarContainer, OnDragStart);
$.RegisterEventHandler('DragEnter', timebarContainer, OnDragEnter);
$.RegisterEventHandler('DragLeave', timebarContainer, OnDragLeave);
$.RegisterEventHandler('DragDrop', timebarContainer, OnDragDrop);
$.RegisterEventHandler('DragEnd', timebarContainer, OnDragEnd);
$.RegisterEventHandler('DragMove', timebarContainer, OnDragMove);

function OnDragStart(panelId, dragCallbacks) {
    let mousePos = GameUI.GetCursorPosition();
    dragCallbacks.displayPanel = panelId;
    
    var dragStartOffsetX = mousePos[0] - timebarContainer.actualxoffset;
    var dragStartOffsetY = mousePos[1] - timebarContainer.actualyoffset;
    dragCallbacks.offsetX = dragStartOffsetX;
    dragCallbacks.offsetY = dragStartOffsetY;
}

function OnDragEnter(a, draggedPanel) {}
function OnDragMove(a, draggedPanel) {
    positionTemp = draggedPanel.style.position;
}
function OnDragLeave(panelId, draggedPanel) {}
function OnDragDrop(panelId, draggedPanel) {}
function OnDragEnd(panelId, draggedPanel) {
    $.Msg("drag end")
    draggedPanel.style.position = positionTemp;
    /* $.Msg(draggedPanel.style.position) */
    positionTemp = "";
    CheckAndFixOffscreenPosition();
}

// Track mouse over anchor
resizeAnchor.SetPanelEvent("onmouseover", function() {
    isMouseOverAnchor = true;
    if (!isResizing) {
        timebarContainer.SetDraggable(false);
    }
});

resizeAnchor.SetPanelEvent("onmouseout", function() {
    isMouseOverAnchor = false;
    if (!isResizing) {
        timebarContainer.SetDraggable(true);
    }
});
lockButton.SetPanelEvent("onmouseactivate", function() {
    if (timeBarLocked==false){
        timeBarLocked=true;
        timebarContainer.SetDraggable(false);
        lockButton.AddClass('Locked')
        $.Msg('Timebar locked')
    }else{
        timeBarLocked=false;
        timebarContainer.SetDraggable(true);
        lockButton.RemoveClass('Locked')
        $.Msg('Timebar unlocked')
    }
    
});
// Update resize and check mouse state
function UpdateResize() {
    var isMouseDown = GameUI.IsMouseDown(0);
    let mousePos = GameUI.GetCursorPosition();
    
    // Scale mouse position to UI space
    let scaledMouseX = mousePos[0] * screenScaleX;
    let scaledMouseY = mousePos[1] * screenScaleY;
    /* debugMouse.style.position=`${scaledMouseX}px ${scaledMouseY}px 0px` */
    // Detect mouse press
    if (isMouseDown && !wasMouseDown && !timeBarLocked) {
        if (isMouseOverAnchor) {
            isResizing = true;
            
            // Store starting values
            resizeStartMouseX = scaledMouseX;
            resizeStartMouseY = scaledMouseY;
            resizeStartWidth = timebarContainer.actuallayoutwidth;
            resizeStartHeight = timebarContainer.actuallayoutheight;
            resizeStartOffsetX=timebarContainer.actualxoffset;
            resizeStartOffsetY=timebarContainer.actualyoffset;
            mouseOffsetX=resizeStartMouseX-resizeStartWidth-resizeStartOffsetX
            mouseOffsetY=resizeStartMouseY-resizeStartHeight-resizeStartOffsetY
            timebarContainer.SetDraggable(false);
            $.Msg('=== RESIZE START ===');
            $.Msg('Start size: ' + resizeStartWidth + 'x' + resizeStartHeight);
            $.Msg('actual offset: ' + resizeStartOffsetX + 'x' + resizeStartOffsetY);
            $.Msg('mouse pos: ' + resizeStartMouseX + 'x' + resizeStartMouseY);
        }
    }
    
    // Detect mouse release
    if (!isMouseDown && wasMouseDown && !timeBarLocked) {
        if (isResizing) {
            isResizing = false;
            timebarContainer.SetDraggable(true);
            CheckAndFixOffscreenPosition();
            $.Msg('=== RESIZE END ===');
        }
    }
    
    wasMouseDown = isMouseDown;
    
    // Perform resize if active
    if (isResizing) {
        
        
        /* let newWidth = Math.max(minWidth,  scaledMouseX -resizeStartOffsetX);
        let newHeight = Math.max(minHeight, scaledMouseY -resizeStartOffsetY); */
        let mouseDeltaX=scaledMouseX-resizeStartMouseX
        let mouseDeltaY=scaledMouseY-resizeStartMouseY
        let newWidth = Math.max(minWidth,  (resizeStartWidth*screenScaleX+mouseDeltaX));
        let newHeight = Math.max(minHeight, (resizeStartHeight*screenScaleY+mouseDeltaY));
        timebarContainer.style.width = newWidth + "px";
        timebarContainer.style.height = newHeight + "px";
        /* $.Msg('=== RESIZing ===');
        $.Msg('mouse del: ' + mouseDeltaX + 'x' + mouseDeltaY); */
    }
    
    $.Schedule(0.01, UpdateResize);
}
// Start the update loop 
UpdateResize();

function CheckAndFixOffscreenPosition() {
    // Get screen dimensions in UI space
    var screenWidth = Game.GetScreenWidth() * screenScaleX;
    var screenHeight = Game.GetScreenHeight() * screenScaleY;
    
    // Get panel position and dimensions in UI space
    var panelX = timebarContainer.actualxoffset * screenScaleX;
    var panelY = timebarContainer.actualyoffset * screenScaleY;
    var panelWidth = timebarContainer.actuallayoutwidth * screenScaleX;
    var panelHeight = timebarContainer.actuallayoutheight * screenScaleY;
    
    // Calculate panel boundaries
    var panelRight = panelX + panelWidth;
    var panelBottom = panelY + panelHeight;
    
    var needsReposition = false;
    var newX = panelX;
    var newY = panelY;
    
    // Check if panel is offscreen and calculate new position
    if (panelX < 0) {
        newX = 0;
        needsReposition = true;
    }
    if (panelY < 0) {
        newY = 0;
        needsReposition = true;
    }
    if (panelRight > screenWidth) {
        newX = screenWidth - panelWidth;
        needsReposition = true;
    }
    if (panelBottom > screenHeight) {
        newY = screenHeight - panelHeight;
        needsReposition = true;
    }
    
    // Reposition if needed
    if (needsReposition) {
        timebarContainer.style.position = newX + "px " + newY + "px 0px";
        $.Msg('Panel repositioned to stay onscreen: ' + newX + 'x' + newY);
    }
}

function hideTimebar(){
    timebarContainer.style.visibility="collapse"
}
function showTimebar(){
    timebarContainer.style.visibility="visible"
}
hideTimebar()

var marksContainer=$('#MiddleSpace')
//class for zone type marks:
class timebarZone{
    constructor(totalTime){
        this.barTotalTime=totalTime;
        this.parentPanel=$('#MiddleSpace')
        this.isDynamic=false;
        this.panel=$.CreatePanel('Panel',marksContainer,"zone_mark");
        this.panel.style['horizontal-align'] = "left";
        this.panel.AddClass("GreenZone")
    }
    SetWidth(time){
        var width=(time/this.barTotalTime)*100;
        /* $.Msg('calculated width:',width); */
        this.panel.style['width']=width+"%";
    }
    SetOffset(time){
        var offset=((time+error)/this.barTotalTime)*100;
        this.panel.style['margin-left']=offset+"%";
    }
    RemoveSelf(){
        this.panel.DeleteAsync(0);
    }
    //todo: add dynamic zone
}
//class for single tick marks:
class timebarSingleMark{
    //add single mark
    //add dynamic single mark
    //marks have colors, 
    constructor(totalTime,color,iconAbilityName){
        this.offsetTime=0;
        this.barTotalTime=totalTime;
        this.parentPanel=$('#MiddleSpace');
        this.iconParentPanel=$('#BottomSpace');
        this.isDynamic=false;
        this.markUpdater=null;
        this.markPanel=$.CreatePanel('Panel',this.parentPanel,"single_mark");
        this.markPanel.AddClass('SingleMarkLine');
        this.markPanel.style['background-color']=color+";";
        this.iconPanel=$.CreatePanel('DOTAAbilityImage',this.iconParentPanel,"single_mark_icon");
        this.iconPanel.abilityname=iconAbilityName;
        this.iconPanel.AddClass('SingleMarkIcon');
        this.ent1=null;
        this.ent2=null;
        this.speed=null;
        this.dynamicOffset=0;
        this.fps=100;
    }
    SetOffset(time){
        this.offsetTime=time;
        var offset=((time+error)/this.barTotalTime)*100;
        this.markPanel.style['margin-left']=offset+"%";
        var iconW=this.iconPanel;
        this.iconPanel.style['margin-left']=offset+"%";
        //todo: make icon to be centered relative to mark (need some calcualtions with screen scale etc.)
    }
    RemoveSelf(){
        this.isDynamic=false;
        $.CancelScheduled(this.markUpdater);
        this.markPanel.DeleteAsync(0);
        this.iconPanel.DeleteAsync(0);
    }
    SetDynamic(entity1,entity2,speed,offset){
        this.isDynamic=true;
        this.ent1=entity1;
        this.ent2=entity2;
        this.speed=speed;
        this.dynamicOffset=offset;
        this.UpdateDistance();
    }
    UpdateDistance(){
        var pos1=Entities.GetAbsOrigin(this.ent1);
        var pos2=Entities.GetAbsOrigin(this.ent2);
        if (!pos1 || !pos2){
            $.Msg('pos1 or pos2 error');
            return null;
        }
        var dx = pos1[0] - pos2[0];
        var dy = pos1[1] - pos2[1];
        var dz = pos1[2] - pos2[2];
        var distance=Math.sqrt(dx * dx + dy * dy + dz * dz)-this.dynamicOffset;
        if (distance<0){
            distance=0;
        }
        var time=distance/this.speed;
        var offset=((this.offsetTime-time+error)/this.barTotalTime)*100;
        this.markPanel.style['margin-left']=offset+"%";
        this.iconPanel.style['margin-left']=offset+"%";
        /* $.Msg('time:',time); */
        if (this.isDynamic){
            this.markUpdater=$.Schedule(1.0 / this.fps, this.UpdateDistance.bind(this));
        }
    }
}
//class for controlling text timer:
class timebarTimer {
    constructor() {
        this.timerLabel = $('#TimeLabel');
        this.isCountdown = false;
        this.fps = 180;
        this.totalTime = 0;
        this.timerScheduler = null;
        this.timerStartTime = 0;
        this.isAnimating = false;
    }
    SetCountdownMode(value) {
        this.isCountdown = value;
    }
    SetTotalTime(time) {
        this.totalTime = time;
    }
    StartTimer() {
        this.timerStartTime = Game.GetGameTime();

        if (this.isCountdown === true) {
            this.timerLabel.text = this.totalTime.toFixed(3);
        } else {
            this.timerLabel.text = "0.000";
        }

        this.isAnimating = true;
        this.DrawTime();
    }
    DrawTime() {
        if (!this.isAnimating) {
            return;
        }

        var currentTime = Game.GetGameTime();
        var elapsed = currentTime - this.timerStartTime;
        var progress = this.totalTime > 0 ? Math.min(elapsed / this.totalTime, 1.0) : 1.0;

        var displayTime;
        if (this.isCountdown === false) {
            // Counting up: show elapsed time, capped at totalTime
            displayTime = Math.min(elapsed, this.totalTime);
        } else {
            // Counting down: show time remaining
            displayTime = Math.max(0, this.totalTime - elapsed);
        }

        this.timerLabel.text = displayTime.toFixed(3);

        if (progress >= 1.0) {
            this.StopAnimation();
            return;
        }

        this.timerScheduler = $.Schedule(1.0 / this.fps, this.DrawTime.bind(this));
    }
    StopAnimation() {
        if (this.timerScheduler !== null) {
            $.CancelScheduled(this.timerScheduler);
            this.timerScheduler = null;
        }

        this.isAnimating = false;
        // Final value depends on mode: countdown ends at 0, count-up ends at totalTime
        this.timerLabel.text = this.isCountdown ? "0.000" : this.totalTime.toFixed(3);
    }
}
//class for controlling bar:
class timebarDynamicBar{
    constructor(){
        this.timeMode=false;//if dynamic bar represents time
        this.distanceMode=false;//if dynamic bar represents distance
        this.totalTime=0;//how much time bar represents, offsets will depend on this
        this.barPanel=$('#DynamicBar');
        this.isAnimating=false;
        this.animationScheduler=null;
        this.animationStartTime=0;
        this.fps=180;
        this.soundTrigger=false;
        this.soundTriggerTime=0;
    }
    SetMode(mode){
        if (mode === "time"){
            this.timeMode = true;
            this.distanceMode = false;
        } else if (mode === "distance"){
            this.timeMode = false;
            this.distanceMode = true;
        } else {
            $.Msg('Unknown mode:', mode);
        }
    }
    SetTotalTime(time){
        this.totalTime=time;
    }
    StartAnimation(){
        //todo: add condition to handle distance mode
        this.barPanel.style['width'] = "0%";
        this.animationStartTime=Game.GetGameTime();
        this.isAnimating=true;
        this.DrawFrame();
    }
    StopAnimation(){
        if (this.animationScheduler !== null) {
            $.CancelScheduled(this.animationScheduler);
            this.animationScheduler=null;
        }
        this.isAnimating=false;
        /* this.barPanel.style['width'] = "0%"; */
    }
    DrawFrame(){
        if (!this.isAnimating) {
            return;
        }
        var currentTime=Game.GetGameTime();
        var elapsed = currentTime - this.animationStartTime;
        if (this.soundTrigger===true){
            if (elapsed>=this.soundTriggerTime){
                Game.EmitSound('dark_carnival.lockpicking.pick_success');
                this.soundTrigger=false;
            }
        }
        var progress = Math.min(elapsed / this.totalTime, 1.0);
        this.barPanel.style['width'] = (progress * 100) + "%";

        if (progress >= 1.0) {
            this.StopAnimation();
            /* $.Msg('Timebar animation completed'); */
            return;
        }
        this.animationScheduler = $.Schedule(1.0 / this.fps, this.DrawFrame.bind(this));
    }
    TriggerSoundOnTime(time){
        this.soundTrigger=true;
        this.soundTriggerTime=time;
    }
    //Game.EmitSound('soundboard.frog')
}
var dynamicBarController=new timebarDynamicBar();
var textTimerController=new timebarTimer();
/* var testMark=new timebarSingleMark(2.0,"#a100e0","invoker_emp");
testMark.SetOffset(0.5) */

function PrepareTimebarDynamic(data){
    $.Msg(JSON.stringify(data));
    var totalBarTime=data.totalBarTime;
    var zoneOffset=data.zoneOffset;
    var color=data.color;
    var abilityname=data.abilityname;
    var ent1=data.ent1;
    var ent2=data.ent2;
    var speed=data.speed;
    var offset=data.offset;
    dynamicBarController.StopAnimation();
    marksTrashCan.forEach((item,index) => {
        item.RemoveSelf();
    });
    marksTrashCan=[];
    textTimerController.SetTotalTime(totalBarTime);
    dynamicBarController.SetMode("time");
    dynamicBarController.SetTotalTime(totalBarTime);
    /* dynamicBarController.TriggerSoundOnTime(zoneOffset); */
    var singleMark=new timebarSingleMark(totalBarTime,color,abilityname);
    marksTrashCan.push(singleMark);
    singleMark.SetOffset(zoneOffset);
    singleMark.SetDynamic(ent1,ent2,speed,offset);
}

function TimebarPrepareZone(data){
    $.Msg(JSON.stringify(data));
    dynamicBarController.StopAnimation();
    marksTrashCan.forEach((item,index) => {
        item.RemoveSelf();
    });
    marksTrashCan=[];
    var totalBarTime=data.totalBarTime;
    var zoneOffset=data.zoneOffset;
    if (zoneOffset<0){
        GameEvents.SendCustomGameEventToServer("announcer_request_show", {message:"#unableToTime", duration:5})
    }
    var zoneWidth=data.zoneWidth;
    textTimerController.SetTotalTime(totalBarTime);
    dynamicBarController.SetMode("time");
    dynamicBarController.SetTotalTime(totalBarTime);
    /* dynamicBarController.TriggerSoundOnTime(zoneOffset); */
    var greenZone=new timebarZone(totalBarTime);
    marksTrashCan.push(greenZone);
    greenZone.SetWidth(zoneWidth);
    greenZone.SetOffset(zoneOffset);
}

function TimebarPrepareSingleMark(data){
    dynamicBarController.StopAnimation();
    marksTrashCan.forEach((item,index) => {
        item.RemoveSelf();
    });
    marksTrashCan=[];
    var totalBarTime=data.totalBarTime;
    var zoneOffset=data.zoneOffset;
    var color=data.color;
    var abilityname=data.abilityname;
    $.Msg('[Timebar] TimebarPrepareSingleMark:');
    $.Msg('totalBarTime',totalBarTime);
    $.Msg('zoneOffset',zoneOffset);
    if (zoneOffset<0){
        GameEvents.SendCustomGameEventToServer("announcer_request_show", {message:"#unableToTime", duration:5})
    }
    $.Msg('color',color);
    $.Msg('abilityname',abilityname);
    textTimerController.SetTotalTime(totalBarTime);
    dynamicBarController.SetMode("time");
    dynamicBarController.SetTotalTime(totalBarTime);
    /* dynamicBarController.TriggerSoundOnTime(zoneOffset); */
    var singleMark=new timebarSingleMark(totalBarTime,color,abilityname);
    marksTrashCan.push(singleMark);
    singleMark.SetOffset(zoneOffset);
}
function StartTimebar(){
    dynamicBarController.StartAnimation();
}

function StopAnimation(){

}
function PlayerAction(){
    if (dynamicBar.style['width']===null){
        return
    }
    RedLine.style['horizontal-align'] = "left";
    RedLine.style['margin-left'] = dynamicBar.style['width']
    
}
function SetBlueLine(){
    if (dynamicBar.style['width']===null){
        return
    }
    BlueLine.style['horizontal-align'] = "left";
    BlueLine.style['margin-left'] = dynamicBar.style['width']
    
}
function ResetLines(){
    BlueLine.style['horizontal-align'] = "left";
    BlueLine.style['margin-left'] = "-5px;";
    RedLine.style['horizontal-align'] = "left";
    RedLine.style['margin-left'] = "-5px;";
}

function GetEntityDistance(sourceIndex, targetIndex, distanceOffset) {
    var sourcePos = Entities.GetAbsOrigin(sourceIndex);
    var targetPos = Entities.GetAbsOrigin(targetIndex);
    if (!sourcePos || !targetPos) return null;

    var dx = targetPos[0] - sourcePos[0];
    var dy = targetPos[1] - sourcePos[1];
    var dz = targetPos[2] - sourcePos[2];
    var result=Math.sqrt(dx * dx + dy * dy + dz * dz)
    /* $.Msg('result:',result)
    $.Msg('distanceOffset:',distanceOffset) */
    result=result-distanceOffset
    if (result<0){
        result=0
    }
    return result
}

GameEvents.Subscribe("timebar_prepare_dynamic", PrepareTimebarDynamic);
GameEvents.Subscribe("timebar_reset_lines", ResetLines);
GameEvents.Subscribe("timebar_blue_line", SetBlueLine);
GameEvents.Subscribe("timebar_player_action", PlayerAction);
/* GameEvents.Subscribe("timebar_prepare", PrepareTimebar);
GameEvents.Subscribe("timebar_start", StartTimebar);
GameEvents.Subscribe("timebar_stop", StopAnimation); */
GameEvents.Subscribe("timebar_start", StartTimebar);
GameEvents.Subscribe("timebar_stop", StopAnimation);
GameEvents.Subscribe("timebar_prepare_zone", TimebarPrepareZone);
GameEvents.Subscribe("timebar_prepare_single_mark", TimebarPrepareSingleMark);
GameEvents.Subscribe("timebar_hide", hideTimebar);
GameEvents.Subscribe("timebar_show", showTimebar);