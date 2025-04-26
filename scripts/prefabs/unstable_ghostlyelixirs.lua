local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

local function OnHit(inst, attacker, target)
    local name = inst.prefab:match("unstable_ghostlyelixir_(.+)")
    local x, y, z = inst.Transform:GetWorldPosition()
    inst:Remove()
    local brust = SpawnPrefab("ghostlyelixir_"..name.."_fx")
    if not brust then
        brust = SpawnPrefab("ghostlyelixir_retaliation_fx")
    end
    brust.Transform:SetPosition(x, y-2.5, z)
    local cloud = SpawnPrefab("unstable_ghostlyelixir_cloud_"..name)
    if cloud then
        cloud.Transform:SetPosition(x, y, z)
    end
end

local function onequip(inst, owner)
    local name = inst.prefab:match("unstable_ghostlyelixir_(.+)")
    owner.AnimState:OverrideSymbol("swap_object", "swap_unstable_ghostlyelixir_"..name, "swap_unstable_ghostlyelixir_"..name)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
    inst.Physics:SetCapsule(.2, .2)
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function MakeUnstableGhostlyElixir(name)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetTwoFaced()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("unstable_ghostlyelixir_"..name)
        inst.AnimState:SetBuild("unstable_ghostlyelixir_"..name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetDeltaTimeMultiplier(.75)

        inst:AddComponent("reticule")
        inst.components.reticule.targetfn = ReticuleTargetFn
        inst.components.reticule.ease = true

        inst:AddTag("allow_action_on_impassable")
        inst:AddTag("show_spoilage")
        inst:AddTag("ghostlyelixir")

        MakeInventoryFloatable(inst, "small", 0.1, 0.8)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor")

        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(15)
        inst.components.complexprojectile:SetGravity(-35)
        inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
        inst.components.complexprojectile:SetOnLaunch(onthrown)
        inst.components.complexprojectile:SetOnHit(OnHit)

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "unstable_ghostlyelixir_"..name
        inst.components.inventoryitem.atlasname = "images/inventoryimages/unstable_ghostlyelixir_"..name..".xml"

        inst:AddComponent("stackable")

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.equipstack = true

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(TUNING.UNARMED_DAMAGE)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "ghostlyelixir_"..name

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("unstable_ghostlyelixir_"..name, fn, {}, {})
end

return MakeUnstableGhostlyElixir("revive"),
        MakeUnstableGhostlyElixir("speed"),
        MakeUnstableGhostlyElixir("attack"),
        MakeUnstableGhostlyElixir("retaliation"),
        MakeUnstableGhostlyElixir("shield"),
        MakeUnstableGhostlyElixir("fastregen"),
        MakeUnstableGhostlyElixir("slowregen")