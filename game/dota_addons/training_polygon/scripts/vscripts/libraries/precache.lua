--class for precaching heroes before individual gamemode starts
--precaching loading models of heroes, can be done while custom game loading, but i dont want people who wants to play specific minigame load heroes for every minigame
if precache == nil then
    precache = class({})
end

function precache:Init()
    self.precacheTable={}

end

function precache:PrecaheAddItemToList(itemList)
    for k,v in pairs(itemList) do
        table.insert(self.precacheTable,{'item',v})
        print(v.." added to table")
    end
end

function precache:PrecacheAddUnitToList(unitList)
    for k,v in pairs(unitList) do
        table.insert(self.precacheTable,{'unit',v})
        print(v.." added to table")
    end
end

function precache:PrecacheAddPlayerUnitToList(unitList)
    for k,v in pairs(unitList) do
        table.insert(self.precacheTable,{'p_unit',v})
        print(v.." added to table")
    end
end

function precache:doPrecache(callback)
    print('Precahe started')
    function precacheElement(callback)
        if self.precacheTable[1]~=nil then
            --[[ PrintTable(self.precacheTable[1]) ]]
            if self.precacheTable[1][1]=="unit" then
                PrecacheUnitByNameAsync(self.precacheTable[1][2],function()
                        table.remove(self.precacheTable,1)
                        precacheElement(callback)
                end)	
            elseif self.precacheTable[1][1]=="p_unit" then	
                 PrecacheUnitByNameAsync(self.precacheTable[1][2],function()
                        table.remove(self.precacheTable,1)
                        precacheElement(callback)
                end,0)
            else
                PrecacheItemByNameAsync(self.precacheTable[1][2],function()
                    table.remove(self.precacheTable,1)
                    precacheElement(callback)
                end)	
            end
            print("Precashing:",self.precacheTable[1][1],self.precacheTable[1][2])
            CustomGameEventManager:Send_ServerToAllClients("precache_progress",{item=self.precacheTable[1][2]})
        else
            print("Precahe done")
            GameMode:HideMenu()
            if callback then
                callback()
            end
        end

    end
    precacheElement(callback)
end

function precache:clearTable()


end