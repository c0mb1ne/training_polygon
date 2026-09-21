--i'm making this to parse dota_abilities.txt KV file
--i wish it could be useful for getting spell values for dodge gamemode, because right now castpoints, projectile speed and other stuff are hardcoded and should be changed with patch changes
--in other hand abilities kv structure can be changed in any patch so idk what is more convenient
if DotaDB == nil then
  DotaDB = class({})
end

function DotaDB:Init()
  --[[ self.abilities_KV=LoadKeyValues("scripts/npc/npc_abilities.txt") ]]
  self.abilities_KV={}
  self.heroes_KV=LoadKeyValues("scripts/npc/npc_heroes.txt")
  local allHeroesTable=DotaDB:GetAllHeroes()
  --[[ DeepPrintTable(self.heroes_KV) ]]
  for hero_id,hero_name in pairs(allHeroesTable) do
    --[[ print('hero_id,hero_name',hero_id,hero_name) ]]
    for ability_name,ability_values in pairs(self.heroes_KV[hero_name]['AbilityDefinitions']) do
      self.abilities_KV[ability_name]=ability_values
    end
  end
  self.units_KV=LoadKeyValues("scripts/npc/npc_units.txt")
  self.items_KV=LoadKeyValues("scripts/npc/items.txt")

  CustomGameEventManager:RegisterListener("dotadb_get_hero_list", function(_, event)
    DotaDB:HeroListForPanorama()
  end)
  print("DotaDB inited")
end

function DotaDB:HeroListForPanorama(args)
  local heroList=self:GetAllHeroes()
  CustomGameEventManager:Send_ServerToAllClients("dotadb_get_hero_list_answer",{hero_list=heroList})
end

function DotaDB:GetAbilityKV(abilityName)
  return self.abilities_KV[abilityName]

end

function DotaDB:GetItemKV(abilityName)
  return self.items_KV[abilityName]
end
function DotaDB:GetHeroKV(heroName)
  return self.heroes_KV[heroName]
end

function DotaDB:GetAllHeroes()
  local heroTable={}
  
  for k,v in pairs(self.heroes_KV) do
    --[[ print(k,v) ]]
    if k~="Version" and k~="npc_dota_hero_base" and k~="npc_dota_hero_target_dummy" then
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


-- Safely walks a chain of keys in a KV table.
-- Usage: DotaDB:SafeGet(self.abilities_KV, {"kez_raptor_dance","AbilityValues","invuln_period"}, default)
function DotaDB:SafeGet(rootTable, pathKeys, default)
  local current = rootTable
  local pathSoFar = ""

  if current == nil then
    print("[DotaDB WARNING] SafeGet called with nil root table")
    return default
  end

  for i, key in ipairs(pathKeys) do
    pathSoFar = pathSoFar .. (i > 1 and "." or "") .. tostring(key)
    if current == nil then
      print(string.format("[DotaDB WARNING] KV path broken at '%s' (full path: %s) - Valve likely changed this KV. Using default: %s",
        pathSoFar, table.concat(pathKeys, "."), tostring(default)))
      return default
    end
    current = current[key]
  end

  if current == nil then
    print(string.format("[DotaDB WARNING] KV path '%s' resolved to nil - Valve likely changed this KV. Using default: %s",
      table.concat(pathKeys, "."), tostring(default)))
    return default
  end

  return current
end

function DotaDB:ParseKVValue(data,level)
  if data == nil then
    print("[parseQuadroValue WARNING] received nil data, returning nil")
    return nil
  end

  local value_count = level == nil and 1 or level
  local res_table = {}
  local start = 1

  for i = 1, string.len(data) do
    local symbol = string.sub(data, i, i)
    if symbol == " " then
      table.insert(res_table, tonumber(string.sub(data, start, i - 1)))
      start = i + 1
    end
  end
  table.insert(res_table, tonumber(string.sub(data, start, string.len(data))))

  if value_count == 'all' then
    return res_table
  else
    return res_table[value_count]
  end
end

function DotaDB:GetParsedValue(rootTable, pathKeys, default, level)
  

  local raw = self:SafeGet(rootTable, pathKeys, default)
  if default == nil then
    local pathStr = table.concat(pathKeys, ".")
    print(string.format("[DotaDB MISSING DEFAULT] No default set for path '%s' - fix this!", pathStr),raw)
  end
  return self:ParseKVValue(raw, level)
end
-- Thin wrappers so callers don't repeat the entity name in the path

function DotaDB:GetAbilityValue(abilityName, subPathKeys, default, level)
  local pathKeys = {abilityName}
  for _, key in ipairs(subPathKeys) do
    table.insert(pathKeys, key)
  end
  return self:GetParsedValue(self.abilities_KV, pathKeys, default, level)
end

function DotaDB:GetItemValue(itemName, subPathKeys, default, level)
  local pathKeys = {itemName}
  for _, key in ipairs(subPathKeys) do
    table.insert(pathKeys, key)
  end
  return self:GetParsedValue(self.items_KV, pathKeys, default, level)
end

function DotaDB:GetUnitValue(unitName, subPathKeys, default, level)
  local pathKeys = {unitName}
  for _, key in ipairs(subPathKeys) do
    table.insert(pathKeys, key)
  end
  return self:GetParsedValue(self.units_KV, pathKeys, default, level)
end
-- Convenience wrapper specifically for ability values
function DotaDB:GetAbilityValueSafe(abilityName, pathKeys, default)
  return self:SafeGet(self.abilities_KV, pathKeys, default)
end

DotaDB:Init()