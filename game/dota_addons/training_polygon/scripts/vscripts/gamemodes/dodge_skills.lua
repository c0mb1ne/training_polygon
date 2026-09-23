function dodge:lina_light_strike_array(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.45 0.45 0.45 0.45")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "light_strike_array_delay_time", "value"}, "0.5")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "700")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    --[[ Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration) ]]
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end
function dodge:rattletrap_hookshot(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3 0.3")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "2000 2500 3000", self.currentAbilityLevel)
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "speed"}, "4000 5000 6000", self.currentAbilityLevel)
    local projectileSize = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "latch_radius"}, "125 125 125")
    local damageDelay = (range - self.respawnOffset - 50 - projectileSize / 2) / projectileSpeed --50 is hull sizes i guess
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:obsidian_destroyer_sanity_eclipse(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.25 0.25 0.25")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "700")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:undying_decay(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.30000001192093")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "650")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:windrunner_powershot(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "arrow_speed"}, "3000")
    local channelTime = DotaDB:GetAbilityValue(abilityName, {"AbilityChannelTime"}, "1")
    local projectileWidth = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "arrow_width", "value"}, "125 125 125 125")
    local range = 1000
    local damageDelay = channelTime + (range - self.respawnOffset - projectileWidth / 2) / projectileSpeed
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:techies_suicide(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"1")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"1000")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "duration"},"0.75")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:rattletrap_rocket_flare(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3 0.3")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "speed"}, "2250")
    local range = 1000
    local damageDelay = (range - self.respawnOffset) / projectileSpeed
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:earthshaker_fissure(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.69 0.69 0.69 0.69")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "AbilityCastRange", "value"}, "1600")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range - 700)
end

function dodge:bloodseeker_blood_bath(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.30000001192093")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay"}, "2.5999999046326")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "1500")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:kunkka_torrent(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.40")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay"},"1.6 1.6 1.6 1.6")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"1300") * 0.6
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:elder_titan_earth_splitter(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.4 0.4 0.4")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "crack_time"}, "2.718")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "2400") / 4
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:warlock_rain_of_chaos(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.5 0.5 0.5")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "stun_delay"},"0.5")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"900")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:leshrac_split_earth(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.7 0.7 0.7 0.7")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay"}, "0.34999999403954")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "650")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:pugna_nether_blast(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.2 0.2 0.2 0.2")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay"}, "0.80000001192093")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "600")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:dark_willow_terrorize(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"1")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"1200")
    local heigth = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "starting_height"},"300")
    local speed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "destination_travel_speed"},"2000")
    local s = math.sqrt((range * range) + (heigth * heigth))
    local damageDelay = (s - 48) / speed
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:meepo_poof(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "1.5")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "400")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:omniknight_purification(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.20")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"},"260")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doSelfCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:obsidian_destroyer_astral_imprisonment(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"})
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "prison_duration", "value"}, nil, self.currentAbilityLevel)
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "damage_radius", "value"})
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doSelfCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:zuus_lightning_bolt(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.3")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"700 750 800 850")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:zuus_thundergods_wrath(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.4 0.4 0.4 0.4")
    local damageDelay = 0
    local range = 600
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:ursa_earthshock(entry)
    local abilityName = entry.spell_name
    local castPoint = 0
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "hop_duration"}, "0.25")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "hop_distance", "value"}, "250")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:visage_summon_familiars_stone_form(entry)
    local abilityName = entry.spell_name
    local castPoint = 0
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "stun_delay"}, "0.55000001192093")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "stun_radius", "value"}, "375")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:elder_titan_echo_stomp(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.40000000596046")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityChannelTime"}, "1.2999999523163")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "500")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:earthshaker_enchant_totem(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.5")
    local damageDelay = 0
    local range = DotaDB:GetAbilityValue("earthshaker_aftershock", {"AbilityValues", "aftershock_range", "value"}, "350")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:tidehunter_anchor_smash(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.40000000596046")
    local damageDelay = 0
    local additionalRange = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "additional_range", "value"}, "225")
    local range = DotaDB:GetHeroValue(entry.hero_name, {"AttackRange"}, "150") + additionalRange
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:necrolyte_death_pulse(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.0 0.0 0.0 0.0")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "projectile_speed"}, "400")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "area_of_effect", "value"}, "500")
    local damageDelay = (range - self.respawnOffset - 50) / projectileSpeed --50 is hull sizes i guess
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:queenofpain_scream_of_pain(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.0 0.0 0.0 0.0")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "projectile_speed"}, "900")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "area_of_effect", "value"}, "600")
    local damageDelay = (range - self.respawnOffset - 50) / projectileSpeed --50 is hull sizes i guess
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:phoenix_supernova(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.00999")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "aura_radius", "value"},"1200")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityDuration"},"6")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:legion_commander_overwhelming_odds(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.3 0.3 0.3 0.3")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"},"600")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:magnataur_reverse_polarity(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "410 410 410")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:slardar_slithereen_crush(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.25")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "crush_radius", "value"}, "325")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:axe_berserkers_call(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "315")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:brewmaster_thunder_clap(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.30000001192093")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "400")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:roshan_slam(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.47 0.47 0.47 0.47")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "350")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:pangolier_shield_crash(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.0 0.0 0.0 0.0")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"},"500")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "jump_duration"},"0.40")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:centaur_hoof_stomp(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "windup_time"}, "0.5")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "325")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:polar_furbolg_ursa_warrior_thunder_clap(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.40000000596046")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "300")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:centaur_khan_war_stomp(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.40000000596046")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "radius", "value"}, "250")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:item_meteor_hammer(entry)
    local abilityName = entry.spell_name
    local castPoint = 0
    local channelTime = DotaDB:GetItemValue(abilityName, {"AbilityChannelTime"},"2")
    local landTime = DotaDB:GetItemValue(abilityName, {"AbilityValues", "land_time"},"0.5")
    local damageDelay = channelTime + landTime
    local range = DotaDB:GetItemValue(abilityName, {"AbilityCastRange"},"600")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    local enemyName = entry.hero_name
    local enemySpell = entry.spell_name
    local preCastDelay = self.castDelay
    local afterCastDelay = self.afterCastDelay + castPoint --crashes without extra second
    local spawnRange = range
    if self.hardcoreMode then
        spawnRange = spawnRange + self.blinkRange
    end
    local spawnpoint = randomCirclePositionVector(spawnRange - self.respawnOffset, self.playerHero:GetAbsOrigin())
    self.currentEnemy = CreateUnitByNameAsync(enemyName, spawnpoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
        local ability = CreateItem(enemySpell, unit, unit)
        unit:AddItem(ability)
        unit:SetAttackCapability(0)

        local blink = nil
        if self.hardcoreMode then
            blink = CreateItem("item_blink", unit, unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya = CreateItem("item_yasha_and_kaya", unit, unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint = (self.playerHero:GetAbsOrigin() - spawnpoint):Normalized() * self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ability:entindex(),
                    Position = self.playerHero:GetAbsOrigin(),
                    Queue = 1
                })
                self.removeTimer = Timers:CreateTimer(afterCastDelay, function()
                    if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
                    return nil
                end)

            end,
            preCastDelay + self:getRandomDelay())
        self.currentEnemy = unit
        return unit
    end)
