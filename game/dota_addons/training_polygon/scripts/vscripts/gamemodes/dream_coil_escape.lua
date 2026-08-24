--TODO: describe what this gamemode does
if dream_coil_escape == nil then
  dream_coil_escape = class({})
end

function dream_coil_escape:Init()
    self.type = "sandbox" -- Define the type of mode
    self.name = "dream_coil_escape" -- Name of the gamemode (must match the key used to register it)
    self.activated = false -- Whether the mode is activated
    self.Player = nil -- Reference to the player
    self.playerHero = nil -- Reference to the player's hero
    self.trainingPlaceDefault = Vector(-2111.1826171875,-6378.5185546875,128) 
    self.trainingPlace = self.trainingPlaceDefault
    self.spellTable={
        item_manta={hero_name="from_js"},
        chaos_knight_phantasm={hero_name="npc_dota_hero_chaos_knight"}
    }

    -- Register listeners here
    --[[ CustomGameEventManager:RegisterListener("get_dream_coil_escape_respawn_pos", function(_, event)
        dream_coil_escape:SendRespawnPos()
    end)
    CustomGameEventManager:RegisterListener("dream_coil_escape_reset_respawn_pos", function(_, event)
        dream_coil_escape:ResetRespawn()
    end) ]]
    CustomGameEventManager:RegisterListener("dream_coil_escape_training_end", function(_, event)
        dream_coil_escape:PrepareDeactivate()
    end)

    CustomGameEventManager:RegisterListener("get_dream_coil_escape_spell_table", function(_, event)
        dream_coil_escape:SendSpellTable()
    end)

    self.deactivateCalled = false
    self.currentDodgeType=nil
    self.selectedEntry=nil
    self.playerHeroName=nil
    self.dreamCoilRange=parseQuadroValue(DotaDB:GetAbilityKV("puck_dream_coil")["AbilityCastRange"])
    self.breakRadius=parseQuadroValue(DotaDB:GetAbilityKV("puck_dream_coil")["AbilityValues"]["coil_break_radius"])
    self.rangeDeviation=0--when puck spawns and cast, how far cast will be from center
    self.timebarExtraDistance=100
    self.puckTimer=nil
    self.dodgeItem=nil
    self.dodgeSpell=nil
    self.breakModifier="modifier_puck_coil_break_stun"
    print('dream_coil_escape inited')
end

--[[ function dream_coil_escape:SendRespawnPos()
    CustomGameEventManager:Send_ServerToAllClients("dream_coil_escape_respawn_pos", {pos = {self.trainingPlace.x, self.trainingPlace.y, self.trainingPlace.z}})
end

function dream_coil_escape:ResetRespawn()
    self.trainingPlace = self.trainingPlaceDefault
    dream_coil_escape:SendRespawnPos()
end ]]

function dream_coil_escape:Prepare(args)
    print("[TemplateMode] Preparing gamemode")
    precache:clearTable()
    local timingType = args.timingType or "item_manta"
    local defaultHero = args.defaultHero or "npc_dota_hero_antimage"
    -- TODO: build the list of units this mode needs precached, based on args,
    -- following the unitsToPrecache/unitsAdded pattern from dodge.lua:Prepare()
    local unitsToPrecache = {
        "npc_dota_hero_puck"
    }
    
    if #unitsToPrecache > 0 then
        precache:PrecacheAddUnitToList(unitsToPrecache)
    end
    local entry=self.spellTable[timingType]
    if entry.hero_name=="from_js" then
        precache:PrecacheAddPlayerUnitToList({defaultHero})
    else
        precache:PrecacheAddPlayerUnitToList({entry.hero_name})
    end
    -- Store args for use after precaching
    self.pendingArgs = args

    -- Start precaching with callback to start the actual game
    precache:doPrecache(function()
        dream_coil_escape:StartGame(self.pendingArgs)
    end)
end

function dream_coil_escape:StartGame(args)
    -- TODO: spawn the player hero, position it at self.trainingPlace, set up the scenario
    CustomGameEventManager:Send_ServerToAllClients("load_hud",{name=self.name})
    self.activated = true
    self.currentDodgeType=args['timingType']
    self.selectedEntry=self.spellTable[self.currentDodgeType]
    self.Player=PlayerResource:GetPlayer(0)
    local old_hero=self.Player:GetAssignedHero()
    if self.selectedEntry.hero_name=="from_js" then
        self.playerHeroName=args['defaultHero']
    else
        self.playerHeroName=self.selectedEntry.hero_name
    end
    self.playerHero=replaceHero(old_hero,self.playerHeroName)
    self.playerHero:SetBaseHealthRegen(300)
    self.playerHero:SetBaseManaRegen(300)
    if self.currentDodgeType=="item_manta" then
        self.dodgeItem=CreateItem("item_manta",self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.dodgeItem)
    else
        self.dodgeSpell=self.playerHero:FindAbilityByName(self.currentDodgeType)
        self.dodgeSpell:SetLevel(1)
    end
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    self.puckTimer=Timers:CreateTimer(2,function()
        self:PuckAction()
        if self.activated then
            return 6
        else
            return nil
        end
    end)
    Timebar:Show()
