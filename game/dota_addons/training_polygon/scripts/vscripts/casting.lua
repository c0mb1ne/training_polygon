ROW_SCORE=0
TOP_SCORE=0
LIVES_COUNT=0
EVASION_TYPE=0

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
  math.randomseed(os.time())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end
function generateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomString = ""
    local charsetLength = string.len(charset)

    for i = 1, length do
        local randomIndex = math.random(1, charsetLength)
        local randomChar = string.sub(charset, randomIndex, randomIndex)
        randomString = randomString .. randomChar
    end

    return randomString
end

function refreshItems(hero)
	if DODGE_TYPE==1 then
		for i=0, 5, 1 do
			local current_item = hero:GetItemInSlot(i)
			if current_item ~= nil then
				current_item:EndCooldown()
			end
		end
	end
	if DODGE_TYPE==2 then
		local fist=hero:FindAbilityByName("ember_spirit_sleight_of_fist")
		fist:EndCooldown()
	end
	if DODGE_TYPE==3 then
		local shift=hero:FindAbilityByName("puck_phase_shift")
		shift:EndCooldown()
	end
	if DODGE_TYPE==5 then
		local shift=hero:FindAbilityByName("bane_nightmare")
		shift:EndCooldown()
	end
	if DODGE_TYPE==6 then
		local shift=hero:FindAbilityByName("naga_siren_mirror_image")
		shift:EndCooldown()
	end
	if DODGE_TYPE==7 then
		local shift=hero:FindAbilityByName("monkey_king_mischief")
		shift:EndCooldown()
	end
	if DODGE_TYPE==8 then
		local shift=hero:FindAbilityByName("nyx_assassin_spiked_carapace")
		shift:EndCooldown()
	end
	if DODGE_TYPE==9 then
		local shift=hero:FindAbilityByName("void_spirit_dissimilate")
		shift:EndCooldown()
	end
end


function refreshItems2(hero)
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
			print("refreshing:",current_item:GetAbilityName())
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
function casterAbilityTarget(hero,abilityName,caster,respawnPlace,castTime,castDelay,deathDelay)
	local oldRespawnPlace
	if BlinkBehavior==1 then
		local moveDirection=(respawnPlace-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawnPlace+1100*moveDirection
		oldRespawnPlace=respawnPlace
		respawnPlace=newRespawnPlace
	end
	local pepe = CreateUnitByNameAsync(caster, respawnPlace, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end

		unit:SetMoveCapability(1)
		unit:SetForwardVector((hero:GetOrigin() - respawnPlace):Normalized())
		unit:SetIdleAcquire(false)
		local ability = unit:FindAbilityByName(abilityName)
		ability:SetLevel(1)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
		end
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=abilityName})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
					ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					AbilityIndex = ability:entindex(),
					TargetIndex = hero:entindex(),
					Queue = 1
				})
			else
				unit:CastAbilityOnTarget(hero,ability,-1)
				unit:SetIdleAcquire(false)
			end
			local ability_interrupted=0
			local frames_to_skip=3
			local ability_recasted=0
			Timers:CreateTimer({
			    useGameTime = false,
			    endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			    callback = function()
			    	if ability:IsCooldownReady() then
			    		if hero:IsInvulnerable() then
			    			print('Invulnerable')
			    		end
			    		if not ability:IsInAbilityPhase() and ability_interrupted==0 then
			    			print('ability interrupted')
			    			ability_interrupted=1
			    		end
			    		if ability_interrupted==1 then
			    			if ability_recasted==0 and not hero:IsInvulnerable() then
			    				ExecuteOrderFromTable({
									UnitIndex = unit:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
									AbilityIndex = ability:entindex(),
									TargetIndex = hero:entindex()
								})
								ability_recasted=1
			    			end
--[[			    			if frames_to_skip~=0 then
			    				frames_to_skip=frames_to_skip-1
			    			end--]]
			    		end
			    		return FrameTime()
			    	else
			    		return nil
			    	end
			    end
			  })
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
end

function casterAbilityPosition(hero,abilityName,caster,respawnPlace,castTime,castDelay,deathDelay,level)
	if not level then
		level=1
	end
	local oldRespawnPlace
	if BlinkBehavior==1 then
		local moveDirection=(respawnPlace-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawnPlace+1100*moveDirection
		oldRespawnPlace=respawnPlace
		respawnPlace=newRespawnPlace
	end
	local pepe = CreateUnitByNameAsync(caster, respawnPlace, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		unit:SetMoveCapability(1)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		unit:SetForwardVector((hero:GetOrigin() - respawnPlace):Normalized())
		unit:SetIdleAcquire(false)
		local ability
		if abilityName=="item_meteor_hammer" then
			ability=CreateItem("item_meteor_hammer",unit,unit)
	  		unit:AddItem(ability)
	  	else
	  		if abilityName=="riki_permanent_invisibility" then
	  			local invis = unit:FindAbilityByName("riki_backstab")
				invis:SetLevel(3)
				unit:AddNewModifier(unit, nil, "modifier_invisible", {})
	  			ability=CreateItem("item_meteor_hammer",unit,unit)
	  			unit:AddItem(ability)
	  		else
				ability = unit:FindAbilityByName(abilityName)
				ability:SetLevel(level)
			end
		end
		local blink_dagger=CreateItem("item_blink",unit,unit)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
		end
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=abilityName})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
					ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = hero:GetOrigin(),
					AbilityIndex = ability:entindex(),
					Queue = 1
				})
			else
				unit:CastAbilityOnPosition(hero:GetOrigin(),ability,-1)
				unit:SetIdleAcquire(false)
			end
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
end

function casterAbilitySelf(hero,abilityName,caster,respawnPlace,castTime,castDelay,deathDelay)
	local oldRespawnPlace
	if BlinkBehavior==1 then
		local moveDirection=(respawnPlace-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawnPlace+1100*moveDirection
		oldRespawnPlace=respawnPlace
		respawnPlace=newRespawnPlace
	end
	local pepe = CreateUnitByNameAsync(caster, respawnPlace, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		unit:SetMoveCapability(1)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		unit:SetForwardVector((hero:GetOrigin() - respawnPlace):Normalized())
		unit:SetIdleAcquire(false)
		local ability = unit:FindAbilityByName(abilityName)
		ability:SetLevel(1)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
		end
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=abilityName})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
					ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					AbilityIndex = ability:entindex(),
					TargetIndex = unit:entindex(),
					Queue = 1
				})
			else
				unit:CastAbilityOnTarget(unit,ability,-1)
				unit:SetIdleAcquire(false)
			end
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
end

function casterAbilityNotarget(hero,abilityName,caster,respawnPlace,castTime,castDelay,deathDelay)
	if not level then
		level=1
	end	
	local oldRespawnPlace
	if BlinkBehavior==1 then
		local moveDirection=(respawnPlace-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawnPlace+1100*moveDirection
		oldRespawnPlace=respawnPlace
		respawnPlace=newRespawnPlace
	end
	local pepe = CreateUnitByNameAsync(caster, respawnPlace, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		unit:SetMoveCapability(1)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		unit:SetForwardVector((hero:GetOrigin() - respawnPlace):Normalized())
		unit:SetIdleAcquire(false)
		local ability = unit:FindAbilityByName(abilityName)
		ability:SetLevel(level)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
		end
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=abilityName})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
					ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = ability:entindex(),
					Queue = 1
				})
			else
				unit:CastAbilityNoTarget(ability,-1)
				unit:SetIdleAcquire(false)
			end
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
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
function randomRingPosition(range1,range2,hero)
	local R=RandomInt(range1,range2)
	local x=RandomInt(-R,R)
	local znakY=0;
	while znakY==0 do
		local hui=RandomInt(-100,100)
		if hui<0 then
			znakY=-1
		end
		if hui>0 then
			znakY=1
		end
	end
	local y=math.floor(math.sqrt((R-x)*(R+x)))*znakY
	local respawn_place = hero:GetAbsOrigin() + Vector(x, y, 0)
	return respawn_place
end
function randomDisruptorPosition(range,hero)
	local hero_place=hero:GetAbsOrigin()
	local x=0
	local znak=0
	if hero_place.x>=0 and hero_place.y>=0 then
		x=RandomInt(-range,0)
		znak=-1
	elseif hero_place.x>=0 and hero_place.y<0 then
		x=RandomInt(-range,0)
		znak=1
	elseif hero_place.x<0 and hero_place.y<0 then
		x=RandomInt(0,range)
		znak=1
	else
		x=RandomInt(0,range)
		znak=-1
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
function randomRingPositionVec(range1,range2,vec)
	local R=RandomInt(range1,range2)
	local x=RandomInt(-R,R)
	local znakY=0;
	while znakY==0 do
		local hui=RandomInt(-100,100)
		if hui<0 then
			znakY=-1
		end
		if hui>0 then
			znakY=1
		end
	end
	local y=math.floor(math.sqrt((R-x)*(R+x)))*znakY
	local respawn_place = vec + Vector(x, y, 0)
	return respawn_place
end
function randomLinePosition(range1,range2,hero)
	local direction=(hero:GetForwardVector()):Normalized()
	local x=direction.x
	local y=direction.y
	local R=RandomInt(range1,range2)
	x=x*R
	y=y*R
	local respawn_place = hero:GetAbsOrigin() + Vector(x,y,0)
	return respawn_place
end
function randomSquarePosition(minX,minY,maxX,maxY,hero)
	local x=RandomInt(-minX,maxX)
	local y=RandomInt(-minY,maxY)
	local respawn_place = hero:GetAbsOrigin() + Vector(x,y,0)
	return respawn_place
end
function randomSquarePositionAim(minX,minY,maxX,maxY,hero)
	local place_found=0
	local respawn_place
	while place_found==0 do
		local x=RandomInt(-minX,maxX)
		local y=RandomInt(-minY,maxY)
		respawn_place = hero:GetAbsOrigin() + Vector(x,y,0)
		local wards=FindUnitsInRadius(hero:GetTeam(), respawn_place, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		if #wards==0 then
			local lenght=hero:GetAbsOrigin()-respawn_place
			local range=lenght:Length()
			if range>350 then
				place_found=1
			end
		end
	end
	

	return respawn_place
end
function removeItems(hero)
	for i=0,14 do
	    local itemFind=hero:GetItemInSlot(i)
	    --print(itemFind)
	    if itemFind~=nil then
	      hero:RemoveItem(itemFind)
	    end
  	end
end

function evasionChecker(skill,hero,castDelay,castTime)
	local hpBefore=hero:GetHealth()
	-- print("evasionChecker starts:",Time())
	-- print("skill:",skill)
	-- print("castDelay:",castDelay)
	-- print("castTime:",castTime)
	local hui_v_zhope=castDelay+castTime+0.6
	-- print("hui_v_zhope",hui_v_zhope)

	Timers:CreateTimer({
		endTime = hui_v_zhope, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
		  --print ("checking hp")
		  --print(hero:GetHealth(),Time())
		  --print()
		  if hero:GetHealth()<hero:GetMaxHealth() then
		  	local badTime=MANTA_CASTED_TIME-MANTA_HERO_HURT_TIME
		  	-- print("MANTA_CASTED_TIME",MANTA_CASTED_TIME)
		  	-- print("MANTA_HERO_HURT_TIME",MANTA_HERO_HURT_TIME)
		  	-- print("badTime",badTime)
		  	if math.abs(badTime)<1.5 then
		  		sendBad(skill,badTime)
		  	else
		  		sendBad(skill,nil)
		  	end
		  else
		  	sendGood(skill)
		  end
		  refreshSkills(hero)
		  refreshItems(hero)
		  healHero(hero)
		end
	})
end
function evasionCheckerTarget(skill,hero,castDelay,castTime,castpoint)
	local hpBefore=hero:GetHealth()
	--print("evasionChecker starts")
	--print(Time())
	--print("hpBefore:")
	--print(hpBefore)
	  Timers:CreateTimer({
	    useGameTime = false,
	    endTime = castDelay+castTime+castpoint+1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	    callback = function()
	      --print ("checking hp")
	      --print(Time())
	      --print(hero:GetHealth())
	      if hero:GetHealth()<hero:GetMaxHealth() then
	      	local badTime=MANTA_CASTED_TIME-MANTA_HERO_HURT_TIME
	      	--print("badTime",badTime)
	      	if math.abs(badTime)<1.5 then
	      		sendBad(skill,badTime)
	      	else
	      		sendBad(skill,nil)
	      	end
	      else
	      	sendGood(skill)
	      end
	      hero:Purge(false,true,false,true,false)
	      refreshSkills(hero)
	      refreshItems(hero)
	      healHero(hero)
	    end
	  })
end
function evasionCheckerDebuff(skill,hero,castDelay,castTime,debuff)
	local hpBefore=hero:GetHealth()
	--print("evasionCheckerD starts")
	  Timers:CreateTimer({
	    useGameTime = false,
	    endTime = castDelay+castTime+0.6, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	    callback = function()
	      --print(hero:FindModifierByName(debuff))
	      if hero:FindModifierByName(debuff) then
	      	local badTime=MANTA_CASTED_TIME-MANTA_MODIFIER_GAINED
	      	--print("badTime",badTime)
	      	if math.abs(badTime)<1.5 then
	      		sendBad(skill,badTime)
	      	else
	      		sendBad(skill,nil)
	      	end
	      else
	      	sendGood(skill)
	      end
	      refreshSkills(hero)
	      refreshItems(hero)
	      hero:RemoveModifierByName(debuff)
	      healHero(hero)
	    end
	  })
end
function evasionCheckerStun(skill,hero,castDelay,castTime)
	local hpBefore=hero:GetHealth()
	print("evasionChecker starts:",Time())
	print("skill:",skill)
	print("castDelay:",castDelay)
	print("castTime:",castTime)
	local hui_v_zhope=castDelay+castTime+0.6
	-- print("hui_v_zhope",hui_v_zhope)
	  Timers:CreateTimer({
	    useGameTime = false,
	    endTime = hui_v_zhope, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	    callback = function()
	      print("CHECKING EVASION:",Time())
	      if hero:IsStunned() then
	      	local badTime=MANTA_CASTED_TIME-MANTA_MODIFIER_GAINED
	      	--print("badTime",badTime)
	      	if math.abs(badTime)<1.5 then
	      		sendBad(skill,badTime)
	      	else
	      		sendBad(skill,nil)
	      	end
	      else
	      	sendGood(skill)
	      end
	      
	      hero:Purge(false,true,false,true,false)
	      refreshSkills(hero)
	      refreshItems(hero)
	      healHero(hero)
	    end
	  })
end
function sendGood(skill)
	print("good:",skill)
	ROW_SCORE=ROW_SCORE+1
	if ROW_SCORE>TOP_SCORE then
		TOP_SCORE=ROW_SCORE
	end
	CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon=skill})
	CustomGameEventManager:Send_ServerToAllClients("top_score",{score=TOP_SCORE})
	CustomGameEventManager:Send_ServerToAllClients("evasion_check",{dodgestreak=ROW_SCORE, how="good", skillId=skill, lives=LIVES_COUNT})

end
function sendBad(skill,badTime)
	print("bad:",skill)
	ROW_SCORE=0
	LIVES_COUNT=LIVES_COUNT-1
	if badTime~=nil then
		--print("AAAAAAAAA EBUT POMOGITE")
		local displayDelay=math.floor(badTime*1000)/1000
		CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad! Delay: '..displayDelay,icon=skill})
		CustomGameEventManager:Send_ServerToAllClients("evasion_check",{dodgestreak=ROW_SCORE, how="bad", skillId=skill, lives=LIVES_COUNT, time=badTime})
	else
		CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon=skill})
		CustomGameEventManager:Send_ServerToAllClients("evasion_check",{dodgestreak=ROW_SCORE, how="bad", skillId=skill, lives=LIVES_COUNT})
	end

	
	CustomGameEventManager:Send_ServerToAllClients("update_lives",{lives=LIVES_COUNT})
end

