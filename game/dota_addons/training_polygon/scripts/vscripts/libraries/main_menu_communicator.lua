if MainMenuCommunicator == nil then
    MainMenuCommunicator = class({})
end

function MainMenuCommunicator:Init()
    CustomGameEventManager:RegisterListener("main_menu_load_page_request", Dynamic_Wrap(MainMenuCommunicator, "LoadPage"))
end

function MainMenuCommunicator:LoadPage(args)
    print('load page called')
    CustomGameEventManager:Send_ServerToAllClients("main_menu_load_page", {page=args['page']})
end

MainMenuCommunicator:Init()