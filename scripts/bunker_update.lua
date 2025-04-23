local function OnGraveMoundUpdate(inst)
    local function PlaySleepLoopSoundTask(inst, stopfn)
        inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
    end
    
    local function stopsleepsound(inst)
        if inst.sleep_tasks ~= nil then
            for i, v in ipairs(inst.sleep_tasks) do
                v:Cancel()
            end
            inst.sleep_tasks = nil
        end
    end
    
    local function startsleepsound(inst, len)
        stopsleepsound(inst)
        inst.sleep_tasks =
        {
            inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
            inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
        }
    end
    
    local function temperaturetick(inst, sleeper)
        if sleeper.components.temperature ~= nil then
            if inst.is_cooling then
                if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                    sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
                end
            elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
            end
        end
    end
    
    local function onwake(inst, sleeper, nostatechange)
        -- inst.AnimState:PlayAnimation("cocoon_enter")
        -- inst.AnimState:PushAnimation(inst.anims.idle, true)
        inst.SoundEmitter:PlaySound("webber2/common/spiderden/out")
        stopsleepsound(inst)
    end
    
    local function onsleep(inst, sleeper)
        -- inst.AnimState:PlayAnimation("cocoon_enter")
        -- inst.AnimState:PushAnimation("cocoon_sleep_loop", true)
        inst.SoundEmitter:PlaySound("webber2/common/spiderden/in")
        startsleepsound(inst, 77)
    end
    
    local function AddSleepingBag(inst)
        if inst.components.sleepingbag == nil then
            inst:AddComponent("sleepingbag")
        end
    
        inst.components.sleepingbag.onsleep = onsleep
        inst.components.sleepingbag.onwake = onwake
    
        inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 1.5
        inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK * 1.5
        inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    
        inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)
    
        inst:AddTag("tent")
    end

    local function RemoveSleepingBag(inst)
        if inst.components.sleepingbag ~= nil then
            inst.components.sleepingbag:DoWakeUp()
            inst:RemoveComponent("sleepingbag")
            inst:RemoveTag("tent")
        end
    end

    inst.entity:AddSoundEmitter()

    inst:DoPeriodicTask(1, function()
        if inst.components.upgradeable then
            if inst.components.upgradeable.stage >= 2 then
                AddSleepingBag(inst)
            else
                RemoveSleepingBag(inst)
            end
        end
        if inst.components.sleepingbag then
            if inst.components.sleepingbag:InUse() then
                TheWorld.components.decoratedgrave_ghostmanager:UnregisterDecoratedGrave(inst)
            else
                TheWorld.components.decoratedgrave_ghostmanager:RegisterDecoratedGrave(inst)
            end
        end
    end)
end

-- AddPrefabPostInit("gravestone", OnGraveMoundUpdate)
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
        if inst.components.sleepingbag then
            if inst.components.sleepingbag:InUse() then
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
    if doer:HasTag("player") and not inst:HasTag("hashider") and inst:HasTag("gravebunker") then
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

local function SetSleeperAwakeState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:RemoveImmunity("sleeping")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("sleeping")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(true)
        inst.components.playercontroller:Enable(true)
    end
    inst:OnWakeUp()
    inst.components.inventory:Show()
    inst:ShowActions(true)
end


AddStategraphState('wilson',
    State{
        name = "bunker",
        tags = { "bunker", "busy", "silentmorph" },

        onenter = function(inst)
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
                inst.components.health:SetInvincible(true)
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
            inst.components.health:SetInvincible(false)
            inst:Show()
            if inst.DynamicShadow ~= nil then
                inst.DynamicShadow:Enable(true)
            end
            local gravestone = inst.usingbunker
            gravestone.components.gravebunker:DoLeave(inst)
            SetSleeperAwakeState(inst)
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