function roundKek(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

--casterAbilityPosition(hero,abilityName,caster,respawnPlace,castTime,castDelay,deathDelay)
function kunkkaGhostship(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castpoint=0.3
	local casttime=3.077
	local castTime=castpoint+casttime
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(400,650,hero)
	else
		respawn_place = randomRingPosition(400,1000,hero)
	end
	local ability_name = "kunkka_ghostship"
	local caster_name = "npc_dota_hero_kunkka"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castpoint+casttime)
	return castTime
end

function linaLightStrike(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castpoint=0.45
	local damageDelay=0.5
	local castTime=castpoint+damageDelay
	local respawn_place = randomRingPosition(400,600,hero)
	local ability_name = "lina_light_strike_array"
	local caster_name = "npc_dota_hero_lina"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function linaLaguna(hero,castDelay,deathDelay)
	local castpoint=0.45
	local damageDelay=0.25
	local castTime=castpoint+damageDelay
	local respawn_place = randomRingPosition(400,600,hero)
	local ability_name = "lina_laguna_blade"
	local caster_name = "npc_dota_hero_lina"
	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerTarget(ability_name,hero,castDelay,castTime,castpoint)
	return castTime
end
function bseekerBloodBath(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castpoint=0.3
	local damageDelay=2.6
	local castTime=castpoint+damageDelay
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(400,650,hero)
	else
		respawn_place = randomRingPosition(400,1000,hero)
	end
	local ability_name = "bloodseeker_blood_bath"
	local caster_name = "npc_dota_hero_bloodseeker"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function pugnaNetherBlast(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castpoint=0.2
	local damageDelay=0.9
	local castTime=castpoint+damageDelay
	local respawn_place = randomCirclePosition(400,hero)
	local ability_name = "pugna_nether_blast"
	local caster_name = "npc_dota_hero_pugna"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function meepoPoof(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=1.5
	local respawn_place = randomRingPosition(30,350,hero)
	local ability_name = "meepo_poof"
	local caster_name = "npc_dota_hero_meepo"
	casterAbilitySelf(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function necroPulse(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local respawn_place = randomRingPosition(150,475,hero)
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=(range-48)/400
	local ability_name = "necrolyte_death_pulse"
	local caster_name = "npc_dota_hero_necrolyte"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function miranaStarfall(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=1.07
	local respawn_place = randomRingPosition(450,650,hero)
	local ability_name = "mirana_starfall"
	local caster_name = "npc_dota_hero_mirana"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end	
function sfCoil(hero,castDelay,deathDelay,coiltype)
	EVASION_TYPE=1
	if coiltype==0 then
		coiltype=RandomInt(1,3)
	end
	local castTime=0.55
	if coiltype==1 then
		ability_name = "nevermore_shadowraze1"
		range=200
	elseif coiltype==2 then
		ability_name = "nevermore_shadowraze2"
		range=450
	elseif coiltype==3 then
		ability_name = "nevermore_shadowraze3"
		range=700
	end
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(range-200,range-50,hero)
	else
		respawn_place = randomRingPosition(range-200,range+200,hero)
	end
	local caster_name = "npc_dota_hero_nevermore"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function zeusBolt(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,700,hero)
	end
	local ability_name = "zuus_lightning_bolt"
	local caster_name = "npc_dota_hero_zuus"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function zeusUlt(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(100,650,hero)
	else
		respawn_place = randomRingPosition(300,700,hero)
	end
	local ability_name = "zuus_thundergods_wrath"
	local caster_name = "npc_dota_hero_zuus"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function tideSmash(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.4
	local respawn_place = randomRingPosition(50,300,hero)
	local ability_name = "tidehunter_anchor_smash"
	local caster_name = "npc_dota_hero_tidehunter"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function ursaSmash(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.3
	local respawn_place = randomRingPosition(50,350,hero)
	local ability_name = "ursa_earthshock"
	local caster_name = "npc_dota_hero_ursa"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function omnikHeal(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.2
	local respawn_place = randomRingPosition(50,250,hero)
	local ability_name = "omniknight_purification"
	local caster_name = "npc_dota_hero_omniknight"
	casterAbilitySelf(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function alcheBanka(hero,castDelay,deathDelay)
	EVASION_TYPE=4
	local nakrutka=RandomFloat(0.5,3)
	--nakrutka=3
	local respawn_place
	local oldRespawnPlace
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(200,650,hero)
		local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawn_place+1100*moveDirection
		oldRespawnPlace=respawn_place
		respawn_place=newRespawnPlace
	else
		respawn_place = randomRingPosition(200,750,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castpoint=0.2
	local castTime=(range-48)/900+castpoint+nakrutka
	local ability_name1 = "alchemist_unstable_concoction"
	local ability_name2 = "alchemist_unstable_concoction_throw"
	local caster_name = "npc_dota_hero_alchemist"
		local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		unit:AddAbility(ability_name1)
		unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
		unit:SetIdleAcquire(false)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		local ability = unit:FindAbilityByName(ability_name1)
		ability:SetLevel(1)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
		end
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name1})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()

			unit:CastAbilityNoTarget(ability,-1)
			unit:SetIdleAcquire(false)
			local ability2 = unit:FindAbilityByName(ability_name2)
			Timers:CreateTimer({
			    useGameTime = false,
			    endTime = nakrutka, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			    callback = function()
    				if BlinkBehavior==1 then
						ExecuteOrderFromTable({
							UnitIndex = unit:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = oldRespawnPlace,
							AbilityIndex = blink_dagger:entindex(),
							Queue = 0
						})
							ExecuteOrderFromTable({
							UnitIndex = unit:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
							AbilityIndex = ability:entindex(),
							TargetIndex = hero:entindex(),
							Queue = 1
						})
					else
						unit:CastAbilityOnTarget(hero,ability2,-1)
					end
			    	Timers:CreateTimer({
					    useGameTime = false,
					    endTime = 0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
					    callback = function()
					    	unit:CastAbilityOnTarget(hero,ability2,-1)
					    end
					  })
			    end
			  })
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
	evasionCheckerTarget(ability_name1,hero,castDelay,castTime,castpoint)
	return castTime
end
function skymageBolt(hero,castDelay,deathDelay)
	EVASION_TYPE=4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(100,650,hero)
	else
		respawn_place = randomRingPosition(100,750,hero)
	end
	
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castpoint=0.1
	local castTime=(range-48)/500+castpoint
	local ability_name = "skywrath_mage_arcane_bolt"
	local caster_name = "npc_dota_hero_skywrath_mage"
	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerTarget(ability_name,hero,castDelay,castTime,castpoint)
	return castTime
end
function medusaSnake(hero,castDelay,deathDelay)
	EVASION_TYPE=4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(100,650,hero)
	else
		respawn_place = randomRingPosition(100,750,hero)
	end
	--local respawn_place =randomCirclePosition(range,hero)
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	--print("range:")
	--print(range)
	local castTime=(range-48)/800+0.4
	--print("Snake cast time:")
	--print(castTime)
	local ability_name = "medusa_mystic_snake"
	local caster_name = "npc_dota_hero_medusa"
	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function medusaUlt(hero,castDelay,deathDelay,level)
	EVASION_TYPE=2
	local castTime=2.4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomLinePosition(100,650,hero)
	else
		respawn_place = randomLinePosition(100,750,hero)
	end
	local ability_name = "medusa_stone_gaze"
	local caster_name = "npc_dota_hero_medusa"
	local modifier_name="modifier_medusa_stone_gaze_stone"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay,level)
	evasionCheckerDebuff(ability_name,hero,castDelay,castTime,modifier_name)
	return castTime
end
function sdUlt(hero,castDelay,deathDelay)
	EVASION_TYPE=3
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(100,650,hero)
	else
		respawn_place = randomRingPosition(100,757,hero)
	end
	local castpoint=0.3
	local castTime=7+castpoint
	local caster_name = "npc_dota_hero_shadow_demon"
	local ability_name = "shadow_demon_demonic_purge"
	-- local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
	-- 	--unit:AddAbility(ability_name)
	-- 	unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
	-- 	unit:SetIdleAcquire(false)

	-- 	local ability = unit:FindAbilityByName(ability_name)
	-- 	ability:SetLevel(1)
	-- 	CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
	-- 	unit:SetContextThink(DoUniqueString("cast_ability"),
	-- 	function()

	-- 		unit:CastAbilityOnTarget(hero,ability,-1)
	-- 		unit:SetIdleAcquire(false)
	-- 		Timers:CreateTimer({
	-- 		    useGameTime = false,
	-- 		    endTime = 0.6, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	-- 		    callback = function()
	-- 		    		unit:CastAbilityOnTarget(hero,ability,-1)
	-- 		    		unit:SetIdleAcquire(false)

			    	
	-- 		    end
	-- 		  })

	-- 	end,
	-- 	castDelay) 
	-- 	unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
	-- 	return unit
 --    end)
 	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerTarget(ability_name,hero,castDelay,castTime,castpoint)
	return castTime
end
function shakerFisssure(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local respawn_place
	local castTime=0.69
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,1300,hero)
	end
	local ability_name = "earthshaker_fissure"
	local caster_name = "npc_dota_hero_earthshaker"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function shakerTotem(hero,castDelay,deathDelay,scepter)
	local castTime
	local respawn_place
	local oldRespawnPlace
	local ability_name = "earthshaker_enchant_totem"
	local ability_name2= "earthshaker_aftershock"
	local caster_name = "npc_dota_hero_earthshaker"
    if scepter==1 then
    	EVASION_TYPE=5
		castTime=1.03
		if BlinkBehavior==1 then
			respawn_place = randomRingPosition(300,650,hero)
			local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
			local newRespawnPlace=respawn_place+1100*moveDirection
			oldRespawnPlace=respawn_place
			respawn_place=newRespawnPlace
		else
			respawn_place = randomRingPosition(200,800,hero)
		end
		local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
			--unit:AddAbility(abilityName)
			unit:SetMoveCapability(1)
			if DODGE_TYPE==2 then
				unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
			end
			unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
			unit:SetIdleAcquire(false)
			local item = CreateItem("item_ultimate_scepter", unit, unit)  
        	unit:AddItem(item)
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(1)
			local ability2 = unit:FindAbilityByName(ability_name2)
			ability2:SetLevel(4)
			local blink_dagger=CreateItem("item_blink",unit,unit)
			if BlinkBehavior==1 then
				unit:AddItem(blink_dagger)
			end
			CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
			unit:SetContextThink(DoUniqueString("cast_ability"),
			function()
				if BlinkBehavior==1 then
					ExecuteOrderFromTable({
						UnitIndex = unit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = oldRespawnPlace,
						AbilityIndex = blink_dagger:entindex(),
						Queue = 0
					})
						ExecuteOrderFromTable({
						UnitIndex = unit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = hero:GetOrigin(),
						AbilityIndex = ability:entindex(),
						Queue = 1
					})
				else
					unit:CastAbilityOnPosition(hero:GetOrigin(),ability,-1)
					unit:SetIdleAcquire(false)
				end
			end,
			castDelay) 
			unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
			return unit
	    end)
	else
		EVASION_TYPE=1
		castTime=0.69
		respawn_place = randomRingPosition(50,250,hero)
		if BlinkBehavior==1 then
			local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
			local newRespawnPlace=respawn_place+1100*moveDirection
			oldRespawnPlace=respawn_place
			respawn_place=newRespawnPlace
		end
		local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
			--unit:AddAbility(abilityName)
			unit:SetMoveCapability(1)
			unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
			unit:SetIdleAcquire(false)
			if DODGE_TYPE==2 then
				unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
			end
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(1)
			local ability2 = unit:FindAbilityByName(ability_name2)
			ability2:SetLevel(4)
			local blink_dagger=CreateItem("item_blink",unit,unit)
			if BlinkBehavior==1 then
				unit:AddItem(blink_dagger)
			end			
			CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
			unit:SetContextThink(DoUniqueString("cast_ability"),
			function()
				if BlinkBehavior==1 then
					ExecuteOrderFromTable({
						UnitIndex = unit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = oldRespawnPlace,
						AbilityIndex = blink_dagger:entindex(),
						Queue = 0
					})
						ExecuteOrderFromTable({
						UnitIndex = unit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = ability:entindex(),
						Queue = 1
					})
				else
					unit:CastAbilityNoTarget(ability,-1)
					unit:SetIdleAcquire(false)
				end
			end,
			castDelay) 
			unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
			return unit
	    end)
	end
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function invokerEmp(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=2.95
	local respawn_place
	local oldRespawnPlace
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
		local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawn_place+1100*moveDirection
		oldRespawnPlace=respawn_place
		respawn_place=newRespawnPlace
	else
		respawn_place = randomRingPosition(300,900,hero)
	end
	local ability_name = "invoker_emp"
	local invoke_name="invoker_invoke"
	local wex_name="invoker_wex"
	local caster_name = "npc_dota_hero_invoker"
	local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)		
		unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
		unit:SetIdleAcquire(false)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		local invoke = unit:FindAbilityByName(invoke_name)
		invoke:SetLevel(1)
		local wex=unit:FindAbilityByName(wex_name)
		wex:SetLevel(3)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		local ability=unit:FindAbilityByName(ability_name)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
			ability:SetLevel(5)
			ability:SetHidden(false)
		end

		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = hero:GetOrigin(),
					AbilityIndex = ability:entindex(),
					Queue = 1
				})
			else
				unit:CastAbilityNoTarget(wex,-1)
				unit:CastAbilityNoTarget(wex,-1)
				unit:CastAbilityNoTarget(wex,-1)
				unit:CastAbilityNoTarget(invoke,-1)
				unit:CastAbilityOnPosition(hero:GetOrigin(),ability,-1)
				unit:SetIdleAcquire(false)
			end
			
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function odUlt(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.25
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,675,hero)
	end
	local ability_name = "obsidian_destroyer_sanity_eclipse"
	local caster_name = "npc_dota_hero_obsidian_destroyer"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function zombieDecay(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.45
	local respawn_place = randomRingPosition(300,600,hero)
	local ability_name = "undying_decay"
	local caster_name = "npc_dota_hero_undying"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function titanStomp(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=1.7
	local respawn_place = randomRingPosition(50,475,hero)
	local ability_name = "elder_titan_echo_stomp"
	local caster_name = "npc_dota_hero_elder_titan"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function clockRocket(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(500,650,hero)
	else
		respawn_place = randomRingPosition(500,1500,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=(range-24)/1750+0.3
	local ability_name = "rattletrap_rocket_flare"
	local caster_name = "npc_dota_hero_rattletrap"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function clockHook(hero,castDelay,deathDelay,level)
	EVASION_TYPE=5
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(500,650,hero)
	else
		respawn_place = randomRingPosition(500,1500,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=(range-48)/4000+0.3
	local ability_name = "rattletrap_hookshot"
	local caster_name = "npc_dota_hero_rattletrap"
	local modifier_name = "modifier_stuned"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay,level)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function wrPowershot(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(500,650,hero)
	else
		respawn_place = randomRingPosition(500,1500,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=(range-24)/3000+1
	local ability_name = "windrunner_powershot"
	local caster_name = "npc_dota_hero_windrunner"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function huskarUlt(hero,castDelay,deathDelay)
	EVASION_TYPE=4
	local respawn_place = randomRingPosition(300,525,hero)
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castpoint=0.3
	local castTime=(range-48)/1000+castpoint
	local ability_name = "huskar_life_break"
	local caster_name = "npc_dota_hero_huskar"
	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerTarget(ability_name,hero,castDelay,castTime,castpoint)
	return castTime
end
function gyroMissle(hero,castDelay,deathDelay)
	EVASION_TYPE=4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(500,650,hero)
	else
		respawn_place = randomRingPosition(500,1000,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()-174
	local speed=340
	local castpoint=0.3
	local castTime=2+castpoint
	while range>0 do
		if range>speed*0.05 then
			range=range-speed*0.05
			castTime=castTime+0.05
			speed=speed+1
		else
			speed=speed+1
			castTime=castTime+range/speed
			range=0
		end
	end
	local ability_name = "gyrocopter_homing_missile"
	local caster_name = "npc_dota_hero_gyrocopter"
	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function tinyToss(hero,castDelay,deathDelay)
	EVASION_TYPE=4
	local oldRespawnPlace
	local respawn_place
	local wisp_respawn
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(800,900,hero)
		-- local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
		-- local newRespawnPlace=respawn_place+1100*moveDirection
		-- oldRespawnPlace=respawn_place
		-- respawn_place=newRespawnPlace
		wisp_respawn=respawn_place+Vector(100,0,0)
	else
		respawn_place = randomRingPosition(500,1200,hero)
		wisp_respawn=respawn_place+Vector(100,0,0)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=1.3
	local ability_name = "tiny_toss"
	local caster_name = "npc_dota_hero_tiny"
	local wisp_name="npc_dota_hero_wisp"
	local wisp = CreateUnitByName(wisp_name,wisp_respawn,true,nil,nil,DOTA_TEAM_BADGUYS)
	wisp:SetIdleAcquire(false)
	if DODGE_TYPE==2 then
		wisp:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
	end
	wisp:SetContextThink(DoUniqueString("Remove_Self"),function()  wisp:RemoveSelf() end, castDelay+deathDelay+castTime)
	local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		unit:SetMoveCapability(1)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
		unit:SetIdleAcquire(false)
		local ability = unit:FindAbilityByName(ability_name)
		ability:SetLevel(1)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		-- if BlinkBehavior==1 then
		-- 	unit:AddItem(blink_dagger)
		-- end
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			-- if BlinkBehavior==1 then
			-- 	ExecuteOrderFromTable({
			-- 		UnitIndex = unit:entindex(),
			-- 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			-- 		Position = oldRespawnPlace,
			-- 		AbilityIndex = blink_dagger:entindex(),
			-- 		Queue = 0
			-- 	})
			-- 		ExecuteOrderFromTable({
			-- 		UnitIndex = unit:entindex(),
			-- 		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			-- 		AbilityIndex = ability:entindex(),
			-- 		TargetIndex = hero:entindex(),
			-- 		Queue = 1
			-- 	})
			-- else
				unit:CastAbilityOnTarget(hero,ability,-1)
				unit:SetIdleAcquire(false)
			-- end
			Timers:CreateTimer({
			    useGameTime = false,
			    endTime = 0.6, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			    callback = function()
			    		unit:CastAbilityOnTarget(hero,ability,-1)
			    		unit:SetIdleAcquire(false)

			    	
			    end
			  })
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
	evasionCheckerTarget(ability_name,hero,castDelay,castTime,0)
	return castTime
end
function phoenixNova(hero,castDelay,deathDelay)
	EVASION_TYPE=2
	local castTime=6.01
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(200,650,hero)
	else
		respawn_place = randomRingPosition(200,900,hero)
	end	local ability_name = "phoenix_supernova"
	local caster_name = "npc_dota_hero_phoenix"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function lcFirstskill(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(400,650,hero)
	else
		respawn_place = randomRingPosition(400,900,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=0.3
	local ability_name = "legion_commander_overwhelming_odds"
	local caster_name = "npc_dota_hero_legion_commander"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function magnusRp(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.3
	local respawn_place = randomRingPosition(50,400,hero)
	local ability_name = "magnataur_reverse_polarity"
	local caster_name = "npc_dota_hero_magnataur"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function slardarStun(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.35
	local respawn_place = randomRingPosition(50,300,hero)
	local ability_name = "slardar_slithereen_crush"
	local caster_name = "npc_dota_hero_slardar"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function axeAgro(hero,castDelay,deathDelay)
	EVASION_TYPE=2
	local castTime=0.4
	local respawn_place = randomRingPosition(90,275,hero)
	local ability_name = "axe_berserkers_call"
	local caster_name = "npc_dota_hero_axe"
	local modifier_name="modifier_axe_berserkers_call"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerDebuff(ability_name,hero,castDelay,castTime,modifier_name)
	return castTime
end
function brewClap(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.4
	local respawn_place = randomRingPosition(90,375,hero)
	local ability_name = "brewmaster_thunder_clap"
	local caster_name = "npc_dota_hero_brewmaster"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function centStun(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.5
	local respawn_place = randomRingPosition(50,300,hero)
	local ability_name = "centaur_hoof_stomp"
	local caster_name = "npc_dota_hero_centaur"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function lionUlt(hero,castDelay,deathDelay)
	EVASION_TYPE=3
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,875,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castpoint=0.3
	local castTime=0.25+castpoint
	local ability_name = "lion_finger_of_death"
	local caster_name = "npc_dota_hero_lion"
	casterAbilityTarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerTarget(ability_name,hero,castDelay,castTime,castpoint)
	return castTime
end
function qopScream(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local respawn_place = randomRingPosition(300,450,hero)
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local castTime=(range-48)/900
	local ability_name = "queenofpain_scream_of_pain"
	local caster_name = "npc_dota_hero_queenofpain"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end

function familiarStun(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.55
	local respawn_place = randomRingPosition(50,300,hero)
	local ability_name = "visage_summon_familiars_stone_form"
	local caster_name = "npc_dota_visage_familiar1"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function neutralUrsaClap(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.5
	local respawn_place = randomRingPosition(50,275,hero)
	local ability_name = "polar_furbolg_ursa_warrior_thunder_clap"
	local caster_name = "npc_dota_neutral_polar_furbolg_ursa_warrior"
	local modifier_name="modifier_polar_furbolg_ursa_warrior_thunder_clap"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerDebuff(ability_name,hero,castDelay,castTime,modifier_name)
	return castTime
end
function forestCentStun(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.5
	local respawn_place = randomRingPosition(50,225,hero)
	local ability_name = "centaur_khan_war_stomp"
	local caster_name = "npc_dota_neutral_centaur_khan"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end

function monkeyTreeJump(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local ability_name1 = "monkey_king_tree_dance"
	local ability_name2 = "monkey_king_primal_spring"
	local caster_name = "npc_dota_mk_fix"
	local tree_respawn_place
	if BlinkBehavior==1 then
		tree_respawn_place = randomRingPosition(700,900,hero)
	else
		tree_respawn_place = randomRingPosition(300,990,hero)
	end
	local lenght=hero:GetAbsOrigin()-tree_respawn_place
	local range=lenght:Length()
	local castTime=1.6+(range/1300)
	CreateTempTree(tree_respawn_place,castDelay+deathDelay+castTime)
	local trees=GridNav:GetAllTreesAroundPoint(tree_respawn_place,200,true)
	local pepe = CreateUnitByNameAsync(caster_name, tree_respawn_place+Vector(50,0,0), true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		unit:SetMoveCapability(1)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		unit:SetForwardVector((hero:GetOrigin() - tree_respawn_place+Vector(50,0,0)):Normalized())
		unit:SetIdleAcquire(false)
		local ability1 = unit:FindAbilityByName(ability_name1)
		ability1:SetLevel(1)
		local ability2 = unit:FindAbilityByName(ability_name2)
		ability2:SetLevel(1)
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			unit:CastAbilityOnTarget(trees[1],ability1,-1)
			unit:SetIdleAcquire(false)
			CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name2})
			unit:SetContextThink(DoUniqueString("cast_ability2"),
			function()
				unit:CastAbilityOnPosition(hero:GetOrigin(),ability2,-1)
				unit:SetIdleAcquire(false)
			end,
			castDelay) 
		end,
		0) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
	evasionChecker(ability_name2,hero,castDelay,castTime)
	return castTime
end
function monkeyBarHit(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.4
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,1100,hero)
	end
	local ability_name = "monkey_king_boundless_strike"
	local caster_name = "npc_dota_mk_fix"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end

function techiesSuicide(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=1.75
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,900,hero)
	end
	local ability_name = "techies_suicide"
	local caster_name = "npc_dota_hero_techies"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end

function ProwlerStun(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.9
	local respawn_place = randomRingPosition(50,225,hero)
	local ability_name = "spawnlord_master_stomp"
	local caster_name = "npc_dota_neutral_prowler_shaman"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end

function odAstral(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.25+4
	local respawn_place = randomRingPosition(50,200,hero)
	local ability_name = "obsidian_destroyer_astral_imprisonment"
	local caster_name = "npc_dota_hero_obsidian_destroyer"
	casterAbilitySelf(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function roshanClap(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=0.47
	local respawn_place = randomRingPosition(80,300,hero)
	local ability_name = "roshan_slam"
	local caster_name = "npc_dota_roshan"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function invokerSunStrike(hero,castDelay,deathDelay)
	EVASION_TYPE=1
	local castTime=1.75
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
		local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawn_place+1100*moveDirection
		oldRespawnPlace=respawn_place
		respawn_place=newRespawnPlace
	else
		respawn_place = randomRingPosition(300,900,hero)
	end
	local ability_name = "invoker_sun_strike"
	local invoke_name="invoker_invoke"
	local exort_name="invoker_exort"
	local caster_name = "npc_dota_hero_invoker"
	local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)		
		unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
		unit:SetIdleAcquire(false)
		if DODGE_TYPE==2 then
			unit:AddNewModifier(unit, nil, "modifier_pugna_decrepify", {})
		end
		local invoke = unit:FindAbilityByName(invoke_name)
		invoke:SetLevel(1)
		local exort=unit:FindAbilityByName(exort_name)
		exort:SetLevel(3)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		
		local ability=unit:FindAbilityByName(ability_name)

		if BlinkBehavior==1 then
			ability:SetLevel(5)
			ability:SetHidden(false)
			unit:AddItem(blink_dagger)
		end	
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = hero:GetOrigin(),
					AbilityIndex = ability:entindex(),
					Queue = 1
				})


			else
				unit:CastAbilityNoTarget(exort,-1)
				unit:CastAbilityNoTarget(exort,-1)
				unit:CastAbilityNoTarget(exort,-1)
				unit:CastAbilityNoTarget(invoke,-1)
				unit:CastAbilityOnPosition(hero:GetOrigin(),ability,-1)
				unit:SetIdleAcquire(false)
			end
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function kunkkaTorrent(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=2
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,900,hero)
	end
	local ability_name = "kunkka_torrent"
	local caster_name = "npc_dota_hero_kunkka"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay,4)
	evasionChecker(ability_name,hero,castDelay,castTime+1.5)
	return castTime
end
function kunkkaTidebringer(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=0
	local respawn_place
	local oldRespawnPlace
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
		local moveDirection=(respawn_place-hero:GetAbsOrigin()):Normalized()
		local newRespawnPlace=respawn_place+1100*moveDirection
		oldRespawnPlace=respawn_place
		respawn_place=newRespawnPlace
	else
		respawn_place = randomRingPosition(300,900,hero)
		oldRespawnPlace=respawn_place
	end
	local ability_name = "kunkka_tidebringer"
	local caster_name = "npc_dota_hero_kunkka"
	local pepe = CreateUnitByNameAsync(caster_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
		--unit:AddAbility(abilityName)
		unit:SetMoveCapability(1)

		unit:SetAttackCapability(1)
		unit:SetForwardVector((hero:GetOrigin() - respawn_place):Normalized())
		unit:SetIdleAcquire(false)
		local ability = unit:FindAbilityByName(ability_name)
		ability:SetLevel(4)
		local blink_dagger=CreateItem("item_blink",unit,unit)
		if BlinkBehavior==1 then
			unit:AddItem(blink_dagger)
		end
		local direction = (hero:GetAbsOrigin()-respawn_place):Normalized()
		local target_point_vector = oldRespawnPlace + 50 * direction
		local target="npc_dota_creep_goodguys_melee"
		local pizduk2=CreateUnitByName(target, target_point_vector, true, nil, nil, hero:GetTeam())
		pizduk2:SetIdleAcquire(false)

		castTime=unit:GetAttackAnimationPoint()
		CustomGameEventManager:Send_ServerToAllClients("spell_casted",{castpoint=castTime, delay=castDelay, abil=ability_name})
		unit:SetContextThink(DoUniqueString("cast_ability"),
		function()
			if BlinkBehavior==1 then
				ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = oldRespawnPlace,
					AbilityIndex = blink_dagger:entindex(),
					Queue = 0
				})
					ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					AbilityIndex = ability:entindex(),
					TargetIndex = pizduk2:entindex(),
					Queue = 1
				})
			else
				unit:CastAbilityOnTarget(pizduk2,ability,-1)
				unit:SetIdleAcquire(false)
			end
			
		end,
		castDelay) 
		unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf();pizduk2:RemoveSelf() end, castDelay+deathDelay+castTime)
		return unit
    end)

	evasionChecker(ability_name,hero,castDelay,castTime+0.3)
	return castTime
end
function elderUlt(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=3.54
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,900,hero)
	end
	local ability_name = "elder_titan_earth_splitter"
	local caster_name = "npc_dota_hero_elder_titan"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay+1.5)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function leshracStun(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=1.05
	local respawn_place = randomRingPosition(300,650,hero)
	local ability_name = "leshrac_split_earth"
	local caster_name = "npc_dota_hero_leshrac"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function warlockGolem(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=1
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,650,hero)
	end
	local ability_name = "warlock_rain_of_chaos"
	local caster_name = "npc_dota_hero_warlock"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function pangoSlam(hero,castDelay,deathDelay)

	local respawn_place = randomRingPosition(300,450,hero)
	local castTime=0.4
	local ability_name = "pangolier_shield_crash"
	local caster_name = "npc_dota_hero_pangolier"
	casterAbilityNotarget(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionChecker(ability_name,hero,castDelay,castTime)
	return castTime
end
function willowFear(hero,castDelay,deathDelay)

	
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,650,hero)
	else
		respawn_place = randomRingPosition(300,1100,hero)
	end
	local lenght=hero:GetAbsOrigin()-respawn_place
	local range=lenght:Length()
	local heigth=300
	local s=math.sqrt((range*range)+(heigth*heigth))
	local castTime=(s-48)/2000+1
	local ability_name = "dark_willow_terrorize"
	local caster_name = "npc_dota_hero_dark_willow"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay+0.5)
	evasionCheckerDebuff(ability_name,hero,castDelay,castTime,"modifier_dark_willow_debuff_fear")
	return castTime
end
function rikiMemeHammer(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=3
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,475,hero)
	else
		respawn_place = randomRingPosition(300,475,hero)
	end
	local ability_name = "item_meteor_hammer"
	local caster_name = "npc_dota_hero_riki"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun(ability_name,hero,castDelay,castTime)
	return castTime
end
function rikiMemeHammerInv(hero,castDelay,deathDelay)
	EVASION_TYPE=5
	local castTime=3
	local respawn_place
	if BlinkBehavior==1 then
		respawn_place = randomRingPosition(300,475,hero)
	else
		respawn_place = randomRingPosition(300,475,hero)
	end
	local ability_name = "riki_permanent_invisibility"
	local caster_name = "npc_dota_hero_riki"
	casterAbilityPosition(hero,ability_name,caster_name,respawn_place,castTime,castDelay,deathDelay)
	evasionCheckerStun("item_meteor_hammer",hero,castDelay,castTime)
	return castTime
end
function castSpellById(id,hero,castDelay,deathDelay)
	--ID=1-46
	local castTime
	if id==1 then
		castTime=linaLightStrike(hero,castDelay,deathDelay)
	elseif id==2 then
		castTime=kunkkaGhostship(hero,castDelay,deathDelay)
	elseif id==3 then
		castTime=linaLaguna(hero,castDelay,deathDelay)
	elseif id==4 then
		castTime=bseekerBloodBath(hero,castDelay,deathDelay)
	elseif id==5 then
		castTime=pugnaNetherBlast(hero,castDelay,deathDelay)
	elseif id==6 then
		castTime=meepoPoof(hero,castDelay,deathDelay)
	elseif id==7 then
		castTime=necroPulse(hero,castDelay,deathDelay)
	elseif id==8 then
		castTime=miranaStarfall(hero,castDelay,deathDelay)
	elseif id==9 then
		castTime=sfCoil(hero,castDelay,deathDelay,1)
	elseif id==10 then
		castTime=sfCoil(hero,castDelay,deathDelay,2)
	elseif id==11 then
		castTime=sfCoil(hero,castDelay,deathDelay,3)
	elseif id==12 then
		castTime=zeusBolt(hero,castDelay,deathDelay)
	elseif id==13 then
		castTime=zeusUlt(hero,castDelay,deathDelay)
	elseif id==14 then
		castTime=tideSmash(hero,castDelay,deathDelay)
	elseif id==15 then
		castTime=ursaSmash(hero,castDelay,deathDelay)
	elseif id==16 then
		castTime=omnikHeal(hero,castDelay,deathDelay)
	elseif id==17 then
		castTime=alcheBanka(hero,castDelay,deathDelay)
	elseif id==18 then
		castTime=skymageBolt(hero,castDelay,deathDelay)
	elseif id==19 then
		castTime=medusaSnake(hero,castDelay,deathDelay)
	elseif id==20 then
		castTime=medusaUlt(hero,castDelay,deathDelay+1,1)
	elseif id==21 then
		castTime=techiesSuicide(hero,castDelay,deathDelay)
	elseif id==22 then
		castTime=monkeyBarHit(hero,castDelay,deathDelay)
	elseif id==23 then
		castTime=sdUlt(hero,castDelay,deathDelay+1)
	elseif id==24 then
		castTime=shakerFisssure(hero,castDelay,deathDelay)
	elseif id==25 then
		castTime=shakerTotem(hero,castDelay,deathDelay)
	elseif id==26 then
		castTime=shakerTotem(hero,castDelay,deathDelay,1)
	elseif id==27 then
		castTime=invokerEmp(hero,castDelay,deathDelay)
	elseif id==28 then
		castTime=odUlt(hero,castDelay,deathDelay)
	elseif id==29 then
		castTime=zombieDecay(hero,castDelay,deathDelay)
	elseif id==30 then
		castTime=titanStomp(hero,castDelay,deathDelay)
	elseif id==31 then
		castTime=clockRocket(hero,castDelay,deathDelay)
	elseif id==32 then
		castTime=clockHook(hero,castDelay,deathDelay,1)
	elseif id==33 then
		castTime=clockHook(hero,castDelay,deathDelay,2)
	elseif id==34 then
		castTime=clockHook(hero,castDelay,deathDelay,3)
	elseif id==35 then
		castTime=wrPowershot(hero,castDelay,deathDelay)
	elseif id==36 then
		castTime=huskarUlt(hero,castDelay,deathDelay)
	elseif id==37 then
		castTime=gyroMissle(hero,castDelay,deathDelay)
	elseif id==38 then
		castTime=tinyToss(hero,castDelay,deathDelay)
	elseif id==39 then
		castTime=phoenixNova(hero,castDelay,deathDelay)
	elseif id==40 then
		castTime=lcFirstskill(hero,castDelay,deathDelay)
	elseif id==41 then
		castTime=magnusRp(hero,castDelay,deathDelay)
	elseif id==42 then
		castTime=slardarStun(hero,castDelay,deathDelay)
	elseif id==43 then
		castTime=axeAgro(hero,castDelay,deathDelay)
	elseif id==44 then
		castTime=brewClap(hero,castDelay,deathDelay)
	elseif id==45 then
		castTime=centStun(hero,castDelay,deathDelay)
	elseif id==46 then
		castTime=lionUlt(hero,castDelay,deathDelay+1.5)
	elseif id==47 then
		castTime=qopScream(hero,castDelay,deathDelay)
	elseif id==48 then
		castTime=monkeyTreeJump(hero,castDelay,deathDelay)
	elseif id==49 then
		castTime=familiarStun(hero,castDelay,deathDelay)
	elseif id==50 then
		castTime=neutralUrsaClap(hero,castDelay,deathDelay)
	elseif id==51 then
		castTime=forestCentStun(hero,castDelay,deathDelay)
	elseif id==52 then
		castTime=ProwlerStun(hero,castDelay,deathDelay)
	elseif id==53 then
		castTime=odAstral(hero,castDelay,deathDelay)
	elseif id==54 then
		castTime=roshanClap(hero,castDelay,deathDelay)
	elseif id==55 then
		castTime=medusaUlt(hero,castDelay,deathDelay+1,2)
	elseif id==56 then
		castTime=medusaUlt(hero,castDelay,deathDelay+1,3)
	elseif id==57 then
		castTime=invokerSunStrike(hero,castDelay,deathDelay)
	elseif id==58 then
		castTime=kunkkaTorrent(hero,castDelay,deathDelay)
	elseif id==59 then
		castTime=kunkkaTidebringer(hero,castDelay,deathDelay)
	elseif id==60 then
		castTime=elderUlt(hero,castDelay,deathDelay)
	elseif id==61 then
		castTime=leshracStun(hero,castDelay,deathDelay)
	elseif id==62 then
		castTime=warlockGolem(hero,castDelay,deathDelay)
	elseif id==63 then
		castTime=pangoSlam(hero,castDelay,deathDelay)
	elseif id==64 then
		castTime=willowFear(hero,castDelay,deathDelay)
	elseif id==65 then
		castTime=rikiMemeHammer(hero,castDelay,deathDelay)
	elseif id==66 then
		castTime=rikiMemeHammerInv(hero,castDelay,deathDelay)
	elseif id==67 then
		castTime=nil
	end

	return castTime
end
function checkSkillshotHitSpirits(pos,radius)
	local target={}
	local spirits
	if INV_SINGLE_TARGET==1 then
		spirits={inv_storm}
	else
		spirits={inv_earth,inv_fire,inv_storm}
	end
	for k,spirit in pairs(spirits) do
		local length=spirit:GetAbsOrigin()-pos
		local range=length:Length()
		if range<radius then
			table.insert(target,spirit)
		end
	end
	return target
end
function checkSunstrikeHit(pos)
	local targets=FindUnitsInRadius(DOTA_TEAM_GOODGUYS, pos, nil, 175, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local aim_time
	local score
	local index_found
	if #targets>0 then
		for k,v in pairs(targets) do
			
			for k1,v1 in pairs(WARD_POOL) do
	          if v1[1]==v:entindex() then
	            index_found=k1

	            break
	          end
	        end
	        aim_time=WARD_POOL[index_found][2]
	        table.remove(WARD_POOL,index_found)
	        AIM_COMBO=AIM_COMBO+1
	        if AIM_COMBO>AIM_MAX_COMBO then
	          AIM_MAX_COMBO=AIM_COMBO
	        end
	        score=math.ceil(500/(Time()-aim_time))*AIM_COMBO
	        --calc avg
	        table.insert(RESULTS_TABLE,Time()-aim_time)
	        local avg_time=0
	        for k,v in pairs(RESULTS_TABLE) do
	          avg_time=avg_time+v
	        end

	        avg_time=avg_time/#RESULTS_TABLE
	        AIM_AVG_TIME=avg_time
	        AIM_SCORE=AIM_SCORE+score
	        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=Time()-aim_time,score=score,avg=avg_time,totalscore=AIM_SCORE,combo=AIM_COMBO})
        	EmitGlobalSound("frog")
			v:RemoveSelf()
		end
		CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good! T:'..tostring(math.floor((Time()-aim_time)*1000)/1000)..' S:'..score,icon='invoker_sun_strike'})
	else
		EmitGlobalSound('sproing')
        AIM_COMBO=1
        CustomGameEventManager:Send_ServerToAllClients("reaction_clicked",{time=0,score='Bad!',totalscore=AIM_SCORE,combo=AIM_COMBO,badx=pos.x,bady=pos.y})
		CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Miss!',icon='invoker_sun_strike'})
	end
--[[	local target={}
	local spirits
	if INV_SINGLE_TARGET==1 then
		spirits={inv_storm}
	else
		spirits={inv_earth,inv_fire,inv_storm}
	end
	for k,spirit in pairs(spirits) do
		local length=spirit:GetAbsOrigin()-pos
		local range=length:Length()
		if range<radius then
			table.insert(target,spirit)
		end
	end
	return target--]]
end
function removeFormInvokeContainer(spirit)
	if spirit==inv_earth then
		table.remove(INV_E_QUE,1)
	end
	if spirit==inv_fire then
		table.remove(INV_F_QUE,1)
	end
	if spirit==inv_storm then
		table.remove(INV_S_QUE,1)
	end
end
function getRandomInvokeSkill()
	local skill_generated=0
	local excludes={}
	local skill
	if INV_BASIC_MODE==1 then
		local gavno=hero:GetAbilityByIndex(3)
	    local pizda=hero:GetAbilityByIndex(4)
	    table.insert(excludes,gavno:GetAbilityName())
	    table.insert(excludes,pizda:GetAbilityName())
	end
	if INV_ONE_SPHERE==1 then
		if #INV_SPHERE_CONTAINER<3 then
			skill=INV_SKILLS[RandomInt(1,10)][1]
		else
			local search_spheres={INV_SPHERE_CONTAINER[2],INV_SPHERE_CONTAINER[3]}
--[[			print("searching:")
			print(search_spheres[1])
			print(search_spheres[2])--]]
			local gavno=hero:GetAbilityByIndex(3)
			local pizda=hero:GetAbilityByIndex(4)
			local skills_found={}
			for key,invokeSkill in pairs(INV_SKILLS) do
				local matches=0
				if search_spheres[1]~=search_spheres[2] then
					for key3,search in pairs(search_spheres) do
						local sphere_matches=0
						for key2,sphere in pairs(invokeSkill[2]) do      
							if search==sphere then
								sphere_matches=sphere_matches+1
							end
						end
						if sphere_matches>0 then
							matches=matches+1
						end
					end
				else
					for key2,sphere in pairs(invokeSkill[2]) do      
						if search_spheres[1]==sphere then
							matches=matches+1
						end
						if matches==3 then
							matches=2
						end
					end
				end
				if matches==2 then
					if invokeSkill[1]~=gavno:GetAbilityName() and invokeSkill[1]~=pizda:GetAbilityName() then
						table.insert(skills_found,invokeSkill[1])
--[[						print("found: ",invokeSkill[1])--]]
					end
				end
			end
			skill=skills_found[RandomInt(1,#skills_found)]
		end
		
	else
		if #INV_E_QUE>0 then
			table.insert(excludes,INV_E_QUE[#INV_E_QUE])
		end
		if #INV_F_QUE>0 then
			table.insert(excludes,INV_F_QUE[#INV_F_QUE])
		end
		if #INV_S_QUE>0 then
			table.insert(excludes,INV_S_QUE[#INV_S_QUE])
		end
		while skill_generated==0 do
			skill=INV_SKILLS[RandomInt(1,10)][1]
			local matches_found=0
			for k,v in pairs(excludes) do
				if skill==v then
					matches_found=1
				end
			end
			if matches_found~=1 then
				skill_generated=1
			end
		end
	end
	
	return skill
end
function checkInvokeContainers(skill)
  local result={}
  if INV_E_QUE[1]==skill then
    table.insert(result,inv_earth)
  end
  if INV_F_QUE[1]==skill then
    table.insert(result,inv_fire)
  end
  if INV_S_QUE[1]==skill then
    table.insert(result,inv_storm)
  end
  return result
end
function checkSpiritsForModifier(modifier_name)
	local result={}
	if INV_SINGLE_TARGET~=1 then
		if inv_earth:FindModifierByName(modifier_name) then
			table.insert(result,inv_earth)
		end
		if inv_fire:FindModifierByName(modifier_name) then
			table.insert(result,inv_fire)
		end
	end
	if inv_storm:FindModifierByName(modifier_name) then
		table.insert(result,inv_storm)
	end
  return result
end
function convertSpiritToJSRow(spirit)
  local row
  if spirit==inv_earth then
    row=0
  end
  if spirit==inv_fire then
    row=1
  end
  if spirit==inv_storm then
    row=2
  end
  return row
end
function invClearLine(spirits)
	local shit={0,1,2}
	for k,v in pairs(spirits) do
		if v==inv_earth then
			table.remove(shit,1)
		end
		if v==inv_fire then
			table.remove(shit,2)
		end
		if v==inv_storm then
			table.remove(shit,3)
		end
	end
	for k,v in pairs(shit) do
		if v==0 then
			removeFormInvokeContainer(inv_earth)
		end
		if v==1 then
			removeFormInvokeContainer(inv_fire)
		end
		if v==2 then
			removeFormInvokeContainer(inv_storm)
		end
		CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='remove',row=v})
	end


end
function invChallangeSKill()
		local skill_id=RandomInt(1,10)
		local skill_name=INV_SKILLS[skill_id][1]
		local targets={}
		if skill_name=="ivoker_emp" then
			local emp_rnd=RandomInt(1,3)
			if emp_rnd==3 then
				targets={1,2,3}

			end
			if emp_rnd==2 then
				local first=RandomInt(1,3)
				local second=first
				while second==first do
					second=RandomInt(1,3)
				end
				table.insert(targets,first)
				table.insert(targets,second)
			end
			if emp_rnd==1 then
				local target=RandomInt(1,3)
				targets={target}
			end
			
		elseif skill_name=="invoker_ghost_walk" or skill_name=="invoker_ice_wall" then
			local emp_rnd=RandomInt(1,2)
			if emp_rnd==2 then
				local first=RandomInt(1,3)
				local second=first
				while second==first do
					second=RandomInt(1,3)
				end
				table.insert(targets,first)
				table.insert(targets,second)
			end
			if emp_rnd==1 then
				local target=RandomInt(1,3)
				targets={target}
			end
		else
			local target=RandomInt(1,3)
			targets={target}
		end
		print("######")
		print("skillname:",skill_name)
		for k,v in pairs(targets) do
			print(k,v)
			
		end
		print("######")
		local e_skill=0
		local f_skill=0
		local s_skill=0
		for k,v in pairs(targets) do
			if v==1 then
				e_skill=1
			end
			if v==2 then
				f_skill=1
			end
			if v==3 then
				s_skill=1
			end
		end
		if e_skill==1 then
			table.insert(INV_E_QUE,skill_name)
			CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=skill_name,row=0})
		else
			table.insert(INV_E_QUE,INV_FILLER)
			CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=INV_FILLER,row=0})
		end
		if f_skill==1 then
			table.insert(INV_F_QUE,skill_name)
			CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=skill_name,row=1})
		else
			table.insert(INV_F_QUE,INV_FILLER)
			CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=INV_FILLER,row=1})
		end
		if s_skill==1 then
			table.insert(INV_S_QUE,skill_name)
			CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=skill_name,row=2})
		else
			table.insert(INV_S_QUE,INV_FILLER)
			CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=INV_FILLER,row=2})
		end




end

function invPUshSkill(roww)
	local inv_row
	if roww==nil then
		if INV_SINGLE_TARGET==1 then
			inv_row=3
		else
			inv_row=RandomInt(1,3)
		end
	else
		inv_row=roww
	end
    local inv_push_skill=getRandomInvokeSkill()
    --local inv_push_skill="invoker_emp"
    if inv_row==1 then
      table.insert(INV_E_QUE,inv_push_skill)
    elseif inv_row==2 then
      table.insert(INV_F_QUE,inv_push_skill)
    elseif inv_row==3 then
      table.insert(INV_S_QUE,inv_push_skill)
    else
      print("wut")
    end
    
    CustomGameEventManager:Send_ServerToAllClients("invok_push",{request='push',skill=inv_push_skill,row=inv_row-1})
end

function isPointInSquare(minVec,maxVec,point)
	local bResult
	if point.x>=minVec.x and point.x<=maxVec.x and point.y<=maxVec.y and point.y>=minVec.y then
		bResult=true
	else
		bResult=false
	end
	return bResult
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

function RemakeTargetsRadius()
	for k,v in pairs(SS_TARGET_MOVE_RADIUS) do
		if v>SS_MAXRANGE or v<SS_MINRANGE then
			local new_range=RandomInt(SS_MINRANGE/50,SS_MAXRANGE/50)
			SS_TARGET_MOVE_RADIUS[k]=new_range*50
		end

	end
end


function RemakeTargetsSpeed()
	for k,v in pairs(SS_MOVE_SPEED) do
		if v>SS_MAXSPEED or v<SS_MINSPEED then
			local new_range=RandomInt(SS_MINSPEED/50,SS_MAXSPEED/50)
			SS_MOVE_SPEED[k]=new_range*50
			SS_TARGETS[k]:SetBaseMoveSpeed(SS_MOVE_SPEED[k])
			
		end

	end
end

function RemakeTarget(target)
	local target_name=target:GetUnitName()
	local target_index=target:entindex()
--[[	SS_TARGETS[target_index]:RemoveSelf()
	SS_TARGETS[target_index]=nil
	SS_TARGET_MOVE_RADIUS[target_index]=nil
	SS_MOVE_DIR[target_index]=nil
	SS_MOVE_SPEED[target_index]=nil


	ssAddUnitNew(target_name,RandomInt(SS_MINRANGE,SS_MAXRANGE),RandomInt(SS_MINSPEED,SS_MAXSPEED),target_index)--]]

	SS_TARGET_MOVE_RADIUS[target_index]=RandomInt(SS_MINRANGE,SS_MAXRANGE)
	SS_MOVE_DIR[target_index]=nil
	SS_MOVE_SPEED[target_index]=RandomInt(SS_MINSPEED,SS_MAXSPEED)
	SS_TARGETS[target_index]:SetBaseMoveSpeed(SS_MOVE_SPEED[target_index])
	local direction_seed=RandomInt(-100,100)
    local direction
    if direction_seed<0 then
      direction=-1
    else
      direction=1
    end
    SS_MOVE_DIR[target_index]=direction
    healHero(SS_TARGETS[target_index])
    Timers:CreateTimer({
	    endTime = FrameTime(),
	    callback = function()
	      SS_TARGETS[target_index]:Purge(false,true,false,true,false)
	    end
	  })
    
--[[    if SS_TARGETS[target_index]:FindModifierByName("modifier_stunned") then
    	print(Time(),'trying to remove stun')
    	SS_TARGETS[target_index]:RemoveModifierByName("modifier_stunned")
    end--]]
--[[    ParticleManager:CreateParticle("particles/econ/events/ti4/blink_dagger_start_ti4.vpcf", PATTACH_ABSORIGIN, SS_TARGETS[target_index])
--]]    local new_pos=randomCirclePositionVector(SS_TARGET_MOVE_RADIUS[target_index],Vector(0,0,128))
    SS_TARGETS[target_index]:SetAbsOrigin(new_pos)
    --[[local unit_pos=targetUnit:GetAbsOrigin()--]]
    local move_dir=(Vector(0,0,128)-new_pos):Normalized()
    if direction>0 then
      new_dir=Vector(move_dir.y,-move_dir.x,0)
    else
      new_dir=Vector(-move_dir.y,move_dir.x,0)
    end
    SS_TARGETS[target_index]:SetForwardVector(new_dir)
--[[    ParticleManager:CreateParticle("particles/econ/events/ti4/blink_dagger_end_ti4.vpcf", PATTACH_ABSORIGIN, SS_TARGETS[target_index])
--]]end

function addLvlChanger(ability)
	local ab_index=ability:entindex()
	 CustomGameEventManager:Send_ServerToAllClients("create_lvl_changer",{index=ab_index})
end

function ssMiranaMove(target_index,debug)
	--if hero:FindModifierByName("modifier_mirana_leap") then
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local color4=Vector(255,255,0)
	local color5=Vector(0,0,0)
	local ztest=true
	local targetUnit=SS_TARGETS[target_index]
	local leap=targetUnit:FindAbilityByName('mirana_leap')
    local leapLvl=4
    leap:SetLevel(leapLvl)
    local leap_distance={550,550,550,550}
    local leap_move_point=nil
    local move_point_leap_dir
    local direction
    local unit_pos
    local move_dir
    local move_dir_radius
    local new_dir
    local rotateAngle
	Timers:CreateTimer("ai_thinker_for_target_"..target_index, {
      useGameTime = false,
      endTime = 0.05,
      callback = function()
        if targetUnit:IsNull()==false then
        	if targetUnit:FindModifierByName("modifier_mirana_leap") then
        		leap_move_point=nil
        	end
	       	if leap_move_point==nil then
				direction=SS_MOVE_DIR[target_index]
				unit_pos=targetUnit:GetAbsOrigin()
				move_dir=(Vector(0,0,128)-unit_pos):Normalized()
				move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
				if direction>0 then
					new_dir=Vector(move_dir.y,-move_dir.x,0)
				else
					new_dir=Vector(-move_dir.y,move_dir.x,0)
				end

				leap_move_point=move_dir_radius+new_dir*leap_distance[leapLvl]
				rotateAngle=(90-(180-math.deg(math.asin((leap_distance[leapLvl]/2)/SS_TARGET_MOVE_RADIUS[target_index]))*2)/2)*direction

				leap_move_point=RotatePosition(move_dir_radius,QAngle(0,rotateAngle,0),leap_move_point)
				move_point_leap_dir=(leap_move_point-move_dir_radius):Normalized()
			end
				local target_to_point_dir=(leap_move_point-targetUnit:GetAbsOrigin()):Normalized()
				local angle_between_vectors=RotationDelta(VectorToAngles(targetUnit:GetForwardVector()), VectorToAngles(target_to_point_dir)).y
				--[[print('angle between vectors:',angle_between_vectors)--]]
				local angle_eps=1
			if angle_between_vectors>angle_eps or angle_between_vectors<-angle_eps then
				targetUnit:SetContextThink(DoUniqueString("move_order_"..target_index),
				function()
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
						OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
						Position = leap_move_point
					})
				end,
				0) 
			else
				targetUnit:SetContextThink(DoUniqueString("cast_ability_"..target_index),
				function()
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = leap:entindex()
					})
				end,
				0) 
			end
			if debug==true then
				--DebugDrawCircle(Vector(0,0,128), color3, 20, SS_TARGET_MOVE_RADIUS[target_index], ztest, 0.05)
				--DebugDrawCircle(leap_move_point, color1, 20, 20, ztest, 0.05)
				local lenght=Vector(0,0,128)-unit_pos
				local radius_now=lenght:Length()
				--DebugDrawText(unit_pos+Vector(100,0,0), tostring(radius_now), true, 0.05)
			end
			return 0.05
		else
			return nil
		end
	end
    })
end

function ssPhoenixMove(target_index,debug)
	--if hero:FindModifierByName("modifier_mirana_leap") then
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local color4=Vector(255,255,0)
	local color5=Vector(0,0,0)
	local ztest=true
	local targetUnit=SS_TARGETS[target_index]
	local dive=targetUnit:FindAbilityByName('phoenix_icarus_dive')
    dive:SetLevel(1)
    local dive_stop=targetUnit:FindAbilityByName('phoenix_icarus_dive_stop')
    local dive_distance=1400
    local dive_move_point=nil
    local move_point_dive_dir
    local direction
    local unit_pos
    local move_dir
    local move_dir_radius
    local new_dir
    local rotateAngle
    local dive_casted=0
    local dive_dur_counter=0
    local fake_mod
    local fly_dur
	local fly_rnd
	local anti_afk=0
	local last_pos=nil
	Timers:CreateTimer("ai_thinker_for_target_"..target_index, {
      useGameTime = false,
      endTime = 0.05,
      callback = function()
        if targetUnit:IsNull()==false then
        	if last_pos~=nil then
        		if targetUnit:GetAbsOrigin()==last_pos then
        			anti_afk=anti_afk+0.05
        			if anti_afk>0.5 then
        				dive_move_point=nil
        				dive_casted=0
        			end
        		else
        			anti_afk=0
        		end
        	end
        	if targetUnit:FindModifierByName("modifier_phoenix_icarus_dive") then
        		--print('dive_dur_counter:',dive_dur_counter)
        		if dive_dur_counter>=fly_dur then
        			--print('i should stop')
					dive_move_point=nil
					targetUnit:SetContextThink(DoUniqueString("cast_ability2_"..target_index),
					function()
						ExecuteOrderFromTable({
							UnitIndex = targetUnit:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = dive_stop:entindex()
						})
					end,
					0) 
					dive_casted=0
        		end
        		dive_dur_counter=dive_dur_counter+0.05
        	end
	       	if dive_move_point==nil then
				direction=SS_MOVE_DIR[target_index]
				unit_pos=targetUnit:GetAbsOrigin()
				move_dir=(Vector(0,0,128)-unit_pos):Normalized()
				move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
				if direction>0 then
					new_dir=Vector(move_dir.y,-move_dir.x,0)
				else
					new_dir=Vector(-move_dir.y,move_dir.x,0)
				end

				dive_move_point=move_dir_radius+new_dir*dive_distance
				rotateAngle=(90-(180-math.deg(math.asin((dive_distance/2)/SS_TARGET_MOVE_RADIUS[target_index]))*2)/2)*direction

				dive_move_point=RotatePosition(move_dir_radius,QAngle(0,rotateAngle,0),dive_move_point)
				move_point_dive_dir=(dive_move_point-move_dir_radius):Normalized()
			end
			if dive_casted==0 then
        		fly_rnd=RandomInt(0,100)
        		if fly_rnd>30 then
        			fly_dur=0.95
        		else
        			fly_dur=1.90
        		end
				targetUnit:SetContextThink(DoUniqueString("cast_ability_"..target_index),
				function()
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = dive_move_point,
						AbilityIndex = dive:entindex()
					})
				end,
				0) 
				dive_casted=1
				dive_dur_counter=0
			end

			if debug==true then
				--DebugDrawCircle(Vector(0,0,128), color3, 20, SS_TARGET_MOVE_RADIUS[target_index], ztest, 0.05)
				--DebugDrawCircle(dive_move_point, color1, 20, 20, ztest, 0.05)
				local lenght=Vector(0,0,128)-unit_pos
				local radius_now=lenght:Length()
				--DebugDrawText(unit_pos+Vector(100,0,0), tostring(radius_now), true, 0.05)
			end
			last_pos=targetUnit:GetAbsOrigin()
			return 0.05
		else
			return nil
		end
	end
    })
end

function ssEsMove(target_index,debug)
	--if hero:FindModifierByName("modifier_mirana_leap") then
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local color4=Vector(255,255,0)
	local color5=Vector(0,0,0)
	local ztest=true
	local targetUnit=SS_TARGETS[target_index]
	local stone=targetUnit:FindAbilityByName('earth_spirit_stone_caller')
    stone:SetLevel(1)
    local roll=targetUnit:FindAbilityByName('earth_spirit_rolling_boulder')
    roll:SetLevel(1)
    local roll_distance={800,1600}
    local roll_move_point=nil
    local move_point_roll_dir
    local direction
    local unit_pos
    local move_dir
    local move_dir_radius
    local new_dir
    local rotateAngle
    local roll_casted=0
    local roll_dur_counter=0
    local fake_mod
    local stone_dur
	local stone_rnd
	local stone_casted=0
	local last_pos=nil
	local anti_afk=0
	Timers:CreateTimer("ai_thinker_for_target_"..target_index, {
      useGameTime = false,
      endTime = 0.05,
      callback = function()
        if targetUnit:IsNull()==false then
        	if last_pos~=nil then
        		if targetUnit:GetAbsOrigin()==last_pos then
        			anti_afk=anti_afk+0.05
        			if anti_afk>0.5 then
        				roll_move_point=nil
        				roll_casted=0
        			end
        		else
        			anti_afk=0
        		end
        	end
        	if roll_casted==1 then
        		if not targetUnit:FindModifierByName("modifier_earth_spirit_rolling_boulder_caster") and roll_dur_counter>=1 then
        			roll_move_point=nil
        			roll_casted=0
        		end
        		if targetUnit:FindModifierByName("modifier_earth_spirit_rolling_boulder_caster") then
        			if stone_dur==2 and roll_dur_counter>=0.4 and stone_casted==0 then
        				--print('placing stone')
        				local stone_pos=targetUnit:GetAbsOrigin()+move_point_roll_dir*80
        				targetUnit:SetContextThink(DoUniqueString("cast_ability"),
			            function()
			              ExecuteOrderFromTable({
			                UnitIndex = targetUnit:entindex(),
			                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			                Position = stone_pos,
			                AbilityIndex = stone:entindex()
			              })
			            end,
			            0)
			            stone_casted=1
        			end
        			roll_dur_counter=roll_dur_counter+0.05
        		end
        	end
	       	if roll_move_point==nil then
	       		--print('roll point calculating')
	       		stone_rnd=RandomInt(0,100)
        		if stone_rnd>20 then
        			stone_dur=1
        		else
        			stone_dur=2
        			stone_casted=0
        		end
				direction=SS_MOVE_DIR[target_index]
				unit_pos=targetUnit:GetAbsOrigin()
				move_dir=(Vector(0,0,128)-unit_pos):Normalized()
				move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
				if direction>0 then
					new_dir=Vector(move_dir.y,-move_dir.x,0)
				else
					new_dir=Vector(-move_dir.y,move_dir.x,0)
				end

				roll_move_point=move_dir_radius+new_dir*roll_distance[stone_dur]
				rotateAngle=(90-(180-math.deg(math.asin((roll_distance[stone_dur]/2)/SS_TARGET_MOVE_RADIUS[target_index]))*2)/2)*direction

				roll_move_point=RotatePosition(move_dir_radius,QAngle(0,rotateAngle,0),roll_move_point)
				move_point_roll_dir=(roll_move_point-move_dir_radius):Normalized()
			end
			if roll_casted==0 then
				--print('try to cast roll')
        		if not targetUnit:IsRooted() then
        			--print('unit not rooted')
					targetUnit:SetContextThink(DoUniqueString("cast_ability_"..target_index),
					function()
						ExecuteOrderFromTable({
							UnitIndex = targetUnit:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = roll_move_point,
							AbilityIndex = roll:entindex()
						})
					end,
					0) 
					roll_casted=1
					roll_dur_counter=0
				end
				
			end

			if debug==true then
				--DebugDrawCircle(Vector(0,0,128), color3, 20, SS_TARGET_MOVE_RADIUS[target_index], ztest, 0.05)
				--DebugDrawCircle(roll_move_point, color1, 20, 20, ztest, 0.05)
				local lenght=Vector(0,0,128)-unit_pos
				local radius_now=lenght:Length()
				--DebugDrawText(unit_pos+Vector(100,0,0), tostring(radius_now), true, 0.05)
			end
			last_pos=targetUnit:GetAbsOrigin()
			return 0.05
		else
			return nil
		end
	end
    })
end

function ssJuggerMove(target_index,debug)
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local ztest=true
	local targetUnit=SS_TARGETS[target_index]
	local direction
	local unit_pos
	local move_dir
	local move_dir_radius
	local new_dir
	local move_point
	targetUnit:AddNewModifier(targetUnit, nil, "modifier_phased", {})
	if SS_SKILLS[SS_SKILL_ID]=="furion_sprout" then
		targetUnit:AddNewModifier(targetUnit, nil, "modifier_black_king_bar_immune", {})
		Timers:CreateTimer(function()
			if not targetUnit:IsNull() then
				local trees=GridNav:GetAllTreesAroundPoint(targetUnit:GetAbsOrigin(),160,true)
				if #trees==8 then
					RemakeTarget(targetUnit)
					CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text='Good!',icon='furion_sprout'})
					GridNav:DestroyTreesAroundPoint(targetUnit:GetAbsOrigin(), 400, true)
					--GOOD
				else
					if #trees>0 then
						RemakeTarget(targetUnit)
						CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text='Bad!',icon='furion_sprout'})
						GridNav:DestroyTreesAroundPoint(targetUnit:GetAbsOrigin(), 400, true)
					end
					
				end
				
				return 0.5
			else
				return nil
			end
		end
		)
	end
	local roll=targetUnit:FindAbilityByName('juggernaut_blade_fury')
    roll:SetLevel(1)
	Timers:CreateTimer("ai_thinker_for_target_"..target_index, {
      useGameTime = false,
      endTime = 0.05,
      callback = function()
        if targetUnit:IsNull()==false then
          direction=SS_MOVE_DIR[target_index]
          unit_pos=targetUnit:GetAbsOrigin()
          move_dir=(Vector(0,0,128)-unit_pos):Normalized()
          move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
          if direction>0 then
            new_dir=Vector(move_dir.y,-move_dir.x,0)
          else
            new_dir=Vector(-move_dir.y,move_dir.x,0)
          end
          move_point=move_dir_radius+new_dir*300
          if debug==true then
	          --DebugDrawCircle(Vector(0,0,128), color3, 20, SS_TARGET_MOVE_RADIUS[target_index], ztest, 0.05)
	          --DebugDrawCircle(move_point, color1, 20, 20, ztest, 0.05)
	          --DebugDrawCircle(move_dir_radius, color2, 20, 20, ztest, 0.05)
	          local lenght=Vector(0,0,128)-unit_pos
	          local radius_now=lenght:Length()
	          --[[print('isIdle?',targetUnit:IsIdle())--]]
	          --[[print('radius_now:',radius_now)--]]
	          --[[targetUnit:MoveToPosition(move_point)--]]
	      end
          targetUnit:SetContextThink(DoUniqueString("move_order_"..target_index),
          function()
            ExecuteOrderFromTable({
              UnitIndex = targetUnit:entindex(),
              OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
              Position = move_point
            })
          end,
          0) 
          return 0.05
        else
          return nil
        end

      end
    })