end

function dodge:alchemist_unstable_concoction(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue("alchemist_unstable_concoction_throw", {"AbilityCastPoint"}, "0.2")
    local projectileSpeed = DotaDB:GetAbilityValue("alchemist_unstable_concoction_throw", {"AbilityValues", "projectile_speed"}, "900")
    local range = DotaDB:GetAbilityValue("alchemist_unstable_concoction_throw", {"AbilityCastRange"}, "775")

    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end

    --self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
    local enemyName = entry.hero_name
    local enemySpell = entry.spell_name
    local preCastDelay = self.castDelay
    local afterCastDelay = self.afterCastDelay + castPoint
    local spawnRange = range
    local maxHoldTime = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "brew_time", "value"}, "5")
    local holdTime = RandomFloat(0.5, maxHoldTime - 0.2)
    local damageDelay = holdTime + (range - self.respawnOffset - 50) / projectileSpeed --50 is hull sizes i guess
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    if self.hardcoreMode then
        spawnRange = spawnRange + self.blinkRange
    end
    local spawnpoint = randomCirclePositionVector(spawnRange - self.respawnOffset, self.playerHero:GetAbsOrigin())

    self.currentEnemy = CreateUnitByNameAsync(enemyName, spawnpoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())

        local ability = unit:FindAbilityByName(enemySpell)
        unit:SetAttackCapability(0)
        unit:UpgradeAbility(ability)
        local blink = nil
        if self.hardcoreMode then
            blink = CreateItem("item_blink", unit, unit)
            unit:AddItem(blink)
        end
        local throwAbility = unit:FindAbilityByName("alchemist_unstable_concoction_throw")
        local randomDelay = self:getRandomDelay()
        local delay = preCastDelay + randomDelay + holdTime
        local blinkCasted = false
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = ability:entindex(),
                    Queue = 1
                })
            end,
            preCastDelay + randomDelay)
        function tryToCast()
            unit:SetContextThink(DoUniqueString("try_cast_ability"),
                function()
                    if self.hardcoreMode and blinkCasted == false then
                        local blinkPoint = (self.playerHero:GetAbsOrigin() - spawnpoint):Normalized() * self.blinkRange
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                            AbilityIndex = blink:entindex(),
                            Position = self.playerHero:GetAbsOrigin(),
                            Queue = 0
                        })
                        blinkCasted = true
                    end
                    --[[ print(self.playerHero:HasModifier(self.dodgeModifier),self.dodgeModifier) ]]
                    --[[ print(throwAbility:IsCooldownReady(),unit:GetSequence(),self.playerHero:IsUnselectable()) ]]
                    if unit:HasModifier("modifier_alchemist_unstable_concoction") and unit:GetSequence() == "idle" and self.playerHero:IsUnselectable() == false then
                        print('trying to cast', throwAbility:GetAbilityName())

                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                            AbilityIndex = throwAbility:entindex(),
                            TargetIndex = self.playerHero:entindex(),
                            Queue = 1
                        })
                    end
                    delay = 0.15
                    if ability:IsCooldownReady() == false then
                        --go to unit removal
                        self.removeTimer = Timers:CreateTimer(afterCastDelay, function()
                            if IsValidEntity(unit) then
                                unit:RemoveSelf()
                            end
                            self:cycleEnemies()
                            return nil
                        end)
                    else
                        tryToCast()
                    end

                end,
                delay)
        end
        tryToCast()
        self.currentEnemy = unit
        return unit
    end)
