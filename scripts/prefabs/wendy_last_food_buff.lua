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

    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
    inst._followtask = inst:DoPeriodicTask(0.13, AlignToTarget, nil, target)
    AlignToTarget(inst, target)
end

local function OnDetached(inst)
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
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

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

