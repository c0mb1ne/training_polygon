if Notifications == nil then
  Notifications = class({})
end
--TODO: add notification sound setting to settings
function Notifications:Init()


end
function Notifications:Show(strColor,strText,strIcon)
    --color can be 'green' 'red'
    --text can be whatever, but would be nice to add support of localize string
    --icon can be 'none' 'pepega' 'pogchamp' or ability icon by name, for ex: 'axe_berserkers_call'
    CustomGameEventManager:Send_ServerToAllClients("show_notification",{color=strColor,text=strText,icon=strIcon})

end
Notifications:Init()