end

function ssQopBlinking(target_index,debug)
	--if hero:FindModifierByName("modifier_mirana_leap") then
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local color4=Vector(255,255,0)
	local color5=Vector(0,0,0)
	local ztest=true
	local targetUnit=SS_TARGETS[target_index]
	local blink=targetUnit:FindAbilityByName('queenofpain_blink')
    blink:SetLevel(1)
    local blink_distance=1300
    local blink_move_point=nil
    local move_point_blink_dir
    local direction
    local unit_pos
    local move_dir
    local move_dir_radius
    local new_dir
    local rotateAngle
    local blink_casted=0
    local blink_dur_counter=0
    local fake_mod
	Timers:CreateTimer("ai_thinker_for_target_"..target_index, {
      useGameTime = false,
      endTime = 0.05,
      callback = function()
        if targetUnit:IsNull()==false then

        	if blink_move_point~=nil and blink_casted==1 then
        		local lenght=blink_move_point-targetUnit:GetAbsOrigin()
				local radius_now=lenght:Length()
				if radius_now<=blink_distance-100 then
	        		blink_casted=0
	        		blink_move_point=nil
	        	end
        	end
	       	if blink_move_point==nil then
				direction=SS_MOVE_DIR[target_index]
				unit_pos=targetUnit:GetAbsOrigin()
				move_dir=(Vector(0,0,128)-unit_pos):Normalized()
				move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
				if direction>0 then
					new_dir=Vector(move_dir.y,-move_dir.x,0)
				else
					new_dir=Vector(-move_dir.y,move_dir.x,0)
				end

				blink_move_point=move_dir_radius+new_dir*blink_distance
				rotateAngle=(90-(180-math.deg(math.asin((blink_distance/2)/SS_TARGET_MOVE_RADIUS[target_index]))*2)/2)*direction

				blink_move_point=RotatePosition(move_dir_radius,QAngle(0,rotateAngle,0),blink_move_point)
				blink_move_point=Vector(blink_move_point.x,blink_move_point.y,128)
				move_point_blink_dir=(blink_move_point-move_dir_radius):Normalized()
			end
			if blink_casted==0 then
				targetUnit:SetContextThink(DoUniqueString("cast_ability_"..target_index),
				function()
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = blink_move_point,
						AbilityIndex = blink:entindex()
					})
				end,
				0) 
				blink_casted=1
				blink_dur_counter=0
			end

			if debug==true then
				--DebugDrawCircle(Vector(0,0,128), color3, 20, SS_TARGET_MOVE_RADIUS[target_index], ztest, 0.05)
				--DebugDrawCircle(blink_move_point, color1, 20, 20, ztest, 0.05)
				local lenght=Vector(0,0,128)-unit_pos
				local radius_now=lenght:Length()
				--DebugDrawText(unit_pos+Vector(100,0,0), tostring(radius_now), true, 0.05)
				local lenght2=targetUnit:GetAbsOrigin()-blink_move_point
				local radius_now2=lenght2:Length()
				print('targetUnit:GetAbsOrigin()',targetUnit:GetAbsOrigin())
				print('blink_move_point',blink_move_point)
				print('lenght:',radius_now2)
			end
			return 0.05
		else
			return nil
		end
	end
    })
