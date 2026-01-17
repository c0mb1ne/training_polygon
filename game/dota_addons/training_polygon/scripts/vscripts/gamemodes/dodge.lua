if dodge == nil then
  dodge = class({})
end

function dodge:Init()
  self.type="sandbox" -- Define the type of mode
  self.name="dodge" -- Name of the gamemode
  self.activated=false -- Whether the mode is activated
  self.Player=nil -- Reference to the player
  self.playerHero=nil -- Reference to the player's hero
  self.trainingPlace=Vector(879.7060546875,4036.7941894531,128) -- Location for training
  -- Define a table of spells with their respective attributes
  -- 0=internal name, 1=hero_name, 2=level, 3=aghs, 4=shard, 5=type(true if ability)  self.spellTable=
  self.spellTable=
  { item_manta=
    {
      lina_light_strike_array={"npc_dota_hero_lina",1,false,false,true},
      kunkka_ghostship={"npc_dota_hero_kunkka",1,false,false,true},
      lina_laguna_blade={"npc_dota_hero_lina",1,false,false,true},
      bloodseeker_blood_bath={"npc_dota_hero_bloodseeker",1,false,false,true},
      pugna_nether_blast={"npc_dota_hero_pugna",1,false,false,true},
      meepo_poof={"npc_dota_hero_meepo",1,false,false,true},
      necrolyte_death_pulse={"npc_dota_hero_necrolyte",1,false,false,true},
      mirana_starfall={"npc_dota_hero_mirana",1,false,false,true},
      nevermore_shadowraze2={"npc_dota_hero_nevermore",1,false,false,true},
      zuus_lightning_bolt={"npc_dota_hero_zuus",1,false,false,true},
      zuus_thundergods_wrath={"npc_dota_hero_zuus",1,false,false,true},
      tidehunter_anchor_smash={"npc_dota_hero_tidehunter",1,false,false,true},
      ursa_earthshock={"npc_dota_hero_ursa",1,false,false,true},
      omniknight_purification={"npc_dota_hero_omniknight",1,false,false,true},
      alchemist_unstable_concoction={"npc_dota_hero_alchemist",1,false,false,true},
      skywrath_mage_arcane_bolt={"npc_dota_hero_skywrath_mage",1,false,false,true},
      medusa_mystic_snake={"npc_dota_hero_medusa",1,false,false,true},
      medusa_stone_gaze={"npc_dota_hero_medusa",1,false,false,true},
      shadow_demon_demonic_purge={"npc_dota_hero_shadow_demon",1,false,false,true},
      earthshaker_fissure={"npc_dota_hero_earthshaker",1,false,false,true},
      earthshaker_enchant_totem={"npc_dota_hero_earthshaker",1,false,false,true},
      invoker_emp={"npc_dota_hero_invoker",1,false,false,true},
      obsidian_destroyer_sanity_eclipse={"npc_dota_hero_obsidian_destroyer",1,false,false,true},
      undying_decay={"npc_dota_hero_undying",1,false,false,true},
      elder_titan_echo_stomp={"npc_dota_hero_elder_titan",1,false,false,true},
      rattletrap_rocket_flare={"npc_dota_hero_rattletrap",1,false,false,true},
      rattletrap_hookshot={"npc_dota_hero_rattletrap",1,false,false,true},
      windrunner_powershot={"npc_dota_hero_windrunner",1,false,false,true},
      huskar_life_break={"npc_dota_hero_huskar",1,false,false,true},
      gyrocopter_homing_missile={"npc_dota_hero_gyrocopter",1,false,false,true},
      tiny_toss={"npc_dota_hero_tiny",1,false,false,true},
      phoenix_supernova={"npc_dota_hero_phoenix",1,false,false,true},
      legion_commander_overwhelming_odds={"npc_dota_hero_legion_commander",1,false,false,true},
      magnataur_reverse_polarity={"npc_dota_hero_magnataur",1,false,false,true},
      slardar_slithereen_crush={"npc_dota_hero_slardar",1,false,false,true},
      axe_berserkers_call={"npc_dota_hero_axe",1,false,false,true},
      brewmaster_thunder_clap={"npc_dota_hero_brewmaster",1,false,false,true},
      centaur_hoof_stomp={"npc_dota_hero_centaur",1,false,false,true},
      lion_finger_of_death={"npc_dota_hero_lion",1,false,false,true},
      queenofpain_scream_of_pain={"npc_dota_hero_queenofpain",1,false,false,true},
      visage_summon_familiars_stone_form={"npc_dota_visage_familiar1",1,false,false,true},
      polar_furbolg_ursa_warrior_thunder_clap={"npc_dota_neutral_polar_furbolg_ursa_warrior",1,false,false,true},
      centaur_khan_war_stomp={"npc_dota_neutral_centaur_khan",1,false,false,true},
      techies_suicide={"npc_dota_hero_techies",1,false,false,true},
      obsidian_destroyer_astral_imprisonment={"npc_dota_hero_obsidian_destroyer",1,false,false,true},
      roshan_slam={"npc_dota_roshan",1,false,false,true},
      invoker_sun_strike={"npc_dota_hero_invoker",1,false,false,true},
      kunkka_torrent={"npc_dota_hero_kunkka",1,false,false,true},
      kunkka_tidebringer={"npc_dota_hero_kunkka",1,false,false,true},
      elder_titan_earth_splitter={"npc_dota_hero_elder_titan",1,false,false,true},
      leshrac_split_earth={"npc_dota_hero_leshrac",1,false,false,true},
      warlock_rain_of_chaos={"npc_dota_hero_warlock",1,false,false,true},
      pangolier_shield_crash={"npc_dota_hero_pangolier",1,false,false,true},
      dark_willow_terrorize={"npc_dota_hero_dark_willow",1,false,false,true},
      item_meteor_hammer={"npc_dota_hero_riki",1,false,false,false}
    },
    ember_spirit_sleight_of_fist=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    puck_phase_shift=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    storm_spirit_ball_lightning=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    bane_nightmare=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    monkey_king_mischief=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    void_spirit_dissimilate=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    antimage_counterspell=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    riki_tricks_of_the_trade=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    },
    nyx_assassin_spiked_carapace=
    {
      {"lina_light_strike_array","npc_dota_hero_lina",1,false,false,true},
      {"kunkka_ghostship","npc_dota_hero_kunkka",1,false,false,true},
      {"lina_laguna_blade","npc_dota_hero_lina",1,false,false,true},
      
    }
  }
  -- Assign the reference of item_manta to other elements
  self.spellTable.ember_spirit_sleight_of_fist = self.spellTable.item_manta
  self.spellTable.puck_phase_shift = self.spellTable.item_manta
  self.spellTable.storm_spirit_ball_lightning = self.spellTable.item_manta
  self.spellTable.bane_nightmare = self.spellTable.item_manta
  self.spellTable.monkey_king_mischief = self.spellTable.item_manta
  self.spellTable.void_spirit_dissimilate = self.spellTable.item_manta
  self.spellTable.antimage_counterspell = self.spellTable.item_manta
  self.spellTable.riki_tricks_of_the_trade = self.spellTable.item_manta
  self.spellTable.nyx_assassin_spiked_carapace = self.spellTable.item_manta
  -- Define a table mapping abilities to heroes
  self.unitTable = {
    item_manta = "npc_dota_hero_antimage",
    ember_spirit_sleight_of_fist = "npc_dota_hero_ember_spirit",
    puck_phase_shift = "npc_dota_hero_puck",
    storm_spirit_ball_lightning = "npc_dota_hero_storm_spirit",
    bane_nightmare = "npc_dota_hero_bane",
    monkey_king_mischief = "npc_dota_hero_monkey_king",
    void_spirit_dissimilate = "npc_dota_hero_void_spirit",
    antimage_counterspell = "npc_dota_hero_antimage",
    riki_tricks_of_the_trade = "npc_dota_hero_riki",
    nyx_assassin_spiked_carapace = "npc_dota_hero_nyx_assassin",
  }
  self.launchParams=nil -- Placeholder for launch parameters

