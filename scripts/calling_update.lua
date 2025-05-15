local HAUNT_CD = 1
local function SpawnSoulLink(source, target)
    local x1, y1, z1 = source.Transform:GetWorldPosition()
    local x2, y2, z2 = target.Transform:GetWorldPosition()

    local dx = x2 - x1
    local dz = z2 - z1
    local distance = math.sqrt(dx * dx + dz * dz)

    if distance == 0 then
        return
    end

    local interval = 0.58
    local steps = math.floor(distance / interval)
    if steps <= 2 then return end -- 至少要有中间链子才能跳过头尾

    local step_dx = dx / steps
    local step_dz = dz / steps

    local total_time = 0.5
    local time_per_step = total_time / steps

    -- 从 i = 1 到 steps - 1（跳过0和steps）
    for i = 1, steps - 1 do
        source:DoTaskInTime(i * time_per_step, function()
            local is_endpoint = (i == steps - 1)
            local prefabname = is_endpoint and "soul_link_endpoint" or "soul_link"
            local soul = SpawnPrefab(prefabname)
            if soul ~= nil then
                local jitter_x, jitter_y, jitter_z = 0, 0, 0
                if not is_endpoint then
                    -- 只有中间的链子抖动
                    jitter_x = (math.random() * 0.4) - 0.2
                    jitter_y = (math.random() * 0.4) - 0.2
                    jitter_z = (math.random() * 0.4) - 0.2
                end

                soul.Transform:SetPosition(
                    x1 + step_dx * i + jitter_x,
                    is_endpoint and 0 or (y1 + 1.5 + jitter_y), -- endpoint固定0
                    z1 + step_dz * i + jitter_z
                )
            end
        end)
    end
end

-- 灵魂隔断
local function doSunder(inst, player)
    -- player发出soul_link连接inst
    SpawnSoulLink(player, inst)
    -- inst发出soul_link连接player
    SpawnSoulLink(inst, player)
    -- if player and player.components.combat then
    --     player.components.combat:GetAttacked(player, 1)
    -- end
    -- if inst and inst.components.combat then
    --     inst.components.combat:GetAttacked(inst, 1)
    -- end

    -- 核心转向逻辑
    if player then
        player:ForceFacePoint(inst.Transform:GetWorldPosition())
    end

    -- 锁定动作
    inst.sg:GoToState("abigail_transform")
    player.sg:GoToState("soul_sunder")

    player:DoTaskInTime(0.25, function(player)
        local player_health = player.components.health
        local inst_health = inst.components.health
        if player_health and inst_health then
            -- 获取血量百分比（考虑debuff，比如最大血量削减）
            local player_health_percentage = player_health:GetPercentWithPenalty()
            local inst_health_percentage = inst_health:GetPercentWithPenalty()

            -- 交换血量百分比
            player_health:SetPercent(inst_health_percentage)
            inst_health:SetPercent(player_health_percentage)

            -- 作祟期间不能再作祟
            player._haunt_cooldown = HAUNT_CD
            player._haunt_countdown_task = player:DoPeriodicTask(1, function()
                if player._haunt_cooldown > 0 then
                    player._haunt_cooldown = player._haunt_cooldown - 1
                else
                    if player._haunt_countdown_task then
                        player.components.talker:Say(GetString(player, "ANNOUNCE_HAUNT_READY"), nil, true)
                        player._haunt_countdown_task:Cancel()
                        player._haunt_countdown_task = nil
                    end
                end
            end)

            -- 阿比血多，就扣饥饿值，约等于帐篷回血了
            -- 阿比血少，就扣理智值，不允许一直给阿比补血，要召唤影怪来干扰
            local health_diff = math.abs(player_health_percentage - inst_health_percentage) -- 取绝对值
            local loss = math.clamp(health_diff * 100, 30, 100) -- 差40%就扣40点饥饿/理智，最少扣30，最多扣100
            if player_health_percentage > inst_health_percentage then
                if player.components.sanity then
                    player.components.sanity:DoDelta(-loss)
                end
            else
                if player.components.hunger then
                    player.components.hunger:DoDelta(-loss)
                end
            end
        end
    end)
