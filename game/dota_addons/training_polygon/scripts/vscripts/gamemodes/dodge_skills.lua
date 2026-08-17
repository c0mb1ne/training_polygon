function dodge:lina_light_strike_array(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["light_strike_array_delay_time"]["value"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    --[[ Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration) ]]
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:rattletrap_hookshot(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"],self.currentAbilityLevel)
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"],self.currentAbilityLevel)
    local projectileSize=parseQuadroValue(abilityKV["AbilityValues"]["latch_radius"])
    local damageDelay=(range-self.respawnOffset-50-projectileSize/2)/projectileSpeed--50 is hull sizes i guess
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:obsidian_destroyer_sanity_eclipse(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:undying_decay(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:windrunner_powershot(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["arrow_speed"])
    local channelTime=parseQuadroValue(abilityKV["AbilityChannelTime"])
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["arrow_width"]["value"])
    local range=1000
    local damageDelay=channelTime+(range-self.respawnOffset-projectileWidth/2)/projectileSpeed
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:techies_suicide(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])

    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["duration"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:rattletrap_rocket_flare(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local range=1000
    local damageDelay=(range-self.respawnOffset)/projectileSpeed
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:earthshaker_fissure(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=parseQuadroValue(abilityKV["AbilityValues"]["AbilityCastRange"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range-700)
end
function dodge:bloodseeker_blood_bath(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:kunkka_torrent(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])-500
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:elder_titan_earth_splitter(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["crack_time"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])-1800
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:warlock_rain_of_chaos(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["stun_delay"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:leshrac_split_earth(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:pugna_nether_blast(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:dark_willow_terrorize(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    local heigth=parseQuadroValue(abilityKV["AbilityValues"]["starting_height"])
    local speed=parseQuadroValue(abilityKV["AbilityValues"]["destination_travel_speed"])
	local s=math.sqrt((range*range)+(heigth*heigth))
    local damageDelay=(s-48)/speed
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:meepo_poof(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:omniknight_purification(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doSelfCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:obsidian_destroyer_astral_imprisonment(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["prison_duration"]["value"],self.currentAbilityLevel)
    local range=parseQuadroValue(abilityKV["AbilityValues"]["damage_radius"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doSelfCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:zuus_lightning_bolt(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:zuus_thundergods_wrath(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local range=600
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:ursa_earthshock(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=0
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["hop_duration"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["hop_distance"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:visage_summon_familiars_stone_form(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=0
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["stun_delay"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["stun_radius"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:elder_titan_echo_stomp(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityChannelTime"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:earthshaker_enchant_totem(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local aftershockKV=DotaDB:GetAbilityKV("earthshaker_aftershock")
    local damageDelay=0
    local range=parseQuadroValue(aftershockKV["AbilityValues"]["aftershock_range"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:tidehunter_anchor_smash(entry)
    local abilityName=entry.spell_name
    local heroKV=DotaDB:GetHeroKV(entry.hero_name)
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    local additionalRange=parseQuadroValue(abilityKV["AbilityValues"]["additional_range"]["value"])
    local range=parseQuadroValue(heroKV["AttackRange"])+additionalRange
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:necrolyte_death_pulse(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["projectile_speed"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["area_of_effect"]["value"])
    local damageDelay=(range-self.respawnOffset-50)/projectileSpeed--50 is hull sizes i guess
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:queenofpain_scream_of_pain(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["projectile_speed"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["area_of_effect"]["value"])
    local damageDelay=(range-self.respawnOffset-50)/projectileSpeed--50 is hull sizes i guess
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:phoenix_supernova(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["aura_radius"]["value"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityDuration"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:legion_commander_overwhelming_odds(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:magnataur_reverse_polarity(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:slardar_slithereen_crush(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["crush_radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:axe_berserkers_call(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:brewmaster_thunder_clap(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:roshan_slam(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:pangolier_shield_crash(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["jump_duration"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:centaur_hoof_stomp(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityValues"]["windup_time"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:polar_furbolg_ursa_warrior_thunder_clap(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:centaur_khan_war_stomp(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:item_meteor_hammer(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetItemKV(abilityName)
    local castPoint=0
    local channelTime=parseQuadroValue(abilityKV["AbilityChannelTime"])
    local landTime=parseQuadroValue(abilityKV["AbilityValues"]["land_time"])
    local damageDelay=channelTime+landTime
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    local enemyName=entry.hero_name
    local enemySpell=entry.spell_name
    local preCastDelay=self.castDelay
    local afterCastDelay=self.afterCastDelay+castPoint --crashes without extra second
    local spawnRange=range
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = CreateItem(enemySpell,unit,unit)
        unit:AddItem(ability)
		unit:SetAttackCapability(0)
		
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
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
                self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
					if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
					return nil
				end)
                
            end,
        preCastDelay+self:getRandomDelay())
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:alchemist_unstable_concoction(entry)
    local abilityName=entry.spell_name
    local throwAbilityKV=DotaDB:GetAbilityKV("alchemist_unstable_concoction_throw")
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(throwAbilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(throwAbilityKV["AbilityValues"]["projectile_speed"])
    local range=parseQuadroValue(throwAbilityKV["AbilityCastRange"])
    
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    
    
    --self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
    local enemyName=entry.hero_name
    local enemySpell=entry.spell_name
    local preCastDelay=self.castDelay
    local afterCastDelay=self.afterCastDelay+castPoint
    local spawnRange=range
    local maxHoldTime=parseQuadroValue(abilityKV["AbilityValues"]["brew_time"]["value"])
    local holdTime=RandomFloat(0.5,maxHoldTime-0.2)
    local damageDelay=holdTime+(range-self.respawnOffset-50)/projectileSpeed--50 is hull sizes i guess
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		unit:UpgradeAbility(ability)
         local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        local throwAbility=unit:FindAbilityByName("alchemist_unstable_concoction_throw")
        local randomDelay=self:getRandomDelay()
        local delay=preCastDelay+randomDelay+holdTime
        local blinkCasted=false
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = ability:entindex(),
                    Queue = 1
                })
            end,
        preCastDelay+randomDelay)
        function tryToCast()
            unit:SetContextThink(DoUniqueString("try_cast_ability"),
                function()
                    
                    if self.hardcoreMode and blinkCasted==false then
                        local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                            AbilityIndex = blink:entindex(),
                            Position = self.playerHero:GetAbsOrigin(),
                            Queue = 0
                        })
                        blinkCasted=true
                    end
                    --[[ print(self.playerHero:HasModifier(self.dodgeModifier),self.dodgeModifier) ]]
                    --[[ print(throwAbility:IsCooldownReady(),unit:GetSequence(),self.playerHero:IsUnselectable()) ]]
                    if unit:HasModifier("modifier_alchemist_unstable_concoction") and unit:GetSequence()=="idle" and self.playerHero:IsUnselectable()==false then
                        print('trying to cast',throwAbility:GetAbilityName())

                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                            AbilityIndex = throwAbility:entindex(),
                            TargetIndex = self.playerHero:entindex(),
                            Queue = 1
                        })
                    end
                    delay=0.15
                    if ability:IsCooldownReady()==false then
                        --go to unit removal
                        self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
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
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:nevermore_shadowraze2(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["shadowraze_range"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:lina_laguna_blade(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["damage_delay"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:lion_finger_of_death(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["damage_delay"]["value"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:huskar_life_break(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["charge_speed"])
    local damageDelay=(range-self.respawnOffset-50)/projectileSpeed--50 is hull sizes i guess
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:shadow_demon_demonic_purge(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityDuration"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:skywrath_mage_arcane_bolt(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["AbilityCastRange"]["value"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["bolt_speed"])
    local damageDelay=(range-self.respawnOffset-50)/projectileSpeed--50 is hull sizes i guess
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
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
    local abilityName     = entry.spell_name
    local abilityKV       = DotaDB:GetAbilityKV(abilityName)
    local castPoint       = parseQuadroValue(abilityKV["AbilityCastPoint"])
    local range           = parseQuadroValue(abilityKV["AbilityCastRange"])
    local preFlyTime      = parseQuadroValue(abilityKV["AbilityValues"]["pre_flight_time"])
    local projectileSpeed = parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local acceleration    = parseQuadroValue(abilityKV["AbilityValues"]["acceleration"])

    local travelDistance = range - self.respawnOffset - 180 --there are too much unknown variables to caclulate travel time of rocket, so i put 180 to fit the timebar, havent tested on different ranges
    local flightTime     = calcHomingMissileFlightTime(travelDistance, projectileSpeed, acceleration)
    local damageDelay    = preFlyTime + flightTime

    if self.yashaKaya then
        castPoint = castPoint * self.yashaKayaModifier
    end
    castPoint = castPoint + damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    --[[ Timebar:Prepare(castPoint, self.dodgeDuration, self.timebarExtraTime, self.dodgeCastPoint) ]]
    self:doTargetCast(entry.hero_name, entry.spell_name, self.castDelay, self.afterCastDelay + castPoint, range)
end

function dodge:medusa_mystic_snake(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityValues"]["AbilityCastPoint"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["AbilityCastRange"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["initial_speed"])
    local damageDelay=(range-self.respawnOffset-50)/projectileSpeed*1.15--50 is hull sizes i guess, 1.15 is to match calculations, i think there is something about how snake moves like sin wave
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:mirana_starfall(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0.57
    local range=parseQuadroValue(abilityKV["AbilityValues"]["starfall_radius"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
function dodge:invoker_emp(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"]["value"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    local enemyName=entry.hero_name
    local enemySpell=entry.spell_name
    local preCastDelay=self.castDelay
    local afterCastDelay=self.afterCastDelay+castPoint
    local spawnRange=range
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		local invoke_name="invoker_invoke"
        local wex_name="invoker_wex"
        local invoke = unit:FindAbilityByName(invoke_name)
        invoke:SetLevel(1)
        local wex=unit:FindAbilityByName(wex_name)
        wex:SetLevel(3)
        unit:CastAbilityNoTarget(wex,-1)
        unit:CastAbilityNoTarget(wex,-1)
        unit:CastAbilityNoTarget(wex,-1)
        unit:CastAbilityNoTarget(invoke,-1)
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
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
                self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
					if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
					return nil
				end)
                
            end,
        preCastDelay+self:getRandomDelay())
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:invoker_sun_strike(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    local range=500
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    local enemyName=entry.hero_name
    local enemySpell=entry.spell_name
    local preCastDelay=self.castDelay
    local afterCastDelay=self.afterCastDelay+castPoint
    local spawnRange=range
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		local invoke_name="invoker_invoke"
        local exort_name="invoker_exort"
        local invoke = unit:FindAbilityByName(invoke_name)
        invoke:SetLevel(1)
        local exort=unit:FindAbilityByName(exort_name)
        exort:SetLevel(3)
        unit:CastAbilityNoTarget(exort,-1)
        unit:CastAbilityNoTarget(exort,-1)
        unit:CastAbilityNoTarget(exort,-1)
        unit:CastAbilityNoTarget(invoke,-1)
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
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
                self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
					if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
					return nil
				end)
                
            end,
        preCastDelay+self:getRandomDelay())
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:tiny_toss(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["duration"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    local enemyName=entry.hero_name
    local enemySpell=entry.spell_name
    local preCastDelay=self.castDelay
    local afterCastDelay=self.afterCastDelay+castPoint
    local spawnRange=range
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		
        ability:SetLevel(1)
        local helper_respawn=spawnpoint+Vector(100,0,0)
        local helper_name="npc_dota_creep_goodguys_melee"
	    local helper = CreateUnitByName(helper_name,helper_respawn,true,nil,nil,DOTA_TEAM_BADGUYS)
        helper:SetAttackCapability(0)
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
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
                self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
					if IsValidEntity(unit) then
                        unit:RemoveSelf()
                        helper:RemoveSelf()
                    end
                    self:cycleEnemies()
					return nil
				end)
                
            end,
        preCastDelay+self:getRandomDelay())
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:medusa_stone_gaze(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["face_duration"])
    local range=parseQuadroValue(abilityKV["AbilityValues"]["AbilityCastRange"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    local enemyName=entry.hero_name
    local enemySpell=entry.spell_name
    local preCastDelay=self.castDelay
    local afterCastDelay=self.afterCastDelay+castPoint
    local spawnRange=range
    --[[ self:doNoTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range) ]]
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=self.playerHero:GetForwardVector()*400+self.playerHero:GetAbsOrigin()
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		unit:UpgradeAbility(ability)
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
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
                self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
					if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
					return nil
				end)
                
            end,
        preCastDelay+self:getRandomDelay())
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:kunkka_ghostship(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local travel_distance=parseQuadroValue(abilityKV["AbilityValues"]["ghostship_distance"])
    local travel_speed=parseQuadroValue(abilityKV["AbilityValues"]["ghostship_speed"])
    local range=parseQuadroValue(abilityKV["AbilityCastRange"])
    local damageDelay=travel_distance/travel_speed
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareZone(castPoint+self.timebarExtraTime,castPoint-self.dodgeDuration-self.dodgeCastPoint,self.dodgeDuration)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay+castPoint,range)
end
