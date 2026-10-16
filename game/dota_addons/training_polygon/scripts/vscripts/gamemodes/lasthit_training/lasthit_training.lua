--TODO: make serverside check for legitimate buy of item in case of making competetive mode out of this
--for now we dont care
--make towers invulnerable
if lasthit_training == nil then
  lasthit_training = class({})
end

require('gamemodes/lasthit_training/lasthit_training_bot_balance')
function lasthit_training:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "lasthit_training" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero

    -- TODO: define self.spellTable / self.unitTable / self.modifierTable etc. here,
    -- following the pattern used in dodge.lua / timing.lua if this mode needs one

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_lasthit_training_respawn_pos", function(_, event)
        lasthit_training:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("lasthit_training_reset_respawn_pos", function(_, event)
        lasthit_training:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("lasthit_training_training_end", function(_, event)
        lasthit_training:PrepareDeactivate()
    end)

    CustomGameEventManager:RegisterListener("get_lasthit_training_starting_items", function(_, event)
        lasthit_training:SendItemTable()
    end)

    self.deactivateCalled = false
    self.startingItems = {
        DOTA_SUBSHOP_CONSUMABLES = {
            "item_tango",
            "item_flask", 
            "item_faerie_fire",
            "item_blood_grenade",
            "item_clarity",
            "item_enchanted_mango",
            "item_magic_stick",
            "item_ward_observer",
            "item_ward_sentry",
            "item_bottle",
            "item_dust",
            "item_smoke_of_deceit",
        },
        DOTA_SUBSHOP_ATTRIBUTES = {
            "item_branches",
            "item_gauntlets",
            "item_slippers",
            "item_mantle",
            "item_circlet",
            "item_bracer",
            "item_wraith_band",
            "item_null_talisman",
            "item_crown",
            "item_belt_of_strength",
            "item_boots_of_elves",
            "item_robe"
        },
        DOTA_SUBSHOP_RECIPE_BASICS = {
            "item_ring_of_regen",
            "item_sobi_mask",
            "item_ring_of_protection",
            "item_quelling_blade",
            "item_fluffy_hat",
            "item_wizard_hat",
            "item_wind_lace",
            "item_boots",
            "item_orb_of_frost",
            "item_blight_stone",
            "item_orb_of_venom",
            "item_blades_of_attack"
        }
    }
    self.itemLimitTable={}
    self.itemLimitTable["item_tango"]=2--idk why do you even need this but ok
    self.itemLimitTable["item_flask"]=5
    self.itemLimitTable["item_blood_grenade"]=0--let make this 0, who even gonna lasthit with grenade
    self.itemLimitTable["item_clarity"]=5
    self.itemLimitTable["item_enchanted_mango"]=4
    self.itemLimitTable["item_ward_observer"]=2
    self.itemLimitTable["item_ward_sentry"]=2
    self.itemLimitTable["item_smoke_of_deceit"]=2

    --parseQuadroValue(DotaDB:GetItemKV("item_tango")["ItemCost"])
    self.playerHeroName=""
    self.selectedLane=""
    self.selectedSide=""
    self.playerSpawns={
        [DOTA_TEAM_BADGUYS]={
            top=Vector(-5879.5595703125,5738.4077148438,128),
            mid=Vector(-216.69892883301,601.20617675781,128),
            bot=Vector(5786.7495117188,-2833.177734375,128)
        },
        [DOTA_TEAM_GOODGUYS]={
            top=Vector(-6468.7875976563,3327.4189453125,128),
            mid=Vector(-1493.5354003906,-744.01934814453,128),
            bot=Vector(5176.671875,-5708.5913085938,128)
        }
    }
    self.startBuy=nil
    self.waveTimer=nil
    self.creepTrashCan={}
    self.onlyEnemySide=false
    self.randomCreepHp=false
    self.botEnabled=false
    self.botHeroName="npc_dota_hero_sniper"
    self.botEnt=nil
    self.lastHittableCreeps={}
    self.playerDamageTracker=nil
    self.pingLasthittable=true
    self.hpHistory={}
    self.lastCreepHurtDmg={}
    self.lastCreepHurtSrc={}
    self.creepLuckyStrike={}
    self.luckyCheckEnabled=true
    --stat counters:
    self.counters={
        lasthitCounterAA=0,
        lasthitCounterAbil=0,
        denyCounter=0,
        missCounter=0,
        botLastHit=0,
        avgDelayCounter=0,
        luckyStrikes=0,
        lasthitToMissPrecent=0,
        sessionTime=0
    }
    self.delaySum=0
    self.delayCount=0
    self.lastWave={}
    self.botMSModifier = nil
    self.botADModifier = nil
    self.botASModifier = nil
    CustomGameEventManager:RegisterListener("lasthit_training_bot_ms_change", function(eventSourceIndex, args)
        lasthit_training:BotMoveSpeedChange(args)
    end)
    CustomGameEventManager:RegisterListener("lasthit_training_bot_as_change", function(eventSourceIndex, args)
        lasthit_training:BotAttackSpeedChange(args)
    end)
    CustomGameEventManager:RegisterListener("lasthit_training_bot_ad_change", function(eventSourceIndex, args)
        lasthit_training:BotAttackDamageChange(args)
    end)
    self.botWardsPos={
        Vector(-546.03894042969,497.81063842773,128),
        Vector(-6077.0205078125,4995.62890625,128),
        Vector(-6438.8442382813,3897.9162597656,128),
        Vector(6358.568359375,-3521.2277832031,128),
        Vector(5887.6669921875,-5583.138671875,128)
    }
    self.botWardsEnts={}
end

function lasthit_training:Prepare(args)
    print("[TemplateMode] Preparing gamemode")
    precache:clearTable()

    -- TODO: build the list of units this mode needs precached, based on args,
    -- following the unitsToPrecache/unitsAdded pattern from dodge.lua:Prepare()
    local unitsToPrecache = {}
    local defaultHero = args.defaultHero or "npc_dota_hero_antimage"
    local botHero = args.botHero or "npc_dota_hero_sniper"
    precache:PrecacheAddPlayerUnitToList({defaultHero})
    precache:PrecacheAddUnitToList({botHero})

    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        lasthit_training:StartGame(self.pendingArgs)
    end)
