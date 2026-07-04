--this would be used to register gamemodes, so ui will know what to draw in menu
if GamemodeManager == nil then
  GamemodeManager = class({})
end

function GamemodeManager:Init()
  self.activeGameMode=nil
  self.gamemodeList={}
  self.modeNames={}
  CustomGameEventManager:RegisterListener("get_gamemodes_for_menu", function(_, event)
      GamemodeManager:GetRegisteredModesForMenu()
  end)
end

function GamemodeManager:RegisterMode(modeName,gamemodeClass,gamemodeType)
  self.gamemodeList[modeName]=gamemodeClass
  table.insert(self.modeNames,{name=modeName,type=gamemodeType})
end

function GamemodeManager:SetActiveGamemode(modeName)
  self.activeGameMode=self.gamemodeList[modeName]
end

function GamemodeManager:GetRegisteredModesForMenu()
  CustomGameEventManager:Send_ServerToAllClients("gamemodes_to_draw",{data=self.modeNames})

end

GamemodeManager:Init()