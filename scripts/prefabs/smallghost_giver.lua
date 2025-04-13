local assets ={}

local function AddChess(inst, possible_loot)
    ---- 雕像棋子
    local CHESS_LOOT =
    {
        "chesspiece_pawn_sketch",
        "chesspiece_muse_sketch",
        "chesspiece_formal_sketch",
        "trinket_15", --bishop
        "trinket_16", --bishop
        "trinket_28", --rook
        "trinket_29", --rook
        "trinket_30", --knight
        "trinket_31", --knight
    }
    local chessunlocks = TheWorld.components.chessunlocks
    if chessunlocks ~= nil then
        for i, v in ipairs(CHESS_LOOT) do
            if not chessunlocks:IsLocked(v) then
                table.insert(possible_loot, { chance = .1, item = v })
            end
        end
    end
end

local function AddSunkenChest(inst, possible_loot)
    ---- 沉底宝箱
    local pearlReturn = true -- The Cracked Pearl has been given to Hermit.
	local hermit = TheWorld.components.messagebottlemanager ~= nil and TheWorld.components.messagebottlemanager:GetHermitCrab() or nil
	if hermit == nil or not hermit.pearlgiven then
		pearlReturn = false -- The Pearl doesn't exist yet.
	end
	if TheSim:FindFirstEntityWithTag("hermitpearl") then
		pearlReturn = false -- The Pearl or Cracked Pearl exist.
	end
	local crabking = TheSim:FindFirstEntityWithTag("crabking")
	if crabking and crabking.gemcount and crabking.gemcount.pearl > 0 then
		pearlReturn = false  -- Checking if crabking has the Pearl.
	end

    if pearlReturn then
        local base = 0.1
        -- if true then
        local EXTRA_LOOT =
        {
            -- saltminer 30%
            {chance = base*3*5,   item = "cookiecuttershell"},
            {chance = base*3*3,   item = "boatpatch"},
            {chance = base*3*6.5,   item = "saltrock"},
            {chance = base*3*1,   item = "goldenpickaxe"},
            {chance = base*3*0.5,   item = "scrapbook_page"},
            {chance = base*3*0.5,   item = "bluegem"},
            {chance = base*3*0.5,   item = "redgem"},
            -- traveler 10%
            {chance = base*1,   item = "cane"}, --standard
            {chance = base*1,   item = "heatrock"},
            {chance = base*1,   item = "gnarwail_horn"},
            {chance = base*6,   item = "papyrus"},
            {chance = base*3,   item = "featherpencil"},
            {chance = base*4,   item = "spoiled_fish"},
            {chance = base*1,   item = "cookingrecipecard"},
            {chance = base*1.5,   item = "scrapbook_page"},
            {chance = base*0.25,   item = "compass"},
            {chance = base*0.75,   item = "goggleshat"},
            -- fisher 30%
            {chance = base*3*6,   item = "boatpatch"},
            {chance = base*3*7,   item = "malbatross_feather"},
            {chance = base*3*1,   item = "oceanfishingrod"},
            {chance = base*3*3.5,   item = "oceanfishingbobber_robin_winter"},
            {chance = base*3*2.5,   item = "oceanfishinglure_spoon_green"},
            {chance = base*3*1,   item = "oceanfishinglure_hermit_heavy"},
            {chance = base*3*1,   item = "cookingrecipecard"},
            {chance = base*3*0.5,   item = "scrapbook_page"},
            {chance = base*3*0.1,   item = "boat_item"},
            {chance = base*3*0.1,   item = "anchor_item"},
            {chance = base*3*0.1,   item = "mast_item"},
            {chance = base*3*0.1,   item = "steeringwheel_item"},
            {chance = base*3*0.1,   item = "fish_box_blueprint"},
            {chance = base*3*0.5,   item = "boat_ancient_item"},
            -- miner 20%
            {chance = base*2*4.5,   item = "cutstone"},
            {chance = base*2*4.5,   item = "goldnugget"},
            {chance = base*2*4.5,   item = "moonglass"},
            {chance = base*2*4.5,   item = "moonrocknugget"},
            {chance = base*2*1,   item = "goldenpickaxe"},
            {chance = base*2*0.5,   item = "scrapbook_page"},
            {chance = base*2*0.5,   item = "purplegem"},
            {chance = base*2*0.1,   item = "greengem"},
            {chance = base*2*0.2,   item = "yellowgem"},
            {chance = base*2*0.2,   item = "orangegem"},
            -- splunker 10%
            {chance = base*1.5,   item = "gears"}, --standard
            {chance = base*6,   item = "thulecite"},
            {chance = base*1,   item = "multitool_axe_pickaxe"},
            {chance = base*1,   item = "armorruins"},
            {chance = base*1,   item = "lantern"},
            {chance = base*0.5,   item = "scrapbook_page"},
            {chance = base*0.5,   item = "yellowgem"},
            {chance = base*0.5,   item = "orangegem"},
            {chance = base*0.9,   item = "purplegem"},
            {chance = base*0.1,   item = "greengem"},
            -- 惊喜种子
            {chance = base*1,   item = "ancienttree_seed"},
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
        end
    end
end

local function MakeLoot(inst)
     ---- 风滚草 基础奖励
    local possible_loot =
    {
        -- base
        {chance = 14,   item = "cutgrass"},
        {chance = 14,   item = "twigs"},
        {chance = 5,   item = "log"},
        {chance = 5,   item = "rocks"},
        {chance = 1,   item = "nitre"},
        {chance = 1,   item = "flint"},
        -- wendy_use
        {chance = 2,    item = "petals"},
        {chance = 1,    item = "petals_evil"},
        {chance = 2,    item = "moon_tree_blossom"},
        {chance = 2,    item = "butterfly"},
        {chance = 2,    item = "butterflywings"},
        {chance = 2,    item = "moonbutterfly"},
        {chance = 2,    item = "moonbutterflywings"},
        {chance = 2,    item = "spidergland"},
        {chance = 0.1,  item = "slurtle_shellpieces"},
        {chance = 0.8,  item = "graveurn"},
        {chance = 2,    item = "forgetmelots"},
        {chance = 1,    item = "reviver"},
        {chance = 1,    item = "honey"},
        {chance = 1,    item = "stinger"},
        {chance = 1,    item = "livinglog"},
        -- seed
        {chance = 1,    item = "seeds"},
        {chance = 0.8,  item = "bullkelp_root"},
        {chance = 0.8,  item = "sapling"},
        {chance = 0.8,  item = "acorn"},
        -- food
        {chance = 0.4,  item = "foliage"},
        {chance = 0.4,  item = "rottenegg"},
        {chance = 0.8,  item = "spoiled_fish_small"},
        {chance = 1.2,  item = "monstermeat"},
        {chance = 1,    item = "berries"},
        {chance = 1,    item = "carrot"},
        {chance = 1,    item = "corn"},
        {chance = 1,    item = "potato"},
        {chance = 1,    item = "pumpkin"},
        {chance = 1,    item = "rock_avocado_fruit"},
        {chance = 1,    item = "cave_banana"},
        {chance = 1,    item = "wormlight"},
        {chance = 0.6,  item = "fishmeat"},
        {chance = 0.6,  item = "batnose"},
        {chance = 0.6,  item = "barnacle"}, -- 藤壶
        {chance = 0.6,  item = "trunk_summer"},
        {chance = 0.3,  item = "trunk_winter"},
        {chance = 0.3,  item = "red_cap"},
        {chance = 0.3,  item = "green_cap"},
        {chance = 0.3,  item = "blue_mushroom"},
        {chance = 0.1,  item = "moon_cap"},
        {chance = 0.1,  item = "fig"},
        {chance = 0.01, item = "butter"},
        {chance = 0.5,  item = "flowersalad"},
        {chance = 1,    item = "meat_dried"}, -- 晾肉干
        {chance = 1,    item = "bananajuice"}, -- 香蕉奶昔
        {chance = 2,    item = "bananapop"}, -- 香蕉冻 wendy最爱
        -- tools
        {chance = 1,    item = "treegrowthsolution"}, -- Tree Jam, 2-4
        {chance = 1,    item = "shovel"}, -- Shovel, 1
        {chance = 1,    item = "goldenshovel"}, -- Regal Shovel, 1
        {chance = 1,    item = "torch"},
        {chance = 1,    item = "moonglassaxe"},
        {chance = 1,    item = "messagebottleempty"},
        {chance = 0.67, item = "blowdart_pipe"}, --吹箭
        {chance = 0.67, item = "boomerang"},
        {chance = 0.33, item = "razor"},
        {chance = 0.67, item = "sewing_kit"},
        {chance = 0.67, item = "grass_umbrella"},
        {chance = 0.67, item = "birdtrap"},
        {chance = 0.67, item = "trap"},
        {chance = 0.67, item = "trap_teeth"},
        {chance = 0.67, item = "beemine"},
        {chance = 1,    item = "bugnet"},
        {chance = 1,    item = "miniflare"}, --信号弹
        {chance = 0.33, item = "chum"}, --鱼食
        {chance = 0.33, item = "fertilizer"}, --便便桶
        {chance = 0.22, item = "rabbitkinghorn"},
        {chance = 0.67, item = "oar_driftwood"},
        {chance = 0.33, item = "wateringcan"},
        {chance = 0.33, item = "minerhat"},
        {chance = 0.33, item = "reskin_tool"},
        {chance = 0.33, item = "pig_coin"},
        {chance = 1,    item = "giftwrap"}, -- 空包
        -- cloth
        {chance = 0.67, item = "winterhat"},
        {chance = 0.67, item = "tophat"},
        {chance = 0.67, item = "catcoonhat"},
        {chance = 0.67, item = "bushhat"},
        {chance = 0.67, item = "beehat"},
        {chance = 0.67, item = "goggleshat"},
        {chance = 0.67, item = "reflectivevest"},
        {chance = 0.67, item = "raincoat"},
        {chance = 0.67, item = "armorslurper"},
        {chance = 0.67, item = "featherhat"},
        -- combat
        {chance = 0.12, item = "gunpowder"},
        {chance = 0.33, item = "waterplant_bomb"}, -- 种壳
        {chance = 0.67, item = "cookiecutterhat"}, -- 饼干头
        {chance = 0.67, item = "footballhat"}, -- 橄榄球头盔
        {chance = 0.67, item = "armorwood"}, -- 木甲
        {chance = 0.67, item = "spear"}, -- 长矛
        {chance = 1.67, item = "tentaclespike"}, -- 触手尖刺
        {chance = 0.67, item = "hambat"}, -- 火腿棒
        {chance = 0.67, item = "batbat"}, -- 蝙蝠棒
        {chance = 0.33, item = "multitool_axe_pickaxe"}, -- 多用斧镐
        {chance = 0.03, item = "panflute"}, -- 排箫
        -- blue print
        {chance = 0.1,  item = "pirate_flag_pole_blueprint"}, -- Blueprint (rare), Moon Quay Pirate Banner
        {chance = 0.1,  item = "polly_rogershat_blueprint"},
        {chance = 1,    item = "blueprint"},
        {chance = 0.04, item = "dragonflyfurnace_blueprint"},
        {chance = 0.04, item = "red_mushroomhat_blueprint"},
        {chance = 0.04, item = "green_mushroomhat_blueprint"},
        {chance = 0.04, item = "blue_mushroomhat_blueprint"},
        {chance = 0.04, item = "mushroom_light_blueprint"},
        {chance = 0.04, item = "mushroom_light2_blueprint"},
        {chance = 0.04, item = "townportal_blueprint"},
        {chance = 0.04, item = "bundlewrap_blueprint"},
        {chance = 0.04, item = "trident_blueprint"},
        ---- materials
        {chance = 0.4,  item = "nightmarefuel"},
        {chance = 0.55, item = "palmcone_scale"}, -- Palmcone Scale, 2-4
        {chance = 0.4,  item = "wagpunk_bits"},
        {chance = 0.25, item = "transistor"},
        {chance = 0.2,  item = "beardhair"},
        {chance = 0.2,  item = "walrus_tusk"},
        {chance = 1,    item = "houndstooth"},
        {chance = 1,    item = "boards"},
        {chance = 1,    item = "gears"},
        {chance = 0.5,  item = "boneshard"},
        {chance = 0.67, item = "charcoal"},
        {chance = 0.33, item = "goldnugget"},
        {chance = 1,    item = "silk"},
        {chance = 1,    item = "rope"},
        {chance = 1,    item = "cutreeds"},
        {chance = 0.33, item = "feather_crow"},
        {chance = 0.33, item = "feather_robin"},
        {chance = 0.33, item = "feather_robin_winter"},
        {chance = 0.33, item = "feather_canary"},
        {chance = 0.33, item = "slurtleslime"}, --蛞蝓龟黏液
        {chance = 0.66, item = "honeycomb"}, -- 蜜脾
        {chance = 1,    item = "beefalowool"},
        {chance = 0.67, item = "papyrus"},
        {chance = 1,    item = "cutstone"},
        {chance = 1,    item = "marble"},
        {chance = 1,    item = "healingsalve"},
        {chance = 0.4,  item = "thulecite"}, -- 铥矿
        {chance = 0.4,  item = "thulecite_pieces"}, -- 铥矿碎片
        {chance = 0.3,  item = "dreadstone"}, -- 绝望石
        {chance = 0.01, item = "moonstorm_static_item"}, -- 约束静电
        ---- important materials
        {chance = 0.07, item = "deerclops_eyeball"},
        {chance = 0.07, item = "dragon_scales"},
        {chance = 0.07, item = "hivehat"},
        {chance = 0.07, item = "shroom_skin"},
        {chance = 0.07, item = "mandrake"},
        {chance = 0.07, item = "bootleg"},
        {chance = 0.01, item = "krampus_sack"},
        ---- animals
        {chance = 2.222, item = "spider"},
        {chance = 1.111, item = "spider_warrior"},
        {chance = 2.222, item = "mole"},
        {chance = 1.111, item = "carrat"},
        {chance = 1.111, item = "canary"}, --金丝雀
        {chance = 0.333, item = "oceanfish_medium_8_inv"}, --冰鲷鱼
        {chance = 0.333, item = "oceanfish_small_8_inv"}, --炽热太阳鱼
        {chance = 1.111, item = "rabbit"},
        {chance = 1.111, item = "bee"},
        {chance = 1.111, item = "killerbee"},
        {chance = 1.111, item = "mosquito"},
        {chance = 1.111, item = "fireflies"},
        {chance = 1.111, item = "pondeel"}, --活鳗鱼
        {chance = 0.667, item = "oceanfish_small_9_inv"}, --口水鱼
        ---- toy
        {chance = 0.04, item = "trinket_1"},
        {chance = 0.04, item = "trinket_2"},
        {chance = 0.04, item = "trinket_3"},
        {chance = 0.04, item = "trinket_4"},
        {chance = 0.04, item = "trinket_5"},
        {chance = 0.04, item = "trinket_6"},
        {chance = 0.04, item = "trinket_7"},
        {chance = 0.04, item = "trinket_8"},
        {chance = 0.04, item = "trinket_9"},
        {chance = 0.04, item = "trinket_10"},
        {chance = 0.04, item = "trinket_11"},
        {chance = 0.04, item = "trinket_12"},
        {chance = 0.04, item = "trinket_13"},
        {chance = 0.04, item = "trinket_14"},
        -- {chance = 0.1, item = "trinket_15"}, --白色主教
        -- {chance = 0.1, item = "trinket_16"}, --黑色主教
        {chance = 0.04, item = "trinket_17"},
        {chance = 0.04, item = "trinket_18"},
        {chance = 0.04, item = "trinket_19"},
        {chance = 0.04, item = "trinket_20"},
        {chance = 0.04, item = "trinket_21"},
        {chance = 0.04, item = "trinket_22"},
        {chance = 0.04, item = "trinket_23"},
        {chance = 0.04, item = "trinket_24"},
        {chance = 0.04, item = "trinket_25"},
        {chance = 0.04, item = "trinket_26"},
        {chance = 0.04, item = "trinket_27"},
        -- {chance = 0.1, item = "trinket_28"}, --白色战车
        -- {chance = 0.1, item = "trinket_29"}, --黑色战车
        -- {chance = 0.1, item = "trinket_30"}, --白色骑士
        -- {chance = 0.1, item = "trinket_31"}, --黑色骑士
        ---- Gem
        {chance = 0.6,  item = "redgem"},
        {chance = 0.6,  item = "bluegem"},
        {chance = 0.4,  item = "purplegem"},
        {chance = 0.2,  item = "orangegem"},
        {chance = 0.2,  item = "yellowgem"},
        {chance = 0.1,  item = "greengem"},
        {chance = 0.01, item = "opalpreciousgem"},
        {chance = 0.6,  item = "amulet"},
        {chance = 0.6,  item = "blueamulet"},
        {chance = 0.4,  item = "firestaff"}, -- 火魔杖
        {chance = 0.4,  item = "icestaff"}, -- 冰魔杖
    }

    ---- 特殊奖励
    AddChess(inst, possible_loot)
    AddSunkenChest(inst, possible_loot)

    local totalchance = 0
    for m, n in ipairs(possible_loot) do
        totalchance = totalchance + n.chance
    end

    local loots = {}
    local next_loot = nil
    local next_chance = nil
    local num_loots = 3
    while num_loots > 0 do
        next_chance = math.random()*totalchance
        next_loot = nil
        for m, n in ipairs(possible_loot) do
            next_chance = next_chance - n.chance
            if next_chance <= 0 then
                next_loot = n.item
                break
            end
        end
        if next_loot ~= nil then
            table.insert(loots, next_loot)
            num_loots = num_loots - 1
        end
    end
    return loots
end

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("ghost_kid")
    inst.AnimState:SetBuild("ghost_kid")
    inst.AnimState:PlayAnimation("appear", false)
	-- inst.AnimState:SetMultColour(1, 1, 1, 1)
	-- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    -- inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    -- inst.AnimState:SetSortOrder(3)
    inst.AnimState:OverrideSymbol("smallghost_hair", "ghost_kid", "smallghost_hair_"..tostring(math.random(0, 3)))

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", function(inst)
		if inst.AnimState:IsCurrentAnimation("dissipate") then
		    -- print("smallghost_giver dissipate123")
            local x, y, z = inst.Transform:GetWorldPosition()
            local smallghost = SpawnPrefab("smallghost")
            smallghost.Transform:SetPosition(x, y, z)
            inst:Remove()
		end
		if inst.AnimState:IsCurrentAnimation("quest_completed") then
			inst.AnimState:PlayAnimation("dissipate", false)
			-- print("smallghost_giver gift")
            local loot_count = {} -- 创建一个表来统计物品数量

            for i = 1, 100 do
                local gift = SpawnPrefab("gift")
                local loots = MakeLoot(inst)

                -- 统计loots内容
                for _, loot in ipairs(loots) do
                    loot_count[loot] = (loot_count[loot] or 0) + 1 -- 增加物品计数
                end

                gift.components.unwrappable:WrapItems(loots)
                local x, y, z = inst.Transform:GetWorldPosition()
                gift.Transform:SetPosition(x + math.random(-2, 2), y, z + math.random(-2, 2))
            end

            -- 输出统计结果
            for item, count in pairs(loot_count) do
                print(string.format("%s: %d", item, count))
            end
            inst:Hide()
		end
		if inst.AnimState:IsCurrentAnimation("appear") then
			-- print("smallghost_giver appear")
			inst.AnimState:PlayAnimation("quest_completed", false)
		end
	end)

	return inst
end


return Prefab("smallghost_giver", shadow_fn, assets)
