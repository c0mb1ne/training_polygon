-- Modifier for bonus attack damage
modifier_bonus_attack_damage = class({})

function modifier_bonus_attack_damage:IsHidden()
    return false -- Set to true if you want to hide the modifier
end

function modifier_bonus_attack_damage:IsPurgable()
    return true -- Set to false if you don't want it to be purgeable
end

function modifier_bonus_attack_damage:GetTexture()
    return "item_demon_edge" -- Icon for the modifier
end

function modifier_bonus_attack_damage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
    return funcs
end

function modifier_bonus_attack_damage:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() -- Returns the stack count as damage bonus
end

