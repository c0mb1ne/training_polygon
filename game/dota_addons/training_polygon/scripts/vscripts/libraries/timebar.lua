if Timebar == nil then
    Timebar = class({})
end

function Timebar:Init()
    CustomGameEventManager:RegisterListener("timebar_show", Dynamic_Wrap(Timebar, "Show"))
    CustomGameEventManager:RegisterListener("timebar_show", Dynamic_Wrap(Timebar, "Hide"))
    CustomGameEventManager:RegisterListener("timebar_start", Dynamic_Wrap(Timebar, "Start"))
    CustomGameEventManager:RegisterListener("timebar_stop", Dynamic_Wrap(Timebar, "Stop"))
end

function Timebar:PrepareZone(totalBarTime,zoneOffset,zoneWidth)
    --[[ print('timebar prepare') ]]
    CustomGameEventManager:Send_ServerToAllClients("timebar_prepare_zone", {
        totalBarTime = totalBarTime,
        zoneOffset = zoneOffset,
        zoneWidth = zoneWidth
    })
end
function Timebar:PrepareSingleMark(totalBarTime,zoneOffset,color,abilityname)
    CustomGameEventManager:Send_ServerToAllClients("timebar_prepare_single_mark", {
        totalBarTime = totalBarTime,
        zoneOffset = zoneOffset,
        color = color,
        abilityname = abilityname
    })
end
function Timebar:PrepareDynamic(totalBarTime,zoneOffset,color,abilityname,ent1,ent2,speed,offset)
    --[[ print('timebar prepare dynamic') ]]
    CustomGameEventManager:Send_ServerToAllClients("timebar_prepare_dynamic", {
        totalBarTime = totalBarTime,               -- time from timebar start to projectile launch
        zoneOffset = zoneOffset,      -- time of greenzone
        color = color,              -- optional, can omit or set to 0, pads bar after impact
        abilityname = abilityname,              -- if greenzone needs time offset
        ent1 = ent1:entindex(),
        ent2 = ent2:entindex(),
        speed = speed,
        offset = offset --offset from hull sizes and projectile width
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
function Timebar:ResetLines()
    CustomGameEventManager:Send_ServerToAllClients("timebar_reset_lines", {})
end
Timebar:Init()