local HEALTH_BOUND = 50
local SPEED_BOUND = 0.05
-- 增加Abigail的属性
local function OnSisterBondChange(inst)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        local leader = inst._playerlink
        local bondHealth = 0
        local bondSpeed = 0
        if leader and leader.prefab == "wendy" and leader.sisterBond then
            bondHealth = leader.sisterBond * HEALTH_BOUND -- 每个sisterBond增加50点生命值
            bondSpeed = leader.sisterBond * SPEED_BOUND -- 每个sisterBond增加0.05速度
        end

        -- print("增加Abigail的生命", bondHealth)
        local health = inst.components.health
        if health then
            if health:IsDead() then
                health.maxhealth = inst.base_max_health + bondHealth
            else
                inst.components.health.maxhealth = inst.components.health.maxhealth + bondHealth
            end

            inst._playerlink.components.pethealthbar:SetMaxHealth(health.maxhealth)
        end

        --print("增加Abigail的速度",)
        local locomotor = inst.components.locomotor
        if locomotor then
            locomotor:RemoveExternalSpeedMultiplier(inst, "sisterBond_speedmult")
            locomotor:SetExternalSpeedMultiplier(inst, "sisterBond_speedmult", 1 + bondSpeed)
        end
    end
end

function SpawnSoulWaves(position, numWaves, waveSpeed, spawn_dist)
    if numWaves == nil or numWaves < 1 then
        return
    end
    local totalAngle = 360
    local anglePerWave = totalAngle/numWaves
    local startAngle = math.random(-180, 180)

    local wave_spawned = false
    for i = 0, numWaves - 1 do
        local angle = (startAngle - (totalAngle/2)) + (i * anglePerWave)
        local offset_direction = Vector3(math.cos(angle*DEGREES), 0, -math.sin(angle*DEGREES)):Normalize()
        local wavepos = position + (offset_direction * spawn_dist)

        wave_spawned = true

        local wave = SpawnPrefab("soul_wave")
        wave.Transform:SetPosition(wavepos:Get())
        wave.Transform:SetRotation(angle)
        wave.Physics:SetMotorVel(waveSpeed, 0, 0)
    end

    return wave_spawned
end


AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.playerbondtracker then
        inst:AddComponent("playerbondtracker")
        -- print("[Bond] 世界组件 playerbondtracker 已添加")
    end
end)

-- 多年生植物祭坛复活事件监听
local function onactivateresurrection(inst, resurrect_target)
    -- print("Resurrection activated!", inst, resurrect_target)
    if resurrect_target and resurrect_target.components.skilltreeupdater and resurrect_target.components.skilltreeupdater:IsActivated("wendy_ghostflower_grave") then
        -- if resurrect_target.sisterBond then
        --     resurrect_target.sisterBond = resurrect_target.sisterBond + 1
        -- else
        --     resurrect_target.sisterBond = 1
        -- end
        local tracker = TheWorld.components.playerbondtracker
        if tracker then
            local currentBond = tracker:GetBondData(resurrect_target.userid, "sisterBond") or 0
            tracker:SetBondData(resurrect_target.userid, "sisterBond", currentBond + 1)
            -- print(string.format("复活加1次", resurrect_target.userid, tracker:GetBondData(resurrect_target.userid, "sisterBond")))
            resurrect_target.sisterBond = tracker:GetBondData(resurrect_target.userid, "sisterBond")
        end

        -- 回收灵魂
        local wave_spawned = SpawnSoulWaves(inst:GetPosition(), resurrect_target.sisterBond, -3.5, 12)
        -- print("Resurrection sisterBond!", resurrect_target.sisterBond)

        -- 更新一次abby血量
        if resurrect_target.components.ghostlybond and resurrect_target.components.ghostlybond.ghost then
            local ghost = resurrect_target.components.ghostlybond.ghost
            -- print("ghost", ghost)
            -- print("Resurrection sisterBond!", resurrect_target.sisterBond)
            OnSisterBondChange(ghost)
            -- 伪召唤一次，修正血量
            ghost.entity:RemoveTag("INLIMBO")
            ghost.entity:SetInLimbo(false)
            ghost:PushEvent("exitlimbo")
            -- resurrect_target.components.ghostlybond:Recall(false)
        end
    end
end

AddPrefabPostInit("wendy_resurrectiongrave", function(inst)
    if inst then
        inst:ListenForEvent("activateresurrection", onactivateresurrection)
    end
end)