end

-- Prepare function to set up the game state
function dodge:Prepare(params)
  self.Player=PlayerResource:GetPlayer(0) -- Get reference to player 0
  self.activated=true -- Activate the mode
  PrintTable(params) -- Debugging line to print parameters
  self.playerHero=self.Player:GetAssignedHero() -- Reference to the player's hero
  self.launchParams=params -- Set launch parameters
  for i=1,5 do
    -- Add heart items to increase the hero's survivability during training
    local item = CreateItem("item_heart",self.playerHero,self.playerHero)
    self.playerHero:AddItem(item)
  end
  
  local spellList = dodge.spellTable["item_manta"] -- List of spells
  local dodgeType=params.dodgeName -- Type of dodge

  if string.sub(dodgeType, 1, 4) == "item" then
    precache:PrecacheAddUnitList({self.unitTable[dodgeType]}) -- Precache units
    precache:PrecaheAddItemList({dodgeType}) -- Precache items
  else
    precache:PrecacheAddUnitList({self.unitTable[dodgeType]}) -- Precache units
  end
  
  local dodgeSpells=params.dodgeSpells -- Get spells to dodge
  for k,v in pairs(dodgeSpells) do
    print("dodge spells element") -- Debugging line
    print(v) -- Debugging line
    print(self.spellTable[v]) -- Debugging line
    precache:PrecacheAddUnitList({self.spellTable[dodgeType][v][1]}) -- Precache unit for spell
  end
  
  function onPrecacheComplete()
    -- Hide the main menu for all clients after precache is complete
    CustomGameEventManager:Send_ServerToAllClients("hide_main_menu", {})
    dodge:Start() -- Start the dodge mode
  end
  
  -- Call precache and pass in the callback function
  precache:doPrecache(onPrecacheComplete)
