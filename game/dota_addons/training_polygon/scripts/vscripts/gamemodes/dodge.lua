--TODO: make a separate tables for each type of dodge, for example: target spells for antimage counterspell
if dodge == nil then
  dodge = class({})
end
require('gamemodes/dodge_skills')--setup for each skills here

function dodge:Init()
    -- Each entry: {spell_name, hero_name, level, aghs, shard, is_ability, cast_func}
    -- Numeric keys allow addressing back from JS
    self.spellTable=
    { item_manta=
        {
        [1]={spell_name="lina_light_strike_array", hero_name="npc_dota_hero_lina", cast_func="lina_light_strike_array", level=1, aghs=false, shard=false, is_ability=true},
        [2]={spell_name="kunkka_ghostship", hero_name="npc_dota_hero_kunkka", cast_func="kunkka_ghostship", level=1, aghs=false, shard=false, is_ability=true},
        [3]={spell_name="lina_laguna_blade", hero_name="npc_dota_hero_lina", cast_func="lina_laguna_blade", level=1, aghs=false, shard=false, is_ability=true},
        [4]={spell_name="bloodseeker_blood_bath", hero_name="npc_dota_hero_bloodseeker", cast_func="bloodseeker_blood_bath", level=1, aghs=false, shard=false, is_ability=true},
        [5]={spell_name="pugna_nether_blast", hero_name="npc_dota_hero_pugna", cast_func="pugna_nether_blast", level=1, aghs=false, shard=false, is_ability=true},
        [6]={spell_name="meepo_poof", hero_name="npc_dota_hero_meepo", cast_func="meepo_poof", level=1, aghs=false, shard=false, is_ability=true},
        [7]={spell_name="necrolyte_death_pulse", hero_name="npc_dota_hero_necrolyte", cast_func="necrolyte_death_pulse", level=1, aghs=false, shard=false, is_ability=true},
        --[[ [8]={spell_name="mirana_starfall", hero_name="npc_dota_hero_mirana", cast_func="mirana_starfall", level=1, aghs=false, shard=false, is_ability=true}, --not dodgable with manta, may be added to other tables]]
        [9]={spell_name="nevermore_shadowraze2", hero_name="npc_dota_hero_nevermore", cast_func="nevermore_shadowraze2", level=1, aghs=false, shard=false, is_ability=true},
        [10]={spell_name="zuus_lightning_bolt", hero_name="npc_dota_hero_zuus", cast_func="zuus_lightning_bolt", level=1, aghs=false, shard=false, is_ability=true},
        [11]={spell_name="zuus_thundergods_wrath", hero_name="npc_dota_hero_zuus", cast_func="zuus_thundergods_wrath", level=1, aghs=false, shard=false, is_ability=true},
        [12]={spell_name="tidehunter_anchor_smash", hero_name="npc_dota_hero_tidehunter", cast_func="tidehunter_anchor_smash", level=1, aghs=false, shard=false, is_ability=true},
        [13]={spell_name="ursa_earthshock", hero_name="npc_dota_hero_ursa", cast_func="ursa_earthshock", level=1, aghs=false, shard=false, is_ability=true},
        [14]={spell_name="omniknight_purification", hero_name="npc_dota_hero_omniknight", cast_func="omniknight_purification", level=1, aghs=false, shard=false, is_ability=true},
        [15]={spell_name="alchemist_unstable_concoction", hero_name="npc_dota_hero_alchemist", cast_func="alchemist_unstable_concoction", level=1, aghs=false, shard=false, is_ability=true},
        [16]={spell_name="skywrath_mage_arcane_bolt", hero_name="npc_dota_hero_skywrath_mage", cast_func="skywrath_mage_arcane_bolt", level=1, aghs=false, shard=false, is_ability=true},
        [17]={spell_name="medusa_mystic_snake", hero_name="npc_dota_hero_medusa", cast_func="medusa_mystic_snake", level=1, aghs=false, shard=false, is_ability=true},
        [18]={spell_name="medusa_stone_gaze", hero_name="npc_dota_hero_medusa", cast_func="medusa_stone_gaze", level=1, aghs=false, shard=false, is_ability=true},
        [19]={spell_name="shadow_demon_demonic_purge", hero_name="npc_dota_hero_shadow_demon", cast_func="shadow_demon_demonic_purge", level=1, aghs=false, shard=false, is_ability=true},
        [20]={spell_name="earthshaker_fissure", hero_name="npc_dota_hero_earthshaker", cast_func="earthshaker_fissure", level=1, aghs=false, shard=false, is_ability=true},
        [21]={spell_name="earthshaker_enchant_totem", hero_name="npc_dota_hero_earthshaker", cast_func="earthshaker_enchant_totem", level=1, aghs=false, shard=false, is_ability=true},
        [22]={spell_name="invoker_emp", hero_name="npc_dota_hero_invoker", cast_func="invoker_emp", level=1, aghs=false, shard=false, is_ability=true},
        [23]={spell_name="obsidian_destroyer_sanity_eclipse", hero_name="npc_dota_hero_obsidian_destroyer", cast_func="obsidian_destroyer_sanity_eclipse", level=1, aghs=false, shard=false, is_ability=true},
        [24]={spell_name="undying_decay", hero_name="npc_dota_hero_undying", cast_func="undying_decay", level=1, aghs=false, shard=false, is_ability=true},
        [25]={spell_name="elder_titan_echo_stomp", hero_name="npc_dota_hero_elder_titan", cast_func="elder_titan_echo_stomp", level=1, aghs=false, shard=false, is_ability=true},
        [26]={spell_name="rattletrap_rocket_flare", hero_name="npc_dota_hero_rattletrap", cast_func="rattletrap_rocket_flare", level=1, aghs=false, shard=false, is_ability=true},
        [27]={spell_name="rattletrap_hookshot", hero_name="npc_dota_hero_rattletrap", cast_func="rattletrap_hookshot", level=1, aghs=false, shard=false, is_ability=true},
        [28]={spell_name="rattletrap_hookshot", hero_name="npc_dota_hero_rattletrap", cast_func="rattletrap_hookshot", level=2, aghs=false, shard=false, is_ability=true},
        [29]={spell_name="rattletrap_hookshot", hero_name="npc_dota_hero_rattletrap", cast_func="rattletrap_hookshot", level=3, aghs=false, shard=false, is_ability=true},
        [30]={spell_name="windrunner_powershot", hero_name="npc_dota_hero_windrunner", cast_func="windrunner_powershot", level=1, aghs=false, shard=false, is_ability=true},
        [31]={spell_name="huskar_life_break", hero_name="npc_dota_hero_huskar", cast_func="huskar_life_break", level=1, aghs=false, shard=false, is_ability=true},
        [32]={spell_name="gyrocopter_homing_missile", hero_name="npc_dota_hero_gyrocopter", cast_func="gyrocopter_homing_missile", level=1, aghs=false, shard=false, is_ability=true},
        [33]={spell_name="tiny_toss", hero_name="npc_dota_hero_tiny", cast_func="tiny_toss", level=1, aghs=false, shard=false, is_ability=true},
        [34]={spell_name="phoenix_supernova", hero_name="npc_dota_hero_phoenix", cast_func="phoenix_supernova", level=1, aghs=false, shard=false, is_ability=true},
        [35]={spell_name="legion_commander_overwhelming_odds", hero_name="npc_dota_hero_legion_commander", cast_func="legion_commander_overwhelming_odds", level=1, aghs=false, shard=false, is_ability=true},
        [36]={spell_name="magnataur_reverse_polarity", hero_name="npc_dota_hero_magnataur", cast_func="magnataur_reverse_polarity", level=1, aghs=false, shard=false, is_ability=true},
        [37]={spell_name="slardar_slithereen_crush", hero_name="npc_dota_hero_slardar", cast_func="slardar_slithereen_crush", level=1, aghs=false, shard=false, is_ability=true},
        [38]={spell_name="axe_berserkers_call", hero_name="npc_dota_hero_axe", cast_func="axe_berserkers_call", level=1, aghs=false, shard=false, is_ability=true},
        [39]={spell_name="brewmaster_thunder_clap", hero_name="npc_dota_hero_brewmaster", cast_func="brewmaster_thunder_clap", level=1, aghs=false, shard=false, is_ability=true},
        [40]={spell_name="centaur_hoof_stomp", hero_name="npc_dota_hero_centaur", cast_func="centaur_hoof_stomp", level=1, aghs=false, shard=false, is_ability=true},
        [41]={spell_name="lion_finger_of_death", hero_name="npc_dota_hero_lion", cast_func="lion_finger_of_death", level=1, aghs=false, shard=false, is_ability=true},
        [42]={spell_name="queenofpain_scream_of_pain", hero_name="npc_dota_hero_queenofpain", cast_func="queenofpain_scream_of_pain", level=1, aghs=false, shard=false, is_ability=true},
        [43]={spell_name="visage_summon_familiars_stone_form", hero_name="npc_dota_visage_familiar1_custom", cast_func="visage_summon_familiars_stone_form", level=1, aghs=false, shard=false, is_ability=true},
        [44]={spell_name="polar_furbolg_ursa_warrior_thunder_clap", hero_name="npc_dota_neutral_polar_furbolg_ursa_warrior_custom", cast_func="polar_furbolg_ursa_warrior_thunder_clap", level=1, aghs=false, shard=false, is_ability=true},
        [45]={spell_name="centaur_khan_war_stomp", hero_name="npc_dota_neutral_centaur_khan_custom", cast_func="centaur_khan_war_stomp", level=1, aghs=false, shard=false, is_ability=true},
        [46]={spell_name="techies_suicide", hero_name="npc_dota_hero_techies", cast_func="techies_suicide", level=1, aghs=false, shard=false, is_ability=true},
        --[[ [47]={spell_name="obsidian_destroyer_astral_imprisonment", hero_name="npc_dota_hero_obsidian_destroyer", cast_func="obsidian_destroyer_astral_imprisonment", level=1, aghs=false, shard=false, is_ability=true},
        [48]={spell_name="obsidian_destroyer_astral_imprisonment", hero_name="npc_dota_hero_obsidian_destroyer", cast_func="obsidian_destroyer_astral_imprisonment", level=2, aghs=false, shard=false, is_ability=true},
        [49]={spell_name="obsidian_destroyer_astral_imprisonment", hero_name="npc_dota_hero_obsidian_destroyer", cast_func="obsidian_destroyer_astral_imprisonment", level=3, aghs=false, shard=false, is_ability=true},
        [50]={spell_name="obsidian_destroyer_astral_imprisonment", hero_name="npc_dota_hero_obsidian_destroyer", cast_func="obsidian_destroyer_astral_imprisonment", level=4, aghs=false, shard=false, is_ability=true}, --not doing aoe damage anymore]]
        [51]={spell_name="roshan_slam", hero_name="npc_dota_roshan_custom", cast_func="roshan_slam", level=1, aghs=false, shard=false, is_ability=true},
        [52]={spell_name="invoker_sun_strike", hero_name="npc_dota_hero_invoker", cast_func="invoker_sun_strike", level=1, aghs=false, shard=false, is_ability=true},
        [53]={spell_name="kunkka_torrent", hero_name="npc_dota_hero_kunkka", cast_func="kunkka_torrent", level=1, aghs=false, shard=false, is_ability=true},
        --[[ [54]={spell_name="kunkka_tidebringer", hero_name="npc_dota_hero_kunkka", cast_func="universal_cast", level=1, aghs=false, shard=false, is_ability=true}, -- i dont like the fact that it have different experience on different attack speed of kunkka so i dont sure it should be here ]]
        [55]={spell_name="elder_titan_earth_splitter", hero_name="npc_dota_hero_elder_titan", cast_func="elder_titan_earth_splitter", level=1, aghs=false, shard=false, is_ability=true},
        [56]={spell_name="leshrac_split_earth", hero_name="npc_dota_hero_leshrac", cast_func="leshrac_split_earth", level=1, aghs=false, shard=false, is_ability=true},
        [57]={spell_name="warlock_rain_of_chaos", hero_name="npc_dota_hero_warlock", cast_func="warlock_rain_of_chaos", level=1, aghs=false, shard=false, is_ability=true},
        [58]={spell_name="pangolier_shield_crash", hero_name="npc_dota_hero_pangolier", cast_func="pangolier_shield_crash", level=1, aghs=false, shard=false, is_ability=true},
        [59]={spell_name="dark_willow_terrorize", hero_name="npc_dota_hero_dark_willow", cast_func="dark_willow_terrorize", level=1, aghs=false, shard=false, is_ability=true},
        [60]={spell_name="item_meteor_hammer", hero_name="npc_dota_hero_riki", cast_func="item_meteor_hammer", level=1, aghs=false, shard=false, is_ability=false},
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
    self.spellTable.kez_raptor_dance = self.spellTable.item_manta
    self.spellTable.chaos_knight_phantasm = self.spellTable.item_manta
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
        kez_raptor_dance = "npc_dota_hero_kez",
        chaos_knight_phantasm = "npc_dota_hero_chaos_knight",
    }
    self.modifierTable = { --not used anywhere btw
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
        kez_raptor_dance = "modifier_kez_raptor_dance_immune",
        chaos_knight_phantasm = "npc_dota_hero_chaos_knight",
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
        kez_raptor_dance = DotaDB:GetAbilityValue("kez_raptor_dance", {"AbilityValues","invuln_period"}, "0.2"),
        chaos_knight_phantasm = DotaDB:GetAbilityValue("chaos_knight_phantasm", {"AbilityValues","invuln_duration"}, "0.5")
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
        kez_raptor_dance = 0,--has cast point, but invul starts as soon as ability used
        chaos_knight_phantasm = DotaDB:GetAbilityValue("chaos_knight_phantasm", {"AbilityCastPoint"}, "0.4 0.4 0.4")
    }
    self.hurtModifiers={
        "modifier_stunned",
        "modifier_medusa_stone_gaze_stone",
        "modifier_axe_berserkers_call",
        "modifier_kunkka_torrent",
        "modifier_dark_willow_debuff_fear"
    }
    self.type="sandbox" -- Define the type of mode
    self.name="dodge" -- Name of the gamemode
    self.activated=false -- Whether the mode is activated
    self.Player=nil -- Reference to the player
    self.playerHero=nil -- Reference to the player's hero
    self.trainingPlaceDefault=Vector(-6020.6640625,4100.78564453125,128)-- Location for training
    self.trainingPlace=self.trainingPlaceDefault
    self.castDelay=2 --delay between unit spawn and cast
    self.afterCastDelay=1 --delay between cast and unit removal
    self.currentEnemy=nil --variable to store enemy bot
    self.spellIndex=0
    self.currentDodgeType=nil
    --register listeners here
    CustomGameEventManager:RegisterListener("get_dodge_spell_table", function(_, event)
        dodge:SendSpellTable()
    end)
    CustomGameEventManager:RegisterListener("get_dodge_respawn_pos", function(_, event)
        dodge:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("dodge_reset_respawn_pos", function(_, event)
        dodge:ResetRespawn()
    end)
    CustomGameEventManager:RegisterListener("dodge_training_end", function(_, event)
        dodge:PrepareDeactivate()
    end)
    self.mantaEnt=nil
    self.dodgeAbilityEnt=nil
    self.dodgeModifier=""
    self.playerGotHurt=false
    self.playerHurtTime=0
    self.playerDodgeTime=0
    self.yashaKaya=false
    self.selectedSpells={}
    self.dodgeMoveSpeedModifier=-99
    self.dodgeDuration=0
    self.timebarExtraTime=1
    self.yashaKayaModifier=0.75
    self.yashaKayaPlayer=false
    self.dodgeCastPoint=0
    self.debugTime=0
    self.currentAbilityName=""
    self.deactivateCalled=false
    self.hardcoreMode=false
    self.fakeCastModeOn=false--planned to make bots cancel cast animations 0-3 times randomly, but complicated thing to do, i will never finish refactoring if i go into that
    self.respawnOffset=50
    self.blinkRange=1000
    self.currentAbilityLevel=0
    self.treeCutTimer=nil
    self.helperForEmber=nil
    print('dodge inited')
end

function dodge:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("dodge_respawn_pos",{pos={self.trainingPlace.x,self.trainingPlace.y,self.trainingPlace.z}})
end
function dodge:ResetRespawn()
    self.trainingPlace=self.trainingPlaceDefault
    CustomGameEventManager:Send_ServerToAllClients("dodge_respawn_pos",{pos={self.trainingPlace.x,self.trainingPlace.y,self.trainingPlace.z}})
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
    if dodgeName=="item_manta" then
        playerHero=args.selectedHero
    end
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
                -- Exception: Visage familiar requires the main Visage hero to be precached
                if enemyHero == "npc_dota_visage_familiar1_custom" and not unitsAdded["npc_dota_hero_visage"] then
                    unitsToPrecache[#unitsToPrecache + 1] = "npc_dota_hero_visage"
                    unitsAdded["npc_dota_hero_visage"] = true
                    print("[Dodge] Adding Visage hero for familiar precache exception")
                end
            end
        end
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
function dodge:doTargetCast(enemyName,enemySpell,preCastDelay,afterCastDelay,spawnRange)
    --[[ print('do target cast:',enemyName,enemySpell) ]]
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		unit:UpgradeAbility(ability)
         local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        local delay=preCastDelay+self:getRandomDelay()
        local blinkCasted=false
        function tryToCast()
            unit:SetContextThink(DoUniqueString("try_cast_ability"),
                function()
                    if self.hardcoreMode and blinkCasted==false then
                        local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                            AbilityIndex = blink:entindex(),
                            Position = self.playerHero:GetAbsOrigin(),
                            Queue = 0
                        })
                        blinkCasted=true
                    end
                    --[[ print(self.playerHero:HasModifier(self.dodgeModifier),self.dodgeModifier) ]]
                    --[[ print(ability:IsCooldownReady(),unit:GetSequence(),self.playerHero:IsUnselectable(),ability:IsInAbilityPhase()) ]]
                    if ability:IsCooldownReady() and self.playerHero:IsUnselectable()==false and ability:IsInAbilityPhase()==false then
                        --[[ print('trying to cast') ]]
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                            AbilityIndex = ability:entindex(),
                            TargetIndex = self.playerHero:entindex(),
                            Queue = 1
                        })
                    end
                    delay=0.15
                    if ability:IsCooldownReady()==false then
                        --go to unit removal
                        self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
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
function dodge:doCast(enemyName,enemySpell,preCastDelay,afterCastDelay,spawnRange,abilityType)-- tried to make a universal method, but dont work properly with kunkka ghosthip, so maybe someone will finish it
    --[[ print('do target cast:',enemyName,enemySpell) ]]
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		unit:UpgradeAbility(ability)
         local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        local delay=preCastDelay+self:getRandomDelay()
        local blinkCasted=false
        function tryToCast()
            unit:SetContextThink(DoUniqueString("try_cast_ability"),
                function()
                    if self.hardcoreMode and blinkCasted==false then
                        local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                            AbilityIndex = blink:entindex(),
                            Position = self.playerHero:GetAbsOrigin(),
                            Queue = 0
                        })
                        blinkCasted=true
                    end
                    --[[ print(self.playerHero:HasModifier(self.dodgeModifier),self.dodgeModifier) ]]
                    if ability:IsCooldownReady() and unit:GetSequence()=="idle_anim" and self.playerHero:IsUnselectable()==false then
                        --[[ print('trying to cast') ]]
                        if abilityType=="target" then
                            ExecuteOrderFromTable({
                                UnitIndex = unit:entindex(),
                                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                                AbilityIndex = ability:entindex(),
                                TargetIndex = self.playerHero:entindex(),
                                Queue = 1
                            })
                        elseif abilityType=="point" then
                            ExecuteOrderFromTable({
                                UnitIndex = unit:entindex(),
                                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                                AbilityIndex = ability:entindex(),
                                Position = self.playerHero:GetAbsOrigin(),
                                Queue = 1
                            })
                        elseif abilityType=="notarget" then

                        end
                    end
                    delay=0.15
                    if ability:IsCooldownReady()==false then
                        --go to unit removal
                        self.removeTimer=Timers:CreateTimer(afterCastDelay, function()
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
function dodge:doPointCast(enemyName,enemySpell,preCastDelay,afterCastDelay,spawnRange)
    --[[ print('do point cast called:',enemyName,enemySpell) ]]
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
        ability:SetLevel(self.currentAbilityLevel)
		--[[ unit:UpgradeAbility(ability) ]]
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ability:entindex(),
                    Position = self.playerHero:GetAbsOrigin(),
                    Queue = 1
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
function dodge:doNoTargetCast(enemyName,enemySpell,preCastDelay,afterCastDelay,spawnRange)
    --[[ print('do point cast called:',enemyName,enemySpell) ]]
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		ability:SetLevel(1)
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        if enemyName=="npc_dota_hero_earthshaker" then 
            local passive=unit:FindAbilityByName("earthshaker_aftershock")
            unit:UpgradeAbility(passive)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = ability:entindex(),
                    Queue = 1
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
function dodge:doSelfCast(enemyName,enemySpell,preCastDelay,afterCastDelay,spawnRange)
    --[[ print('do point cast called:',enemyName,enemySpell) ]]
    if self.hardcoreMode then
        spawnRange=spawnRange+self.blinkRange
    end
    local spawnpoint=randomCirclePositionVector(spawnRange-self.respawnOffset,self.playerHero:GetAbsOrigin())
    self.currentEnemy=CreateUnitByNameAsync(enemyName,spawnpoint,true,nil,nil,DOTA_TEAM_BADGUYS,function(unit)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - spawnpoint):Normalized())
		local ability = unit:FindAbilityByName(enemySpell)
		unit:SetAttackCapability(0)
		ability:SetLevel(self.currentAbilityLevel)
        local blink=nil
        if self.hardcoreMode then
            blink=CreateItem("item_blink",unit,unit)
            unit:AddItem(blink)
        end
        if self.yashaKaya then
            local yashaKaya=CreateItem("item_yasha_and_kaya",unit,unit)
            unit:AddItem(yashaKaya)
        end
        unit:SetContextThink(DoUniqueString("cast_ability"),
            function()
                if self.hardcoreMode then
                    local blinkPoint=(self.playerHero:GetAbsOrigin() - spawnpoint):Normalized()*self.blinkRange
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                        AbilityIndex = blink:entindex(),
                        Position = self.playerHero:GetAbsOrigin(),
                        Queue = 0
                    })
                end
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = ability:entindex(),
                    TargetIndex = unit:entindex(),
                    Queue = 1
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
    --[[ DeepPrintTable(args) ]]
    self.activated = true
    self.yashaKaya=false
    if args['yashaKaya']==1 then
        self.yashaKaya=true
    else
        self.yashaKaya=false
    end
    self.yashaKayaPlayer=false
    if args['yashaKayaPlayer']==1 then
        self.yashaKayaPlayer=true
    else
        self.yashaKayaPlayer=false
    end
    self.hardcoreMode=false
    if args['hardcoreMode']==1 then
        self.hardcoreMode=true
    else
        self.hardcoreMode=false
    end
    
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    
    self.currentDodgeType=args['dodgeName']
    if self.currentDodgeType=="kez_raptor_dance" then
        self.afterCastDelay=3
    else
        self.afterCastDelay=1
    end
    self.Player=PlayerResource:GetPlayer(0)
    local old_hero=self.Player:GetAssignedHero()
    local new_hero=self.unitTable[self.currentDodgeType]
    if self.currentDodgeType=="item_manta" then
        new_hero=args['selectedHero']
    end
    self.playerHero=replaceHero(old_hero,new_hero)
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    --[[ print("repawnPos:")
    DeepPrintTable(args.respawnPos) ]]
    local pos = args.respawnPos
    self.trainingPlace = Vector(
        tonumber(pos["0"]),
        tonumber(pos["1"]),
        tonumber(pos["2"])
    )
    --[[ print(self.trainingPlace) ]]
    self.treeCutTimer=Timers:CreateTimer(0, function()
        if args['destroyTrees']==1 then
            GridNav:DestroyTreesAroundPoint(self.trainingPlace, 1500, true)
        end
        return 4
    end)
    
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    if self.hardcoreMode then
        self.playerHero:SetDayTimeVisionRange(675)
    else
        Timebar:Show()
    end
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
    if self.yashaKayaPlayer then
        local yashaKaya=CreateItem("item_yasha_and_kaya",self.playerHero,self.playerHero)
        self.playerHero:AddItem(yashaKaya)
    end
    self.stormFlyTime=tonumber(args['stormTime'])
    self.spellIndex=1
    self.firstCycle=true
    self.selectedSpells={}
    --[[ DeepPrintTable(args['dodgeSpells']) ]]
    for k,v in pairs(args['dodgeSpells']) do
        table.insert(self.selectedSpells,tonumber(k))
    end
    self.dodgeModifier=self.modifierTable[self.currentDodgeType]
    self.dodgePressed=false
    self.playerDodgeTime=0
    self.playerGotHurt=false
    self.dodgeDuration=self.dodgeWindowTime[self.currentDodgeType]
    self.dodgeCastPoint=self.dodgeCastPointTable[self.currentDodgeType]
    if self.yashaKayaPlayer then
        self.dodgeCastPoint=self.dodgeCastPoint*self.yashaKayaModifier
    end
    if self.currentDodgeType=="storm_spirit_ball_lightning" then
        self.dodgeDuration=self.stormFlyTime
    end
    if self.currentDodgeType=="ember_spirit_sleight_of_fist" then
        self.helperForEmber=CreateUnitByName("npc_dota_neutral_centaur_khan_custom",self.trainingPlace+Vector(100,0,0),true,self.playerHero,self.playerHero,DOTA_TEAM_BADGUYS)
        self.helperForEmber:SetIdleAcquire(false)
        self.helperForEmber:Stop()
        self.helperForEmber:SetControllableByAllPlayers(true)
        self.helperForEmber:SetBaseHealthRegen(100)
    end
    self:cycleEnemies()