end

function lasthit_training:StartGame(args)
    
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
    --for mid game starts at 15 sec after first wave spawn, for other lanes at 25
    --[[ CreepController:SpawnCreepWave25sec(DOTA_TEAM_GOODGUYS,'top','initial')
    CreepController:SpawnCreepWave15sec(DOTA_TEAM_GOODGUYS,'mid','initial')
    CreepController:SpawnCreepWave25sec(DOTA_TEAM_GOODGUYS,'bot','initial')
    CreepController:SpawnCreepWave25sec(DOTA_TEAM_BADGUYS,'top','initial')
    CreepController:SpawnCreepWave15sec(DOTA_TEAM_BADGUYS,'mid','initial')
    CreepController:SpawnCreepWave25sec(DOTA_TEAM_BADGUYS,'bot','initial') ]]
    --[[ CreepController:CalibrateCreepWaveSpawnPositions(10, 15.0) ]]
    self.playerHeroName=args.defaultHero
    self.botHeroName=args.botHero
    if args.selectedSide=="direside" then
        self.selectedSide=DOTA_TEAM_BADGUYS
    else
        self.selectedSide=DOTA_TEAM_GOODGUYS
    end
    if args.selectedLane=="topLane" then
        self.selectedLane="top"
    elseif args.selectedLane=="midLane" then
        self.selectedLane="mid"
    else
        self.selectedLane="bot"
    end
    self.onlyEnemySide=false
    if args['onlyEnemyWave']==1 then
        self.onlyEnemySide=true
    else
        self.onlyEnemySide=false
    end
    self.randomCreepHp=false
    if args['randomCreepHp']==1 then
        self.randomCreepHp=true
    else
        self.randomCreepHp=false
    end
    self.botEnabled=false
    if args['enemyBot']==1 then
        self.botEnabled=true
    else
        self.botEnabled=false
    end
    self.luckyCheckEnabled=false
    if args['luckyCheckEnabled']==1 then
        self.luckyCheckEnabled=true
    else
        self.luckyCheckEnabled=false
    end
    self.Player=PlayerResource:GetPlayer(0)
    local old_hero=self.Player:GetAssignedHero()
    self.playerHero=replaceHero(old_hero,self.playerHeroName)
    if not self.botEnabled then
        self.playerHero:SetBaseHealthRegen(300)
    end
    --[[ self.playerHero:SetBaseManaRegen(300) ]]
    --[[ print('debug:',self.selectedSide,self.selectedLane,self.playerSpawns[self.selectedSide][self.selectedLane]) ]]
    self.playerHero:SetAbsOrigin(self.playerSpawns[self.selectedSide][self.selectedLane])
    --[[ PlayerResource:SetCustomTeamAssignment(args.PlayerID,self.selectedSide) ]]
    self.playerHero:SetTeam(self.selectedSide)
    self.Player=PlayerResource:GetPlayer(0)
    self.Player:SetTeam(self.selectedSide)
    self.startBuy=args.startItems
    --[[ print('start buy:') ]]
    for index,item_name in pairs(self.startBuy) do
        local item=CreateItem(item_name,self.playerHero,self.playerHero)
        self.playerHero:AddItem(item)
    end
    self.playerHero:SetAbilityPoints(1)
    
    local cycleStartTime
    if self.selectedLane=="mid" then
        cycleStartTime=15
    else
        cycleStartTime=5
    end
    self:SpawnCreepWave(DOTA_TEAM_BADGUYS,true)
    self:SpawnCreepWave(DOTA_TEAM_GOODGUYS,true)
    if self.onlyEnemySide==false then
        self.waveTimer=Timers:CreateTimer(cycleStartTime,function()
            self:SpawnCreepWave(DOTA_TEAM_BADGUYS,false)
            self:SpawnCreepWave(DOTA_TEAM_GOODGUYS,false)
            if self.activated then
                return 30
            else
                return nil
            end
        end)
    end
    TowerController:TurnOnAttack()
    Timers:CreateTimer(1,function()
        if self.activated then
            self:UpdateCounters('sessionTime',1)
            return 1
        else
            return
        end
    end)
    if self.botEnabled then
        local botRespawnPlace=self.playerSpawns[5-self.selectedSide][self.selectedLane]
        self.botEnt=lasthit_training_bot_balance:Init(self.botHeroName, botRespawnPlace, 5-self.selectedSide, self.selectedLane)
        self.botMSModifier = self.botEnt:AddNewModifier(self.botEnt,nil,"modifier_custom_speed_boost_flat",{})
        self.botADModifier = self.botEnt:AddNewModifier(self.botEnt,nil,"modifier_bonus_attack_damage",{})
        self.botASModifier = self.botEnt:AddNewModifier(self.botEnt,nil,"modifier_bonus_attack_speed",{})
        --we only have settings for bot, so show them here
        CustomGameEventManager:Send_ServerToAllClients("lasthit_show_settings",{})
        self:refreshBotStats()
        --lets also put wards for bot
        for _,pos in pairs(self.botWardsPos) do
            local ward=CreateUnitByName("npc_dota_observer_wards",pos,true,nil,nil,5-self.selectedSide)
            ward:AddNewModifier(ward,nil,"modifier_invisible",{})
            table.insert(self.botWardsEnts,ward)
        end
    end
    --[[ self.playerHero:AddNewModifier(hero, nil, "modifier_attack_tracker", {}) ]]
    --[[ ParticleMessage:Test(self.playerHero) ]]