end

function dodge:nevermore_shadowraze2(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.55000001192093")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "shadowraze_range"}, "450")
    local damageDelay = 0
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:lina_laguna_blade(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.30000001192093")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "damage_delay"}, "0.25")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "750")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:lion_finger_of_death(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "damage_delay", "value"}, "0.25")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "900")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:huskar_life_break(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.3 0.3 0.3")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"550")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "charge_speed"},"1200")
    local damageDelay = (range - self.respawnOffset - 50) / projectileSpeed --50 is hull sizes i guess
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:shadow_demon_demonic_purge(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityDuration"}, "5")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "800")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:skywrath_mage_arcane_bolt(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.1 0.1 0.1 0.1")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "AbilityCastRange", "value"}, "875")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "bolt_speed"}, "500")
    local damageDelay = (range - self.respawnOffset - 50) / projectileSpeed --50 is hull sizes i guess
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:gyrocopter_homing_missile(entry)
    local function calcHomingMissileFlightTime(distance, initialSpeed, acceleration)
        -- d = v₀·t + ½·a·t²
        -- ½·a·t² + v₀·t - d = 0
        local a = 0.5 * acceleration
        local b = initialSpeed
        local c = -distance

        local discriminant = b * b - 4 * a * c
        local t = (-b + math.sqrt(discriminant)) / (2 * a)
        return t
    end
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "1050")
    local preFlyTime = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "pre_flight_time"}, "2.5")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "speed"}, "500")
    local acceleration = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "acceleration"}, "15")

    local travelDistance = range - self.respawnOffset - 180 --there are too much unknown variables to caclulate travel time of rocket, so i put 180 to fit the timebar, havent tested on different ranges
    local flightTime = calcHomingMissileFlightTime(travelDistance, projectileSpeed, acceleration)
    local damageDelay = preFlyTime + flightTime

    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    --[[ Timebar:Prepare(castPoint, self.dodgeDuration, self.timebarExtraTime, self.dodgeCastPoint) ]]
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:medusa_mystic_snake(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "AbilityCastPoint"}, "0.200")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "AbilityCastRange"}, "750")
    local projectileSpeed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "initial_speed"}, "800")
    local damageDelay = (range - self.respawnOffset - 50) / projectileSpeed * 1.15 --50 is hull sizes i guess, 1.15 is to match calculations, i think there is something about how snake moves like sin wave
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:mirana_starfall(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"})
    local damageDelay = 0.57
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "starfall_radius", "value"})
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:invoker_emp(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.050000000745058")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay", "value"}, "2.9000000953674")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "950")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    local enemyName = entry.hero_name
    local enemySpell = entry.spell_name
    local preCastDelay = self.castDelay
    local afterCastDelay = self.afterCastDelay + castPoint
    local spawnRange = range
    if self.hardcoreMode then
        spawnRange = spawnRange + self.blinkRange
    end
    local spawnpoint = randomCirclePositionVector(spawnRange - self.respawnOffset, self.playerHero:GetAbsOrigin())
    self.currentEnemy = CreateUnitByNameAsync(enemyName, spawnpoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
        local ability = unit:FindAbilityByName(enemySpell)
        unit:SetAttackCapability(0)
        local invoke_name = "invoker_invoke"
        local wex_name = "invoker_wex"
        local invoke = unit:FindAbilityByName(invoke_name)
        invoke:SetLevel(1)
        local wex = unit:FindAbilityByName(wex_name)
        wex:SetLevel(3)
        unit:CastAbilityNoTarget(wex, -1)
        unit:CastAbilityNoTarget(wex, -1)
        unit:CastAbilityNoTarget(wex, -1)
        unit:CastAbilityNoTarget(invoke, -1)
        local blink = nil
        if self.hardcoreMode then
            blink = CreateItem("item_blink", unit, unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya = CreateItem("item_yasha_and_kaya", unit, unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint = (self.playerHero:GetAbsOrigin() - spawnpoint):Normalized() * self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ability:entindex(),
                    Position = self.playerHero:GetAbsOrigin(),
                    Queue = 1
                })
                self.removeTimer = Timers:CreateTimer(afterCastDelay, function()
                    if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
                    return nil
                end)

            end,
            preCastDelay + self:getRandomDelay())
        self.currentEnemy = unit
        return unit
    end)
