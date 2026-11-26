-- Aim Challenge owns these items/abilities so legacy topor behavior stays unchanged.
if aim_compet_topor_base == nil then
    aim_compet_topor_base = class({})
end

function aim_compet_topor_base:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function aim_compet_topor_base:GetManaCost()
    return 0
end

function aim_compet_topor_base:GetCooldown()
    return 0
end

function aim_compet_topor_base:GetCastRange()
    if aim_compet ~= nil and aim_compet.GetToporCastRange ~= nil then
        return aim_compet:GetToporCastRange()
    end
    return 1200
end

function aim_compet_topor_base:OnSpellStart()
    if aim_compet ~= nil and aim_compet.UseTopor ~= nil then
        aim_compet:UseTopor(self)
    end
end

if item_aim_topor == nil then item_aim_topor = class(aim_compet_topor_base) end
if item_aim_topor2 == nil then item_aim_topor2 = class(aim_compet_topor_base) end
if item_aim_topor3 == nil then item_aim_topor3 = class(aim_compet_topor_base) end
if item_aim_topor4 == nil then item_aim_topor4 = class(aim_compet_topor_base) end

-- Separate ability names let every ability slot hold any axe color.
if aim_compet_topor_ability == nil then aim_compet_topor_ability = class(aim_compet_topor_base) end
if aim_compet_topor_ability_2 == nil then aim_compet_topor_ability_2 = class(aim_compet_topor_base) end
if aim_compet_topor_ability_3 == nil then aim_compet_topor_ability_3 = class(aim_compet_topor_base) end
if aim_compet_topor_ability_4 == nil then aim_compet_topor_ability_4 = class(aim_compet_topor_base) end
if aim_compet_topor2_ability == nil then aim_compet_topor2_ability = class(aim_compet_topor_base) end
if aim_compet_topor2_ability_2 == nil then aim_compet_topor2_ability_2 = class(aim_compet_topor_base) end
if aim_compet_topor2_ability_3 == nil then aim_compet_topor2_ability_3 = class(aim_compet_topor_base) end
if aim_compet_topor2_ability_4 == nil then aim_compet_topor2_ability_4 = class(aim_compet_topor_base) end
if aim_compet_topor3_ability == nil then aim_compet_topor3_ability = class(aim_compet_topor_base) end
if aim_compet_topor3_ability_2 == nil then aim_compet_topor3_ability_2 = class(aim_compet_topor_base) end
if aim_compet_topor3_ability_3 == nil then aim_compet_topor3_ability_3 = class(aim_compet_topor_base) end
if aim_compet_topor3_ability_4 == nil then aim_compet_topor3_ability_4 = class(aim_compet_topor_base) end
if aim_compet_topor4_ability == nil then aim_compet_topor4_ability = class(aim_compet_topor_base) end
if aim_compet_topor4_ability_2 == nil then aim_compet_topor4_ability_2 = class(aim_compet_topor_base) end
if aim_compet_topor4_ability_3 == nil then aim_compet_topor4_ability_3 = class(aim_compet_topor_base) end
if aim_compet_topor4_ability_4 == nil then aim_compet_topor4_ability_4 = class(aim_compet_topor_base) end
