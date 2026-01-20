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
    print('Precache started')
    local totalCount = #self.precacheTable
    local currentCount = 0

    -- Send precache_start event to show the modal
    CustomGameEventManager:Send_ServerToAllClients("precache_start", {total = totalCount})
    GameMode:HideMenu()
    function precacheElement(callback)
        if self.precacheTable[1] ~= nil then
            local itemType = self.precacheTable[1][1]
            local itemName = self.precacheTable[1][2]

            currentCount = currentCount + 1
            print("Precaching:", itemType, itemName, "(" .. currentCount .. "/" .. totalCount .. ")")

            -- Send progress event with current/total
            CustomGameEventManager:Send_ServerToAllClients("precache_progress", {
                item = itemName,
                current = currentCount,
                total = totalCount
            })

            if itemType == "unit" then
                PrecacheUnitByNameAsync(itemName, function()
                    table.remove(self.precacheTable, 1)
                    precacheElement(callback)
                end)
            elseif itemType == "p_unit" then
                PrecacheUnitByNameAsync(itemName, function()
                    table.remove(self.precacheTable, 1)
                    precacheElement(callback)
                end, 0)
            else
                PrecacheItemByNameAsync(itemName, function()
                    table.remove(self.precacheTable, 1)
                    precacheElement(callback)
                end)
            end
        else
            print("Precache done")
            -- Send precache_complete event to hide the modal
            CustomGameEventManager:Send_ServerToAllClients("precache_complete", {})
            --[[ GameMode:HideMenu() ]]
            if callback then
                callback()
            end
        end
    end

    -- Handle empty precache list
    if totalCount == 0 then
        print("Precache: nothing to precache")
        CustomGameEventManager:Send_ServerToAllClients("precache_complete", {})
        --[[ GameMode:HideMenu() ]]
        if callback then
            callback()
        end
        return
    end

    precacheElement(callback)
end

function precache:clearTable()
    self.precacheTable = {}
end
