if CreepController == nil then
  CreepController = class({})
end

function CreepController:Init()
    --class names of default dota spawners
    --would be cool to store vectors here, but this loads before map
    self.spawnPoints={
        [DOTA_TEAM_BADGUYS]={
            top={spawner="lane_top_badguys_melee_spawner",pathcorner="lane_top_pathcorner_badguys_1"},
            mid={spawner="lane_mid_badguys_melee_spawner",pathcorner="lane_mid_pathcorner_badguys_1"},
            bot={spawner="lane_bot_badguys_melee_spawner",pathcorner="lane_bot_pathcorner_badguys_1"}
        },
        [DOTA_TEAM_GOODGUYS]={
            top={spawner="lane_top_goodguys_melee_spawner",pathcorner="lane_top_pathcorner_goodguys_1"},
            mid={spawner="lane_mid_goodguys_melee_spawner",pathcorner="lane_mid_pathcorner_goodguys_1"},
            bot={spawner="lane_bot_goodguys_melee_spawner",pathcorner="lane_bot_pathcorner_goodguys_1"}
        }
    }
    --todo: declare more waves for 31st, 61st etc https://liquipedia.net/dota2/Lane_Creeps
    self.creepWaves={
        [DOTA_TEAM_BADGUYS]={
            initial={
                "npc_dota_creep_badguys_melee",
                "npc_dota_creep_badguys_melee",
                "npc_dota_creep_badguys_melee",
                "npc_dota_creep_badguys_ranged",
            }
        },
        [DOTA_TEAM_GOODGUYS]={
            initial={
                "npc_dota_creep_goodguys_melee",
                "npc_dota_creep_goodguys_melee",
                "npc_dota_creep_goodguys_melee",
                "npc_dota_creep_goodguys_ranged",
            }
        }
    }
    self.creepStorage={}
    --[[ DeepPrintTable(self.spawnPoints) ]]
end



function CreepController:SpawnCreepWave(team,lane,typeOfWave)
    local returnTable={}
    local pathcorner=self.spawnPoints[team][lane].pathcorner
    local spawnerName=self.spawnPoints[team][lane].spawner
    --[[ print('[CreepController] debug:',pathcorner,spawnerName) ]]
    local pathcornerEnt=Entities:FindByName(nil, pathcorner)
    local spawnerEnt=Entities:FindByName(nil, spawnerName)
    local respawnPlace=spawnerEnt:GetAbsOrigin()
    for k,v in pairs(self.creepWaves[team][typeOfWave]) do
        local unit=CreateUnitByName(v,respawnPlace,true,nil,nil,team)
        unit:SetInitialGoalEntity(pathcornerEnt)
        table.insert(returnTable,unit)
        table.insert(self.creepStorage,unit)
    end
    --[[ print('[CreepController] spawning:',self.spawnPoints[team][lane].spawner) ]]
    return returnTable
end

function CreepController:SpawnCreepWave25sec(team,lane,typeOfWave)
    local spawnPoints={
        [DOTA_TEAM_BADGUYS]={
            top=Vector(-4720.955078125,5806.6069335938,128),
            mid=Vector(-447.20712280273,-316.08651733398,5.2379069328308),
            bot=Vector(6257.6669921875,-4214.2421875,128)
        },
        [DOTA_TEAM_GOODGUYS]={
            top=Vector(-6268.2788085938,3772.8723144531,128),
            mid=Vector(-622.1123046875,-454.08047485352,17.705816268921),
            bot=Vector(4275.2890625,-6121.8129882813,128)
        }
    }
    local returnTable={}
    local pathcorner=self.spawnPoints[team][lane].pathcorner
    local pathcornerEnt=Entities:FindByName(nil, pathcorner)
    
    local respawnPlace=spawnPoints[team][lane]
    for k,v in pairs(self.creepWaves[team][typeOfWave]) do
        local unit=CreateUnitByName(v,respawnPlace,true,nil,nil,team)
        unit:SetInitialGoalEntity(pathcornerEnt)
        table.insert(returnTable,unit)
        table.insert(self.creepStorage,unit)
    end

    return returnTable
end
function CreepController:SpawnCreepWave15sec(team,lane,typeOfWave)
    local spawnPoints={
        [DOTA_TEAM_BADGUYS]={
            top=Vector(-1532.3088378906,6093.3959960938,20.743253707886),
            mid=Vector(572.74499511719,460.87606811523,128),
            bot=Vector(6449.9750976563,-1025.6356201172,128)
        },
        [DOTA_TEAM_GOODGUYS]={
            top=Vector(-6306.3427734375,595.43865966797,128),
            mid=Vector(-1630.4013671875,-1263.1811523438,128),
            bot=Vector(1039.5280761719,-6409.7939453125,25.502643585205)
        }
    }
    local returnTable={}
    local pathcorner=self.spawnPoints[team][lane].pathcorner
    local pathcornerEnt=Entities:FindByName(nil, pathcorner)
    
    local respawnPlace=spawnPoints[team][lane]
    for k,v in pairs(self.creepWaves[team][typeOfWave]) do
        local unit=CreateUnitByName(v,respawnPlace,true,nil,nil,team)
        unit:SetInitialGoalEntity(pathcornerEnt)
        table.insert(returnTable,unit)
        table.insert(self.creepStorage,unit)
    end

    return returnTable
