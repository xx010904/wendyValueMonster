
--DSV uses 4 but ignores physics radius
local function onattacked_shield(inst, data)
    if data.redirected then
        return
    end

	local fx = SpawnPrefab("elixir_player_forcefield")
	inst:AddChild(fx)
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/shield/on")

	inst.components.health.externalreductionmodifiers:RemoveModifier(inst, "ghostlyelixir_shield")
end

local EXCLUDE_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget", "player", "companion", "invisible", "noattack", "hiding", "abigail", "abigail_tether", "shadowcreature" }
local COMBAT_TARGET_TAGS = { "_combat" }
local function onattacked_retaliation(inst, data)
	inst:RemoveEventCallback("attacked", onattacked_retaliation)
	local hitrange = 5
	local damage = math.random(10, 30)

	local x, y, z = inst.Transform:GetWorldPosition()

	for i, v in ipairs(TheSim:FindEntities(x, y, z, hitrange, COMBAT_TARGET_TAGS, EXCLUDE_TAGS)) do
		if v:IsValid() and v.entity:IsVisible() and v.components.combat ~= nil then
			local range = hitrange + v:GetPhysicsRadius(0)
			if v:GetDistanceSqToPoint(x, y, z) < range * range then
				if inst.owner ~= nil and not inst.owner:IsValid() then
					inst.owner = nil
				end
				if inst.owner ~= nil then
					if inst.owner.components.combat ~= nil and
						inst.owner.components.combat:CanTarget(v) and
						not inst.owner.components.combat:IsAlly(v)
					then
						local retaliation = SpawnPrefab("abigail_retaliation")
						retaliation:SetRetaliationTarget(v)
					end
				elseif v.components.combat:CanBeAttacked() then
					-- NOTES(JBK): inst.owner is nil here so this is for non worn things like the bramble trap.
					local isally = false
					if not inst.canhitplayers then
						--non-pvp, so don't hit any player followers (unless they are targeting a player!)
						local leader = v.components.follower ~= nil and v.components.follower:GetLeader() or nil
						isally = leader ~= nil and leader:HasTag("player") and
							not (v.components.combat ~= nil and
								v.components.combat.target ~= nil and
								v.components.combat.target:HasTag("player"))
					end
					if not isally then
						v.components.combat:GetAttacked(inst, damage, nil, nil, inst.spdmg)
						local retaliation = SpawnPrefab("abigail_retaliation")
						retaliation:SetRetaliationTarget(v)
					end
				end
			end
		end
	end
end

