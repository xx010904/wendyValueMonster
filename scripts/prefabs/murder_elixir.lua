local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "small", 0.15, 0.55)

	inst.AnimState:SetBank("ghostly_elixirs")
	inst.AnimState:SetBuild("ghostly_elixirs")
	inst.AnimState:PlayAnimation("attack")

	inst:AddTag("murder_elixir")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "ghostlyelixir_murder"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/ghostlyelixir_murder.xml"

	inst:AddComponent("murderelixirusage")

	inst:AddComponent("stackable")
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("murder_elixir", fn)
