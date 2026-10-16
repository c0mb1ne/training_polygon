--[[
    lasthit_training_bot_balance
    ----------------------------------------------------------------------------
    Lane-equilibrium lasthit bot. No per-creep timing windows; every tick it just
    picks the single best target from a scored list:

      1. KILL     creep that our next hit will kill (accounting for damage that
                  other units will deal while our attack is travelling/approaching)
      2. DESYNC   two creeps of one team with ~same low hp -> hit the lower one so
                  they stop dying in the same moment
      3. BALANCE  nothing to kill: hit creeps of the side that has more total hp,
                  so neither wave out-pushes the other
      4. nothing  stand behind our wave, don't touch anything

    Safety: if more than CFG.maxTankers units are hitting the bot it retreats to
    its own tower until it is calm again. It never targets creeps standing inside
    the enemy tower's range.

    Works for melee and ranged: the approach time and projectile flight time are
    derived from attack range / move speed / projectile speed of the bot unit.

    Same interface as the old bot:
        local ent = lasthit_training_bot_balance:Init(heroName, respawnVec, botTeam, lane)
        lasthit_training_bot_balance:Stop()
]]

if lasthit_training_bot_balance == nil then
    lasthit_training_bot_balance = class({})
end

local CFG = {
    thinkInterval = 0.05,  -- seconds between decisions
    scanRadius    = 1800,  -- how far around the bot we look for units

    -- lasthit prediction
    leadFactor    = 0.8,   -- how much of the "other units' damage during our hit's travel" we trust (0 = ignore)

    -- balance
    deadband      = 0.12,  -- hp imbalance (0..1) below which we consider the lane even

    -- desync (two creeps with the same hp)
    desyncGap     = 0.6,   -- hp difference smaller than this many hits = "same hp"
    desyncZone    = 2.5,   -- only care when the lower one has <= this many hits of hp left

    -- tanking
    maxTankers    = 1,     -- more than this many creeps/tower hitting the bot -> retreat
    calmTime      = 0.7,   -- seconds with nobody hitting us before going back

    -- misc
    towerMargin   = 100,   -- extra distance kept from enemy tower range
    stickiness    = 15,    -- score bonus for the current target (prevents flip-flopping)
    idleBehind    = 150,   -- idle position offset behind the friendly wave centre
    debug         = false,
}

-- scores
local SCORE_KILL   = 100
local SCORE_DESYNC = 60
local SCORE_SOFTEN = 20

---------------------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------------------
local function Dist2D(a, b)
    return (a - b):Length2D()
end

local function ArmorMult(target)
    local armor = target:GetPhysicalArmorValue(false)
    return 1 - 0.06 * armor / (1 + 0.06 * math.abs(armor))
end

local function IsLaneCreep(u)
    return u ~= nil and IsValidEntity(u) and u:IsAlive() and u:GetClassname() == "npc_dota_creep_lane"
end

---------------------------------------------------------------------------------
-- lifecycle
---------------------------------------------------------------------------------
function lasthit_training_bot_balance:Init(botHeroName, vecRespawnPlace, botTeam, selectedLane)
    self.botHeroName     = botHeroName
    self.botRespawnPlace = vecRespawnPlace
    self.botTeam         = botTeam
    self.selectedLane    = selectedLane
    self.botEnt          = nil
    self.thinkTimer      = nil

    local direTower   = TowerController.towers['npc_dota_badguys_tower1_' .. selectedLane]
    local radiantTower = TowerController.towers['npc_dota_goodguys_tower1_' .. selectedLane]
    if botTeam == DOTA_TEAM_BADGUYS then
        self.friendlyTower, self.enemyTower = direTower, radiantTower
    else
        self.friendlyTower, self.enemyTower = radiantTower, direTower
    end

    -- unit vector pointing from the enemy tower to our tower (along the lane)
    local d = self.friendlyTower:GetAbsOrigin() - self.enemyTower:GetAbsOrigin()
    d.z = 0
    self.laneDir = d:Length2D() > 0 and d:Normalized() or Vector(1, 0, 0)

    -- state
    self.retreating = false
    self.calmSince  = nil
    self.orderKind  = nil   -- "attack" | "move" | "idle"
    self.orderTarget = nil  -- entindex for attack orders
    self.orderPos   = nil
    self.orderTime  = 0

    self:CreateBotUnit()
    return self.botEnt
