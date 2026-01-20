--i'm making this to parse dota_abilities.txt KV file
--i wish it could be useful for getting spell values for dodge gamemode, because right now castpoints, projectile speed and other stuff are hardcoded and should be changed with patch changes
--in other hand abilities kv structure can be changed in any patch so idk what is more convenient
if DotaDB == nil then
  DotaDB = class({})
end

function DotaDB:Init()
  self.abilities_KV=LoadKeyValues("scripts/npc/npc_abilities.txt")
  self.heroes_KV=LoadKeyValues("scripts/npc/npc_heroes.txt")
  local heroTable=DotaDB:GetAllHeroes()
  for k,v in pairs(heroTable) do
    
    if v~="npc_dota_hero_base" and v~="Version" then
      --[[ print('trying to load',"scripts/npc/heroes/"..v..".txt") ]]
      heroAbilities=LoadKeyValues("scripts/npc/heroes/"..v..".txt")
      --[[ PrintTable(heroAbilities) ]]
      for kk,vv in pairs(heroAbilities) do
        if kk~="Version" then
          --[[ print(kk,vv) ]]
          --[[ table.insert(self.abilities_KV,heroAbilities[kk]) ]]
          self.abilities_KV[kk]=vv
        end
      end
    end
    --[[ table.insert(self.abilities_KV, ]]
  end
  self.units_KV=LoadKeyValues("scripts/npc/npc_units.txt")
  self.items_KV=LoadKeyValues("scripts/npc/items.txt")
end

function DotaDB:RequestDB(uiEvent)
  local DBdata=DotaDB:GetAllAbilities()
  --DeepPrintTable(DBdata)
  CustomGameEventManager:Send_ServerToAllClients("dotadb_answer",{data=DBdata})
end

function DotaDB:GetAbilityKV(abilityName)
  return self.abilities_KV[abilityName]

end

function DotaDB:GetAllHeroes()
  local heroTable={}
  
  for k,v in pairs(self.heroes_KV) do
    --[[ print(k,v) ]]
    if k~="Version" and k~="npc_dota_hero_base" then
      table.insert(heroTable,k)
    end
  end
  return heroTable
end

function DotaDB:GetAllAbilities()
  local output={}
  for k,v in pairs(self.abilities_KV) do
    if k~="Version" and
    not string.find(k, "halloween") and
    not string.find(k, "seasonal") and
    not string.find(k, "greevil") and
    not string.find(k, "empty") and
    not string.find(k, "cny") and
    not string.find(k, "plus") then
      if v["AbilityType"]~="DOTA_ABILITY_TYPE_ATTRIBUTES" then
        if v["AbilityBehavior"]~=nil then
          

        end
        --output[k]=v
        table.insert(output,k)
      end
    end
  end
  return output
end

function DotaDB:GetHeroByAbility(ability_name)
  local hero = ""
  local heroTable = DotaDB:GetAllHeroes()

  for k, v in pairs(heroTable) do
      for kk, vv in pairs(self.heroes_KV[v]) do
          if kk:match("^Ability%d*$") and vv == ability_name then
              return v  -- Return the hero name if the ability is found
          end
      end
  end

  return hero
end

function DotaDB:test()
  print('dotadb test')
end

function dota_db_request( eventSourceIndex, args )
  print('dota_db_request called')
  DotaDB:RequestDB(args['uiEvent'])
end

CustomGameEventManager:RegisterListener( "dota_db_request", dota_db_request )