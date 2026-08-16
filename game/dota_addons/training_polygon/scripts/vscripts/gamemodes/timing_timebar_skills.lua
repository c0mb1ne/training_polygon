--this take too much space and its more ez to work with when they are in separate file
function timing:timebar_axe_berserkers_call()
    local abilityName="axe_berserkers_call"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#9e2727",abilityName)
end
function timing:timebar_centaur_hoof_stomp()
    local abilityName="centaur_hoof_stomp"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityValues"]["windup_time"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#581d15",abilityName)
end
function timing:timebar_item_meteor_hammer()
    local abilityName="item_meteor_hammer"
    local abilityKV = DotaDB:GetItemKV(abilityName)
    local castPoint=0
    local channelTime=parseQuadroValue(abilityKV["AbilityChannelTime"])
    local landTime=parseQuadroValue(abilityKV["AbilityValues"]["land_time"])
    local damageDelay=channelTime+landTime
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#0099b4",abilityName)
end
function timing:timebar_pudge_meat_hook()
    local abilityName="pudge_meat_hook"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["hook_speed"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["hook_width"])
    local distanceOffset=projectileWidth/2
    --[[ print("distanceOffset",distanceOffset) ]]
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#004110",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
    
end
function timing:timebar_mirana_arrow()
    local abilityName="mirana_arrow"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["arrow_speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["arrow_width"]["value"])
    local distanceOffset=projectileWidth/2
    --[[ print("distanceOffset",distanceOffset) ]]
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#002ab4",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_earth_spirit_boulder_smash()
    local abilityName="earth_spirit_boulder_smash"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local distanceOffset=projectileWidth/2
    --[[ print("distanceOffset",distanceOffset) ]]
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#003a05",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_earth_spirit_rolling_boulder()
    local abilityName="earth_spirit_rolling_boulder"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#003a05",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_earth_spirit_rolling_boulder_stone() --called from OnNPCSpawned when stone is placed
    local abilityName="earth_spirit_rolling_boulder"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["rock_speed"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["radius"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#003a05",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_earthshaker_fissure()
    local abilityName="earthshaker_fissure"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#976700",abilityName)
end
function timing:timebar_earthshaker_enchant_totem()
    local aftershock=self.playerHero:FindAbilityByName("earthshaker_aftershock")
    aftershock:SetLevel(1)
    local abilityName="earthshaker_enchant_totem"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#976700",abilityName)
end
function timing:timebar_earthshaker_echo_slam()
    local aftershock=self.playerHero:FindAbilityByName("earthshaker_aftershock")
    aftershock:SetLevel(1)
    local abilityName="earthshaker_echo_slam"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#976700",abilityName)
end
function timing:timebar_elder_titan_echo_stomp()
    local abilityName="elder_titan_echo_stomp"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityChannelTime"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00804a",abilityName)
end
function timing:timebar_ember_spirit_searing_chains()
    local abilityName="ember_spirit_searing_chains"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#a53400",abilityName)
end
function timing:timebar_gyrocopter_call_down()
    local abilityName="gyrocopter_call_down"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["missile_delay_tooltip"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#724400",abilityName)
end
function timing:timebar_kunkka_torrent()
    local abilityName="kunkka_torrent"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#0098d4",abilityName)
end
function timing:timebar_kunkka_ghostship()
    local abilityName="kunkka_ghostship"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["tooltip_delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#0098d4",abilityName)
end
function timing:timebar_magnataur_skewer()
    local abilityName="magnataur_skewer"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["skewer_speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["skewer_radius"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#006cb4",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end