end

function lasthit_training:BotMoveSpeedChange(args)
    if self.botMSModifier then
        self.botMSModifier:SetStackCount(tonumber(args.value))
        self:refreshBotStats()
    end
end

function lasthit_training:BotAttackDamageChange(args)
    print("attack speed change",args.value)
    if self.botADModifier then
        self.botADModifier:SetStackCount(tonumber(args.value))
        self:refreshBotStats()
    end
end

function lasthit_training:BotAttackSpeedChange(args)
    if self.botASModifier then
        self.botASModifier:SetStackCount(tonumber(args.value))
        self:refreshBotStats()
    end
end

function lasthit_training:refreshBotStats()
    local bot = self.botEnt
    if not bot or bot:IsNull() then return end

    -- white damage range
    local baseMin = bot:GetDamageMin()
    local baseMax = bot:GetDamageMax()

    -- total average damage (includes bonus damage from items/modifiers)
    local avgTotal = bot:GetAverageTrueAttackDamage(nil)
    local bonus = avgTotal - (baseMin + baseMax) / 2

    local minDmg = baseMin + bonus
    local maxDmg = baseMax + bonus

    local ms = bot:GetIdealSpeed()

    local attackSpeed = bot:GetAttackSpeed(false) * 100   -- e.g. 100 = base speed
    local aps = bot:GetAttacksPerSecond(false)

    CustomGameEventManager:Send_ServerToAllClients("lasthit_training_bot_stats", {
        minDmg = math.floor(minDmg),
        maxDmg = math.floor(maxDmg),
        ms = ms,
        attackSpeed = attackSpeed,
        aps = aps,
    })
