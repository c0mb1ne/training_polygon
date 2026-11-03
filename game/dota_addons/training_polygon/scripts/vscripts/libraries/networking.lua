if Networking == nil then
  Networking = class({})
end
require('libraries/http_relay')
local dedic_key=GetDedicatedServerKeyV3( "sq@#dfqs" )
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

--json.decode throws on nil/invalid bodies; inside HTTP callbacks that becomes "error in error handling", so decode defensively
local function safeDecode(body)
    if type(body) ~= "string" or body == "" then return nil end
    local ok, result = pcall(json.decode, body)
    if ok and type(result) == "table" then return result end
    return nil
end

function Networking:Init()
  self.serverAdress="https://combine.isgood.host/"
  self.secretKey=generateRandomString(8)
  self.steamId=nil
  self.pollSecret=nil
  self.authKey=nil
  self.loginUrl=nil
  self.loggingEnabled=true
  self.loginState=""
  self.clientLanguage=""
  self.forceRelay=true --set true to always use the client http relay (testing in tools mode); false = native http when available
  --[[ self.devSecret="67e54aqweqweqwece7e1f927c0437dd59997b" ]]
  CustomGameEventManager:RegisterListener("init_user", function(_, args)
      --errors inside C-invoked listeners surface as "error in error handling" in non-tools mode, so catch and print them explicitly
      local ok, err = xpcall(function()
        Networking.steamId=tostring(PlayerResource:GetSteamID(0))
        Networking:InitUser(args)
      end, function(e) return tostring(e) end)
      if not ok then
        print("[Networking] error in init_user listener: "..tostring(err))
      end
      --[[ Networking:GetUserConfig(steam) ]]
  end)
  CustomGameEventManager:RegisterListener("get_leaderboard", function(_, args)
      Networking:GetLeaderboard(args)
  end)
  CustomGameEventManager:RegisterListener("get_login_state", function(_, args)
      Networking:LoginState()
  end)
  CustomGameEventManager:RegisterListener("start_login", function(_, args)
      Networking:StartLogin()
  end)
  CustomGameEventManager:RegisterListener("start_polling", function(_, args)
      Networking:StartPolling()
  end)
  CustomGameEventManager:RegisterListener("get_login_link", function(_, args)
      Networking:LoginUrlSet()
  end)
  --[[ CustomGameEventManager:RegisterListener("init_user", Dynamic_Wrap(Networking, "InitUser")) ]]
end

function Networking:StartPolling()
  local route="auth/status?steamid="..self.steamId.."&key="..self.secretKey
  self:MakeRequest("poll",route,nil,"handlePoll",'GET')
end

function Networking:handlePoll(body)
  --[[ print('poll response:',body) ]]
  local response=safeDecode(body)
  if response==nil then
    print("[Networking] handlePoll: bad body:",tostring(body))
    return
  end
  if response.status=="pending" then
    Timers:CreateTimer(2,function()
      self:StartPolling()
    end)
  end
  if response.status=="ok" then
    self.authKey=response.token
    --do something on ui
    self.loginState="login_done"
    CustomGameEventManager:Send_ServerToAllClients("login_done",{})
    --let interested libraries know the auth key is ready (settings sync etc.)
    if UserConfig~=nil and UserConfig.OnAuthenticated~=nil then
      UserConfig:OnAuthenticated()
    end
  end
end
function Networking:LoginState()
  CustomGameEventManager:Send_ServerToAllClients("login_state",{state=self.loginState})

end
function Networking:InitUser(args)
  local route="auth/init"
  local language=args['data']['language']
  self.clientLanguage=language
  local map_name=GetMapName()
  local body=json.encode({steamid=self.steamId,key=self.secretKey,language=language,version=TP_VERSION,map=map_name})
  --[[ DeepPrintTable(args) ]]
  self:MakeRequest(body,route,nil,"handleInit")
end
function Networking:LoginUrlSet(args)
  if self.loginUrl~=nil then
    self.loginState="link_ready"
    CustomGameEventManager:Send_ServerToAllClients("login_link_set",{link=self.loginUrl})
  end
end
function Networking:handleInit(body)
  --[[ print('handling init')
  print('init response:',body) ]]
  local responseJson=safeDecode(body)
  if responseJson==nil then
    print("[Networking] handleInit: bad body:",tostring(body))
    return
  end
  if responseJson.version then
    if responseJson.version~=TP_VERSION then
      CustomGameEventManager:Send_ServerToAllClients("update_required",{new_version=responseJson.version})
    end
    self.loginState="server_alive"
    CustomGameEventManager:Send_ServerToAllClients("server_alive",{})
  end
  
