if ParticleMessage == nil then
  ParticleMessage = class({})
end

function ParticleMessage:Init()
  self.numbersParticle="particles/tp_custom_msg.vpcf"
  self.dotParticle="particles/tp_custom_msg_dot.vpcf"
  self.plusParticle="particles/tp_custom_msg_plus.vpcf"
  self.minusParticle="particles/tp_custom_msg_minus.vpcf"
  self.luckyParticle="particles/tp_custom_msg_lucky.vpcf"
  self.unluckyParticle="particles/tp_custom_msg_unlucky.vpcf"
  self.gapBetweenNumbers=12
  self.colors={
    yellow=Vector(255,215,0),
    red=Vector(255,0,0),
    green=Vector(0,255,0),
    purple=Vector(75,0,130),
    blue=Vector(0,0,255),
    cyan=Vector(0,255,255)
  }
end

function ParticleMessage:Show(tableArguments)

end

function ParticleMessage:Test(npc)
  Timers:CreateTimer(0,function()
      --[[ self:ShowNumber(npc,Vector(15,0,110), 1.5)
      self:ShowNumber(npc,Vector(0,0,110), -12.345)
      self:ShowNumber(npc,Vector(-15,0,110), 3) ]]
    self:ShowNumber(npc, Vector(0,0,110), RandomFloat(-20.0,20.0), self:getRandomColor(), false)
    return 1.5
  end)
end

--------------------------------------------------------------------------
-- Low level: single glyph particles
--------------------------------------------------------------------------

function ParticleMessage:ShowSingleNumber(npc,vecOffset,number,color)
  color = color or self.colors.green
  local particleFX = ParticleManager:CreateParticle(self.numbersParticle, PATTACH_ABSORIGIN_FOLLOW, npc)
  ParticleManager:SetParticleControl(particleFX, 1, vecOffset)
  ParticleManager:SetParticleControl(particleFX, 2, Vector(number,0,0)) --x number from 0 to 9
  ParticleManager:SetParticleControl(particleFX, 3, color)
end

function ParticleMessage:ShowSingleDot(npc,vecOffset,color)
  color = color or self.colors.green
  local particleFX = ParticleManager:CreateParticle(self.dotParticle, PATTACH_ABSORIGIN_FOLLOW, npc)
  ParticleManager:SetParticleControl(particleFX, 1, vecOffset)
  ParticleManager:SetParticleControl(particleFX, 3, color)
end

function ParticleMessage:ShowSingleMinus(npc,vecOffset,color)
  color = color or self.colors.green
  local particleFX = ParticleManager:CreateParticle(self.minusParticle, PATTACH_ABSORIGIN_FOLLOW, npc)
  ParticleManager:SetParticleControl(particleFX, 1, vecOffset)
  ParticleManager:SetParticleControl(particleFX, 3, color)
end

function ParticleMessage:ShowSinglePlus(npc,vecOffset,color)
  color = color or self.colors.green
  local particleFX = ParticleManager:CreateParticle(self.plusParticle, PATTACH_ABSORIGIN_FOLLOW, npc)
  ParticleManager:SetParticleControl(particleFX, 1, vecOffset)
  ParticleManager:SetParticleControl(particleFX, 3, color)
end

--------------------------------------------------------------------------
-- High level: show a full number (handles sign, int part, up to 3 decimals)
--------------------------------------------------------------------------

-- number: any lua number, e.g. 3, -12.345, 1.5
-- vecOffset: center position for the whole string
-- color: optional Vector from self.colors, defaults to green
-- showPlus: optional bool, if true prefixes positive numbers with a plus particle
function ParticleMessage:ShowNumber(npc, vecOffset, number, color, showPlus)
  color = color or self.colors.green

  local isNegative = number < 0
  local absNumber = math.abs(number)

  -- round to 3 decimal places to avoid float noise, then split
  local rounded = math.floor(absNumber * 1000 + 0.5)
  local intPart = math.floor(rounded / 1000)
  local fracPart = rounded % 1000 -- 0-999, exactly 3 digits worth

  local intStr = tostring(intPart)
  local fracStr = string.format("%03d", fracPart) -- always 3 digits, e.g. "050"

  -- only show the decimal part if it's non-zero
  local hasFrac = fracPart > 0

  -- build ordered list of symbols to render
  local symbols = {}

  if isNegative then
    table.insert(symbols, "minus")
  elseif showPlus then
    table.insert(symbols, "plus")
  end

  for c in intStr:gmatch(".") do
    table.insert(symbols, tonumber(c))
  end

  if hasFrac then
    table.insert(symbols, "dot")
    for c in fracStr:gmatch(".") do
      table.insert(symbols, tonumber(c))
    end
  end

  -- center the whole string on vecOffset
  local totalWidth = (#symbols - 1) * self.gapBetweenNumbers
  local startX = -totalWidth / 2

  for i, sym in ipairs(symbols) do
    local offset = vecOffset + Vector(startX + (i-1) * self.gapBetweenNumbers, 0, 0)
    if sym == "minus" then
      self:ShowSingleMinus(npc, offset, color)
    elseif sym == "plus" then
      self:ShowSinglePlus(npc, offset, color)
    elseif sym == "dot" then
      self:ShowSingleDot(npc, offset, color)
    else
      self:ShowSingleNumber(npc, offset, sym, color)
    end
  end
end

function ParticleMessage:getRandomColor()
  local keys = {}
  for k in pairs(self.colors) do
    table.insert(keys, k)
  end
  local randomKey = keys[math.random(#keys)]
  return self.colors[randomKey]
end

ParticleMessage:Init()

--materials/particle/debug/debug_msg.vtex
--materials/particle/drow/drow_arcana/drow_arcana_msg.vtex
--materials/particle/hoodwink/hoodwink_msg_01.vtex
--materials/particle/juggernaut/arcana/juggernaut_messages.vtex
--materials/particle/last_hit/last_hit_msg.vtex
--materials/particle/legion/legion_messages.vtex
--materials/particle/msg/msg_01.vtex
--materials/particle/msg/msg_01_outline.vtex
--materials/particle/msg/msg_radiance.vtex
--materials/particle/msg/msg_radiance_noring.vtex
--materials/particle/numbers_test/numbers_test.vtex
--materials/particle/oracle/oracle_major_arcana_card_symbols.vtex symbols
--materials/particle/ringmaster/ringmaster_msg.vtex