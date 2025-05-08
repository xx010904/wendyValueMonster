-- 在 prefab 初始化中绑定组件
AddPrefabPostInit("abigail_flower", function(inst)
    inst:AddComponent("possessionflower") -- 占位用来触发动作
end)

---- 定义动作，谋杀地上的花
local MURDER_ABIGAIL = Action({priority=10, mount_valid=false})
MURDER_ABIGAIL.id = "MURDER_ABIGAIL"
MURDER_ABIGAIL.str = STRINGS.ACTIONS.MURDER_ABIGAIL or "Murder Abigail!"
MURDER_ABIGAIL.fn = function(act)
    local flower = act.target
    local doer = act.doer

    if flower and flower.components.possessionflower then
        return flower.components.possessionflower:DoMurder(doer)
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


---- 定义动作，谋杀药水
local function find_abigail_flower(item)
    return item:HasTag("abigail_flower")
end

local MURDER_ELIXIR = Action({priority=1, rmb=true, distance=1, mount_valid = false})
MURDER_ELIXIR.id = "MURDER_ELIXIR"
MURDER_ELIXIR.str = STRINGS.ACTIONS.MURDER_ABIGAIL or "Murder Abigail!"
MURDER_ELIXIR.fn = function(act)
    local doer = act.doer
    local object = act.invobject -- 药水
    if doer and object and doer.components.inventory then
        local flower = doer.components.inventory:FindItem(find_abigail_flower)
        if flower then
            if flower.components.possessionflower then
                local success = flower.components.possessionflower:DoMurder(doer)
                if success then
                    object:Remove()
                    return true
                end
            end
        else
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_NO_FLOWER_INVENTORY"), nil, true)
            return true
        end
    end
    return true
end
AddAction(MURDER_ELIXIR)

--args: inst, doer, actions, right
AddComponentAction("INVENTORY", "murderelixirusage", function(inst, doer, actions, right)
    if inst:HasTag("murder_elixir") and doer ~= nil then
        table.insert(actions, ACTIONS.MURDER_ELIXIR)
    end
end)

-- sg
AddStategraphState('wilson',
    State{
        name = "murder_elixir",
        tags = { "doing", "busy" },

        onenter = function(inst)
            print("onenter:",inst)
            inst.components.locomotor:Stop()
            local flower = inst.components.inventory:FindItem(find_abigail_flower)
            if flower then
                inst.AnimState:PlayAnimation("wendy_elixir_pre")
                inst.AnimState:PushAnimation("wendy_elixir",false)
                inst.SoundEmitter:PlaySound("meta5/wendy/pour_elixir_f17")

                inst.sg.statemem.action = inst:GetBufferedAction()
                if inst.sg.statemem.action ~= nil then

                    inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs", "ghostly_elixirs_shadow_swap")

                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                        else
                            inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                        end
                    end
                end
            end
            inst.sg:SetTimeout(50 * FRAMES)
        end,

        timeline =
        {
            FrameEvent(4, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            FrameEvent(19, function(inst)
                if not inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    }
)

AddStategraphState('wilson_client',
    State{
        name = "murder_elixir",
        tags = { "busy" },
        server_states = { "murder_elixir" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_elixir_pre")
            inst.AnimState:PushAnimation("wendy_elixir_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.invobject ~= nil then

                inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs", "ghostly_elixirs_shadow_swap")
            end
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
    return "murder_elixir"
end
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.MURDER_ELIXIR, stategraph))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.MURDER_ELIXIR, stategraph))