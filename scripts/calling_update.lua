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

    player:DoTaskInTime(0.25, function()
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
            player.AnimState:SetHaunted(true)
            player:AddTag("haunted")
            player:DoTaskInTime(12, function()
                if player:HasTag("haunted") then
                    player.AnimState:SetHaunted(false)
                    player:RemoveTag("haunted")
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

local POSSESSION_COOLDOWN = 10
local function abigailPossession(inst, player)
    inst.Transform:SetPosition(player.Transform:GetWorldPosition())
    player.components.ghostlybond:Recall(false)

    player:AddComponent("possessionaoe")
    player.components.possessionaoe:Enable()

    player:ListenForEvent("ghostlybond_summoncomplete", function()
        if player.components.possessionaoe then
            player.components.possessionaoe:Disable()
            player:RemoveComponent("possessionaoe")
            -- 需要分开一会
            inst.needApart = true
            inst:DoTaskInTime(POSSESSION_COOLDOWN, function()
                inst.needApart = false
            end)
        end
    end)
end

---- 作祟修改
AddPrefabPostInit("abigail", function(inst)
    inst.needApart = false

    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then
            old_OnSave(inst, data)
        end
        if inst.needApart then
            data.needApart = inst.needApart
        end
    end

    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then
            old_OnLoad(inst, data)
        end
        if data and data.needApart then
            inst.needApart = data.needApart
        end
    end

    if inst and inst.ListenForEvent then
        inst:ListenForEvent("do_ghost_hauntat", function(inst, pos)
            if (inst.sg and inst.sg:HasStateTag("nocommand"))
                    or (inst.components.health and inst.components.health:IsDead()) then
                return
            end

            local player = inst._playerlink
            if not (player and player:IsValid()) or player:HasTag("haunted") then
                return
            end

            if inst.needApart then
                player.components.talker:Say(GetString(player, "ANNOUNCE_NEED_APART"))
                return
            end

            -- 获取位置坐标
            local px, py, pz = pos:Get()

            -- 获取与 player 的距离
            local player_x, player_y, player_z = player.Transform:GetWorldPosition()
            local distance = math.sqrt((px - player_x)^2 + (pz - player_z)^2)

            -- 如果 player 和 pos 的距离小于等于2
            if distance <= 2 then
                -- doSunder(inst, player)
                abigailPossession(inst, player)

                -- 清除原本作祟的目标
                inst._haunt_target = nil
            end

        end)
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