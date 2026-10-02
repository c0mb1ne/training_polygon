modifier_invulnerable_custom = class({})

--------------------------------------------------------------------------------
-- Usage:
--   LinkLuaModifier("modifier_invulnerable_custom", "modifiers/modifier_invulnerable_custom", LUA_MODIFIER_MOTION_NONE)
--   unit:AddNewModifier(unit, nil, "modifier_invulnerable_custom", {})
--
-- Optional kv:
--   block_all_damage = 0   -- set to 0 to block only physical damage/attacks (default 1: all damage blocked)
--   duration         = X   -- optional, standard duration, otherwise permanent
--------------------------------------------------------------------------------

function modifier_invulnerable_custom:IsHidden() return false end
function modifier_invulnerable_custom:IsDebuff() return false end
function modifier_invulnerable_custom:IsPurgable() return false end
function modifier_invulnerable_custom:RemoveOnDeath() return true end

function modifier_invulnerable_custom:OnCreated(kv)
    self.block_all = (kv.block_all_damage or 1) == 1
end

function modifier_invulnerable_custom:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_invulnerable_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    }
end

-- attacks deal physical damage, so this blocks them (and other physical damage)
function modifier_invulnerable_custom:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_invulnerable_custom:GetAbsoluteNoDamageMagical()
    return self.block_all and 1 or 0
end

function modifier_invulnerable_custom:GetAbsoluteNoDamagePure()
    return self.block_all and 1 or 0
end