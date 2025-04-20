local function EquipWeapon(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(10)
        weapon.components.weapon:SetRange(6, 10)
        weapon.components.weapon:SetProjectile("abigail_tether_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        weapon:AddComponent("equippable")
        weapon:AddTag("nosteal")

        inst.components.inventory:Equip(weapon)
    end
end

local function normalfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("tree_petal_fx")
    inst.AnimState:SetBuild("tree_petal_fx")
    inst.AnimState:PlayAnimation("chop")
    -- inst.Transform:SetScale(0.4, 0.4, 0.4)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("invincible")
    inst:AddTag("flying")

    MakeFlyingCharacterPhysics(inst, 1, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst:AddComponent("inventory")

    inst.components.combat:SetDefaultDamage(1)
    inst.components.combat:SetAttackPeriod(6)

    EquipWeapon(inst)
    return inst
end


return Prefab("abigail_tether", normalfn, {}, {})
