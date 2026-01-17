notificationContainer=$('#pointer').GetParent()
var id_counter=0

function createNotification(color,text,icon){
	var id=id_counter
	id_counter+=1
	var notification=$.CreatePanel('Panel', notificationContainer, 'notify_'+id)
	notification.AddClass('NotificationPanel')
	var slashContainer=$.CreatePanel('Panel',notification,'SlashContainer')
	var teamColorBar=$.CreatePanel('Panel',slashContainer,'TeamColorBar')
	var eventLabel=$.CreatePanel('Label',notification,'EventLabel')
	eventLabel.AddClass('EventListLabel')
	if (color=='red'){
		notification.AddClass('EnemyEvent')
		Game.EmitSound("badSnd")
	}
	if (color=='green'){
		notification.AddClass('AllyEvent')
		Game.EmitSound("goodSnd")
	}
	eventLabel.text=text
	if (icon!='none'){
		if (icon=='pogchamp'){
			eventLabel.AddClass('Skilled')
			var skillIcon=$.CreatePanel('Panel',eventLabel,'notifyIcon')
			skillIcon.AddClass('pogChamp')
		
		}else{
			if (icon=='pepega'){
				eventLabel.AddClass('Skilled')
				var skillIcon=$.CreatePanel('Panel',eventLabel,'notifyIcon')
				skillIcon.AddClass('pepega')
		
			}else{
				eventLabel.AddClass('Skilled')
				var skillIcon=$.CreatePanel('DOTAAbilityImage',eventLabel,'notifyIcon')
				skillIcon.abilityname=icon
				skillIcon.AddClass('skillIcon')
			}
			
		}
		
	}
	notification.AddClass('NotPanelAnimate')
	$.Schedule(8, function(){ hideNotification(notification);})
	if (id>19){
		var trashId=id-20
		$('#notify_'+trashId).DeleteAsync(2)
	}
}
function hideNotification(panel){
	panel.AddClass('NotificationCollapse')
}
function showNotification(panel){
	panel.RemoveClass('NotificationCollapse')
}
function showNotify(data){
	createNotification(data.color,data.text,data.icon)
}

 GameEvents.Subscribe("show_notification", showNotify);