--this take too much space and its more ez to work with when they are in separate file
function timing:timebar_axe_berserkers_call()
    local abilityName="axe_berserkers_call"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#9e2727",abilityName)
end
function timing:timebar_magnataur_reverse_polarity()
    local abilityName="magnataur_reverse_polarity"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#274d9e",abilityName)
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
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
function timing:timebar_sandking_burrowstrike()
    local abilityName="sandking_burrowstrike"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["burrow_speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["burrow_width"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#8b4f00",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_slardar_slithereen_crush()
    local abilityName="slardar_slithereen_crush"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#2500ca",abilityName)
end
function timing:timebar_spirit_breaker_charge_of_darkness()
    --requires some calculation for timebar beacause of weird speed increase formula, dont wanna do it right now
    --for now let it be pure speculative
    announcer:Show({message="#warningTimebar",duration=5})
    if self.spiritBreakerHelper==nil then
        self.spiritBreakerHelper=CreateUnitByName("npc_dota_neutral_centaur_khan_custom",self.trainingPlace+Vector(100,0,0),true,self.playerHero,self.playerHero,DOTA_TEAM_BADGUYS)
        self.spiritBreakerHelper:SetIdleAcquire(false)
        self.spiritBreakerHelper:Stop()
        self.spiritBreakerHelper:SetControllableByAllPlayers(true)
        self.spiritBreakerHelper:SetBaseHealthRegen(100)
    end
    if self.spiritBreakerSpeedModifier==nil then
        self.spiritBreakerSpeedModifier = self.playerHero:AddNewModifier(
            self.playerHero, 
            nil, 
            "modifier_custom_speed_boost_flat", 
            {}
        )
    else
        print('failer to add speed modifier')
    end
    CustomGameEventManager:Send_ServerToAllClients("show_spirit_braker_settings",{})
    local bash=nil
    if self.rubickMode then
        bash=self.playerHero:AddAbility("spirit_breaker_greater_bash")
    else
        bash=self.playerHero:FindAbilityByName("spirit_breaker_greater_bash")
    end
    bash:SetLevel(1)
    self.spiritBreakerSkill1=self.playerHero:FindAbilityByName("spirit_breaker_charge_of_darkness")
    self.spiritBreakerSkill2=self.playerHero:FindAbilityByName("spirit_breaker_bulldoze")
    if self.spiritBreakerSkill2~=nil then
        self.spiritBreakerSkill2:SetLevel(1)
    end
    local abilityName="spirit_breaker_charge_of_darkness"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["movement_speed"]["value"])+100
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["bash_radius"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"rgb(0, 150, 187)",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_tidehunter_ravage()
    local abilityName="tidehunter_ravage"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=250--havent found any value in kv, lets trust liquipedia
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00aa63",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_tusk_snowball(recalculate)
    if recalculate~=true then
        CustomGameEventManager:Send_ServerToAllClients("show_tuskar_settings",{})
        if self.spiritBreakerHelper==nil then
            self.spiritBreakerHelper=CreateUnitByName("npc_dota_neutral_centaur_khan_custom",self.trainingPlace+Vector(100,0,0),true,self.playerHero,self.playerHero,DOTA_TEAM_BADGUYS)
            self.spiritBreakerHelper:SetIdleAcquire(false)
            self.spiritBreakerHelper:Stop()
            self.spiritBreakerHelper:SetControllableByAllPlayers(true)
            self.spiritBreakerHelper:SetBaseHealthRegen(100)
        end
    end
    local abilityName="tusk_snowball"
    local level=self.playerHero:FindAbilityByName(abilityName):GetLevel()
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["snowball_speed"],level)
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["snowball_windup_radius"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#9bd7ff",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_bloodseeker_blood_bath()
    local abilityName="bloodseeker_blood_bath"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#3f0000",abilityName)
end
function timing:timebar_lone_druid_savage_roar()
    local abilityName="lone_druid_savage_roar"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#008547",abilityName)
end
function timing:timebar_meepo_poof()
    local abilityName="meepo_poof"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#aaac50",abilityName)
end
function timing:timebar_monkey_king_boundless_strike()
    local abilityName="monkey_king_boundless_strike"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#d45f00",abilityName)
end
function timing:timebar_nyx_assassin_impale()
    local abilityName="nyx_assassin_impale"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["width"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#ff8484",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_pangolier_shield_crash()
    local abilityName="pangolier_shield_crash"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["jump_duration"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#d44401",abilityName)
end
function timing:timebar_nevermore_shadowraze1()
    local abilityName="nevermore_shadowraze1"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#7c0000",abilityName)
end
function timing:timebar_nevermore_shadowraze2()
    local abilityName="nevermore_shadowraze2"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#7c0000",abilityName)
end
function timing:timebar_nevermore_shadowraze3()
    local abilityName="nevermore_shadowraze3"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#7c0000",abilityName)
end
function timing:timebar_nevermore_requiem()
    local abilityName="nevermore_requiem"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["requiem_line_speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["requiem_line_width_start"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#7c0000",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_ancient_apparition_ice_blast()
    --requires messing with timebar
    --dont wanna make a formulas for this right now, maybe later
    announcer:Show({message="#warningTimebar",duration=5})
    local abilityName="ancient_apparition_ice_blast"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["radius_min"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#4dafff",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_dark_seer_vacuum()
    local abilityName="dark_seer_vacuum"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#360099",abilityName)
end
function timing:timebar_death_prophet_silence()
    local abilityName="death_prophet_silence"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00962d",abilityName)
end
function timing:timebar_invoker_emp()
    local wex=self.playerHero:FindAbilityByName("invoker_wex")
    wex:SetLevel(1)
    local abilityName="invoker_emp"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#96005c",abilityName)
end
function timing:timebar_invoker_sun_strike()
    local exort=self.playerHero:FindAbilityByName("invoker_exort")
    exort:SetLevel(1)
    local abilityName="invoker_sun_strike"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#c59700",abilityName)
end
function timing:timebar_leshrac_split_earth()
    local abilityName="leshrac_split_earth"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00a396",abilityName)
end
function timing:timebar_lina_light_strike_array()
    local abilityName="lina_light_strike_array"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["light_strike_array_delay_time"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#c55900",abilityName)
end
function timing:timebar_lion_impale()
    local abilityName="lion_impale"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["speed"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=parseQuadroValue(abilityKV["AbilityValues"]["width"]["value"])
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#b87d00",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end
function timing:timebar_puck_waning_rift()
    local abilityName="puck_waning_rift"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#4c2ef8",abilityName)
end
function timing:timebar_pugna_nether_blast()
    local abilityName="pugna_nether_blast"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#034e00",abilityName)
end
function timing:timebar_visage_summon_familiars()
    local abilityName="visage_summon_familiars_stone_form"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["stun_delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#002874",abilityName)
end
function timing:timebar_warlock_rain_of_chaos()
    local abilityName="warlock_rain_of_chaos"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["stun_delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#691e00",abilityName)
end
function timing:timebar_windrunner_shackleshot()
    if self.spiritBreakerHelper==nil then
        self.spiritBreakerHelper=CreateUnitByName("npc_dota_neutral_centaur_khan_custom",self.trainingPlace+Vector(100,0,0),true,self.playerHero,self.playerHero,DOTA_TEAM_BADGUYS)
        self.spiritBreakerHelper:SetIdleAcquire(false)
        self.spiritBreakerHelper:Stop()
        self.spiritBreakerHelper:SetControllableByAllPlayers(true)
        self.spiritBreakerHelper:SetBaseHealthRegen(100)
    end
    local abilityName="windrunner_shackleshot"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=parseQuadroValue(abilityKV["AbilityValues"]["arrow_speed"]["value"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=2--idk
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00750a",abilityName, self.playerHero, self.spiritBreakerHelper, projectileSpeed,distanceOffset)
end
function timing:timebar_snapfire_firesnap_cookie()
    local abilityName="snapfire_firesnap_cookie"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["jump_duration"]["value"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#691e00",abilityName)
end