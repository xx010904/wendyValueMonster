local MIN_FADE_VALUE = 0.00
local MIN_FADE_COLOUR = {1.00, 1.00, 1.00, MIN_FADE_VALUE}
local MAX_FADE_VALUE = 0.30
local MAX_FADE_COLOUR = {1.00, 1.00, 1.00, MAX_FADE_VALUE}
local FADE_DIFFERENCE = MAX_FADE_VALUE - MIN_FADE_VALUE
local FADE_TIME = 0.5

local function shake(inst)
    if not inst._base_pos then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst._base_pos = { x, y, z }
    end

    -- 每次 shake 随机生成偏移
    local offset_x = math.random(-100, 100) / 1000 -- -0.1 到 0.1
    local offset_y = math.random(-50, 50) / 1000   -- -0.05 到 0.05
    local offset_z = math.random(-100, 100) / 1000

    local base_x, base_y, base_z = unpack(inst._base_pos)
    inst.Transform:SetPosition(base_x + offset_x, base_y + offset_y, base_z + offset_z)

    -- 随机缩放模拟抖动扩张
    local scale = 0.6 + math.random(-2, 2) * 0.01
    inst.Transform:SetScale(scale, scale, scale)

    -- 渐变透明度造成残影错觉（可选）
    if inst.AnimState then
        local alpha = 0.4 + math.random() * 0.3  -- 0.4 到 0.7 之间波动
        inst.AnimState:SetMultColour(1, 1, 1, alpha)
    end
end

local function moveToPlayer(inst, player)
    local start_x, start_y, start_z = inst.Transform:GetWorldPosition()
    local duration = 0.3
    local elapsed = 0

    -- 如果 shake_task 存在，先取消
    if inst.shake_task then
        inst.shake_task:Cancel()
        inst.shake_task = nil
        inst.Transform:SetScale(0.6, 0.6, 0.6) -- 恢复缩放
    end

    inst.move_task = inst:DoPeriodicTask(0, function()
        elapsed = elapsed + FRAMES
        local t = math.min(elapsed / duration, 1)

        -- 每一帧获取玩家当前位置，实现跟踪移动
        local px, py, pz = player.Transform:GetWorldPosition()
        local new_x = Lerp(start_x, px, t)
        local new_y = Lerp(start_y, py, t)
        local new_z = Lerp(start_z, pz, t)
        inst.Transform:SetPosition(new_x, new_y, new_z)

        if t >= 1 then
            inst.move_task:Cancel()
            inst.move_task = nil

            if player.components.inventory then
                player.SoundEmitter:KillSound("shaking_sound")
                player.SoundEmitter:PlaySound("meta5/abigail/gestalt_abigail_dashattack_hit")
                SpawnPrefab("abigail_gestalt_hit_fx").Transform:SetPosition(px, py, pz)
                player.components.inventory:GiveItem(SpawnPrefab("abigail_gestalt_lotus"))
            end

            inst:Remove()
        end
    end)
end

local function on_player_near(inst, player)
    local current_colour = inst.AnimState:GetMultColour()
    if current_colour ~= nil then
        local _fade_time = FADE_TIME * ((MAX_FADE_VALUE - current_colour) / FADE_DIFFERENCE)
        inst.components.colourtweener:StartTween(MAX_FADE_COLOUR, _fade_time)
    else
        inst.components.colourtweener:StartTween(MAX_FADE_COLOUR, FADE_TIME)
    end

    if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("wendy_lunar_3") then
        -- 启动抖动，延迟1秒后开始
        inst:DoTaskInTime(1.3, function()
            player.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/level_change/2", "shaking_sound")
            inst.shake_task = inst:DoPeriodicTask(0.01, function()
                shake(inst)  -- 调用抖动函数
            end)

            -- 启动计时器，1秒后移动到玩家身上
            inst:DoTaskInTime(1.3, function()
                if inst.shake_task then  -- 仅在抖动仍然存在时移动
                    moveToPlayer(inst, player)  -- 移动到玩家位置
                end
            end)
        end)
    end
end

local function on_player_far(inst)
    local current_colour = inst.AnimState:GetMultColour()
    if current_colour ~= nil then
        local _fade_time = FADE_TIME * ((current_colour - MIN_FADE_VALUE) / FADE_DIFFERENCE)
        inst.components.colourtweener:StartTween(MIN_FADE_COLOUR, _fade_time)
    else
        inst.components.colourtweener:StartTween(MIN_FADE_COLOUR, FADE_TIME)
    end

    -- 取消抖动
    if inst.shake_task then
        inst.shake_task:Cancel()
        inst.shake_task = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    local entity_physics = inst.entity:AddPhysics()
    entity_physics:SetMass(1.0)
    entity_physics:SetFriction(0.1)
    entity_physics:SetDamping(0.0)
    entity_physics:SetRestitution(0.5)
    entity_physics:SetCollisionGroup(COLLISION.ITEMS)
    entity_physics:ClearCollisionMask()
    entity_physics:CollidesWith(COLLISION.WORLD)
    entity_physics:SetSphere(0.5)

    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lotus")
    inst.AnimState:SetBuild("lotus")
    inst.AnimState:PlayAnimation("idle_water", true)
    inst.AnimState:SetMultColour(unpack(MIN_FADE_COLOUR))
    inst.AnimState:SetHaunted(true)
    inst.Transform:SetScale(0.6, 0.6, 0.6)

    inst:AddTag("haunted")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._current_fade = MIN_FADE_VALUE

    inst.persists = false

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(TUNING.GHOST_HUNT.TOY_FADE.IN, TUNING.GHOST_HUNT.TOY_FADE.IN)
    inst.components.playerprox:SetOnPlayerNear(on_player_near)
    inst.components.playerprox:SetOnPlayerFar(on_player_far)

    inst:AddComponent("colourtweener")

    inst:WatchWorldState("cycles", function (inst)
        inst:Remove()
    end)

    return inst
end

return Prefab("moondial_lotus_fx", fn, {})


