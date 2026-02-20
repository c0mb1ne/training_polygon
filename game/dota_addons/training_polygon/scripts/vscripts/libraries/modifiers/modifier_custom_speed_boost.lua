modifier_custom_speed_boost = class({})

function modifier_custom_speed_boost:IsHidden()
    return false -- Show the buff icon
end

function modifier_custom_speed_boost:IsDebuff()
    return false
end

function modifier_custom_speed_boost:IsPurgable()
    return false
end

function modifier_custom_speed_boost:GetTexture()
    return "item_phase_boots" -- Use phase boots icon
end

function modifier_custom_speed_boost:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_custom_speed_boost:GetModifierMoveSpeedBonus_Percentage()
    -- Stack count contains the multiplier * 100 (e.g., 180 for 1.8x)
    local multiplier = self:GetStackCount() / 100
    return (multiplier - 1) * 100 -- Convert to percentage bonus
end

--[[ function modifier_custom_speed_boost:GetEffectName()
    return "particles/items_fx/phase_boots.vpcf"
end ]]

function modifier_custom_speed_boost:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end