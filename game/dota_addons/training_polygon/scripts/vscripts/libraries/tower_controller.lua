if TowerController == nil then
    TowerController = class({})
end

function TowerController:Init()
    print("[TowerController] Init")
    self.towers={}
    local towers=Entities:FindAllByClassname("npc_dota_tower")
    for _,towerEnt in pairs(towers) do
        local towerName=towerEnt:GetUnitName()
        print("[TowerController] tower found:",towerName)
        self.towers[towerName]=towerEnt
    end
    self:TurnOffAttack()
    self:InvulnerablityOn()
end

function TowerController:TurnOffAttack()
    for _,towerEnt in pairs(self.towers) do
        towerEnt:AddNewModifier(towerEnt, nil, "modifier_disarmed_custom", {})
    end
end

function TowerController:TurnOnAttack()
    for _,towerEnt in pairs(self.towers) do
        towerEnt:RemoveModifierByName("modifier_disarmed_custom")
    end
end

function TowerController:InvulnerablityOn()
--modifier_invulnerable
    for _,towerEnt in pairs(self.towers) do
        towerEnt:AddNewModifier(towerEnt, nil, "modifier_invulnerable_custom", {})
    end
end
function TowerController:InvulnerablityOff()
--modifier_invulnerable
    for _,towerEnt in pairs(self.towers) do
        towerEnt:RemoveModifierByName("modifier_invulnerable_custom")
    end
end
