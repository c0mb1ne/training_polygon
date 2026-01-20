--class for getting ping from client. ping_reader.js just getting it from ui
--used for leaderboard display of ping
if ping_reader == nil then
  ping_reader = class({})
end

function ping_reader:Init()
  self.ping=0

end

function ping_reader:SetPing(ping)
  self.ping=ping

end
function ping_reader:GetPing()
  return self.ping

end

function store_ping( eventSourceIndex, args )
  local ping_from_ui=args['ping']
  --CustomGameEventManager:Send_ServerToAllClients("send_nudes",{nudes=ping_from_ui})
  --print(math.floor((Time()-args['ping'])*1000))
  --print((Time()-args['ping'])*1000)

  --ping_reader:SetPing(math.floor((Time()-args['ping'])*1000))
  --print("ping:",ping_from_ui)
  ping_reader:SetPing(ping_from_ui)
end




CustomGameEventManager:RegisterListener( "store_ping", store_ping )