-- wendy记录复活次数和Abigail当前血量
AddPrefabPostInit("wendy", function(inst)
    if inst then
        local old_OnSave = inst.OnSave
        inst.OnSave = function(inst, data)
            if old_OnSave then
                old_OnSave(inst, data)
            end
            if inst.sisterBond then
                -- data.sisterBond = inst.sisterBond
                -- if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                --     local ghost = inst.components.ghostlybond.ghost
                --     if ghost.components.health then
                --         data.ghostcurrenthealth = ghost.components.health.currenthealth
                --         print("save data.ghostcurrenthealth", data.ghostcurrenthealth)
                --     end
                -- end
            end
        end

        local old_OnLoad = inst.OnLoad
        inst.OnLoad = function(inst, data)
            if old_OnLoad then
                old_OnLoad(inst, data)
            end
            if data and data.sisterBond then
                -- inst.sisterBond = data.sisterBond
                -- if data and data.ghostcurrenthealth and inst.components.health then
                --     if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                --         local ghost = inst.components.ghostlybond.ghost
                --         if ghost.components.health then
                --             OnSisterBondChange(ghost)
                --             print("load data.ghostcurrenthealth", data.ghostcurrenthealth)
                --             ghost.components.health.currenthealth = data.ghostcurrenthealth
                --         end
                --     end
                -- end
            end
        end

        inst:DoTaskInTime(0, function(inst)
            -- 确保组件和玩家都有效
            if TheWorld.components.playerbondtracker and inst.userid then
                -- print("获取血量GetBondData")
                local bond = TheWorld.components.playerbondtracker:GetBondData(inst.userid, "sisterBond")
                local ghostcurrenthealth = TheWorld.components.playerbondtracker:GetBondData(inst.userid, "ghostcurrenthealth")


                -- 在这里处理加载后的逻辑，例如重新设定玩家的某个状态
                inst.sisterBond = bond or 0
                -- print(string.format("[Bond] 玩家跨世界加载完成，保护欲：", inst:GetDisplayName(), bond))

                if ghostcurrenthealth then
                    if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                        local ghost = inst.components.ghostlybond.ghost
                        if ghost.components.health then
                            OnSisterBondChange(ghost)
                            print("load data.ghostcurrenthealth", ghostcurrenthealth)
                            ghost.components.health.currenthealth = ghostcurrenthealth
                        end
                    end
                end
            end
        end)
    end
end)

local function OnDeath(inst)
    local leader = inst._playerlink
    if leader and leader.prefab == "wendy" and leader.sisterBond then
        if leader.sisterBond > 0 then
            --释放灵魂
            local wave_spawned = SpawnSoulWaves(inst:GetPosition(), leader.sisterBond, 3.5, 1)

            local reduction = math.max(1, (math.ceil(leader.sisterBond / 3)))
            local tracker = TheWorld.components.playerbondtracker
            if tracker then
                local currentBond = tracker:GetBondData(leader.userid, "sisterBond")
                if currentBond > reduction then
                    tracker:SetBondData(leader.userid, "sisterBond", currentBond-reduction)
                    -- print(string.format("阿比死亡减少", reduction, tracker:GetBondData(leader.userid, "sisterBond")))
                    leader.sisterBond = tracker:GetBondData(leader.userid, "sisterBond")
                end
            end
            -- print("阿比盖尔死亡reduction：", reduction)
            -- leader.sisterBond = leader.sisterBond - math.max(1, reduction)
        end
    end
end

local ATTACK_MUST_TAGS = { "_combat" }
local EXCLUDE_TAGS = {
    "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget",
    "player", "companion", "invisible", "noattack", "hiding",
    "abigail", "abigail_tether", "graveghost", "ghost", "shadowcreature",
    "playingcard", "deckcontainer"
}
local function FindAbigailAttackTarget(inst, player, attack_power)
    local target = inst.components.combat.target
    -- print("直接目标", target)
    -- 如果当前没有直接目标，就找有debuff的
    if not target then
        -- print("no target")
        local x, y, z = inst.Transform:GetWorldPosition()
        local vex_targets = TheSim:FindEntities(x, y, z, 8, ATTACK_MUST_TAGS, EXCLUDE_TAGS)
        for _, entity in ipairs(vex_targets) do
            if entity.components.health and entity.components.health.currenthealth > 0 then
                -- print("找到附近目标", entity)
                local debuffable = entity.components.debuffable
                if debuffable then
                    -- print("有debuff的目标吗？" ,entity, debuffable:HasDebuff("abigail_vex_debuff"))
                    -- print("有shadowdebuff的目标吗？" ,entity, debuffable:HasDebuff("abigail_vex_shadow_debuff"))
                    if (debuffable:HasDebuff("abigail_vex_debuff") or debuffable:HasDebuff("abigail_vex_shadow_debuff")) then
                        target = entity
                        break
                    end
                end
            end
        end
    end
    -- 如果目标血量太低，尝试寻找新的附近目标
    if target and target.components.health and target.components.health.currenthealth < attack_power * 2 then
        local x, y, z = target.Transform:GetWorldPosition()
        local entities = TheSim:FindEntities(x, y, z, 4, ATTACK_MUST_TAGS, EXCLUDE_TAGS)
        for _, entity in ipairs(entities) do
            if entity ~= target and entity.components.health and entity.components.health.currenthealth > 0 then
                -- print("找到血量高一点的目标防止浪费伤害")
                target = entity
                break
            end
        end
    end
    return target
