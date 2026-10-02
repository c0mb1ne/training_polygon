modifier_disarmed_custom = class({})

--------------------------------------------------------------------------------
-- Usage:
--   LinkLuaModifier("modifier_disarmed_custom", "modifiers/modifier_disarmed_custom", LUA_MODIFIER_MOTION_NONE)
--
--   -- turn attacks off
--   unit:AddNewModifier(unit, nil, "modifier_disarmed_custom", {})
--
--   -- turn attacks back on
--   unit:RemoveModifierByName("modifier_disarmed_custom")
--
-- Optional kv:
--   duration = X   -- auto-remove after X seconds, otherwise permanent
--
-- Works on any unit (hero, creep, tower...). Does not touch attack capability,
-- so the unit's projectile/attack setup stays untouched.
--------------------------------------------------------------------------------

function modifier_disarmed_custom:IsHidden() return false end
function modifier_disarmed_custom:IsDebuff() return false end
function modifier_disarmed_custom:IsPurgable() return false end
function modifier_disarmed_custom:IsPurgeException() return false end
function modifier_disarmed_custom:RemoveOnDeath() return true end

function modifier_disarmed_custom:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end