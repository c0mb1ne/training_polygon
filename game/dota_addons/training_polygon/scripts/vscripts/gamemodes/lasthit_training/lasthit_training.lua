--TODO: make serverside check for legitimate buy of item in case of making competetive mode out of this
--for now we dont care
--make towers invulnerable
if lasthit_training == nil then
  lasthit_training = class({})
end

require('gamemodes/lasthit_training/lasthit_training_bot')--wanna isolate bot logic

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
        consumables = {
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
        attributes = {
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
        accessories = {
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
    --helper for bot to undestand waves
    self.creepWaves={
        [DOTA_TEAM_BADGUYS]={},
        [DOTA_TEAM_GOODGUYS]={}
    }
    --debug of attack tracker
    self.attacksLaunched=0
    self.attacksLanded=0
    self.landedUnknown=0
    self.attacksFailed=0
    self.pendingByRecord = {}   -- [record] = hit
    self.pendingByTarget = {}   -- [target entindex] = { [record] = hit }
    self.flightModel     = {}   -- [unitName] = {speed=, offset=}, falls back to nominal speed, offset 0
    self.flightModel["npc_dota_creep_badguys_ranged"] = {speed=1000, offset=75}
    self.flightModel["npc_dota_creep_goodguys_ranged"] = {speed=1000, offset=75}
    self.flightStats     = {}   -- [unitName] = regression + error sums
    self.lastLaunch={}
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
    self.waveTimer=Timers:CreateTimer(cycleStartTime,function()
        self:SpawnCreepWave(DOTA_TEAM_BADGUYS,false)
        self:SpawnCreepWave(DOTA_TEAM_GOODGUYS,false)
        if self.activated then
            return 30
        else
            return nil
        end
    end)
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
        self.botEnt=lasthit_training_bot:Init(self.botHeroName,botRespawnPlace,5-self.selectedSide,self.selectedLane)
    end
    self.playerHero:AddNewModifier(hero, nil, "modifier_attack_tracker", {})
    --[[ ParticleMessage:Test(self.playerHero) ]]
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
            spawnedWave[side]=CreepController:SpawnCreepWave15sec(side,self.selectedLane,'initial')
        else
            spawnedWave[side]=CreepController:SpawnCreepWave25sec(side,self.selectedLane,'initial')
        end
    else
        spawnedWave[side]=CreepController:SpawnCreepWave(side,self.selectedLane,'initial')
    end
    for side,creepTable in pairs(spawnedWave) do
        table.insert(self.creepWaves[side],creepTable)
    end
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
    -- TODO: return false to prevent specific damage instances, true to allow
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
                    print('creep became lasthittable')
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
--a lot of ai code gonna be here, since im too lazy to calculate attacks by myself
local function ArmorMultiplier(target)
    local armor = target:GetPhysicalArmorValue(false)
    return 1 - 0.06 * armor / (1 + 0.06 * math.abs(armor))
end

function lasthit_training:OnAttackLaunched(attacker, target, record)
    if attacker == nil or target == nil or target:IsNull() then return end
    self.attacksLaunched = (self.attacksLaunched or 0) + 1
    DebugVar("attacksLaunched",self.attacksLaunched)
    self.lastLaunch[attacker:entindex()] = Time()
    local pos = attacker:GetAbsOrigin()
    local hit = {
        record     = record,
        attacker   = attacker,
        target     = target,
        launchPos  = pos,
        launchTime = Time(),
        ranged     = attacker:IsRangedAttacker(),
        damage     = attacker:GetAverageTrueAttackDamage(target) * ArmorMultiplier(target),
    }
    hit.predictedFlight = self:PredictFlight(attacker, target, pos)  -- at launch, for comparison

    self.pendingByRecord[record] = hit
    local idx = target:entindex()
    local t = self.pendingByTarget[idx] or {}
    self.pendingByTarget[idx] = t
    t[record] = hit
end

function lasthit_training:RemoveHit(record)
    local h = self.pendingByRecord[record]
    if not h then return nil end
    self.pendingByRecord[record] = nil
    local t = self.pendingByTarget[h.target:entindex()]
    if t then t[record] = nil end
    return h
end

function lasthit_training:OnAttackLanded(attacker, target, record)
    local h = self:RemoveHit(record)
    if not h then
        self.landedUnknown = (self.landedUnknown or 0) + 1
        return
    end
    self.attacksLanded = (self.attacksLanded or 0) + 1
    DebugVar("attacksLanded",self.attacksLanded)
    if not h.ranged then return end

    local flight = Time() - h.launchTime
    local dist   = (target:GetAbsOrigin() - h.launchPos):Length2D()
    if flight < 0.01 then return end

    local name = attacker:GetUnitName()
    local s = self.flightStats[name]
    if not s then
        s = {n=0, sx=0, sy=0, sxx=0, sxy=0, errSum=0, errAbsSum=0}
        self.flightStats[name] = s
    end
    local err = flight - h.predictedFlight   -- positive: projectile was slower than predicted
    s.n = s.n + 1
    s.sx, s.sy = s.sx + dist, s.sy + flight
    s.sxx, s.sxy = s.sxx + dist*dist, s.sxy + dist*flight
    s.errSum, s.errAbsSum = s.errSum + err, s.errAbsSum + math.abs(err)
end

function lasthit_training:OnAttackFail(record)
    if self:RemoveHit(record) then
        self.attacksFailed = (self.attacksFailed or 0) + 1
        DebugVar("attacksFailed",self.attacksFailed)
    end
end

function lasthit_training:PredictFlight(attacker, target, launchPos)
    if not attacker:IsRangedAttacker() then return 0 end
    local m = self.flightModel[attacker:GetUnitName()]
    local speed  = m and m.speed  or attacker:GetProjectileSpeed()
    local offset = m and m.offset or 0
    local dist = (target:GetAbsOrigin() - launchPos):Length2D()
    return math.max(0, dist - offset) / speed
end

function lasthit_training:DumpFlightStats()
    for name, s in pairs(self.flightStats) do
        local denom = s.n * s.sxx - s.sx * s.sx
        local line = ""
        if s.n >= 5 and denom > 1e-6 then
            local slope = (s.n * s.sxy - s.sx * s.sy) / denom
            local intercept = (s.sy - slope * s.sx) / s.n
            local speed = 1 / slope
            local offset = -intercept * speed
            line = string.format(" fit: speed=%.0f offset=%.0f", speed, offset)
            s.fit = {speed = speed, offset = offset}
        end
        DebugVar(name,(string.format("%s: n=%d meanErr=%.3f meanAbsErr=%.3f%s",
            name, s.n, s.errSum / s.n, s.errAbsSum / s.n, line)))
    end
end

function lasthit_training:ApplyFits(minSamples)
    for name, s in pairs(self.flightStats) do
        if s.fit and s.n >= (minSamples or 30) and s.fit.speed > 0 then
            self.flightModel[name] = {speed = s.fit.speed, offset = s.fit.offset}
        end
    end
end

function lasthit_training:PredictLastHittableTime(target, damage)
    local now = Time()
    local hp = target:GetHealth()
    if hp <= damage then return now end

    local hits = {}

    -- 1) hits in flight
    local pending = self.pendingByTarget[target:entindex()]
    if pending then
        for record, h in pairs(pending) do
            local t = h.launchTime + self:PredictFlight(h.attacker, target, h.launchPos)
            if h.attacker:IsNull() or now - t > 1.0 then
                self:RemoveHit(record)          -- safety sweep, shouldn't trigger often
            else
                hits[#hits+1] = {t = math.max(t, now), damage = h.damage}
            end
        end
    end

    -- 2) future attacks from units currently targeting this creep
    local horizon = 6
    local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, 1500,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for _, a in ipairs(units) do
        if a:GetAttackTarget() == target then
            local spa = a:GetSecondsPerAttack(false)
            local last = self.lastLaunch[a:entindex()] or (now - spa)
            local launch = math.max(now, last + spa)
            local travel = self:PredictFlight(a, target, a:GetAbsOrigin())
            local dmg = a:GetAverageTrueAttackDamage(target) * ArmorMultiplier(target)
            while launch - now < horizon do
                hits[#hits+1] = {t = launch + travel, damage = dmg}
                launch = launch + spa
            end
        end
    end

    table.sort(hits, function(a, b) return a.t < b.t end)
    for _, h in ipairs(hits) do
        hp = hp - h.damage
        if hp <= 0 then return nil end
        if hp <= damage then return h.t end
    end
    return nil
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
    self.attacksLaunched=0
    self.attacksLanded=0
    self.landedUnknown=0
    self.attacksFailed=0
    self.pendingByRecord = {}   -- [record] = hit
    self.pendingByTarget = {}   -- [target entindex] = { [record] = hit }
    self.flightModel     = {}   -- [unitName] = {speed=, offset=}, falls back to nominal speed, offset 0
    self.flightStats     = {}   -- [unitName] = regression + error sums
    self.lastLaunch={}
    self.delaySum=0
    self.delayCount=0
    self.attacksFailed=0
    self.creepWaves={
        [DOTA_TEAM_BADGUYS]={},
        [DOTA_TEAM_GOODGUYS]={}
    }
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
    if IsValidEntity(self.botEnt) then
        self.botEnt:RemoveSelf()
        self.botEnt=nil
    end
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
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

lasthit_training:Init()
GamemodeManager:RegisterMode(lasthit_training.name, lasthit_training, lasthit_training.type)


