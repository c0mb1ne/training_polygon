--class for picking custom place for training on dota map before training, made for dodge, but maybe can be used in others like aim, or timing
if placePicker == nil then
    placePicker = class({})
end

function placePicker:Init()
    CustomGameEventManager:RegisterListener("place_picker_start", Dynamic_Wrap(placePicker, "StartPicking"))
    CustomGameEventManager:RegisterListener("place_picker_picked", Dynamic_Wrap(placePicker, "Picked"))
end
function placePicker:Picked(args)
    CustomGameEventManager:Send_ServerToAllClients("place_picker_result", {pos=args['pos']})
    GameMode:ShowMenu()
end
function placePicker:StartPicking(args)
    GameMode:HideMenu()
    CustomGameEventManager:Send_ServerToAllClients("place_picker_show", {})
end

placePicker:Init()