end

function dodge:invoker_sun_strike(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.050000000745058")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "delay"}, "1.7000000476837")
    local range = 500
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    local enemyName = entry.hero_name
    local enemySpell = entry.spell_name
    local preCastDelay = self.castDelay
    local afterCastDelay = self.afterCastDelay + castPoint
    local spawnRange = range
    if self.hardcoreMode then
        spawnRange = spawnRange + self.blinkRange
    end
    local spawnpoint = randomCirclePositionVector(spawnRange - self.respawnOffset, self.playerHero:GetAbsOrigin())
    self.currentEnemy = CreateUnitByNameAsync(enemyName, spawnpoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
        local ability = unit:FindAbilityByName(enemySpell)
        unit:SetAttackCapability(0)
        local invoke_name = "invoker_invoke"
        local exort_name = "invoker_exort"
        local invoke = unit:FindAbilityByName(invoke_name)
        invoke:SetLevel(1)
        local exort = unit:FindAbilityByName(exort_name)
        exort:SetLevel(3)
        unit:CastAbilityNoTarget(exort, -1)
        unit:CastAbilityNoTarget(exort, -1)
        unit:CastAbilityNoTarget(exort, -1)
        unit:CastAbilityNoTarget(invoke, -1)
        local blink = nil
        if self.hardcoreMode then
            blink = CreateItem("item_blink", unit, unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya = CreateItem("item_yasha_and_kaya", unit, unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint = (self.playerHero:GetAbsOrigin() - spawnpoint):Normalized() * self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ability:entindex(),
                    Position = self.playerHero:GetAbsOrigin(),
                    Queue = 1
                })
                self.removeTimer = Timers:CreateTimer(afterCastDelay, function()
                    if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
                    return nil
                end)

            end,
            preCastDelay + self:getRandomDelay())
        self.currentEnemy = unit
        return unit
    end)