end

-- Function to start the dodge mode/game
function dodge:Start()
  print("Dodge started") -- Debugging line
  self.playerHero:SetAbsOrigin(self.trainingPlace) -- Move hero to training place
  dodge:castSpellOnHero("npc_dota_hero_lina", "lina_light_strike_array") -- Cast a spell on the hero
  self.playerHero:SetIdleAcquire(false) -- Prevent hero from acquiring targets
  CustomGameEventManager:Send_ServerToAllClients("set_camera_on_ent",{ent=self.playerHero:entindex()}) -- Set camera on hero
end

-- Function to end the dodge mode
function dodge:End()
  self.activated=false -- Deactivate the mode
end

-- Function to send the spell table to clients
function dodge:SendSpellTable()
  CustomGameEventManager:Send_ServerToAllClients("dodge_spell_table",{data=self.spellTable})
end

-- Callback function to handle sending the spell table
function GetSpellTable(eventSourceIndex, args)
  print('spell table sent') -- Debugging line
  dodge:SendSpellTable()
end

-- Register listener for getting the dodge spell table
CustomGameEventManager:RegisterListener( "get_dodge_spell_table", GetSpellTable )

-- Function to cast a spell on the hero
function dodge:castSpellOnHero(casterUnitName, abilityName)
  local targetHero = self.playerHero
  local targetHeroTeam = targetHero:GetTeam()
  local enemyTeam = (targetHeroTeam == DOTA_TEAM_GOODGUYS) and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
  local spawnLocation = targetHero:GetAbsOrigin() -- Or any location as required
  Timers:CreateTimer({
    endTime = 4, -- Delay before casting the ability
    callback = function()
      local caster = CreateUnitByNameAsync(casterUnitName, spawnLocation, true, nil, nil, enemyTeam, function(unit)
        unit:SetIdleAcquire(false) -- Disable auto targeting for caster unit
        unit:SetContextThink(DoUniqueString("cast_ability"),function()
          CastAbility(unit, abilityName, targetHero, 1) -- Cast ability on target hero
        end,
        3) -- Delay before ability casting
        unit:SetContextThink(DoUniqueString("Remove_Self"),function()  unit:RemoveSelf() end, 5) -- Remove caster after casting
        return unit
      end)
      return nil
    end
  })
end

