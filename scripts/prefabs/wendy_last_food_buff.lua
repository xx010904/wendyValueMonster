local assets ={}

local FADE_FRAMES = 5

local function OnUpdateFade(inst)
    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function AlignToTarget(inst, target)
    -- 持续掉血
    if target.components.health then
        local delta = target.components.health.maxhealth * (0.13/4)
        target.components.health:DoDelta(-delta)
    end
    inst.Transform:SetRotation(target.Transform:GetRotation())
end

local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)
    -- OnChangeFollowSymbol(inst, target, followsymbol, Vector3(followoffset.x, -255, followoffset.z)) --y越小，位置越高
    OnChangeFollowSymbol(inst, target, followsymbol, Vector3(followoffset.x, -15, followoffset.z)) --y越小，位置越高

    -- buff效果跟随，并且持续掉血
    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
    inst._followtask = inst:DoPeriodicTask(0.13, AlignToTarget, nil, target)
    AlignToTarget(inst, target)

    ---- 新增小惊吓帮拿东西
    local keeper = SpawnPrefab("wendy_last_keeper")
    local x, y, z=target.Transform:GetWorldPosition()
    local a = math.random() * math.pi
    keeper.Transform:SetPosition(x + math.cos(a), y, z + math.sin(a))
    keeper.components.follower:SetLeader(target)
    target.components.inventory:TransferInventory(keeper)
    target.components.locomotor:SetExternalSpeedMultiplier(inst, "last_dash", 1.5)

    ---- 不生成骨架
    target.old_skeleton_prefab = target.skeleton_prefab
    target.skeleton_prefab = nil
end

local function OnDetached(inst)
    local target = inst.entity:GetParent()
    ---- 恢复骨架
    target.skeleton_prefab = target.old_skeleton_prefab
    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "explode" then
        inst.AnimState:PushAnimation("fx_trebleclef", false)
        inst:ListenForEvent("animover", function()
            inst.components.debuff:Stop()
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    -- last light
    inst.Light:SetRadius(12.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetColour(111/255, 111/255, 111/255)
    inst.Light:Enable(true)

    inst.AnimState:SetBank("fx_wathgrithr_buff")
    inst.AnimState:SetBuild("fx_wathgrithr_buff")
    inst.AnimState:PlayAnimation("fx_trebleclef")
    inst.AnimState:PushAnimation("fx_trebleclef", true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)

    inst._fade = net_smallbyte(inst.GUID, "sporebomb._fade", "fadedirty")

    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetChangeFollowSymbolFn(OnChangeFollowSymbol)
    inst.isTrigger = false

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("explode", 99999)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("wendy_last_food_buff", fn, assets)

