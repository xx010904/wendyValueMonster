local assets ={}

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("sisturn_salting_fx")
	inst.AnimState:SetBuild("sisturn_salting_fx")
	inst.AnimState:PlayAnimation("plate", true)
	-- inst.AnimState:SetScale(1.5, 1.5, 1.5)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end


return Prefab("sisturn_salting_fx", shadow_fn, assets)
