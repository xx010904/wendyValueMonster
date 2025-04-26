AddPlayerPostInit(function(inst)
    if inst.components.eater then
        local eater = inst.components.eater
        local old_oneatfn = eater.oneatfn
        eater.oneatfn = function (inst, food, feeder)
            if old_oneatfn then
                old_oneatfn(inst, food, feeder)
            end
            if food.prefab == "wendy_last_food" then
                if inst.components.temperature then
                    inst.components.temperature:SetTemp(TUNING.STARTING_TEMP)
                end
                if inst.components.moisture then
                    inst.components.moisture:DoDelta(-TUNING.MAX_WETNESS, true)
                end
                if inst.components.health then
                    inst.components.health:DeltaPenalty(-TUNING.MAXIMUM_HEALTH_PENALTY)
                    inst.components.health:SetPercent(1)
                end

                -- kill eater
                inst:AddDebuff("wendy_last_food_buff", "wendy_last_food_buff")
            end
        end
    end
end)