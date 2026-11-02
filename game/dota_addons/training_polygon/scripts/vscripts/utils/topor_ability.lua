if topor_ability==nil then
	topor_ability=class({})
end

function topor_ability:GetBehavior()
	-- no IMMEDIATE: it fires the cast instantly at the cursor with no targeting phase,
	-- so clicking the icon counted as a ground cast (self damage)
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET+DOTA_ABILITY_BEHAVIOR_POINT+DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end
function topor_ability:GetManaCost()
    return 0
end

function topor_ability:GetCooldown( nLevel )
    return 0
end
function topor_ability:OnSpellStart()
    local hCaster = self:GetCaster() --We will always have Caster.
    local hTarget = false --We might not have target so we make fail-safe so we do not get an error when calling - self:GetCursorTarget()
    if not self:GetCursorTargetingNothing() then
        hTarget = self:GetCursorTarget()
    end
    --print('hTarget',hTarget)
    if hTarget then
        
        if hTarget:GetUnitName()=="npc_dota_observer_wards" then
    		hTarget:Kill(self,hCaster)
    	elseif hTarget:GetUnitName()=="npc_dota_neutral_centaur_khan" then
            hTarget:Kill(self,hCaster)
        elseif hTarget:GetUnitName()=="npc_dota_sentry_wards" then
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
function topor_ability:GetCustomCastErrorTarget( hTarget) -- hTarget is the targeted NPC. 
    local hCaster = self:GetCaster() --We will always have Caster.
    local vOrigin = hCaster:GetAbsOrigin() --Our caster's location

end

-- copies 2-4 so a hero can hold several topors at once (abilities are keyed by name)
if topor_ability_2==nil then
	topor_ability_2=class(topor_ability)
end
if topor_ability_3==nil then
	topor_ability_3=class(topor_ability)
end
if topor_ability_4==nil then
	topor_ability_4=class(topor_ability)
end
