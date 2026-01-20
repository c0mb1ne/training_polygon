--my try to take mouse logs when people play aim challenges to make an anticheat system. logging works, but after one week it made 5 gigs of logs
if action_logging == nil then
  action_logging = class({})
end
MAX_PARTS=5
CURRENT_PART=1
function action_logging:Init()
  self.active=false
  self.log=nil
  self.steam=nil
  self.unique_id=nil
  self.mode=nil
end

function action_logging:OrderExecuted(event)
  if self.active then
    --DeepPrintTable(event)
    if event['order_type']==6 then
      local orderPos=EntIndexToHScript(event['entindex_target']):GetAbsOrigin()
      CustomGameEventManager:Send_ServerToAllClients("logger_order_pos",{position=orderPos})
    end
    if event['order_type']==5 then
      local orderPos=Vector(event['position_x'],event['position_y'],event['position_z'])
      CustomGameEventManager:Send_ServerToAllClients("logger_order_pos",{position=orderPos})
    end
  end
end
function action_logging:SetMode(mode)
  self.mode=mode
end
function action_logging:SetSteam(steam)
  self.steam=steam
end
function action_logging:SetID(stringID)
  self.unique_id=stringID
end
function action_logging:StartLogging()
  self.active=true
  CustomGameEventManager:Send_ServerToAllClients("logger_start",{})

end

function action_logging:StopLogging()
  self.active=false
  CustomGameEventManager:Send_ServerToAllClients("logger_stop",{})

end

function action_logging:GetLog()

  return self.log
end

function action_logging:SetLog(log)
  print('saving log in logger')
  --self.log=log
  local log_encoded=json.encode(log)
  local log_splited=splitString(log_encoded, 5)
  print('log len:',string.len(log_encoded))
  print('sending log with parameters:',self.steam,self.unique_id,self.mode)
  sendLogToServer(log_splited,self.steam,self.unique_id,self.mode,CURRENT_PART)
end

function action_logging:SaveLog()
  print('asking panorama to get log')
  CustomGameEventManager:Send_ServerToAllClients("logger_get_log",{})
end

function LogReciever( eventSourceIndex, args )
  print('recieved log from panorama')
  action_logging:SetLog(args['log'])

end

function splitString(inputStr, numParts)
  local strLength = string.len(inputStr)
  local partLength = math.ceil(strLength / numParts)
  local parts = {}

  for i = 1, numParts do
      local startPos = (i - 1) * partLength + 1
      local endPos = math.min(i * partLength, strLength)
      local part = string.sub(inputStr, startPos, endPos)
      table.insert(parts, part)
  end

  return parts
end

function sendLogToServer(log,steam,log_id,mode,part)
  print('sending mouse log')
  local req = CreateHTTPRequestScriptVM('POST', CMB_SERVER.."mouse_log.php")
  local key=GetDedicatedServerKeyV2('dick')
  req:SetHTTPRequestGetOrPostParameter("request","sendLog")
  req:SetHTTPRequestHeaderValue("Auth-Token", key)
  req:SetHTTPRequestGetOrPostParameter("steam", steam)
  req:SetHTTPRequestGetOrPostParameter("mode", mode)
  req:SetHTTPRequestGetOrPostParameter("log_id", log_id)
  req:SetHTTPRequestGetOrPostParameter("log", log[CURRENT_PART])
  req:SetHTTPRequestGetOrPostParameter("part", tostring(part))
  --[[$steamdb=$_POST['steam'];
  $modedb=$_POST['mode'];
  $lbid=$_POST['log_id'];
  $log=$_POST['log'];--]]
  req:Send(function(res)
    if res.StatusCode ~= 200 then
      my_output("Failed to contact server")
      my_output("Status Code:".. (res.StatusCode or "nil"))
      my_output("Body:".. (res.Body or "nil"))
    else
      my_output("part"..tostring(CURRENT_PART).." sent "..res.StatusCode)
      my_output("Body:".. (res.Body or "nil"))
    end
    CURRENT_PART=CURRENT_PART+1
    if CURRENT_PART<=MAX_PARTS then
      --sendLogToServer(log,steam,log_id,mode,CURRENT_PART)
    else
      CURRENT_PART=1
    end

  end)
end

CustomGameEventManager:RegisterListener( "logger_send_log", LogReciever )