end

function dodge:tiny_toss(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"},"0.0 0.0 0.0 0.0")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "duration"},"1.10")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"},"800 900 1000 1100")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    local enemyName = entry.hero_name
    local enemySpell = entry.spell_name
    local preCastDelay = self.castDelay
    local afterCastDelay = self.afterCastDelay + castPoint
    local spawnRange = range
    if self.hardcoreMode then
        spawnRange = spawnRange + self.blinkRange
    end
    local spawnpoint = randomCirclePositionVector(spawnRange - self.respawnOffset, self.playerHero:GetAbsOrigin())
    self.currentEnemy = CreateUnitByNameAsync(enemyName, spawnpoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
        local ability = unit:FindAbilityByName(enemySpell)
        unit:SetAttackCapability(0)

        ability:SetLevel(1)
        local helper_respawn = spawnpoint + Vector(100, 0, 0)
        local helper_name = "npc_dota_creep_goodguys_melee"
        local helper = CreateUnitByName(helper_name, helper_respawn, true, nil, nil, DOTA_TEAM_BADGUYS)
        helper:SetAttackCapability(0)
        local blink = nil
        if self.hardcoreMode then
            blink = CreateItem("item_blink", unit, unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya = CreateItem("item_yasha_and_kaya", unit, unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint = (self.playerHero:GetAbsOrigin() - spawnpoint):Normalized() * self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = ability:entindex(),
                    TargetIndex = self.playerHero:entindex(),
                    Queue = 1
                })
                self.removeTimer = Timers:CreateTimer(afterCastDelay, function()
                    if IsValidEntity(unit) then
                        unit:RemoveSelf()
                        helper:RemoveSelf()
                    end
                    self:cycleEnemies()
                    return nil
                end)

            end,
            preCastDelay + self:getRandomDelay())
        self.currentEnemy = unit
        return unit
    end)
end

function dodge:medusa_stone_gaze(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.40")
    local damageDelay = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "face_duration"}, "2")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "AbilityCastRange"}, "1200")
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    local enemyName = entry.hero_name
    local enemySpell = entry.spell_name
    local preCastDelay = self.castDelay
    local afterCastDelay = self.afterCastDelay + castPoint
    local spawnRange = range
    --[[ self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range) ]]
    if self.hardcoreMode then
        spawnRange = spawnRange + self.blinkRange
    end
    local spawnpoint = self.playerHero:GetForwardVector() * 400 + self.playerHero:GetAbsOrigin()
    self.currentEnemy = CreateUnitByNameAsync(enemyName, spawnpoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
        local ability = unit:FindAbilityByName(enemySpell)
        unit:SetAttackCapability(0)
        unit:UpgradeAbility(ability)
        local blink = nil
        if self.hardcoreMode then
            blink = CreateItem("item_blink", unit, unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya = CreateItem("item_yasha_and_kaya", unit, unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint = (self.playerHero:GetAbsOrigin() - spawnpoint):Normalized() * self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = ability:entindex(),
                    Queue = 1
                })
                self.removeTimer = Timers:CreateTimer(afterCastDelay, function()
                    if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
                    return nil
                end)

            end,
            preCastDelay + self:getRandomDelay())
        self.currentEnemy = unit
        return unit
    end)
end

function dodge:kunkka_ghostship(entry)
    local abilityName = entry.spell_name
    local castPoint = DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.30000001192093")
    local travel_distance = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "ghostship_distance"}, "2000")
    local travel_speed = DotaDB:GetAbilityValue(abilityName, {"AbilityValues", "ghostship_speed"}, "650")
    local range = DotaDB:GetAbilityValue(abilityName, {"AbilityCastRange"}, "1000")
    local damageDelay = travel_distance / travel_speed
    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint + self.timebarExtraTime, castPoint - self.dodgeDuration - self.dodgeCastPoint, self.dodgeDuration)
    self:doPointCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end