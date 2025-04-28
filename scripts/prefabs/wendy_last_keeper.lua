local function GetOwner(inst)
    return inst.components.follower and inst.components.follower.leader or nil
end

local MUST_HAVE_TAGS = {"_combat", "_health"}
local CANTHAVE_TAGS = { "INLIMBO", "epic", "structure", "butterfly", "wall", "balloon", "groundspike", "smashable", "companion"}
local function DoRemove(inst)
    if inst.wating_task then
        inst.wating_task:Cancel()
        inst.wating_task = nil
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    -- 复活吓到周围的生物
    local ents = TheSim:FindEntities(x, y, z, 10, MUST_HAVE_TAGS, CANTHAVE_TAGS)
    for _, target in ipairs(ents) do
        if target.components.hauntable ~= nil and target.components.hauntable.panicable then
            target.components.hauntable:Panic(3)
        end
    end
    inst:Remove()
end

local function OnInit(inst)
    inst.time_left = 120
    inst.wating_task = inst:DoPeriodicTask(1, function()
        -- 到点消失
        if inst.time_left > 0 then
            inst.time_left = inst.time_left - 1
        else
            if inst.components.inventory then
                inst.components.inventory:DropEverything(true)
            end
            DoRemove(inst)
        end
        -- 玩家回来消失
        local x, y, z = inst.Transform:GetWorldPosition()
        local nearest_player = FindClosestPlayerInRange(x, y, z, 4, true)
        local owner = GetOwner(inst)
        if owner and nearest_player and nearest_player == owner and not owner:HasTag("playerghost") and not owner:HasTag("playerghost_fake") then
            if inst.components.inventory and owner.components.inventory then
                inst.components.inventory:TransferInventory(owner)
            end
            DoRemove(inst)
        end
    end, 1)
end

local function OnSave(inst, data)

end

local function OnLoad(inst, data)
    if inst and inst.components.inventory then
        inst.components.inventory:DropEverything(true)
    end
    DoRemove(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    -- inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    -- MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)

    inst.Transform:SetFourFaced(inst)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wendy") -- "waxwell_shadow_mod" Deprecated.
    inst.AnimState:PlayAnimation("death")
    inst.AnimState:PushAnimation("death_idle", true)

    -- inst.AnimState:SetMultColour(1, 1, 1, 1)

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst.ripple_pool = {}
        -- inst:DoPeriodicTask(.6, TryRipple, math.random() * .6, TheWorld.Map)
        -- inst.OnRemoveEntity = OnRemoveEntity
    end

    inst.entity:SetPristine()

    inst:AddTag("ghost")
    inst:AddTag("flying")
    inst:AddTag("girl")
    inst:AddTag("noauradamage")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("wendy_last_keeper")

    -- inst.Light:SetRadius(1.5)
    -- inst.Light:SetIntensity(.75)
    -- inst.Light:SetFalloff(0.5)
    -- inst.Light:SetColour(111/255, 111/255, 111/255)
    -- inst.Light:Enable(true)

    inst.entity:SetPristine()

    inst.GetOwner = GetOwner
    inst.OnInit = OnInit
    OnInit(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()

    local inventory = inst:AddComponent("inventory")
    inventory.maxslots = 100

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    -- inst:AddComponent("soulchain")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("wendy_last_keeper", fn, {}, {})
