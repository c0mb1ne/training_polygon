if Networking == nil then
  Networking = class({})
end

function Networking:Init()
  self.serverAdress="https://combine.isgood.host/"
  self.secretKey=GetDedicatedServerKeyV3('qweqwe')

  self.devSecret="67e54aqweqweqw7ce7e1f927c0437dd59997b"
  CustomGameEventManager:RegisterListener("init_user", function(_, args)
      Networking:InitUser(args)
  end)
  CustomGameEventManager:RegisterListener("get_leaderboard", function(_, args)
      Networking:GetLeaderboard(args)
  end)
  --[[ CustomGameEventManager:RegisterListener("init_user", Dynamic_Wrap(Networking, "InitUser")) ]]
end

function Networking:InitUser(args)
  DeepPrintTable(args)
  self:MakeRequest(args['data'],args['route'])
end

function Networking:GetLeaderboard(args)
  local route='get_leaderboard'
  self:MakeRequest(args['data'],route,'leaderboard_response')
end

function Networking:DebugLog(data)
    CustomGameEventManager:Send_ServerToAllClients("debug_output",{text=data})
end

function Networking:GetUserConfig(steam)
  local route='get_config'
  print('making request to:',self.serverAdress..route)
  local req = CreateHTTPRequestScriptVM('POST', self.serverAdress..route)
  req:SetHTTPRequestHeaderValue("Auth-Token", self.secretKey)
  req:SetHTTPRequestHeaderValue("Dev-Secret", self.devSecret)
  req:SetHTTPRequestGetOrPostParameter('steam',tostring(steam))
  req:Send(function(res)
    if res.StatusCode ~= 200 then
      self:DebugLog("Failed to contact server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
      self:DebugLog("Body:".. (res.Body or "nil"))
    else
      self:DebugLog("Connected to leaderboard server "..res.StatusCode)
      self:DebugLog("Body:".. (res.Body or "nil"))
      if res.Body=="no config" or res.Body==nil then
        PLAYER_CONFIG="no config"
      else
        PLAYER_CONFIG=json.decode(res.Body)
      end
    end
    if not res.Body then
      self:DebugLog("No result returned from server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
    end
  end)
end

function Networking:RefreshConfig()
  local encoded_config=json.encode(PLAYER_CONFIG)
  local route='refresh_config'
  local steam=PlayerResource:GetSteamID(0)
  print('making request to:',self.serverAdress..route)
  local req = CreateHTTPRequestScriptVM('POST', self.serverAdress..route)
  req:SetHTTPRequestHeaderValue("Auth-Token", self.secretKey)
  req:SetHTTPRequestHeaderValue("Dev-Secret", self.devSecret)
  req:SetHTTPRequestGetOrPostParameter('steam',tostring(steam))
  req:SetHTTPRequestGetOrPostParameter('config',encoded_config)
  req:Send(function(res)
    if res.StatusCode ~= 200 then
      self:DebugLog("Failed to contact server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
      self:DebugLog("Body:".. (res.Body or "nil"))
    else
      self:DebugLog("Connected to leaderboard server "..res.StatusCode)
      self:DebugLog("Body:".. (res.Body or "nil"))
      --[[ if res.Body=="no config" or res.Body==nil then
        PLAYER_CONFIG="no config"
      else
        PLAYER_CONFIG=json.decode(res.Body)
      end ]]
    end
    if not res.Body then
      self:DebugLog("No result returned from server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
    end
  end)
end

function Networking:SendChallengeResult(mode,steam,score,other,log_id,ping)
  local result={}
  result['mode']=mode
  result['steam']=tostring(steam)
  result['score']=score
  result['other']=other
  local result_to_send=json.encode(result)
  local parameters={data=result_to_send,ping=ping,log_id=log_id}
  self:MakeRequest(parameters,"send_result","result_popup")
end

function Networking:MakeRequest(data,route,jsCallback)
  print('making request to:',self.serverAdress..route)
  local req = CreateHTTPRequestScriptVM('POST', self.serverAdress..route)
  req:SetHTTPRequestHeaderValue("Auth-Token", self.secretKey)
  req:SetHTTPRequestHeaderValue("Dev-Secret", self.devSecret)
  for k,v in pairs(data) do
    print(k,v)
    req:SetHTTPRequestGetOrPostParameter(tostring(k),tostring(v))
  end
  req:Send(function(res)
    if res.StatusCode ~= 200 then
      self:DebugLog("Failed to contact server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
      self:DebugLog("Body:".. (res.Body or "nil"))
    else
      self:DebugLog("Connected to leaderboard server "..res.StatusCode)
      self:DebugLog("Body:".. (res.Body or "nil"))
      if jsCallback then
          CustomGameEventManager:Send_ServerToAllClients(jsCallback,{data=res.Body})
      end
    end
    if not res.Body then
      self:DebugLog("No result returned from server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
    end
  end)
end

Networking:Init()