--UserConfig: per-user settings store (general + per-gamemode), synced to the backend.
--
--usage:
--  UserConfig:RegisterDefaults("general", "notif_good_sound", "frog")  --or scope = mode name, e.g. "dodge"
--  UserConfig:Get("dodge", "camera_shake")
--  UserConfig:Set("dodge", "camera_shake", false)                      --server-side change, debounce-saved too
--  UserConfig:Watch("dodge", "camera_shake", function(value) ... end)  --react to client changes and loaded values
--
--client flow: ui asks with "user_config_get", receives "user_config_load" {data={general={...},modes={...}}},
--and pushes changes with "user_config_set" {scope=..., key=..., value=...}.
--sync to the backend starts only after the login flow finished and Networking has
--an auth key (Networking calls UserConfig:OnAuthenticated); before that all changes
--are kept locally and pushed once the auth key arrives.
--
--wire format (compact): authentication is the X-Auth-Key header that Networking adds
--to every request after login, so no steamid/key travels in the body. only dirty
--keys are pushed, as a flat map with short dotted paths: g.<key> for general
--settings, m.<mode>.<key> for gamemode settings, booleans encoded as 0/1. the
--backend merges this map into the player's stored document, so a typical save is
--a couple hundred bytes at most. load returns the same flat map.
if UserConfig == nil then
  UserConfig = class({})
end


local SAVE_DEBOUNCE=7 --seconds of quiet after the last change before pushing to the server
local GET_ROUTE='get_user_settings'
local SAVE_ROUTE='save_user_settings'
local LOAD_FALLBACK_TIMEOUT=8 --if the backend never answers, unlock with defaults

function UserConfig:Init()
  --{ general = {key=value,...}, modes = { dodge = {...}, timing = {...} } }
  self.defaults={ general={}, modes={} }
  self.data={ general={}, modes={} }
  self.dirty={} --flat "g.key" / "m.mode.key" -> value, only what changed since the last push
  self.watchers={} --"scope.key" -> {callback,...}
  self.saveTimer=nil
  self.loaded=false
  self.loadRequested=false

  CustomGameEventManager:RegisterListener("user_config_set", function(_, event)
    --errors inside C-invoked listeners surface as "error in error handling", so catch and print them explicitly
    local ok, err = xpcall(function()
      UserConfig:OnClientSet(event)
    end, function(e) return tostring(e) end)
    if not ok then
      print("[UserConfig] error in user_config_set listener: "..tostring(err))
    end
  end)
  CustomGameEventManager:RegisterListener("user_config_get", function(_, event)
    UserConfig:SendToClient()
  end)
  --no init_user listener here on purpose: loading the config right at game start
  --races the login flow (extra http request while auth/polling is in flight).
  --Networking calls UserConfig:OnAuthenticated() once the auth key is ready instead.
end

--called by Networking when the login flow finished and the auth key is ready
function UserConfig:OnAuthenticated()
  self:RequestLoad()
end

--scope is "general" or a gamemode name; returns the bucket for it (creates unless noCreate)
function UserConfig:Bucket(t,scope,noCreate)
  if scope=="general" then return t.general end
  if t.modes[scope]==nil and not noCreate then
    t.modes[scope]={}
  end
  return t.modes[scope]
end

function UserConfig:FlatKey(scope,key)
  if scope=="general" then return "g."..key end
  return "m."..scope.."."..key
end

function UserConfig:ParseFlatKey(flatKey)
  local mode,key=string.match(flatKey,"^m%.([^.]+)%.(.+)$")
  if mode then return mode,key end
  local generalKey=string.match(flatKey,"^g%.([^.]+)$")
  if generalKey then return "general",generalKey end
  return nil,nil
end

--register a known setting with its default; saved values only apply to registered keys,
--so renaming/removing a setting in a new version can never load garbage
function UserConfig:RegisterDefaults(scope,key,defaultValue)
  if type(scope)~="string" or type(key)~="string" then return end
  if string.find(scope,"%.") or string.find(key,"%.") then
    print("[UserConfig] scopes and keys must not contain dots: "..tostring(scope).."."..tostring(key))
    return
  end
  local t=type(defaultValue)
  if t~="string" and t~="number" and t~="boolean" then
    print("[UserConfig] only string/number/boolean settings are supported: "..scope.."."..key)
    return
  end
  self:Bucket(self.defaults,scope)[key]=defaultValue
  local dataBucket=self:Bucket(self.data,scope)
  --keep an already loaded/saved value, fill only holes
  if dataBucket[key]==nil then
    dataBucket[key]=defaultValue
  end
end

function UserConfig:Get(scope,key)
  local bucket=self:Bucket(self.data,scope,true)
  if bucket==nil then return nil end
  return bucket[key]
end