end

function dodge:cycleEnemies()
    if self.deactivateCalled==true then
        self:Deactivate()
    end
    if self.activated==false then
        return
    end
    if self.firstCycle==false then
        self:checkResult()
    end
    --[[ DeepPrintTable(self.selectedSpells) ]]
    local currentSpellIndex=self.selectedSpells[self.spellIndex]

    local entry = self.spellTable[self.currentDodgeType][currentSpellIndex]
    self.currentAbilityName=entry.spell_name
    self.currentAbilityLevel=entry.level
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
    print("[Dodge] Trying to cast:",entry.spell_name)
    if entry.cast_func then
        self[entry.cast_func](self, entry)
        --[[ DeepPrintTable(entry) ]]
    end
    self.firstCycle=false
end
function dodge:checkResult()
    
    if self.playerGotHurt then
        --bad result
        if self.dodgePressed then
            local delay=self.playerDodgeTime-self.playerHurtTime
            delay=math.floor(delay*1000)/1000
            Notifications:Show('red','bad, delay:'..delay,self.currentAbilityName)
        else
            Notifications:Show('red','bad',self.currentAbilityName)
        end
    else
        --good result
        Notifications:Show('green','good',self.currentAbilityName)
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
    if npc:GetUnitName()=="npc_dota_warlock_golem" then
        npc:SetAttackCapability(0)
        
        Timers:CreateTimer({
        endTime = FrameTime(),
        callback = function()
            npc:RemoveSelf()
        end
        })
    end
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
    --lets fire timebar animations by catching orders from bots

    --[[ DeepPrintTable(event) ]]
    if event['issuer_player_id_const']==-1 then
        --bot order
        if event['order_type']~=1 then
            if event['entindex_ability']~=0 then
                local ability=EntIndexToHScript(event['entindex_ability'])
                if ability~=nil then
                    --[[ print(ability) ]]
                    if ability:GetAbilityName()=="alchemist_unstable_concoction_throw" then
                        --do nothing
                    else
                        Timebar:Start()
                        --[[ print('starting timebar') ]]
                    end
                end
            end
        end
    else
        --player order
        local ability=EntIndexToHScript(event['entindex_ability'])
        if ability==self.dodgeAbilityEnt then
            --player pressed dodge skill/item
            --if player pressed dodge ability while being stunned, game replicate order on stun end, so we make sure to catch first dodge press
            --reset checker in checkResult()
            if self.dodgePressed==false then
                self.dodgePressed=true
                self.playerDodgeTime=Time()
                print('manta pressed')
                Timebar:PlayerAction()
            end
        end
        if ability~=nil then
            if ability:GetAbilityName()=="storm_spirit_ball_lightning" then
                --[[ DeepPrintTable(event) ]]
                --simulate short jump here, i tried mana manipulations but since most api calls for mana doesnt work, lets just modify orders
                local startPos=self.playerHero:GetAbsOrigin()
                local desiredPos=Vector(event['position_x'],event['position_y'],event['position_z'])
                local jumpDir=(desiredPos-startPos):Normalized()
                local jumpSpeed=1400
                local jumpLen=jumpSpeed*self.stormFlyTime
                local modifiedPos=startPos+jumpDir*jumpLen
                event['position_x']=modifiedPos.x
                event['position_y']=modifiedPos.y
                --[[ print(self.stormFlyTime) ]]
            end
        end
    end
    return true
