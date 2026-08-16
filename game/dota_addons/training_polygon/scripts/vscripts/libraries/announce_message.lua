--[[
	class for showing announce messages at the top of the screen, launchable
	from server Lua directly or from client JS (through custom game events)

	Place at: game/scripts/vscripts/announcer.lua
	Require it once from your addon_game_mode.lua:

		require('announcer')

	Usage from anywhere in server Lua:
		announcer:Show({message="Roshan has spawned!", duration=5})   -- auto-hides after 5s
		announcer:Show({message="Draft phase"})                       -- stays until Hide() is called
		announcer:Hide({})

	Usage from client JS (see announcer.js):
		GameEvents.SendCustomGameEventToServer("announcer_request_show", {message="GG", duration=5})
		GameEvents.SendCustomGameEventToServer("announcer_request_hide", {})
]]

if announcer == nil then
	announcer = class({})
end

function announcer:Init()
	CustomGameEventManager:RegisterListener("announcer_request_show", Dynamic_Wrap(announcer, "Show"))
	CustomGameEventManager:RegisterListener("announcer_request_hide", Dynamic_Wrap(announcer, "Hide"))
end

-- args.message: string to display
-- args.duration: seconds before auto-hide, omit/<=0 to stay until Hide() is called
function announcer:Show(args)
	CustomGameEventManager:Send_ServerToAllClients("announcer_show_message", {
		message = args['message'],
		duration = tonumber(args['duration']) or -1
	})
end

function announcer:Hide(args)
	CustomGameEventManager:Send_ServerToAllClients("announcer_hide_message", {})
end

announcer:Init()