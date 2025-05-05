require "prefabutil"

-----------------------------------------------------------------------------------------------------------------------------

local SALTLICKER_MUST_TAGS = { "saltlicker" }
local SALTLICKER_CANT_TAGS = { "INLIMBO" }

local IMAGERANGE = 5

local function AlertNearbyCritters(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, TUNING.SALTLICK_CHECK_DIST, SALTLICKER_MUST_TAGS, SALTLICKER_CANT_TAGS)

    local data = { inst = inst }

    for _, ent in ipairs(ents) do
        ent:PushEvent("saltlick_placed", data)
    end
end

local function GetImageNum(inst)
    return tostring(IMAGERANGE - math.ceil(inst.components.finiteuses:GetPercent() * IMAGERANGE) + 1)
end

local function PlayIdle(inst, push)
    if inst:HasTag("burnt") then
        return
    end

    -- local anim = "idle"..inst:GetImageNum()

    -- if push then
    --     inst.AnimState:PushAnimation(anim, true)
    -- else
    --     inst.AnimState:PlayAnimation(anim, true)
    -- end
end

local function OnUsed(inst, data)
    -- inst:PlayIdle()
    local uses = inst.components.finiteuses:GetUses()
    if uses < 20 then
        local alpha = 0.5 + (uses / 20) * 0.5
        inst.AnimState:SetMultColour(1, 1, 1, alpha)
    else
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
    inst.components.finiteuses:SetMaxUses(uses)
end

local function OnBuiltFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/salt_lick_craft")

    inst.AnimState:PlayAnimation("place")

    inst:PlayIdle(true)
    inst:AlertNearbyCritters()
end

local function OnFinished(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle6", true)
    end

    inst:RemoveTag("saltlick")
    inst:Remove()
end

local function OnHammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    -- inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")

    inst:Remove()
end

local function OnHit(inst)
    if inst:HasTag("burnt") then
        return
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/salt_lick_hit")

    inst.AnimState:PlayAnimation("idle1")

    inst:PlayIdle(true)
end

-----------------------------------------------------------------------------------------------------------------------------

local function Regular_OnBurnt(inst)
    inst:RemoveTag("saltlick")

    inst.components.finiteuses:SetUses(0)
end

local function Regular_OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function Regular_OnLoad(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

-----------------------------------------------------------------------------------------------------------------------------

local function CommonFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    -- MakeObstaclePhysics(inst, .4)
    -- inst:AddTag("filter_station")       -- 供主容器查找使用
    -- inst:AddTag("NOCLICK")              -- 玩家无法点击打开
    -- inst:AddTag("CLASSIFIED")           -- 防止UI显示名字

    inst.AnimState:SetBuild("sisturn_salt_marks")
    inst.AnimState:SetBank("sisturn_salt_marks")
    inst.AnimState:PlayAnimation("idle", true)
    -- inst.AnimState:SetBuild("sisturn_salt_pool")
    -- inst.AnimState:SetBank("sisturn_salt_pool")
    -- inst.AnimState:PlayAnimation("idle0", true)
    -- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    -- inst.AnimState:SetMultColour(1, 1, 1, 0) -- 初始透明
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    
    inst:AddTag("structure")
    inst:AddTag("saltlick")
    inst:AddTag("sisturn_saltlick")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnUsed = OnUsed
    inst.PlayIdle = PlayIdle
    inst.GetImageNum = GetImageNum
    inst.AlertNearbyCritters = AlertNearbyCritters

    inst.OnBuiltFn = OnBuiltFn

    inst:AddComponent("inspectable")
    -- inst:AddComponent("lootdropper")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(20)
    inst.components.finiteuses:SetUses(20)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst:PlayIdle()

    inst:ListenForEvent("percentusedchange", inst.OnUsed)

    MakeSnowCovered(inst)
    MakeHauntableLaunch(inst)

    return inst
end

local function RegularFn()
    local inst = CommonFn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnBurnt = Regular_OnBurnt

    inst.OnSave = Regular_OnSave
    inst.OnLoad = Regular_OnLoad

    -- MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    -- inst:ListenForEvent("burntup", inst.OnBurnt)

    inst:AlertNearbyCritters()

    inst:DoPeriodicTask(60, function()
        if inst.components.finiteuses ~= nil then
            inst.components.finiteuses:Use(1)
        end
    end)

    return inst
end


return Prefab("sisturn_saltlick", RegularFn, {})
