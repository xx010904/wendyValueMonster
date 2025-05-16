local GraveBunker = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("gravebunker")
end)

function GraveBunker:OnRemoveFromEntity()
    self.inst:RemoveTag("gravebunker")
end

local radius = 4 -- 定义半径
local totalScares = 4
function GraveBunker:DoBunk(doer)
	self.inst:RemoveTag("gravediggable")

	if self.inst == nil then
		return
	end
	-- 设置冷却时间
	self.inst:AddTag("bunkerCD")
	self.inst.AnimState:SetHaunted(true)
	self.inst:AddTag("haunted")
	-- self.cdtask = self.inst:DoTaskInTime(bunkCd, function()
	-- 	self.inst.AnimState:SetHaunted(false)
	-- 	self.inst:RemoveTag("haunted")
	-- 	self.inst:RemoveTag("bunkerCD")
	-- end)

    -- print("DoBunk called by:", doer.prefab)

    doer.usingbunker = self.inst
    self.inst:AddTag("hashider")

    if self.callingtask ~= nil then
        self.callingtask:Cancel()
    end

    -- 获取当前位置
    local x, y, z = self.inst.Transform:GetWorldPosition()
    -- 初始化大惊吓列表
    self.inst.scares = self.inst.scares or {}

    -- 创建大惊吓
    for i = 1, totalScares do
        local angle = (i - 1) * (360 / totalScares) -- 计算每个惊吓的角度

        -- 定义名字获取
        local function BigSpook_DisplayNameFn(inst)
            local names = STRINGS.NAMES.BIGSPOOK_ALT_NAMES
            if names and #names > 0 then
                local index = math.random(#names)
                return names[index]
            end
            return "Grave Guard Plus!"
        end

        -- 创建大惊吓实例
        local scare = SpawnPrefab("graveguard_ghost")
        if scare then
            -- 去掉大惊吓的脑子
            scare:SetBrain(nil)
            scare.components.combat:SetKeepTargetFunction(nil)

            -- 如果没有 Name 组件，添加一个 Name 组件
            if not scare.components.named then
                scare:AddComponent("named")
            end
            scare:AddComponent("discoparty")
            scare.components.discoparty:StartDisco()

            -- 设置名称为随机生成的名称
            scare.components.named:SetName(BigSpook_DisplayNameFn(scare))

			if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_makegravemounds") then
				if scare.components.health then
					scare.components.health:SetMaxHealth(TUNING.ABIGAIL_HEALTH_LEVEL3)
				end
				if scare.components.combat then
					scare.components.combat:SetDefaultDamage(TUNING.ABIGAIL_DAMAGE.night / 25)
				end
            else
                if scare.components.health then
					scare.components.health:SetMaxHealth(TUNING.ABIGAIL_HEALTH_LEVEL2)
				end
				if scare.components.combat then
					scare.components.combat:SetDefaultDamage(TUNING.ABIGAIL_DAMAGE.dusk / 25)
				end
			end
            -- 设置初始位置
            scare.Transform:SetPosition(
                x + radius * math.cos(math.rad(angle)),
                y, -- 保持 y 不变
                z + radius * math.sin(math.rad(angle))
            )
            -- print("Spawned graveguard_ghost at:", scare.Transform:GetWorldPosition())
            -- 检查并添加 locomotor 组件
            if not scare.components.locomotor then
                scare:AddComponent("locomotor")
            end
            -- 设定速度
            if scare.components.locomotor then
                scare.components.locomotor:StopMoving()
                scare.components.locomotor:SetExternalSpeedMultiplier(scare, "soldierspeedboost", 1.5)
            end

            -- 监听死亡事件
            scare:ListenForEvent("death", function()
                if scare:IsValid() then
                    -- 调用 DoLeave 方法
                    self.inst:AddTag("hasScareDeath")
                    self:DoLeave(doer)
                end
            end)

            -- 监听被打事件
            scare:ListenForEvent("attacked", function()
                if scare:IsValid() then
                    self.inst:AddTag("hasScareHurt")
                end
            end)

            table.insert(self.inst.scares, scare) -- 记录到实例中
        else
            -- print("Failed to spawn graveguard_ghost")
        end
    end

    -- 定义移动任务
    local function MoveScares()
        local time = GetTime() -- 获取当前时间
        local maxScares = #self.inst.scares -- 获取大惊吓数量

        for i, scare in ipairs(self.inst.scares) do
            local index = i - 1 -- 从 0 开始索引
            local FORMATION_RADIUS = radius -- 使用定义的半径
            local FORMATION_ROTATION_SPEED = 0.5 -- 设置旋转速度
            local theta = (index / maxScares) * (2 * math.pi) + time * FORMATION_ROTATION_SPEED -- 计算角度

            -- 获取中心点位置
            local center_x, center_y, center_z = self.inst.Transform:GetWorldPosition()

            -- 计算目标位置
            local target_x = center_x + FORMATION_RADIUS * math.cos(theta)
            local target_z = center_z + FORMATION_RADIUS * math.sin(theta)

            -- 移动到目标位置
            if scare.components.locomotor then
                scare.components.locomotor:GoToPoint(Vector3(target_x, center_y, target_z))
                scare:FacePoint(target_x, center_y, target_z) -- 朝向目标位置
            end

            local scarex, scarey, scarez = scare.Transform:GetWorldPosition()
            local scareradius = 4 -- 伤害范围
            local AREAATTACK_MUST_TAGS = { "_combat" }
            local AREA_EXCLUDE_TAGS = {
                "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget",
                "player", "companion", "invisible", "noattack", "hiding",
                "abigail", "abigail_tether", "graveghost", "ghost", "shadowcreature",
                "playingcard", "deckcontainer"
            }
            local targets = TheSim:FindEntities(scarex, scarey, scarez, scareradius, AREAATTACK_MUST_TAGS, AREA_EXCLUDE_TAGS)
            for _, target in ipairs(targets) do
                if target.components.health and scare.components.combat then
                    scare.components.combat:DoAttack(target)
                end
            end
            -- print("Moved graveguard_ghost #", i, "to:", scare.Transform:GetWorldPosition())
        end
    end

    -- 更新大惊吓的位置
    self.scaretask = self.inst:DoPeriodicTask(0.1, MoveScares)

    -- 消耗 sanity
    if doer and doer.components.sanity then
        if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_makegravemounds") then
            doer.components.sanity:DoDelta(-5)
        else
            doer.components.sanity:DoDelta(-10)
        end
    end
    self.sanitytask = doer:DoPeriodicTask(1.33, function()
        if doer and doer.components.sanity then
            -- 不然无限卡在墓碑里面了
            if doer.components.sanity:GetPercent() <= 0 then
                self:DoLeave(doer)
            end
			if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_makegravemounds") then
				doer.components.sanity:DoDelta(-1)
			else
				doer.components.sanity:DoDelta(-2)
			end
        end
    end)
    -- print("Scare task created to move ghosts.")
end

local function SetSleeperAwakeState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:RemoveImmunity("sleeping")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("sleeping")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(true)
        inst.components.playercontroller:Enable(true)
    end
    inst:OnWakeUp()
    inst.components.inventory:Show()
    inst:ShowActions(true)
end


function GraveBunker:DoLeave(doer)
    -- print("DoLeave called by:", doer.prefab)
    doer.usingbunker = nil
	self.inst:AddTag("gravediggable")

	-- 设置更多冷却时间
	if not self.inst:HasTag("bunkerCD") then
		self.inst.AnimState:SetHaunted(true)
		self.inst:AddTag("haunted")
		self.inst:AddTag("bunkerCD")
	end

	if self.cdtask then
		self.cdtask:Cancel()
		self.cdtask = nil
	end

    local bunkCd = 5
    print("hasScareHurt", self.inst:HasTag("hasScareHurt"))
    if self.inst:HasTag("hasScareDeath") or self.inst:HasTag("hasScareHurt") then
        bunkCd = 120
    end
    self.cdtask = self.inst:DoTaskInTime(bunkCd, function()
		self.inst.AnimState:SetHaunted(false)
		self.inst:RemoveTag("haunted")
		self.inst:RemoveTag("bunkerCD")
        self.inst:RemoveTag("hasScareDeath")
        self.inst:RemoveTag("hasScareHurt")
	end)

	if self.inst:HasTag("hasScareDeath") then
		doer.sg:GoToState("getoffbunker")
	end

    self.inst:RemoveTag("hashider")

    if self.scaretask then
        self.scaretask:Cancel()
        self.scaretask = nil
    end

	if self.sanitytask then
        self.sanitytask:Cancel()
        self.sanitytask = nil
    end

    -- 移除所有大惊吓
	if self.inst.scares then
		for _, scare in ipairs(self.inst.scares) do
			if scare and scare:IsValid() then
                scare.components.discoparty:StopDisco()
                scare.components.locomotor:Stop()
                scare.components.locomotor:Clear()
                scare.AnimState:PlayAnimation("dissipate")
                scare:ListenForEvent("animover", scare.Remove)
			end
		end
	end

	self.inst.scares = {} -- 清空记录

    if self.inst.Physics ~= nil then
        doer.Physics:Teleport(self.inst.Transform:GetWorldPosition())
    end
    -- 暂时无敌
	doer:DoTaskInTime(0.5, function (inst)
		inst.components.health:SetInvincible(false)
	end)
	doer:Show()
	if doer.DynamicShadow ~= nil then
		doer.DynamicShadow:Enable(true)
	end
	SetSleeperAwakeState(doer)
	doer.components.locomotor:Stop()
end

return GraveBunker
