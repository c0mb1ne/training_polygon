if lasthit_training_bot == nil then
  lasthit_training_bot = class({})
end

function lasthit_training_bot:Init(botHeroName,vecRespawnPlace,botTeam,selectedLane)
    self.currentBehaviour=nil
    self.botThinkInterval=FrameTime()
    self.botEnt=nil
    self.botHeroName=botHeroName
    self.botRespawnPlace=vecRespawnPlace
    self.botTeam=botTeam
    self.aliveCreeps={}
    self.friendlyCreeps={}
    self.enemyCreeps={}
    self.friendlyCreepsHealthSum=0
    self.enemyCreepsHealthSum=0
    self.thinkTimer=nil
    self.selectedLane=selectedLane
    self.friendlyTower=nil
    self.enemyTower=nil
    self.direTower=TowerController.towers['npc_dota_badguys_tower1_'..self.selectedLane]
    self.radiantTower=TowerController.towers['npc_dota_goodguys_tower1_'..self.selectedLane]
    if self.botTeam==DOTA_TEAM_BADGUYS then
        self.friendlyTower=self.direTower
        self.enemyTower=self.radiantTower
    else
        self.friendlyTower=self.radiantTower
        self.enemyTower=self.direTower
    end
    self.creepScanZone={
        maxVec=self.radiantTower:GetAbsOrigin()-Vector(400,400,0),
        minVec=self.direTower:GetAbsOrigin()+Vector(400,400,0)
    }

    self:CreateBotUnit()
    self.botAttackRange=self.botEnt:GetBaseAttackRange()
    self.botDamageMin=0
    self.sleepUntil=nil
    --[[ local new_as = self.botEnt:AddNewModifier(self.botEnt, nil, "modifier_bonus_attack_speed", {})
    new_as:SetStackCount(200) ]]
    DebugPanelShow()
    return self.botEnt
end

function lasthit_training_bot:CreateBotUnit()
    self.botEnt=CreateUnitByName(self.botHeroName,self.botRespawnPlace,true,nil,nil,self.botTeam)
    self.botEnt:SetBaseHealthRegen(300)
    self.botEnt:SetIdleAcquire(false)
    self.thinkTimer=Timers:CreateTimer(0,function()
        if IsValidEntity(self.botEnt) then
            self:Think()
            return self.botThinkInterval
        else
            DebugPanelHide()
            return nil
        end
    end)
end

local function IsCreepAlive(c)
    return c ~= nil and IsValidEntity(c) and c:IsAlive()
end

local function IsCreepDeniable(c)
    return c:GetHealth()<c:GetMaxHealth()/2
end
-- removes dead/invalid creeps from the wave in place, returns true if any are left
local function PruneWave(wave)
    for i = #wave, 1, -1 do
        if not IsCreepAlive(wave[i]) then
            table.remove(wave, i)
        end
    end
    return #wave > 0
end

function lasthit_training_bot:getOldestWave(team)
    local waves = lasthit_training.creepWaves[team]
    while #waves > 0 and not PruneWave(waves[1]) do
        table.remove(waves, 1)
    end
    return waves[1]  -- nil if no living waves
end

