datadriven_range_cd = class({})
LinkLuaModifier("modifier_datadriven_range_cd", "utils/castrange_cdreduc.lua", LUA_MODIFIER_MOTION_NONE)

function datadriven_range_cd:GetAbilityTextureName()
   return "dragon_knight_dragon_blood"
end

function datadriven_range_cd:GetIntrinsicModifierName()
    return "modifier_datadriven_range_cd"
end
function datadriven_range_cd:IsHidden() return true end

-- creating buff
modifier_datadriven_range_cd = class({})

function modifier_datadriven_range_cd:OnCreated()
    -- Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.bonus_cd_reduc_per_stack = self.ability:GetSpecialValueFor("bonus_cd_reduc_per_stack")

end

function modifier_datadriven_range_cd:IsHidden() return true end
function modifier_datadriven_range_cd:IsPurgable() return false end
function modifier_datadriven_range_cd:IsDebuff() return false end

function modifier_datadriven_range_cd:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}

    return decFuncs
end

function modifier_datadriven_range_cd:GetModifierMoveSpeedBonus_Constant() 
    return self.bonus_cd_reduc_per_stack*self:GetStackCount()
end



function modifier_datadriven_range_cd:OnStackCountChanged( nOldStackCount )
    if IsServer() then
        if self:GetStackCount() == -1 then
            self:Destroy()
        else
            self:ForceRefresh()
        end
    end
end