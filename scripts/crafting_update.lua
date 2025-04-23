local healthBound = 50
local speedBound = 0.05

-- 多年生植物祭坛复活事件监听
local function onactivateresurrection(inst, resurrect_target)
    -- print("Resurrection activated!", inst, resurrect_target)
    if resurrect_target and resurrect_target.prefab == "wendy" then
        if resurrect_target.sisterBond then
            resurrect_target.sisterBond = resurrect_target.sisterBond + 1
        else
            resurrect_target.sisterBond = 1
        end

        -- print("Resurrection sisterBond!", resurrect_target.sisterBond)
    end
end

AddPrefabPostInit("wendy_resurrectiongrave", function(inst)
    if inst then
        inst:ListenForEvent("activateresurrection", onactivateresurrection)
    end
end)


-- 增加Abigail的属性
local function SetVal(self, boneHealth, cause, afflicter)
    local old_health = self.currenthealth
    local val = boneHealth + old_health
    local max_health = self:GetMaxWithPenalty()
    local min_health = math.min(self.minhealth or 0, max_health)

    if val > max_health then
        val = max_health
    end

    if val <= min_health then
        self.currenthealth = min_health
        self.inst:PushEvent("minhealth", { cause = cause, afflicter = afflicter })
    else
        self.currenthealth = val
    end
end

local function OnSisterBondChange(inst)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        local leader = inst._playerlink
        local bondHealth = 0
        local bondSpeed = 0
        if leader and leader.prefab == "wendy" and leader.sisterBond then
            bondHealth = leader.sisterBond * healthBound -- 每个sisterBond增加50点生命值
            bondSpeed = leader.sisterBond * speedBound -- 每个sisterBond增加0.05速度
        end

        -- print("增加Abigail的生命", boneHealth)
        local health = inst.components.health
        if health then
            if health:IsDead() then
                health.maxhealth = inst.base_max_health + bondHealth
            else
                -- health:SetMaxHealth(inst.base_max_health + boneHealth)
                inst.components.health.maxhealth = inst.components.health.maxhealth + bondHealth
                SetVal(health, bondHealth, true)
                -- health:DoDelta(0, true, nil, true, nil, true)
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

-- wendy记录复活次数和Abigail当前血量
AddPrefabPostInit("wendy", function(inst)
    if inst then
        local old_OnSave = inst.OnSave
        inst.OnSave = function(inst, data)
            if old_OnSave then
                old_OnSave(inst, data)
            end
            if inst.sisterBond then
                data.sisterBond = inst.sisterBond
                if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                    local ghost = inst.components.ghostlybond.ghost
                    if ghost.components.health then
                        data.ghostcurrenthealth = ghost.components.health.currenthealth
                        -- print("save data.ghostcurrenthealth", data.ghostcurrenthealth)
                    end
                end
            end
        end

        local old_OnLoad = inst.OnLoad
        inst.OnLoad = function(inst, data)
            if old_OnLoad then
                old_OnLoad(inst, data)
            end
            if data and data.sisterBond then
                inst.sisterBond = data.sisterBond
                if data and data.ghostcurrenthealth and inst.components.health then
                    if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                        local ghost = inst.components.ghostlybond.ghost
                        if ghost.components.health then
                            OnSisterBondChange(ghost)
                            -- print("load data.ghostcurrenthealth", data.ghostcurrenthealth)
                            ghost.components.health.currenthealth = data.ghostcurrenthealth
                        end
                    end
                end
            end
        end
    end
end)

local function OnDeath(inst)
    local leader = inst._playerlink
    if leader and leader.prefab == "wendy" and leader.sisterBond then
        if leader.sisterBond > 0 then
            local reduction = math.ceil(leader.sisterBond / 3)
            -- print("阿比盖尔死亡reduction：", reduction)
            leader.sisterBond = leader.sisterBond - math.max(1, reduction)
        end
    end
end

local ATTACK_MUST_TAGS = { "_combat" }
local EXCLUDE_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget", "player", "companion", "invisible", "noattack", "hiding", "abigail", "abigail_tether" }
AddPrefabPostInit("abigail", function(inst)
    if inst then
        inst:ListenForEvent("pre_health_setval", OnSisterBondChange)
        inst:ListenForEvent("death", OnDeath)

        -- 侧翼机枪
        local attack_interval = 1.6
        inst:DoPeriodicTask(attack_interval, function()
            local player = inst._playerlink
            if player and player.components.ghostlybond and player.components.ghostlybond.summoned and player.sisterBond and player.sisterBond > 0 then
                if inst and inst.components.combat and inst.components.combat.target then
                    local target = inst.components.combat.target
                    -- 创建 abigail_tether
                    local tether = SpawnPrefab("abigail_tether")
                    if tether and target then
                        tether.Transform:SetPosition(inst.Transform:GetWorldPosition())

                        -- 获取 tether 手上的武器并修改攻击力
                        local weapon = tether.components.combat:GetWeapon()
                        local attack_power = player.sisterBond * 8/3 -- 计算攻击力
                        if weapon then
                            weapon.components.weapon:SetDamage(attack_power)
                        end

                        -- 检查目标生命值
                        if target.components.health and target.components.health.currenthealth < attack_power * 2 then
                            -- 寻找附近的其他目标
                            local nearby_target = nil
                            local x, y, z = target.Transform:GetWorldPosition()
                            local radius = 4

                            local entities = TheSim:FindEntities(x, y, z, radius, ATTACK_MUST_TAGS, EXCLUDE_TAGS)
                            for _, entity in ipairs(entities) do
                                if entity ~= target and entity.components.health and entity.components.health.currenthealth > 0 then
                                    nearby_target = entity
                                    break
                                end
                            end

                            -- 如果找到附近的目标，就攻击它
                            if nearby_target then
                                target = nearby_target
                            end
                        end

                        -- 攻击目标
                        if target.components.health then
                            tether.components.combat:DoAttack(target) -- 进行攻击
                            -- target.components.combat:SetTarget(nil)
                        end

                        tether:DoTaskInTime(attack_interval, function()
                            if tether and tether:IsValid() then
                                tether:Remove() -- 删除 tether
                            end
                        end)
                    end
                end
            end
        end)
    end
end)



