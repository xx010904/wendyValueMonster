local containers = require("containers")
local params = containers.params

local MAX_FLESHIELD = 600
local EACH_FLESHIELD = 15
AddPrefabPostInit("abigail", function(inst)
    inst.meatshield = 0

    local function UpdateAbsorbModifier(oldpercent)
        if inst.components.health then
            local absorb_percent = inst.meatshield > 0 and 1 or 0
            inst.components.health.externalabsorbmodifiers:SetModifier(inst, absorb_percent, "meatshield")
            -- print("externalabsorbmodifierstoldpercent", oldpercent)
            -- 复用废案的盾
            local max = absorb_percent * MAX_FLESHIELD
            local op = oldpercent or 0
            local np = max > 0 and inst.meatshield / max or 0
            -- print("PushEventoldpercent", oldpercent)

            inst:PushEvent("pethealthbar_bonuschange", {
                max = max,
                oldpercent = op,
                newpercent = np,
            })
        end
    end

    -- Hook onload and onsave methods to maintain the meatshield
    local _OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if _OnSave then
            _OnSave(inst, data)
        end
        data.meatshield = inst.meatshield
    end

    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _OnLoad then
            _OnLoad(inst, data)
        end
        if data and data.meatshield then
            inst.meatshield = data.meatshield
            local oldpercent = inst.meatshield / MAX_FLESHIELD
            -- print("_OnLoadoldpercent", oldpercent)
            UpdateAbsorbModifier(oldpercent)
        end
    end

    -- 初始化
    inst._init_meatsheild_badge_task = inst:DoPeriodicTask(2, function()
        -- 计数器
        if not inst._meatshield_task_count then
            inst._meatshield_task_count = 0
        end
        inst._meatshield_task_count = inst._meatshield_task_count + 1

        local oldpercent = inst.meatshield / MAX_FLESHIELD
        -- print("当前oldpercent", oldpercent)
        if oldpercent > 0 then
            UpdateAbsorbModifier(oldpercent)
        else
            -- 取消任务并清除任务记录
            if inst._init_meatsheild_badge_task then
                inst._init_meatsheild_badge_task:Cancel()  -- 停止周期任务
                inst._init_meatsheild_badge_task = nil
            end
        end

        -- 满60次时取消任务
        if inst._meatshield_task_count >= 30 then
            if inst._init_meatsheild_badge_task then
                inst._init_meatsheild_badge_task:Cancel()  -- 停止周期任务
                inst._init_meatsheild_badge_task = nil
            end
        end
    end)

    -- 动态修改 meatshield 时手动调用这个方法
    inst.ConsumeMeatShield = function(inst, damage)
        local oldpercent = inst.meatshield / MAX_FLESHIELD
        if inst.meatshield >= damage then
            inst.meatshield = inst.meatshield - damage
            damage = 0
        else
            damage = damage - inst.meatshield
            inst.meatshield = 0
        end
        UpdateAbsorbModifier(oldpercent)
        return damage
    end

    inst:ListenForEvent("attacked", function(inst, data)
        if inst.meatshield > 0 and data and data.damage then
            local actual_damage = inst:ConsumeMeatShield(data.damage)
            if actual_damage > 0 then
                -- 手动补伤害，因为 absorb 是 100%
                inst.components.health:DoDelta(-actual_damage, false, inst)
            end
        end
    end)
end)


local PROCESS_TIME_EACH_FLESH = 2.5

-- 封闭施法
local function SpawnFossilSpikes(inst, item_count)
    local spike_count = 9
    local radius = 2.4
    local x, y, z = inst.Transform:GetWorldPosition()
    local random_offset_angle = math.random() * 2 * PI  -- 0 到 2π 的随机偏移

    for i = 1, spike_count do
        local angle = random_offset_angle + (i - 1) * (2 * PI / spike_count)
        local offset = Vector3(math.cos(angle), 0, math.sin(angle)) * radius
        local spike = SpawnPrefab("sisturn_spike")
        if spike then
            spike.Transform:SetPosition(x + offset.x, y, z + offset.z)
            spike.task = spike:DoTaskInTime(0, spike.StartSpike, item_count * PROCESS_TIME_EACH_FLESH, math.random(7))
        end
    end
end

