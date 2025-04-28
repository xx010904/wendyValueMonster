-- 定义所有药剂，key是prefab
local elixir_suffix_map = {
    ghostlyelixir_revive = "revive",
    ghostlyelixir_slowregen = "slowregen",
    ghostlyelixir_fastregen = "fastregen",
    ghostlyelixir_shield = "shield",
    ghostlyelixir_attack = "attack",
    ghostlyelixir_speed = "speed",
    ghostlyelixir_retaliation = "retaliation"
}

---- 添加配方
AddRecipe2("unstable_ghostlyelixir_slowregen", { Ingredient("ghostlyelixir_slowregen", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_slowregen", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_slowregen.xml", image = "unstable_ghostlyelixir_slowregen.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_slowregen", numtogive = 1, })
AddRecipe2("unstable_ghostlyelixir_fastregen", { Ingredient("ghostlyelixir_fastregen", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_fastregen", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_fastregen.xml", image = "unstable_ghostlyelixir_fastregen.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_fastregen", numtogive = 1, })
AddRecipe2("unstable_ghostlyelixir_shield", { Ingredient("ghostlyelixir_shield", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_shield", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_shield.xml", image = "unstable_ghostlyelixir_shield.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_shield", numtogive = 1, })
AddRecipe2("unstable_ghostlyelixir_retaliation", { Ingredient("ghostlyelixir_retaliation", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_retaliation", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_retaliation.xml", image = "unstable_ghostlyelixir_retaliation.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_retaliation", numtogive = 1, })
AddRecipe2("unstable_ghostlyelixir_attack", { Ingredient("ghostlyelixir_attack", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_attack", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_attack.xml", image = "unstable_ghostlyelixir_attack.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_attack", numtogive = 1, })
AddRecipe2("unstable_ghostlyelixir_speed", { Ingredient("ghostlyelixir_speed", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_speed", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_speed.xml", image = "unstable_ghostlyelixir_speed.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_speed", numtogive = 1, })
AddRecipe2("unstable_ghostlyelixir_revive", { Ingredient("ghostlyelixir_revive", 2) }, TECH.NONE, { product = "unstable_ghostlyelixir_revive", actionstr="BREW_UNSTABLE", atlas = "images/inventoryimages/unstable_ghostlyelixir_revive.xml", image = "unstable_ghostlyelixir_revive.tex", builder_skill= "wendy_potion_yield", description = "unstable_ghostlyelixir_revive", numtogive = 1, })
AddRecipeToFilter("unstable_ghostlyelixir_slowregen", "CHARACTER")
AddRecipeToFilter("unstable_ghostlyelixir_fastregen", "CHARACTER")
AddRecipeToFilter("unstable_ghostlyelixir_shield", "CHARACTER")
AddRecipeToFilter("unstable_ghostlyelixir_retaliation", "CHARACTER")
AddRecipeToFilter("unstable_ghostlyelixir_attack", "CHARACTER")
AddRecipeToFilter("unstable_ghostlyelixir_speed", "CHARACTER")
AddRecipeToFilter("unstable_ghostlyelixir_revive", "CHARACTER")

---- 给所有原版药剂加上组件
for elixir, _ in pairs(elixir_suffix_map) do
    AddPrefabPostInit(elixir, function(inst)
        inst:AddComponent("unstableghostlyelixirbrewer")
    end)
end

---- 批量调制不稳定的化合物 动作
-- 定义
local BREW_UNSTABLE = Action({priority=1, rmb=true, distance=1, mount_valid=true })
BREW_UNSTABLE.id = "BREW_UNSTABLE"
BREW_UNSTABLE.str = STRINGS.ACTIONS.BREW_UNSTABLE
BREW_UNSTABLE.fn = function(act)
    local function giveUnstableElixirs(doer, prefab_suffix, count)
        for i = 1, count do
            local unstable_elixir = SpawnPrefab("unstable_ghostlyelixir_" .. prefab_suffix)
            if unstable_elixir then
                doer.components.inventory:GiveItem(unstable_elixir)
                -- 减少原材料数量
                if act.invobject.components.stackable then
                    act.invobject.components.stackable:Get():Remove()
                else
                    act.invobject:Remove()
                end

                if act.target.components.stackable then
                    act.target.components.stackable:Get():Remove()
                else
                    act.target:Remove()
                end
            end
        end
    end

    if act.doer ~= nil and
       act.doer.components.skilltreeupdater and
       act.doer.components.skilltreeupdater:IsActivated("wendy_potion_yield") and
       act.invobject ~= nil and
       act.target ~= nil
    then
        local elixir_suffix = elixir_suffix_map[act.invobject.prefab]
        if elixir_suffix and act.target.prefab == act.invobject.prefab then
            local inv_count = act.invobject.components.stackable and act.invobject.components.stackable.stacksize or 1
            local target_count = act.target.components.stackable and act.target.components.stackable.stacksize or 1
            local max_count = math.min(inv_count, target_count)

            if max_count > 0 then
                giveUnstableElixirs(act.doer, elixir_suffix, max_count)
                return true
            end
        end
    end
    return false
end
AddAction(BREW_UNSTABLE)

-- 定义动作选择器
--args: inst, doer, target, actions, right
AddComponentAction("USEITEM", "unstableghostlyelixirbrewer", function(inst, doer, target, actions, right)
    if inst and target and doer and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_potion_yield") then
        local elixir_suffix = elixir_suffix_map[target.prefab]
        if elixir_suffix and inst.prefab == target.prefab then
            table.insert(actions, ACTIONS.BREW_UNSTABLE)
        end
    end
end)

-- Stategraph
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.BREW_UNSTABLE, function(inst, action) return "dolongaction" end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.BREW_UNSTABLE, function(inst, action) return "dolongaction" end))