local MIN_FADE_VALUE = 0.40
local MIN_FADE_COLOUR = {1.00, 1.00, 1.00, MIN_FADE_VALUE}
local function mutation(inst, caster)
	if caster ~= nil then
		if caster.components.ghostlybond and caster.components.ghostlybond.ghost then
            if not caster.components.ghostlybond.summoned then
                return false, "NOGHOST"
            end
            local ghost = caster.components.ghostlybond.ghost
            if ghost:HasTag("gestalt") then
                ghost:ChangeToGestalt(false)
            else
                ghost:ChangeToGestalt(true)
            end
            if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
                inst.components.stackable:Get():Remove()
            else
                inst:Remove()
            end
            return true
        end
	end
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

return Prefab("abigail_gestalt_lily", fn, {})