end

function ssAmBlinking(target_index,debug)
	--if hero:FindModifierByName("modifier_mirana_leap") then
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local color4=Vector(255,255,0)
	local color5=Vector(0,0,0)
	local ztest=true
	local targetUnit=SS_TARGETS[target_index]
	local blink=targetUnit:FindAbilityByName('antimage_blink')
	local blinklvl=4
    blink:SetLevel(blinklvl)
    local blink_distance={925, 1000, 1075, 1150}
    local blink_move_point=nil
    local move_point_blink_dir
    local direction
    local unit_pos
    local move_dir
    local move_dir_radius
    local new_dir
    local rotateAngle
    local blink_casted=0
    local blink_dur_counter=0
    local fake_mod
	Timers:CreateTimer("ai_thinker_for_target_"..target_index, {
      useGameTime = false,
      endTime = 0.05,
      callback = function()
        if targetUnit:IsNull()==false then

        	if blink_move_point~=nil and blink_casted==1 then
        		local lenght=blink_move_point-targetUnit:GetAbsOrigin()
				local radius_now=lenght:Length()
				if radius_now<=blink_distance[blinklvl]-100 then
	        		blink_casted=0
	        		blink_move_point=nil
	        	end
        	end
	       	if blink_move_point==nil then
				direction=SS_MOVE_DIR[target_index]
				unit_pos=targetUnit:GetAbsOrigin()
				move_dir=(Vector(0,0,128)-unit_pos):Normalized()
				move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
				if direction>0 then
					new_dir=Vector(move_dir.y,-move_dir.x,0)
				else
					new_dir=Vector(-move_dir.y,move_dir.x,0)
				end

				blink_move_point=move_dir_radius+new_dir*blink_distance[blinklvl]
				rotateAngle=(90-(180-math.deg(math.asin((blink_distance[blinklvl]/2)/SS_TARGET_MOVE_RADIUS[target_index]))*2)/2)*direction

				blink_move_point=RotatePosition(move_dir_radius,QAngle(0,rotateAngle,0),blink_move_point)
				blink_move_point=Vector(blink_move_point.x,blink_move_point.y,128)
				move_point_blink_dir=(blink_move_point-move_dir_radius):Normalized()
			end
			if blink_casted==0 then
				targetUnit:SetContextThink(DoUniqueString("cast_ability_"..target_index),
				function()
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = blink_move_point,
						AbilityIndex = blink:entindex()
					})
				end,
				0) 
				blink_casted=1
				blink_dur_counter=0
			end

			if debug==true then
				--DebugDrawCircle(Vector(0,0,128), color3, 20, SS_TARGET_MOVE_RADIUS[target_index], ztest, 0.05)
				--DebugDrawCircle(blink_move_point, color1, 20, 20, ztest, 0.05)
				local lenght=Vector(0,0,128)-unit_pos
				local radius_now=lenght:Length()
				--DebugDrawText(unit_pos+Vector(100,0,0), tostring(radius_now), true, 0.05)
				local lenght2=targetUnit:GetAbsOrigin()-blink_move_point
				local radius_now2=lenght2:Length()
				print('targetUnit:GetAbsOrigin()',targetUnit:GetAbsOrigin())
				print('blink_move_point',blink_move_point)
				print('lenght:',radius_now2)
			end
			return 0.05
		else
			return nil
		end
	end
    })
end

MANTA_PRECACHE={{"npc_dota_hero_invoker","unit"},
				{"npc_dota_hero_tiny","unit"},
				{"npc_dota_hero_riki","unit"},
				{"npc_dota_hero_shredder","unit"},
				{"npc_dota_hero_pangolier","unit"},
				{"npc_dota_hero_dark_willow","unit"},
				{"npc_dota_hero_spirit_breaker","unit"},
				{"npc_dota_hero_sand_king","unit"},
				{"npc_dota_hero_death_prophet","unit"},
				{"npc_dota_hero_chaos_knight","unit"},
				{"npc_dota_hero_naga_siren","unit"},
				{"npc_dota_hero_phantom_lancer","unit"},
				{"npc_dota_hero_nyx_assassin","unit"},
				{"npc_dota_hero_puck","unit"},
				{"npc_dota_hero_kunkka","unit"},
				{"npc_dota_hero_lina","unit"},
				{"npc_dota_hero_bloodseeker","unit"},
				{"npc_dota_hero_pugna","unit"},
				{"npc_dota_hero_meepo","unit"},
				{"npc_dota_hero_necrolyte","unit"},
				{"npc_dota_hero_mirana","unit"},
				{"npc_dota_hero_nevermore","unit"},
				{"npc_dota_hero_zuus","unit"},
				{"npc_dota_hero_tidehunter","unit"},
				{"npc_dota_hero_ursa","unit"},
				{"npc_dota_hero_omniknight","unit"},
				{"npc_dota_hero_alchemist","unit"},
				{"npc_dota_hero_skywrath_mage","unit"},
				{"npc_dota_hero_shadow_demon","unit"},
				{"npc_dota_hero_earthshaker","unit"},
				{"npc_dota_hero_obsidian_destroyer","unit"},
				{"npc_dota_hero_undying","unit"},
				{"npc_dota_hero_elder_titan","unit"},
				{"npc_dota_hero_rattletrap","unit"},
				{"npc_dota_hero_windrunner","unit"},
				{"npc_dota_hero_gyrocopter","unit"},
				{"npc_dota_hero_wisp","unit"},
				{"npc_dota_hero_phoenix","unit"},
				{"npc_dota_hero_legion_commander","unit"},
				{"npc_dota_hero_magnataur","unit"},
				{"npc_dota_hero_slardar","unit"},
				{"npc_dota_hero_axe","unit"},
				{"npc_dota_hero_brewmaster","unit"},
				{"npc_dota_hero_centaur","unit"},
				{"npc_dota_hero_lion","unit"},
				{"npc_dota_hero_queenofpain","unit"},
				{"npc_dota_visage_familiar1","unit"},
				{"npc_dota_neutral_polar_furbolg_ursa_warrior","unit"},
				{"npc_dota_neutral_centaur_khan","unit"},
				{"npc_dota_mk_fix","unit"},
				{"npc_dota_hero_techies","unit"},
				{"npc_dota_neutral_prowler_shaman","unit"},
				{"npc_dota_roshan","unit"},
				{"npc_dota_hero_leshrac","unit"},
				{"npc_dota_hero_warlock","unit"},
				{"npc_dota_hero_skeleton_king","unit"},
				{"npc_dota_creep_badguys_melee","unit"},
				{"npc_dota_goodguys_tower1_mid","unit"},
				{"npc_dota_creep_goodguys_melee","unit"},
				{"npc_dota_hero_disruptor","unit"},
				{"npc_dota_observer_wards","unit"},
				{"npc_dota_hero_earth_spirit","unit"},
				{"npc_dota_hero_ember_spirit","unit"},
				{"npc_dota_hero_storm_spirit","unit"},
				{"npc_dota_hero_antimage","unit"},
				{"npc_dota_hero_juggernaut","unit"},
				{"item_manta","item"},
				{"item_cyclone","item"},
				{"item_aegis","item"}}
--