end

function lasthit_training:AddLasthittableMarker(npc)
    if npc:IsAlive() and self.pingLasthittable then
        --[[ local particleFX = ParticleManager:CreateParticle("particles/msg_fx/msg_deniable_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, npc) ]]
        --[[ local particleFX = ParticleManager:CreateParticle("particles/ui_mouseactions/ping.vpcf", PATTACH_ABSORIGIN_FOLLOW, npc)
        ParticleManager:SetParticleControl(particleFX, 1, Vector(0,0,500))--z is height of bean
        ParticleManager:SetParticleControl(particleFX, 2, Vector(25,0.05,0))--x is radius, y is duration
        ParticleManager:SetParticleControl(particleFX, 5, Vector(-1,0,0))--removing icon, but 6 might be good
        ParticleManager:SetParticleControl(particleFX, 3, Vector(0,0,0))--y is removing dota plus badge ]]
    end
end

function lasthit_training:SpawnCreepWave(side,bFirst)
    local spawnedWave={}
    if self.onlyEnemySide then
        if side==self.selectedSide then
            return nil
        end
    end
    if bFirst then
        if self.selectedLane=="mid" then
            spawnedWave=CreepController:SpawnCreepWave15sec(side,self.selectedLane,'initial')
        else
            spawnedWave=CreepController:SpawnCreepWave25sec(side,self.selectedLane,'initial')
        end
    else
        spawnedWave=CreepController:SpawnCreepWave(side,self.selectedLane,'initial')
    end
    self.lastWave=spawnedWave
end

function lasthit_training:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    --[[ print('npc spawned: ',npc:GetClassname(),npc:GetUnitName()) ]]
    if npc:GetClassname()=="npc_dota_creep_lane" then
        table.insert(self.creepTrashCan,npc)
        if self.randomCreepHp then
            local maxHp=npc:GetMaxHealth()
            local newHp=RandomInt(0,maxHp)
            npc:SetHealth(newHp)
        end
    end
end

function lasthit_training:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    return true
end

function lasthit_training:ModifierGained(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    if event.name_const=="modifier_item_buff_ward" then
        event.duration=-1
    end
    --[[ debugModifier(event) ]]
    return true
end

function lasthit_training:DamageFilter(event)
    --[[ DeepPrintTable(event) ]]
    if EntIndexToHScript(event.entindex_attacker_const)==self.playerHero then
        --[[ DeepPrintTable(event) ]]
        local damage=math.ceil(event.damage)
        print('[Lasthit] damage filter:',damage)
        --[[ print('[Lasthit] damage filter raw:',event.damage) ]]
    end
    local entVictim=EntIndexToHScript(event.entindex_victim_const)
    if entVictim:GetClassname()=="npc_dota_creep_lane" then
        local damage=math.ceil(event.damage)
        self.lastCreepHurtDmg[event.entindex_victim_const]=damage
    end
    if entVictim:GetUnitName()=="npc_dota_observer_wards" then
        return false
    end
    return true
end

function lasthit_training:OnAbilityUsed(keys)
    -- TODO: react to abilities being cast
end

function lasthit_training:OnEntityHurt(keys)
    --[[ DeepPrintTable(keys) ]]
    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        local entCause = EntIndexToHScript(keys.entindex_attacker)
        if entCause==self.playerHero then
            --[[ DeepPrintTable(keys)
            local damage=keys.damage
            print('[Lasthit] entity hurt:',damage)
            local entVictim = EntIndexToHScript(keys.entindex_killed)
            local hp=entVictim:GetHealth()
            print('[Lasthit] entity hp:',hp) ]]
        end
        local entVictim = EntIndexToHScript(keys.entindex_killed)
        if entVictim:GetClassname()=="npc_dota_creep_lane" then
            --logic for autoattack
            local victim_hp=entVictim:GetHealth()
            local minDamage=self:GetMinDamageForTarget(self.playerHero,entVictim)
            if victim_hp<=minDamage then
                
                if self.lastHittableCreeps[entVictim:entindex()]==nil then
                    --[[ print('creep became lasthittable') ]]
                    self.lastHittableCreeps[entVictim:entindex()]=Time()
                    self:AddLasthittableMarker(entVictim)
                end
            end
            local damage=keys.damage
            local hp=entVictim:GetHealth()
            if hp>0 then
                self:RecordHp(keys.entindex_killed,hp)
            else
                if entCause:IsControllableByAnyPlayer() then
                    --triggers when killed
                    if damage>minDamage then
                        self.creepLuckyStrike[keys.entindex_killed]=true
                        --[[ ParticleMessage:ShowLuckySign(entVictim,Vector(0,0,70))
                        print('lucky strike') ]]
                    end
                end
            end
            --[[ self.lastCreepHurtSrc=keys.entindex_inflictor ]]
        end
    end
end

function lasthit_training:GetMinDamageForTarget(attackerEnt,victimEnt)
    local victim_armor=victimEnt:GetPhysicalArmorValue(false)
    local dmg_multiplier=1-(0.05*victim_armor/(1+0.05*math.abs(victim_armor)))
    local attackerMinDamage=attackerEnt:GetBaseDamageMin()
    return attackerMinDamage*dmg_multiplier
end
function lasthit_training:GetMaxDamageForTarget(attackerEnt,victimEnt)
    local victim_armor=victimEnt:GetPhysicalArmorValue(false)
    local dmg_multiplier=1-(0.05*victim_armor/(1+0.05*math.abs(victim_armor)))
    local attackerMaxDamage=attackerEnt:GetBaseDamageMax()
    return attackerMaxDamage*dmg_multiplier
end
function lasthit_training:RecordHp(entindex, hp)
    local hist = self.hpHistory[entindex]
    if hist == nil then
        hist = {}
        self.hpHistory[entindex] = hist
    end
    hist[#hist+1] = {t = Time(), hp = hp}
end

function lasthit_training:GetLasthittableTime(entindex, damage)
    local hist = self.hpHistory[entindex]
    if hist == nil or #hist == 0 then
        return nil
    end

    -- walk backward from most recent record
    local crossedAt = nil
    for i = #hist, 1, -1 do
        if hist[i].hp <= damage then
            crossedAt = hist[i].t
        else
            -- found a point where hp was above the threshold, so the most
            -- recent crossing is whatever we captured in crossedAt (if any)
            break
        end
    end

    return crossedAt -- nil if hp was never <= damage in recorded history
end

function lasthit_training:ShowDelayParticle(npc,offsetVec,delay,color,showSigns)
    if delay~=nil then
        ParticleMessage:ShowNumber(npc, offsetVec, delay, color, showSigns)
    else
        ParticleMessage:ShowGoodSign(npc,offsetVec,color)
    end
end

function lasthit_training:OnEntityKilled(keys)
    --[[ DeepPrintTable(keys) ]]
    local attacker=EntIndexToHScript(keys.entindex_attacker)
    local victim=EntIndexToHScript(keys.entindex_killed)
    if victim==self.playerHero then
        self.playerHero:SetRespawnPosition(self.playerSpawns[self.selectedSide][self.selectedLane])
        self.playerHero:SetTimeUntilRespawn(5)
        --[[ Timers:CreateTimer(5,function()
            self.playerHero:RespawnHero(false,false)
        end) ]]
    end
    if victim:GetClassname()=="npc_dota_creep_lane" then
        if self.onlyEnemySide then
            local aliveCreeps=0
            for _,creep in pairs(self.lastWave) do
                if IsValidEntity(creep) and creep:IsAlive() then
                    aliveCreeps=aliveCreeps+1
                end
            end
            if aliveCreeps==0 then
                if self.activated then
                    self:SpawnCreepWave(DOTA_TEAM_BADGUYS,true)
                    self:SpawnCreepWave(DOTA_TEAM_GOODGUYS,true)
                end
            end
        end
        if attacker:IsControllableByAnyPlayer() then
            --creep killed by hero or controllable unit
            local green=Vector(0,255,0)
            local lastDmg=self.lastCreepHurtDmg[keys.entindex_killed]
            local lasthitableTime=self:GetLasthittableTime(keys.entindex_killed,lastDmg)
            local delay --can be nil in randomCreepHp if creep spawns already lasthitable
            --i feel like nil delay handling kinda messy here, but dont wanna stuck here or rewrite everything for now        
            if lasthitableTime==nil then
                delay=nil
            else
                delay=Time()-lasthitableTime
                delay=math.floor(delay*1000)/1000
            end
            if keys.entindex_inflictor~=nil then
                --killed by ability
                local ability=EntIndexToHScript(keys.entindex_inflictor)
                if delay==nil then
                    Notifications:Show('green','good',ability:GetAbilityName())
                else
                    Notifications:Show('green','good delay:'..delay,ability:GetAbilityName())
                    self:UpdateCounters('avgDelayCounter',delay)
                end
                self:UpdateCounters('lasthitCounterAbil',1)
                self:ShowDelayParticle(victim, Vector(0,0,50), delay, green, false)
            else
                --killed by autoattack
                if self.luckyCheckEnabled then
                    if self.creepLuckyStrike[keys.entindex_killed] then
                        if delay==nil then
                            Notifications:Show('green','good','none')
                        else
                            Notifications:Show('yellow','lucky strike','none')
                            self:ShowDelayParticle(victim, Vector(0,0,50), delay, green, false)
                            ParticleMessage:ShowLuckySign(victim,Vector(0,0,70))
                        end
                        
                        self:UpdateCounters('luckyStrikes',1)
                        if attacker:GetTeam()==victim:GetTeam() then
                            self:UpdateCounters('denyCounter',1)
                        else
                            self:UpdateCounters('lasthitCounterAA',1)
                        end
                        
                        --[[ print('lucky strike') ]]
                    else
                        if delay==nil then
                            Notifications:Show('green','good','none')
                        else
                            Notifications:Show('green','good delay:'..delay,'none')
                            self:UpdateCounters('avgDelayCounter',delay)
                        end
                        if attacker:GetTeam()==victim:GetTeam() then
                            self:UpdateCounters('denyCounter',1)
                        else
                            self:UpdateCounters('lasthitCounterAA',1)
                        end
                        self:ShowDelayParticle(victim, Vector(0,0,50), delay, green, false)
                    end
                else
                    if delay==nil then
                        Notifications:Show('green','good','none')
                    else
                        Notifications:Show('green','good delay:'..delay,'none')
                        self:UpdateCounters('avgDelayCounter',delay)
                    end
                    if attacker:GetTeam()==victim:GetTeam() then
                        self:UpdateCounters('denyCounter',1)
                    else
                        self:UpdateCounters('lasthitCounterAA',1)
                    end
                    self:ShowDelayParticle(victim, Vector(0,0,50), delay, green, false)
                end
            end
        else
            Notifications:Show('red','bad','none')
            self:UpdateCounters('missCounter',1)
            --todo add check if killed by bot
            if attacker==self.botEnt then
                self:UpdateCounters('botLastHit',1)
                local red=Vector(255,0,0)
                local lastDmg=self.lastCreepHurtDmg[keys.entindex_killed]
                local lasthitableTime=self:GetLasthittableTime(keys.entindex_killed,lastDmg)
                if lasthitableTime==nil then
                    delay=nil
                else
                    delay=Time()-lasthitableTime
                    delay=math.floor(delay*1000)/1000
                end
                if delay~=nil then
                    self:ShowDelayParticle(victim, Vector(0,0,50), delay, red, false)
                end
            end
            --creep killed by creep probably
        end
        --clean tables for this creep (funeral)
        self.lastCreepHurtDmg[keys.entindex_killed]=nil
        self.hpHistory[keys.entindex_killed]=nil
        self.creepLuckyStrike[keys.entindex_killed]=nil
        --waves table cleanup:
        --[[ for side, waves in pairs(self.creepWaves) do
            for i = #waves, 1, -1 do
                local wave = waves[i]
                for j = #wave, 1, -1 do
                    if wave[j] == killed then
                        table.remove(wave, j)
                        break
                    end
                end
                if #wave == 0 then
                    table.remove(waves, i)
                end
            end
        end ]]
    end
end


function lasthit_training:SendItemTable()
    local itemsWithPrices = {}

    for category, itemList in pairs(self.startingItems) do
        itemsWithPrices[category] = {}
        for i, itemName in ipairs(itemList) do
            --using 100 as default value kinda bad, but i dont think anything will ever break here
            local cost = DotaDB:GetItemValue(itemName, {"ItemCost"}, "100") or 0 
            local limit = self.itemLimitTable[itemName] or -1
            itemsWithPrices[category][i] = {
                item_name = itemName,
                price = cost,
                limit = limit
            }
        end
    end
    CustomGameEventManager:Send_ServerToAllClients("lasthit_training_spell_table", itemsWithPrices)
end

function lasthit_training:UpdateCounters(name,value)
    if self.counters[name]==nil then
        print('[Lasthit] Failed to update counter, wrong name')
    else
        if name=="avgDelayCounter" then
            self.delaySum=self.delaySum+value
            self.delayCount=self.delayCount+1
            self.counters[name]=self.delaySum/self.delayCount
        else
            local old=self.counters[name]
            self.counters[name]=old+value
        end
        local hits=self.counters['lasthitCounterAA']+self.counters['lasthitCounterAbil']+self.counters['denyCounter']
        local total=hits+self.counters['missCounter']
        if total>0 then
            self.counters['lasthitToMissPrecent']=math.floor((hits/total)*100)
        else
            self.counters['lasthitToMissPrecent']=0
        end
        CustomGameEventManager:Send_ServerToAllClients("lasthit_refresh_counters", self.counters)
    end
end

function lasthit_training:CreateEnemyBot()

end

function lasthit_training:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function lasthit_training:Deactivate()
    self.activated = false
    TowerController:TurnOffAttack()
    self.delaySum=0
    self.delayCount=0
    self.attacksFailed=0
    self.lastWave={}
    for k in pairs(self.counters) do
        self.counters[k] = 0
    end
    self.lastHittableCreeps={}
    if self.waveTimer~=nil then
        Timers:RemoveTimer(self.waveTimer)
    end
    if self.playerDamageTracker~=nil then
        Timers:RemoveTimer(self.playerDamageTracker)
    end
    lasthit_training_bot_balance:Stop()
    self.deactivateCalled = false
    self.playerHero:SetTeam(DOTA_TEAM_GOODGUYS)
    self.Player:SetTeam(DOTA_TEAM_GOODGUYS)
    self.playerHero:SetAbsOrigin(Vector(-1501.5784912109,820.67797851563,0))
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    for _,creep in pairs(self.creepTrashCan) do
        if IsValidEntity(creep) then
            creep:RemoveSelf()
        end
    end
    self.creepTrashCan={}
    for _,ward in pairs(self.botWardsEnts) do
        if IsValidEntity(ward) then
            ward:RemoveSelf()
        end
    end
    self.botWardsEnts={}
    
end

lasthit_training:Init()
GamemodeManager:RegisterMode(lasthit_training.name, lasthit_training, lasthit_training.type)


