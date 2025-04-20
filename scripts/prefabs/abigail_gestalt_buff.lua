local function OnTimerDone(inst, data)
    if data.name == "explode" then
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target)
    if target and target:IsValid() then
        target:ChangeToGestalt(true)
    end
end

local function OnDetached(inst, target)
    if target and target:IsValid() then
        target:ChangeToGestalt(false)
    end
    inst:Remove()
end

local function abigail_gestalt_buff_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("explode", TUNING.SKILLS.WENDY.MURDER_BUFF_DURATION * 60)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("abigail_gestalt_buff", abigail_gestalt_buff_fn)