function precacheTable(table)
	local counter=1
	function precacheIter(ind)
		print("loading",table[ind][1])
		CustomGameEventManager:Send_ServerToAllClients("loading_progress",{total=#table,current=ind})
		if ind==#table then
			if table[ind][2]=="unit" then
				PrecacheUnitByNameAsync(table[ind][1],function() print("loading done!") end)
			else
				PrecacheItemByNameAsync(table[ind][1], function() print("loading done!") end)
			end
		else
			if table[ind][2]=="unit" then
				PrecacheUnitByNameAsync(table[ind][1],function() precacheIter(ind+1) end)
			else
				PrecacheItemByNameAsync(table[ind][1], function() precacheIter(ind+1) end)
			end
			
		end
	end
	precacheIter(1)

end

PRECACHED_LIST={}
SKIP_LIST={}

function precache_v2(jsArgs)

	---dodging precache
	DODGE_SECONDARY={
	"npc_dota_hero_lina",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_lina",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_pugna",
	"npc_dota_hero_meepo",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_mirana",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_zuus",
	"npc_dota_hero_zuus",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_ursa",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_medusa",
	"npc_dota_hero_medusa",
	"npc_dota_hero_techies",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_invoker",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_undying",
	"npc_dota_hero_elder_titan",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_huskar",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_tiny",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_slardar",
	"npc_dota_hero_axe",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_centaur",
	"npc_dota_hero_lion",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_visage",
	"npc_dota_neutral_polar_furbolg_ursa_warrior",
	"npc_dota_neutral_centaur_khan",
	"npc_dota_neutral_prowler_shaman",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_roshan",
	"npc_dota_hero_medusa",
	"npc_dota_hero_medusa",
	"npc_dota_hero_invoker",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_elder_titan",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_warlock",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_dark_willow",
	"npc_dota_hero_riki",
	"npc_dota_hero_riki"
	}



--[[	PL_TIMING_SECONDARY={"npc_dota_hero_naga_siren",
                           "npc_dota_hero_axe",
                          "npc_dota_hero_centaur",
                          "npc_dota_hero_earth_spirit",
                           "npc_dota_hero_earthshaker",
                           "npc_dota_hero_earthshaker",
                           "npc_dota_hero_earthshaker",
                           "npc_dota_hero_earthshaker",
                          "npc_dota_hero_elder_titan",
                           "npc_dota_hero_ember_spirit",
                          "npc_dota_hero_gyrocopter",
                          "npc_dota_hero_kunkka",
                          "npc_dota_hero_kunkka",
                          "npc_dota_hero_kunkka",
                          "npc_dota_hero_magnataur",
                          "npc_dota_hero_magnataur",
                           "npc_dota_hero_pudge",
                           "npc_dota_hero_sand_king",
                          "npc_dota_hero_slardar",
                           "npc_dota_hero_spirit_breaker",
                           "npc_dota_hero_tidehunter",
                           "npc_dota_hero_tusk",
                          "npc_dota_hero_bloodseeker",
                          "npc_dota_hero_lone_druid",
                          "npc_dota_hero_meepo",
                          "npc_dota_hero_mirana",
                          "npc_dota_hero_monkey_king",
                           "npc_dota_hero_nyx_assassin",
                          "npc_dota_hero_pangolier",
                           "npc_dota_hero_nevermore",
                           "npc_dota_hero_nevermore",
                           "npc_dota_hero_nevermore",
                           "npc_dota_hero_nevermore",
                          "npc_dota_hero_ancient_apparition",
                          "npc_dota_hero_ancient_apparition",
                          "npc_dota_hero_dark_seer",
                          "npc_dota_hero_dark_willow",
                           "npc_dota_hero_death_prophet",
                           "npc_dota_hero_invoker",
                          "npc_dota_hero_invoker",
                          "npc_dota_hero_invoker",
                           "npc_dota_hero_leshrac",
                           "npc_dota_hero_lina",
                           "npc_dota_hero_lion",
                          "npc_dota_hero_puck",
                          "npc_dota_hero_pugna",
                          "npc_dota_hero_visage",
                           "npc_dota_hero_warlock",
                          "npc_dota_hero_windrunner"
                          }
	PL_TIMING_PRIMARY={
	                    "npc_dota_hero_shadow_demon",
	                    "npc_dota_hero_shadow_demon",
	                    "npc_dota_hero_obsidian_destroyer",
	                    "npc_dota_hero_antimage",
	                    "npc_dota_hero_skeleton_king",
	                    "npc_dota_hero_storm_spirit",
	                    "npc_dota_hero_naga_siren",
	                    "npc_dota_hero_disruptor",
	                    "npc_dota_hero_kunkka",
	                    "npc_dota_hero_brewmaster"
	                  }--]]


  PL_TIMING_SECONDARY={"npc_dota_hero_kunkka",--id=1
              "npc_dota_hero_nevermore",--id=2
              "npc_dota_hero_invoker",--id=3
              "npc_dota_hero_elder_titan",--id=4
              "npc_dota_hero_techies",--id=5
              "npc_dota_hero_death_prophet",--id=6
              "npc_dota_hero_lina",--id=7
              "npc_dota_hero_earthshaker",--id=8
              "npc_dota_hero_earthshaker",--id=9
              "npc_dota_hero_leshrac",--id=10
              "npc_dota_hero_slardar",--id=11
              "npc_dota_hero_centaur",--id=12
              "npc_dota_hero_bloodseeker",--id=13
              "npc_dota_hero_earthshaker",--id=14 AGHS
              "npc_dota_hero_windrunner",
              "npc_dota_hero_lion",--id=15
              "npc_dota_hero_nyx_assassin",--id=16
              "npc_dota_hero_phoenix",--id=17
              "npc_dota_hero_pudge",--id=18
              "npc_dota_hero_earth_spirit",--id=19
              "npc_dota_hero_mirana",--id=20
              "npc_dota_hero_sand_king",--id=21
              "npc_dota_hero_spirit_breaker",--id=22
              "npc_dota_hero_spirit_breaker",--id=23 with talent
              "npc_dota_hero_sand_king",--id=24 with AGHS
              "npc_dota_hero_nyx_assassin",--id=25 AGHS
              "npc_dota_hero_earthshaker",
              "npc_dota_hero_riki"
            }

      PL_TIMING_PRIMARY={nil,--id=1
              "npc_dota_hero_shadow_demon",--id=2
              "npc_dota_hero_obsidian_destroyer",--id=3
              "npc_dota_hero_tiny",--id=4
              "npc_dota_hero_skeleton_king",--id=5--id=6
     		  "npc_dota_goodguys_tower1_mid"
            }


	PL_GLIMPSE_TYPE={"npc_dota_hero_antimage",
	            "npc_dota_hero_phantom_lancer",
	            "npc_dota_hero_naga_siren",
	            "npc_dota_hero_ember_spirit",
	            "npc_dota_hero_chaos_knight",
	            "npc_dota_hero_sand_king",
	            "npc_dota_hero_shredder"
	            }

	SS_ENEMIES_v2={"npc_dota_hero_nevermore",
				"npc_dota_hero_earthshaker",
				"npc_dota_hero_windrunner",
				"npc_dota_hero_tusk",
				"npc_dota_hero_meepo",
				"npc_dota_hero_riki"
	}
	SS_HEROES={"npc_dota_hero_rattletrap",--id=1
				"npc_dota_hero_earth_spirit",--id=2
				"npc_dota_hero_ember_spirit",--id=3
				"npc_dota_hero_invoker",--id=4
				"npc_dota_hero_meepo",--id=5
				"npc_dota_hero_mirana",--id=6
				"npc_dota_hero_nyx_assassin",--id=7
				"npc_dota_hero_pudge",--id=8
				"npc_dota_hero_puck",--id=9
				"npc_dota_hero_phoenix",--id=10
				"npc_dota_hero_nevermore",--id=11
				"npc_dota_hero_windrunner",
				"npc_dota_hero_windrunner",
				"npc_dota_hero_wisp",
				"npc_dota_hero_ancient_apparition",
				"npc_dota_hero_furion",
				"npc_dota_hero_invoker",
				"npc_dota_hero_leshrac",
				"npc_dota_hero_kunkka",
				"npc_dota_hero_mars"
	}

	SS_ENEMIES={"npc_dota_hero_antimage",
				"npc_dota_hero_juggernaut",
				"npc_dota_hero_phoenix",
				"npc_dota_hero_earth_spirit",
				"npc_dota_hero_mirana",
				"npc_dota_hero_queenofpain"}

  MORPH_HERO_LIST={"npc_dota_hero_abaddon",
                    "npc_dota_hero_abyssal_underlord",
                    "npc_dota_hero_alchemist",
                    "npc_dota_hero_ancient_apparition",
                    "npc_dota_hero_antimage",
                    "npc_dota_hero_arc_warden",
                    "npc_dota_hero_axe",
                    "npc_dota_hero_bane",
                    "npc_dota_hero_batrider",
                    "npc_dota_hero_beastmaster",
                    "npc_dota_hero_bloodseeker",
                    "npc_dota_hero_bounty_hunter",
                    "npc_dota_hero_brewmaster",
                    "npc_dota_hero_bristleback",
                    "npc_dota_hero_broodmother",
                    "npc_dota_hero_centaur",
                    "npc_dota_hero_chaos_knight",
                    "npc_dota_hero_chen",
                    "npc_dota_hero_clinkz",
                    "npc_dota_hero_crystal_maiden",
                    "npc_dota_hero_dark_seer",
                    "npc_dota_hero_dark_willow",
                    "npc_dota_hero_dazzle",
                    "npc_dota_hero_death_prophet",
                    "npc_dota_hero_disruptor",
                    "npc_dota_hero_doom_bringer",
                    "npc_dota_hero_dragon_knight",
                    "npc_dota_hero_drow_ranger",
                    "npc_dota_hero_earth_spirit",
                    "npc_dota_hero_earthshaker",
                    "npc_dota_hero_elder_titan",
                    "npc_dota_hero_ember_spirit",
                    "npc_dota_hero_enchantress",
                    "npc_dota_hero_enigma",
                    "npc_dota_hero_faceless_void",
                    "npc_dota_hero_furion",
                    "npc_dota_hero_grimstroke",
                    "npc_dota_hero_gyrocopter",
                    "npc_dota_hero_huskar",
                    --[["npc_dota_hero_invoker",--]]
                    "npc_dota_hero_jakiro",
                    "npc_dota_hero_juggernaut",
                    "npc_dota_hero_keeper_of_the_light",
                    "npc_dota_hero_kunkka",
                    "npc_dota_hero_legion_commander",
                    "npc_dota_hero_leshrac",
                    "npc_dota_hero_lich",
                    "npc_dota_hero_life_stealer",
                    "npc_dota_hero_lina",
                    "npc_dota_hero_lion",
                    "npc_dota_hero_lone_druid",
                    "npc_dota_hero_luna",
                    "npc_dota_hero_lycan",
                    "npc_dota_hero_magnataur",
                    "npc_dota_hero_marci",
                    "npc_dota_hero_mars",
                    "npc_dota_hero_medusa",
                    "npc_dota_hero_meepo",
                    "npc_dota_hero_mirana",
                    "npc_dota_hero_monkey_king",
                    --[["npc_dota_hero_morphling",--]]
                    "npc_dota_hero_naga_siren",
                    "npc_dota_hero_necrolyte",
                    "npc_dota_hero_nevermore",
                    "npc_dota_hero_night_stalker",
                    "npc_dota_hero_nyx_assassin",
                    "npc_dota_hero_obsidian_destroyer",
                    "npc_dota_hero_ogre_magi",
                    "npc_dota_hero_omniknight",
                    "npc_dota_hero_oracle",
                    "npc_dota_hero_pangolier",
                    "npc_dota_hero_phantom_assassin",
                    "npc_dota_hero_phantom_lancer",
                    "npc_dota_hero_phoenix",
                    "npc_dota_hero_primal_beast",
                    "npc_dota_hero_puck",
                    "npc_dota_hero_pudge",
                    "npc_dota_hero_pugna",
                    "npc_dota_hero_queenofpain",
                    "npc_dota_hero_rattletrap",
                    "npc_dota_hero_razor",
                    "npc_dota_hero_riki",
                    "npc_dota_hero_rubick",
                    "npc_dota_hero_sand_king",
                    "npc_dota_hero_shadow_demon",
                    "npc_dota_hero_shadow_shaman",
                    "npc_dota_hero_shredder",
                    "npc_dota_hero_silencer",
                    "npc_dota_hero_skeleton_king",
                    "npc_dota_hero_skywrath_mage",
                    "npc_dota_hero_slardar",
                    "npc_dota_hero_slark",
                    "npc_dota_hero_snapfire",
                    "npc_dota_hero_sniper",
                    "npc_dota_hero_spectre",
                    "npc_dota_hero_spirit_breaker",
                    "npc_dota_hero_storm_spirit",
                    "npc_dota_hero_sven",
                    "npc_dota_hero_techies",
                    "npc_dota_hero_templar_assassin",
                    "npc_dota_hero_terrorblade",
                    "npc_dota_hero_tidehunter",
                    "npc_dota_hero_tinker",
                    "npc_dota_hero_tiny",
                    "npc_dota_hero_treant",
                    "npc_dota_hero_troll_warlord",
                    "npc_dota_hero_tusk",
                    "npc_dota_hero_undying",
                    "npc_dota_hero_ursa",
                    "npc_dota_hero_vengefulspirit",
                    "npc_dota_hero_venomancer",
                    "npc_dota_hero_viper",
                    "npc_dota_hero_visage",
                    "npc_dota_hero_void_spirit",
                    "npc_dota_hero_warlock",
                    "npc_dota_hero_weaver",
                    "npc_dota_hero_windrunner",
                    "npc_dota_hero_winter_wyvern",
                    "npc_dota_hero_wisp",
                    "npc_dota_hero_witch_doctor",
                    "npc_dota_hero_zuus",
                		"npc_dota_hero_hoodwink",
                    "npc_dota_hero_dawnbreaker",}


	DeepPrintTable(jsArgs)
	for k,v in pairs(jsArgs) do
		print('training name:',k)
		if k=="custom_manta_training_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_antimage")
			for kk,vv in pairs(v['skills']) do
				print('need to precache:',DODGE_SECONDARY[vv])
				
				addToPrecacheTable(PRECACHED_LIST,DODGE_SECONDARY[vv])
			end
		end
		if k=="euls_training" then
			addToPrecacheTable(PRECACHED_LIST,PL_TIMING_SECONDARY[v['skillId']])
			addToPrecacheTable(PRECACHED_LIST,PL_TIMING_PRIMARY[v['timingType']+1])
		end

		if k=="old_timing_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_tiny")
			addToPrecacheTable(PRECACHED_LIST,PL_TIMING_SECONDARY[v['skillId']])
			addToPrecacheTable(PRECACHED_LIST,PL_TIMING_PRIMARY[v['timingType']+1])

		end
		if k=="start_glimpse" then
			addToPrecacheTable(PRECACHED_LIST,PL_TIMING_SECONDARY[v['skillId']])
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_disruptor")
		end
		if k=="armlet_training_start" then
			addToPrecacheTable(PRECACHED_LIST,v['unitName'])
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_life_stealer")
			
		end
		if k=="invoker_invoke_training" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_invoker")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_storm_spirit")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_ember_spirit")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_earth_spirit")
		end
		if k=="invoker_procast_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_invoker")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_tiny")
		end
		if k=="alche_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_alchemist")
		end
		if k=="kunnka_training_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_kunkka")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_tiny")
		end
		if k=="deam_coil_escape" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_puck")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_antimage")
		end
		if k=="lasthit_start" then
			addToPrecacheTable(PRECACHED_LIST,v['hero'])
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_sniper")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_axe")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_badguys_tower1_mid")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_goodguys_tower1_mid")
		end
		if k=="aim_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_pangolier")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_observer_wards")
		end
		if k=="aim_start2" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_pangolier")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_observer_wards")
		end
		if k=="aim_start3" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_pangolier")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_observer_wards")
		end
		if k=="map_aim_start" then
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_hero_pangolier")
			addToPrecacheTable(PRECACHED_LIST,"npc_dota_creep_badguys_melee")
		end
		if k=="morph_training_start" then
			for k,v in pairs(MORPH_HERO_LIST) do
				addToPrecacheTable(PRECACHED_LIST,v)
			end
		end
		if k=="skillshot_training_v2" then
			for k,v in pairs(SS_ENEMIES_v2) do
				addToPrecacheTable(PRECACHED_LIST,v)
			end
			addToPrecacheTable(PRECACHED_LIST,SS_HEROES[v['skill_id']])
		end
		if k=="skillshot_training" then
			for k,v in pairs(SS_ENEMIES) do
				addToPrecacheTable(PRECACHED_LIST,v)
			end
			addToPrecacheTable(PRECACHED_LIST,SS_HEROES[v['skill_id']])
			
		end
	end
	precacheTable_v2(PRECACHED_LIST,jsArgs)
end

function addToPrecacheTable(tPrecacheTable,tPrecacheEntity)
	--[[local type
	print(string.sub(tPrecacheEntity,1,3))--]]
	local matchfound=0
	for k,v in pairs(tPrecacheTable) do
		if tPrecacheEntity==v then
			matchfound=1
		end
	end
	for k,v in pairs(SKIP_LIST) do
		if tPrecacheEntity==v then
			matchfound=1
		end
	end
	if matchfound==0 then
		print('added to table:',tPrecacheEntity)
		table.insert(tPrecacheTable,tPrecacheEntity)
	end

end

