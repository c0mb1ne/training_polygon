if lasthit_training_bot == nil then
  lasthit_training_bot = class({})
end

function lasthit_training_bot:Init(botHeroName,vecRespawnPlace,botTeam)
    self.currentBehaviour=nil
    self.botThinkInterval=FrameTime()
    self.botEnt=nil
    self.botHeroName=botHeroName
    self.botRespawnPlace=vecRespawnPlace
    self.botTeam=botTeam
    self.aliveCreeps={}
    self.thinkTimer=nil
    self:CreateBotUnit()
    DebugPanelShow()
    return self.botEnt
end

function lasthit_training_bot:RegisterCreep(creepEnt)
    table.insert(self.aliveCreeps,creepEnt)
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
    local color1=Vector(255,0,0)
    local color2=Vector(0,0,255)
    local color3=Vector(255,0,255)
    local color4=Vector(255,255,0)
    local color5=Vector(0,0,0)
    DebugVar("botPos",self.botEnt:GetAbsOrigin())
    --[[ for k,v in pairs(self.aliveCreeps) do
        if v:IsValidEntity() then
            DebugDrawCircle(v:GetAbsOrigin(), color1, 20, 20, true, self.botThinkInterval)
        end
    end ]]
end