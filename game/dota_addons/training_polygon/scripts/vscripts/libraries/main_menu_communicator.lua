if MainMenuCommunicator == nil then
    MainMenuCommunicator = class({})
end

function MainMenuCommunicator:Init()
    CustomGameEventManager:RegisterListener("main_menu_load_page_request", Dynamic_Wrap(MainMenuCommunicator, "LoadPage"))
    CustomGameEventManager:RegisterListener("open_login_popup_request", function(_, args)
        --client asked to open the steam login page in the html popup; echo the link to all ui
        local link = (args and args.link) or (Networking and Networking.loginUrl) or ""
        CustomGameEventManager:Send_ServerToAllClients("open_login_popup", {link=link})
    end)
end

function MainMenuCommunicator:LoadPage(args)
    print('load page called')
    CustomGameEventManager:Send_ServerToAllClients("main_menu_load_page", {page=args['page']})
end

MainMenuCommunicator:Init()