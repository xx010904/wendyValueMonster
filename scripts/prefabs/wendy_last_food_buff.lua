local assets ={}

local FADE_FRAMES = 5

local function OnUpdateFade(inst)
    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function AlignToTarget(inst, target)
    -- 持续掉血
    -- if target.components.health then
    --     local delta = target.components.health.maxhealth * (0.13/4)
    --     target.components.health:DoDelta(-delta)
    -- end
    inst.Transform:SetRotation(target.Transform:GetRotation())
end

local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function GhostActionFilter(inst, action)
    return action.ghost_valid
end

local function ConfigureGhostActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PushActionFilter(GhostActionFilter, 99)
    end
end

local function ConfigureGhostLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4 is base
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6 is base
    inst.components.locomotor.fasteronroad = false
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor:SetAllowPlatformHopping(false)
	inst.components.locomotor.pusheventwithdirection = true
end

local function CommonPlayerDeath(inst)
    inst.player_classified.MapExplorer:EnableUpdate(false)

    inst:RemoveComponent("burnable")

    inst.components.freezable:Reset()
    inst:RemoveComponent("freezable")
    inst:RemoveComponent("propagator")

    inst:RemoveComponent("grogginess")
	inst:RemoveComponent("slipperyfeet")

    inst.components.moisture:ForceDry(true, inst)

    inst.components.sheltered:Stop()

    inst.components.debuffable:Enable(false)

    if inst.components.revivablecorpse == nil then
        inst.components.age:PauseAging()
    end

    inst.components.frostybreather:Disable()
end

--- speed
local function IsFacingTarget(inst, target_pos, threshold_angle)
    local facing_angle = inst.Transform:GetRotation()
    local to_target = target_pos - inst:GetPosition()
    local target_angle = math.deg(math.atan2(-to_target.z, to_target.x)) -- 注意DST里z是负的
    local diff = math.abs(anglediff(facing_angle, target_angle))

    return diff <= threshold_angle
end

local function UpdateSpeed(inst, target_pos)
    if not inst:IsValid() then
        return
    end

    local current_pos = inst:GetPosition()
    local dist = current_pos:Dist(target_pos)

    -- 根据距离线性衰减
    local max_speed = 3
    local max_distance = 30
    local speed = max_speed * math.max(0, (max_distance - dist) / max_distance)

    -- 如果朝向目标点，速度直接是部分衰减
    if IsFacingTarget(inst, target_pos, 180) then -- 允许角度误差
        speed = speed * 1.5
        if speed > max_speed then
            speed = max_speed
        end
    end

    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "last_dash", speed)
end


local function StartSpeedUpdater(inst, x, y, z)
    if inst.speedupdater_task then
        inst.speedupdater_task:Cancel()
    end

    local target_pos = Vector3(x, y, z)

    inst.speedupdater_task = inst:DoPeriodicTask(0.1, function()
        UpdateSpeed(inst, target_pos)
    end)
end


---- death begin
local function becomeGhost(inst)
    if inst:HasTag("playerghost_fake") then
        return
    end
    inst:AddTag("noteleport")

    local x, y, z = inst.Transform:GetWorldPosition()
    inst.AnimState:SetBank("ghost")

    inst.components.skinner:SetSkinMode("ghost_skin")

    inst.components.bloomer:PushBloom("playerghostbloom", "shaders/anim_bloom_ghost.ksh", 100)
    inst.AnimState:SetLightOverride(TUNING.GHOST_LIGHT_OVERRIDE)

    inst:SetStateGraph("SGwilsonghost")

    --Switch to ghost light values
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.6)
    inst.Light:SetColour(180/255, 195/255, 225/255)
    inst.Light:Enable(true)
    inst.DynamicShadow:Enable(false)

    CommonPlayerDeath(inst)

    MakeGhostPhysics(inst, 1, .5)
    inst.Physics:Teleport(x + 1, y + 1, z + 1)

    inst:AddTag("playerghost_fake")
    inst.Network:AddUserFlag(USERFLAGS.IS_GHOST)

    inst.components.health:ForceUpdateHUD(true)

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(true)
    end
    inst.player_classified:SetGhostMode(true)

    ConfigureGhostLocomotor(inst)
    ConfigureGhostActions(inst)

    -- 隐藏物品栏
    inst.components.inventory:Hide()
    StartSpeedUpdater(inst, x, y, z)

