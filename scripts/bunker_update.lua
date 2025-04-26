AddPrefabPostInit("gravestone", function (inst)
    inst:AddComponent("gravebunker")
    inst:DoPeriodicTask(1, function()
        if inst.components.upgradeable then
            if inst.components.upgradeable.stage >= 2 then
                inst:AddTag("gravebunker")
            else
                inst:RemoveTag("gravebunker")
            end
        end
        if TheWorld.components.decoratedgrave_ghostmanager then
            if inst:HasTag("hashider") then
                TheWorld.components.decoratedgrave_ghostmanager:UnregisterDecoratedGrave(inst)
            else
                TheWorld.components.decoratedgrave_ghostmanager:RegisterDecoratedGrave(inst)
            end
        end
    end)
end)

---- 钻墓碑动作
-- 定义
local BUNK = Action({priority=1, rmb=true, distance=1, mount_valid=true })
BUNK.id = "BUNK"
BUNK.str = STRINGS.ACTIONS.BUNK
BUNK.fn = function(act)
    if act.doer ~= nil then
        local bunker = act.target
        if bunker and bunker.components.upgradeable and bunker.components.upgradeable.stage >= 2 then
            bunker.components.gravebunker:DoBunk(act.doer)
        end
        return true
    end
end
AddAction(BUNK)

-- 定义动作选择器
--args: inst, doer, target, actions, right
AddComponentAction("SCENE", "gravebunker", function(inst, doer, actions, right)
    if doer and doer.prefab == "wendy" and not inst:HasTag("hashider") and inst:HasTag("gravebunker") and not inst:HasTag("bunkerCD") then
        table.insert(actions, ACTIONS.BUNK)
    end
end)

-- 定义sg
local function SetSleeperSleepState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:AddImmunity("sleeping")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:IgnoreAll("sleeping")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Disable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(false)
        inst.components.playercontroller:Enable(false)
    end
    inst:OnSleepIn()
    inst.components.inventory:Hide()
    inst:PushEvent("ms_closepopups")
    inst:ShowActions(false)
end

AddStategraphState('wilson',
    State{
        name = "bunker",
        tags = { "bunker", "busy", "silentmorph" },

        onenter = function(inst)
            inst.components.health:SetInvincible(true)
            inst.components.locomotor:Stop()

            local target = inst:GetBufferedAction().target --gravestone

            inst.AnimState:PlayAnimation("pickup")
            inst.sg:SetTimeout(6 * FRAMES)

            SetSleeperSleepState(inst)
        end,

        ontimeout = function(inst)
            local bufferedaction = inst:GetBufferedAction()
            if bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
                return
            end
            local gravestone = bufferedaction.target
            if gravestone == nil or
                not gravestone.components.gravebunker or
                not gravestone:HasTag("gravebunker") or
                gravestone:HasTag("hashider")
            then
                --Edge cases, don't bother with fail dialogue
                --Also, think I will let smolderig pass this one
                inst:PushEvent("performaction", { action = inst.bufferedaction })
                inst:ClearBufferedAction()
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
            else
                inst:PerformBufferedAction()
                inst:Hide()
                if inst.Physics ~= nil then
                    inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                end
                if inst.DynamicShadow ~= nil then
                    inst.DynamicShadow:Enable(false)
                end
                inst.sg:AddStateTag("bunking")
                inst.sg:RemoveStateTag("busy")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,

        onexit = function(inst)
            local gravestone = inst.usingbunker
            if gravestone then
                gravestone.components.gravebunker:DoLeave(inst)
            end
        end,
    }
)

AddStategraphState('wilson_client',
    State{
        name = "bunker",
        tags = { "bunker", "busy" },
        server_states = { "bunker" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(2)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickup_pst")
            inst.sg:GoToState("idle", true)
        end,
    }
)

-- -- Stategraph
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.BUNK, function(inst, action) return "bunker" end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.BUNK, function(inst, action) return "bunker" end))


AddStategraphState('wilson',
    State{
        name = "getoffbunker",
        tags = { "busy", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wakeup")
            if inst and inst.components.drownable and inst.components.moisture then
                inst.components.drownable:TakeDrowningDamage()
            end

            local puddle = SpawnPrefab("sanity_lower")
            puddle.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_GET_OFF_BUNKER"))

                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)

