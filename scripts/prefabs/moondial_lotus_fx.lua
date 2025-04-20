local MIN_FADE_VALUE = 0.00
local MIN_FADE_COLOUR = {1.00, 1.00, 1.00, MIN_FADE_VALUE}
local MAX_FADE_VALUE = 0.30
local MAX_FADE_COLOUR = {1.00, 1.00, 1.00, MAX_FADE_VALUE}
local FADE_DIFFERENCE = MAX_FADE_VALUE - MIN_FADE_VALUE
local FADE_TIME = 0.5

local shake_time = 0  -- 用于计算抖动的时间
local function shake(inst)
    shake_time = (shake_time + 0.1) % (2 * math.pi)  -- 增加时间并保持在一个周期内
    local x, y, z = inst.Transform:GetWorldPosition()  -- 获取当前位置的 x, y, z

    -- 使用正弦函数来计算偏移量
    local offset_x = 0.05 * math.sin(shake_time * 2)  -- 左右抖动
    local offset_z = 0.05 * math.cos(shake_time * 2)  -- 前后抖动
    local offset_y = 0.05 * math.cos(shake_time * 2)  -- 上下抖动

    inst.Transform:SetPosition(x + offset_x, y + offset_y, z + offset_z)  -- 使用偏移量更新位置
end

local function moveToPlayer(inst, player)
    local start_x, start_y, start_z = inst.Transform:GetWorldPosition()  -- 获取当前坐标
    local player_x, player_y, player_z = player.Transform:GetWorldPosition()  -- 获取玩家位置
    local duration = 0.1
    local elapsed = 0

    inst:DoPeriodicTask(0.01, function()
        elapsed = elapsed + 0.01
        local t = math.min(elapsed / duration, 1)  -- Clamp t to 0-1
        local new_x = Lerp(start_x, player_x, t)
        local new_z = Lerp(start_z, player_z, t)
        inst.Transform:SetPosition(new_x, start_y, new_z)

        if t >= 1 then
            if inst.shake_task then
                inst.shake_task:Cancel()  -- 停止抖动
                inst.shake_task = nil  -- 清除引用
            end

            -- 给玩家的背包添加 abigail_gestalt_lotus
            if player.components.inventory then
                player.SoundEmitter:KillSound("shaking_sound")
                player.SoundEmitter:PlaySound("meta5/abigail/gestalt_abigail_dashattack_hit")
                SpawnPrefab("abigail_gestalt_hit_fx").Transform:SetPosition(player.Transform:GetWorldPosition())
                player.components.inventory:GiveItem(SpawnPrefab("abigail_gestalt_lotus"))
                inst:Remove()
            end
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
        inst:DoTaskInTime(1, function()
            player.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/level_change/2", "shaking_sound")
            inst.shake_task = inst:DoPeriodicTask(0.01, function()
                shake(inst)  -- 调用抖动函数
            end)

            -- 启动计时器，1秒后移动到玩家身上
            inst:DoTaskInTime(1, function()
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
    inst.AnimState:PlayAnimation("idle")
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