function UserConfig:Set(scope,key,value)
  if type(scope)~="string" or type(key)~="string" then return false end
  local defaultsBucket=self:Bucket(self.defaults,scope,true)
  if defaultsBucket==nil or defaultsBucket[key]==nil then
    print("[UserConfig] rejected unknown setting: "..tostring(scope).."."..tostring(key))
    return false
  end
  local default=defaultsBucket[key]
  --the ui sometimes sends booleans as 1/0, coerce them to the default's type
  if type(default)=="boolean" and type(value)=="number" then
    value=(value~=0)
  end
  if type(value)~=type(default) then
    print("[UserConfig] rejected type mismatch on "..scope.."."..key..": expected "..type(default)..", got "..type(value))
    return false
  end
  local dataBucket=self:Bucket(self.data,scope)
  if dataBucket[key]==value then return true end
  dataBucket[key]=value
  self.dirty[self:FlatKey(scope,key)]=value
  self:FireWatchers(scope,key,value)
  self:DebouncedSave()
  return true
end

function UserConfig:Watch(scope,key,callback)
  local watchKey=scope.."."..key
  if self.watchers[watchKey]==nil then
    self.watchers[watchKey]={}
  end
  table.insert(self.watchers[watchKey],callback)
end

function UserConfig:FireWatchers(scope,key,value)
  local list=self.watchers[scope.."."..key]
  if list==nil then return end
  for _,cb in pairs(list) do
    local ok,err=pcall(cb,value)
    if not ok then
      print("[UserConfig] watcher error on "..scope.."."..key..": "..tostring(err))
    end
  end
end

function UserConfig:OnClientSet(event)
  if type(event)~="table" then return end
  self:Set(event.scope,event.key,event.value)
end

function UserConfig:IsLoaded()
  return self.loaded
end

function UserConfig:RequestLoad()
  if self.loadRequested then return end
  self.loadRequested=true
  if Networking.authKey==nil then
    --no auth key yet (login not finished), retry shortly
    Timers:CreateTimer(2,function()
      UserConfig.loadRequested=false
      UserConfig:RequestLoad()
    end)
    return
  end
  --no body needed: the X-Auth-Key header identifies the player
  Networking:MakeRequest(nil,GET_ROUTE,nil,function(resBody)
    UserConfig:HandleLoad(resBody)
  end)
  Timers:CreateTimer(LOAD_FALLBACK_TIMEOUT,function()
    if not UserConfig.loaded then
      print("[UserConfig] load timed out, continuing with defaults")
      UserConfig.loaded=true
      UserConfig:SendToClient()
    end
  end)
end

function UserConfig:HandleLoad(body)
  if self.loaded then return end
  local response=nil
  --json.decode throws on nil/invalid bodies, decode defensively
  if type(body)=="string" and body~="" then
    local ok,result=pcall(json.decode,body)
    if ok and type(result)=="table" then response=result end
  end
  if response and type(response.settings)=="table" then
    self:ApplySavedFlat(response.settings)
  else
    print("[UserConfig] no saved settings (or bad response), using defaults")
  end
  self.loaded=true
  self:SendToClient()
end

--applies the flat saved map on top of registered defaults; unknown keys are ignored
function UserConfig:ApplySavedFlat(flat)
  for flatKey,value in pairs(flat) do
    local scope,key=self:ParseFlatKey(flatKey)
    --skip keys the player changed locally while the load was in flight: the fresh
    --local value wins and will be pushed to the backend by the debounce timer
    if scope~=nil and self.dirty[flatKey]==nil then
      local defaultsBucket=self:Bucket(self.defaults,scope,true)
      if defaultsBucket~=nil and defaultsBucket[key]~=nil then
        local default=defaultsBucket[key]
        --booleans travel as 0/1, restore them using the default's type
        if type(default)=="boolean" and type(value)=="number" then
          value=(value~=0)
        end
        if type(value)==type(default) then
          self:Bucket(self.data,scope)[key]=value
          self:FireWatchers(scope,key,value)
        else
          print("[UserConfig] skipped saved value with wrong type: "..flatKey)
        end
      end
    end
  end
end

function UserConfig:DebouncedSave()
  if self.saveTimer~=nil then
    Timers:RemoveTimer(self.saveTimer)
    self.saveTimer=nil
  end
  self.saveTimer=Timers:CreateTimer(SAVE_DEBOUNCE,function()
    UserConfig.saveTimer=nil
    UserConfig:PushDirty()
  end)
end

--booleans go over the wire as 0/1 to keep the payload small and json-safe
function UserConfig:EncodeValue(value)
  if type(value)=="boolean" then
    if value then return 1 end
    return 0
  end
  return value
end

function UserConfig:PushDirty()
  if next(self.dirty)==nil then return end
  if Networking.authKey==nil then
    --not logged in yet, keep dirty and retry after another quiet window
    self:DebouncedSave()
    return
  end
  local payload={}
  for flatKey,value in pairs(self.dirty) do
    payload[flatKey]=self:EncodeValue(value)
  end
  self.dirty={}
  local body=json.encode({settings=payload})
  print("[UserConfig] saving "..body)
  Networking:MakeRequest(body,SAVE_ROUTE,nil,function(resBody)
    --nothing to do on success; if it failed the next change will push everything again
  end)
end

function UserConfig:SendToClient()
  CustomGameEventManager:Send_ServerToAllClients("user_config_load",{data=self.data})
end

UserConfig:Init()
