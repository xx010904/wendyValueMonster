local MurderElixirUsage = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("murderelixirusage")
end)

function MurderElixirUsage:OnRemoveFromEntity()
    self.inst:RemoveTag("murderelixirusage")
end

function MurderElixirUsage:DoMurder(doer)
    local flower = self.inst

    if flower and flower.prefab == "abigail_flower"
       and doer and doer.prefab == "wendy"
       and doer.components.ghostlybond
       and doer.components.ghostlybond.ghost
    then
        if not doer.needApart then
            local fx = SpawnPrefab("abigailsummonfx")
            fx.entity:SetParent(doer.entity)

            local skin_build = flower:GetSkinBuild()
            if skin_build ~= nil then
                fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild())
            end

            flower:Remove()
            doer:AddDebuff("murder_abigail_buff", "murder_abigail_buff")
        end
        return true
    end

    return false
end

return MurderElixirUsage