local potion_tunings =
{
	-- 亡者补药 Revenant Restorative
	ghostlyelixir_slowregen =
	{
		TICK_RATE = 2.2,
		-- ABIGAIL CONTENT
		ONAPPLY = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(5, true, inst.prefab)
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(-5, true, inst.prefab)
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.health ~= nil then
				if math.random() > 0.2 then
					target.components.health:DoDelta(3, true, inst.prefab)
				else
					target.components.health:DoDelta(-1, true, inst.prefab)
				end
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_SLOWREGEN_DURATION, --480s
		FLOATER = {"small", 0.15, 0.55},
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
		skill_modifier_long_duration = true,

		-- PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(5, true, inst.prefab)
			end
		end,
		ONDETACH_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(-5, true, inst.prefab)
			end
		end,
		TICK_FN_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				if math.random() > 0.2 then
					target.components.health:DoDelta(3, true, inst.prefab)
				else
					target.components.health:DoDelta(-1, true, inst.prefab)
				end
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_SLOWREGEN_DURATION, --20s
		fx_player = "ghostlyelixir_player_slowregen_fx",
		dripfx_player = "ghostlyelixir_player_slowregen_dripfx",
		ghostly_healing = true,
	},
	-- 灵魂万灵药 Spectral Cure-All
	ghostlyelixir_fastregen =
	{
		TICK_RATE = 0.25,
		-- ABIGAIL CONTENT
		ONAPPLY = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(math.random(250, 300), true, inst.prefab)
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(120 + math.random(250, 300), true, inst.prefab) -- 补偿前面扣的120
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(-1, true, inst.prefab)
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_FASTREGEN_DURATION, --30s
		FLOATER = {"small", 0.15, 0.55},
		fx = "ghostlyelixir_fastregen_fx",
		dripfx = "ghostlyelixir_fastregen_dripfx",

		-- PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(25, true, inst.prefab)
			end
		end,
		ONDETACH_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(20 + math.random(50, 100), true, inst.prefab)  -- 补偿前面扣的20
			end
		end,
		TICK_FN_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(-0.25, true, inst.prefab)
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_FASTREGEN_DURATION, --20s
		fx_player = "ghostlyelixir_player_fastregen_fx",
		dripfx_player = "ghostlyelixir_player_fastregen_dripfx",
		ghostly_healing = true,
	},
	-- 夜影万金油 Nightshade Nostrum
	ghostlyelixir_attack =
	{
		TICK_RATE = 0.9,
		-- ABIGAIL CONTENT
		ONAPPLY = function(inst, target)
			if target.components.combat then
				target.components.combat.externaldamagemultipliers:SetModifier(target, 1.25, "ghostlyelixir_attack")
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.combat then
				target.components.combat.externaldamagemultipliers:RemoveModifier(target, "ghostlyelixir_attack")
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.combat then
				target.components.combat.externaldamagemultipliers:RemoveModifier(target, "ghostlyelixir_attack")
				local attack = math.random(10, 15) / 10
				target.components.combat.externaldamagemultipliers:SetModifier(target, attack, "ghostlyelixir_attack")
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_DAMAGE_DURATION, --480s
		FLOATER = {"small", 0.1, 0.5},
		fx = "ghostlyelixir_attack_fx",
		dripfx = "ghostlyelixir_attack_dripfx",
		skill_modifier_long_duration = true,

		-- PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			target:AddDebuff("ghostvision_buff", "ghostvision_buff")
		end,
		ONDETACH_PLAYER = function(inst, target)
			target:RemoveDebuff("ghostvision_buff")
		end,
		TICK_FN_PLAYER = function(inst, target)
			target:RemoveDebuff("ghostvision_buff")
			if math.random() > 0.1 then
				target:AddDebuff("ghostvision_buff", "ghostvision_buff")
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_DAMAGE_DURATION, --360s
		fx_player = "ghostlyelixir_player_attack_fx",
		dripfx_player = "ghostlyelixir_player_attack_dripfx",
	},
	-- 强健精油 Vigor Mortis
	ghostlyelixir_speed =
	{
		-- ABIGAIL CONTENT
		TICK_RATE = 0.5,
		ONAPPLY = function(inst, target)
			if target.components.locomotor ~= nil then
				target.components.locomotor:SetExternalSpeedMultiplier(inst, "ghostlyelixir_speed", 1.75)
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.locomotor ~= nil then
				target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ghostlyelixir_speed")
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.locomotor ~= nil then
				target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ghostlyelixir_speed")
				local speed = math.random(10, 25) / 10
				target.components.locomotor:SetExternalSpeedMultiplier(inst, "ghostlyelixir_speed", speed)
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_SPEED_DURATION, --480s
        FLOATER = {"small", 0.2, 0.4},
		fx = "ghostlyelixir_speed_fx",
		dripfx = "ghostlyelixir_speed_dripfx",
		speed_hauntable = true,
		skill_modifier_long_duration = true,

		--PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			if target.components.locomotor ~= nil then
				target.components.locomotor:SetExternalSpeedMultiplier(inst, "ghostlyelixir_speed", 1.25)
			end
		end,
		ONDETACH_PLAYER = function(inst, target)
			if target.components.locomotor ~= nil then
				target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ghostlyelixir_speed")
			end
		end,
		TICK_FN_PLAYER = function(inst, target)
			if target.components.locomotor ~= nil then
				target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ghostlyelixir_speed")
				local speed = math.random(10, 15) / 10
				target.components.locomotor:SetExternalSpeedMultiplier(inst, "ghostlyelixir_speed", speed)
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_SPEED_DURATION, --480s
		fx_player = "ghostlyelixir_player_speed_fx",
		dripfx_player = "ghostlyelixir_player_speed_dripfx",
	},
	-- 不屈药剂 Unyielding Draught
	ghostlyelixir_shield =
	{
		TICK_RATE = 10,
		-- ABIGAIL CONTENT
		ONAPPLY = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:SetModifier(target, 75, "ghostlyelixir_shield")
				target:ListenForEvent("attacked", onattacked_shield)
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:RemoveModifier(target, "ghostlyelixir_shield")
				target:RemoveEventCallback("attacked", onattacked_shield)
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:RemoveModifier(target, "ghostlyelixir_shield")
				target.components.health.externalreductionmodifiers:SetModifier(target, math.random(50, 100), "ghostlyelixir_shield")
				target:RemoveEventCallback("attacked", onattacked_shield)
				target:ListenForEvent("attacked", onattacked_shield)
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_SHIELD_DURATION,
        FLOATER = {"small", 0.15, 0.8},
		shield_prefab = "abigailforcefieldbuffed",
		fx = "ghostlyelixir_shield_fx",
		dripfx = "ghostlyelixir_shield_dripfx",
		skill_modifier_long_duration = true,

		--PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:SetModifier(target, 50, "ghostlyelixir_shield")
				target:ListenForEvent("attacked", onattacked_shield)
			end
		end,
		ONDETACH_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:RemoveModifier(target, "ghostlyelixir_shield")
				target:RemoveEventCallback("attacked", onattacked_shield)
			end
		end,
		TICK_FN_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:RemoveModifier(target, "ghostlyelixir_shield")
				target.components.health.externalreductionmodifiers:SetModifier(target, math.random(25, 75), "ghostlyelixir_shield")
				target:RemoveEventCallback("attacked", onattacked_shield)
				target:ListenForEvent("attacked", onattacked_shield)
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_SHIELD_DURATION,
		fx_player = "ghostlyelixir_player_shield_fx",
		dripfx_player = "ghostlyelixir_player_shield_dripfx",
	},
	-- 蒸馏复仇 Distilled Vengeance
	ghostlyelixir_retaliation =
	{
		TICK_RATE = 2.5,
		-- ABIGAIL CONTENT
		ONAPPLY = function(inst, target)
			if target.components.health ~= nil then
				target:ListenForEvent("attacked", onattacked_retaliation)
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.health ~= nil then
				target:RemoveEventCallback("attacked", onattacked_retaliation)
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.health ~= nil then
				target:RemoveEventCallback("attacked", onattacked_retaliation)
				target:ListenForEvent("attacked", onattacked_retaliation)
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_RETALIATION_DURATION,
		-- ABIGAIL CONTENT
        FLOATER = {"small", 0.2, 0.4},
		shield_prefab = "abigailforcefieldretaliation",
		fx = "ghostlyelixir_retaliation_fx",
		dripfx = "ghostlyelixir_retaliation_dripfx",
		skill_modifier_long_duration = true,

		--PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target:ListenForEvent("attacked", onattacked_retaliation)
			end
		end,
		ONDETACH_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target:RemoveEventCallback("attacked", onattacked_retaliation)
			end
		end,
		TICK_FN_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target:RemoveEventCallback("attacked", onattacked_retaliation)
				target:ListenForEvent("attacked", onattacked_retaliation)
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_SHIELD_DURATION,
		playerreatliate=true,
		fx_player = "ghostlyelixir_player_retaliation_fx",
		dripfx_player = "ghostlyelixir_player_retaliation_dripfx",
	},
	-- 恐怖经历 Ghastly Experience
	ghostlyelixir_revive =
	{
		TICK_RATE = 0.1,
		-- ABIGAIL CONTENT
		ONAPPLY = function(inst, target)
			if target.components.follower.leader and target.components.follower.leader.components.ghostlybond then
				local ghostlybond = target.components.follower.leader.components.ghostlybond
				if ghostlybond.bondlevel < 2 then
					ghostlybond:SetBondLevel(2)
				end
			end
		end,
		ONDETACH = function(inst, target)
			if target.components.health ~= nil then
				if target.components.follower.leader and target.components.follower.leader.components.ghostlybond then
					local ghostlybond = target.components.follower.leader.components.ghostlybond
					ghostlybond:SetBondLevel(ghostlybond.maxbondlevel)
				end
			end
		end,
		TICK_FN = function(inst, target)
			if target.components.health ~= nil then
				target.components.health:DoDelta(1, true, inst.prefab)
			end
		end,
		DURATION = TUNING.GHOSTLYELIXIR_REVIVE_DURATION, --2s
		-- ABIGAIL CONTENT
        FLOATER = {"small", 0.1, 0.7},
		fx = "ghostlyelixir_retaliation_fx",
		dripfx = "ghostlyelixir_retaliation_dripfx",
		skill_modifier_long_duration = true,

		--PLAYER CONTENT
		ONAPPLY_PLAYER = function(inst, target)
			local mult = math.random(25, 30)
			if target.components.sanity then
				target.components.sanity:DoDelta(5/mult)
			end
			if target.components.hunger then
				target.components.hunger:DoDelta(12.5/mult)
			end
			if target.components.health ~= nil then
				target.components.health:DeltaPenalty(-0.25/mult)
			end
		end,
		ONDETACH_PLAYER = function(inst, target)
			local mult = math.random(25, 30)
			if target.components.sanity then
				target.components.sanity:DoDelta(5/mult)
			end
			if target.components.hunger then
				target.components.hunger:DoDelta(12.5/mult)
			end
			if target.components.health ~= nil then
				target.components.health:DeltaPenalty(-0.25/mult)
			end
		end,
		TICK_FN_PLAYER = function(inst, target)
			local mult = math.random(25, 30)
			if target.components.sanity then
				target.components.sanity:DoDelta(5/mult)
			end
			if target.components.hunger then
				target.components.hunger:DoDelta(12.5/mult)
			end
			if target.components.health ~= nil then
				target.components.health:DeltaPenalty(-0.25/mult)
			end
		end,
		DURATION_PLAYER = TUNING.GHOSTLYELIXIR_PLAYER_REVIVE_DURATION * 10, --3s
		fx_player = "ghostlyelixir_player_retaliation_fx",
		dripfx_player = "ghostlyelixir_player_retaliation_dripfx",
	},
}

