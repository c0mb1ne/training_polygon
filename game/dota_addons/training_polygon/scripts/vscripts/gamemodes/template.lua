if templateMode == nil then
  templateMode = class({})
end

function templateMode:Init()
    self.type="sandbox" -- Define the type of mode
    self.name="templateMode" -- Name of the gamemode
end

--game events
function templateMode:OnIllusionsCreated(keys)

end

function templateMode:OnNonPlayerUsedAbility(keys)

end

function templateMode:OnAbilityUsed(keys)

end

function templateMode:OnEntityHurt(keys)

end

function templateMode:OnNPCSpawned(keys)

end
--event filters
function templateMode:ModifierGained(event)
    return true
end

function templateMode:DamageFilter(event)
    return true
end

function templateMode:OrderFilter(event)
    return true
end