if Timebar == nil then
    Timebar = class({})
end

function Timebar:Init()
    CustomGameEventManager:RegisterListener("timebar_prepare", Dynamic_Wrap(Timebar, "Prepare"))
    CustomGameEventManager:RegisterListener("timebar_show", Dynamic_Wrap(Timebar, "Show"))
    CustomGameEventManager:RegisterListener("timebar_show", Dynamic_Wrap(Timebar, "Hide"))
    CustomGameEventManager:RegisterListener("timebar_start", Dynamic_Wrap(Timebar, "Start"))
    CustomGameEventManager:RegisterListener("timebar_stop", Dynamic_Wrap(Timebar, "Stop"))
end

function Timebar:Prepare(castTime,greenZoneTime,extraTime,castPoint)
    --[[ print('timebar prepare') ]]
    CustomGameEventManager:Send_ServerToAllClients("timebar_prepare", {
        castTime = castTime,
        greenZoneTime = greenZoneTime,
        extraTime = extraTime,  -- optional, can omit or set to 0
        castPoint = castPoint
    })
end
function Timebar:Show()
    CustomGameEventManager:Send_ServerToAllClients("timebar_show", {})
end
function Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("timebar_hide", {})
end
function Timebar:Start()
    CustomGameEventManager:Send_ServerToAllClients("timebar_start", {})
end
function Timebar:Stop()
    CustomGameEventManager:Send_ServerToAllClients("timebar_stop", {})
end
function Timebar:PlayerAction()
    CustomGameEventManager:Send_ServerToAllClients("timebar_player_action", {})
end
function Timebar:BlueLine()
    CustomGameEventManager:Send_ServerToAllClients("timebar_blue_line", {})
end
Timebar:Init()