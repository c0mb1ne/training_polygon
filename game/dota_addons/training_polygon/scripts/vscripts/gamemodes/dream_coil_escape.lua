--TODO: 
--change particle color depends on distance
--if player dodge coil placement, cycle of puck respawns breaks, need to add some timer checker
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
        item_manta={hero_name="from_js",invulModifier="modifier_manta_phase"},
        --[[ chaos_knight_phantasm={hero_name="npc_dota_hero_chaos_knight"}, ]]
        --[[ kez_echo_slash={hero_name="npc_dota_hero_kez"}, ]]
        --[[ naga_siren_mirror_image={hero_name="npc_dota_hero_naga_siren"}, ]]
        item_cyclone={hero_name="from_js",invulModifier="modifier_eul_cyclone"}
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
    CustomGameEventManager:RegisterListener("dream_coil_escape_ms_change", function(eventSourceIndex, args)
        dream_coil_escape:MoveSpeedChange(args)
    end)
    self.deactivateCalled = false
    self.currentDodgeType=nil
    self.selectedEntry=nil
    self.playerHeroName=nil
    self.dreamCoilRange=parseQuadroValue(DotaDB:GetAbilityKV("puck_dream_coil")["AbilityCastRange"])
    self.dreamCoilDuration=parseQuadroValue(DotaDB:GetAbilityKV("puck_dream_coil")["AbilityValues"]["coil_duration"],3)
    self.breakRadius=parseQuadroValue(DotaDB:GetAbilityKV("puck_dream_coil")["AbilityValues"]["coil_break_radius"])
    self.rangeDeviation=0--when puck spawns and cast, how far cast will be from center
    self.timebarExtraDistance=100
    self.puckTimer=nil
    self.dodgeItem=nil
    self.dodgeSpell=nil
    self.breakModifier="modifier_puck_coil_break_stun" --applied when player break coil
    self.coilModifier="modifier_puck_coiled" --applied when player got root
    self.coilRangeDisplay=true
    self.forceStaffEnabled=false
    self.forceStaffEnt=nil
    self.playerSpeedModifier=nil
    self.coilDone={}
    self.coilInvulPressed={}
    self.timeBetweenCoils=0
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
    if self.currentDodgeType=="item_manta" or self.currentDodgeType=="item_cyclone" then
        self.dodgeItem=CreateItem(self.currentDodgeType,self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.dodgeItem)
        --[[ self.forceStaffEnt=CreateItem("item_force_staff",self.playerHero,self.playerHero)
        self.playerHero:AddItem(self.forceStaffEnt)--seems like you cant use force stuff under coil]]
    else
        self.dodgeSpell=self.playerHero:FindAbilityByName(self.currentDodgeType)
        self.dodgeSpell:SetLevel(1)
    end
    self.playerHero:SetAbsOrigin(self.trainingPlace)
    --[[ self.puckTimer=Timers:CreateTimer(2,function()
        self:PuckAction()
        if self.activated then
            return 7
        else
            return nil
        end
    end) ]]
    self:PuckActionDelayed(1)
    Timebar:Show()
    if self.playerSpeedModifier==nil then
        self.playerSpeedModifier = self.playerHero:AddNewModifier(
            self.playerHero, 
            nil, 
            "modifier_custom_speed_boost_flat", 
            {}
        )
    else
        print('failer to add speed modifier')
    end
end

