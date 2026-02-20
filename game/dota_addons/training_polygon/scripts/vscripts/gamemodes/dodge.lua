--TODO: make a separate tables for each type of dodge, for example: target spells for antimage counterspell
if dodge == nil then
  dodge = class({})
end


function dodge:Init()
    -- Each entry: {spell_name, hero_name, level, aghs, shard, is_ability, cast_func}
    -- Numeric keys allow addressing back from JS
    self.spellTable=
    { item_manta=
        {
        [1]={spell_name="lina_light_strike_array", hero_name="npc_dota_hero_lina", level=1, aghs=false, shard=false, is_ability=true, cast_func="lina_light_strike_array"},
        [2]={spell_name="kunkka_ghostship", hero_name="npc_dota_hero_kunkka", level=1, aghs=false, shard=false, is_ability=true, cast_func="basic_point_cast"},
        [3]={spell_name="lina_laguna_blade", hero_name="npc_dota_hero_lina", level=1, aghs=false, shard=false, is_ability=true, cast_func="lina_laguna_blade"},
        [4]={spell_name="bloodseeker_blood_bath", hero_name="npc_dota_hero_bloodseeker", level=1, aghs=false, shard=false, is_ability=true, cast_func="basic_point_cast"},
        [5]={spell_name="pugna_nether_blast", hero_name="npc_dota_hero_pugna", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [6]={spell_name="meepo_poof", hero_name="npc_dota_hero_meepo", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [7]={spell_name="necrolyte_death_pulse", hero_name="npc_dota_hero_necrolyte", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [8]={spell_name="mirana_starfall", hero_name="npc_dota_hero_mirana", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [9]={spell_name="nevermore_shadowraze2", hero_name="npc_dota_hero_nevermore", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [10]={spell_name="zuus_lightning_bolt", hero_name="npc_dota_hero_zuus", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [11]={spell_name="zuus_thundergods_wrath", hero_name="npc_dota_hero_zuus", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [12]={spell_name="tidehunter_anchor_smash", hero_name="npc_dota_hero_tidehunter", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [13]={spell_name="ursa_earthshock", hero_name="npc_dota_hero_ursa", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [14]={spell_name="omniknight_purification", hero_name="npc_dota_hero_omniknight", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [15]={spell_name="alchemist_unstable_concoction", hero_name="npc_dota_hero_alchemist", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [16]={spell_name="skywrath_mage_arcane_bolt", hero_name="npc_dota_hero_skywrath_mage", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [17]={spell_name="medusa_mystic_snake", hero_name="npc_dota_hero_medusa", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [18]={spell_name="medusa_stone_gaze", hero_name="npc_dota_hero_medusa", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [19]={spell_name="shadow_demon_demonic_purge", hero_name="npc_dota_hero_shadow_demon", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [20]={spell_name="earthshaker_fissure", hero_name="npc_dota_hero_earthshaker", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [21]={spell_name="earthshaker_enchant_totem", hero_name="npc_dota_hero_earthshaker", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [22]={spell_name="invoker_emp", hero_name="npc_dota_hero_invoker", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [23]={spell_name="obsidian_destroyer_sanity_eclipse", hero_name="npc_dota_hero_obsidian_destroyer", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [24]={spell_name="undying_decay", hero_name="npc_dota_hero_undying", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [25]={spell_name="elder_titan_echo_stomp", hero_name="npc_dota_hero_elder_titan", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [26]={spell_name="rattletrap_rocket_flare", hero_name="npc_dota_hero_rattletrap", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [27]={spell_name="rattletrap_hookshot", hero_name="npc_dota_hero_rattletrap", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [28]={spell_name="windrunner_powershot", hero_name="npc_dota_hero_windrunner", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [29]={spell_name="huskar_life_break", hero_name="npc_dota_hero_huskar", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [30]={spell_name="gyrocopter_homing_missile", hero_name="npc_dota_hero_gyrocopter", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [31]={spell_name="tiny_toss", hero_name="npc_dota_hero_tiny", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [32]={spell_name="phoenix_supernova", hero_name="npc_dota_hero_phoenix", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [33]={spell_name="legion_commander_overwhelming_odds", hero_name="npc_dota_hero_legion_commander", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [34]={spell_name="magnataur_reverse_polarity", hero_name="npc_dota_hero_magnataur", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [35]={spell_name="slardar_slithereen_crush", hero_name="npc_dota_hero_slardar", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [36]={spell_name="axe_berserkers_call", hero_name="npc_dota_hero_axe", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [37]={spell_name="brewmaster_thunder_clap", hero_name="npc_dota_hero_brewmaster", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [38]={spell_name="centaur_hoof_stomp", hero_name="npc_dota_hero_centaur", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [39]={spell_name="lion_finger_of_death", hero_name="npc_dota_hero_lion", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [40]={spell_name="queenofpain_scream_of_pain", hero_name="npc_dota_hero_queenofpain", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [41]={spell_name="visage_summon_familiars_stone_form", hero_name="npc_dota_visage_familiar1", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [42]={spell_name="polar_furbolg_ursa_warrior_thunder_clap", hero_name="npc_dota_neutral_polar_furbolg_ursa_warrior", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [43]={spell_name="centaur_khan_war_stomp", hero_name="npc_dota_neutral_centaur_khan", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [44]={spell_name="techies_suicide", hero_name="npc_dota_hero_techies", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [45]={spell_name="obsidian_destroyer_astral_imprisonment", hero_name="npc_dota_hero_obsidian_destroyer", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [46]={spell_name="roshan_slam", hero_name="npc_dota_roshan", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [47]={spell_name="invoker_sun_strike", hero_name="npc_dota_hero_invoker", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [48]={spell_name="kunkka_torrent", hero_name="npc_dota_hero_kunkka", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [49]={spell_name="kunkka_tidebringer", hero_name="npc_dota_hero_kunkka", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [50]={spell_name="elder_titan_earth_splitter", hero_name="npc_dota_hero_elder_titan", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [51]={spell_name="leshrac_split_earth", hero_name="npc_dota_hero_leshrac", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [52]={spell_name="warlock_rain_of_chaos", hero_name="npc_dota_hero_warlock", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [53]={spell_name="pangolier_shield_crash", hero_name="npc_dota_hero_pangolier", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [54]={spell_name="dark_willow_terrorize", hero_name="npc_dota_hero_dark_willow", level=1, aghs=false, shard=false, is_ability=true, cast_func="universal_cast"},
        [55]={spell_name="item_meteor_hammer", hero_name="npc_dota_hero_riki", level=1, aghs=false, shard=false, is_ability=false, cast_func="universal_cast"},
        }
    }
    -- Assign the reference of item_manta to other dodge types for now, in future we can make a different spell lists for different dodge types
    --TODO: add chaos knight and ringmaster
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
    self.mofifierTable = {
        item_manta = "modifier_invulnerable",
        ember_spirit_sleight_of_fist = "modifier_ember_spirit_sleight_of_fist_caster_invulnerability", --maybe "modifier_ember_spirit_sleight_of_fist_in_progress"
        puck_phase_shift = "modifier_puck_phase_shift",
        storm_spirit_ball_lightning = "modifier_storm_spirit_ball_lightning",
        bane_nightmare = "modifier_bane_nightmare_invulnerable",
        monkey_king_mischief = "modifier_monkey_king_transform",
        void_spirit_dissimilate = "modifier_void_spirit_dissimilate_phase",
        antimage_counterspell = "modifier_antimage_counterspell",
        riki_tricks_of_the_trade = "modifier_riki_tricks_of_the_trade_phase",
        nyx_assassin_spiked_carapace = "modifier_nyx_assassin_spiked_carapace",
    }
    self.dodgeWindowTime = {
        item_manta = 0.1,
        ember_spirit_sleight_of_fist = 0.25, --TODO: take values from KV
        puck_phase_shift = 1,
        storm_spirit_ball_lightning = 0, --configurable from ui
        bane_nightmare = 1,
        monkey_king_mischief = 0.1,
        void_spirit_dissimilate = 1.1,
        antimage_counterspell = 1.2,
        riki_tricks_of_the_trade = 2,
        nyx_assassin_spiked_carapace = 1.1,
    }
    self.dodgeCastPointTable = {
        item_manta = 0,
        ember_spirit_sleight_of_fist = 0, --TODO: take values from KV
        puck_phase_shift = 0,
        storm_spirit_ball_lightning = 0.3,
        bane_nightmare = 0.4,
        monkey_king_mischief = 0,
        void_spirit_dissimilate = 0.3,
        antimage_counterspell = 0,
        riki_tricks_of_the_trade = 0.3,
        nyx_assassin_spiked_carapace = 0,
    }
    self.type="sandbox" -- Define the type of mode
    self.name="dodge" -- Name of the gamemode
    self.activated=false -- Whether the mode is activated
    self.Player=nil -- Reference to the player
    self.playerHero=nil -- Reference to the player's hero
    self.trainingPlace=Vector(879.7060546875,4036.7941894531,128) -- Location for training
    self.castDelay=2 --delay between unit spawn and cast
    self.afterCastDelay=1.4 --delay between cast and unit removal
    self.currentEnemy=nil --variable to store enemy bot
    self.spellIndex=0
    self.currentDodgeType=nil
    --register listeners here
    CustomGameEventManager:RegisterListener("get_dodge_spell_table", function(_, event)
        dodge:SendSpellTable()
    end)
    CustomGameEventManager:RegisterListener("dodge_training_end", function(_, event)
        dodge:Deactivate()
    end)
    print('dodge inited')
    self.mantaEnt=nil
    self.dodgeAbilityEnt=nil
    self.dodgeModifier=""
    self.playerGotHurt=false
    self.playerHurtTime=0
    self.playerDodgeTime=0
    self.yashaKaya=false
    self.selectedSpells={}
    self.dodgeMoveSpeedModifier=-99
    self.timebarTiming=0
    self.timebarExtraTime=1
    self.yashaKayaModifier=0.75
    self.yashaKayaPlayer=false
    self.dodgeCastPoint=0
    self.debugTime=0
end

function dodge:Prepare(args)
    print("[Dodge] Preparing gamemode")
    precache:clearTable()

    local dodgeName = args.dodgeName or "item_manta"
    local selectedSpells = args.dodgeSpells or {}

    print("[Dodge] Dodge type: " .. dodgeName)

    -- Count selected spells (it's now an object/table with string keys)
    local spellCount = 0
    for _ in pairs(selectedSpells) do spellCount = spellCount + 1 end
    print("[Dodge] Selected spells count: " .. spellCount)

    local unitsToPrecache = {}
    local unitsAdded = {}

    -- Add player hero based on dodge type
    local playerHero = self.unitTable[dodgeName]
    if playerHero then
        unitsToPrecache[#unitsToPrecache + 1] = playerHero
        unitsAdded[playerHero] = true
        print("[Dodge] Adding player hero: " .. playerHero)
    end

    -- Add enemy caster heroes for selected spells
    -- selectedSpells is now a table with numeric keys matching spellTable indices
    -- Format: { [key] = { spell_name, hero_name, level, aghs, shard, is_ability }, ... }
    for key, spellInfo in pairs(selectedSpells) do
        if spellInfo and spellInfo.hero_name then
            local enemyHero = spellInfo.hero_name
            if enemyHero and enemyHero ~= "" and not unitsAdded[enemyHero] then
                unitsToPrecache[#unitsToPrecache + 1] = enemyHero
                unitsAdded[enemyHero] = true
                print("[Dodge] Adding enemy hero: " .. enemyHero)
            end
        end
        -- Log the full spell info for debugging
        -- key can be used to address self.spellTable[dodgeName][key]
        print("[Dodge] Key: " .. tostring(key) ..
              ", Spell: " .. (spellInfo.spell_name or "nil") ..
              ", hero: " .. (spellInfo.hero_name or "nil") ..
              ", level: " .. (spellInfo.level or "nil") ..
              ", aghs: " .. tostring(spellInfo.aghs) ..
              ", shard: " .. tostring(spellInfo.shard))
    end

    -- Add units to precache list
    if playerHero then
        precache:PrecacheAddPlayerUnitToList({playerHero})
    end

    local enemyUnits = {}
    for _, unit in ipairs(unitsToPrecache) do
        if unit ~= playerHero then
            enemyUnits[#enemyUnits + 1] = unit
        end
    end
    if #enemyUnits > 0 then
        precache:PrecacheAddUnitToList(enemyUnits)
    end

    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        dodge:StartGame(self.pendingArgs)
    end)
end

function dodge:lina_light_strike_array(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["light_strike_array_delay_time"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:Prepare(castPoint,self.timebarTiming,self.timebarExtraTime,self.dodgeCastPoint)
    self:doPointCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay)
end
function dodge:lina_laguna_blade(entry)
    local abilityName=entry.spell_name
    local abilityKV = DotaDB:GetAbilityKV(abilityName)
    local castPoint=parseQuadroValue(abilityKV["AbilityCastPoint"])
    local damageDelay=parseQuadroValue(abilityKV["AbilityValues"]["damage_delay"])
    if self.yashaKaya then
        castPoint=castPoint*self.yashaKayaModifier
    end
    castPoint=castPoint+damageDelay
    Timebar:Prepare(castPoint,self.timebarTiming,self.timebarExtraTime,self.dodgeCastPoint)
    self:doTargetCast(entry.hero_name,entry.spell_name,self.castDelay,self.afterCastDelay)
end
function dodge:doTargetCast(enemyName,enemySpell)
    --[[ print('do target cast:',enemyName,enemySpell) ]]
    local spawnpoint=randomCirclePositionVector(400,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		unit:UpgradeAbility(ability)
        
        local delay=self.castDelay+self:getRandomDelay()
        
        function tryToCast()
            unit:SetContextThink(DoUniqueString("try_cast_ability"),
                function()
                    --[[ print(self.playerHero:HasModifier(self.dodgeModifier),self.dodgeModifier) ]]
                    if ability:IsCooldownReady() and unit:GetSequence()=="idle_anim" and self.playerHero:IsUnselectable()==false then
                        --[[ print('trying to cast') ]]
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                            AbilityIndex = ability:entindex(),
                            TargetIndex = self.playerHero:entindex(),
                            Queue = 0
                        })
                    end
                    delay=0.15
                    if ability:IsCooldownReady()==false then
                        --go to unit removal
                        self.removeTimer=Timers:CreateTimer(dodge.afterCastDelay, function()
                            if IsValidEntity(unit) then
                                unit:RemoveSelf()
                            end
                            self:cycleEnemies()
                            return nil
                        end) 
                    else
                        tryToCast()
                    end

                    
                end,
            delay)
        end
        tryToCast()
        self.currentEnemy=unit
        return unit
    end)
end
function dodge:doPointCast(enemyName,enemySpell,preCastDelay,afterCastDelay)
    --[[ print('do point cast called:',enemyName,enemySpell) ]]
    local spawnpoint=randomCirclePositionVector(400,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		unit:UpgradeAbility(ability)
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ability:entindex(),
                    Position = self.playerHero:GetAbsOrigin(),
                    Queue = 0
                })
                self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
					if IsValidEntity(unit) then
                        unit:RemoveSelf()
                    end
                    self:cycleEnemies()
					return nil
				end)
                
            end,
        preCastDelay+self:getRandomDelay())
        self.currentEnemy=unit
        return unit
    end)
end

function dodge:getRandomDelay()
    local randomDelay=RandomFloat(0,0.5)
    return randomDelay
end

function dodge:StartGame(args)
    print("[Dodge] Starting game after precache")
    DeepPrintTable(args)
    self.activated = true
    self.yashaKaya=false
    if args['yashaKaya']==1 then
        self.yashaKaya=true
    else
        self.yashaKaya=false
    end
    if args['yashaKayaPlayer']==1 then
        self.yashaKayaPlayer=true
    else
        self.yashaKayaPlayer=false
    end
    
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    Timebar:Show()
    self.currentDodgeType=args['dodgeName']
    self.Player=PlayerResource:GetPlayer(0)
    local old_hero=self.Player:GetAssignedHero()
    local new_hero=self.unitTable[self.currentDodgeType]
    self.playerHero=replaceHero(old_hero,new_hero)
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    if self.currentDodgeType=="storm_spirit_ball_lightning" then
        
        self.playerHero:AddNewModifier(self.playerHero, nil, "modifier_custom_speed_boost", {})
        
        
    else
        self.playerHero:SetMoveCapability(0)
        
    end
    
    
    self.playerHero:SetAttackCapability(0)
    if self.currentDodgeType=="item_manta" then
        self.mantaEnt=CreateItem("item_manta",self.playerHero,self.playerHero)
        self.dodgeAbilityEnt=self.mantaEnt
        self.playerHero:AddItem(self.mantaEnt)
    else
        self.dodgeAbilityEnt=self.playerHero:FindAbilityByName(self.currentDodgeType)
        self.playerHero:UpgradeAbility(self.dodgeAbilityEnt)
        
    end
    self.stormFlyTime=tonumber(args['stormTime'])
    self.spellIndex=1
    self.firstCycle=true
    self.selectedSpells={}
    --[[ DeepPrintTable(args['dodgeSpells']) ]]
    for k,v in pairs(args['dodgeSpells']) do
        table.insert(self.selectedSpells,tonumber(k))
    end
    self.dodgeModifier=self.mofifierTable[self.currentDodgeType]
    self.dodgePressed=false
    self.playerDodgeTime=0
    self.playerGotHurt=false
    self.timebarTiming=self.dodgeWindowTime[self.currentDodgeType]
    self.dodgeCastPoint=self.dodgeCastPointTable[self.currentDodgeType]
    if self.currentDodgeType=="storm_spirit_ball_lightning" then
        self.timebarTiming=self.stormFlyTime
    end
    
    self:cycleEnemies()
end

function dodge:cycleEnemies()
    if self.activated==false then
        return
    end
    if self.firstCycle==false then
        self:checkResult()
    end
    DeepPrintTable(self.selectedSpells)
    local currentSpellIndex=self.selectedSpells[self.spellIndex]

    local entry = self.spellTable[self.currentDodgeType][currentSpellIndex]
    if self.spellIndex==#self.selectedSpells then
        self.spellIndex=1
    else
        self.spellIndex=self.spellIndex+1
    end
    refreshSkills(self.playerHero)
    refreshItems(self.playerHero)
    local manaMod=self.playerHero:FindModifierByName("modifier_set_max_mana")
    if manaMod then
        manaMod:SetStackCount(1000)
    end
    if entry.cast_func then
        self[entry.cast_func](self, entry)
        --[[ DeepPrintTable(entry) ]]
        
        
        
    end
    self.firstCycle=false
end
function dodge:checkResult()

    if self.playerGotHurt then
        --bad result
        Notifications:Show('red','bad','none')
    else
        --good result
        Notifications:Show('green','good','none')
    end
    self.playerGotHurt=false
    self.dodgePressed=false
end
function dodge:SendSpellTable()
    --[[ print(self.spellTable)
    DeepPrintTable(self.spellTable) ]]
    CustomGameEventManager:Send_ServerToAllClients("dodge_spell_table",{data=self.spellTable})
end
function dodge:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    if npc:IsIllusion() then
      Timers:CreateTimer({
        endTime = FrameTime(), 
        callback = function()
          npc:RemoveSelf()
        end
      })
    end
end

function dodge:OrderFilter(event)
    --lets fire timebar animations from catching orders from bots

    --[[ DeepPrintTable(event) ]]
    if event['issuer_player_id_const']==-1 then
        --bot order
        Timebar:Start()
    else
        --player order
        local ability=EntIndexToHScript(event['entindex_ability'])
        if ability==self.dodgeAbilityEnt then
            --player pressed dodge skill/item
            --if player pressed dodge ability while being stunned, game replicate order on stun end, so we make sure to catch first dodge press
            --reset checker in checkResult()
            if self.dodgePressed==false then
                self.dodgePressed=true
                print('manta pressed')
                Timebar:PlayerAction()
            end
        end
        if ability~=nil then
            if ability:GetAbilityName()=="storm_spirit_ball_lightning" then
                DeepPrintTable(event)
                --simulate short jump here, i tried mana manipulations but since most api calls for mana doesnt work, lets just modify orders
                local startPos=self.playerHero:GetAbsOrigin()
                local desiredPos=Vector(event['position_x'],event['position_y'],event['position_z'])
                local jumpDir=(desiredPos-startPos):Normalized()
                local jumpSpeed=1400
                local jumpLen=jumpSpeed*self.stormFlyTime
                local modifiedPos=startPos+jumpDir*jumpLen
                event['position_x']=modifiedPos.x
                event['position_y']=modifiedPos.y
                print(self.stormFlyTime)
            end
        end
    end
    return true
end

function dodge:ModifierGained(event)
    
    --[[ DeepPrintTable(event) ]]
    if event.name_const=="modifier_ember_spirit_sleight_of_fist_caster_invulnerability" then
        --[[ self.debugTime=Time()
        Timers(function()
            if self.playerHero:FindModifierByName("modifier_ember_spirit_sleight_of_fist_caster_invulnerability") then
                return FrameTime()
            else
                print('invul duration:',Time()-self.debugTime)
                return nil
            end

            
        end) ]]

    end
    if event.name_const=="modifier_stunned" then
        event.duration=0.2
        if self.currentDodgeType~="monkey_king_mischief" then
            if self.playerGotHurt==false then
                self.playerGotHurt=true
                print('player hurt by stun')
                self.playerHurtTime=Time()
                Timebar:BlueLine()
            end
        end
        --[[ DeepPrintDota(event) ]]
        return true
    end
    if event.name_const=="modifier_monkey_king_transform" then
        --[[ Timers:CreateTimer({
            endTime = 0.1, 
            callback = function()
                local npc=EntIndexToHScript(event.entindex_parent_const)
                npc:RemoveModifierByName("modifier_monkey_king_transform")
            end
        }) ]]
        
    end
    
end

function dodge:OnIllusionsCreated(keys)

end

function dodge:OnNonPlayerUsedAbility(keys)

end

function dodge:OnAbilityUsed(keys)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local abilityname = keys.abilityname
    print("abilityname",abilityname)
    if abilityname=="monkey_king_mischief" then
        refreshSkills(self.playerHero)
    end
end

function dodge:OnEntityHurt(keys)
    --[[ DeepPrintTable(keys) ]]
    local entCause=nil
    local entVictim=nil
    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        entCause = EntIndexToHScript(keys.entindex_attacker)
        entVictim = EntIndexToHScript(keys.entindex_killed)
    end
    if entVictim~=nil then
        if keys.damage~=0 and entVictim==self.playerHero then
            if self.playerGotHurt==false then
                self.playerGotHurt=true
                print('player hurt by damage')
                self.playerHurtTime=Time()
                Timebar:BlueLine()
            end
        end
    end
end

function dodge:Deactivate()
    self.activated=false
    CustomGameEventManager:Send_ServerToAllClients("clear_hud",{})
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu",{})
    Timebar:Hide()
    --[[ self.currentEnemy:RemoveSelf() ]] --do not do this, if we remove unit in middle of a cast, game would crash
end

dodge:Init()