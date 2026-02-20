modifier_set_max_mana = class({})

function modifier_set_max_mana:IsHidden()
    return false
end

function modifier_set_max_mana:IsPurgable()
    return false
end

function modifier_set_max_mana:GetTexture()
    return "item_arcane_boots" -- swap icon as needed
end

function modifier_set_max_mana:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_BONUS,
    }
end

function modifier_set_max_mana:OnCreated(params)
    self.mana_delta = 0
end

function modifier_set_max_mana:GetModifierManaBonus()
    local hero = self:GetParent()
    if not hero then return 0 end

    local desired_max = self:GetStackCount()
    -- current max mana without our contribution
    local current_max = hero:GetMaxMana() - self.mana_delta
    self.mana_delta = desired_max - current_max

    return self.mana_delta
end