local function OnTimerDone(inst, data)
    if data.name == "explode" then
        inst.components.debuff:Stop()
    end
end

local function buff_OnTick(inst, target)
    if target.components.health ~= nil and not target.components.health:IsDead() then
        if target:HasTag("player") then
            inst.potion_tunings.TICK_FN_PLAYER(inst, target)
        else
            inst.potion_tunings.TICK_FN(inst, target)
        end
    else
        inst.components.debuff:Stop()
    end
end

local function buff_DripFx(inst, target)
    local prefab = (target:HasTag("player") and inst.potion_tunings.dripfx_player) or inst.potion_tunings.dripfx

    if not target.inlimbo and not target.sg:HasStateTag("busy") then
        SpawnPrefab(prefab).Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function OnAttached(inst, target)
	local duration = inst.potion_tunings.DURATION
	-- inst.components.timer:StartTimer("explode", duration * 0.25 + 0.25)
	inst.components.timer:StartTimer("explode", duration)

    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading

    if target:HasTag("player") then
        if inst.potion_tunings.ONAPPLY_PLAYER ~= nil then
            inst.potion_tunings.ONAPPLY_PLAYER(inst, target)
        end
    else
        if inst.potion_tunings.ONAPPLY ~= nil then
            inst.potion_tunings.ONAPPLY(inst, target)
        end
    end

    if inst.potion_tunings.TICK_RATE ~= nil then
        inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
    end

	-- 滴落效果
    inst.driptask = inst:DoPeriodicTask(1.3, buff_DripFx, 0.44, target)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    if inst.potion_tunings.fx ~= nil and not target.inlimbo then
        local fx = SpawnPrefab((target:HasTag("player") and inst.potion_tunings.fx_player) or inst.potion_tunings.fx)
        fx.entity:SetParent(target.entity)
    end
