local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst:AddTag("filter_station")       -- 供主容器查找使用
    inst:AddTag("NOCLICK")              -- 玩家无法点击打开
    inst:AddTag("CLASSIFIED")           -- 防止UI显示名字

    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("treasure_chest")
    inst.AnimState:PlayAnimation("closed")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sisturn_filter") -- 你需要在containers.lua中注册它

    -- 设定为隐藏容器，永远不被自动关闭（仅由主容器控制）
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.canbeopened = true

    inst:DoTaskInTime(0, function()
        inst:RemoveTag("structure") -- 禁止建筑类交互
    end)

    return inst
end

return Prefab("sisturn_filter", fn, {})
