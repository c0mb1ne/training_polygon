function timing:timebar_axe_berserkers_call()
    local abilityName="axe_berserkers_call"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","windup_time"}, "0.5")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#581d15",abilityName)
end

function timing:timebar_item_meteor_hammer()
    local abilityName="item_meteor_hammer"
    local castPoint=0
    local channelTime=DotaDB:GetItemValue(abilityName, {"AbilityChannelTime"}, "2")
    local landTime=DotaDB:GetItemValue(abilityName, {"AbilityValues","land_time"}, "0.5")
    local damageDelay=channelTime+landTime
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#0099b4",abilityName)
end

function timing:timebar_pudge_meat_hook()
    local abilityName="pudge_meat_hook"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3 0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","hook_speed","value"},"1600")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","hook_width"}, "100")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#004110",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_mirana_arrow()
    local abilityName="mirana_arrow"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.5 0.5 0.5 0.5")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","arrow_speed"}, "900")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","arrow_width","value"}, "115")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#002ab4",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_earth_spirit_boulder_smash()
    local abilityName="earth_spirit_boulder_smash"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, nil)
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","speed"})
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","radius","value"}, nil)
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#003a05",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_earth_spirit_rolling_boulder()
    local abilityName="earth_spirit_rolling_boulder"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, nil)
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","speed"})
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, nil)
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","radius","value"}, nil)
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#003a05",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_earth_spirit_rolling_boulder_stone()
    local abilityName="earth_spirit_rolling_boulder"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, nil)
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","rock_speed"})
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, nil)
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","radius","value"}, nil)
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#003a05",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_earthshaker_fissure()
    local abilityName="earthshaker_fissure"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.69 0.69 0.69 0.69")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.5")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0 0 0 0")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.4")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityChannelTime"}, "1.29")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00804a",abilityName)
end

function timing:timebar_ember_spirit_searing_chains()
    local abilityName="ember_spirit_searing_chains"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#a53400",abilityName)
end

function timing:timebar_gyrocopter_call_down()
    local abilityName="gyrocopter_call_down"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","missile_delay_tooltip"}, "2")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#724400",abilityName)
end

function timing:timebar_kunkka_torrent()
    local abilityName="kunkka_torrent"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.4")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, "1.6 1.6 1.6 1.6")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#0098d4",abilityName)
end

function timing:timebar_kunkka_ghostship()
    local abilityName="kunkka_ghostship"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, nil)
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","tooltip_delay"}, nil)
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#0098d4",abilityName)
end

function timing:timebar_magnataur_skewer()
    local abilityName="magnataur_skewer"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3 0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","skewer_speed"},"900")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","skewer_radius","value"}, "145")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#006cb4",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_sandking_burrowstrike()
    local abilityName="sandking_burrowstrike"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.0 0.0 0.0 0.0")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","burrow_speed"},"2000")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","burrow_width","value"}, "150")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#8b4f00",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_slardar_slithereen_crush()
    local abilityName="slardar_slithereen_crush"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.25")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.1")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","movement_speed","value"}, "275 325 375 425")+100
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","bash_radius","value"}, "300 300 300 300")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"rgb(0, 150, 187)",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_tidehunter_ravage()
    local abilityName="tidehunter_ravage"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","speed"}, "725")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=250
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.1 0.1 0.1 0.1")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","snowball_speed"}, "575 600 625 650", level)
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","snowball_windup_radius","value"}, "100")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#9bd7ff",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_bloodseeker_blood_bath()
    local abilityName="bloodseeker_blood_bath"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, "2.59")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#3f0000",abilityName)
end

function timing:timebar_lone_druid_savage_roar()
    local abilityName="lone_druid_savage_roar"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.1")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "1.5")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.4")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","speed"},"1600")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","width","value"}, "140")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#ff8484",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_pangolier_shield_crash()
    local abilityName="pangolier_shield_crash"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.0 0.0 0.0 0.0")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","jump_duration"}, "0.4")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#d44401",abilityName)
end

function timing:timebar_nevermore_shadowraze1()
    local abilityName="nevermore_shadowraze1"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.55")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.55")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.55")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "1.67 1.67 1.67")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","requiem_line_speed"},"700 700 700")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","requiem_line_width_start","value"}, "125")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#7c0000",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_ancient_apparition_ice_blast()
    announcer:Show({message="#warningTimebar",duration=5})
    local abilityName="ancient_apparition_ice_blast"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.01 0.01 0.01")
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","speed"},"1500 1500 1500")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","radius_min","value"}, "300")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#4dafff",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_dark_seer_vacuum()
    local abilityName="dark_seer_vacuum"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.4")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.2")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.05")
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay","value"}, "2.9")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.05")
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, "1.7")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#c59700",abilityName)
end

function timing:timebar_leshrac_split_earth()
    local abilityName="leshrac_split_earth"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.7 0.7 0.7 0.7")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, "0.349")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00a396",abilityName)
end

function timing:timebar_lina_light_strike_array()
    local abilityName="lina_light_strike_array"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.45 0.45 0.45 0.45")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","light_strike_array_delay_time","value"}, "0.5")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#c55900",abilityName)
end

function timing:timebar_lion_impale()
    local abilityName="lion_impale"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.3 0.3 0.3 0.3")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","speed"},"2800")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","width","value"}, "140")
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#b87d00",abilityName, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
end

function timing:timebar_puck_waning_rift()
    local abilityName="puck_waning_rift"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.1")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#4c2ef8",abilityName)
end

function timing:timebar_pugna_nether_blast()
    local abilityName="pugna_nether_blast"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.2 0.2 0.2 0.2")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","delay"}, "0.8")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#034e00",abilityName)
end

function timing:timebar_visage_summon_familiars()
    local abilityName="visage_summon_familiars_stone_form"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0")
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","stun_delay"}, "0.55")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#002874",abilityName)
end

function timing:timebar_warlock_rain_of_chaos()
    local abilityName="warlock_rain_of_chaos"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.5 0.5 0.5")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","stun_delay"}, "0.5")
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
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.15")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local projectileSpeed=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","arrow_speed","value"},"1650")
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    local projectileWidth=2
    local distanceOffset=projectileWidth/2
    Timebar:PrepareDynamic(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#00750a",abilityName, self.playerHero, self.spiritBreakerHelper, projectileSpeed,distanceOffset)
end

function timing:timebar_snapfire_firesnap_cookie()
    local abilityName="snapfire_firesnap_cookie"
    local castPoint=DotaDB:GetAbilityValue(abilityName, {"AbilityCastPoint"}, "0.2")
    if self.rubickMode then
        castPoint=self.playerHero:FindAbilityByName(abilityName):GetCastPoint()
    end
    local damageDelay=DotaDB:GetAbilityValue(abilityName, {"AbilityValues","jump_duration","value"}, "0.4839999973774")
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:PrepareSingleMark(self.castDelay+self.cycleCastDuration,self.cycleCastDuration-castPoint,"#691e00",abilityName)
end