end

local function OnExtended(inst, target)
	-- local duration = inst.potion_tunings.DURATION
	-- inst.components.timer:StopTimer("explode")
	-- inst.components.timer:StartTimer("explode", duration * 0.25 + 0.25)

	-- if inst.task ~= nil then
	-- 	inst.task:Cancel()
	-- 	inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
	-- end

	-- -- 多次特效
	-- -- if inst.potion_tunings.fx ~= nil and not target.inlimbo and not target:HasTag("player") then
	-- -- 	local fx = SpawnPrefab(inst.potion_tunings.fx)
	-- --     fx.entity:SetParent(target.entity)
	-- -- end

	-- inst.slowed = nil
end

local function OnDetached(inst, target)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if inst.driptask ~= nil then
        inst.driptask:Cancel()
        inst.driptask = nil
    end

    if target:HasTag("player") then
        if inst.potion_tunings.ONDETACH_PLAYER ~= nil then
            inst.potion_tunings.ONDETACH_PLAYER(inst, target)
        end
    else
        if inst.potion_tunings.ONDETACH ~= nil then
            inst.potion_tunings.ONDETACH(inst, target)
        end
    end
    inst:Remove()
end

local function MakeUnstableBuff(name)
    local potion_prefab = "ghostlyelixir_"..name

    local function buff_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst.potion_tunings = potion_tunings[potion_prefab]

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)

        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab("unstable_ghostlyelixir_buff_"..name, buff_fn)
end

return MakeUnstableBuff("revive"),
        MakeUnstableBuff("speed"),
        MakeUnstableBuff("attack"),
        MakeUnstableBuff("retaliation"),
        MakeUnstableBuff("shield"),
        MakeUnstableBuff("fastregen"),
        MakeUnstableBuff("slowregen")