function precacheTable_v2(tPrecacheTable,jsArgs)
	local counter=1
	function precacheIter(ind)
		table.insert(SKIP_LIST,tPrecacheTable[ind])
		CustomGameEventManager:Send_ServerToAllClients("loading_progress",{total=#tPrecacheTable,current=ind,name=tPrecacheTable[ind]})
		if ind==#tPrecacheTable then
			print("loading",tPrecacheTable[ind])
			
			PrecacheUnitByNameAsync(tPrecacheTable[ind],function() loadingDone(jsArgs) end)
			
		else
			print("loading",tPrecacheTable[ind])
			
			PrecacheUnitByNameAsync(tPrecacheTable[ind],function() precacheIter(ind+1) end)		
		end

	end
	print("loading table len:",#tPrecacheTable)
	if #tPrecacheTable>0 then
		precacheIter(1)
	else
		loadingDone(jsArgs)
	end

end

function loadingDone(callbackArgs)
	print("loading done!")
	CustomGameEventManager:Send_ServerToAllClients("loading_done",{callback_args=callbackArgs})
	PRECACHED_LIST={}

end

function inokeDebug(containers,targets)
	print('###Containers:###')
	for k,v in pairs(containers) do
		print(k,v)
	end
	print('###Targets:###')
	for k,v in pairs(targets) do
		print(k,v)
	end

end

function invokeSpellCasted()
	--current time, spheres per cast, cast time
	local info={Time(),INV_SPHERES_COUNTER}
	table.insert(INV_SPHERES_BENCHMARK,info)
	INV_SPHERES_COUNTER=0
	if #INV_SPHERES_BENCHMARK>1 then
		while INV_SPHERES_BENCHMARK[1][1]<(Time()-60) do
			table.remove(INV_SPHERES_BENCHMARK,1)
		end
		local SPS=0
		for k,v in pairs(INV_SPHERES_BENCHMARK) do
			SPS=SPS+v[2]
		end
		SPS=SPS/#INV_SPHERES_BENCHMARK
		local totalTime=INV_SPHERES_BENCHMARK[#INV_SPHERES_BENCHMARK][1]-INV_SPHERES_BENCHMARK[1][1]
		local ACT=totalTime/(#INV_SPHERES_BENCHMARK-1)
		local SPM=(#INV_SPHERES_BENCHMARK*60)/totalTime
		CustomGameEventManager:Send_ServerToAllClients("invoke_benchmark",{skillsMin=SPM,skillsAvg=ACT,sphersPerSkill=SPS})
	end
	
end

function generateSkillSchedule(enemyTable)
	local startTime=3
	local endTime=MANTA_END_INTERVAL
	local decTime=0.03
	local maxValue=100
	local resultTable={}
	for i=1,maxValue/5 do
		local mocha={1,2,3,4,5}
		shake(mocha)
		if i>1 then
			print('ids:',(i-1)*5,(i-1)*5+1)
			print('before',MANTA_ENEMY_TABLE[resultTable[(i-1)*5][1]][1],MANTA_ENEMY_TABLE[mocha[5]][1])
			if resultTable[(i-1)*5][1]==mocha[5] then
				swap(mocha,1,5)
				print('after',MANTA_ENEMY_TABLE[resultTable[(i-1)*5][1]][1],MANTA_ENEMY_TABLE[mocha[5]][1])
			end
		end
		for j=5,1,-1 do
			local time=startTime-decTime*(i*5-j)

			if time<endTime then
				time=endTime+RandomFloat(-0.3,0.3)
			end
			resultTable[i*5-j+1]={mocha[j],time}
		end
	end
	print('total schedule:')
	for k,v in pairs(resultTable) do
		print(k,MANTA_ENEMY_TABLE[v[1]][1],v[2])
	end
	return resultTable
end
function notargetMantaEnemyAI(hero,unit_name,ability_name,ability_radius,respawnDistance)
  local color1=Vector(255,0,0)
  local color2=Vector(0,0,255)
  local color3=Vector(255,0,255)
  local color4=Vector(255,255,0)
  local color5=Vector(0,0,0)
  local ztest=true
  local respawn_place=randomCirclePositionVector(respawnDistance,Vector(0,0,128))
  local unit=CreateUnitByName(unit_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)
  unit:SetAttackCapability(0)
  unit:SetBaseManaRegen(100)
  unit:SetBaseIntellect(100)
  local ability = unit:FindAbilityByName(ability_name)
  ability:SetLevel(1)
  local blink_dagger=CreateItem("item_blink",unit,unit)
  unit:AddItem(blink_dagger)
  unit:SetForwardVector((hero:GetAbsOrigin() - respawn_place):Normalized())
  local k=1
  Timers:CreateTimer(personalSchedule[unit_name][k], function()
      ability:EndCooldown()
      blink_dagger:EndCooldown()
      --[[if ability_name=="axe_berserkers_call" then
        hero:RemoveModifierByName("modifier_axe_berserkers_call")
      end--]]

      local unitDir=(hero:GetOrigin() - unit:GetOrigin()):Normalized()
      unit:SetForwardVector(unitDir)
      local lenght=hero:GetAbsOrigin()-unit:GetAbsOrigin()
      local distanceToHero=lenght:Length()
      local blinkPoint=unit:GetAbsOrigin()+(unitDir*(distanceToHero-RandomInt(-50,50)))
      local blinkOutPoint=unit:GetAbsOrigin()+unitDir*(respawnDistance*2)
      local ability_casted=0
      local blink_in=0
      local blink_out=0

      local blink_time=0
      Timers:CreateTimer(0, function()
          --DebugDrawCircle(blinkPoint, color3, 20, 20, ztest, FrameTime())
          --DebugDrawText(blinkPoint, 'blinkPoint', true, FrameTime())
          --DebugDrawCircle(blinkOutPoint, color1, 20, 20, ztest, FrameTime())
          --DebugDrawText(blinkOutPoint, 'blinkOutPoint', true, FrameTime())
          --blink in
          if blink_dagger:IsCooldownReady()==true and ability_casted==0 and blink_in==0 then
          	unit:SetContextThink(DoUniqueString("cast_blink_in_"..unit_name),
				function()
					unit:CastAbilityOnPosition(blinkPoint,blink_dagger,-1)
				end,
				0) 
            --unit:CastAbilityOnPosition(blinkPoint,blink_dagger,-1)
            blink_in=1
          end
          --use ability
          if blink_dagger:IsCooldownReady()==false and ability:IsInAbilityPhase()==false and blink_in==1 and ability:IsCooldownReady()==true then
            unit:SetContextThink(DoUniqueString("cast_skill_"..unit_name),
				function()
					unit:CastAbilityNoTarget(ability,-1)
				end,
				0) 
            --unit:CastAbilityNoTarget(ability,-1)
            print('trying to cast:',ability_name,Time()-MANTA_CAST_TIME)
            MANTA_CAST_TIME=Time()
            blink_dagger:EndCooldown()
            ability_casted=1
--[[            blink_time=Time()+wait_time--]]
          end
          --waiting



          --blink out
          if ability:IsCooldownReady()==false and blink_in==1 and ability_casted==1 and blink_out==0 then
            unit:SetContextThink(DoUniqueString("cast_blink_out_"..unit_name),
				function()
					unit:CastAbilityOnPosition(blinkOutPoint,blink_dagger,-1)
				end,
				0) 
            --unit:CastAbilityOnPosition(blinkOutPoint,blink_dagger,-1)
            blink_out=1
          end
          if blink_in==1 and ability_casted==1 and blink_out==1 then
            return nil
          else
            return FrameTime()
          end
        end
      )
      --unit:SetAbsOrigin(randomCirclePositionVector(respawnDistance,Vector(0,0,128)))
      	k=k+1
		if k>table.getn(personalSchedule[unit_name]) then
			return nil
		else
			return personalSchedule[unit_name][k]
		end
    end
  )

end


function positionMantaEnemyAI(hero,unit_name,ability_name,ability_radius,respawnDistance)
  local color1=Vector(255,0,0)
  local color2=Vector(0,0,255)
  local color3=Vector(255,0,255)
  local color4=Vector(255,255,0)
  local color5=Vector(0,0,0)
  local ztest=true
  local respawn_place=randomCirclePositionVector(respawnDistance,Vector(0,0,128))
  local unit=CreateUnitByName(unit_name, respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS)
  unit:SetAttackCapability(0)
  unit:SetBaseManaRegen(100)
  unit:SetBaseIntellect(100)
  local ability
  if ability_name=="invoker_emp" then
	local invoke_name="invoker_invoke"
	local wex_name="invoker_wex"
	local invoke = unit:FindAbilityByName(invoke_name)
	invoke:SetLevel(1)
	local wex=unit:FindAbilityByName(wex_name)
	wex:SetLevel(3)
	unit:CastAbilityNoTarget(wex,-1)
	unit:CastAbilityNoTarget(wex,-1)
	unit:CastAbilityNoTarget(wex,-1)
	unit:CastAbilityNoTarget(invoke,-1)
	ability=unit:FindAbilityByName("invoker_emp")
  else
  	ability = unit:FindAbilityByName(ability_name)
  	ability:SetLevel(1)
  end
  
  local blink_dagger=CreateItem("item_blink",unit,unit)
  unit:AddItem(blink_dagger)
  unit:SetForwardVector((hero:GetAbsOrigin() - respawn_place):Normalized())
  local k=1
  Timers:CreateTimer(personalSchedule[unit_name][k], function()
      ability:EndCooldown()
      blink_dagger:EndCooldown()
      --[[if ability_name=="axe_berserkers_call" then
        hero:RemoveModifierByName("modifier_axe_berserkers_call")
      end--]]

      
      local unitDir=(hero:GetOrigin() - unit:GetOrigin()):Normalized()
      unit:SetForwardVector(unitDir)
      local lenght=hero:GetAbsOrigin()-unit:GetAbsOrigin()
      local distanceToHero=lenght:Length()
      local blinkPoint=unit:GetAbsOrigin()+(unitDir*(distanceToHero-RandomInt(200,250)))
      local castPosition=hero:GetAbsOrigin()+(unitDir*(RandomInt(-200,200)))
      local blinkOutPoint=unit:GetAbsOrigin()+unitDir*(respawnDistance*2+400)
      local ability_casted=0
      local blink_in=0
      local blink_out=0
      local wait_time=1.5
      Timers:CreateTimer(0, function()
          --DebugDrawCircle(blinkPoint, color3, 20, 20, ztest, FrameTime())
          --DebugDrawText(blinkPoint, 'blinkPoint', true, FrameTime())
          --DebugDrawCircle(blinkOutPoint, color1, 20, 20, ztest, FrameTime())
          --DebugDrawText(blinkOutPoint, 'blinkOutPoint', true, FrameTime())
          --blink in
          if blink_dagger:IsCooldownReady()==true and ability_casted==0 and blink_in==0 then
          	unit:SetContextThink(DoUniqueString("cast_blink_in_"..unit_name),
				function()
					unit:CastAbilityOnPosition(blinkPoint,blink_dagger,-1)
				end,
				0) 
            --unit:CastAbilityOnPosition(blinkPoint,blink_dagger,-1)
            blink_in=1
          end
          --use ability
          if blink_dagger:IsCooldownReady()==false and ability:IsInAbilityPhase()==false and blink_in==1 and ability:IsCooldownReady()==true then
            unit:SetContextThink(DoUniqueString("cast_ability_"..unit_name),
				function()
					unit:CastAbilityOnPosition(castPosition,ability,-1)
				end,
				0) 
            --unit:CastAbilityOnPosition(castPosition,ability,-1)
            print('trying to cast:',ability_name,Time()-MANTA_CAST_TIME)
            MANTA_CAST_TIME=Time()
            blink_dagger:EndCooldown()
            ability_casted=1
          end
          --blink out
          if ability:IsCooldownReady()==false and blink_in==1 and ability_casted==1 and blink_out==0 then
            unit:SetContextThink(DoUniqueString("cast_blink_out_"..unit_name),
				function()
					unit:CastAbilityOnPosition(blinkOutPoint,blink_dagger,-1)
				end,
				0.75) 
            --unit:CastAbilityOnPosition(blinkOutPoint,blink_dagger,-1)
            blink_out=1
          end
          if blink_in==1 and ability_casted==1 and blink_out==1 then
            return nil
          else
            return FrameTime()
          end
        end
      )
      --unit:SetAbsOrigin(randomCirclePositionVector(respawnDistance,Vector(0,0,128)))
      	k=k+1
		if k>table.getn(personalSchedule[unit_name]) then
			return nil
		else
			return personalSchedule[unit_name][k]
		end
    end
  )

end
function createSFCrosshair(hero)
	--debug
	--[[local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local ztest=true
	local radius=250
	local l1=200
	local l2=450
	local l3=700
	Timers:CreateTimer(function()
		local point1=hero:GetAbsOrigin()+(hero:GetForwardVector()*l1)
		local point2=hero:GetAbsOrigin()+(hero:GetForwardVector()*l2)
		local point3=hero:GetAbsOrigin()+(hero:GetForwardVector()*l3)
		--DebugDrawCircle(point1, color1, 20, radius, ztest, 0.05)
		--DebugDrawCircle(point2, color1, 20, radius, ztest, 0.05)
		--DebugDrawCircle(point3, color1, 20, radius, ztest, 0.05)
		return 0.05
	end
	)--]]
	hero:SetAbsOrigin(Vector(0,0,128))
	hero:SetForwardVector(Vector(1,0,0):Normalized())
	cs1 = ParticleManager:CreateParticle("particles/sf_crosshair1.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	cs2 = ParticleManager:CreateParticle("particles/sf_crosshair2.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	cs3 = ParticleManager:CreateParticle("particles/sf_crosshair3.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
end
function removeSFCrosshair()
	ParticleManager:DestroyParticle(cs1, true)
    ParticleManager:ReleaseParticleIndex(cs1)
    ParticleManager:DestroyParticle(cs2, true)
    ParticleManager:ReleaseParticleIndex(cs2)
    ParticleManager:DestroyParticle(cs3, true)
    ParticleManager:ReleaseParticleIndex(cs3)

end

lh_middle_point=Vector(-498.22644042969,-296.97790527344,128)
lh_radiant_spawn=lh_middle_point+Vector(-1,-1,0)*1200
lh_dire_spawn=lh_middle_point+Vector(1,1,0)*1200
lh_dire_tower_spawn=lh_middle_point+Vector(1,1,0)*1000
lh_radiant_tower_spawn=lh_middle_point+Vector(-1,-1,0)*1000
function sendRadiantMidCreepwave()
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local ztest=true
	-- for i, v in ipairs(hero_pos_table) do 
	-- 
	--local radiant_mid_respawn=Vector(-5008, -4488, 352)
	local radiant_mid_respawn=lh_radiant_spawn
	local radiant_mid_waypoints={lh_dire_spawn
								--Vector(-4856, -4376, 320),
	                          --Vector(-3104, -2736, 320),
	                          --Vector(-976, -824, 256),
	                          --Vector(-360, -256, 160),
	                          --Vector(176, 120, 256),
	                          --Vector(912, 624, 320),
	                          --Vector(2384, 1888, 320),
	                          --Vector(4472, 3944, 352),
	                          --Vector(5323, 4788, 384)}
	                        }
	local radiant_mid_creep1=CreateUnitByName("npc_dota_creep_goodguys_melee", radiant_mid_respawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local radiant_mid_creep2=CreateUnitByName("npc_dota_creep_goodguys_melee", radiant_mid_respawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local radiant_mid_creep3=CreateUnitByName("npc_dota_creep_goodguys_melee", radiant_mid_respawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local radiant_mid_creep4=CreateUnitByName("npc_dota_creep_goodguys_ranged", radiant_mid_respawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local radiant_creepPack={radiant_mid_creep1,radiant_mid_creep2,radiant_mid_creep3,radiant_mid_creep4}
	for k,v in pairs(radiant_creepPack) do
		v:SetDeathXP(0)
		v:SetContextThink(DoUniqueString("creep_move_"..tostring(k)),
		function()
		  for i=1,1 do
		    ----DebugDrawCircle(radiant_mid_waypoints[i], color3, 20, 20, ztest, 10)
		    ----DebugDrawText(radiant_mid_waypoints[i], 'waypoint '..tostring(i), true, 20)
		    ExecuteOrderFromTable({
		      UnitIndex = v:entindex(),
		      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		      Position = radiant_mid_waypoints[i],
		      Queue = i-1
		    })
		  end
		end,
		0)
	end
end

function sendDireMidCreepwave()
	local color1=Vector(255,0,0)
	local color2=Vector(0,0,255)
	local color3=Vector(255,0,255)
	local ztest=true
	--local dire_mid_respawn=Vector(4096, 3584, 368)
	local dire_mid_respawn=lh_dire_spawn
	local dire_mid_waypoints={
							lh_radiant_spawn
								--Vector(2368, 1904, 320),
	                          --Vector(864, 672, 320),
	                          --Vector(144, 152, 256),
	                          --Vector(-392, -224, 160),
	                          --Vector(-1008, -760, 256),
	                          --Vector(-4872, -4360, 320),
	                          --Vector(-5527, -5024, 384)
	                      }
	local dire_mid_creep1=CreateUnitByName("npc_dota_creep_badguys_melee", dire_mid_respawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	local dire_mid_creep2=CreateUnitByName("npc_dota_creep_badguys_melee", dire_mid_respawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	local dire_mid_creep3=CreateUnitByName("npc_dota_creep_badguys_melee", dire_mid_respawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	local dire_mid_creep4=CreateUnitByName("npc_dota_creep_badguys_ranged", dire_mid_respawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	local dire_creepPack={dire_mid_creep1,dire_mid_creep2,dire_mid_creep3,dire_mid_creep4}
	for k,v in pairs(dire_creepPack) do
		v:SetDeathXP(0)
		v:SetContextThink(DoUniqueString("creep_move_"..tostring(k)),

		function()
		  for i=1,1 do
		    --DebugDrawCircle(dire_mid_waypoints[i], color2, 20, 20, ztest, 10)
		    --DebugDrawText(dire_mid_waypoints[i], 'waypoint '..tostring(i), true, 20)
		    ExecuteOrderFromTable({
		      UnitIndex = v:entindex(),
		      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		      Position = dire_mid_waypoints[i],
		      Queue = i-1
		    })
		  end
		end,
		0)
	end
end

function addLHCreepToTable(entCreep)
	local creep_found=0
	for k,v in pairs(LH_CREEPS) do
		if v[1]==entCreep then
			--print('creep already in table')
			creep_found=1
		end
	end
	if creep_found==0 then
		print('creep added')
		local tableshit={entCreep,Time()}
        table.insert(LH_CREEPS,tableshit)
	end
	
end

function getLHResult(entCreep)
	local creep_index=0
	local result_time=0
	for k,v in pairs(LH_CREEPS) do
		if v[1]==entCreep then
			print('creep found')
			creep_index=k
			result_time=Time()-v[2]
		end
	end
	table.remove(LH_CREEPS,creep_index)
	return result_time
end

function displayLHResult(result,victim)
	if result==1 then
		LH_GOOD_HITS=LH_GOOD_HITS+1
		--good
		local msg="Good!"
		local delay=getLHResult(victim)
		table.insert(LH_AVG_TIMES,delay)
		local displayDelay=math.floor(delay*1000)/1000
		if victim:GetTeam()==player_side then
			msg=msg..' Deny delay: '..displayDelay
		else
			msg=msg..' Lasthit delay: '..displayDelay
		end
		CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='green',text=msg,icon='pogchamp'})
		
	else
		LH_BAD_HITS=LH_BAD_HITS+1
		local delay=getLHResult(victim)
		local msg="Bad!"
		CustomGameEventManager:Send_ServerToAllClients("show_notification",{color='red',text=msg,icon='pepega'})
		--bad
	end
	local accuracy=math.floor(LH_GOOD_HITS/LH_BAD_HITS*100)
	local avg_delay=0
	for k,v in pairs(LH_AVG_TIMES) do
		avg_delay=avg_delay+v

	end
	avg_delay=avg_delay/#LH_AVG_TIMES
	local avg_delay_disp=math.floor(avg_delay*1000)/1000
	CustomGameEventManager:Send_ServerToAllClients("refresh_lasthit_values",{avg=avg_delay_disp, killed=LH_GOOD_HITS, missed=LH_BAD_HITS})

end



function getAbilityCastpoint(ability_name,unit)
	local castpoint=0
	local delay=0
	local formula=nil
	
	local kv_table
	if ability_name=="item_meteor_hammer" then
		local item = CreateItem("item_meteor_hammer",unit,unit)
    	kv_table=item:GetAbilityKeyValues()
    	local target_type=getTargetType(item)
		print("target_type",target_type)
    	--[[DeepPrintTable(kv_table)
    	print('AbilityChannelTime',tonumber(table['AbilityChannelTime']))
    	print('AbilitySpecial',table['AbilitySpecial']['10']['land_time'])--]]
    	delay=tonumber(kv_table['AbilityChannelTime'])+kv_table['AbilitySpecial']['10']['land_time']
    	--unit:AddItem(item)
	elseif ability_name=="item_cyclone" then
		local item = CreateItem(ability_name,unit,unit)
    	kv_table=item:GetAbilityKeyValues()
    	local target_type=getTargetType(item)
		print("target_type",target_type)
    	--DeepPrintTable(kv_table)
    	delay=kv_table['AbilitySpecial']['04']['cyclone_duration']
	elseif ability_name=="item_aegis" then
		local item = CreateItem(ability_name,unit,unit)
    	kv_table=item:GetAbilityKeyValues()
    	--DeepPrintTable(kv_table)
    	delay=kv_table['AbilitySpecial']['01']['reincarnate_time']
	elseif ability_name=="item_travel_boots" then
		local item = CreateItem(ability_name,unit,unit)
    	kv_table=item:GetAbilityKeyValues()
    	delay=tonumber(kv_table['AbilityChannelTime'])
    	--DeepPrintTable(kv_table)
	else
		unit:AddAbility(ability_name)
		local ability = unit:FindAbilityByName(ability_name)
		ability:SetLevel(1)
		if TIMING_RUBICK_MODE==1 then
			ability:SetStolen(true)
		end
		kv_table=ability:GetAbilityKeyValues()
		
		if ability_name=="shadow_demon_disruption" then
			castpoint=ability:GetCastPoint()
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			delay=parseQuadroValue(kv_table['AbilitySpecial']['01']['disruption_duration'],nil)
		elseif ability_name=="obsidian_destroyer_astral_imprisonment" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilityDuration'])
		elseif ability_name=="skeleton_king_reincarnation" then
			delay=parseQuadroValue(kv_table['AbilitySpecial']['01']['reincarnate_time'],nil)
		elseif ability_name=="naga_siren_song_of_the_siren" then
			
			delay=0.4
		elseif ability_name=="earthshaker_enchant_totem" then
			if TIMING_PRIMARY_SKILL_ID==7 then
				delay=tonumber(kv_table['AbilitySpecial']['04']['duration'])
			else
				castpoint=ability:GetCastPoint()
				--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			end
		elseif ability_name=="elder_titan_echo_stomp" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilityChannelTime'])
	
		elseif ability_name=="gyrocopter_call_down" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['01']['slow_duration_first'])	
		elseif ability_name=="kunkka_torrent" then
			castpoint=ability:GetCastPoint()
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			delay=parseQuadroValue(kv_table['AbilitySpecial']['05']['delay'],nil)
		elseif ability_name=="kunkka_ghostship" then
			if TIMING_PRIMARY_SKILL_ID==14 then
				castpoint=ability:GetCastPoint()
				--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
				formula={speed=tonumber(kv_table['AbilitySpecial']['08']['ghostship_speed_scepter']),width=tonumber(kv_table['AbilitySpecial']['09']['ghostship_width_scepter'])}

			else
				castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
				delay=3.077
			end
		elseif ability_name=="bloodseeker_blood_bath" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['04']['delay'])
		elseif ability_name=="pangolier_shield_crash" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['05']['jump_duration'])
		elseif ability_name=="ancient_apparition_cold_feet" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=parseQuadroValue(kv_table['AbilityDuration'],nil)
		elseif ability_name=="dark_willow_cursed_crown" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['01']['delay'])
		elseif ability_name=="invoker_emp" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['01']['delay'])
		elseif ability_name=="invoker_chaos_meteor" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['01']['land_time'])
		elseif ability_name=="invoker_sun_strike" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['01']['delay'])
		elseif ability_name=="leshrac_split_earth" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['01']['delay'])
		elseif ability_name=="lina_light_strike_array" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilitySpecial']['02']['light_strike_array_delay_time'])
		elseif ability_name=="pugna_nether_blast" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=parseQuadroValue(kv_table['AbilitySpecial']['02']['delay'],nil)
		elseif ability_name=="visage_summon_familiars" then
			unit:AddAbility("visage_summon_familiars_stone_form")
			local ability2 = unit:FindAbilityByName("visage_summon_familiars_stone_form")
			kv_table2=ability2:GetAbilityKeyValues()
			castpoint=parseQuadroValue(kv_table2['AbilityCastPoint'],nil)
			delay=tonumber(kv_table2['AbilitySpecial']['02']['stun_delay'])
		elseif ability_name=="warlock_rain_of_chaos" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			delay=tonumber(kv_table['AbilityModifierSupportValue'])
		elseif ability_name=="earth_spirit_boulder_smash" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['05']['speed']),width=tonumber(kv_table['AbilitySpecial']['01']['radius']),max_distance=tonumber(kv_table['AbilitySpecial']['07']['rock_distance'])}
		elseif ability_name=="magnataur_skewer" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['01']['skewer_speed']),width=tonumber(kv_table['AbilitySpecial']['04']['skewer_radius'])}
		elseif ability_name=="pudge_meat_hook" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['01']['hook_speed']),width=tonumber(kv_table['AbilitySpecial']['02']['hook_width'])}
		elseif ability_name=="sandking_burrowstrike" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['03']['burrow_speed']),width=tonumber(kv_table['AbilitySpecial']['01']['burrow_width'])}
		elseif ability_name=="spirit_breaker_charge_of_darkness" then
			unit:AddAbility("special_bonus_unique_spirit_breaker_2")
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			local ability2 = unit:FindAbilityByName("special_bonus_unique_spirit_breaker_2")
			kv_table2=ability2:GetAbilityKeyValues()
			formula={speed_talent=tonumber(kv_table2['AbilitySpecial']['01']['value']),speed=parseQuadroValue(kv_table['AbilitySpecial']['01']['movement_speed'],'all'),width=parseQuadroValue(kv_table['AbilitySpecial']['03']['bash_radius'],nil)}
		elseif ability_name=="tusk_snowball" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['02']['snowball_speed']),width=tonumber(kv_table['AbilitySpecial']['07']['snowball_radius'])}
		elseif ability_name=="mirana_arrow" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['01']['arrow_speed']),width=tonumber(kv_table['AbilitySpecial']['02']['arrow_width'])}
		elseif ability_name=="nyx_assassin_impale" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=parseQuadroValue(kv_table['AbilitySpecial']['04']['speed'],nil),width=parseQuadroValue(kv_table['AbilitySpecial']['01']['width'],nil)}
		elseif ability_name=="lion_impale" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=parseQuadroValue(kv_table['AbilitySpecial']['04']['speed'],nil),width=parseQuadroValue(kv_table['AbilitySpecial']['01']['width'],nil)}
		elseif ability_name=="windrunner_shackleshot" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['04']['arrow_speed']),width=0}
		elseif ability_name=="slark_pounce" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['02']['pounce_speed']),width=tonumber(kv_table['AbilitySpecial']['07']['leash_radius'])}
		elseif ability_name=="tidehunter_ravage" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=tonumber(kv_table['AbilitySpecial']['02']['speed']),width=0}
		elseif ability_name=="ancient_apparition_ice_blast" then
			--castpoint=parseQuadroValue(kv_table['AbilityCastPoint'],nil)
			castpoint=ability:GetCastPoint()
			formula={speed=parseQuadroValue(kv_table['AbilitySpecial']['07']['speed'],nil),width=275}
		else
			ability:SetLevel(1)
			castpoint=ability:GetCastPoint()

			--[[print("LOL:",kv_table['AbilityCastPoint'])
			delay=tonumber(kv_table['AbilityCastPoint'])--]]
		end
	end
	local result_table={castpoint,delay,formula}
	
	return result_table

end



function timingAutocastAI(unit,ability,delay,targetUnit)
	local target_type=getTargetType(ability)
	local cast_order
	if target_type=='notarget' then
        cast_order={
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = ability:entindex()
                    }	
	end
	if target_type=='target' then
		cast_order={
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    TargetIndex = targetUnit:entindex(),
                    AbilityIndex = ability:entindex()
                    }
	end
	if target_type=='point' then
		cast_order={
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    Position = targetUnit:GetAbsOrigin(),
                    AbilityIndex = ability:entindex()
                    }
	end
	print("target_type",target_type)
	Timers:CreateTimer(2, function()
		if ability:IsNull() or unit:IsNull() then
			return nil
		else
			ability:EndCooldown()
			ability:RefundManaCost()
			unit:SetContextThink(DoUniqueString("auto_cast_timing"),
			function()
			    ExecuteOrderFromTable(cast_order)
			end,
			0)
			return delay+2
		end
	end
	)




end



function timingAddAbility(unit,ability_name)
	local ability
	if string.sub(ability_name,1,4)=='item' then
		ability = CreateItem(ability_name,unit,unit)
    	unit:AddItem(ability)
	else
		ability=unit:FindAbilityByName(ability_name)
    	ability:SetLevel(1)
	end
	
	return ability


end

function getTargetType(ability)
	local result=nil
	local kv_table=ability:GetAbilityKeyValues()
	local ability_behavior=kv_table['AbilityBehavior']
	if string.find(ability_behavior,"DOTA_ABILITY_BEHAVIOR_NO_TARGET") then
		result='notarget'
	end
	if string.find(ability_behavior,"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") then
		result='target'

	end
	if string.find(ability_behavior,"DOTA_ABILITY_BEHAVIOR_POINT") then
		result='point'
	end
	return result

end

function createFlask(hero,pos)
	--[[local flask = CreateItem("item_flask",hero,hero)
	CreateItemOnPositionSync(pos, flask)
	CustomGameEventManager:Send_ServerToAllClients("ping_on_minimap",{respawn_place=pos}) 
	AddFOWViewer(DOTA_TEAM_GOODGUYS, pos, 400, 5, true) --]]
end

function glimpseOnFlaskPickup(hero)
	if glimpse_v2_training_state==1 then
		GLIMPSE_POS_COUNTER=GLIMPSE_POS_COUNTER+1
		createFlask(hero,glimpse_waypoints[GLIMPSE_POS_COUNTER])
	end
end

function glimpseHero(hero)
	AddFOWViewer(DOTA_TEAM_BADGUYS, hero:GetAbsOrigin(), 1000, 5, true) 
	local respawnPoint=hero:GetAbsOrigin()+Vector(0,100,0)
	print("respawnPoint",respawnPoint)

	local bratan = CreateUnitByNameAsync("npc_dummy_unit", respawnPoint, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
	  --unit:SetAbsOrigin(respawnPoint)
	  unit:SetMaxHealth(10000)
	  unit:SetHealth(10000)
	  unit:SetMoveCapability(1)
	  unit:SetIdleAcquire(false)
--[[	  unit:AddNewModifier(unit, nil, "modifier_phased", {})
	  unit:AddNewModifier(unit, nil, "modifier_no_health_bar", {})--]]
	  unit:AddAbility("disruptor_glimpse")
	  unit:SetForwardVector((hero:GetOrigin() - respawnPoint):Normalized())
	  local ability = unit:FindAbilityByName("disruptor_glimpse")

	  ability:SetLevel(1)

	  print('ability',ability)
	  print('hero',hero)

	  unit:SetContextThink(DoUniqueString("cast_ability_qdqsdsa"),
	    function()
	      print("cast ability")
	      	ExecuteOrderFromTable({
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				AbilityIndex = ability:entindex(),
				TargetIndex = hero:entindex(),
				Queue = 0
			})
	    end,
	  0)
	  unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", 3) unit:RemoveSelf() end, 3)
	  return unit
	end)

