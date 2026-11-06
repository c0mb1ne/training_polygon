local abilityName = "kunkka_torrent"

SpellTiming:Register(abilityName, {
  GetDistanceRange = function(self)
    local castRange = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "1300")
    return 0, castRange
  end,

  GetImpactDelay = function(self, distance, castSpeedModifier)
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.40")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay"}, "1.6 1.6 1.6 1.6")
    return castPoint * castSpeedModifier + damageDelay
  end,
})
