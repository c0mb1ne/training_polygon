-- Modifier for bonus attack speed
modifier_bonus_attack_speed = class({})

function modifier_bonus_attack_speed:IsHidden()
    return false -- Set to true if you want to hide the modifier
end

function modifier_bonus_attack_speed:IsPurgable()
    return true -- Set to false if you don't want it to be purgeable
end

function modifier_bonus_attack_speed:GetTexture()
    return "item_hyperstone" -- Icon for the modifier
end

function modifier_bonus_attack_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_bonus_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() -- Returns the stack count as attack speed bonus
end

