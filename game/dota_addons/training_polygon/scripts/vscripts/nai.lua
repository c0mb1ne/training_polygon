

--
--rewards
--8 creeps per wave
--+30 for lasthit enemy
--+25 for deny
---20 for missed creep
---5 for doing wrong action like attacking creep that not exist
--set to 0 for taking hit from tower
--set to 0 from moving out of range
--start budget 480
--INPUT DEF
-- Define the maximum number of creeps that can exist in the game
--outputs: each output determine action
--17,18,19,20: wasd movement, 1-16 attack one of the creeps, 21 stop
local max_creeps = 16
local friendly_creeps_ent={}
local enemy_creeps_ent={}
local output_layer_size = 1
-- Define the size of the input vector
local input_size = 3 + 3 * max_creeps

-- Define the input vector
local input = {}
for i = 1, input_size do
  input[i] = 0
end

--define a hidden layer
hidden_layer = {}
local layer_size = 128

for i = 1, layer_size do
  hidden_layer[i] = {
    bias = math.random(),
    weights = {}
  }

  for j = 1, input_size do
    hidden_layer[i].weights[j] = math.random()
  end
end

--[[print("json:",result_to_send)--]]
--print("json_len=",string.len(result_to_send))

--[[local minVec=hero:GetAbsOrigin()-Vector(750,350,0)
  local maxVec=hero:GetAbsOrigin()+Vector(750,650,0)--]]
  

local ai_start_thinking_time
BOT_REWARD=0
BOT_LASTHITS=0
BOT_DENY=0

