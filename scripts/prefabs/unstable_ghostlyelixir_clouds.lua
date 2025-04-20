local TICK_PERIOD = .5

local OVERLAY_COORDS =
{
    { 0,0,0,               1 },
    { 5/2,0,0,             0.8, 0 },
    { 2.5/2,0,-4.330/2,    0.8 , 5/3*180 },
    { -2.5/2,0,-4.330/2,   0.8, 4/3*180 },
    { -5/2,0,0,            0.8, 3/3*180 },
    { 2.5/2,0,4.330/2,     0.8, 1/3*180 },
    { -2.5/2,0,4.330/2,    0.8, 2/3*180 },
}

local function SpawnOverlayFX(inst, i, set, isnew, name)
    if i ~= nil then
        inst._overlaytasks[i] = nil
        if next(inst._overlaytasks) == nil then
            inst._overlaytasks = nil
        end
    end

    local fx = SpawnPrefab("unstable_ghostlyelixir_cloud_overlay_"..name)
    fx.entity:SetParent(inst.entity)
    fx.Transform:SetPosition(set[1] * .85, 0, set[3] * .85)
    fx.Transform:SetScale(set[4], set[4], set[4])
    if set[5] ~= nil then
        fx.Transform:SetRotation(set[4])
    end

    if not isnew then
        fx.AnimState:PlayAnimation("sleepcloud_overlay_loop")
        fx.AnimState:SetTime(math.random() * .7)
    end

    if inst._overlayfx == nil then
        inst._overlayfx = { fx }
    else
        table.insert(inst._overlayfx, fx)
    end
end

local function CreateBase(isnew)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("abigail_attack_fx")
    inst.AnimState:SetBuild("abigail_attack_fx")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)
    local scale = 1.35
    inst.Transform:SetScale(scale, scale, scale)
    inst.AnimState:SetDeltaTimeMultiplier(0.55)
    inst.AnimState:SetMultColour(0, 0, 0, .46)
    inst.AnimState:SetHaunted(true)

    inst:AddTag("haunted")

    if isnew then
        inst.AnimState:PlayAnimation("attack1_ground_loop")
		-- inst.AnimState:SetFrame(12)
        inst.AnimState:PushAnimation("attack3_ground_loop", false)
    else
        inst.AnimState:PlayAnimation("attack3_ground_loop")
    end

    return inst
end

----

local function OnStateDirty(inst)
    if inst._state:value() > 0 then
        if inst._inittask ~= nil then
            inst._inittask:Cancel()
            inst._inittask = nil
        end
        if inst._state:value() == 1 then
            if inst._basefx == nil then
                inst._basefx = inst._create_base_fn(false)
                inst._basefx.entity:SetParent(inst.entity)
            end
        elseif inst._basefx ~= nil then
            inst.AnimState:SetDeltaTimeMultiplier(0.25)
            inst._basefx.AnimState:PlayAnimation("attack3_ground_pst")
        end
    end
end

local function OnAnimOver(inst)
    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(1)
end

local function OnOverlayAnimOver(fx)
    fx.AnimState:PlayAnimation("sleepcloud_overlay_loop")
end

local function KillOverlayFX(fx)
    fx:RemoveEventCallback("animover", OnOverlayAnimOver)
    fx.AnimState:PlayAnimation("sleepcloud_overlay_pst")
end

