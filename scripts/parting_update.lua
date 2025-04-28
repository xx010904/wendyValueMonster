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

                -- kill eater, because I want to use the meter badge
                inst.sg:GoToState("parting")
            end
        end
    end
end)

AddStategraphState('wilson',
    State{
        name = "parting",
        tags = { "busy", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("death")

            ---- 从commonDeath提前弄过来
            inst.components.health:SetInvincible(true)
            inst.components.health.canheal = false

            inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/death_voice")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_PARTING"))

                    inst.sg:GoToState("idle")

                    ---- 新增尸体帮拿东西
                    local x, y, z = inst.Transform:GetWorldPosition()
                    -- local a = math.random() * math.pi
                    -- inst.Transform:SetPosition(x + math.cos(a), y, z + math.sin(a))

                    local keeper = SpawnPrefab("wendy_last_keeper")
                    keeper.Transform:SetPosition(x, y, z)
                    keeper.components.follower:SetLeader(inst)
                    keeper.components.skinner:CopySkinsFromPlayer(inst)
                    -- keeper:ListenForEvent("animover", function()
                        -- inst.sg:RemoveStateTag("nointerrupt")
                        -- inst.sg:RemoveStateTag("busy")
                        SpawnPrefab("attune_out_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        SpawnPrefab("abigailsummonfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst:AddDebuff("wendy_last_food_buff", "wendy_last_food_buff")
                    -- end)
                    inst.components.inventory:TransferInventory(keeper)
                end
            end),
        },
    }
)