end

function glimpseOnUnitSpawned(npc)
	if glimpse_v2_training_state==1 then

		if npc:GetUnitName()=="npc_dota_thinker" then
			refreshSkills(active_hero)
			local pos=npc:GetAbsOrigin()
			local length=(active_hero:GetAbsOrigin()-npc:GetAbsOrigin()):Length()
		    local glimpse_time=length/600
		    if length/600>1.8 then
		      glimpse_time=1.8
		    end
		    CustomGameEventManager:Send_ServerToAllClients("glimpse_casted",{bartime=glimpse_time,castpoint=GLIMPSE_SAFETIME})
		    local success=false


		end
	end

end

function glimpseOnSkillUsed(abilityName)
	if glimpse_v2_training_state==1 then
		if abilityName~="disruptor_glimpse" and abilityName~="item_travel_boots" then
			TRY_TO_DODGE=Time()
		end
	end

end

function ssAddUnitNew(unitName,radius,speed,remake)
  if unitName=="npc_dota_hero_antimage" then
    if radius<800 then
      radius=800
    end
  end
  if unitName=="npc_dota_hero_juggernaut" then 

  end
  if unitName=="npc_dota_hero_phoenix" then
    if radius<800 then
      radius=800
    end
  end
  if unitName=="npc_dota_hero_earth_spirit" then
    if radius<1000 then
      radius=1000
    end
  end
  if unitName=="npc_dota_hero_mirana" then

  end
  if unitName=="npc_dota_hero_queenofpain" then
    if radius<950 then
      radius=950
    end
  end
  local kekus=CreateUnitByNameAsync(unitName, randomCirclePositionVector(radius,TRAINING_PLACE), true, nil, nil, DOTA_TEAM_BADGUYS, function(targetUnit) 
    targetUnit:SetBaseStrength(200)
    targetUnit:SetBaseAgility(0)
    targetUnit:SetBaseHealthRegen(100)

    targetUnit:SetBaseManaRegen(50)
    
    --[[if speed>550 then
    	targetUnit:AddNewModifier(targetUnit, nil, "modifier_dark_seer_surge", {})
    else
    	
    	targetUnit:AddNewModifier(targetUnit, nil, "modifier_dark_seer_surge", {})
    end--]]

    targetUnit:SetMoveCapability(1)
    targetUnit:SetAttackCapability(0)
    local direction_seed=RandomInt(-100,100)
    local direction
    if direction_seed<0 then
      direction=-1
    else
      direction=1
    end
    local target_index=targetUnit:entindex()
    SS_MOVE_DIR[target_index]=direction
    SS_TARGETS[target_index]=targetUnit
    SS_TARGET_MOVE_RADIUS[target_index]=radius
    SS_MOVE_DIR[target_index]=direction
    SS_MOVE_SPEED[target_index]=speed
    local unit_pos=targetUnit:GetAbsOrigin()
    local move_dir=(TRAINING_PLACE-unit_pos):Normalized()
    local move_dir_radius=-move_dir*SS_TARGET_MOVE_RADIUS[target_index]
    if direction>0 then
      new_dir=Vector(move_dir.y,-move_dir.x,0)
    else
      new_dir=Vector(-move_dir.y,move_dir.x,0)
    end
    targetUnit:SetForwardVector(new_dir)
    if remake then
      CustomGameEventManager:Send_ServerToAllClients("skillshot_replace",{old=remake,new=target_index})
    else
      CustomGameEventManager:Send_ServerToAllClients("skillshot_new_target",{index=target_index,name=unitName})
    end
    if unitName=="npc_dota_hero_antimage" then
      ssAmBlinking(target_index,false)
    end
    if unitName=="npc_dota_hero_juggernaut" then 
      ssJuggerMove(target_index,false)
    end
    if unitName=="npc_dota_hero_phoenix" then
      ssPhoenixMove(target_index,false)
    end
    if unitName=="npc_dota_hero_earth_spirit" then
      ssEsMove(target_index,false)
    end
    if unitName=="npc_dota_hero_mirana" then
      ssMiranaMove(target_index,false)
    end
    if unitName=="npc_dota_hero_queenofpain" then
      ssQopBlinking(target_index,false)
    end
  end)
end

function ss_beglec(active_hero)

	SS_ENEMIES={"npc_dota_hero_nevermore",
	    "npc_dota_hero_earthshaker",
	    "npc_dota_hero_windrunner",
	    "npc_dota_hero_tusk",
	    "npc_dota_hero_meepo",
	    "npc_dota_hero_riki"
	  }
	local unitname=SS_ENEMIES[RandomInt(1,6)]

	waypoints1={
		Vector(-3592.6506347656,-1018.6044311523,384),
		Vector(-4850.9174804688,-1396.0091552734,384),
		Vector(-869.45404052734,-4010.3049316406,384),
		Vector(1785.5065917969,-5665.6801757813,384),
	}

	waypoints2={
		Vector(5400.4326171875,-3155.8054199219,384),
		Vector(3625.8869628906,-3315.4985351563,249.88737487793),
		Vector(2004.5510253906,-2399.7614746094,256),
		Vector(-478.88110351563,-319.41876220703,128),
		Vector(-2099.2329101563,544.71551513672,239.99560546875),
		Vector(-4149.7709960938,1769.2938232422,384),
		Vector(-5404.5649414063,2585.34765625,384),
	}

	waypoint3=Vector(5323, 4788, 384)
	for k,v in pairs(waypoints1) do
		--DebugDrawCircle(v, Vector(255,255,0), 25, 25, true, 100)
		--DebugDrawText(v+Vector(100,0,0), tostring(k), true, 100)

	end
	for k,v in pairs(waypoints2) do
		--DebugDrawCircle(v, Vector(255,0,255), 25, 25, true, 100)
		--DebugDrawText(v+Vector(100,0,0), tostring(k), true, 100)
	end

	local waypoint1_ind=RandomInt(1,4)
	local waypoint2_ind
	if waypoint1_ind>2 then
		waypoint2_ind=RandomInt(1,4)
	elseif waypoint1_ind<2 then
		waypoint2_ind=RandomInt(5,7)
	else
		waypoint2_ind=RandomInt(6,5)
	end
	local waypoint1=waypoints1[waypoint1_ind]
	local waypoint2=waypoints2[waypoint2_ind]

	BEGLEC_WP_1=waypoint2
	BEGLEC_WP_2=waypoint3
	escapeUnit=CreateUnitByName(unitname, waypoint1, true, nil, nil, DOTA_TEAM_BADGUYS)
	escapeUnit:AddNewModifier(active_hero, nil, "modifier_bounty_hunter_track", {})
	escapeUnit:SetAttackCapability(0)
	escapeUnit:SetBaseHealthRegen(25)
	escapeUnit:SetBaseStrength(200)
	local travel = CreateItem("item_travel_boots", escapeUnit, escapeUnit)  
	escapeUnit:AddItem(travel)
		
--[[		Timers:CreateTimer({
          useGameTime = false,
          endTime = FrameTime(),
          callback = function()
            if not targetUnit:IsNull() then
              AddFOWViewer(DOTA_TEAM_GOODGUYS, targetUnit:GetAbsOrigin(), 400, FrameTime(), true)
              return FrameTime()
            else
              return nil
            end
          end
        })--]]

	--escapeUnit:AddNewModifier(active_hero, nil, "modifier_bounty_hunter_track", {})
	escapeUnit:SetContextThink(DoUniqueString("move_order"),
    function()
         ExecuteOrderFromTable({
            UnitIndex = escapeUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = waypoint2,
            Queue = 0
         })
      	ExecuteOrderFromTable({
			UnitIndex = escapeUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = waypoint3,
			Queue = 1
		})
    end,
    0) 
    --finish check
    Timers:CreateTimer(function()
			if not escapeUnit:IsNull() then
				local len_to_finish=GridNav:FindPathLength(escapeUnit:GetAbsOrigin(), waypoint3)
				print('len to finish:',len_to_finish)
				if len_to_finish>200 then
					return 0.5
				else

					print("FININSHNAYA")
					return nil

				end
			else
				return nil
			end
	    end
  	)

end

function skillshotNotUsing()
	local closest_waypoint
	if GridNav:FindPathLength(escapeUnit:GetAbsOrigin(), BEGLEC_WP_1)<GridNav:FindPathLength(escapeUnit:GetAbsOrigin(), BEGLEC_WP_2) then
		closest_waypoint=BEGLEC_WP_1
	else
		closest_waypoint=BEGLEC_WP_2
	end
	

	escapeUnit:SetContextThink(DoUniqueString("unit_stop"),
	function()
	ExecuteOrderFromTable({
	  	UnitIndex = escapeUnit:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    	Position = BEGLEC_WP_2
	})
	end,
	0) 



end


function skillshotEnemyDie()

end

function skillshotOnEnemyHit()


end

function skillshotOnSkillUsed(abilityname,caster,cast_pos)
	--print('skill cast begin:',abilityname)
	--ability:IsInAbilityPhase()
	if abilityname=="pudge_meat_hook" then
		LH_UNIT_ESCAPE=1
		hero = caster
		local ability=hero:FindAbilityByName(abilityname)
		kv_table=ability:GetAbilityKeyValues()
		local speed=tonumber(kv_table['AbilitySpecial']['01']['hook_speed'])
		local distance=tonumber(kv_table['AbilitySpecial']['03']['hook_distance'])
		local width=tonumber(kv_table['AbilitySpecial']['02']['hook_width'])
		local castpoint=ability:GetCastPoint()
		local hero_dir=hero:GetForwardVector()
		local hero_pos=hero:GetAbsOrigin()
		local new_dir
		local time=0
		local color1=Vector(255,0,0)
		local color2=Vector(0,0,255)
		local color3=Vector(255,0,255)
		local ztest=true
		local max_time=castpoint+(distance/speed)
		local pizduk_dir=escapeUnit:GetForwardVector()
		--DebugDrawLine(hero_pos, cast_pos, 20,255,20, ztest, 20)
		local pizduk_pos=escapeUnit:GetAbsOrigin()
		local pos1=(hero_pos-cast_pos):Normalized()
		local pos2=(hero_pos-pizduk_pos):Normalized()
		----DebugDrawCircle(pizduk_pos, color1, 20, 20, ztest, 20)
--[[		local angle = (RotationDelta((VectorToAngles(pos1)), VectorToAngles(hero_dir)).y)
		if angle>0 then
		new_dir=Vector(hero_dir.y,-hero_dir.x,0)
		else
		new_dir=Vector(-hero_dir.y,hero_dir.x,0)
		end--]]
		local move_point
		
		local actual_len

		--ТАКТИКА СЪЕБА

		--ищем сторону дальнюю от линии полета скилшота
		local side_angle=(RotationDelta((VectorToAngles(pos1)), VectorToAngles(pos2)))
		--print('side angle:',side_angle)
		if side_angle.y>0 then
			escape_dir=Vector(pos1.y,-pos1.x,0)
		else
			escape_dir=Vector(-pos1.y,pos1.x,0)
		end


		local found_iter
		local iters=9
		local min_len=9999999999999999999

		for i=1,iters do
			local new_point_len=300
			new_dir=RotatePosition(Vector(0,0,0),QAngle(0,i*5-45,0),escape_dir)
			move_point=pizduk_pos+new_dir*new_point_len
			actual_len=GridNav:FindPathLength(move_point, pizduk_pos)
			while actual_len==-1 do
				new_point_len=new_point_len+20
				move_point=pizduk_pos+new_dir*new_point_len
				actual_len=GridNav:FindPathLength(move_point, pizduk_pos)
			end
			
			----DebugDrawText(move_point+Vector(100,0,0), tostring(actual_len), true, 20)
			----DebugDrawText(move_point+Vector(100,0,0), tostring(i*5-45), true, 10)
			if GridNav:IsTraversable(move_point) then
				----DebugDrawCircle(move_point, color2, 20, 20, ztest, 10)
			else
				----DebugDrawCircle(move_point, color1, 20, 20, ztest, 10)
			end
			
			if actual_len<min_len and actual_len~=-1 then
				found_iter=i
				min_len=actual_len
			end
		end
		
		--print('min_len=',min_len)

		new_dir=RotatePosition(Vector(0,0,0),QAngle(0,found_iter*5-45,0),escape_dir)
		local angle = (RotationDelta((VectorToAngles(pos1)), VectorToAngles(new_dir)))
		--print('angle=',angle)
		move_point=pizduk_pos+new_dir*300


		--[[if actual_len>200 or actual_len==-1 then 
			while actual_len>200 or actual_len==-1 do
				new_dir=RotatePosition(Vector(0,0,0),QAngle(0,15,0),new_dir)
				move_point=pizduk_pos+new_dir*250
				--DebugDrawCircle(move_point, color2, 20, 20, ztest, 4)
				actual_len=GridNav:FindPathLength(move_point, pizduk_pos)
			end
		end--]]

		
		----DebugDrawCircle(move_point, color3, 80, 20, ztest, 4)
		escapeUnit:SetContextThink(DoUniqueString("cast_ability"),
		function()
		ExecuteOrderFromTable({
		  UnitIndex = escapeUnit:entindex(),
		  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		  Position = move_point,
		  Queue = 0
		})
		ExecuteOrderFromTable({
			UnitIndex = escapeUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = BEGLEC_WP_2,
			Queue = 1
		})
		end,
		0) 
		-- for i, v in ipairs(hero_pos_table) do 
		-- --DebugDrawCircle(v, color, 20, 20, ztest, interval)
		

    end
    if abilityname=="nyx_assassin_impale" then
		LH_UNIT_ESCAPE=1
		hero = caster
		local ability=hero:FindAbilityByName(abilityname)
		kv_table=ability:GetAbilityKeyValues()
		local speed=parseQuadroValue(kv_table['AbilitySpecial']['04']['speed'])
		local distance=tonumber(kv_table['AbilitySpecial']['03']['length'])
		local width=tonumber(kv_table['AbilitySpecial']['01']['width'])
		local castpoint=ability:GetCastPoint()
		local hero_dir=hero:GetForwardVector()
		local hero_pos=hero:GetAbsOrigin()
		local new_dir
		local time=0
		local color1=Vector(255,0,0)
		local color2=Vector(0,0,255)
		local color3=Vector(255,0,255)
		local ztest=true
		local max_time=castpoint+(distance/speed)
		local pizduk_dir=escapeUnit:GetForwardVector()
		--DebugDrawLine(hero_pos, cast_pos, 20,255,20, ztest, 20)
		local pizduk_pos=escapeUnit:GetAbsOrigin()
		local pos1=(hero_pos-cast_pos):Normalized()
		local pos2=(hero_pos-pizduk_pos):Normalized()
		----DebugDrawCircle(pizduk_pos, color1, 20, 20, ztest, 20)
--[[		local angle = (RotationDelta((VectorToAngles(pos1)), VectorToAngles(hero_dir)).y)
		if angle>0 then
		new_dir=Vector(hero_dir.y,-hero_dir.x,0)
		else
		new_dir=Vector(-hero_dir.y,hero_dir.x,0)
		end--]]
		local move_point
		
		local actual_len

		--ТАКТИКА СЪЕБА

		--ищем сторону дальнюю от линии полета скилшота
		local side_angle=(RotationDelta((VectorToAngles(pos1)), VectorToAngles(pos2)))
		--print('side angle:',side_angle)
		if side_angle.y>0 then
			escape_dir=Vector(pos1.y,-pos1.x,0)
		else
			escape_dir=Vector(-pos1.y,pos1.x,0)
		end


		local found_iter
		local iters=9
		local min_len=9999999999999999999

		for i=1,iters do
			local new_point_len=300
			new_dir=RotatePosition(Vector(0,0,0),QAngle(0,i*5-45,0),escape_dir)
			move_point=pizduk_pos+new_dir*new_point_len
			actual_len=GridNav:FindPathLength(move_point, pizduk_pos)
			while actual_len==-1 do
				new_point_len=new_point_len+20
				move_point=pizduk_pos+new_dir*new_point_len
				actual_len=GridNav:FindPathLength(move_point, pizduk_pos)
			end
			
			----DebugDrawText(move_point+Vector(100,0,0), tostring(actual_len), true, 20)
			----DebugDrawText(move_point+Vector(100,0,0), tostring(i*5-45), true, 10)
			if GridNav:IsTraversable(move_point) then
				----DebugDrawCircle(move_point, color2, 20, 20, ztest, 10)
			else
				----DebugDrawCircle(move_point, color1, 20, 20, ztest, 10)
			end
			
			if actual_len<min_len and actual_len~=-1 then
				found_iter=i
				min_len=actual_len
			end
		end
		
		--print('min_len=',min_len)

		new_dir=RotatePosition(Vector(0,0,0),QAngle(0,found_iter*5-45,0),escape_dir)
		local angle = (RotationDelta((VectorToAngles(pos1)), VectorToAngles(new_dir)))
		--print('angle=',angle)
		move_point=pizduk_pos+new_dir*300


		--[[if actual_len>200 or actual_len==-1 then 
			while actual_len>200 or actual_len==-1 do
				new_dir=RotatePosition(Vector(0,0,0),QAngle(0,15,0),new_dir)
				move_point=pizduk_pos+new_dir*250
				--DebugDrawCircle(move_point, color2, 20, 20, ztest, 4)
				actual_len=GridNav:FindPathLength(move_point, pizduk_pos)
			end
		end--]]

		
		----DebugDrawCircle(move_point, color3, 80, 20, ztest, 4)
		escapeUnit:SetContextThink(DoUniqueString("cast_ability"),
		function()
		ExecuteOrderFromTable({
		  UnitIndex = escapeUnit:entindex(),
		  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		  Position = move_point,
		  Queue = 0
		})
		ExecuteOrderFromTable({
			UnitIndex = escapeUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = BEGLEC_WP_2,
			Queue = 1
		})
		end,
		0) 
		-- for i, v in ipairs(hero_pos_table) do 
		-- --DebugDrawCircle(v, color, 20, 20, ztest, interval)
		

    end


end


function customCooldownController(keys)

	if (keys==1) then

	elseif (keys==0) then


	else
		local player = PlayerResource:GetPlayer(keys.PlayerID)
  		local abilityname = keys.abilityname
  		local targetHero=player:GetAssignedHero()
		Timers:CreateTimer(1.5, function()
        if not targetHero:IsNull() then
    	for i=0, 6, 1 do
			local current_item = targetHero:GetAbilityByIndex(i)
			if current_item ~= nil then
				current_item:EndCooldown()
				current_item:RefundManaCost()
			end
		end

        end
      end
      )


	end

end
SN_AI_CREEPS={}
SN_AI_MINDMG=0
SN_AI_CURRENT_TARGET=nil
SN_AI_SNIPER=nil
SN_AI_KILLSTREAK=0
SN_AI_KILLCOUNT=0


function AveragePoint(vectors)
    local avg = Vector(0,0,0)

    -- Sum all the vectors
    for i, vec in ipairs(vectors) do
        avg.x = avg.x + vec.x
        avg.y = avg.y + vec.y
        avg.z = avg.z + vec.z
    end

    -- Divide by the number of vectors to find the average
    avg.x = avg.x / #vectors
    avg.y = avg.y / #vectors
    avg.z = avg.z / #vectors

    return avg
end

function moveUnitAndTurnToDirection(unit,point,direction)
	ExecuteOrderFromTable({
	  UnitIndex = unit:entindex(),
	  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	  Position = point,
	  Queue = 0
	})
	ExecuteOrderFromTable({
		UnitIndex = unit:entindex(),
    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = turnaround_point,
		Queue = 1
	})
end

