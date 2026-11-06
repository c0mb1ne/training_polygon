local abilityName = "mirana_arrow"

SpellTiming:Register(abilityName, {
  GetDistanceRange = function(self)
    local arrowRange = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "arrow_range"}, "3000")
    return 0, arrowRange
  end,

  GetImpactDelay = function(self, distance, castSpeedModifier)
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.5 0.5 0.5 0.5")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "arrow_speed"}, "900")
    local projectileWidth = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "arrow_width", "value"}, "115")
    local travelDistance = math.max(0, distance - projectileWidth / 2)
    return castPoint * castSpeedModifier + travelDistance / projectileSpeed
  end,
})