end

function lasthit_training_bot_balance:CreateBotUnit()
    self.botEnt = CreateUnitByName(self.botHeroName, self.botRespawnPlace, true, nil, nil, self.botTeam)
    self.botEnt:SetBaseHealthRegen(300)
    self.botEnt:SetIdleAcquire(false)
    if self.botEnt.SetAcquisitionRange then
        self.botEnt:SetAcquisitionRange(0)
    end
    self.thinkTimer = Timers:CreateTimer(0, function()
        if not IsValidEntity(self.botEnt) then
            return nil
        end
        if self.botEnt:IsAlive() then
            self:Think()
        end
        return CFG.thinkInterval
    end)
end

function lasthit_training_bot_balance:Stop()
    if self.thinkTimer ~= nil then
        Timers:RemoveTimer(self.thinkTimer)
        self.thinkTimer = nil
    end
    if IsValidEntity(self.botEnt) then
        self.botEnt:RemoveSelf()
    end
    self.botEnt = nil
end

---------------------------------------------------------------------------------
-- orders (only re-issued when something actually changed)
---------------------------------------------------------------------------------
function lasthit_training_bot_balance:OrderAttack(creep)
    local bot, now, idx = self.botEnt, Time(), creep:entindex()
    local need = (self.orderKind ~= "attack") or (self.orderTarget ~= idx)
    if not need and now - self.orderTime > 0.3
        and not bot:IsAttacking() and bot:GetAttackTarget() == nil then
        need = true -- order got lost somehow
    end
    if need then
        ExecuteOrderFromTable({
            UnitIndex   = bot:entindex(),
            OrderType   = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = idx,
            Queue       = false,
        })
        self.orderKind, self.orderTarget, self.orderTime = "attack", idx, now
    end
end

function lasthit_training_bot_balance:OrderMove(pos)
    local bot, now = self.botEnt, Time()
    if Dist2D(bot:GetAbsOrigin(), pos) < 60 then
        if self.orderKind ~= "idle" then
            ExecuteOrderFromTable({
                UnitIndex = bot:entindex(),
                OrderType = DOTA_UNIT_ORDER_STOP,
                Queue     = false,
            })
            self.orderKind, self.orderTarget, self.orderTime = "idle", nil, now
        end
        return
    end
    local need = (self.orderKind ~= "move")
        or (self.orderPos == nil or Dist2D(self.orderPos, pos) > 80)
        or (now - self.orderTime > 0.5)
    if need then
        ExecuteOrderFromTable({
            UnitIndex = bot:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position  = pos,
            Queue     = false,
        })
        self.orderKind, self.orderTarget, self.orderPos, self.orderTime = "move", nil, pos, now
    end
end

