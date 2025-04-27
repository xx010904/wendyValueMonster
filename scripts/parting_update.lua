local function GhostActionFilter(inst, action)
    return action.ghost_valid
end

local function ConfigureGhostActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PushActionFilter(GhostActionFilter, 99)
    end
end

local function ConfigureGhostLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4 is base
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6 is base
    inst.components.locomotor.fasteronroad = false
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor:SetAllowPlatformHopping(false)
	inst.components.locomotor.pusheventwithdirection = true
end

local function CommonPlayerDeath(inst)
    inst.player_classified.MapExplorer:EnableUpdate(false)

    inst:RemoveComponent("burnable")

    inst.components.freezable:Reset()
    inst:RemoveComponent("freezable")
    inst:RemoveComponent("propagator")

    inst:RemoveComponent("grogginess")
	inst:RemoveComponent("slipperyfeet")

    inst.components.moisture:ForceDry(true, inst)

    inst.components.sheltered:Stop()

    inst.components.debuffable:Enable(false)

    if inst.components.revivablecorpse == nil then
        inst.components.age:PauseAging()
    end

    inst.components.health:SetInvincible(true)
    inst.components.health.canheal = false

    if not GetGameModeProperty("no_sanity") then
        inst.components.sanity:SetPercent(.5, true)
    end
    inst.components.sanity.ignore = true

    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:SetPercent(2 / 3, true)
    end
    inst.components.hunger:Pause()

    if not GetGameModeProperty("no_temperature") then
        inst.components.temperature:SetTemp(TUNING.STARTING_TEMP)
    end
    inst.components.frostybreather:Disable()
end

AddPlayerPostInit(function(inst)
    if inst.components.eater then
        local eater = inst.components.eater
        local old_oneatfn = eater.oneatfn
        eater.oneatfn = function (inst, food, feeder)
            if old_oneatfn then
                old_oneatfn(inst, food, feeder)
            end
            if food.prefab == "wendy_last_food" then
                -- if inst.components.temperature then
                --     inst.components.temperature:SetTemp(TUNING.STARTING_TEMP)
                -- end
                -- if inst.components.moisture then
                --     inst.components.moisture:DoDelta(-TUNING.MAX_WETNESS, true)
                -- end
                -- if inst.components.health then
                --     inst.components.health:DeltaPenalty(-TUNING.MAXIMUM_HEALTH_PENALTY)
                --     inst.components.health:SetPercent(1)
                -- end

                -- -- kill eater, because I want to use the meter badge
                -- inst:AddDebuff("wendy_last_food_buff", "wendy_last_food_buff")
                local x, y, z = inst.Transform:GetWorldPosition()
                
                inst.AnimState:SetBank("ghost")

                inst.components.skinner:SetSkinMode("ghost_skin")
            
                inst.components.bloomer:PushBloom("playerghostbloom", "shaders/anim_bloom_ghost.ksh", 100)
                inst.AnimState:SetLightOverride(TUNING.GHOST_LIGHT_OVERRIDE)
            
                inst:SetStateGraph("SGwilsonghost")
            
                --Switch to ghost light values
                inst.Light:SetIntensity(.6)
                inst.Light:SetRadius(.5)
                inst.Light:SetFalloff(.6)
                inst.Light:SetColour(180/255, 195/255, 225/255)
                inst.Light:Enable(true)
                inst.DynamicShadow:Enable(false)
            
                CommonPlayerDeath(inst)
            
                MakeGhostPhysics(inst, 1, .5)
                inst.Physics:Teleport(x, y, z)
            
                inst:AddTag("playerghost")
                inst.Network:AddUserFlag(USERFLAGS.IS_GHOST)
            
                inst.components.health:SetCurrentHealth(TUNING.RESURRECT_HEALTH * (inst.resurrect_multiplier or 1))
                inst.components.health:ForceUpdateHUD(true)
            
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst.player_classified:SetGhostMode(true)
            
                ConfigureGhostLocomotor(inst)
                ConfigureGhostActions(inst)
            end
        end
    end
end)