end

function Networking:StartLogin()
  local route="auth/start"
  local language=self.clientLanguage
  local body=json.encode({steamid=self.steamId,key=self.secretKey,language=language})
  self:MakeRequest(body,route,nil,"handleLogin")
end

function Networking:handleLogin(body)
  --[[ print('handling init')
  print('init response:',body) ]]
  local responseJson=safeDecode(body)
  if responseJson==nil then
    print("[Networking] handleLogin: bad body:",tostring(body))
    return
  end
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

  --shared header/body setup for both transports
  local headers={}
  if self.authKey~=nil then
    headers["X-Auth-Key"]=self.authKey
  end
  if self.steamId~=nil then
    headers["X-Steam-Id"]=self.steamId
  end
  if data=="poll" and self.pollSecret~=nil then
    headers["X-Poll-Secret"]=self.pollSecret
  end
  --[[ headers["Dev-Secret"]=self.devSecret ]]
  local params=nil
  local body=nil
  if type(data) == "table" then
    params=data
    for k,v in pairs(data) do
      print(k,v)
      self:DebugLog("Parameters of request: "..tostring(k)..":"..tostring(v))
    end
  elseif data~=nil then
    body=data
    self:DebugLog("Body of request: "..data)
  end

  local function onResponse(res)
    --errors inside HTTP callbacks surface as "error in error handling" in non-tools mode, so catch and print them explicitly
    local ok, err = xpcall(function()
      if (res.StatusCode or 0)==0 then
        --total transport failure (relay timeout etc.): tell the ui
        self.loginState="server_unreachable"
        CustomGameEventManager:Send_ServerToAllClients("server_unreachable",{})
      end
      if res.StatusCode ~= 200 then
        self:DebugLog("Failed to contact server")
        self:DebugLog("Status Code:"..tostring(res.StatusCode))
        self:DebugLog("Body:"..tostring(res.Body))
      else
        self:DebugLog("Connected to backend server "..tostring(res.StatusCode))
        self:DebugLog("Body:"..tostring(res.Body))
        if jsCallback then
            CustomGameEventManager:Send_ServerToAllClients(jsCallback,{data=res.Body})
        end
        if networkingCallback then
          --accepts either a method name on Networking or a plain function
          if type(networkingCallback)=="function" then
            networkingCallback(res.Body)
          else
            self[networkingCallback](self, res.Body)
          end
        end
      end
      if not res.Body then
        self:DebugLog("No result returned from server")
        self:DebugLog("Status Code:"..tostring(res.StatusCode))
      end
    end, function(e) return tostring(e) end)
    if not ok then
      print("[Networking] callback error on route "..tostring(route)..": "..tostring(err))
    end
  end

  local req = CreateHTTPRequestScriptVM(reqType, self.serverAdress..route)
  if _G.TP_FORCE_HTTP_RELAY or self.forceRelay then
    req=nil --testing: pretend native http is unavailable so the relay path runs
  end
  if req~=nil then
    --native transport (tools mode / raw listen server)
    for k,v in pairs(headers) do
      req:SetHTTPRequestHeaderValue(k,v)
    end
    if params~=nil then
      for k,v in pairs(params) do
        req:SetHTTPRequestGetOrPostParameter(tostring(k),tostring(v))
      end
    elseif body~=nil then
      req:SetHTTPRequestRawPostBody("application/json",body)
    end
    req:Send(onResponse)
  else
    --relay transport (lobby-hosted games): the client's Panorama bridge executes the request
    print("[Networking] native http unavailable, relaying via client: "..tostring(route))
    self:DebugLog("Native http unavailable, using client relay")
    local relayBody=body
    if params~=nil then
      --form-encode params like the native POST does (lua side has no urlencode, so inline it)
      local parts={}
      for k,v in pairs(params) do
        local ev=string.gsub(tostring(v),"([^%w%-%_%.%~])",function(c) return string.format("%%%02X",string.byte(c)) end)
        table.insert(parts,tostring(k).."="..ev)
      end
      relayBody=table.concat(parts,"&")
      headers["Content-Type"]="application/x-www-form-urlencoded"
    elseif relayBody~=nil then
      --raw json body (auth/init etc.): flask needs the content type to parse it
      headers["Content-Type"]="application/json"
    end
    HttpRelay:Send(reqType,self.serverAdress..route,headers,relayBody,onResponse)
  end
end

Networking:Init()