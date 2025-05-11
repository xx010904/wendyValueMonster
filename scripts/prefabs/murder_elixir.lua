local function StartEffect(inst)
    if inst._trailtask == nil then
        inst._trailtask = inst:DoPeriodicTask(0.75, function()
            local x, y, z = inst.Transform:GetWorldPosition()
            local offsets = {
                {0.25, 0},   -- right
                {-0.25, 0},  -- left
                {0, 0.25},   -- front
                {0, -0.25},  -- back
            }

            for _, offset in ipairs(offsets) do
                local rand_x = offset[1] + math.random(-3, 3) * 0.05
                local rand_z = offset[2] + math.random(-3, 3) * 0.05

                local fx = SpawnPrefab("wurt_terraformer_fx_shadow")
                fx.Transform:SetPosition(x + rand_x, y, z + rand_z)

                -- 添加随机旋转角度（0 ~ 360 度）
                fx.Transform:SetRotation(math.random() * 360)
            end
        end)
    end
end

local function StopEffect(inst)
    if inst._trailtask ~= nil then
        inst._trailtask:Cancel()
        inst._trailtask = nil
    end
end

local function OnDropped(inst)
    StartEffect(inst)
end

local function OnPutInInventory(inst)
    StopEffect(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small", 0.15, 0.55)

    inst.AnimState:SetBank("ghostly_elixirs")
    inst.AnimState:SetBuild("ghostly_elixirs")
    inst.AnimState:PlayAnimation("shadow")

    inst:AddTag("murder_elixir")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "murder_elixir"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/murder_elixir.xml"

    inst:AddComponent("murderelixirusage")

    inst:AddComponent("stackable")
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeHauntableLaunch(inst)

    inst:DoTaskInTime(0, function()
        if inst.components.inventoryitem and not inst.components.inventoryitem:IsHeld() then
            StartEffect(inst)
        end
    end)    

    -- 添加监听器
    inst:ListenForEvent("ondropped", OnDropped)
    inst:ListenForEvent("onputininventory", OnPutInInventory)

    return inst
end

return Prefab("murder_elixir", fn)
