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
var error=0.075//some magical offset
// Prepare the timebar with cast time and green zone parameters
function PrepareTimebar(data) {
    var castTime=data.castTime
    var greenZoneTime=data.greenZoneTime
    var extraTime=data.extraTime
    var castPoint=data.castPoint
    extraTime = extraTime || 0;
    
    // Stop any ongoing animation
    StopAnimation();
    
    // Calculate total duration and green zone position
    animationDuration = castTime + extraTime;
    var damageTime = castTime+error; // Damage happens at the end of cast time
    
    // Green zone is centered around damage time
    /* greenZoneStart = damageTime - (greenZoneTime / 2); */
    greenZoneStart = damageTime-castPoint-greenZoneTime;
    greenZoneWidth = greenZoneTime;
    
    // Reset dynamic bar to start position
    dynamicBar.style['width'] = "0%";
    
    // Position green zone
    var greenZoneStartPercent = (greenZoneStart / animationDuration) * 100;
    var greenZoneWidthPercent = (greenZoneWidth / animationDuration) * 100;
    
    greenZone.style['horizontal-align'] = "left";
    greenZone.style['margin-left'] = greenZoneStartPercent + "%"; 
    greenZone.style['width'] = greenZoneWidthPercent + "%";
    
    // Update time label
    TimeLabel.text = animationDuration.toFixed(3);
    
    $.Msg('Timebar prepared: Duration=' + animationDuration + 's, GreenZone=' + greenZoneStart + 's to ' + (greenZoneStart + greenZoneWidth) + 's');
}

// Start the timebar animation
function StartTimebar() {
    // Stop any ongoing animation first
    StopAnimation();
    
    if (animationDuration <= 0) {
        $.Msg('Error: Call PrepareTimebar first!');
        return;
    }
    
    isAnimating = true;
    animationStartTime = Game.GetGameTime();
    
    $.Msg('Timebar animation started');
    
    // Start animation loop
    AnimateBar();
}

// Animation loop
function AnimateBar() {
    if (!isAnimating) {
        return;
    }
    
    var currentTime = Game.GetGameTime();
    var elapsed = currentTime - animationStartTime;
    var progress = Math.min(elapsed / animationDuration, 1.0);
    
    // Update dynamic bar width
    dynamicBar.style['width'] = (progress * 100) + "%";
    
    // Update time label
    var remainingTime = Math.max(0, animationDuration - elapsed);
    TimeLabel.text = remainingTime.toFixed(3);
    
    // Check if animation is complete
    if (progress >= 1.0) {
        StopAnimation();
        $.Msg('Timebar animation completed');
        return;
    }
    
    // Schedule next frame
    animationSchedule = $.Schedule(1.0 / fps, AnimateBar);
}

// Stop the animation
function StopAnimation() {
    if (animationSchedule !== null) {
        $.CancelScheduled(animationSchedule);
        animationSchedule = null;
    }
    isAnimating = false;
}
function PlayerAction(){
    RedLine.style['horizontal-align'] = "left";
    RedLine.style['margin-left'] = dynamicBar.style['width']
    
}
function SetBlueLine(){
    BlueLine.style['horizontal-align'] = "left";
    BlueLine.style['margin-left'] = dynamicBar.style['width']
    
}
GameEvents.Subscribe("timebar_blue_line", SetBlueLine);
GameEvents.Subscribe("timebar_player_action", PlayerAction);
GameEvents.Subscribe("timebar_prepare", PrepareTimebar);
GameEvents.Subscribe("timebar_start", StartTimebar);
GameEvents.Subscribe("timebar_stop", StopAnimation);
GameEvents.Subscribe("timebar_hide", hideTimebar);
GameEvents.Subscribe("timebar_show", showTimebar);