-- Function to cast an ability with given parameters
function CastAbility(unit, abilityName, targetHero, level)
  local ability=unit:FindAbilityByName(abilityName) -- Find ability on unit
  local ability_kv = DotaDB:GetAbilityKV(abilityName) -- Get ability key-values
  if not ability_kv or not ability_kv["AbilityBehavior"] then
    print("Ability or its behavior not defined in KV for: " .. abilityName)
    return
  end
  if ability==nil then
    unit:AddAbility(abilityName)
    ability=unit:FindAbilityByName(abilityName)
  end
  ability:SetLevel(level)
  local behavior = ability_kv["AbilityBehavior"]

  if behavior:find("DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") then
    ExecuteOrderFromTable({
      UnitIndex = unit:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
      AbilityIndex = ability:entindex(),
      TargetIndex = hero:entindex(),
      Queue = 1
    })
  elseif behavior:find("DOTA_ABILITY_BEHAVIOR_POINT") then
    ExecuteOrderFromTable({
      UnitIndex = unit:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
      Position = targetHero:GetOrigin(),
      AbilityIndex = ability:entindex(),
      Queue = 1
    })
  elseif behavior:find("DOTA_ABILITY_BEHAVIOR_NO_TARGET") then
    ExecuteOrderFromTable({
      UnitIndex = unit:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
      AbilityIndex = ability:entindex(),
      Queue = 1
    })
  elseif behavior:find("DOTA_ABILITY_BEHAVIOR_SELF") then
    ExecuteOrderFromTable({
      UnitIndex = unit:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
      AbilityIndex = ability:entindex(),
      TargetIndex = unit:entindex(),
      Queue = 1
    })
  else
    print("Unsupported ability behavior for ability: " .. ability_name)
  end
  
  unit:SetIdleAcquire(false) -- Prevent unit from acquiring new targets automatically
end

-- Function called when an NPC is spawned in the game
function dodge:OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)
  if npc:IsIllusion() then
    Timers:CreateTimer({
      endTime = FrameTime(), -- Wait for one frame
      callback = function()
        npc:RemoveSelf() -- Remove the illusion
      end
    })
  end
end

-- Function to filter orders given by players
function dodge:OrderFilter(event)
  if event['entindex_ability']~=0 then
    local ability=EntIndexToHScript(event['entindex_ability'])
    local manta_skills={"item_manta","ember_spirit_sleight_of_fist","puck_phase_shift","storm_spirit_ball_lightning","bane_nightmare","naga_siren_mirror_image","monkey_king_mischief"}
    local abilityname=ability:GetAbilityName()
    local ability_found=0
    for k,v in pairs(manta_skills) do
      if v==abilityname then
        ability_found=1
      end
    end
    if ability_found==1 then -- PLAYER PRESSED MANTA
      MANTA_CASTED_TIME=Time()
      if MANTA_HERO_HURT==1 then
        -- Placeholder for further actions
      else
        -- Placeholder for further actions
      end
    end
  end
end

-- Function triggered when a modifier is gained by a unit
function dodge:ModifierGained(event)
  if event['name_const']=="modifier_warlock_golem_permanent_immolation_debuff" then
    return false -- Block this modifier
  end
  if event['name_const']=="modifier_medusa_stone_gaze_stone" then
    MANTA_MODIFIER_GAINED=Time() -- Record the time when this modifier is gained
  end
  if event['name_const']=="modifier_stunned" then
    MANTA_MODIFIER_GAINED=Time()
  end
  if event['name_const']=="modifier_axe_berserkers_call" then
    MANTA_MODIFIER_GAINED=Time()
  end
end

-- Function called when an ability is used by a player
function dodge:OnAbilityUsed(player,abilityname)
  if abilityname=="item_manta" then
    local hero = player:GetAssignedHero()
    Timers:CreateTimer(3, function()
      if not hero:IsNull() then
        refreshItems2(hero) -- Refresh hero items
        healHero(hero) -- Heal the hero
      end
    end)
  end
end

-- Function called when an entity gets hurt
function dodge:OnEntityHurt(entCause,entVictim,damagingAbility)
  if entVictim==active_hero then
    MANTA_HERO_HURT_TIME=Time() -- Record the time when the hero was hurt
  end
end