function sniperAIv2(sniper)
	--start ai thinker
	--states:1-reposition,2-attack,3-prepare for attack
	--3 state condition: if one of creeps has <100 hp and there is no 0 creeps on each side(radiant dire)
	--test state: 4 state when enemy creeps has more hp in total - attack the biggest one
	--make states an interruptable value: only reposition can be interruptable
	SN_AI_SNIPER=sniper
	sniper:SetBaseHealthRegen(150)
	sniper:SetPhysicalArmorBaseValue(50)
	sniper:SetIdleAcquire(false)
	local blades_of_attack=CreateItem("item_blades_of_attack",sniper,sniper)
  sniper:AddItem(blades_of_attack)
  local fairy_hueta=CreateItem("item_faerie_fire",sniper,sniper)
  sniper:AddItem(fairy_hueta)
  sniper:AddItem(fairy_hueta)
	local ability = sniper:FindAbilityByName("sniper_take_aim")
	ability:SetLevel(4)
	custom_value=12
	SN_AI_MINDMG=sniper:GetBaseDamageMin()+custom_value
	print('sniper min base dmg',SN_AI_MINDMG)
	local current_state=0
	local sniper_side=sniper:GetTeam()
	local sniper_tower=nil
	local sniper_enemy_side=nil
	local sniper_min_dmg=sniper:GetBaseDamageMin()

	if sniper_side==DOTA_TEAM_BADGUYS then
		sniper_tower=lh_dire_tower_spawn
		sniper_enemy_side=DOTA_TEAM_GOODGUYS
	else
		sniper_tower=lh_radiant_tower_spawn
		sniper_enemy_side=DOTA_TEAM_BADGUYS
	end
	local distance_to_reposition=400
  Timers:CreateTimer("ai_thinker_for_sniper", {
    useGameTime = false,
    endTime = FrameTime(),
    callback = function()
    	--print('ai_thinker_started')

      if sniper:IsNull()==false then
      	local isIdle=sniper:IsIdle()
      	local IsAttacking=sniper:IsAttacking()
      	local debug_string=""
      	--checking creeps hp
      	local enemy_creeps_total_hp=0
      	local allied_creeps_total_hp=0
      	local creeps=Entities:FindAllByName("npc_dota_creep_lane")
      	local friendly_creeps_pos={}
      	local lasthittable_enemy_creeps={}
      	local friendly_attackable_creeps={}
      	local lasthitable_allied_creeps={}
      	local fattest_enemy_creep=nil
      	local creep_to_attack=nil
      	for k,v in pairs(creeps) do
      		if v~=nil then
	      		if v:IsNull()==false then
	      			local creep=v
	      			local creep_armor=creep:GetPhysicalArmorValue(false)
	      			local creep_dmg_mult=1-(0.05*creep_armor/(1+0.05*math.abs(creep_armor)))
							
							local creep_hp=creep:GetHealth()
							local creep_lasthittable=false
							if creep_hp<=sniper_min_dmg*creep_dmg_mult then
								creep_lasthittable=true
							end
							local creep_team=creep:GetTeam()
							local creep_entindex=creep:GetEntityIndex()
							local creep_debug_string="ENTI:"..tostring(creep_entindex).."_TEAM:"..tostring(creep_team).."_HP:"..tostring(creep_hp).." "
							debug_string=debug_string..creep_debug_string
							if creep_team==sniper_side and creep_hp~=0 then
								table.insert(friendly_creeps_pos,creep:GetAbsOrigin())
							end
							if creep_team==sniper_side and creep_hp~=0 then
								allied_creeps_total_hp=allied_creeps_total_hp+creep_hp
							end
							if creep_team==sniper_enemy_side and creep_hp~=0 then
								enemy_creeps_total_hp=enemy_creeps_total_hp+creep_hp
							end
							if creep_team==sniper_enemy_side and creep_lasthittable and creep_hp~=0 then
								table.insert(lasthittable_enemy_creeps,creep)
							end
							if creep_team==sniper_side and creep_lasthittable and creep_hp~=0 then
								table.insert(lasthitable_allied_creeps,creep)
							end
							if creep_team==sniper_side and creep_hp<(creep:GetMaxHealth()/2) and creep_hp~=0 then
								table.insert(friendly_attackable_creeps,creep)
							end
							if creep_team==sniper_enemy_side then
								if fattest_enemy_creep==nil then
									fattest_enemy_creep=creep
								else
									if creep_hp>fattest_enemy_creep:GetHealth() then
										fattest_enemy_creep=creep
									end
								end
							end
							

						end
					end
				end
				if #lasthitable_allied_creeps>0 or #lasthittable_enemy_creeps>0 then
					--sniper:Stop()
					current_state=2
				end

				if current_state==0 then
					
					if math.abs(allied_creeps_total_hp-enemy_creeps_total_hp)>50 then
						
						if allied_creeps_total_hp>enemy_creeps_total_hp then
							if #friendly_attackable_creeps>0 then
								creep_to_attack=friendly_attackable_creeps[#friendly_attackable_creeps]
							end
						else
							if fattest_enemy_creep~=nil then
								creep_to_attack=fattest_enemy_creep
							end
						end
					end
					if creep_to_attack~=nil then
						current_state=4
					end
				end
				debug_string=debug_string.."CURRENT_STATE:"..tostring(current_state).." "
				local color1=Vector(255,0,0)
				local color2=Vector(0,0,255)
				local color3=Vector(255,0,255)
				local color4=Vector(255,255,0)
				local color5=Vector(0,0,0)
				local ztest=true
				--print(debug_string)
				debug_string=debug_string.."AMMOUNT_OF_FRIENDLY_VECTORS:"..tostring(#friendly_creeps_pos).." "
				local fr_cr_avg_point=AveragePoint(friendly_creeps_pos)
				--DebugDrawCircle(fr_cr_avg_point, color1, 20, 20, ztest, FrameTime())
				--DebugDrawCircle(sniper:GetAbsOrigin(), color2, 20, distance_to_reposition, ztest, FrameTime())
				
				local direction
				local save_spot
				local turnaround_point
				if #friendly_creeps_pos>0 then
					direction = (sniper_tower-fr_cr_avg_point):Normalized()
					save_spot=fr_cr_avg_point + 430 * direction
					turnaround_point=fr_cr_avg_point + 400 * direction
				else
					save_spot=sniper_tower
					turnaround_point=randomCirclePosition(50,sniper)
				end

				--DebugDrawCircle(save_spot, color2, 20, 20, ztest, FrameTime())
				--DebugDrawCircle(turnaround_point, color3, 20, 20, ztest, FrameTime())
				local distance_to_save_spot=DistanceBetweenTwoVectors(sniper:GetAbsOrigin(),save_spot)
				debug_string=debug_string.."DISTANCE_TO_SAVE_SPOT:"..tostring(distance_to_save_spot).." "
				if current_state==1 then
					if distance_to_save_spot>distance_to_reposition then
						ExecuteOrderFromTable({
						  UnitIndex = sniper:entindex(),
						  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
						  Position = save_spot,
						  Queue = 0
						})
--[[						ExecuteOrderFromTable({
							UnitIndex = sniper:entindex(),
	            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	            Position = turnaround_point,
							Queue = 1
						})--]]
					end
				end
				if current_state==2 then
					local target_creep
					if #lasthitable_allied_creeps>0 then
						target_creep=lasthitable_allied_creeps[#lasthitable_allied_creeps]
					end
					if #lasthittable_enemy_creeps>0 then
						target_creep=lasthittable_enemy_creeps[#lasthittable_enemy_creeps]
					end
					SN_AI_CURRENT_TARGET=target_creep
					if isIdle then
						ExecuteOrderFromTable({
							UnitIndex = sniper:entindex(),
							OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
							TargetIndex = target_creep:entindex()
						})
						print('sniper atacks')
					end
				end
				if current_state==4 then
					if isIdle then
						ExecuteOrderFromTable({
							UnitIndex = sniper:entindex(),
							OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
							TargetIndex = creep_to_attack:entindex()
						})
						print('sniper atacks')
					end
				end
				if distance_to_save_spot>distance_to_reposition then
	    		current_state=1
	    	else
	    		current_state=0
	    	end

				debug_string=debug_string.."SAVE_SPOT:"..tostring(save_spot.x)..","..tostring(save_spot.y)..","..tostring(save_spot.z).." "
				debug_string=debug_string.."TURN_SPOT:"..tostring(turnaround_point.x)..","..tostring(turnaround_point.y)..","..tostring(turnaround_point.z).." "
				local distance_between_save_and_turn=DistanceBetweenTwoVectors(save_spot,turnaround_point)
				debug_string=debug_string.."DISTANCE_BETWEEN_SAVE_AND_TURN:"..tostring(distance_between_save_and_turn).." "
				debug_string=debug_string.."ENEMY_CREEPS_HP:"..tostring(enemy_creeps_total_hp).." "
				debug_string=debug_string.."FRIENDLY_CREEPS_HP:"..tostring(allied_creeps_total_hp).." "
				debug_string=debug_string.."SNIPER_IDLE:"..tostring(isIdle).." "
				debug_string=debug_string.."SNIPER_ATTACKS:"..tostring(IsAttacking).." "
				CustomGameEventManager:Send_ServerToAllClients("setDebugOutput",{msg=debug_string})
				return FrameTime()
			else
				return nil
			end
		end
	})
end


function activateShiperAI(targetUnit)
	--Vector(-37.186794281006,228.02165222168,128) start place
	--Vector(-160.56265258789,208.11791992188,128)
--[[	ExecuteOrderFromTable({
		UnitIndex = targetUnit:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = Vector(-160.56265258789,208.11791992188,128)
	})--]]
	SN_AI_SNIPER=targetUnit
	targetUnit:SetBaseHealthRegen(150)
	targetUnit:SetPhysicalArmorBaseValue(50)
	targetUnit:SetIdleAcquire(false)
	local blades_of_attack=CreateItem("item_blades_of_attack",targetUnit,targetUnit)
    targetUnit:AddItem(blades_of_attack)
    local fairy_hueta=CreateItem("item_faerie_fire",targetUnit,targetUnit)
    targetUnit:AddItem(fairy_hueta)
    targetUnit:AddItem(fairy_hueta)
	
	local ability = targetUnit:FindAbilityByName("sniper_take_aim")
	ability:SetLevel(4)
	custom_value=12
	SN_AI_MINDMG=targetUnit:GetBaseDamageMin()+custom_value
	print('sniper min base dmg',SN_AI_MINDMG)
	Timers:CreateTimer("ai_thinker_for_sniper", {
      useGameTime = false,
      endTime = FrameTime(),
      callback = function()
        if targetUnit:IsNull()==false then
        	--s=0
        	--lh_dire_tower_spawn
        	--lh_radiant_tower_spawn
        	for k,v in pairs(LH_CREEPS) do
						if SN_AI_CURRENT_TARGET==nil then
							SN_AI_CURRENT_TARGET=v[1]
							ExecuteOrderFromTable({
								UnitIndex = targetUnit:entindex(),
								OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
								TargetIndex = SN_AI_CURRENT_TARGET:entindex()
							})
							print('sniper atacks')
						end
					end
        	--print("S=",s)
        	

			return FrameTime()
		else
			return nil
		end
	end
    })
	Timers:CreateTimer("ai_thinker_for_sniper_reposition", {
      useGameTime = false,
      endTime = FrameTime(),
      callback = function()
        if targetUnit:IsNull()==false then
        	print('reposition tick')
        	sniperAIReposition()
			return 1
		else
			return nil
		end
	end
    })

	--[[local direction = (hero:GetAbsOrigin()-respawn_place):Normalized()
				local target_point_vector = oldRespawnPlace + 50 * direction--]]

end


function sniperAIReposition()

	targetUnit=SN_AI_SNIPER
	
	local sniper_side=targetUnit:GetTeam()
	local sniper_tower=nil
	local sniper_enemy_side=nil
	if sniper_side==DOTA_TEAM_BADGUYS then
		sniper_tower=lh_dire_tower_spawn
		sniper_enemy_side=DOTA_TEAM_GOODGUYS
	else
		sniper_tower=lh_radiant_tower_spawn
		sniper_enemy_side=DOTA_TEAM_BADGUYS
	end
    local trash=Entities:FindAllByName("npc_dota_creep_lane")
	local min_range=1000
	local farest_point=nil
	for k,v in pairs(trash) do
		if targetUnit:GetTeam()~=v:GetTeam() then
			local lenght=targetUnit:GetAbsOrigin()-v:GetAbsOrigin()
			local range=lenght:Length()
			if range<min_range then
				min_range=range
				farest_point=v:GetAbsOrigin()
			end
		end
	end
	if farest_point~=nil then
		if targetUnit:IsAttacking() then
			print('sniper attacking')
		else
			local color1=Vector(255,0,0)
			local color2=Vector(0,0,255)
			local color3=Vector(255,0,255)
			local color4=Vector(255,255,0)
			local color5=Vector(0,0,0)
			local ztest=true
			local direction = (sniper_tower-farest_point):Normalized()
			local target_point_vector = farest_point + 530 * direction
			local target_point_vector2 = farest_point + 510 * direction

			--debug
			local lenght1=targetUnit:GetAbsOrigin()-target_point_vector
			local range1=lenght1:Length()
			print("RETREAT RANGE IS:",range1)
			print("MIN RANGE IS:",min_range)
			--[[if min_range>500 and min_range<700 then
				local lenght2=targetUnit:GetAbsOrigin()-active_hero:GetAbsOrigin()
				local range2=lenght2:Length()
				if targetUnit:Script_GetAttackRange()>range2 then
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = active_hero:entindex()
					})
					print('sniper atacks hero')

				end

			else
				if range1>150 then
					ExecuteOrderFromTable({
					  UnitIndex = targetUnit:entindex(),
					  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					  Position = target_point_vector,
					  Queue = 0
					})
					ExecuteOrderFromTable({
						UnitIndex = targetUnit:entindex(),
			            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			            Position = target_point_vector2,
						Queue = 1
					})
				end
			end--]]
			if range1>150 then
				ExecuteOrderFromTable({
				  UnitIndex = targetUnit:entindex(),
				  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				  Position = target_point_vector,
				  Queue = 0
				})
				ExecuteOrderFromTable({
					UnitIndex = targetUnit:entindex(),
		            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		            Position = target_point_vector2,
					Queue = 1
				})
			end
			--DebugDrawCircle(target_point_vector, color1, 20, 20, ztest, 5)

			print('sniper get backs')
		end
	else
		print("farest point is nil")
		--Vector(-160.56265258789,208.11791992188,128)
		ExecuteOrderFromTable({
		  UnitIndex = targetUnit:entindex(),
		  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		  Position = Vector(-160,208,128),
		  Queue = 0
		})
		ExecuteOrderFromTable({
			UnitIndex = targetUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = Vector(-158,206,128),
			Queue = 1
		})
	end



end


function sniperAIonUnitDead(killedUnit,targetUnit)
	if SN_AI_CURRENT_TARGET==killedUnit then
		if targetUnit==SN_AI_SNIPER then
			if killedUnit:GetTeam()==targetUnit:GetTeam() then
				local mode = GameRules:GetGameModeEntity()
				local sign = ParticleManager:CreateParticle("particles/econ/events/ti8/msg_deny_ti8.vpcf", PATTACH_CUSTOMORIGIN, mode)
				ParticleManager:SetParticleControl(sign, 0, killedUnit:GetAbsOrigin())
				ParticleManager:SetParticleControl(sign, 3, Vector(138, 43, 226))
				ParticleManager:SetParticleControl(sign, 4, Vector(30,0,0))
				ParticleManager:ReleaseParticleIndex(sign)
			end
			SN_AI_KILLCOUNT=SN_AI_KILLCOUNT+1
			local mode = GameRules:GetGameModeEntity()
			local sign = ParticleManager:CreateParticle("particles/newplayer_fx/last_hit_streak.vpcf", PATTACH_CUSTOMORIGIN, mode)
			ParticleManager:SetParticleControl(sign, 0, SN_AI_SNIPER:GetAbsOrigin())
			ParticleManager:SetParticleControl(sign, 3, Vector(138, 43, 226))
			ParticleManager:SetParticleControl(sign, 1, Vector(0,SN_AI_KILLCOUNT,0))
			ParticleManager:ReleaseParticleIndex(sign)
			
			--PUT X PARTICLE HERE
		end
		Timers:CreateTimer({
          endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
          callback = function()
            SN_AI_CURRENT_TARGET=nil
            
          end
        })
	
	end


end

function sniperAIonUnitHurt(entCause,entVictim,victim_hp)



end



function createGGTree(vectorPos,intTime)
	CreateTempTreeWithModel(vectorPos, intTime,"models/props_tree/ti7/ggbranch.vmdl")
end

function removeReplicateFromHero(hero)

	hero:RemoveModifierByName("modifier_morphling_replicate_manager")
	hero:RemoveModifierByName("modifier_morphling_replicate")
	print('removing replicate from',hero:GetUnitName())

end

morph_abilities_ignore={"ability_capture",
	"marci_guardian",
	"twin_gate_portal_warp",
	"ability_lamp_use",
	"ability_pluck_famango",
	"keeper_of_the_light_radiant_bind",
				"generic_hidden",
				"bane_nightmare_end",
			"arc_warden_scepter",
		"chen_holy_persuasion",
		"doom_bringer_devour",
	"clinkz_death_pact",
"earth_spirit_petrify",
"elder_titan_return_spirit",
"ember_spirit_activate_fire_remnant",
"enchantress_bunny_hop",
"enigma_demonic_conversion",
"keeper_of_the_light_illuminate_end",
"keeper_of_the_light_spirit_form_illuminate",
"keeper_of_the_light_spirit_form_illuminate_end",
"kunkka_torrent_storm",
"lycan_wolf_bite",
"medusa_mana_shield",
"kunkka_return",
"nyx_assassin_burrow",
"nyx_assassin_unburrow",
"ogre_magi_unrefined_fireblast",
"phantom_lancer_phantom_edge",
"phoenix_icarus_dive_stop",
"phoenix_launch_fire_spirit",
"phoenix_sun_ray_toggle_move",
"grimstroke_scepter",
"mars_bulwark",
"monkey_king_tree_dance",
"monkey_king_primal_spring",
"monkey_king_mischief",
"monkey_king_primal_spring_early",
"monkey_king_untransform",
"pudge_rot",
"pudge_eject",
"alchemist_unstable_concoction_throw",
"phoenix_sun_ray_stop",
"rattletrap_overclocking",
"rubick_telekinesis_land",
"rubick_hidden1",
"rubick_hidden2",
"rubick_hidden3",
"shredder_chakram_2",
"shredder_return_chakram_2",
"spectre_reality",
"spectre_haunt_single",
"techies_focused_detonate",
"techies_minefield_sign",
"templar_assassin_trap",
"templar_assassin_trap_teleport",
"tiny_tree_grab",
"tiny_tree_channel",
"tiny_toss_tree",
"treant_eyes_in_the_forest",
"tusk_walrus_kick",
"visage_stone_form_self_cast",
"wisp_tether",
"wisp_tether_break",
"witch_doctor_voodoo_restoration",
"juggernaut_swift_slash",
"snapfire_spit_creep",
"snapfire_gobble_up",
"terrorblade_terror_wave",
"zuus_cloud",
"keeper_of_the_light_blinding_light",
"medusa_split_shot",
"pangolier_rollup_stop",
"rubick_telekinesis_land_self",
"visage_summon_familiars_stone_form",
"wisp_spirits_in",
"wisp_spirits_out",
"zuus_heavenly_jump",
"abyssal_underlord_portal_warp",
"tusk_frozen_sigil",
"dawnbreaker_converge",
"dawnbreaker_land",
"elder_titan_move_spirit",
"marci_companion_run",
"primal_beast_uproar",
"batrider_sticky_napalm_application_damage"
}
morph_abilities_need_creep={
	"chen_holy_persuasion",
	"clinkz_death_pact",
	"doom_bringer_devour",
	"enigma_demonic_conversion"
}

function checkIfInTable(TableToCheck,element)
	local result=false
	for k,v in pairs(TableToCheck) do
		if v==element then
			result=true
		end
	end
	return result
end

function morphHeroIteration()
	MORPH_WAIT_FOR={}
	print("current_hero_name",current_hero_name)
	local current_hero_name=MORPH_HERO_LIST[MORPH_INDEX_COUNTER]
	if MORPHLING_TARGET~=nil then
		if not MORPHLING_TARGET:IsNull() then
			MORPHLING_TARGET:RemoveSelf()
		end
	end
	MORPHLING_TARGET= CreateUnitByName(current_hero_name, TRAINING_PLACE+Vector(100,100,0), true, nil, nil, DOTA_TEAM_BADGUYS)
	MORPHLING_TARGET:SetIdleAcquire(false)
	MORPHLING_TARGET:SetBaseStrength(200)
	for i=1,28 do
		MORPHLING_TARGET:HeroLevelUp(false)
	end
	
	print(MORPHLING_TARGET:GetAbilityCount())
	for i=0,MORPHLING_TARGET:GetAbilityCount()-1 do
		local ability=MORPHLING_TARGET:GetAbilityByIndex(i)
		if ability~=nil then
			local abilityname=ability:GetAbilityName()
			if string.find(abilityname, "special_bonus")==nil and checkIfInTable(morph_abilities_ignore,abilityname)==false then
				local ability_kv=ability:GetAbilityKeyValues()
				--DeepPrintTable(ability_kv)
				--print(ability_kv['AbilityBehavior'])
				if string.find(ability_kv['AbilityBehavior'], "DOTA_ABILITY_BEHAVIOR_PASSIVE")==nil then
					if string.find(ability_kv['AbilityType'], "DOTA_ABILITY_TYPE_ULTIMATE")==nil then
						if string.find(ability_kv['AbilityBehavior'], "DOTA_ABILITY_BEHAVIOR_ATTACK")==nil then
							if ability_kv['IsGrantedByShard']==nil then
								if ability_kv['IsGrantedByScepter']==nil then
									learnAbility(MORPHLING_TARGET,ability,4)
									if abilityname=="troll_warlord_berserkers_rage" then
										table.insert(MORPH_WAIT_FOR,{abilityname,true})
									else
										table.insert(MORPH_WAIT_FOR,{abilityname,false})
									end
									
									--print("ABILITY TABLE FOR:",abilityname)
									--DeepPrintTable(ability_kv)
								end
							end
						end
					end
				end
			end
		end
		
	end
	CustomGameEventManager:Send_ServerToAllClients("update_morph_skills",{skills=MORPH_WAIT_FOR,redraw=1})
	--DeepPrintTable(MORPH_WAIT_FOR)
end

function learnAbility(hero,ability,level)
	for i=1,level do
		hero:UpgradeAbility(ability)
	end
end

function morphCheckForWaiting(abilityname)

	
	local remove_index=0
	for k,v in pairs(MORPH_WAIT_FOR) do
		if v[1]==abilityname then
			v[2]=true
		end
	end
	DeepPrintTable(MORPH_WAIT_FOR)
	
	
	isReadyToNextIteration()

end

function isReadyToNextIteration()
	local index_counter=0
	local true_counter=0
	for k,v in pairs(MORPH_WAIT_FOR) do
		index_counter=index_counter+1
		if v[2]==true then
			true_counter=true_counter+1
		end
	end
	if index_counter==true_counter then
		--print("READY FOR NEXT ITER")
		local current_hero_name=MORPH_HERO_LIST[MORPH_INDEX_COUNTER]

		if current_hero_name=="npc_dota_hero_dawnbreaker" then
			--END OF THE GAME
			local playerId=MORPHLING_ENT:GetPlayerOwnerID()
			local steam=PlayerResource:GetSteamID(playerId)
			local result_time=(Time()-MORPHLING_START_TIME)*1000
			Networking:SendChallengeResult('morph',tostring(steam),result_time,other)
			MORPH_TRAINING=0
			CustomGameEventManager:Send_ServerToAllClients("morph_ended",{time=result_time})
		else
			MORPH_INDEX_COUNTER=MORPH_INDEX_COUNTER+1
			morphHeroIteration()
		end
	else
		CustomGameEventManager:Send_ServerToAllClients("update_morph_skills",{skills=MORPH_WAIT_FOR,redraw=0})
	end
end

function createTreeInRandomRadius(vectorCenter,radius,timeAlive)
	local spawnPoint=randomCirclePositionVector(radius,vectorCenter)
	--[[local any_trees_around=GridNav:GetAllTreesAroundPoint(spawnPoint,200,true)
	while #any_trees_around~=0 do
		spawnPoint=randomCirclePositionVector(radius,vectorCenter)
		any_trees_around=GridNav:GetAllTreesAroundPoint(spawnPoint,200,true)
	end
	print("THRERE ARE SOME TREES AROUND POINT",#any_trees_around)--]]
	CreateTempTreeWithModel(spawnPoint, timeAlive,"models/props_tree/ti7/ggbranch.vmdl")
	local trees=GridNav:GetAllTreesAroundPoint(spawnPoint,5,true)
	for k,v in pairs(trees) do
		v:SetRenderColor(118,140,79)

	end
end



function setItemConfig(hero,mode)
	local items={}
	for i=0,9 do
		local item=hero:GetItemInSlot(i)
		if item then
			table.insert(items,{i,item:GetAbilityName()})
			--print(item:GetAbilityName())
		end
	end
	local result={}
	result[mode]=items
	--return json.encode(result)
	--compare to global config
	if PLAYER_CONFIG~=nil then
		if PLAYER_CONFIG=="no config" then
			print('no config detected, turning config into array')
			PLAYER_CONFIG={}
			print('adding this mode config to fresh config')
			PLAYER_CONFIG[mode]=items
			sendNewConfigData()
		else
			print('looks like config exists')
			print('checking for config for this mode')
			if PLAYER_CONFIG[mode]~=nil then
				print('config for this mode exists')
				print('comparing configs')
				local config_items=PLAYER_CONFIG[mode]
				local tables_are_same=true
				for k,v in pairs(items) do

					if config_items[k]~=nil then
						if config_items[k][1]~=v[1] or config_items[k][2]~=v[2] then
							tables_are_same=false
						end
					else
						tables_are_same=false
					end
				end
				if tables_are_same==true then
					print('configs are the same')
				else
					print('configs are not the same')
					PLAYER_CONFIG[mode]=items
					sendNewConfigData()
				end
			else
				print('config for this mode not exists, adding it to config')
				PLAYER_CONFIG[mode]=items
				sendNewConfigData()
			end
		end
	end
	
end



function getConfigAndApply(hero,mode)
	--[[ DeepPrintTable(PLAYER_CONFIG) ]]
	if PLAYER_CONFIG~=nil and PLAYER_CONFIG~='no config' then
		if PLAYER_CONFIG[mode]~=nil then
			for k,v in pairs(PLAYER_CONFIG[mode]) do
				local slot=v[1]
				local item_name=v[2]
				for i=0,9 do
					local item=hero:GetItemInSlot(i)
					if item then
						local found_item_name=item:GetAbilityName()
						if found_item_name==item_name then
							if slot~=i then
								hero:SwapItems(slot,i)
							end
						end
					end
				end

			end
		end
	end
end

function DistanceBetweenTwoVectors(vector1,vector2)
	local lenght=vector1-vector2
  local result=lenght:Length()
  return result
end