end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)
    -- OnChangeFollowSymbol(inst, target, followsymbol, Vector3(followoffset.x, -255, followoffset.z)) --y越小，位置越高
    OnChangeFollowSymbol(inst, target, followsymbol, Vector3(followoffset.x, -15, followoffset.z)) --y越小，位置越高

    -- buff效果跟随，并且持续掉血
    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
    inst._followtask = inst:DoPeriodicTask(0.13, AlignToTarget, nil, target)
    AlignToTarget(inst, target)

    ---- 不生成骨架
    target.old_skeleton_prefab = target.skeleton_prefab
    target.skeleton_prefab = nil

    ---- 开始死亡                
    becomeGhost(target)
    target.components.avengingghost:StartAvenging()
end

local function ShouldKnockout(inst)
    return DefaultKnockoutTest(inst) and not inst.sg:HasStateTag("yawn")
end

local function GetHopDistance(inst, speed_mult)
	return speed_mult < 0.8 and TUNING.WILSON_HOP_DISTANCE_SHORT
			or speed_mult >= 1.2 and TUNING.WILSON_HOP_DISTANCE_FAR
			or TUNING.WILSON_HOP_DISTANCE
end

local function ConfigurePlayerActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PopActionFilter(GhostActionFilter)
    end
end

local function ConfigurePlayerLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6
    inst.components.locomotor.fasteronroad = true
    inst.components.locomotor:SetFasterOnCreep(inst:HasTag("spiderwhisperer"))
    inst.components.locomotor:SetTriggersCreep(not inst:HasTag("spiderwhisperer"))
    inst.components.locomotor:SetAllowPlatformHopping(true)
	inst.components.locomotor:EnableHopDelay(true)
	inst.components.locomotor.hop_distance_fn = GetHopDistance
	inst.components.locomotor.pusheventwithdirection = true
end

local function CommonActualRez(inst)
    inst.player_classified.MapExplorer:EnableUpdate(true)

    if inst.components.revivablecorpse ~= nil then
        inst.components.inventory:Show()
    else
        inst.components.inventory:Open()
        inst.components.age:ResumeAging()
    end

    inst.components.health.canheal = true
    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:Resume()
    end
    if not GetGameModeProperty("no_temperature") then
        inst.components.temperature:SetTemp() --nil param will resume temp
    end
    inst.components.frostybreather:Enable()

    MakeMediumBurnableCharacter(inst, "torso")
    inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
    inst.components.burnable.nocharring = true

    MakeLargeFreezableCharacter(inst, "torso")
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

    inst:AddComponent("grogginess")
    inst.components.grogginess:SetResistance(3)
    inst.components.grogginess:SetKnockOutTest(ShouldKnockout)

	inst:AddComponent("slipperyfeet")

    inst.components.moisture:ForceDry(false, inst)

    inst.components.sheltered:Start()

    inst.components.debuffable:Enable(true)

    --don't ignore sanity any more
    inst.components.sanity.ignore = GetGameModeProperty("no_sanity")

    ConfigurePlayerLocomotor(inst)
    ConfigurePlayerActions(inst)

    if inst.rezsource ~= nil then
        local announcement_string = GetNewRezAnnouncementString(inst, inst.rezsource)
        if announcement_string ~= "" then
            TheNet:AnnounceResurrect(announcement_string, inst.entity)
        end
        inst.rezsource = nil
    end
    inst.remoterezsource = nil

	inst.last_death_position = nil
	inst.last_death_shardid = nil

	inst:RemoveTag("reviving")
end