end

AddPrefabPostInit("abigail", function(inst)
    if not TheWorld.ismastersim then return end

    -- 监听者：死亡与治疗
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("pre_health_setval", OnSisterBondChange)

    local attack_interval = 2.4
    local tether_spawn_duration = 0.4 -- 0.4 秒内生成完 4 个
    
    -- 四个方向偏移
    local offsets = {
        {x = 1, z = 0},   -- 右
        {x = -1, z = 0},  -- 左
        {x = 0, z = 1},   -- 上
        {x = 0, z = -1},  -- 下
    }
    
    -- 启动定时任务
    local function StartTetherTask()
        local player = inst._playerlink
        if player and player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("wendy_ghostflower_grave") then
            if inst._tether_task == nil and inst:IsValid() and not inst:IsInLimbo() then
                inst._tether_task = inst:DoPeriodicTask(attack_interval, function()

                    if player and player.components.ghostlybond and player.components.ghostlybond.ghost ~= inst then
                        return -- 忽略错误绑定的 Abigail
                    end

                    if player and player.components.ghostlybond and player.components.ghostlybond.summoned and player.sisterBond and player.sisterBond > 0 then
                        if inst.components.combat then
                            local attack_power = player.sisterBond * 1 -- 4个就是4攻击力
                            local interval = tether_spawn_duration / (#offsets - 1)

                            for i, offset in ipairs(offsets) do
                                inst:DoTaskInTime(interval * (i - 1), function()
                                    if inst:IsValid() then
                                        local target = FindAbigailAttackTarget(inst, player, attack_power)
                                        if target then
                                            local tether = SpawnPrefab("abigail_tether")

                                            -- 计算偏移位置
                                            local x, y, z = inst.Transform:GetWorldPosition()
                                            tether.Transform:SetPosition(x + offset.x, y, z + offset.z)

                                            local weapon = tether.components.combat:GetWeapon()
                                            if weapon then
                                                weapon.components.weapon:SetDamage(attack_power)
                                            end

                                            tether.components.combat:DoAttack(target)
                                            tether:DoTaskInTime(attack_interval, function()
                                                if tether:IsValid() then
                                                    tether:Remove()
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end
        end
    end

    -- 停止定时任务
    local function StopTetherTask()
        if inst._tether_task then
            inst._tether_task:Cancel()
            inst._tether_task = nil
        end
    end

    -- LIMBO 状态监听
    inst:ListenForEvent("enterlimbo", StopTetherTask)
    inst:ListenForEvent("exitlimbo", StartTetherTask)

    -- 初始状态检查
    if not inst:IsInLimbo() then
        if inst._tether_task ~= nil then return end
        StartTetherTask()
    end
end)

-- DebugSetSisterBond(5)
local ENABLE_DEBUG = GetModConfigData("ENABLE_DEBUG_SISTERBOND")
if ENABLE_DEBUG then
    GLOBAL.DebugSetSisterBond = function(number)
        if number == nil then
            print("没有数字！")
            return
        end
        if TheWorld and TheWorld.components.playerbondtracker then
            TheWorld.components.playerbondtracker:SetBondData(ThePlayer.userid, "sisterBond", number)
            print("已设置 sisterBond 为", number)
            local ghost = ThePlayer.components.ghostlybond and ThePlayer.components.ghostlybond.ghost
            print("已找到 Abigail 为", ghost)
            local tracker = TheWorld.components.playerbondtracker
            ThePlayer.sisterBond = tracker:GetBondData(ThePlayer.userid, "sisterBond")
            print("已找到 ThePlayer 为", ThePlayer.sisterBond)
            if ghost ~= nil then
                OnSisterBondChange(ghost)
                print("已更新 Abigail层数！")
            else
                print("Abigail 不存在，未更新")
            end
        else
            print("没有找到 playerbondtracker 组件")
        end
    end
end
