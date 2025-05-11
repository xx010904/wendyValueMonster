local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    local entity_physics = inst.entity:AddPhysics()
    entity_physics:SetMass(1.0)
    entity_physics:SetFriction(0.1)
    entity_physics:SetDamping(0.0)
    entity_physics:SetRestitution(0.5)
    entity_physics:SetCollisionGroup(COLLISION.ITEMS)
    entity_physics:ClearCollisionMask()
    entity_physics:CollidesWith(COLLISION.WORLD)
    entity_physics:SetSphere(0.5)

    inst.entity:AddNetwork()

    inst.AnimState:SetBank("shadow_thrall_parasite_transition_fx")
    inst.AnimState:SetBuild("shadow_thrall_parasite_transition_fx")
    inst.AnimState:PlayAnimation("transition", false)
    -- inst.AnimState:SetMultColour(0, 0, 0, 1) -- 设置特效为黑色
    -- inst.Transform:SetScale(1.6, 1.6, 1.6)

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("smallghost_parasite_fx", fn, {})


