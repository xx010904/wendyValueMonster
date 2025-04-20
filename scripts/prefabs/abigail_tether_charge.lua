local assets =
{
    Asset("ANIM", "anim/bishop_attack.zip"),
    Asset("SOUND", "sound/chess.fsb"),
}

local function OnHit(inst, owner, target)
    SpawnPrefab("abigail_tether_charge_hit").Transform:SetPosition(target.Transform:GetWorldPosition())
    local reset_fx = SpawnPrefab("yotb_confetti")
    reset_fx.Transform:SetScale(0.4, 0.4, 0.4)
    reset_fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    inst:Remove()
end

local function OnAnimOver(inst)
    inst:DoTaskInTime(2, inst.Remove)
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

    inst.AnimState:SetBuild("butterfly_moon")
    inst.AnimState:SetBank("butterfly")
    inst.AnimState:PlayAnimation("flight_cycle")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(-14)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(0.01)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)

    inst:DoTaskInTime(0.4, function()
        inst.components.projectile:SetSpeed(24)
        inst.components.projectile:SetHitDist(2)
    end)

    return inst
end

local function PlayHitSound(proxy)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")

    inst:Remove()
end

local function hit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame in case we are about to be removed
        inst:DoTaskInTime(0, PlayHitSound)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(.5, inst.Remove)

    return inst
end

return Prefab("abigail_tether_charge", fn, assets),
    Prefab("abigail_tether_charge_hit", hit_fn)