---------------------------------------------------------------------------------
-- world scan
---------------------------------------------------------------------------------
function lasthit_training_bot_balance:Scan()
    local bot = self.botEnt
    local units = FindUnitsInRadius(
        self.botTeam, bot:GetAbsOrigin(), nil, CFG.scanRadius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    local s = {ally = {}, enemy = {}, incoming = {}, tankers = 0, allyHp = 0, enemyHp = 0}
    local attackers = {}

    for _, u in ipairs(units) do
        if u ~= bot and u:IsAlive() then
            attackers[#attackers + 1] = u
            if u:GetClassname() == "npc_dota_creep_lane" then
                if u:GetTeamNumber() == self.botTeam then
                    s.ally[#s.ally + 1] = u
                    s.allyHp = s.allyHp + u:GetHealth()
                else
                    s.enemy[#s.enemy + 1] = u
                    s.enemyHp = s.enemyHp + u:GetHealth()
                    if u:GetAttackTarget() == bot then
                        s.tankers = s.tankers + 1
                    end
                end
            end
        end
    end
    -- towers are invulnerable so FindUnits skips them; add them by hand
    for _, t in ipairs({self.friendlyTower, self.enemyTower}) do
        if IsValidEntity(t) and t:IsAlive() then
            attackers[#attackers + 1] = t
        end
    end
    if IsValidEntity(self.enemyTower) and self.enemyTower:GetAttackTarget() == bot then
        s.tankers = s.tankers + 1
    end

    -- expected dps on every lane creep from everybody who is currently attacking it
    for _, a in ipairs(attackers) do
        local t = a:GetAttackTarget()
        if t ~= nil and t ~= bot and IsLaneCreep(t) then
            local spa = a:GetSecondsPerAttack(false)
            if spa > 0 then
                local dps = a:GetAverageTrueAttackDamage(t) * ArmorMult(t) / spa
                local i = t:entindex()
                s.incoming[i] = (s.incoming[i] or 0) + dps
            end
        end
    end
    return s
end

local function Centroid(list)
    if #list == 0 then return nil end
    local sum = Vector(0, 0, 0)
    for _, u in ipairs(list) do sum = sum + u:GetAbsOrigin() end
    return sum / #list
end

---------------------------------------------------------------------------------
-- per-creep evaluation
---------------------------------------------------------------------------------
function lasthit_training_bot_balance:Evaluate(c, isAlly, incoming, range)
    local bot = self.botEnt
    local hp, maxHp = c:GetHealth(), c:GetMaxHealth()
    local info = {unit = c, idx = c:entindex(), ally = isAlly, hp = hp, maxHp = maxHp}

    -- allied creeps can only be denied under 50% hp
    if isAlly then
        info.valid = hp < maxHp / 2
    else
        info.valid = true
    end

    -- keep away from the enemy tower
    local towerRange = self.enemyTower:GetBaseAttackRange() + CFG.towerMargin
    if range > 250 then towerRange = towerRange - math.min(range, 400) * 0.5 end
    if Dist2D(c:GetAbsOrigin(), self.enemyTower:GetAbsOrigin()) < towerRange then
        info.valid = false
    end

    -- our damage (lower end of the roll, so a "kill" is a real kill)
    local avg    = bot:GetAverageTrueAttackDamage(c)
    local spread = (bot:GetBaseDamageMax() - bot:GetBaseDamageMin()) / 2
    info.dmg = math.max(1, avg - spread) * ArmorMult(c)

    -- how long until our hit would land: walk + attack animation + projectile
    local dist = Dist2D(bot:GetAbsOrigin(), c:GetAbsOrigin())
    local reach = range + c:GetHullRadius() + bot:GetHullRadius()
    local approach = math.max(0, dist - reach) / math.max(100, bot:GetIdealSpeed())
    local travel = 0
    if bot:IsRangedAttacker() then
        local sp = bot:GetProjectileSpeed()
        if sp and sp > 0 then travel = math.min(dist, reach) / sp end
    end
    info.lead = approach + bot:GetAttackAnimationPoint() + travel

    info.incoming = incoming[info.idx] or 0
    info.eff = hp - info.incoming * info.lead * CFG.leadFactor
    -- eff <= 0: somebody else will get it before us, don't waste the attack
    info.killable = info.valid and info.eff > 0 and info.eff <= info.dmg
    return info
end

---------------------------------------------------------------------------------
-- decision
---------------------------------------------------------------------------------
function lasthit_training_bot_balance:Think()
    local bot, now = self.botEnt, Time()
    local s = self:Scan()

    -- 1) don't tank ---------------------------------------------------------
    if not self.retreating and s.tankers > CFG.maxTankers then
        self.retreating, self.calmSince = true, nil
    end
    if self.retreating then
        if s.tankers == 0 then
            self.calmSince = self.calmSince or now
            if now - self.calmSince > CFG.calmTime then
                self.retreating = false
            end
        else
            self.calmSince = nil
        end
    end
    if self.retreating then
        local spot = self.friendlyTower:GetAbsOrigin() - self.laneDir * 200
        self:OrderMove(spot)
        return
    end

    -- 2) evaluate creeps ----------------------------------------------------
    local range = bot.Script_GetAttackRange and bot:Script_GetAttackRange() or bot:GetBaseAttackRange()
    local infos = {}
    local bySide = {ally = {}, enemy = {}}
    for _, c in ipairs(s.ally) do
        local i = self:Evaluate(c, true, s.incoming, range)
        infos[#infos + 1] = i
        bySide.ally[#bySide.ally + 1] = i
    end
    for _, c in ipairs(s.enemy) do
        local i = self:Evaluate(c, false, s.incoming, range)
        infos[#infos + 1] = i
        bySide.enemy[#bySide.enemy + 1] = i
    end

    -- which side is stronger? (hit the stronger one to pull the lane back)
    local strong = nil
    local big = math.max(s.allyHp, s.enemyHp, 1)
    local imb = (s.allyHp - s.enemyHp) / big
    if imb > CFG.deadband then strong = "ally"
    elseif imb < -CFG.deadband then strong = "enemy" end

    -- desync: same-hp neighbours on one side, both about to become lasthittable
    local desyncPick = {}
    for _, list in pairs(bySide) do
        table.sort(list, function(a, b)
            if a.hp == b.hp then return a.idx < b.idx end
            return a.hp < b.hp
        end)
        for k = 1, #list - 1 do
            local lo, hi = list[k], list[k + 1]
            if lo.valid and lo.eff > 0
                and lo.hp <= lo.dmg * CFG.desyncZone
                and (hi.hp - lo.hp) <= lo.dmg * CFG.desyncGap then
                desyncPick[lo.idx] = true
            end
        end
    end

    -- 3) score --------------------------------------------------------------
    local best, bestScore = nil, 0
    for _, i in ipairs(infos) do
        local score = 0
        if i.killable then
            score = SCORE_KILL
            -- urgent (others will kill it soon) first
            local ttd = (i.incoming > 0) and (i.hp / i.incoming) or 99
            score = score + math.max(0, 20 - ttd * 10)
            -- prefer kills on the stronger side (also pulls the lane back)
            local side = i.ally and "ally" or "enemy"
            if strong == nil or side == strong then score = score + 10 end
        elseif i.valid and i.eff > 0 then
            if desyncPick[i.idx] then
                score = SCORE_DESYNC
            elseif strong ~= nil and ((i.ally and strong == "ally") or (not i.ally and strong == "enemy"))
                and i.hp > i.dmg then
                -- soften the weakest creep of the strong side
                score = SCORE_SOFTEN + (1 - i.hp / i.maxHp) * 10
            end
        end
        if score > 0 and self.orderKind == "attack" and self.orderTarget == i.idx then
            score = score + CFG.stickiness
        end
        if score > bestScore then
            best, bestScore = i, score
        end
    end

    -- 4) act ----------------------------------------------------------------
    if CFG.debug then
        for _, i in ipairs(infos) do
            DebugDrawText(i.unit:GetAbsOrigin(),
                string.format("%d eff%.0f d%.0f", i.hp, i.eff, i.dmg), true, CFG.thinkInterval)
        end
        if best then
            DebugDrawCircle(best.unit:GetAbsOrigin(), Vector(255, 255, 0), 20, 40, true, CFG.thinkInterval)
        end
    end

    if best ~= nil then
        self:OrderAttack(best.unit)
        return
    end

    -- nothing to do: stand just behind our own wave
    local centre = Centroid(s.ally)
    local spot
    if centre ~= nil then
        spot = centre + self.laneDir * CFG.idleBehind
    else
        spot = self.botRespawnPlace
    end
    self:OrderMove(spot)
end