local function DoActualRez(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if x and y and z then
        local diefx = SpawnPrefab("die_fx")
        if diefx then
            diefx.Transform:SetPosition(x, y, z)
        end
    end

    -- inst.AnimState:SetBank("wilson")
    -- inst.components.skinner:SetSkinMode("normal_skin")

    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
	inst.AnimState:Hide("HEAD_HAT_NOHELM")
	inst.AnimState:Hide("HEAD_HAT_HELM")

    inst:Show()

    inst:SetStateGraph("SGwilson")

    inst.Physics:Teleport(x, y, z)

    inst.player_classified:SetGhostMode(false)

    -- Resurrector is involved
    inst.DynamicShadow:Enable(true)
    inst.AnimState:SetBank("wilson")
    inst.ApplySkinOverrides(inst) -- restore skin
    inst.components.bloomer:PopBloom("playerghostbloom")
    inst.AnimState:SetLightOverride(0)

    inst.components.inventory:Hide()
    inst:PushEvent("ms_closepopups")
    inst.sg:GoToState("rewindtime_rebirth")

    SpawnPrefab("attune_in_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    SpawnPrefab("abigailunsummonfx").Transform:SetPosition(inst.Transform:GetWorldPosition())

    --Default to electrocute light values
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.65)
    inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)
    inst.Light:Enable(false)

    MakeCharacterPhysics(inst, 75, .5)

    CommonActualRez(inst)

    inst:RemoveTag("playerghost_fake")
    inst.Network:RemoveUserFlag(USERFLAGS.IS_GHOST)

    inst:PushEvent("ms_respawnedfromghost")
end

local function respawnFromGhost(inst, data) -- from ListenForEvent "respawnfromghost")
    if not inst:HasTag("playerghost_fake") then
        return
    end
    ---- 补上
    inst:RemoveTag("noteleport")

    local followers = inst.components.leader:GetFollowersByTag("wendy_last_keeper")
    for _, follower in ipairs(followers) do
        if follower.components.follower.leader == inst then
            inst.Transform:SetPosition(follower.Transform:GetWorldPosition())
            follower:Hide()
            break
        end
    end
    inst:AddTag("reviving")

    inst.deathclientobj = nil
    inst.deathcause = nil
    inst.deathpkname = nil
    inst.deathbypet = nil
    inst:ShowHUD(false)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end
    if inst.components.talker ~= nil then
        inst.components.talker:ShutUp()
    end
    inst.sg:AddStateTag("busy")

    inst:DoTaskInTime(0, DoActualRez)

    inst.rezsource =
        data ~= nil and (
            (data.source ~= nil and not data.source:HasTag("reviver") and data.source:GetBasicDisplayName()) or
            (data.user ~= nil and data.user:GetDisplayName())
        ) or
        STRINGS.NAMES.SHENANIGANS

    inst.remoterezsource =
        data ~= nil and
        data.source ~= nil and
        data.source.components.attunable ~= nil and
        (data.source.components.attunable:GetAttunableTag() == "remoteresurrector"
        or data.source.components.attunable:GetAttunableTag() == "gravestoneresurrector")

    -- 恢复物品栏
    inst.components.inventory:Show()
    if inst.speedupdater_task then
        inst.speedupdater_task:Cancel()
        inst.speedupdater_task = nil
    end
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "last_dash")
end

local function OnDetached(inst)
    local target = inst.entity:GetParent()
    ---- 恢复骨架
    target.skeleton_prefab = target.old_skeleton_prefab
    target:DoTaskInTime(15, function()
        respawnFromGhost(target)
    end)
    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "explode" then
        inst.AnimState:PushAnimation("fx_trebleclef", false)
        inst:ListenForEvent("animover", function()
            inst.components.debuff:Stop()
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    -- last light
    inst.Light:SetRadius(12.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetColour(111/255, 111/255, 111/255)
    inst.Light:Enable(true)

    inst.AnimState:SetBank("fx_wathgrithr_buff")
    inst.AnimState:SetBuild("fx_wathgrithr_buff")
    inst.AnimState:PlayAnimation("fx_trebleclef")
    inst.AnimState:PushAnimation("fx_trebleclef", true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)

    inst._fade = net_smallbyte(inst.GUID, "sporebomb._fade", "fadedirty")

    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetChangeFollowSymbolFn(OnChangeFollowSymbol)
    inst.isTrigger = false

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("explode", 30)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("wendy_last_food_buff", fn, assets)

