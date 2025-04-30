local function ShouldParting(inst)
	if not TheWorld.ismastersim then
		return
	end

	local avenge = nil
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 40.0, {"player"})
	for _, ent in ipairs(ents) do
		if ent.components.skilltreeupdater and ent.components.skilltreeupdater:IsActivated("wendy_avenging_ghost") then
			avenge = true
			break
		end
	end

	return avenge
end

local function gotoparting(inst)
    if inst.sg.currentstate.name ~= "parting" and inst.sg.currentstate.name ~= "dismount" then
        inst.sg:GoToState("parting")
        inst:RemoveEventCallback("animover", gotoparting)
    end
end

local function OnEaten(inst, eater)
    if ShouldParting(eater) then
        if eater.components.rider then
            local mount = eater.components.rider:GetMount()
            if mount then
                eater.components.rider:Dismount()
                if mount.components.hauntable ~= nil and mount.components.hauntable.panicable then
                    mount.components.hauntable:Panic(20)
                end
            end
        end
        if eater.components.temperature then
            eater.components.temperature:SetTemp(TUNING.STARTING_TEMP)
        end
        if eater.components.moisture then
            eater.components.moisture:DoDelta(-TUNING.MAX_WETNESS, true)
        end

        -- kill eater, because I want to use the meter badge
        eater:ListenForEvent("animover", gotoparting)
    else
        if eater.components.talker then
            eater.components.talker:Say(GetString(eater, "ANNOUNCE_NOT_PARTING"), nil, true)
        end
    end
end

local function OnSave(inst, data)
    if inst.components.perishable then
        data.perish_percent = inst.components.perishable:GetPercent()
    end
end

local function OnLoad(inst, data)
    if data and data.perish_percent and inst.components.perishable then
        inst.components.perishable:SetPercent(data.perish_percent)
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wendy_last_food")
    inst.AnimState:SetBuild("wendy_last_food")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

    inst:AddTag("wendy_last_food")
    inst:AddTag("show_spoilage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wendy_last_food"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wendy_last_food.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = TUNING.SANITY_LARGE
    inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP
    inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_AVERAGE
    inst.components.edible:SetOnEatenFn(OnEaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(666 * 480) -- 666 days
    inst.components.perishable:SetPercent(0.0197166864)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("wendy_last_food", fn, {})