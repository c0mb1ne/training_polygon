



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