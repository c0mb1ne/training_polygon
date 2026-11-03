--[[
    =========================================================================================
    TRAINING POLYGON - HTTP RELAY (http_relay.lua)
    =========================================================================================
    Fallback HTTP transport for game sessions where CreateHTTPRequestScriptVM
    returns nil (lobby-hosted games). Requests are sent to the client via
    custom game events, executed by invisible DOTAHTMLPanels in Panorama
    (api_http_relay.js) against the /bridge endpoint, and the response comes
    back through chunked custom game events.

    Used by Networking:MakeRequest only. Protocol adapted from RANDOM FARM TD.
    =========================================================================================
]]

if HttpRelay == nil then
  HttpRelay = {
    seq = 0,
    sessionPrefix = nil,
    pending = {},          -- reqId -> {callback, parts, total, status, acked, timerData}
    bridgeOnline = false,
    listenersRegistered = false,
    RELAY_CHUNK = 700,     -- body chunk size, server -> client
    TIMEOUT_SEC = 35,      -- absolute per-request timeout
  }
end

--set true (or `tp_relay_force 1` in console) to test the relay in tools mode
_G.TP_FORCE_HTTP_RELAY = _G.TP_FORCE_HTTP_RELAY or false

Convars:RegisterCommand("tp_relay_force", function(_, val)
  if val == "1" or val == "true" then
    _G.TP_FORCE_HTTP_RELAY = true
    print("[HttpRelay] forced relay: ON")
  elseif val == "0" or val == "false" then
    _G.TP_FORCE_HTTP_RELAY = false
    print("[HttpRelay] forced relay: OFF")
  else
    print("[HttpRelay] forced relay is: " .. tostring(_G.TP_FORCE_HTTP_RELAY))
  end
end, "Toggle forced http relay (1/0)", FCVAR_CHEAT)

function HttpRelay:RegisterListeners()
  if self.listenersRegistered then return end
  self.listenersRegistered = true

  CustomGameEventManager:RegisterListener("api_http_relay_result", function(_, ev)
    if not ev then return end
    local reqId = tonumber(ev.request_id) or 0
    local row = HttpRelay.pending[reqId]
    if not row then return end

    local total = math.max(1, tonumber(ev.chunk_total) or 1)
    local idx = tonumber(ev.chunk_index) or 0
    if ev.status ~= nil then
      row.status = tonumber(ev.status) or 0
    end
    row.total = total
    row.parts[idx] = tostring(ev.chunk or ev.body or "")

    local have = 0
    for i = 0, total - 1 do
      if row.parts[i] ~= nil then
        have = have + 1
      end
    end
    if have < total then return end

    HttpRelay.pending[reqId] = nil
    local fullBody = ""
    for i = 0, total - 1 do
      fullBody = fullBody .. (row.parts[i] or "")
    end

    if row.callback then
      local cb = row.callback
      row.callback = nil
      local ok, err = pcall(cb, { StatusCode = row.status, Body = fullBody })
      if not ok then
        print("[HttpRelay] callback error: " .. tostring(err))
      end
    end
  end)

  CustomGameEventManager:RegisterListener("api_http_relay_ack", function(_, ev)
    if not ev then return end
    local reqId = tonumber(ev.request_id) or 0
    local row = HttpRelay.pending[reqId]
    if row then
      row.acked = true
    end
  end)

  CustomGameEventManager:RegisterListener("api_http_relay_hello", function(_, ev)
    if not HttpRelay.bridgeOnline then
      HttpRelay.bridgeOnline = true
      print("[HttpRelay] Panorama bridge online")
    end
  end)
end

function HttpRelay:EmitChunks(reqId, method, url, headersJson, body, total)
  for i = 0, total - 1 do
    local startIdx = i * self.RELAY_CHUNK + 1
    local endIdx = math.min(#body, (i + 1) * self.RELAY_CHUNK)
    local piece = (#body > 0) and string.sub(body, startIdx, endIdx) or ""
    CustomGameEventManager:Send_ServerToAllClients("api_http_relay", {
      request_id = reqId,
      method = method,
      url = url,
      headers_json = headersJson,
      chunk = piece,
      chunk_index = i,
      chunk_total = total,
    })
  end
end

-- method: "GET"/"POST", url: absolute url, headers: table or nil,
-- body: string or nil, callback: function(res) with res = {StatusCode, Body}
function HttpRelay:Send(method, url, headers, body, callback)
  self:RegisterListeners()

  if not self.sessionPrefix then
    self.sessionPrefix = RandomInt(100, 999)
  end
  self.seq = self.seq + 1
  local reqId = self.sessionPrefix * 100000 + (self.seq % 100000)

  local raw = body or ""
  local total = math.max(1, math.ceil(#raw / self.RELAY_CHUNK))
  local headersJson = json.encode(headers or {})

  self.pending[reqId] = {
    callback = callback,
    parts = {},
    total = total,
    status = 0,
    acked = false,
  }

  self:EmitChunks(reqId, method, url, headersJson, raw, total)

  -- resend once if the client did not ack (event can arrive before the bridge subscribed)
  Timers:CreateTimer(1.0, function()
    local row = HttpRelay.pending[reqId]
    if row and not row.acked then
      HttpRelay:EmitChunks(reqId, method, url, headersJson, raw, total)
    end
  end)

  -- absolute timeout
  Timers:CreateTimer(self.TIMEOUT_SEC, function()
    local row = HttpRelay.pending[reqId]
    if row then
      HttpRelay.pending[reqId] = nil
      print("[HttpRelay] timeout for request id=" .. reqId .. " url=" .. string.sub(url, 1, 80))
      if row.callback then
        local cb = row.callback
        row.callback = nil
        pcall(cb, { StatusCode = 0, Body = "" })
      end
    end
  end)

  return reqId
end
