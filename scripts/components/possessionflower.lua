local PossessionFlower = Class(function(self, inst)
    self.inst = inst
end)

function PossessionFlower:DoMurder(doer)
    local flower = self.inst

    if flower and flower.prefab == "abigail_flower"
       and doer and doer.prefab == "wendy"
       and doer.components.ghostlybond
       and doer.components.ghostlybond.ghost
    then
        local fx = SpawnPrefab("abigailsummonfx")
        fx.entity:SetParent(doer.entity)

        local skin_build = flower:GetSkinBuild()
        if skin_build ~= nil then
            fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild())
        end

        flower:Remove()
        doer:AddDebuff("murder_abigail_buff", "murder_abigail_buff")
        return true
    end

    return false
end

return PossessionFlower