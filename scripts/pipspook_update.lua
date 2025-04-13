AddPrefabPostInit("ghostflower", function(inst)
    inst:AddComponent("hiresmallghost")
end)

---- 雇佣小惊吓动作
-- 定义
local HIRE_PIPSPOOK = Action({priority=1, rmb=false, distance=1, mount_valid=true })
HIRE_PIPSPOOK.id = "HIRE_PIPSPOOK"
HIRE_PIPSPOOK.str = STRINGS.ACTIONS.HIRE_PIPSPOOK
HIRE_PIPSPOOK.fn = function(act)
    -- act.target.taskTime = 60
    -- act.target._farm_task = act.target:DoPeriodicTask(1.6, doFarmWork)
    -- 干掉一个
    if act.invobject and act.invobject.components.stackable then
        act.invobject.components.stackable:Get():Remove()
    end
    if act.doer.components.talker then
        act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SMALLGHOST_LEAVE"), nil, true)
    end
    local lagTime = math.random(40, 60)
    SpawnPrefab("ghostlyelixir_speed_dripfx").Transform:SetPosition(act.target.Transform:GetWorldPosition())
    act.target:LinkToPlayer(act.doer)
    act.target:StopBrain()
    act.target:ListenForEvent("animover", function(inst)
        if inst.AnimState:IsCurrentAnimation("quest_completed") then
            -- print("act.target dissipate123")
            inst:Hide()
            inst.DynamicShadow:SetSize(0.0, 0.0)
            inst.Physics:Teleport(0, 0, 0)
            inst.components.locomotor:StopMoving()
            -- 延迟删除是因为墓碑马上会生成
            inst:DoTaskInTime(lagTime, function(inst)
                if inst and inst:IsValid() then
                    inst:Remove()
                end
            end)
        end
    end)
    act.target.AnimState:PlayAnimation("quest_completed", false)

    act.doer:DoTaskInTime(lagTime, function(inst)
        if inst and inst:IsValid() then
            local x, y, z = inst.Transform:GetWorldPosition()
            local offset = Vector3(math.random(-1, 1), 0, math.random(-1, 1))
            local spawn_pos = Vector3(x, y, z) + offset
            local smallghost = SpawnPrefab("smallghost_giver")
            smallghost.Transform:SetPosition(spawn_pos:Get())
            if act.doer.components.talker then
                act.doer.components.talker:Say(GetString(inst, "ANNOUNCE_SMALLGHOST_BACK"), nil, true)
            end
        end
    end)
    return true
end
AddAction(HIRE_PIPSPOOK)

-- 定义动作选择器
--args: inst, doer, target, actions, right
AddComponentAction("USEITEM", "hiresmallghost", function(inst, doer, target, actions, right)
    if doer and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_smallghost_3") and target.prefab == "smallghost" then
        table.insert(actions, ACTIONS.HIRE_PIPSPOOK)
    end
end)

-- Stategraph
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.HIRE_PIPSPOOK, function(inst, action) return "give" end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.HIRE_PIPSPOOK, function(inst, action) return "give" end))