local function DoDisperse(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    if inst._drowsytask ~= nil then
        inst._drowsytask:Cancel()
        inst._drowsytask = nil
    end

    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(2)

    inst.AnimState:PlayAnimation("sleepcloud_pst")
    inst.SoundEmitter:KillSound("spore_loop")
    inst.persists = false
    inst:DoTaskInTime(3-1.8, inst.Remove) --anim len + 1.5 sec

    if inst._basefx ~= nil then
        inst._basefx.AnimState:PlayAnimation("attack3_ground_pst")
    end

    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:DoTaskInTime(i == 1 and 0 or math.random() * .5, KillOverlayFX)
        end
    end
end

local function OnTimerDone(inst, data)
    if data.name == "disperse" then
        DoDisperse(inst)
    end
end

local function OnLoad(inst, data)
    --Not a brand new cloud, cancel initial sound and pre-anims
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    inst:RemoveEventCallback("animover", OnAnimOver)

    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:Remove()
        end
        inst._overlayfx = nil
    end

    local t = inst.components.timer:GetTimeLeft("disperse")
    if t == nil or t <= 0 then
        if inst._drowsytask ~= nil then
            inst._drowsytask:Cancel()
            inst._drowsytask = nil
        end
        inst._state:set(2)
        inst.SoundEmitter:KillSound("spore_loop")
        inst:Hide()
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    else
        inst._state:set(1)
        inst.AnimState:PlayAnimation("sleepcloud_loop", true)

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst._basefx = inst._create_base_fn(false)
            inst._basefx.entity:SetParent(inst.entity)
        end

        for i, v in ipairs(OVERLAY_COORDS) do
            SpawnOverlayFX(inst, nil, v, false, inst.cloudName)
        end
    end
end

local function InitFX(inst)
    inst._inittask = nil

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst._basefx = inst._create_base_fn(true)
        inst._basefx.entity:SetParent(inst.entity)
    end
end

local ONEOF_TAGS = { "abigail", "player" }
local CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local function DoElixirBuff(inst, name)
    local x, y, z = inst.Transform:GetWorldPosition()
    local range = 3.5
    local t = GetTime()
    local ents = TheSim:FindEntities(x, y, z, range, nil, CANT_TAGS, ONEOF_TAGS)
    for i, ent in ipairs(ents) do
		ent:AddDebuff("unstable_ghostlyelixir_buff_"..name, "unstable_ghostlyelixir_buff_"..name)
    end
end

local function SetOwner(inst, owner)
	inst.owner = owner
end

local function MakeUnstableGhostlyElixirCloud(name)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("unstable_ghostlyelixir_cloud_"..name)
        inst.AnimState:SetBuild("unstable_ghostlyelixir_cloud_"..name)
        inst.AnimState:PlayAnimation("sleepcloud_pre")

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst:AddTag("notarget")

        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")

        inst._state = net_tinybyte(inst.GUID, "sleepcloud._state", "statedirty")

        inst._inittask = inst:DoTaskInTime(0, InitFX)

        inst._create_base_fn = CreateBase

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            inst:ListenForEvent("statedirty", OnStateDirty)

            return inst
        end

        inst._drowsytask = inst:DoPeriodicTask(TICK_PERIOD, DoElixirBuff, nil, name)

        inst.AnimState:PushAnimation("sleepcloud_loop", true)
        inst:ListenForEvent("animover", OnAnimOver)

        inst:AddComponent("timer")
        local duration = (target:HasTag("player") and inst.potion_tunings.DURATION_PLAYER) or inst.potion_tunings.DURATION
        inst.components.timer:StartTimer("disperse", TUNING.SLEEPBOMB_DURATION)

        inst:ListenForEvent("timerdone", OnTimerDone)

        inst.cloudName = name
        inst.SetOwner = SetOwner
        inst.OnLoad = OnLoad

        inst._overlaytasks = {}
        for i, v in ipairs(OVERLAY_COORDS) do
            inst._overlaytasks[i] = inst:DoTaskInTime(i == 1 and 0 or math.random() * .7, SpawnOverlayFX, i, v, true, name)
        end

        return inst
    end

    ----

    return Prefab("unstable_ghostlyelixir_cloud_"..name, fn, {}, {})
end

local function MakeUnstableGhostlyElixirCloudOverlay(name)
    local function overlayfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.Transform:SetTwoFaced()

        inst.AnimState:SetBank("unstable_ghostlyelixir_cloud_"..name)
        inst.AnimState:SetBuild("unstable_ghostlyelixir_cloud_"..name)
        inst.AnimState:PlayAnimation("sleepcloud_overlay_pre")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", OnOverlayAnimOver)

        inst.persists = false

        return inst
    end

    return Prefab("unstable_ghostlyelixir_cloud_overlay_"..name, overlayfn, {})
end


return MakeUnstableGhostlyElixirCloud("revive"),
        MakeUnstableGhostlyElixirCloud("speed"),
        MakeUnstableGhostlyElixirCloud("attack"),
        MakeUnstableGhostlyElixirCloud("retaliation"),
        MakeUnstableGhostlyElixirCloud("shield"),
        MakeUnstableGhostlyElixirCloud("fastregen"),
        MakeUnstableGhostlyElixirCloud("slowregen"),
        MakeUnstableGhostlyElixirCloudOverlay("revive"),
        MakeUnstableGhostlyElixirCloudOverlay("speed"),
        MakeUnstableGhostlyElixirCloudOverlay("attack"),
        MakeUnstableGhostlyElixirCloudOverlay("retaliation"),
        MakeUnstableGhostlyElixirCloudOverlay("shield"),
        MakeUnstableGhostlyElixirCloudOverlay("fastregen"),
        MakeUnstableGhostlyElixirCloudOverlay("slowregen")