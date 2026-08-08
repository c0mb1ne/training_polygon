if timing == nil then
  timing = class({})
end

function timing:Init()
    self.type="sandbox" -- Define the type of mode
    self.name="timing" -- Name of the gamemode
    self.activated=false -- Whether the mode is activated
    self.Player=nil -- Reference to the player
    self.playerHero=nil -- Reference to the player's hero
    self.trainingPlaceDefault=Vector(-6040.6640625,4100.78564453125,128) -- Location for training
    self.trainingPlace=self.trainingPlaceDefault
    self.spellTable=
    {
        item_cyclone=
        {
            [1]={spell_name="item_meteor_hammer",hero_name="npc_dota_hero_riki",level=1,aghs=false,shard=false,is_ability=false,need_helper=false},
            [2]={spell_name="axe_berserkers_call",hero_name="npc_dota_hero_axe",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [3]={spell_name="centaur_hoof_stomp",hero_name="npc_dota_hero_centaur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [4]={spell_name="earth_spirit_boulder_smash",hero_name="npc_dota_hero_earth_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [5]={spell_name="earthshaker_fissure",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [6]={spell_name="earthshaker_enchant_totem",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [8]={spell_name="earthshaker_echo_slam",hero_name="npc_dota_hero_earthshaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [9]={spell_name="elder_titan_echo_stomp",hero_name="npc_dota_hero_elder_titan",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [10]={spell_name="ember_spirit_searing_chains",hero_name="npc_dota_hero_ember_spirit",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [11]={spell_name="gyrocopter_call_down",hero_name="npc_dota_hero_gyrocopter",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [12]={spell_name="kunkka_torrent",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [13]={spell_name="kunkka_ghostship",hero_name="npc_dota_hero_kunkka",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [15]={spell_name="magnataur_skewer",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [16]={spell_name="magnataur_reverse_polarity",hero_name="npc_dota_hero_magnataur",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [17]={spell_name="pudge_meat_hook",hero_name="npc_dota_hero_pudge",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [18]={spell_name="sandking_burrowstrike",hero_name="npc_dota_hero_sandking",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [19]={spell_name="slardar_slithereen_crush",hero_name="npc_dota_hero_slardar",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [20]={spell_name="spirit_breaker_charge_of_darkness",hero_name="npc_dota_hero_spirit_breaker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [21]={spell_name="tidehunter_ravage",hero_name="npc_dota_hero_tidehunter",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [22]={spell_name="tusk_snowball",hero_name="npc_dota_hero_tusk",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [23]={spell_name="bloodseeker_blood_bath",hero_name="npc_dota_hero_bloodseeker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [24]={spell_name="lone_druid_savage_roar",hero_name="npc_dota_hero_lone_druid",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [25]={spell_name="meepo_poof",hero_name="npc_dota_hero_meepo",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [26]={spell_name="mirana_arrow",hero_name="npc_dota_hero_mirana",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [27]={spell_name="monkey_king_boundless_strike",hero_name="npc_dota_hero_monkey_king",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [28]={spell_name="nyx_assassin_impale",hero_name="npc_dota_hero_nyx_assassin",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [29]={spell_name="pangolier_shield_crash",hero_name="npc_dota_hero_pangolier",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [30]={spell_name="nevermore_shadowraze1",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [31]={spell_name="nevermore_shadowraze2",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [32]={spell_name="nevermore_shadowraze3",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [33]={spell_name="nevermore_requiem",hero_name="npc_dota_hero_nevermore",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [34]={spell_name="ancient_apparition_cold_feet",hero_name="npc_dota_hero_ancient_apparition",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [35]={spell_name="ancient_apparition_ice_blast",hero_name="npc_dota_hero_ancient_apparition",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [36]={spell_name="dark_seer_vacuum",hero_name="npc_dota_hero_dark_seer",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [37]={spell_name="dark_willow_cursed_crown",hero_name="npc_dota_hero_dark_willow",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [38]={spell_name="death_prophet_silence",hero_name="npc_dota_hero_death_prophet",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [39]={spell_name="invoker_emp",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [40]={spell_name="invoker_chaos_meteor",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [41]={spell_name="invoker_sun_strike",hero_name="npc_dota_hero_invoker",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [42]={spell_name="leshrac_split_earth",hero_name="npc_dota_hero_leshrac",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [43]={spell_name="lina_light_strike_array",hero_name="npc_dota_hero_lina",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [44]={spell_name="lion_impale",hero_name="npc_dota_hero_lion",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [45]={spell_name="puck_waning_rift",hero_name="npc_dota_hero_puck",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [46]={spell_name="pugna_nether_blast",hero_name="npc_dota_hero_pugna",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [47]={spell_name="visage_summon_familiars",hero_name="npc_dota_hero_visage",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [48]={spell_name="warlock_rain_of_chaos",hero_name="npc_dota_hero_warlock",level=1,aghs=false,shard=false,is_ability=true,need_helper=false},
            [49]={spell_name="windrunner_shackleshot",hero_name="npc_dota_hero_windrunner",level=1,aghs=false,shard=false,is_ability=true,need_helper=false}
        }
    }
    self.spellTable.shadow_demon_disruption = self.spellTable.item_cyclone
    self.spellTable.obsidian_destroyer_astral_imprisonment = self.spellTable.item_cyclone
    self.spellTable.item_aegis = self.spellTable.item_cyclone
    self.spellTable.skeleton_king_reincarnation = self.spellTable.item_cyclone
    --declaring spells this way, so we can declare different lists of spells to different types of timings
    --for now let them be the same
    --bot npcs for types:
    self.unitTable = {
        item_cyclone = "npc_dota_hero_lion",
        shadow_demon_disruption = "npc_dota_hero_shadow_demon",
        obsidian_destroyer_astral_imprisonment = "npc_dota_hero_obsidian_destroyer",
        item_aegis = "npc_dota_hero_ursa",
        skeleton_king_reincarnation = "npc_dota_hero_skeleton_king",
        
    }
    --delays calculations
    local cycloneKV=DotaDB:GetItemKV("item_cyclone")
    local cycloneCastpoint=parseQuadroValue(cycloneKV['AbilityCastPoint'])
    local cycloneDuration=parseQuadroValue(cycloneKV['AbilityValues']['cyclone_duration'])
    local disruptionKV=DotaDB:GetAbilityKV("shadow_demon_disruption")
    local disruptionCastpoint=parseQuadroValue(disruptionKV['AbilityCastPoint'])
    local disruptionDuration=parseQuadroValue(disruptionKV['AbilityValues']['disruption_duration']['value'])
    --[[ local astralKV=DotaDB:GetAbilityKV("obsidian_destroyer_astral_imprisonment")
    local astralCastpoint=parseQuadroValue(astralKV["AbilityCastPoint"])
    local astralDuration=parseQuadroValue(astralKV["AbilityValues"]["prison_duration"]) ]]
    local aegisKV=DotaDB:GetItemKV("item_aegis")
    local aegisDuration=parseQuadroValue(aegisKV["AbilityValues"]["reincarnate_time"])
    local wkResKV=DotaDB:GetAbilityKV("skeleton_king_reincarnation")
    local wkResKVDuration=parseQuadroValue(wkResKV['AbilityValues']['reincarnate_time'])
    self.delayTable={
        item_cyclone = cycloneCastpoint+cycloneDuration,
        shadow_demon_disruption = disruptionCastpoint+disruptionDuration,
        obsidian_destroyer_astral_imprisonment = 0, --has different duration depends on level, need exception approach
        item_aegis = aegisDuration,
        skeleton_king_reincarnation = wkResKVDuration,
        
    }
    self.actionsTable={
        item_cyclone = "item_cyclone_cycle",
        shadow_demon_disruption = "shadow_demon_disruption_cycle",
        obsidian_destroyer_astral_imprisonment = "obsidian_destroyer_astral_imprisonment_cycle",
        item_aegis = "item_aegis_cycle",
        skeleton_king_reincarnation = "skeleton_king_reincarnation_cycle",
        
    }
    self.hurtModifiers={
        "modifier_axe_berserkers_call",
        "modifier_item_meteor_hammer_burn",
    }
    self.invulModifiers={
        "modifier_eul_cyclone",
        "modifier_shadow_demon_disruption",
        "modifier_obsidian_destroyer_astral_imprisonment_prison"
    }
    --register listeners here
    CustomGameEventManager:RegisterListener("get_timing_spell_table", function(_, event)
        timing:SendSpellTable()
    end)
    CustomGameEventManager:RegisterListener("get_timing_respawn_pos", function(_, event)
        timing:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("timing_training_end", function(_, event)
        timing:PrepareDeactivate()
    end)
    self.currentTimingType=nil
    self.selectedSpell=nil
    self.playerHero=nil
    self.enemyHeroName=nil
    self.enemyHero=nil
    self.treeCutTimer=nil
    self.cycleCooldown=2
    self.trainingItem=nil
    self.trainingSpell=nil
    self.eulBotCast=nil
    self.enemyActionTimer=nil
    self.timebarExtraTime=1
    self.castDelay=1
    self.yashaKaya=false
    self.yashaKayaModifier=0.75
    self.cycleCastDuration=0
    self.timebarGreenZone=0.1
    self.enemyGotHurt=false
    self.enemyHurtTime=0
    self.invulOutTime=0
    self.deactivateCalled=false
    self.firstCycle=true
    self.manualEul=nil
end
function timing:Prepare(args)
    print("[Timing] Preparing gamemode")
    precache:clearTable()
    --[[ print("[Timing] Selected type:",args.timingType)
    print("[Timing] Selected spell:",args.selectedSpell) ]]
    local timingType = args.timingType or "item_cyclone"
    local selectedSpells = args.selectedSpell or {}
    print("[Timing] Selected type:",timingType)
    DeepPrintTable(args.selectedSpell)
    local enemyHero = self.unitTable[timingType]
    local playerHero
    for k,v in pairs(args.selectedSpell) do
        playerHero=v.hero_name
    end
    
    print("[Timing] Player hero:",playerHero)
    print("[Timing] Enemy hero:",enemyHero)
    precache:PrecacheAddPlayerUnitToList({playerHero})
    precache:PrecacheAddUnitToList({enemyHero})
    precache:doPrecache(function()
        timing:StartGame(args)
    end)
end
function timing:StartGame(args)
    print("[Timing] Starting game after precache")
    self.activated = true
    local playerHero
    for k,v in pairs(args.selectedSpell) do
        playerHero=v.hero_name
        self.selectedSpell=v
    end
    self.deactivateCalled=false
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    Timebar:Show()
    self.Player=PlayerResource:GetPlayer(0)
    self.currentTimingType=args.timingType or "item_cyclone"
    self.cycleCastDuration=self.delayTable[self.currentTimingType]
    --exception for durations depending on skill level
    self.cycleSpellLevel=tonumber(args['abilityLevel'])
    if self.currentTimingType=="obsidian_destroyer_astral_imprisonment" then
        local astralKV=DotaDB:GetAbilityKV("obsidian_destroyer_astral_imprisonment")
        local astralCastpoint=parseQuadroValue(astralKV["AbilityCastPoint"])
        local astralDuration=parseQuadroValue(astralKV["AbilityValues"]["prison_duration"]["value"],self.cycleSpellLevel)
        self.cycleCastDuration=astralCastpoint+astralDuration
    end
    if args.helperMode==1 then
        self.eulBotCast=true
    else
        self.eulBotCast=false
    end
    self.enemyHeroName = self.unitTable[self.currentTimingType]
    local old_hero=self.Player:GetAssignedHero()
    local new_hero=playerHero
    self.playerHero=replaceHero(old_hero,new_hero)
    local pos = args.respawnPos
    self.trainingPlace = Vector(
        tonumber(pos["0"]),
        tonumber(pos["1"]),
        tonumber(pos["2"])
    )
    self.treeCutTimer=Timers:CreateTimer(0, function()
        if args['destroyTrees']==1 then
            GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
        end
        return 4
    end)
    self.firstCycle=true
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    local enemyRespawnPlace=randomCirclePosition(400,self.playerHero)
    local enemyCaster=CreateUnitByNameAsync(self.enemyHeroName,enemyRespawnPlace,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetAttackCapability(0)
        unit:SetBaseManaRegen(100)
        unit:SetBaseHealthRegen(100)
        self[self.actionsTable[self.currentTimingType]](self,unit)
        self.enemyHero=unit
        self['timebar_'..self.selectedSpell.spell_name](self)--preparing timebar here
        return unit
    end)
    --[[ print('self.selectedSpell.is_ability',self.selectedSpell.is_ability) ]]
    if self.selectedSpell.is_ability==0 then
        self.trainingItem=CreateItem(self.selectedSpell.spell_name,self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.trainingItem)
    else
        self.trainingSpell=self.playerHero:FindAbilityByName(self.selectedSpell.spell_name)
        self.trainingSpell:SetLevel(self.selectedSpell.level)
        --add aghanim and shard here  
    end
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    
end

function timing:OnStartOfCycle()
    --can do result check here
    if self.deactivateCalled then
        self:Deactivate()
        return true
    end
    
    if self.firstCycle==false then
        if self.enemyGotHurt then
            print('enemyHurtTime',self.enemyHurtTime)
            print('invulOutTime',self.invulOutTime)
            local delay=self.enemyHurtTime-self.invulOutTime
            delay=math.floor(delay*1000)/1000
            Notifications:Show('green','good, delay:'..delay,self.selectedSpell.spell_name)
        else
            Notifications:Show('red','bad',self.selectedSpell.spell_name)
        end
        if self.trainingItem~=nil then
            self.trainingItem:EndCooldown()
        end
        if self.trainingSpell~=nil then
            self.trainingSpell:EndCooldown()
        end
        if self.manualEul~=nil then
            self.manualEul:EndCooldown()
        end
        self.enemyGotHurt=false
    end
    self.firstCycle=false
end

function timing:item_cyclone_cycle(unit)
    if self.eulBotCast then
        local eul=CreateItem("item_cyclone",unit,unit)
        unit:AddItem(eul)
        self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
            self:OnStartOfCycle()
            if IsValidEntity(unit) then
                eul:EndCooldown()
                unit:SetContextThink(DoUniqueString("cast_ability"), function()
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                        AbilityIndex = eul:entindex(),
                        TargetIndex = unit:entindex(),
                        Queue = 1
                    })
                end,0)
                return self.castDelay+self.cycleCastDuration
            else
                return nil
            end
        end)
    else
        self.manualEul=CreateItem("item_cyclone",self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.manualEul)
    end
    print('item cyclone cycle called')
end
function timing:shadow_demon_disruption_cycle(unit)
    local disruption=unit:FindAbilityByName(self.currentTimingType)
    disruption:SetLevel(1)
    self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
        self:OnStartOfCycle()
        if IsValidEntity(unit) then
            disruption:EndCooldown()
            unit:SetContextThink(DoUniqueString("cast_ability"), function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = disruption:entindex(),
                    TargetIndex = unit:entindex(),
                    Queue = 1
                })
            end,0)
            return self.castDelay+self.cycleCastDuration
        else
            return nil
        end
    end)
    --print('shadow_demon_disruption_cycle called')
end
function timing:obsidian_destroyer_astral_imprisonment_cycle(unit)
    local prison=unit:FindAbilityByName(self.currentTimingType)
    prison:SetLevel(self.cycleSpellLevel)
    self.enemyActionTimer=Timers:CreateTimer(self.castDelay,function()
        self:OnStartOfCycle()
        if IsValidEntity(unit) then
            prison:EndCooldown()
            unit:SetContextThink(DoUniqueString("cast_ability"), function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = prison:entindex(),
                    TargetIndex = unit:entindex(),
                    Queue = 1
                })
            end,0)
            return self.castDelay+self.cycleCastDuration
        else
            return nil
        end
    end)
end
function timing:item_aegis_cycle(unit)
    print('item_aegis_cycle called')
end
function timing:skeleton_king_reincarnation_cycle(unit)
    print('skeleton_king_reincarnation_cycle called')
end
function timing:item_travel_boots_cycle(unit)
    print('item_travel_boots_cycle called')
end
function timing:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    --[[ print("[Timing] NPC spawned:",npc:GetUnitName()) ]]
    if npc:IsIllusion() then
        Timers:CreateTimer({
            endTime = FrameTime(), 
            callback = function()
                npc:RemoveSelf()
            end
        })
    end
end

function timing:timebar_axe_berserkers_call()
    local abilityName="axe_berserkers_call"
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=0
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:Prepare(self.cycleCastDuration-castPoint+self.timebarGreenZone,self.timebarGreenZone,self.castDelay+castPoint-self.timebarGreenZone,0)
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
    Timebar:Prepare(self.cycleCastDuration-castPoint+self.timebarGreenZone,self.timebarGreenZone,self.castDelay+castPoint-self.timebarGreenZone,0)
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
    Timebar:Prepare(self.cycleCastDuration-castPoint+self.timebarGreenZone,self.timebarGreenZone,self.castDelay+castPoint-self.timebarGreenZone,0)
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
    local distanceOffset=projectileWidth+50
    print("distanceOffset",distanceOffset)
    Timebar:PrepareDynamic(self.cycleCastDuration-castPoint+self.timebarGreenZone, self.timebarGreenZone, self.castDelay+castPoint-self.timebarGreenZone, 0, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
    --[[ Timebar:Prepare(self.cycleCastDuration-castPoint+self.timebarGreenZone,self.timebarGreenZone,self.castDelay+castPoint-self.timebarGreenZone,0) ]]
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
    local distanceOffset=projectileWidth+50
    print("distanceOffset",distanceOffset)
    Timebar:PrepareDynamic(self.cycleCastDuration-castPoint+self.timebarGreenZone, self.timebarGreenZone, self.castDelay+castPoint-self.timebarGreenZone, 0, self.playerHero, self.enemyHero, projectileSpeed,distanceOffset)
    --[[ Timebar:Prepare(self.cycleCastDuration-castPoint+self.timebarGreenZone,self.timebarGreenZone,self.castDelay+castPoint-self.timebarGreenZone,0) ]]
end
function timing:OrderFilter(event)
    if event['issuer_player_id_const']==-1 then
        --bot order
        if event['entindex_ability']~=0 then
            local ability=EntIndexToHScript(event['entindex_ability'])
            if ability~=nil then
                Timebar:Start()
            end
        end
    else
        --player order
        local ability=EntIndexToHScript(event['entindex_ability'])
        if ability~=nil then
            if ability==self.trainingSpell or ability==self.trainingItem then
                Timebar:PlayerAction()
            end
        end
    end
    return true
end

function timing:ModifierGained(event)
    --[[ DeepPrintTable(event) ]]
    if string_in_array(event.name_const,self.hurtModifiers) then
        event.duration=0.2
        if self.enemyGotHurt==false then
            self.enemyGotHurt=true
            print('[Timing] player hurt by modifier',event.name_const)
            self.enemyHurtTime=Time()
            Timebar:BlueLine()
        end
        
        return true
    end
    --catching frame where enemy became able to get hit
    if string_in_array(event.name_const,self.invulModifiers) then
        
        Timers:CreateTimer(FrameTime(),function()
            if IsValidEntity(self.enemyHero) then
                if self.enemyHero:HasModifier(event.name_const) then
                    return FrameTime()
                else
                    --print('modifier expired')
                    if self.eulBotCast==false then
                        self.firstCycle=false
                        if event.name_const=="modifier_eul_cyclone" then
                            Timers:CreateTimer(self.castDelay,function()
                                self:OnStartOfCycle()
                            end)
                        end
                        
                    end
                    
                    self.invulOutTime=Time()
                    return nil
                end
            else
                return nil
            end
        end)
        
        return true
    end
    return true
end
function timing:OnEntityHurt(keys)
    --[[ DeepPrintTable(keys) ]]
    local entCause=nil
    local entVictim=nil
    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        entCause = EntIndexToHScript(keys.entindex_attacker)
        entVictim = EntIndexToHScript(keys.entindex_killed)
    end
    if entVictim~=nil then
        if keys.damage~=0 and entVictim==self.playerHero then
            if self.enemyGotHurt==false then
                self.enemyGotHurt=true
                print('[Timing] player hurt by damage')
                self.enemyHurtTime=Time()
                Timebar:BlueLine()
            end
        end
    end
end

function timing:OnAbilityUsed(keys)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local abilityname = keys.abilityname
    --[[ print("abilityname",abilityname) ]]
    if abilityname=="item_cyclone" and self.eulBotCast==false then
        Timebar:Start()
    end
end

function timing:SendSpellTable()
    CustomGameEventManager:Send_ServerToAllClients("timing_spell_table",{data=self.spellTable})
end
function timing:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("timing_respawn_pos",{pos={self.trainingPlace.x,self.trainingPlace.y,self.trainingPlace.z}})
end

function timing:PrepareDeactivate()
    self.activated=false
    self.deactivateCalled=true
    CustomGameEventManager:Send_ServerToAllClients("clear_hud",{})
    if self.eulBotCast==false and self.currentTimingType=="item_cyclone" then
        self:Deactivate()
    end
end

function timing:Deactivate()
    if self.enemyActionTimer~=nil then
        Timers:RemoveTimer(self.enemyActionTimer)
    end
    self.enemyHero:RemoveSelf()
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("clear_hud",{})
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu",{})
end

timing:Init()
GamemodeManager:RegisterMode(timing.name,timing,timing.type)