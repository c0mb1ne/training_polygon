if Networking == nil then
  Networking = class({})
end

local function generateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local charsetLength = string.len(charset)
    local result = {}

    for i = 1, length do
        local randomIndex = RandomInt(1, charsetLength)
        result[i] = string.sub(charset, randomIndex, randomIndex)
    end

    return table.concat(result)
end

function Networking:Init()
  self.serverAdress="https://combine.isgood.host/"
  self.secretKey=generateRandomString(8)
  self.steamId=nil
  self.pollSecret=nil
  self.authKey=nil
  self.loginUrl=nil
  self.loggingEnabled=false
  --[[ self.devSecret="67e54aqweqweqwece7e1f927c0437dd59997b" ]]
  CustomGameEventManager:RegisterListener("init_user", function(_, args)
      
      local cmdPlayer=PlayerResource:GetPlayer(0)
      Networking.steamId=tostring(PlayerResource:GetSteamID(cmdPlayer:GetPlayerID()))
      Networking:InitUser(args)
      --[[ Networking:GetUserConfig(steam) ]]
  end)
  CustomGameEventManager:RegisterListener("get_leaderboard", function(_, args)
      Networking:GetLeaderboard(args)
  end)
  CustomGameEventManager:RegisterListener("get_login_url", function(_, args)
      Networking:LoginUrlSet(args)
  end)
  CustomGameEventManager:RegisterListener("start_polling", function(_, args)
      Networking:StartPolling()
  end)
  --[[ CustomGameEventManager:RegisterListener("init_user", Dynamic_Wrap(Networking, "InitUser")) ]]
end

function Networking:StartPolling()
  local route="auth/status?steamid="..self.steamId.."&key="..self.secretKey
  self:MakeRequest("poll",route,nil,"handlePoll",'GET')
end

function Networking:handlePoll(body)
  --[[ print('poll response:',body) ]]
  local response=json.decode(body)
  if response.status=="pending" then
    Timers:CreateTimer(2,function()
      self:StartPolling()
    end)
  end
  if response.status=="ok" then
    self.authKey=response.token
    --do something on ui
    CustomGameEventManager:Send_ServerToAllClients("login_done",{})
  end
end

function Networking:InitUser(args)
  local route="auth/init"
  local language=args['data']['language']
  local body=json.encode({steamid=self.steamId,key=self.secretKey,language=language})
  --[[ DeepPrintTable(args) ]]
  self:MakeRequest(body,route,nil,"handleInit")
end
function Networking:LoginUrlSet(args)
  if self.loginUrl~=nil then
    CustomGameEventManager:Send_ServerToAllClients("login_link_set",{link=self.loginUrl})
  end
end
function Networking:handleInit(body)
  --[[ print('handling init')
  print('init response:',body) ]]
  local responseJson=json.decode(body)
  if responseJson.poll_secret then
    self.pollSecret=responseJson.poll_secret
  else
    print('no secret, body:',body)
    return
  end
  if responseJson.link then
    self.loginUrl=responseJson.link
  else
    print('no url, body:',body)
    return
  end
  self:LoginUrlSet()
  self:StartPolling()
end

function Networking:GetLeaderboard(args)
  local route='get_leaderboard'
  self:MakeRequest(args['data'],route,'leaderboard_response')
end

function Networking:DebugLog(data)
  if self.loggingEnabled then
    CustomGameEventManager:Send_ServerToAllClients("debug_output",{text=data})
  end
end

function Networking:GetUserConfig(steam)
  local route='get_config'
  print('making request to:',self.serverAdress..route)
  local req = CreateHTTPRequestScriptVM('POST', self.serverAdress..route)
  req:SetHTTPRequestHeaderValue("Auth-Token", self.secretKey)
  --[[ req:SetHTTPRequestHeaderValue("Dev-Secret", self.devSecret) ]]
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
  --[[ req:SetHTTPRequestHeaderValue("Dev-Secret", self.devSecret) ]]
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

function Networking:MakeRequest(data,route,jsCallback,networkingCallback,reqType)
  if not reqType then
    reqType='POST'
  end
  self:DebugLog("Making request to: "..self.serverAdress..route)
  local req = CreateHTTPRequestScriptVM(reqType, self.serverAdress..route)
  if self.authKey~=nil then
    req:SetHTTPRequestHeaderValue("X-Auth-Key", self.authKey)
  end
  req:SetHTTPRequestHeaderValue("X-Steam-Id", self.steamId)
  if data=="poll" then
    req:SetHTTPRequestHeaderValue("X-Poll-Secret", self.pollSecret)
  end
  --[[ req:SetHTTPRequestHeaderValue("Dev-Secret", self.devSecret) ]]
  if type(data) == "table" then
    for k,v in pairs(data) do
      print(k,v)
      req:SetHTTPRequestGetOrPostParameter(tostring(k),tostring(v))
      self:DebugLog("Parameters of request: "..tostring(k)..":"..tostring(v))
    end
  else
    req:SetHTTPRequestRawPostBody("application/json",data)
    self:DebugLog("Body of request: "..data)
  end
  req:Send(function(res)
    if res.StatusCode ~= 200 then
      self:DebugLog("Failed to contact server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
      self:DebugLog("Body:".. (res.Body or "nil"))
    else
      self:DebugLog("Connected to backend server "..res.StatusCode)
      self:DebugLog("Body:".. (res.Body or "nil"))
      if jsCallback then
          CustomGameEventManager:Send_ServerToAllClients(jsCallback,{data=res.Body})
      end
      if networkingCallback then
        self[networkingCallback](self, res.Body)
      end
    end
    if not res.Body then
      self:DebugLog("No result returned from server")
      self:DebugLog("Status Code:".. (res.StatusCode or "nil"))
    end
  end)
end

Networking:Init()