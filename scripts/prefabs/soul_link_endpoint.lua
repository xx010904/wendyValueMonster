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
	inst.AnimState:SetBank("wendy_soul_link_endpoint")
	inst.AnimState:SetBuild("wendy_soul_link_endpoint")
	inst.AnimState:PlayAnimation("debuff_loop_large")
	inst.AnimState:SetMultColour(1, 1, 1, 0.66)
	-- inst.AnimState:SetFrame(12)
	-- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    -- inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    -- inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	-- inst:DoTaskInTime(1*FRAMES,function(inst)
	-- 	inst:Remove()
	-- end)
	inst:ListenForEvent("animover", function(inst)
		inst:Hide()
		inst:Remove()
	end)

	return inst
end


return Prefab("soul_link_endpoint", shadow_fn, assets)
