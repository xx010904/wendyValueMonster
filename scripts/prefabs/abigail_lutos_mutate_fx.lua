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
    inst.AnimState:SetBank("lunarthrall_plant_gestalt")
    inst.AnimState:SetBuild("lunarthrall_plant_gestalt")
    inst.AnimState:PlayAnimation("infest", false)
	inst.AnimState:SetFrame(30)
	inst.AnimState:SetMultColour(1, 1, 1, 1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:DoTaskInTime(115*FRAMES,function(inst)
		inst:Remove()
	end)

	return inst
end


return Prefab("abigail_lutos_mutate_fx", shadow_fn, assets)
