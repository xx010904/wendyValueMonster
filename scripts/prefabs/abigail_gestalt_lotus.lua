local MIN_FADE_VALUE = 0.40
local MIN_FADE_COLOUR = {1.00, 1.00, 1.00, MIN_FADE_VALUE}
local function mutation(inst, caster)
    -- 参数校验层
    if caster == nil or not caster:IsValid() then
        return false, "INVALID_CASTER"
    end

    local ghostlybond = caster.components.ghostlybond
    if not (ghostlybond and ghostlybond.ghost) then
        return false, "NO_GHOSTLY_BOND"
    end

    if not ghostlybond.summoned then
        return false, "GHOST_NOT_SUMMONED"
    end

    local ghost = ghostlybond.ghost
    if not (ghost and ghost:IsValid()) then
        return false, "INVALID_GHOST"
    end

    -- 核心转向逻辑
    if caster then
        caster:ForceFacePoint(ghost.Transform:GetWorldPosition())
    end

    -- 幽灵形态切换
    ghost:ChangeToGestalt(not ghost:HasTag("gestalt"))

    -- 物品消耗
    if inst.components.stackable and inst.components.stackable:IsStack() then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end

    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local entity_physics = inst.entity:AddPhysics()
    entity_physics:SetMass(1.0)
    entity_physics:SetFriction(0.1)
    entity_physics:SetDamping(0.0)
    entity_physics:SetRestitution(0.5)
    entity_physics:SetCollisionGroup(COLLISION.ITEMS)
    entity_physics:ClearCollisionMask()
    entity_physics:CollidesWith(COLLISION.WORLD)
    entity_physics:SetSphere(0.5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lotus")
    inst.AnimState:SetBuild("lotus")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetMultColour(unpack(MIN_FADE_COLOUR))
    inst.AnimState:SetHaunted(true)
    inst.Transform:SetScale(0.6, 0.6, 0.6)

    inst:AddTag("haunted")
    inst:AddTag("ghostflower")

	MakeInventoryFloatable(inst, "small")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("lutosmutation")
    inst.mutation = mutation

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lotusflower_gestalt"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/lotusflower_gestalt.xml"

    MakeHauntableLaunch(inst)


    return inst
end

return Prefab("abigail_gestalt_lotus", fn, {})
