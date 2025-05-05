local AstroWraith = Class(function(self, inst)
    self.inst = inst
    self.aoe_enabled = false
    self.attack_count = 0
    self.radius = 4
    self.aoe_task = nil
    self.update_timer = 0
    self.original_damagemultiplier = nil
    self.max_attack_count = 100
    self.drown_rate = 0.06
    self.attack_rate = 0.66

    inst:ListenForEvent("onattackother", function(inst, data)
        if data and data.target and inst.components.astrowraith then
            inst.components.astrowraith:OnAttackLanded(data.target)
        end
    end)

    -- 注册更新回调
    inst:StartUpdatingComponent(self)
end)

-- 每次攻击命中时掉 attack_rate 点
function AstroWraith:OnAttackLanded(target)
    if self.attack_count > 0 then
        self.attack_count = self.attack_count - self.attack_rate

        if self.attack_count == 0 and self.original_damagemultiplier then
            self.inst.components.combat.damagemultiplier = self.original_damagemultiplier
            self.original_damagemultiplier = nil

            if self.inst.components.talker then
                self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_LOST_GHOST_POWER"), nil, true)
            end
        end
    end
end

-- 每帧更新（由 StartUpdatingComponent 启动）
function AstroWraith:OnUpdate(dt)
    self.update_timer = self.update_timer + dt

    if self.update_timer >= 1.0 then
        self.update_timer = self.update_timer - 1.0
        self:UpdateAttackCount()
    end
end

-- 长时间更新（如跳过天数）
function AstroWraith:LongUpdate(dt)
    while dt > 1 do
        dt = dt - 1
        self:UpdateAttackCount()
    end
end

-- 每秒递减攻击计数并调整伤害倍率
function AstroWraith:UpdateAttackCount()
    local combat = self.inst.components.combat
    if not combat then return end

    -- 更新 HUD 上的 AvengingGhostBadge 的数字显示
    if TheWorld.ismastersim and self.inst.userid then
        SendModRPCToClient(
            CLIENT_MOD_RPC["WendyValueMonster"]["UpdateGhostPowerBadge"],
            self.inst.userid,
            self.attack_count,
            self.max_attack_count
        )
    end

    -- 如果是鬼魂状态，重置为原始倍率
    if self.inst:HasTag("playerghost") or self.inst:HasTag("playerghost_fake") then
        if self.original_damagemultiplier ~= nil then
            combat.damagemultiplier = self.original_damagemultiplier
            self.original_damagemultiplier = nil
        end
        return
    end

    if self.attack_count > 0 then
        self.attack_count = self.attack_count - self.drown_rate

        -- 如果没有记录原始倍率，则记录一次
        if self.original_damagemultiplier == nil then
            self.original_damagemultiplier = combat.damagemultiplier or 1
            combat.damagemultiplier = self.original_damagemultiplier + 0.25
        end
    else
        -- 恢复原始倍率
        if self.original_damagemultiplier ~= nil then
            combat.damagemultiplier = self.original_damagemultiplier
            self.original_damagemultiplier = nil

            if self.inst.components.talker then
                self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_LOST_GHOST_POWER"), nil, true)
            end
        end
    end

end


-- 启动AOE攻击
function AstroWraith:EnableAOE()
    if self.aoe_enabled then return end
    self.aoe_enabled = true

    self.aoe_task = self.inst:DoPeriodicTask(1, function()
        self:DoAOEAttack()
    end, 0.5)
end

-- 停止AOE攻击
function AstroWraith:DisableAOE()
    if not self.aoe_enabled then return end
    self.aoe_enabled = false

    if self.aoe_task then
        self.aoe_task:Cancel()
        self.aoe_task = nil
    end
end

-- 增加攻击计数
function AstroWraith:AddAttackCount(num)
    num = num or 0.5
    if self.max_attack_count > self.attack_count then
        self.attack_count = self.attack_count + num
    end
end

-- 范围攻击
function AstroWraith:DoAOEAttack()
    if not self.inst:IsValid() or not self.inst.components.combat then
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local radius = self.radius or 4

    local MUST_TAGS = { "_combat" }
    local EXCLUDE_TAGS = {
        "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget",
        "player", "companion", "invisible", "noattack", "hiding",
        "abigail", "abigail_tether", "graveghost", "ghost", "shadowcreature",
        "playingcard", "deckcontainer"
    }

    local targets = TheSim:FindEntities(x, y, z, radius, MUST_TAGS, EXCLUDE_TAGS)

    for _, target in ipairs(targets) do
        if target ~= self.inst and target.components.health and not target.components.health:IsDead() then
            self.inst.components.combat:DoAttack(target)

            if target:HasTag("epic") then
                self:AddAttackCount(2.5)
            end
            self:AddAttackCount(0.5)
        end
    end
end

-- 状态辅助函数
function AstroWraith:IsAOEEnabled()
    return self.aoe_enabled
end

function AstroWraith:GetAttackCount()
    return self.attack_count
end

function AstroWraith:SetRadius(r)
    self.radius = r
end

-- 保存/加载函数
function AstroWraith:OnSave()
    return {
        attack_count = self.attack_count,
        original_damagemultiplier = self.original_damagemultiplier,
    }
end

function AstroWraith:OnLoad(data)
    if data then
        self.attack_count = data.attack_count or 0
        self.original_damagemultiplier = data.original_damagemultiplier or nil

        -- 如果角色不是鬼魂，并且原始倍率被保存了，恢复它
        if self.original_damagemultiplier and not (self.inst:HasTag("playerghost") or self.inst:HasTag("playerghost_fake")) then
            local combat = self.inst.components.combat
            if combat then
                combat.damagemultiplier = self.original_damagemultiplier + 0.25
            end
        end
    end
end

return AstroWraith