function lasthit_training_bot:getLatestWave(team)
    local waves = lasthit_training.creepWaves[team]
    while #waves > 0 and not PruneWave(waves[#waves]) do
        table.remove(waves, #waves)
    end
    return waves[#waves]  -- nil if no living waves
end
-- prunes all waves of a team, drops empty ones
function lasthit_training_bot:CleanupWaves(team)
    local waves = lasthit_training.creepWaves[team]
    for i = #waves, 1, -1 do
        if not PruneWave(waves[i]) then
            table.remove(waves, i)
        end
    end
end
function lasthit_training_bot:MoveToSaveSpotBehaviour(saveSpotVec)
    self.botEnt:SetContextThink(DoUniqueString("bot_relocation"),function()
        ExecuteOrderFromTable({
            UnitIndex = self.botEnt:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = saveSpotVec
        })
    end,0)
    
end
function lasthit_training_bot:MoveToCreep(creep)
    self.botEnt:SetContextThink(DoUniqueString("bot_relocation"),function()
        ExecuteOrderFromTable({
            UnitIndex = self.botEnt:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
            TargetIndex = creep:entindex()
        })
    end,0)
end
function lasthit_training_bot:AttackCreep(creep)
    self.botEnt:SetContextThink(DoUniqueString("bot_relocation"),function()
        ExecuteOrderFromTable({
            UnitIndex = self.botEnt:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = creep:entindex()
        })
    end,0)
end
function lasthit_training_bot:RemoveAggroAndRelocate(saveSpotVec,creep)
    self.botEnt:SetContextThink(DoUniqueString("bot_unagro_relocation"),function()
        ExecuteOrderFromTable({
            UnitIndex = self.botEnt:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            Position = saveSpotVec
        })
        ExecuteOrderFromTable({
            UnitIndex = self.botEnt:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        })
        ExecuteOrderFromTable({
            UnitIndex = self.botEnt:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            TargetIndex = creep:entindex()
        })
    end,0)
    
end

function lasthit_training_bot:Think()
    --[[ self.botEnt:Stop() ]]
    local color1=Vector(255,0,0)
    local color2=Vector(0,0,255)
    local color3=Vector(255,0,255)
    local color4=Vector(255,255,0)
    local color5=Vector(0,0,0)
    local botPosition=self.botEnt:GetAbsOrigin()
    local allyTeam=self.botTeam
    local enemyTeam=5-self.botTeam
    self:CleanupWaves(allyTeam)
    self:CleanupWaves(enemyTeam)
    --[[ DebugVar("botPos",self.botEnt:GetAbsOrigin()) ]]
    self.friendlyCreepsHealthSum=0
    self.enemyCreepsHealthSum=0
    self.aliveCreeps={}
    local friendlyWave=self:getOldestWave(allyTeam)
    local enemyWave=self:getOldestWave(enemyTeam)
    self.friendlyCreeps={}
    self.enemyCreeps={}
    local creepsAttackingBot=0
    local allyWaves = lasthit_training.creepWaves[allyTeam]
    local lowestHpAllyCreep=nil
    local lowestHpEnemyCreep=nil
    local botAttackTime=self.botEnt:GetSecondsPerAttack(false)
    self.botDamageMin=self.botEnt:GetBaseDamageMin()
    local leastDelayCreep=nil
    local leastDelay=nil
    --[[ lasthit_training:DumpFlightStats() ]]
    DebugVar('bot attack time',botAttackTime)
    for _,wave in pairs(allyWaves) do
        local creepsPos={}
        for _,creep in pairs(wave) do
            if lowestHpAllyCreep==nil then
                lowestHpAllyCreep=creep
            else
                if creep:GetHealth()<lowestHpAllyCreep:GetHealth() then
                    lowestHpAllyCreep=creep
                end
            end
            local pos=creep:GetAbsOrigin()
            table.insert(creepsPos,pos)
            local prediction=lasthit_training:PredictLastHittableTime(creep,self.botDamageMin)
            if prediction~=nil then
                if leastDelay==nil then
                    leastDelay=prediction-Time()
                else
                    if leastDelay<prediction-Time() then
                        leastDelay=prediction-Time()
                        leastDelayCreep=creep
                    end
                end
                local displayDelay=math.floor((prediction-Time())*1000)/1000
                DebugDrawText(creep:GetAbsOrigin(),tostring(displayDelay),true,self.botThinkInterval)
            end
        end
        if #creepsPos > 0 then
            DebugDrawCircle(AveragePoint(creepsPos), color2, 20, 20, true, self.botThinkInterval)
        end
    end
    local enemyWaves = lasthit_training.creepWaves[enemyTeam]
    for _,wave in pairs(enemyWaves) do
        for _,creep in pairs(wave) do
            if lowestHpEnemyCreep==nil then
                lowestHpEnemyCreep=creep
            else
                if creep:GetHealth()<lowestHpEnemyCreep:GetHealth() then
                    lowestHpEnemyCreep=creep
                end
            end
            if creep:IsAttackingEntity(self.botEnt) then
                creepsAttackingBot=creepsAttackingBot+1
                DebugDrawLine(creep:GetAbsOrigin(),self.botEnt:GetAbsOrigin(),255,255,0,false,self.botThinkInterval)
            end
            --[[ local creepTarget=creep:GetAttackTarget()
            if creepTarget~=nil and creepTarget==self.botEnt then
                DebugDrawLine(creep:GetAbsOrigin(),self.botEnt:GetAbsOrigin(),255,255,0,false,self.botThinkInterval)
            end ]]
            local prediction=lasthit_training:PredictLastHittableTime(creep,self.botDamageMin)
            if prediction~=nil then
                if leastDelay==nil then
                    leastDelay=prediction-Time()
                else
                    if leastDelay<prediction-Time() then
                        leastDelay=prediction-Time()
                        leastDelayCreep=creep
                    end
                end
                local displayDelay=math.floor((prediction-Time())*1000)/1000
                DebugDrawText(creep:GetAbsOrigin(),tostring(displayDelay),true,self.botThinkInterval)
            end
        end
        
    end
    if self.enemyTower:IsAttackingEntity(self.botEnt) then
        creepsAttackingBot=creepsAttackingBot+1
        DebugDrawLine(self.enemyTower:GetAbsOrigin(),self.botEnt:GetAbsOrigin(),255,255,0,false,self.botThinkInterval)
    end
    local oldestWavePositions={}
    for _,creep in pairs(friendlyWave) do
        local pos=creep:GetAbsOrigin()
        table.insert(oldestWavePositions,pos)
    end
    local safeSpot
    if creepsAttackingBot>0 then
        safeSpot=self.friendlyTower:GetAbsOrigin()
    else
        safeSpot=AveragePoint(oldestWavePositions)
    end
    --[[ safeSpot=Vector(-1980.1783447266,96.06982421875,128) --chill place for debugging ]]
    
    
    DebugVar("bot attackers",creepsAttackingBot)
    DebugDrawCircle(safeSpot, color3, 20, 20, true, self.botThinkInterval)
    --[[ self.aliveCreeps=Entities:FindAllByName("npc_dota_creep_lane")
    for _,creep in pairs(self.aliveCreeps) do
        if creep:IsAlive() then
            if creep:GetTeam()==self.botEnt:GetTeam() then
                table.insert(self.friendlyCreeps,creep)
                local hp=creep:GetHealth()
                self.friendlyCreepsHealthSum=self.friendlyCreepsHealthSum+hp
            else
                table.insert(self.enemyCreeps,creep)
                local hp=creep:GetHealth()
                self.enemyCreepsHealthSum=self.enemyCreepsHealthSum+hp
            end
        end
    end ]]
    DebugDrawCircle(botPosition, color1, 20, self.botAttackRange, true, self.botThinkInterval)
    
    --[[ DebugDrawCircle(self.creepScanZone.minVec, color2, 20, 20, true, self.botThinkInterval) ]]
    --[[ DrawDebugBoxCustom(self.creepScanZone.minVec,self.creepScanZone.maxVec,color2,true,self.botThinkInterval)
    DebugDrawCircle(self.creepScanZone.minVec, color2, 20, 20, true, self.botThinkInterval)
    DebugDrawCircle(self.creepScanZone.maxVec, color1, 20, 20, true, self.botThinkInterval) ]]
    DebugVar("creeps",#self.aliveCreeps)
    DebugVar("enemy",#self.enemyCreeps)
    DebugVar("friendly",#self.friendlyCreeps)
    DebugVar("creepwave",#lasthit_training.creepWaves[DOTA_TEAM_GOODGUYS])
    --[[ if creepsAttackingBot>0 then
        local creep=lowestHpAllyCreep
        self:RemoveAggroAndRelocate(saveSpotVec,creep)
        return
    end ]]
    --do actions here
    if self.sleepUntil~=nil then
        if Time()<self.sleepUntil then
            return
        end
    end
    if creepsAttackingBot>0 then
        if distanceBetweenTwoVec(safeSpot,botPosition)>150 then
            self:MoveToSaveSpotBehaviour(safeSpot)
            return
        end
    end
    if leastDelayCreep~=nil and self.botEnt:IsAttacking()==false then
        self:AttackCreep(leastDelayCreep)
        return
    end
    if distanceBetweenTwoVec(safeSpot,botPosition)>150 then
        self:MoveToSaveSpotBehaviour(safeSpot)
        return
    end
end