-- Usage: DebugVar("gold", 123)
-- Make sure this file is loaded (e.g. require("debug_var") in addon_game_mode.lua)
function DebugVar(key, value)
    CustomGameEventManager:Send_ServerToAllClients("send_debug_var", {
        key = tostring(key),
        value = tostring(value),
    })
end

function DebugPanelShow()
    CustomGameEventManager:Send_ServerToAllClients("debug_panel_show", {})
end

function DebugPanelHide()
    CustomGameEventManager:Send_ServerToAllClients("debug_panel_hide", {})
end