---- 撒盐块
local function dropSaltBlock(inst, item_count)
    if not item_count or item_count <= 0 then return end

    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnFossilSpikes(inst, item_count)
    local ents = TheSim:FindEntities(x, y, z, 1, { "sisturn_saltlick" })

    -- 查找已有的盐块
    local target_saltlick = nil
    for _, ent in ipairs(ents) do
        if ent.prefab == "sisturn_saltlick" and ent.components.finiteuses then
            target_saltlick = ent
            break
        end
    end

    -- 没找到就生成一个新的
    if not target_saltlick then
        target_saltlick = SpawnPrefab("sisturn_saltlick")
        if target_saltlick then
            target_saltlick.Transform:SetPosition(x, y, z)
            if target_saltlick.components.finiteuses then
                target_saltlick.components.finiteuses:SetMaxUses(1)
                target_saltlick.components.finiteuses:SetUses(1)
                target_saltlick.AnimState:SetMultColour(1, 1, 1, 1/20)
                item_count = item_count - 1
            end
        end
    end

    -- 逐步加盐与播特效
    local added = 0
    inst.drop_salt_block_task = inst:DoPeriodicTask(PROCESS_TIME_EACH_FLESH, function()
        if not target_saltlick:IsValid() or not target_saltlick.components.finiteuses then
            inst.drop_salt_block_task:Cancel()
            inst.drop_salt_block_task = nil
            return
        end

        -- local current_max = target_saltlick.components.finiteuses.total
        local current_uses = target_saltlick.components.finiteuses:GetUses()

        target_saltlick.components.finiteuses:SetMaxUses(current_uses + 2)
        target_saltlick.components.finiteuses:SetUses(current_uses + 2)

        local fx = SpawnPrefab("sisturn_salting_fx")
        local offset_x = math.random(-0.75, 0.75)
        local offset_z = math.random(-0.75, 0.75)
        fx.Transform:SetPosition(x + offset_x, y, z + offset_z)
        fx:DoTaskInTime(34 * FRAMES, function() fx:Remove() end)

        local uses = target_saltlick.components.finiteuses:GetUses()
        if uses < 20 then
            local alpha = uses / 20
            target_saltlick.AnimState:SetMultColour(1, 1, 1, alpha)
        else
            target_saltlick.AnimState:SetMultColour(1, 1, 1, 1)
        end

        added = added + 1
        if added >= item_count then
            inst.drop_salt_block_task:Cancel()
            inst.drop_salt_block_task = nil
        end
    end)
end

-- 加上肉盾
local function addFleshSheild(inst, item_count, doer)
    if doer.components.ghostlybond and doer.components.ghostlybond.ghost then
        local ghost = doer.components.ghostlybond.ghost
        if ghost and ghost.components.health then
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_ASHES_LICK"), nil, true)
            local added = 0
            inst.add_flesh_sheild_task = ghost:DoPeriodicTask(PROCESS_TIME_EACH_FLESH, function()
                if not ghost:IsValid() or not ghost.components.health then
                    inst.add_flesh_sheild_task:Cancel()
                    inst.add_flesh_sheild_task = nil
                    return
                end

                ghost.meatshield = math.min(ghost.meatshield + EACH_FLESHIELD, MAX_FLESHIELD)

                ghost:PushEvent("pethealthbar_bonuschange", {
                    max = MAX_FLESHIELD,
                    oldpercent = 1,
                    newpercent = ghost.meatshield / MAX_FLESHIELD,
                })

                ghost.components.health.externalabsorbmodifiers:SetModifier(ghost, 1, "meatshield")

                added = added + 1
                if added >= item_count then
                    inst.add_flesh_sheild_task:Cancel()
                    inst.add_flesh_sheild_task = nil
                end
            end)
        end
    end
end

-- 完全平摊新鲜度
local function refreshSisturnFreshness(inst, item_count)
    local sisturn = inst._link_sisturn
    if not (sisturn and sisturn.components and sisturn.components.container) then
        print("找不到sisturn!")
        return
    end

    local sis_container = sisturn.components.container
    local fresh_items = {}
    local total_days = 0

    -- 统计所有带新鲜度物品的剩余天数
    for i = 1, sis_container:GetNumSlots() do
        local item = sis_container:GetItemInSlot(i)
        if item and item.components.perishable then
            local perish = item.components.perishable
            local days_left = perish:GetPercent() * perish.perishtime / TUNING.TOTAL_DAY_TIME
            total_days = total_days + days_left
            table.insert(fresh_items, item)
        end
    end

    if #fresh_items == 0 then
        -- print("找不到sisturn的物品!")
        return
    end

    -- 加上通过献祭得到的额外新鲜度
    total_days = total_days + (item_count * 1.2)

    -- 统一计算平均天数并设置每个物品的新鲜度
    local avg_days = total_days / #fresh_items
    for _, item in ipairs(fresh_items) do
        local perish = item.components.perishable
        local new_percent = math.min(avg_days * TUNING.TOTAL_DAY_TIME / perish.perishtime, 1)
        perish:SetPercent(new_percent)
    end
end

-- 锁上容器，全部替换食物
local function lockFilterContainer(inst, item_count)
    if inst.components.container == nil then
        return
    end

    inst.components.container:Close()
    inst.components.container.canbeopened = false

    if inst._link_sisturn and inst._link_sisturn.components.container then
        inst._link_sisturn.components.container:Close()
        inst._link_sisturn.components.container.canbeopened = false
    end

    local container = inst.components.container
    local current_slot = 1

    inst.replace_food_task = inst:DoPeriodicTask(PROCESS_TIME_EACH_FLESH, function()
        if not inst:IsValid() or not container then
            if inst.replace_food_task then
                inst.replace_food_task:Cancel()
                inst.replace_food_task = nil
            end
            return
        end

        if current_slot > container:GetNumSlots() then
            -- 处理完成，解锁容器
            container.canbeopened = true
            if inst._link_sisturn and inst._link_sisturn.components.container then
                inst._link_sisturn.components.container.canbeopened = true
            end

            inst.replace_food_task:Cancel()
            inst.replace_food_task = nil
            return
        end

        local old_item = container:GetItemInSlot(current_slot)
        if old_item then
            old_item:Remove()
            local new_item = SpawnPrefab("sisturn_food")
            if new_item then
                container:GiveItem(new_item, current_slot)
            end
        end

        current_slot = current_slot + 1
    end)
