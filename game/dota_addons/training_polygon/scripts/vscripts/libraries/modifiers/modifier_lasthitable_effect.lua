--[[
	modifier_lasthitable_effect
	A reusable status-effect modifier template for Dota 2 custom games.
	Purely visual/backend — no icon, no buff bar entry, no player-facing indicator
	other than whatever particle/effect you attach.

	Usage:
		unit:AddNewModifier(caster, ability, "modifier_lasthitable_effect", { duration = 5 })

	NOTE: LinkLuaModifier for this modifier is handled elsewhere in your codebase.
]]

modifier_lasthitable_effect = class({})

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function modifier_lasthitable_effect:IsHidden()
	return true -- hidden from buff bar entirely, purely a backend/visual effect
end

function modifier_lasthitable_effect:IsPurgable()
	return true -- can be dispelled
end

function modifier_lasthitable_effect:IsDebuff()
	return false -- doesn't matter much while hidden, but keep consistent with intent
end

function modifier_lasthitable_effect:IsStunDebuff()
	return false
end

function modifier_lasthitable_effect:RemoveOnDeath()
	return true
end

-- Called on both client and server when the modifier is created
function modifier_lasthitable_effect:OnCreated( kv )
	self.bonus_move_speed_pct = self.ability and self.ability:GetSpecialValueFor( "bonus_move_speed_pct" ) or 0
	self.bonus_armor         = self.ability and self.ability:GetSpecialValueFor( "bonus_armor" ) or 0

	if IsServer() then
		self:StartIntervalThink( 1.0 ) -- optional periodic tick, remove if unused
	end

	if IsClient() then
		self:OnRefresh( kv ) -- attach particle client-side
	end
end

function modifier_lasthitable_effect:OnRefresh( kv )
	if IsServer() then
		self:OnCreated( kv )
		return
	end

	-- Client-side: attach the visual effect here, e.g.
	local particle = ParticleManager:CreateParticle( "particles/status_fx/status_effect_electrical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	self:AddParticle( particle, false, false, -1, false, false )
end

function modifier_lasthitable_effect:OnDestroy()
	if not IsServer() then return end
	-- clean up sounds/state here if needed (particles attached via AddParticle
	-- are cleaned up automatically when the modifier ends)
end

--------------------------------------------------------------------------------
-- Periodic think (optional — remove DeclareFunctions/OnIntervalThink if unused)
--------------------------------------------------------------------------------

function modifier_lasthitable_effect:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	if not parent or not parent:IsAlive() then return end

	-- Example: damage over time / heal over time / stack logic goes here
	-- ApplyDamage({ victim = parent, attacker = self:GetCaster(), damage = 10, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
end

--------------------------------------------------------------------------------
-- Stat modification hooks (declare only what you use)
--------------------------------------------------------------------------------

function modifier_lasthitable_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_PROPERTY_ATTACK_SPEED_BONUS_CONSTANT,
		-- MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_PROPERTY_DISABLE_HEALING,
		-- MODIFIER_STATE_STUNNED,
	}
	return funcs
end

function modifier_lasthitable_effect:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_move_speed_pct
end

function modifier_lasthitable_effect:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

-- Example state flag (uncomment in DeclareFunctions to use)
-- function modifier_lasthitable_effect:GetModifierStunned()
-- 	return 1
-- end