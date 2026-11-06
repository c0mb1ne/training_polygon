local abilityName = "lina_light_strike_array"

SpellTiming:Register(abilityName, {
  GetDistanceRange = function(self)
    local castRange = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "700")
    return 0, castRange
  end,

  GetImpactDelay = function(self, distance, castSpeedModifier)
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.45 0.45 0.45 0.45")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "light_strike_array_delay_time", "value"}, "0.5")
    return castPoint * castSpeedModifier + damageDelay
  end,
})
