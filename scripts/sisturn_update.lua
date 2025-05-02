AddPrefabPostInit("sisturn", function (inst)
    -- 播放撒骨灰特效
    inst:DoPeriodicTask(6, function()
        if inst:HasTag("saltlick") then
            local x, y, z = inst.Transform:GetWorldPosition()
            local entities = TheSim:FindEntities(x, y, z, TUNING.SALTLICK_CHECK_DIST, nil, nil, {"saltlicker"})
            if #entities > 0 and inst.salting_fx == nil then
                local fx = SpawnPrefab("sisturn_salting_fx")
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                fx:DoTaskInTime(1, function() fx:Remove() end)
            end
        end
    end)

    -- Hook onload and onsave methods to maintain the "saltlick" tag
    local _OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if _OnSave then
            _OnSave(inst, data)
        end
        data.saltlick = inst:HasTag("saltlick")
    end

    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _OnLoad then
            _OnLoad(inst, data)
        end
        if data and data.saltlick then
            inst:RemoveTag("saltlick")
            inst:AddTag("saltlick")
        end
    end
end)

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    -- 监听 ms_updatesisturnstate 事件
    inst:ListenForEvent("ms_updatesisturnstate", function(inst, data)
        if not data or not data.inst then
            return
        end
        local sisturn = data.inst
        if data.is_active then
            local x, y, z = sisturn.Transform:GetWorldPosition()
            local players = FindPlayersInRange(x, y, z, 4, true)
            local real_doer = nil
            if #players > 0 then
                for _, player in ipairs(players) do
                    if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("wendy_sisturn_3") then
                        real_doer = player
                        break
                    end
                end
            end
            if real_doer then
                inst:RemoveTag("saltlick")
                sisturn:AddTag("saltlick")
                sisturn:DoTaskInTime(2, function()
                    local entities = TheSim:FindEntities(x, y, z, TUNING.SALTLICK_CHECK_DIST, nil, nil, {"saltlicker"})
                    if real_doer.components.talker and #entities > 0  then
                        real_doer.components.talker:Say(GetString(real_doer, "ANNOUNCE_ASHES_LICK"), nil, true)
                    end
                end)
            end
        else
            sisturn:RemoveTag("saltlick")
        end
    end)
end)