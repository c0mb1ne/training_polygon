modifier_custom_speed_boost_flat = class({})

function modifier_custom_speed_boost_flat:IsHidden()
    return false -- Show the buff icon
end

function modifier_custom_speed_boost_flat:IsDebuff()
    return false
end

function modifier_custom_speed_boost_flat:IsPurgable()
    return false
end

function modifier_custom_speed_boost_flat:GetTexture()
    return "item_phase_boots" -- Use phase boots icon
end

function modifier_custom_speed_boost_flat:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function modifier_custom_speed_boost_flat:GetModifierMoveSpeedBonus_Constant()
    -- Stack count directly represents the flat bonus (e.g., 100 for +100 movespeed)
    return self:GetStackCount()
end

--[[ function modifier_custom_speed_boost_flat:GetEffectName()
    return "particles/items_fx/phase_boots.vpcf"
end ]]

function modifier_custom_speed_boost_flat:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end