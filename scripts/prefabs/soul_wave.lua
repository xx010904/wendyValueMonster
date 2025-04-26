local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("shadow_thrall_projectile_fx")
    inst.AnimState:SetBuild("shadow_thrall_projectile_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    -- inst.AnimState:SetMultColour(0, 0, 0, 0.5)
    local scale = 1.5
    inst.Transform:SetScale(scale, scale, scale)
    inst.Transform:SetEightFaced()

    local phys = inst.entity:AddPhysics()
    phys:SetSphere(1)
    phys:SetCollides(false)

    inst:AddTag("scarytoprey")
    inst:AddTag("wave")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- 定义标签
    local AREAATTACK_MUST_TAGS = { "_combat" }
    local AREA_EXCLUDE_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO", "wall", "notarget", "player", "companion", "invisible", "noattack", "hiding", "abigail", "abigail_tether", "shadowcreature"}
    inst.time = 0
    inst.damageTick = 0.133
    -- 定时造成伤害的函数
    local function DealDamage()
        local x, y, z = inst.Transform:GetWorldPosition()
        local radius = 5 -- 伤害范围

        SpawnPrefab("sanity_lower").Transform:SetPosition(x,y,z)
        SpawnPrefab("deerclops_laserscorch").Transform:SetPosition(x,y,z)
        local targets = TheSim:FindEntities(x, y, z, radius, AREAATTACK_MUST_TAGS, AREA_EXCLUDE_TAGS) -- 查找符合条件的敌人
        for _, target in ipairs(targets) do
            if target.components.health then
                target.components.health:DoDelta(-20)
            end
        end
        if inst.time < 1.8 / inst.damageTick then
            inst.time = inst.time + 1
            inst.SoundEmitter:PlaySound("turnoftides/common/together/water/wave/LP", "wave")
            inst.SoundEmitter:SetParameter("wave", "size", 0.5)
        else
            if inst.damage_task then
                inst.damage_task:Cancel()
                inst.damage_task = nil
            end
            inst.AnimState:PlayAnimation("projectile_impact")
            inst:ListenForEvent("animover", inst.Remove)
        end
    end

    -- 每damageTick秒执行一次伤害函数
    inst.damage_task = inst:DoPeriodicTask(inst.damageTick, DealDamage)
    return inst
end


return Prefab("soul_wave", fn, {}, {} )
