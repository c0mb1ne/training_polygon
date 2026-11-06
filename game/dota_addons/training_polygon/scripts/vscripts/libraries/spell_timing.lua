-- Shared cast-order-to-impact timing calculations.
-- This library only calculates timing; casting and timebar rendering stay in the modes.
require('libraries/dota_database')

if SpellTiming == nil then
  SpellTiming = class({})
end

function SpellTiming:Init()
  self.definitions = {}

  require('libraries/spell_timing/heroes/lina')
  require('libraries/spell_timing/heroes/kunkka')
  require('libraries/spell_timing/heroes/mirana')

  print("SpellTiming inited")
end

function SpellTiming:Register(spellName, definition)
  assert(type(spellName) == "string" and spellName ~= "", "[SpellTiming] Spell name must be a non-empty string")
  assert(type(definition) == "table", "[SpellTiming] Definition must be a table for " .. tostring(spellName))
  assert(type(definition.GetDistanceRange) == "function", "[SpellTiming] GetDistanceRange is required for " .. spellName)
  assert(type(definition.GetImpactDelay) == "function", "[SpellTiming] GetImpactDelay is required for " .. spellName)
  assert(self.definitions[spellName] == nil, "[SpellTiming] Duplicate definition for " .. spellName)

  self.definitions[spellName] = definition
end

function SpellTiming:GetDefinition(spellName)
  local definition = self.definitions[spellName]
  if definition == nil then
    return nil, "[SpellTiming] No timing definition registered for " .. tostring(spellName)
  end
  return definition
end

function SpellTiming:ValidateModifier(castSpeedModifier)
  local modifier = castSpeedModifier
  if modifier == nil then
    modifier = 1
  end

  if type(modifier) ~= "number" or modifier <= 0 then
    return nil, "[SpellTiming] castSpeedModifier must be a positive number"
  end

  return modifier
end

-- Distance is measured between unit origins. Each spell applies its own collision offsets.
function SpellTiming:GetImpactDelay(spellName, distance, castSpeedModifier)
  local definition, definitionError = self:GetDefinition(spellName)
  if definition == nil then
    return nil, definitionError
  end

  local modifier, modifierError = self:ValidateModifier(castSpeedModifier)
  if modifier == nil then
    return nil, modifierError
  end

  if type(distance) ~= "number" or distance < 0 then
    return nil, "[SpellTiming] Distance must be a non-negative number for " .. tostring(spellName)
  end

  local minDistance, maxDistance = definition:GetDistanceRange()
  if type(minDistance) ~= "number" or type(maxDistance) ~= "number" or minDistance < 0 or maxDistance < minDistance then
    return nil, "[SpellTiming] Invalid distance range returned for " .. tostring(spellName)
  end

  if distance < minDistance or distance > maxDistance then
    return nil, string.format("[SpellTiming] Distance %.3f is outside %.3f-%.3f for %s",
      distance, minDistance, maxDistance, tostring(spellName))
  end

  local impactDelay = definition:GetImpactDelay(distance, modifier)
  if type(impactDelay) ~= "number" or impactDelay < 0 then
    return nil, "[SpellTiming] Invalid impact delay returned for " .. tostring(spellName)
  end

  return impactDelay
end

function SpellTiming:GetImpactDelayRange(spellName, castSpeedModifier)
  local definition, definitionError = self:GetDefinition(spellName)
  if definition == nil then
    return nil, definitionError
  end

  local modifier, modifierError = self:ValidateModifier(castSpeedModifier)
  if modifier == nil then
    return nil, modifierError
  end

  local minDistance, maxDistance = definition:GetDistanceRange()
  if type(minDistance) ~= "number" or type(maxDistance) ~= "number" or minDistance < 0 or maxDistance < minDistance then
    return nil, "[SpellTiming] Invalid distance range returned for " .. tostring(spellName)
  end

  local minDelay, minDelayError = self:GetImpactDelay(spellName, minDistance, modifier)
  if minDelay == nil then
    return nil, minDelayError
  end

  local maxDelay, maxDelayError = self:GetImpactDelay(spellName, maxDistance, modifier)
  if maxDelay == nil then
    return nil, maxDelayError
  end

  return {
    minDistance = minDistance,
    maxDistance = maxDistance,
    minDelay = minDelay,
    maxDelay = maxDelay,
  }
end

SpellTiming:Init()
