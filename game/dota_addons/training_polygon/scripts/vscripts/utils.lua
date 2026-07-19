
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

function string_in_array(str, arr)
    for _, value in ipairs(arr) do
        if value == str then
            return true
        end
    end
    return false
end
--for parsing KV values like "1.0 2.0 3.0 4.0"
function parseQuadroValue(data,level)
	--print('parser input:',data,level)
	local value_count
	if level==nil then
		value_count=1
	else
		value_count=level
	end
	local res_table={}
	local result
	local start=1
	for i=1,string.len(data) do
		local symbol=string.sub(data,i,i)
		if symbol==" " then
			--print('trying to insert:',string.sub(data,start,i-1))
			table.insert(res_table,tonumber(string.sub(data,start,i-1)))
			start=i+1
		end
		
	end
	table.insert(res_table,tonumber(string.sub(data,start,string.len(data))))
	--[[ DeepPrintTable(res_table) ]]
	if value_count=='all' then
		return res_table
	else
		return res_table[value_count]
	end
end

function randomCirclePositionVector(range,vector)
	local x=RandomInt(-range,range)
	local znak=0;
	while znak==0 do
		local hui=RandomInt(-100,100)
		if hui<0 then
			znak=-1
		end
		if hui>0 then
			znak=1
		end
	end
	--print("znak:")
	--print(znak)
	local y=(math.sqrt((range-x)*(range+x)))*znak
	--print("x:")
	--print(x)
	--print("y:")
	--print(y)
	local respawn_place = vector + Vector(x, y, 0)
	--print("vector:")
	--print(respawn_place)
	return respawn_place
end

function randomCirclePosition(range,hero)
	local x=RandomInt(-range,range)
	local znak=0;
	while znak==0 do
		local hui=RandomInt(-100,100)
		if hui<0 then
			znak=-1
		end
		if hui>0 then
			znak=1
		end
	end
	--print("znak:")
	--print(znak)
	local y=(math.sqrt((range-x)*(range+x)))*znak
	--print("x:")
	--print(x)
	--print("y:")*
	--print(y)
	local respawn_place = hero:GetAbsOrigin() + Vector(x, y, 0)
	--print("vector:")
	--print(respawn_place)
	return respawn_place
end