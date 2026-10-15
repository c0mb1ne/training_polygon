modifier_attack_tracker = class({})

function modifier_attack_tracker:IsHidden() return true end
function modifier_attack_tracker:IsPurgable() return false end
function modifier_attack_tracker:RemoveOnDeath() return false end

function modifier_attack_tracker:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_FAIL
    }
end

function modifier_attack_tracker:OnAttack(p)
    if not IsServer() then return end
    --[[ for k,v in pairs(p) do
        print(k,v)
    end ]]
    if lasthit_training~=nil then
        lasthit_training:OnAttackLaunched(p.attacker, p.target, p.record)
    end
end

function modifier_attack_tracker:OnAttackLanded(p)
    if not IsServer() then return end
    if lasthit_training~=nil then
        lasthit_training:OnAttackLanded(p.attacker, p.target, p.record)
    end
end
function modifier_attack_tracker:OnAttackFail(p)
    if not IsServer() then return end
    if lasthit_training~=nil then
        lasthit_training:OnAttackFail(p.record)
    end
end