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
    DebugPanelShow()
    return self.botEnt
end

function lasthit_training_bot:CreateBotUnit()
    self.botEnt=CreateUnitByName(self.botHeroName,self.botRespawnPlace,true,nil,nil,self.botTeam)
    self.botEnt:SetBaseHealthRegen(300)
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

function lasthit_training_bot:Think()
    self.botEnt:Stop()
    local color1=Vector(255,0,0)
    local color2=Vector(0,0,255)
    local color3=Vector(255,0,255)
    local color4=Vector(255,255,0)
    local color5=Vector(0,0,0)
    local botPosition=self.botEnt:GetAbsOrigin()
    --[[ DebugVar("botPos",self.botEnt:GetAbsOrigin()) ]]
    self.friendlyCreepsHealthSum=0
    self.enemyCreepsHealthSum=0
    self.aliveCreeps={}
    self.friendlyCreeps={}
    self.enemyCreeps={}
    self.aliveCreeps=Entities:FindAllByName("npc_dota_creep_lane")
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
    end
    DebugDrawCircle(botPosition, color1, 20, self.botAttackRange, true, self.botThinkInterval)

    --[[ DebugDrawCircle(self.creepScanZone.minVec, color2, 20, 20, true, self.botThinkInterval) ]]
    --[[ DrawDebugBoxCustom(self.creepScanZone.minVec,self.creepScanZone.maxVec,color2,true,self.botThinkInterval)
    DebugDrawCircle(self.creepScanZone.minVec, color2, 20, 20, true, self.botThinkInterval)
    DebugDrawCircle(self.creepScanZone.maxVec, color1, 20, 20, true, self.botThinkInterval) ]]
    DebugVar("creeps",#self.aliveCreeps)
    DebugVar("enemy",#self.enemyCreeps)
    DebugVar("friendly",#self.friendlyCreeps)
    DebugVar("creepwave",#lasthit_training.creepWaves[DOTA_TEAM_GOODGUYS])
end