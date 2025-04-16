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
                print("inst.components.upgradeable.stage", inst.components.upgradeable.stage)
                AddSleepingBag(inst)
            else
                print("inst.components.upgradeable.stage", inst.components.upgradeable.stage)
                RemoveSleepingBag(inst)
            end
        end
    end)
end

AddPrefabPostInit("gravestone", OnGraveMoundUpdate)