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

    inst.AnimState:SetBank("fx_plant_spray")
    inst.AnimState:SetBuild("fx_plant_spray")
    inst.AnimState:PlayAnimation("play_fx", false)
    inst.AnimState:SetMultColour(0, 0, 0, 1) -- 设置特效为黑色
    inst.Transform:SetScale(2.6, 2.6, 2.6)

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("murder_abigail_fx", fn, {})


