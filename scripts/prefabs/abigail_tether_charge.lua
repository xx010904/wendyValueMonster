local function OnHit(inst, owner, target)
    SpawnPrefab("abigail_tether_charge_hit").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function OnAnimOver(inst)
    inst:DoTaskInTime(1.4, inst.Remove)
end

local function OnThrown(inst)
    inst:ListenForEvent("animover", OnAnimOver)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("ghost")
    inst.AnimState:SetBuild("ghost_abigail_build")
	inst.AnimState:PlayAnimation("gestalt_attack_loop", true)

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(-9)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(0.01)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)

    inst:DoTaskInTime(0.4, function(inst)
        SpawnPrefab("planar_resist_fx").entity:SetParent(inst.entity)
        inst.components.projectile:SetSpeed(19)
        inst.components.projectile:SetHitDist(0.75)
    end)

    return inst
end

local function PlayHitSound(proxy)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.SoundEmitter:PlaySound("terraria1/skins/weapon_whoosh")
    -- inst.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")

    inst:Remove()
end

local function PushColour(inst, r, g, b)
	if inst.target:IsValid() then
		if inst.target.components.colouradder == nil then
			inst.target:AddComponent("colouradder")
		end
		inst.target.components.colouradder:PushColour(inst, r, g, b, 0)
	end
end

local function PopColour(inst)
	inst.OnRemoveEntity = nil
	if inst.target.components.colouradder ~= nil and inst.target:IsValid() then
		inst.target.components.colouradder:PopColour(inst)
	end
end

local function PushFlash(inst, target)
	inst.target = target
	PushColour(inst, .1, .1, .1)
	inst:DoTaskInTime(4 * FRAMES, PushColour, .075, .075, .075)
	inst:DoTaskInTime(7 * FRAMES, PushColour, .05, .05, .05)
	inst:DoTaskInTime(9 * FRAMES, PushColour, .025, .025, .025)
	inst:DoTaskInTime(10 * FRAMES, PopColour)
	inst.OnRemoveEntity = PopColour
end

local function hit_fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame in case we are about to be removed
        inst:DoTaskInTime(0, PlayHitSound)
    end

	inst.AnimState:SetBank("rose_petals_fx")
	inst.AnimState:SetBuild("rose_petals_fx")
	inst.AnimState:PlayAnimation("fall")
    inst.Transform:SetScale(1.7, 1.7, 1.7)
	inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(.5)

    inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	-- if math.random() < 0.5 then
	-- 	inst.AnimState:PlayAnimation("fall")
	-- end
    inst:DoTaskInTime(.85, inst.Remove)

	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false

	inst.PushFlash = PushFlash

	return inst
end

return Prefab("abigail_tether_charge", fn, {}),
    Prefab("abigail_tether_charge_hit", hit_fn)