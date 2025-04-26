local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cook_pot_food")
    inst.AnimState:SetBuild("cook_pot_food")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "bananapop")

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

    inst:AddTag("wendy_last_food")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lotusflower_gestalt"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/lotusflower_gestalt.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = TUNING.HEALING_SUPERHUGE * 2
    inst.components.edible.hungervalue = TUNING.CALORIES_SUPERHUGE * 2
    inst.components.edible.sanityvalue = TUNING.SANITY_HUGE * 2

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wendy_last_food", fn, {})