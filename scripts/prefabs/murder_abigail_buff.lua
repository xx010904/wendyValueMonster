local TICK_RATE = 1 -- 每秒触发一次
local RADIUS = 4 -- 攻击范围
local FADE_FRAMES = 5
local BUFF_DURATION = TUNING.SKILLS.WENDY.MURDER_BUFF_DURATION * 20

local function OnUpdateFade(inst)
    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

-- 添加debuff
function ApplyDebuff(inst, attack_target)
	if attack_target ~= nil then
        local buff = "abigail_vex_debuff"

        if inst:GetDebuff("super_elixir_buff") and inst:GetDebuff("super_elixir_buff").prefab == "ghostlyelixir_shadow_buff" then
            buff = "abigail_vex_shadow_debuff"
        end

        local olddebuff = attack_target:GetDebuff("abigail_vex_debuff")
        if olddebuff and olddebuff.prefab ~= buff then
            attack_target:RemoveDebuff("abigail_vex_debuff")
        end

        attack_target:AddDebuff("abigail_vex_debuff", buff, nil, nil, nil, inst)

        local debuff = attack_target:GetDebuff("abigail_vex_debuff")

        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil and debuff ~= nil then
            debuff.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", inst.GUID, "abigail_attack_fx" )
        end
	end
end

local function GetTimeBasedDamage(inst)
    local finalDamage = 15 / 1.1
    local attack_anim = "attack1"
	if TheWorld.state.isday then
		finalDamage = TUNING.ABIGAIL_DAMAGE.day / 1.1
		attack_anim = "attack1"
	elseif TheWorld.state.isdusk then
		finalDamage = TUNING.ABIGAIL_DAMAGE.dusk / 1.1
		attack_anim = "attack2"
	elseif TheWorld.state.isnight then
		finalDamage = TUNING.ABIGAIL_DAMAGE.night / 1.1
		attack_anim = "attack3"
	end
    inst.murder_ghost_attack_fx.AnimState:PlayAnimation(attack_anim .. "_pre")
    inst.murder_ghost_attack_fx.AnimState:PushAnimation(attack_anim .. "_loop")
    inst.murder_ghost_attack_fx.AnimState:PushAnimation(attack_anim .. "_pst")
    return finalDamage
end

local function DoAOEDamage(inst)
    if not inst:IsValid() then return end

    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, y, z, RADIUS, { "_combat" }, {
        "player", "FX", "INLIMBO", "ghost", "abigail", "wall", "noattack",
    })

    local damage = GetTimeBasedDamage(inst)

    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/attack_LP", "angry")
    -- inst.AnimState:SetMultColour(207/255, 92/255, 92/255, 1)

    for _, attack_target in ipairs(targets) do
        if attack_target ~= inst and attack_target.components.health and not attack_target.components.health:IsDead() then
            attack_target.components.combat:GetAttacked(inst, damage, nil, nil, nil)
            ApplyDebuff(inst, attack_target)
            -- inst.components.combat:DoAttack(target, nil, nil, nil, damage)
        end
    end
end

local function OnAttached(inst, target)
    if target and target:IsValid() then
        inst._target = target

        target.murder_ghost_attack_fx = SpawnPrefab("abigail_attack_fx")
        target:AddChild(target.murder_ghost_attack_fx)

        target.murder_ghost_attack_fx.Light:SetIntensity(.6)
        target.murder_ghost_attack_fx.Light:SetRadius(.5)
        target.murder_ghost_attack_fx.Light:SetFalloff(.6)
        target.murder_ghost_attack_fx.Light:Enable(true)
        target.murder_ghost_attack_fx.Light:SetColour(180 / 255, 195 / 255, 225 / 255)

        target._murder_ghost_damage_task = target:DoPeriodicTask(TICK_RATE, DoAOEDamage)
    end
end

local function OnDetached(inst, target)
    if target.murder_ghost_attack_fx then
        target.murder_ghost_attack_fx:Remove()
        target.murder_ghost_attack_fx = nil
    end

    if target._murder_ghost_damage_task then
        target._murder_ghost_damage_task:Cancel()
        target._murder_ghost_damage_task = nil
    end
    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "expire" then
        inst.components.debuff:Stop()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("shadow_fire_fx")
    inst.AnimState:SetBuild("shadow_fire_fx")
    inst.AnimState:PlayAnimation("anim1")
    inst.AnimState:PushAnimation("anim1", true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)

    inst._fade = net_smallbyte(inst.GUID, "sporebomb._fade", "fadedirty")

    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = true

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("expire", BUFF_DURATION)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("murder_abigail_buff", fn)
