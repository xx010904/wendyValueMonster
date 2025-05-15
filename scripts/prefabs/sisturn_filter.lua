local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- MakeInventoryPhysics(inst)
    inst:AddTag("filter_station")       -- 供主容器查找使用
    inst:AddTag("NOCLICK")              -- 玩家无法点击打开
    inst:AddTag("CLASSIFIED")           -- 防止UI显示名字

    -- inst:AddTag("saltlick")

    -- inst.AnimState:SetBuild("moonglasspool_tile")
    -- inst.AnimState:SetBank("moonglasspool_tile")
    -- inst.AnimState:PlayAnimation("smallpool_idle", true)
    -- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
    -- inst.AnimState:SetSortOrder(3)
    -- inst.AnimState:SetLightOverride(0.25)
    -- inst.Transform:SetScale(0.65, 0.65, 0.65)

    -- inst.AnimState:SetBuild("sisturn_salt_pool")
    -- inst.AnimState:SetBank("sisturn_salt_pool")
    -- inst.AnimState:PlayAnimation("idle4", true)
    -- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
    -- inst.AnimState:SetSortOrder(3)
    -- inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sisturn_filter")

    -- 设定为隐藏容器，永远不被自动关闭（仅由主容器控制）
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.canbeopened = true

    inst._link_sisturn = nil

    inst:DoPeriodicTask(60, function()
        if inst._link_sisturn == nil then
            inst.components.container:DropEverything()
            inst:Remove()
        end
    end)

    return inst
end

return Prefab("sisturn_filter", fn, {})
