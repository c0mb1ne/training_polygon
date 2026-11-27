if TowerController == nil then
    TowerController = class({})
end

function TowerController:Init()
    print("[TowerController] Init")
    self.towers={} -- Keep name -> tower lookup for existing callers.
    self.towerList={} -- Keep every tower, including units sharing a name.
    local towers=Entities:FindAllByClassname("npc_dota_tower")
    for _,towerEnt in pairs(towers) do
        local towerName=towerEnt:GetUnitName()
        print("[TowerController] tower found:",towerName)
        table.insert(self.towerList,towerEnt)
        if self.towers[towerName] == nil then
            self.towers[towerName]=towerEnt
        end
    end
    self:TurnOffAttack()
    self:InvulnerablityOn()
end

function TowerController:TurnOffAttack()
    for _,towerEnt in ipairs(self.towerList) do
        towerEnt:AddNewModifier(towerEnt, nil, "modifier_disarmed_custom", {})
    end
end

function TowerController:TurnOnAttack()
    for _,towerEnt in ipairs(self.towerList) do
        towerEnt:RemoveModifierByName("modifier_disarmed_custom")
    end
end

function TowerController:InvulnerablityOn()
--modifier_invulnerable
    for _,towerEnt in ipairs(self.towerList) do
        towerEnt:AddNewModifier(towerEnt, nil, "modifier_invulnerable_custom", {})
    end
end
function TowerController:InvulnerablityOff()
--modifier_invulnerable
    for _,towerEnt in ipairs(self.towerList) do
        towerEnt:RemoveModifierByName("modifier_invulnerable_custom")
    end
end