function naiSniper(sniper)
  SN_AI_SNIPER=sniper
  BOT_REWARD=480
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
  ai_start_thinking_time=Time()
  local sniper_side=sniper:GetTeam()
  Timers:CreateTimer("ai_thinker_for_sniper", {
    useGameTime = false,
    endTime = FrameTime(),
    callback = function()
      if sniper:IsNull()==false then
        local debug_string=""
        local friendly_creeps={}
        local enemy_creeps={}
        friendly_creeps_ent={}
        enemy_creeps_ent={}
        local creeps=Entities:FindAllByName("npc_dota_creep_lane")
        for k,v in pairs(creeps) do
          if v~=nil then
            if v:IsNull()==false then
              local creep=v
              local creep_team=creep:GetTeam()
              local creep_hp=creep:GetHealth()
              local creep_pos=creep:GetAbsOrigin()
              local creep_parsed={}
              if creep_team==sniper_side and creep_hp~=0 then
                creep_parsed.ent=creep
                creep_parsed.health=creep_hp
                creep_parsed.position={x=math.floor(creep_pos.x),y=math.floor(creep_pos.y)}
                table.insert(friendly_creeps,creep_parsed)
                table.insert(friendly_creeps_ent,creep)
                DebugDrawText(creep_pos, tostring(#friendly_creeps_ent), true, FrameTime())
              end
              if creep_team~=sniper_side and creep_hp~=0 then
                creep_parsed.ent=creep
                creep_parsed.health=creep_hp
                creep_parsed.position={x=math.floor(creep_pos.x),y=math.floor(creep_pos.y)}
                table.insert(enemy_creeps,creep_parsed)
                table.insert(enemy_creeps_ent,creep)
                DebugDrawText(creep_pos, tostring(#enemy_creeps_ent), true, FrameTime())
              end
            end
          end
        end
        --state of sniper 1-moving,2-attacking,3-doing nothing
        local state=3
        if sniper:IsAttacking() then
          state=2
        end
        if sniper:IsIdle() then
          state=3
        end
        if sniper:IsMoving() then
          state=1
        end
        local sniper_pos=sniper:GetAbsOrigin()
        local bot_left=Vector(-1893.4349365234,-1761.212890625,128)
        local top_right=Vector(961.759765625,1132.8590087891,128)
        if sniper_pos.x<bot_left.x or sniper_pos.y<bot_left.y or sniper_pos.x>top_right.x or sniper_pos.y>top_right.y then
          BOT_REWARD=0
        end
        local bot={}
        bot.state=state
        bot.angle=math.floor(VectorToAngles(sniper:GetForwardVector()).y)
        bot.position={x=math.floor(sniper_pos.x),y=math.floor(sniper_pos.y)}
        setInputs(bot,friendly_creeps,enemy_creeps)
        debug_string=debug_string.."INPUT: "
        for k,v in pairs(input) do
          debug_string=debug_string..tostring(k)..":"..tostring(v).." "
        end
        debug_string=debug_string.." -------------------------------------------------------------------------------------------------- "
        debug_string=debug_string.."SCORE:"..tostring(BOT_REWARD).." BOT_LASTHITS:"..tostring(BOT_LASTHITS).." BOT_DENY:"..tostring(BOT_DENY)
        CustomGameEventManager:Send_ServerToAllClients("setDebugOutput",{msg=debug_string})
        

        return FrameTime()
      else
        return nil
      end
    end
  })
end



function setInputs(bot,friendly_creeps,enemy_creeps)
  for i = 1, input_size do
    input[i] = 0
  end
  -- Store the current position of the bot in the first two elements of the input vector
  input[1] = bot.position.x
  input[2] = bot.position.y

  -- Store the current state of the bot in the third element of the input vector
  input[3] = bot.state
  input[4] = bot.angle
  -- Store the current game time in the fourth element of the input vector
  local game_time=Time()-ai_start_thinking_time
  --input[4] = math.floor(game_time*10)/10
  --clearing input out
  
  -- Store the health and position of the friendly creeps in the first half of the remaining elements of the input vector
  for i = 1, #friendly_creeps do
    local creep = friendly_creeps[i]
    if creep then
      input[3 * i + 2] = creep.health
      input[3 * i + 3] = creep.position.x
      input[3 * i + 4] = creep.position.y
    end
  end

  -- Store the health and position of the enemy creeps in the second half of the remaining elements of the input vector
  for i = 1, #enemy_creeps do
    local creep = enemy_creeps[i]
    if creep then
      input[3 * i + max_creeps*1.5 + 2] = creep.health
      input[3 * i + max_creeps*1.5 + 3] = creep.position.x
      input[3 * i + max_creeps*1.5 + 4] = creep.position.y
    end
  end
end

function aiDoAction(actionInt)
  --17,18,19,20: wasd movement, 1-16 attack one of the creeps, 21 stop
  --1-8 friendly creeps
  --9-16 enemy creeps
  if actionInt>=1 and actionInt<=8 then
    local target=friendly_creeps_ent[actionInt]
    if target~=nil then
      if target:IsNull()==false then
        if target:GetHealth()~=0 then
          if target:GetHealth()<target:GetMaxHealth()/2 then
            ExecuteOrderFromTable({
              UnitIndex = SN_AI_SNIPER:entindex(),
              OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
              TargetIndex = target:entindex()
            })
          else
            BOT_REWARD=BOT_REWARD-5
          end
        else
          BOT_REWARD=BOT_REWARD-5
        end
      else
        BOT_REWARD=BOT_REWARD-5
      end
    else
      BOT_REWARD=BOT_REWARD-5
    end
  end
  if actionInt>=9 and actionInt<=16 then
    local target=enemy_creeps_ent[actionInt-8]
    if target~=nil then
      if target:IsNull()==false then
        if target:GetHealth()>0 then
          ExecuteOrderFromTable({
            UnitIndex = SN_AI_SNIPER:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:entindex()
          })
        else
          BOT_REWARD=BOT_REWARD-5
        end
      else
        BOT_REWARD=BOT_REWARD-5
      end
    else
      BOT_REWARD=BOT_REWARD-5
    end
  end
  if actionInt==21 then
    ExecuteOrderFromTable({
      UnitIndex = SN_AI_SNIPER:entindex(),
      OrderType = DOTA_UNIT_ORDER_STOP
    })
  end
  --UP
  if actionInt==17 then
    ExecuteOrderFromTable({
      UnitIndex = SN_AI_SNIPER:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = SN_AI_SNIPER:GetAbsOrigin()+Vector(0,50,0)
    })
  end
  --LEFT
  if actionInt==18 then
    ExecuteOrderFromTable({
      UnitIndex = SN_AI_SNIPER:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = SN_AI_SNIPER:GetAbsOrigin()+Vector(-50,0,0)
    })
  end
  --DOWN
  if actionInt==19 then
    ExecuteOrderFromTable({
      UnitIndex = SN_AI_SNIPER:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = SN_AI_SNIPER:GetAbsOrigin()+Vector(0,-50,0)
    })
  end
  --RIGHT
  if actionInt==20 then
    ExecuteOrderFromTable({
      UnitIndex = SN_AI_SNIPER:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = SN_AI_SNIPER:GetAbsOrigin()+Vector(50,0,0)
    })
  end
  CustomGameEventManager:Send_ServerToAllClients("ai_action_done",{action=actionInt})
end