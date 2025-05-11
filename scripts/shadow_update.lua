-- 在 prefab 初始化中绑定组件
AddPrefabPostInit("abigail_flower", function(inst)
    inst:AddComponent("possessionflower") -- 占位用来触发动作
end)

---- 添加制作配方
AddRecipe2("murder_elixir",
{
    Ingredient("ghostlyelixir_shadow", 1),
    Ingredient("nightmarefuel", 2),
},
TECH.NONE,
{
    product = "murder_elixir", -- 唯一id
    actionstr = "THRIVING", -- 动作id
    atlas = "images/inventoryimages/murder_elixir.xml",
    image = "murder_elixir.tex",
    builder_skill= "wendy_shadow_3",
    description = "murder_elixir", -- 描述的id，而非本身
    numtogive = 1,
}
)
AddRecipeToFilter("murder_elixir", "CHARACTER")


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
    local ghost = act.doer.components.ghostlybond and act.doer.components.ghostlybond.ghost
    if ghost then
        local killfx = SpawnPrefab("murder_abigail_fx")
        killfx.entity:SetParent(ghost.entity)
        ghost:DoTaskInTime(1.4, function()
            if doer and object and doer.components.inventory then
                local flower = doer.components.inventory:FindItem(find_abigail_flower)
                if flower then
                    if flower.components.possessionflower then
                        local success = flower.components.possessionflower:DoMurder(doer)
                        if success then
                            if object.components.stackable then
                                object.components.stackable:Get():Remove()
                            else
                                object:Remove()
                            end
                            return true
                        end
                    end
                    return true
                end
            end
        end)
    end
    return true
end
AddAction(MURDER_ELIXIR)

--args: inst, doer, actions, right
AddComponentAction("INVENTORY", "murderelixirusage", function(inst, doer, actions, right)

    if inst:HasTag("murder_elixir") and doer ~= nil and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_shadow_3") then
        table.insert(actions, ACTIONS.MURDER_ELIXIR)
    end
end)

-- sg
AddStategraphState('wilson',
    State{
        name = "murder_elixir",
        tags = { "doing", "busy" },

        onenter = function(inst)
            -- print("onenter:",inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_elixir_pre")
            inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs", "ghostly_elixirs_shadow_swap")
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.sg:SetTimeout(20 * FRAMES)
        end,

        timeline =
        {
            FrameEvent(4, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            FrameEvent(14, function(inst)
                local flower = inst.components.inventory:FindItem(find_abigail_flower)
                if flower then
                    local skin_build = flower:GetSkinBuild()
                    if skin_build ~= nil then
                        inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                    if inst.components.ghostlybond and inst.components.ghostlybond.ghost and inst.components.ghostlybond.summoned then
                        inst.SoundEmitter:PlaySound("meta5/wendy/pour_elixir_f17")
                        inst.AnimState:PushAnimation("wendy_elixir", false)
                        inst:PerformBufferedAction()
                    else
                        inst.components.talker:Say(GetString(inst, "ANNOUNCE_GHOST_NOT_SUMMONED"), nil, true)
                        inst.sg:GoToState("idle", true)
                    end
                else
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_NO_FLOWER_INVENTORY"), nil, true)
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
            inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs", "ghostly_elixirs_shadow_swap")

            if inst.components.ghostlybond and inst.components.ghostlybond.ghost and inst.components.ghostlybond.summoned then
                inst.AnimState:PushAnimation("wendy_elixir_lag", false)
                inst:PerformPreviewBufferedAction()
            end
            inst.sg:SetTimeout(1)
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