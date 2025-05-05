-- 月晷可以采9朵莲
AddPrefabPostInit("moondial", function(inst)
    -- Hook onload and onsave methods to maintain lotus_create_cd
    local _OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if _OnSave then
            _OnSave(inst, data)
        end
        -- 保存 lotus_create_cd
        if inst.lotus_create_cd then
            data.lotus_create_cd = inst.lotus_create_cd
        end
    end

    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _OnLoad then
            _OnLoad(inst, data)
        end
        -- 恢复 lotus_create_cd
        if data and data.lotus_create_cd then
            inst.lotus_create_cd = data.lotus_create_cd
        else
            inst.lotus_create_cd = 9  -- 默认值为9
        end
    end

    -- 初始化lotus_create_cd字段，默认为9
    if inst.lotus_create_cd == nil then
        inst.lotus_create_cd = 9
    end

    -- 在周围生成特效
    local function createLotus(inst)
        local maxNum = 9 --采9朵莲
        local radius = 1.2
        if inst.lotus_fx == nil then
            inst.lotus_fx = {}
        end
        for _, fx in ipairs(inst.lotus_fx) do
            if fx:IsValid() then
                fx:Remove()  -- 删除现有特效
            end
        end
        for i = 1, maxNum do
            local angle = (i - 1) * (360 / maxNum) * DEGREES
            local offset = Vector3(math.cos(angle), 0, math.sin(angle)) * radius
            local fx = SpawnPrefab("moondial_lotus_fx")
            local pos_x, pos_y, pos_z = inst.Transform:GetWorldPosition()
            fx.Transform:SetPosition(pos_x + offset.x, pos_y, pos_z + offset.z)
            table.insert(inst.lotus_fx, fx)
        end
    end

    if inst.components.ghostgestalter then

        -- 生成莲花数量
        inst:WatchWorldState("moonphase", function(inst, phase)
            if TheWorld.state.moonphase == "full" and not TheWorld.state.isalterawake then
                -- 只有lotus_create_cd <= 0时才生成莲花
                if inst.lotus_create_cd <= 0 then
                    createLotus(inst)
                    inst.lotus_create_cd = 9  -- 生成后重置lotus_create_cd为9
                end
                if inst.lotus_create_cd > 0 then
                    inst.lotus_create_cd = inst.lotus_create_cd - 1
                end
            end
        end)
    end
end)


---- 月灵化的动作
-- 定义
local LOTUSMUTATION = Action({priority=1, rmb=true, distance=1, mount_valid=true })
LOTUSMUTATION.id = "LOTUSMUTATION"
LOTUSMUTATION.str = STRINGS.ACTIONS.LOTUSMUTATION
LOTUSMUTATION.fn = function(act)
    if act.doer.components.skilltreeupdater and act.doer.components.skilltreeupdater:IsActivated("wendy_lunar_3") then
        if act.invobject and act.invobject.components.itemmimic and act.invobject.components.itemmimic.fail_as_invobject then
            return false, "ITEMMIMIC"
        end
        local success, reason = act.invobject:mutation(act.doer)
        -- print("success, reanson")
        return success, reason
    end
    return false
end
AddAction(LOTUSMUTATION)

-- 定义动作选择器
--args: inst, doer, actions, right
AddComponentAction("INVENTORY", "lutosmutation", function(inst, doer, actions, right)
    if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_lunar_3") and inst then
        table.insert(actions, ACTIONS.LOTUSMUTATION)
    end
end)

AddStategraphState('wilson',
    State{
        name = "lutosmutation_pre",
        tags = { "busy", "nointerrupt", "keep_pocket_rummage" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_commune_pre", false)
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("lutosmutation")
            end),
        },
    }
)
AddStategraphState('wilson',
    State{
        name = "lutosmutation",
        tags = { "busy", "nointerrupt", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.AnimState:OverrideSymbol("flower", "abigail_flower_rework", "flower")
            inst.AnimState:PushAnimation("wendy_commune_pst", false)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                SpawnPrefab("abigail_lutos_mutate_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst:PerformBufferedAction()
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("meta5/abigail/gestalt_abigail_dashattack_hit")
            end),
            TimeEvent(33 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:IsCurrentAnimation("wendy_commune_pst") then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)
-- 定义动作的stategraph2
AddStategraphState('wilson_client',
    State{
        name = "lutosmutation_pre",
        tags = {"busy", "nointerrupt"},
        server_states = { "lutosmutation_pre", "lutosmutation" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("wendy_commune_pre", false)
            inst.AnimState:PushAnimation("wendy_commune_lag", false)

            inst.AnimState:OverrideSymbol("flower", "abigail_flower_rework", "flower")
            inst.AnimState:PushAnimation("wendy_commune_pst", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(3)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    }
)

-- Stategraph
local stategraph = function(inst, action)
    return "lutosmutation_pre"
end
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.LOTUSMUTATION, stategraph))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.LOTUSMUTATION, stategraph))