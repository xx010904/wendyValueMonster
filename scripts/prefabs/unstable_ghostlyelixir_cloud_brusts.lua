local assets ={}

local function MakeBrust(name)

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddFollower()
		inst.entity:AddNetwork()

		inst:AddTag("FX")
		inst:AddTag("NOCLICK")

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.AnimState:SetBank("abigail_vial_fx")
		inst.AnimState:SetBuild("abigail_vial_fx")
		inst.AnimState:PlayAnimation(name)
		inst.AnimState:SetMultColour(1, 1, 1, 1)

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst.persists = false
		inst:DoTaskInTime(15*FRAMES,function(inst)
			inst:Remove()
		end)

		return inst
	end

	return Prefab("unstable_ghostlyelixir_cloud_brust_"..name, fn, assets)
end



return MakeBrust("revive"),
		MakeBrust("speed"),
		MakeBrust("attack"),
		MakeBrust("retaliation"),
		MakeBrust("shield"),
		MakeBrust("fastregen"),
		MakeBrust("slowregen")