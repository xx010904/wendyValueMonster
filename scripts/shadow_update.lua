local POSSESSION_COOLDOWN = 10
local function abigailPossession(inst, player)
    inst.Transform:SetPosition(player.Transform:GetWorldPosition())
    player.components.ghostlybond:Recall(true)

    -- player:AddComponent("possessionaoe")
    -- player.components.possessionaoe:Enable()

    -- player:ListenForEvent("ghostlybond_summoncomplete", function()
    --     if player.components.possessionaoe then
    --         player.components.ghostlybond:Recall(true)
    --         -- player.components.possessionaoe:Disable()
    --         -- player:RemoveComponent("possessionaoe")
    --         -- -- 需要分开一会
    --         -- inst.needApart = true
    --         -- inst:DoTaskInTime(POSSESSION_COOLDOWN, function()
    --         --     inst.needApart = false
    --         -- end)
    --     end
    -- end)
    player:AddDebuff("murder_abigail_buff", "murder_abigail_buff")
    return true
end

-- 在 prefab 初始化中绑定组件
AddPrefabPostInit("abigail_flower", function(inst)
    inst:AddComponent("possessionflower") -- 占位用来触发动作
end)

AddPrefabPostInit("wendy", function(inst)

    inst._has_murder_abigail_buff = false
    inst._murder_abigail_buff_time_left = nil

    -- 保存
    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then old_OnSave(inst, data) end

        if inst.components.debuffable and inst.components.debuffable:HasDebuff("murder_abigail_buff") then
            data.has_murder_abigail_buff = true

            local buff = inst.components.debuffable:GetDebuff("murder_abigail_buff")
            if buff and buff.components and buff.components.timer then
                local t = buff.components.timer:GetTimeLeft("expire")
                data.murder_abigail_buff_time_left = t
                print("[BuffSave] Saved murder_abigail_buff with", t, "seconds left")
            else
                print("[BuffSave] Buff found but timer missing!")
            end
        else
            print("[BuffSave] No murder_abigail_buff found on Wendy")
        end
    end

    -- 读取
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then old_OnLoad(inst, data) end

        if data and data.has_murder_abigail_buff then
            inst._has_murder_abigail_buff = true
            inst._murder_abigail_buff_time_left = data.murder_abigail_buff_time_left or 0

            print("[BuffLoad] Will restore murder_abigail_buff with", inst._murder_abigail_buff_time_left, "seconds left")

            inst:DoTaskInTime(0, function()
                if inst:IsValid() and inst.components.debuffable then
                    inst.components.debuffable:AddDebuff("murder_abigail_buff", "murder_abigail_buff")

                    local buff = inst.components.debuffable:GetDebuff("murder_abigail_buff")
                    if buff and buff.components and buff.components.timer and inst._murder_abigail_buff_time_left then
                        buff.components.timer:StopTimer("expire")
                        buff.components.timer:StartTimer("expire", inst._murder_abigail_buff_time_left)
                        print("[BuffLoad] Timer restarted for murder_abigail_buff:", inst._murder_abigail_buff_time_left)
                    else
                        print("[BuffLoad] Failed to restart buff timer!")
                    end
                end
            end)
        else
            print("[BuffLoad] No murder_abigail_buff to restore")
        end
    end
end)


-- 定义动作
local MURDER_ABIGAIL = Action({priority=10, mount_valid=false})
MURDER_ABIGAIL.id = "MURDER_ABIGAIL"
MURDER_ABIGAIL.str = STRINGS.ACTIONS.MURDER_ABIGAIL or "Murder Abigail"
MURDER_ABIGAIL.fn = function(act)
    local flower = act.target -- 地上的花
    local doer = act.doer     -- wendy 本人

    if flower and flower.prefab == "abigail_flower" and
       doer and doer.prefab == "wendy" and
       doer.components.ghostlybond and
       doer.components.ghostlybond.ghost
    then
        local ghost = doer.components.ghostlybond.ghost
        local fx = SpawnPrefab("abigailsummonfx")
        fx.entity:SetParent(doer.entity)
        local skin_build = flower:GetSkinBuild()
        if skin_build ~= nil then
            fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
        end
        flower:Remove()
        abigailPossession(ghost, doer)
        return true
    end

    return false
end
AddAction(MURDER_ABIGAIL)


-- 动作选择器 让 abigail_flower 右键使用时识别目标是 wendy
AddComponentAction("SCENE", "possessionflower", function(inst, doer, actions, right)
    if right and doer.prefab == "wendy" then
        table.insert(actions, ACTIONS.MURDER_ABIGAIL)
    end
end)

-- 添加到 StateGraph
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MURDER_ABIGAIL, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MURDER_ABIGAIL, "dolongaction"))