end

---- 灵魂链接
local LINK_TIME = 60
local function doLink(ghost, player)
    if not (ghost and player) then return end

    -- 检查 player 身上是否有 ghostflower
    if player.components.inventory then
        local flower = player.components.inventory:FindItem(function(item)
            return item.prefab == "ghostflower"
        end)

        if flower then
            if flower.components.stackable and flower.components.stackable:StackSize() > 1 then
                flower.components.stackable:Get(1):Remove()  -- 消耗1个
            else
                flower:Remove()  -- 只有1个，直接移除
                -- 链接就绪
            end
        else
            player.components.talker:Say(GetString(player, "ANNOUNCE_HAUNT_NO_GHOSTFLOWER"), nil, true)
            return
        end
    end
    player.components.talker:Say(GetString(player, "ANNOUNCE_HAUNT_READY"), nil, true)

    local ghost_cd = false
    local player_cd = false
    local heal_task = nil

    -- ghost 攻击 -> player 回血 6.8 * 6，扣 3.4 * 6 理智
    local function OnGhostAttack(ghost, data)
        if not data or not data.target then return end
        if ghost_cd then return end

        if player.components.health and not player.components.health:IsDead() then
            local playerhealth = player.components.health
            if playerhealth.currenthealth >= playerhealth.maxhealth then
                return -- 满血不执行
            end

            ghost_cd = true

            playerhealth:DoDelta(6.8 * 6, nil, ghost)

            if player.components.sanity then
                player.components.sanity:DoDelta(-3.4 * 6)
            end

            SpawnPrefab("soul_link_endpoint").Transform:SetPosition(player.Transform:GetWorldPosition())
            ghost:DoTaskInTime(0.1, function() ghost_cd = false end)
        end
    end

    -- ghost startaura事件开始，定时给player回血+扣理智
    local function OnStartAura()
        if heal_task then return end

        heal_task = ghost:DoPeriodicTask(1, function()
            if player.components.health and not player.components.health:IsDead() then
                local playerhealth = player.components.health
                if playerhealth.currenthealth < playerhealth.maxhealth then
                    SpawnPrefab("soul_link_endpoint").Transform:SetPosition(player.Transform:GetWorldPosition())
                    playerhealth:DoDelta(6.8, nil, ghost)
                    if player.components.sanity then
                        player.components.sanity:DoDelta(-3.4)
                    end
                end
            end
        end)
    end

    local function OnStopAura()
        if heal_task then
            heal_task:Cancel()
            heal_task = nil
        end
    end

    -- player 攻击 -> ghost 回血 6.8，player 扣 3.4 饥饿
    local function OnPlayerAttack(player, data)
        if not data or not data.target then return end
        if player_cd then return end

        if ghost.components.health and not ghost.components.health:IsDead() then
            local ghosthealth = ghost.components.health
            if ghosthealth.currenthealth >= ghosthealth.maxhealth then
                return -- 满血不执行
            end

            player_cd = true

            ghosthealth:DoDelta(6.8, nil, player)

            if player.components.hunger then
                player.components.hunger:DoDelta(-3.4)
            end

            SpawnPrefab("soul_link_endpoint").Transform:SetPosition(ghost.Transform:GetWorldPosition())
            player:DoTaskInTime(0.1, function() player_cd = false end)
        end
    end

    -- 初始化标记（只初始化一次）
    if not ghost._soul_linked_to_player then
        ghost._soul_linked_to_player = player
        player._soul_linked_to_ghost = ghost


        -- 添加监听（只添加一次）
        ghost:ListenForEvent("onattackother", OnGhostAttack)
        ghost:ListenForEvent("startaura", OnStartAura)
        ghost:ListenForEvent("stopaura", OnStopAura)
        player:ListenForEvent("onattackother", OnPlayerAttack)

        -- 记录 heal_task 给后面清理用
        ghost._soul_link_heal_task = heal_task
    end

    -- 重置 LINK_TIME 倒计时
    if ghost._soul_link_timer_task then
        ghost._soul_link_timer_task:Cancel()
    end

    ghost._soul_link_timer_task = ghost:DoTaskInTime(LINK_TIME, function()
        -- 解绑监听
        ghost:RemoveEventCallback("onattackother", OnGhostAttack)
        ghost:RemoveEventCallback("startaura", OnStartAura)
        ghost:RemoveEventCallback("stopaura", OnStopAura)
        player:RemoveEventCallback("onattackother", OnPlayerAttack)

        -- 停止回血任务
        if ghost._soul_link_heal_task then
            ghost._soul_link_heal_task:Cancel()
            ghost._soul_link_heal_task = nil
        end

        -- 清除标记
        ghost._soul_linked_to_player = nil
        player._soul_linked_to_ghost = nil
        ghost._soul_link_timer_task = nil

        -- 链接结束
        player.components.talker:Say(GetString(player, "ANNOUNCE_HAUNT_COOLDOWN"), nil, true)
    end)
