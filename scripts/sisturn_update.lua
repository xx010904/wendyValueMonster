local containers = require("containers")
local params = containers.params

params.sisturn_filter = {
    widget =
    {
        slotpos = {},
        animbank = "ui_fish_box_5x4",
        animbuild = "ui_fish_box_5x4",
        slotbg = {},
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    acceptsstacks = false,
    type = "chest",
    openlimit = 1,
    lowpriorityselection = true,
}
for y = 2.5, -0.5, -1 do
    for x = -1, 3 do
        table.insert(params.sisturn_filter.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        table.insert(params.sisturn_filter.widget.slotbg, { image = "inv_slot_morsel.tex" })
    end
end
function params.sisturn_filter.itemtestfn(container, item, slot)
    if item.prefab == "monstermeat" or item.prefab == "smallmeat" then
        return true
    end
end

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

    inst:ListenForEvent("onopen", function(inst, data)
        if not inst._child_container or not inst._child_container:IsValid() then
            -- 如果没有子容器，则创建一个新的子容器
            local child = SpawnPrefab("sisturn_filter")
            if child then
                child.entity:SetParent(inst.entity)
                -- child.Transform:SetPosition(0, 0, 0) -- 可根据需要微调位置
                inst._child_container = child
            end
        end
        inst._child_container.components.container:Open(data and data.doer or nil)
    end)

    inst:ListenForEvent("onclose", function(inst, data)
        if inst._child_container ~= nil and inst._child_container:IsValid() then
            inst._child_container.components.container:Close()
        end
    end)

    inst:ListenForEvent("onbuilt", function(inst, data)
        if not inst._child_container then
            local child = SpawnPrefab("sisturn_filter")
            if child then
                child.entity:SetParent(inst.entity)
                -- child.Transform:SetPosition(0, 0, 0) -- 可根据需要微调位置
                inst._child_container = child
            end
        end
    end)

    inst:ListenForEvent("onremove", function()
        if inst._child_container and inst._child_container:IsValid() then
            inst._child_container.components.container:Close()
            inst._child_container.components.container:DropEverything()
            inst._child_container:Remove()
        end
    end)

    inst:ListenForEvent("onburnt", function()
        if inst._child_container and inst._child_container:IsValid() then
            inst._child_container.components.container:Close()
            inst._child_container.components.container:DropEverything()
            inst._child_container:Remove()
        end
    end)
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