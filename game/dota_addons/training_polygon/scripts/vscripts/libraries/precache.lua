if precache == nil then
    precache = class({})
end

function precache:Init()
    self.precacheTable={}

end

function precache:PrecaheAddItemList(itemList)
    for k,v in pairs(itemList) do
        table.insert(self.precacheTable,{'item',v})
        print(v.." added to table")
    end
end

function precache:PrecacheAddUnitList(unitList)
    for k,v in pairs(unitList) do
        table.insert(self.precacheTable,{'unit',v})
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