end



function dream_coil_escape:PuckAction()
    if self.dodgeSpell~=nil then
        self.dodgeSpell:EndCooldown()
    end
    if self.dodgeItem~=nil then
        self.dodgeItem:EndCooldown()
    end
    --[[ local pointForCast=randomRingPosition(self.rangeDeviation,self.breakRadius-50,self.playerHero) ]]
    local pointForCast=randomRingPosition(0,0,self.playerHero)--TODO: add more variants of vectors generation
    local respawn_place = randomRingPositionVec(200,self.dreamCoilRange-100,pointForCast)
    
    local puck = CreateUnitByNameAsync("npc_dota_hero_puck", respawn_place, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
        unit:SetAttackCapability(0)
        unit:SetBaseManaRegen(100)
        unit:SetBaseHealthRegen(100)

        local ability = unit:FindAbilityByName("puck_dream_coil")
        ability:SetLevel(1)

        unit:SetContextThink(DoUniqueString("cast_ability"), function()
            if not ability:IsFullyCastable() then
                return 0.1 -- retry shortly if mana/cast point not ready
            end
            ExecuteOrderFromTable({
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                AbilityIndex = ability:entindex(),
                Position = pointForCast,
                Queue = false
            })
            self.removeTimer=Timers:CreateTimer(1.5, function()
                if IsValidEntity(unit) then
                    unit:RemoveSelf()
                end
                return nil
            end) 
            return nil -- cast once, stop thinking
        end, 0)

        return unit
    end)

    return puck
end

function dream_coil_escape:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    --[[ print("[DreamCoilEscape] npc spawned:",npc:GetUnitName()) ]]
    if npc:GetUnitName()=="npc_dota_thinker" then
        --start timebar here
        Timebar:PrepareDistance(self.breakRadius+self.timebarExtraDistance,npc,self.playerHero)
        Timebar:AddSingleMark(self.breakRadius+self.timebarExtraDistance,self.breakRadius,"#2100da","puck_dream_coil")
        Timebar:Start()
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

function dream_coil_escape:OrderFilter(event)
    -- TODO: return false to block specific player orders, true to allow
    if event['issuer_player_id_const']==-1 then
        --bot order
    else
        --player order
        local ability=EntIndexToHScript(event['entindex_ability'])
        if ability~=nil then
            if ability==self.dodgeSpell or ability==self.dodgeItem then
                Timebar:PlayerAction()
            end
        end
    end
    return true
end

function dream_coil_escape:ModifierGained(event)
    debugModifier(event)
    -- TODO: react to modifiers being applied (e.g. track dodge/invuln windows)
    return true
end

function dream_coil_escape:DamageFilter(event)
    -- TODO: return false to prevent specific damage instances, true to allow
    return true
end

function dream_coil_escape:OnAbilityUsed(keys)
    --[[ DeepPrintTable(keys) ]]
    -- TODO: react to abilities being cast
end

function dream_coil_escape:OnNonPlayerUsedAbility(keys)
    --[[ if keys.abilityname=="puck_dream_coil" then
    end ]]
    --DeepPrintTable(keys)
    -- TODO: react to abilities being cast
end

function dream_coil_escape:OnEntityHurt(keys)
    -- TODO: react to entities taking damage
end

function dream_coil_escape:SendSpellTable()
    -- TODO: send this mode's spell table to the client, if it has one, e.g.
    CustomGameEventManager:Send_ServerToAllClients("dream_coil_escape_spell_table", {data=self.spellTable})
end

function dream_coil_escape:PrepareDeactivate()
    self.deactivateCalled = true
    --[[ announcer:Show({message = "#waitingForCastEnd"}) ]]
    CustomGameEventManager:Send_ServerToAllClients("clear_hud", {})
    self:Deactivate()
end

function dream_coil_escape:Deactivate()
    self.activated = false
    self.deactivateCalled = false
    Timers:RemoveTimer(self.puckTimer)
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

dream_coil_escape:Init()
GamemodeManager:RegisterMode(dream_coil_escape.name, dream_coil_escape, dream_coil_escape.type)