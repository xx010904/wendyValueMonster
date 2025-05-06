require "prefabutil"

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sisturn_food")
    inst.AnimState:SetBuild("sisturn_food")
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(0.65, 0.65, 0.65)

    MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()
    inst:AddTag("saltbox_valid")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/4
    inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
	inst.components.edible.secondaryfoodtype = FOODTYPE.ROUGHAGE

    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sisturn_food"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sisturn_food.xml"

    inst:AddComponent("forcecompostable")
    inst.components.forcecompostable.brown = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("sisturn_food", fn, {})
