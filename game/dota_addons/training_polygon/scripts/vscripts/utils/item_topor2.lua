if item_topor2==nil then
	item_topor2=class({})
end

function item_topor2:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET+DOTA_ABILITY_BEHAVIOR_POINT
end
function item_topor2:GetManaCost()
    return 0
end

function item_topor2:GetCooldown( nLevel )
    return 0
end
function item_topor2:OnSpellStart()
    local hCaster = self:GetCaster() --We will always have Caster.
    local hTarget = false --We might not have target so we make fail-safe so we do not get an error when calling - self:GetCursorTarget()
    if not self:GetCursorTargetingNothing() then
        hTarget = self:GetCursorTarget()
    end
    if hTarget then
        if hTarget:GetUnitName()=="npc_dota_sentry_wards" then
    		hTarget:Kill(self,hCaster)
    	elseif hTarget:GetUnitName()=="npc_dota_observer_wards" then
            local damageTable = {
                victim = hCaster,
                attacker = hCaster,
                damage = 1,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
                ability = self, --Optional.
            }
            ApplyDamage(damageTable)
        end
	else
    	local damageTable = {
			victim = hCaster,
			attacker = hCaster,
			damage = 1,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)
	end

end
function item_topor2:GetCustomCastErrorTarget( hTarget) -- hTarget is the targeted NPC. 
    local hCaster = self:GetCaster() --We will always have Caster.
    local vOrigin = hCaster:GetAbsOrigin() --Our caster's location

end