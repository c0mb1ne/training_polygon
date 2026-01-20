
--just bunch of useful functions accross every gamemode


function refreshItems(hero)
	for i=0, 10, 1 do
		local current_item = hero:GetItemInSlot(i)
		if current_item ~= nil then
			current_item:EndCooldown()
		end
	end

end

function refreshSkills(hero)
	for i=0, 5, 1 do
		local current_item = hero:GetAbilityByIndex(i)
		if current_item ~= nil then
			current_item:EndCooldown()
		end
	end

end
function healHero(hero)
	local maxMana=hero:GetMaxMana()
	local maxHp=hero:GetMaxHealth()
	hero:SetHealth(maxHp)
	hero:SetMana(maxMana)
end
--workaround for broken PlayerResource:ReplaceHeroWith method, 
--ReplaceHeroWith trying to get facet id from old hero and give new hero facet with same id, 
--and if new hero dont have such facet throw the error
function replaceHero(old_hero,new_hero)
	local respawn_place=old_hero:GetAbsOrigin()
	local cmdPlayer=PlayerResource:GetPlayer(0)
	old_hero:RemoveSelf()
  print('creating new hero')
  local newHero=CreateHeroForPlayer(new_hero,cmdPlayer)
  newHero:SetControllableByPlayer(0,false)
  newHero:SetRespawnPosition(respawn_place)
  cmdPlayer:SetAssignedHeroEntity(newHero)
  return newHero

end