function dream_coil_escape:PuckActionDelayed(delay)
    if self.activated==false then
        return
    end
    Timers:CreateTimer(delay,function()
        self:PuckAction()
    end)
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
        local particle2 = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControl(particle2, 0, respawn_place)
        ParticleManager:ReleaseParticleIndex(particle2)
        unit:SetAttackCapability(0)
        unit:SetBaseManaRegen(100)
        unit:SetBaseHealthRegen(100)
        unit:SetForwardVector((self.playerHero:GetAbsOrigin() - respawn_place):Normalized())
        local ability = unit:FindAbilityByName("puck_dream_coil")
        ability:SetLevel(3)

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
    --[[ debugModifier(event) ]]
    local victim=EntIndexToHScript(event.entindex_parent_const)
    --Player got hurt by breaking dream coil
    if event.name_const==self.breakModifier then
        Timebar:BlueLine()
    end
    --dream coil placed
    if event.name_const=="modifier_dream_coil_thinker" then
        print('coil placed')
        local npc=EntIndexToHScript(event.entindex_parent_const)
        self.coilDone[event.entindex_parent_const]=false
        --start timebar here
        Timebar:PrepareDistance(self.breakRadius+self.timebarExtraDistance,npc,self.playerHero)
        Timebar:AddSingleMark(self.breakRadius+self.timebarExtraDistance,self.breakRadius,"#b600da","puck_dream_coil")
        Timebar:Start()
        -- range display particles/ui_mouseactions/range_display.vpcf
        if self.coilRangeDisplay==true then
            print('drawing circle')
            -- Create the particle effect
            local particleFX = ParticleManager:CreateParticle("particles/ui_mouseactions/range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, npc)
            ParticleManager:SetParticleControl(particleFX, 0, npc:GetAbsOrigin())
            ParticleManager:SetParticleControl(particleFX, 1, Vector(self.breakRadius,0,0))
            Timers:CreateTimer(0,function()
                if IsValidEntity(npc) then
                    local vecDiff=self.playerHero:GetAbsOrigin()-npc:GetAbsOrigin()
                    local distance=vecDiff:Length()
                    local progress=distance/self.breakRadius
                    if progress>1 then
                        progress=1
                    end
                    ParticleManager:SetParticleControl(particleFX, 2, Vector(progress,0,0))
                    return FrameTime()
                else
                    return nil
                end
            end)
            --add vision so particles wont disappear in fog of war
            AddFOWViewer(DOTA_TEAM_GOODGUYS, npc:GetAbsOrigin(), 25, self.dreamCoilDuration, true)
        end
    end
    if event.name_const==self.coilModifier then
        local placedTime=Time()
        Timers:CreateTimer(0,function()
            if IsValidEntity(self.playerHero) then
                if self.playerHero:HasModifier(self.coilModifier) then
                    return FrameTime()
                else
                    if self.playerHero:HasModifier(self.selectedEntry.invulModifier) then
                        --check time if it was fake
                        print('coil expired while in invul')
                        Notifications:Show('green','good',"puck_dream_coil")
                    else
                        print('coil duration:',Time()-placedTime)
                        print('coil just expired')
                        Notifications:Show('red','bad',"puck_dream_coil")
                    end
                    self:PuckActionDelayed(self.timeBetweenCoils+FrameTime())
                    return nil
                end
            else
                return nil
            end
        end)
    end
    return true
end
function dream_coil_escape:MoveSpeedChange(args)
    --[[ print(args.value) ]]
    if self.playerSpeedModifier then
        self.playerSpeedModifier:SetStackCount(tonumber(args.value))
        --[[ self:timebar_spirit_breaker_charge_of_darkness() ]]
    end
end
--[[ function dream_coil_escape:AbilityTuning(event)
    DeepPrintTable(event)
    return true
end ]]
function dream_coil_escape:DamageFilter(event)
    --[[ DeepPrintTable(event) ]]
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
    self.playerSpeedModifier=nil
    if self.puckTimer~=nil then
        Timers:RemoveTimer(self.puckTimer)
    end
    Timebar:ResetLines()
    Timebar:Hide()
    CustomGameEventManager:Send_ServerToAllClients("show_main_menu", {})
    self.dodgeSpell=nil
    self.dodgeItem=nil
    self.forceStaffEnt=nil
    -- TODO: clean up any spawned units/timers/helpers specific to this mode,
    -- following the pattern in dodge.lua:Deactivate() / timing.lua:Deactivate()
end

dream_coil_escape:Init()
GamemodeManager:RegisterMode(dream_coil_escape.name, dream_coil_escape, dream_coil_escape.type)