end

function CreepController:RemoveCreeps()
    for k,v in pairs(self.creepStorage) do
        if IsValidEntity(v) then
            v:RemoveSelf()
        end
    end
    self.creepStorage={}
end

--some ai slop code to calculate position for lane creep spawns on 25 seconds for example
--[[ ========================================
[CreepController] CALIBRATION COMPLETE 25 sec
========================================
-- GOODGUYS top:
Vector(-6268.2788085938,3772.8723144531,128)
-- GOODGUYS mid:
Vector(-622.1123046875,-454.08047485352,17.705816268921)
-- GOODGUYS bot:
Vector(4275.2890625,-6121.8129882813,128)
-- BADGUYS top:
Vector(-4720.955078125,5806.6069335938,128)
-- BADGUYS mid:
Vector(-447.20712280273,-316.08651733398,5.2379069328308)
-- BADGUYS bot:
Vector(6257.6669921875,-4214.2421875,128)

========================================
[CreepController] CALIBRATION COMPLETE 20 sec
========================================
-- GOODGUYS top:
Vector(-6510.4013671875,2161.2282714844,128)
-- GOODGUYS mid:
Vector(-620.75982666016,-455.32363891602,15.703117370605)
-- GOODGUYS bot:
Vector(2640.6174316406,-6259.287109375,128)
-- BADGUYS top:
Vector(-3108.1540527344,6084.2275390625,128)
-- BADGUYS mid:
Vector(-428.23370361328,-302.61444091797,7.9470772743225)
-- BADGUYS bot:
Vector(6467.3530273438,-2602.37890625,128)
========================================
========================================
[CreepController] CALIBRATION COMPLETE 15 sec
========================================
-- GOODGUYS top:
Vector(-6306.3427734375,595.43865966797,128)
-- GOODGUYS mid:
Vector(-1630.4013671875,-1263.1811523438,128)
-- GOODGUYS bot:
Vector(1039.5280761719,-6409.7939453125,25.502643585205)
-- BADGUYS top:
Vector(-1532.3088378906,6093.3959960938,20.743253707886)
-- BADGUYS mid:
Vector(572.74499511719,460.87606811523,128)
-- BADGUYS bot:
Vector(6449.9750976563,-1025.6356201172,128)
========================================
======================================== ]]
function CreepController:CalibrateCreepWaveSpawnPositions(tries, delay)
    tries = tries or 10
    delay = delay or 25.0

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
    local teamNames = {[DOTA_TEAM_GOODGUYS]="GOODGUYS", [DOTA_TEAM_BADGUYS]="BADGUYS"}
    local lanes = {"top", "mid", "bot"}

    self.calibratedSpawnPoints = {}
    local totalJobs = #teams * #lanes
    local jobsCompleted = 0

    for _, team in pairs(teams) do
        self.calibratedSpawnPoints[team] = {}
        for _, lane in pairs(lanes) do
            self:_CalibrateLane(team, lane, tries, delay, function(avgPos)
                self.calibratedSpawnPoints[team][lane] = avgPos

                print(string.format("[CreepController] done team=%s lane=%s ->", teamNames[team], lane))
                printVector(avgPos)

                jobsCompleted = jobsCompleted + 1
                if jobsCompleted == totalJobs then
                    self:_PrintFinalResults(teamNames, lanes)
                end
            end)
        end
    end
end

function CreepController:_CalibrateLane(team, lane, triesLeft, delay, onDone, accumSum, accumCount)
    accumSum = accumSum or Vector(0, 0, 0)
    accumCount = accumCount or 0

    if triesLeft <= 0 then
        if accumCount == 0 then
            print("[CreepController] WARNING: no successful trials for", team, lane)
            onDone(Vector(0, 0, 0))
            return
        end
        onDone(accumSum * (1 / accumCount))
        return
    end

    local units = self:SpawnCreepWave(team, lane, 'initial')

    Timers:CreateTimer(delay, function()
        local sum = Vector(0, 0, 0)
        local count = 0

        for _, unit in pairs(units) do
            if unit and IsValidEntity(unit) and unit:IsAlive() then
                sum = sum + unit:GetAbsOrigin()
                count = count + 1
            end
        end

        for _, unit in pairs(units) do
            if unit and IsValidEntity(unit) then
                UTIL_Remove(unit)
            end
        end

        if count > 0 then
            local waveAvg = sum * (1 / count)
            self:_CalibrateLane(team, lane, triesLeft - 1, delay, onDone,
                accumSum + waveAvg, accumCount + 1)
        else
            self:_CalibrateLane(team, lane, triesLeft - 1, delay, onDone,
                accumSum, accumCount)
        end
    end)
end

function CreepController:_PrintFinalResults(teamNames, lanes)
    print("========================================")
    print("[CreepController] CALIBRATION COMPLETE")
    print("========================================")
    for team, lanePositions in pairs(self.calibratedSpawnPoints) do
        for _, lane in pairs(lanes) do
            local pos = lanePositions[lane]
            print(string.format("-- %s %s:", teamNames[team], lane))
            printVector(pos)
        end
    end
    print("========================================")
end

CreepController:Init()
