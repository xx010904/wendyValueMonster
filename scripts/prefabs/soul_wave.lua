local function oncollidewave(inst, other)
    if other and not other:HasTag("wave") then
        if other.components.health ~= nil then
            other.components.health:DoDelta(-100)
        end
        local x,y,z = inst.Transform:GetWorldPosition()
        SpawnPrefab("sanity_raise").Transform:SetPosition(x,y,z)
    end
    -- inst:Remove()
end

local function OnRemoveEntity(inst)
    inst.SoundEmitter:KillSound("wave")
end

local function fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

	inst.AnimState:SetBank("shadow_thrall_projectile_fx")
	inst.AnimState:SetBuild("shadow_thrall_projectile_fx")
	inst.AnimState:PlayAnimation("projectile_pre")
	inst.AnimState:PushAnimation("projectile_loop")

    local phys = inst.entity:AddPhysics()
    phys:SetSphere(1)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCollides(false) --Still will get collision callback, just not dynamic collisions.

    inst:AddTag("scarytoprey")
    inst:AddTag("wave")
    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst.OnEntitySleep = inst.Remove

    inst.Physics:SetCollisionCallback(oncollidewave)

    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/wave/LP", "wave")
    inst.SoundEmitter:SetParameter("wave", "size", 0.5)

    inst.OnRemoveEntity = OnRemoveEntity

    return inst
end


return Prefab("soul_wave", fn, {}, {} )