end

-- 加工瘦肉
local function processFlesh(inst, doer) --filter
    if not doer or not doer.components.skilltreeupdater or not doer.components.skilltreeupdater:IsActivated("wendy_sisturn_3") then
        doer.components.talker:Say(GetString(doer, "ANNOUNCE_NOT_FLESHEILD"), nil, true)
        return
    end
    if inst.components.container ~= nil then
        local item_count = 0
        for i, slot in pairs(inst.components.container.slots) do
            if slot ~= nil then
            item_count = item_count + 1
            end
        end
        if item_count > 0 then
            -- 给filter容器关闭
            lockFilterContainer(inst, item_count)
            -- 恢复花的耐久
            refreshSisturnFreshness(inst, item_count)
            -- 逐渐给鬼魂加盾
            addFleshSheild(inst, item_count, doer)
            -- 洒下盐块
            dropSaltBlock(inst, item_count)
        else
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_NOT_ENOUGH_FLESH"), nil, true)
        end
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    end
end

local function processFleshValidFn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end

-- 隐藏容器定义
params.sisturn_filter = {
    widget =
    {
        slotpos = {},
        animbank = "ui_fish_box_5x4",
        animbuild = "ui_fish_box_5x4",
        slotbg = {},
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = STRINGS.SISTURNFILTER.UI.BLESSED_FLESHED,
            position = Vector3(0, -170, 0),
            fn = processFlesh,
            validfn = processFleshValidFn,
        }
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
    if item.prefab == "smallmeat" or
        item.prefab == "froglegs" or
        item.prefab == "batwing" or
        item.prefab == "batnose" or
        item.prefab == "drumstick" or
        item.prefab == "eel" or
        item.prefab == "fishmeat_small" or
        item.prefab == "monstermeat"
    then
        return true
    end
end

---- 修改骨灰罐，附着隐藏容器
AddPrefabPostInit("sisturn", function (inst)
    -- Hook onload and onsave methods to maintain the "saltlick" tag
    local _OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if _OnSave then
            _OnSave(inst, data)
        end
        if inst._child_container and inst._child_container:IsValid() then
            data.child_container_record = inst._child_container:GetSaveRecord()
        end
    end

    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _OnLoad then
            _OnLoad(inst, data)
        end
        if data and data.child_container_record then
            inst._child_container = SpawnSaveRecord(data.child_container_record)
            inst._child_container._link_sisturn = inst
        end
    end

    inst:ListenForEvent("onopen", function(inst, data)
        local doer = data and data.doer or nil
        local isSkillActived = doer and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_sisturn_3")
        if not isSkillActived then
            -- if doer and doer.components.talker then
            --     doer.components.talker:Say(GetString(doer, "ANNOUNCE_NOT_FLESHEILD"), nil, true)
            -- end
            return
        end
        if not inst._child_container or not inst._child_container:IsValid() then
            -- 如果没有子容器，则创建一个新的子容器
            local child = SpawnPrefab("sisturn_filter")
            if child then
                child.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst._child_container = child
                child._link_sisturn = inst
            end
        end
        if inst._child_container.components.container and inst._child_container.components.container.canbeopened then
            inst._child_container.components.container:Open(data and data.doer or nil)
        end
    end)

    inst:ListenForEvent("onclose", function(inst, data)
        if inst._child_container and inst._child_container:IsValid() and inst._child_container.components.container then
            inst._child_container.components.container:Close()
        end
    end)

    -- inst:ListenForEvent("onbuilt", function(inst, data)
    --     if not inst._child_container then
    --         local child = SpawnPrefab("sisturn_filter")
    --         if child then
    --             child.Transform:SetPosition(inst.Transform:GetWorldPosition())
    --             inst._child_container = child
    --             child._link_sisturn = inst
    --         end
    --     end
    -- end)

    -- inst:DoTaskInTime(0, function()
    --     if not inst._child_container then
    --         local child = SpawnPrefab("sisturn_filter")
    --         if child then
    --             child.Transform:SetPosition(inst.Transform:GetWorldPosition())
    --             inst._child_container = child
    --             child._link_sisturn = inst
    --         end
    --     end
    -- end)

    inst:ListenForEvent("onremove", function()
        if inst._child_container and inst._child_container:IsValid() and inst._child_container.components.container then
            inst._child_container.components.container:Close()
            inst._child_container.components.container:DropEverything()
            inst._child_container:Remove()
        end
    end)

    inst:ListenForEvent("onburnt", function()
        if inst._child_container and inst._child_container:IsValid() and inst._child_container.components.container then
            inst._child_container.components.container:Close()
            inst._child_container.components.container:DropEverything()
            inst._child_container:Remove()
        end
    end)
end)

AddIngredientValues({ "sisturn_food" }, { veggie = 0.25, meat = 0.25 })