end


---- 作祟修改
AddPrefabPostInit("abigail", function(inst)
    if inst and inst.ListenForEvent then
        inst:ListenForEvent("do_ghost_hauntat", function(inst, pos)
            if (inst.sg and inst.sg:HasStateTag("nocommand")) or (inst.components.health and inst.components.health:IsDead()) then
                return
            end

            local player = inst._playerlink
            if not (player and player:IsValid()) then
                return
            end

            if player._haunt_cooldown > 0 and player.components.talker then
                player.components.talker:Say(GetString(player, "ANNOUNCE_HAUNT_COOLDOWN").." ("..player._haunt_cooldown.."s)", nil, true)
                return
            end

            -- 获取位置坐标
            local px, py, pz = pos:Get()

            -- 获取与 player 的距离
            local player_x, player_y, player_z = player.Transform:GetWorldPosition()
            local distance = math.sqrt((px - player_x)^2 + (pz - player_z)^2)

            -- 如果 player 和 pos 的距离小于等于2
            if distance <= 2 then
                -- player发出soul_link连接inst
                SpawnSoulLink(player, inst)
                -- inst发出soul_link连接player
                SpawnSoulLink(inst, player)
                -- 核心转向逻辑
                if player then
                    player:ForceFacePoint(inst.Transform:GetWorldPosition())
                end
                -- 锁定动作
                inst.sg:GoToState("abigail_transform")
                player.sg:GoToState("soul_sunder")

                player:DoTaskInTime(0.25, function(player)
                    -- doSunder(inst, player)
                    doLink(inst, player)
                end)
                -- 清除原本作祟的目标
                inst._haunt_target = nil
            end
        end)
    end
end)

AddPrefabPostInit("wendy", function(inst)
    inst._haunt_cooldown = 0

    -- Hook 原来的 OnSave
    local _old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if _old_OnSave then
            _old_OnSave(inst, data)
        end
        data.haunt_cooldown = inst._haunt_cooldown
    end

    -- Hook 原来的 OnLoad
    local _old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _old_OnLoad then
            _old_OnLoad(inst, data)
        end
        if data and data.haunt_cooldown ~= nil then
            inst._haunt_cooldown = data.haunt_cooldown
        else
            inst._haunt_cooldown = 0
        end
    end
end)

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end
AddStategraphState('wilson',
    State{
        name = "soul_sunder",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, frozen)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            -- inst.AnimState:PushAnimation("hit", false)

            if frozen == "noimpactsound" then
                frozen = nil
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end
            inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/hurt")

            local stun_frames = 66
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction(nil)
            end
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)