end

function dodge:ModifierGained(event)
    --[[ debugModifier(event) ]]
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
    if string_in_array(event.name_const,self.hurtModifiers) then
        event.duration=0.2
        if self.currentDodgeType~="monkey_king_mischief" then
            if self.playerGotHurt==false then
                self.playerGotHurt=true
                --[[ print('player hurt by stun') ]]
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
    return true
end

function dodge:OnIllusionsCreated(keys)

end

function dodge:OnNonPlayerUsedAbility(keys)

end
function dodge:DamageFilter(event)
    --[[ DeepPrintTable(event) ]]
    local damager=nil
    if event.entindex_attacker_const then
        damager=EntIndexToHScript(event.entindex_attacker_const)
    end
    local damager_name
    if damager~=nil then
        --[[ print(damager:GetUnitName()) ]]
        if damager:GetUnitName()=="npc_dota_hero_phoenix" then
            --checking for dodging stun only
            return false
        end
        if damager:GetUnitName()=="npc_dota_hero_kunkka" then
            --checking for dodging stun only
            return false
        end
        if damager==self.playerHero then
            --preventing from accidentally kill enemy (kez hits hard)
            return false
        end
    end
    return true
end
function dodge:OnAbilityUsed(keys)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local abilityname = keys.abilityname
    --[[ print("abilityname",abilityname) ]]
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
                --[[ print('player hurt by damage') ]]
                self.playerHurtTime=Time()
                Timebar:BlueLine()
            end
        end
    end
end

function dodge:PrepareDeactivate()
    self.deactivateCalled=true
    announcer:Show({message="#waitingForCastEnd"})
    CustomGameEventManager:Send_ServerToAllClients("clear_hud",{})
end

function dodge:Deactivate()
    Timebar:ResetLines()
    self.activated=false
    self.deactivateCalled=false
    self.playerHero:SetDayTimeVisionRange(2000)
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu",{})
    GridNav:RegrowAllTrees()
    Timers:RemoveTimer(self.treeCutTimer)
    if self.helperForEmber~=nil then
        self.helperForEmber:RemoveSelf()
        self.helperForEmber=nil
    end
    announcer:Hide()
    --[[ self.currentEnemy:RemoveSelf() ]] --do not do this, if we remove unit in middle of a cast, game would crash
end

dodge:Init()
GamemodeManager:RegisterMode(dodge.name,dodge,dodge.type)