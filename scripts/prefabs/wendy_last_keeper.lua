local function GetOwner(inst)
    return inst.components.follower and inst.components.follower.leader or nil
end

local function DoRemove(inst)
    if inst.wating_task then
        inst.wating_task:Cancel()
        inst.wating_task = nil
    end
    inst.AnimState:PlayAnimation("small_happy")
    inst:ListenForEvent("animover", function(inst)
        if inst.AnimState:IsCurrentAnimation("small_happy") then
            -- print("小惊吓small_happy")
            if inst then
                if inst.components.inventory then
                    local owner = GetOwner(inst)
                    if owner and not owner:HasTag("playerghost") then
                        inst.AnimState:PlayAnimation("quest_completed")
                        inst.components.inventory:TransferInventory(owner)
                    else
                        inst.AnimState:PlayAnimation("dissipate")
                        inst.components.inventory:DropEverything(true)
                    end
                else
                    inst.AnimState:PlayAnimation("dissipate")
                end
            end
        elseif inst.AnimState:IsCurrentAnimation("quest_completed") then
            -- print("小惊吓quest_completed")
            inst:Remove()
        elseif inst.AnimState:IsCurrentAnimation("dissipate") then
            -- print("小惊吓dissipate")
            inst:Remove()
        end
    end)
end

local function OnInit(inst)
    inst.time_left = 120
    inst.wating_task = inst:DoPeriodicTask(1, function()
        -- 到点消失
        if inst.time_left > 0 then
            inst.time_left = inst.time_left - 1
        else
            DoRemove(inst)
        end
        -- 玩家回来消失
        local x, y, z = inst.Transform:GetWorldPosition()
        local nearest_player = FindClosestPlayerInRange(x, y, z, 4, true)
        local owner = GetOwner(inst)
        if owner and nearest_player and nearest_player == owner then
            DoRemove(inst)
        end
    end, 10) --至少保管10秒
end

local function OnSave(inst, data)

end

local function OnLoad(inst, data)

end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeTinyGhostPhysics(inst, 0.5, 0.5)

	inst.DynamicShadow:SetSize(0.75, 0.75)

    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    inst.AnimState:SetBank("ghost_kid")
    inst.AnimState:SetBuild("ghost_kid")
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:PushAnimation("idle_sad")

    inst:AddTag("ghost")
    inst:AddTag("ghostkid")
    inst:AddTag("flying")
    inst:AddTag("girl")
    inst:AddTag("noauradamage")
    inst:AddTag("NOBLOCK")

    inst.Light:SetRadius(1.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetColour(111/255, 111/255, 111/255)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    inst.OnInit = OnInit
    OnInit(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    local inventory = inst:AddComponent("inventory")
    inventory.maxslots = 100

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("wendy_last_keeper", fn, {}, {})
