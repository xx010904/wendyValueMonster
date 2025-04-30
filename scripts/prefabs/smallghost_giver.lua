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

local function AddRift(inst, possible_loot)
    if TheWorld.components.riftspawner ~= nil and TheWorld.components.riftspawner:IsLunarPortalActive() then
        local EXTRA_LOOT = {
            {chance = 3,  item = "lunarplant_husk"},
            {chance = 3,  item = "purebrilliance"},
            {chance = 3,  item = "security_pulse_cage_full"}, --充能火花柜
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
        end
    end
    if TheWorld.components.riftspawner ~= nil and TheWorld.components.riftspawner:IsShadowPortalActive() then
        local EXTRA_LOOT = {
            {chance = 3,  item = "horrorfuel"},
            {chance = 3,  item = "voidcloth"},
            {chance = 3,  item = "shadowheart_infused"}, --附身暗影心房
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
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
        local base = 0.05
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

local function AddDays(inst, possible_loot)
    if TheWorld.state.cycles > 30 then
        local EXTRA_LOOT = {
            -- wendy_use
            {chance = 1,    item = "livinglog"},
            {chance = 2,    item = "forgetmelots"},
            {chance = 3,    item = "moon_tree_blossom"},
            {chance = 0.6,  item = "slurtle_shellpieces"},
            {chance = 1.2,  item = "graveurn"},
            {chance = 1,    item = "bananajuice"}, -- 香蕉奶昔
            {chance = 3,    item = "bananapop"}, -- 香蕉冻 wendy最爱
            --seed
            {chance = 0.8,  item = "seeds_cooked"},
            {chance = 0.8,  item = "pumpkin_seeds"},
            {chance = 0.8,  item = "tomato_seeds"},
            {chance = 0.8,  item = "eggplant_seeds"},
            {chance = 0.8,  item = "spore_small"},
            {chance = 0.8,  item = "spore_medium"},
            {chance = 0.8,  item = "spore_tall"},
            {chance = 0.8,  item = "spore_moon"},
            --vege
            {chance = 0.8,  item = "pumpkin_cooked"},
            {chance = 0.8,  item = "tomato_cooked"},
            {chance = 0.8,  item = "eggplant_cooked"},
            {chance = 0.8,  item = "pumpkin"},
            {chance = 0.8,  item = "tomato"},
            {chance = 0.8,  item = "eggplant"},
            {chance = 0.8,  item = "lightbulb"},
            {chance = 0.8,  item = "firenettles"},
            {chance = 0.8,  item = "tillweed"},
            {chance = 1,    item = "rock_avocado_fruit"}, --石果
            {chance = 1,    item = "cave_banana"},
            {chance = 1,    item = "wormlight"},
            {chance = 1,    item = "kelp_cooked"},
            {chance = 1,    item = "cutlichen"}, --苔藓
            --meat
            {chance = 0.3,  item = "trunk_winter"},
            {chance = 0.8,  item = "slurper_pelt"},
            {chance = 0.8,  item = "goatmilk"},
            --Gem
            {chance = 0.6,  item = "redgem"},
            {chance = 0.6,  item = "bluegem"},
            {chance = 0.4,  item = "purplegem"},
            {chance = 0.6,  item = "amulet"},
            {chance = 0.6,  item = "blueamulet"},
            {chance = 0.4,  item = "firestaff"}, -- 火魔杖
            {chance = 0.4,  item = "icestaff"}, -- 冰魔杖
            --tools
            {chance = 0.45, item = "pitchfork"},
            {chance = 0.45, item = "goldenpitchfork"},
            {chance = 1,    item = "hammer"},
            {chance = 0.6,  item = "onemanband"},
            {chance = 1,    item = "treegrowthsolution"},
            {chance = 1,    item = "boat_bumper_shell_kit"},
            {chance = 1,    item = "boat_bumper_kelp_kit"},
            {chance = 1,    item = "waterballoon"},
            {chance = 1,    item = "soil_amender"}, --催长剂起子
            {chance = 0.33, item = "thulecitebugnet"}, --铥矿捕虫网
            --wall
            {chance = 1.2,  item = "wall_moonrock_item"},
            {chance = 1.2,  item = "wall_ruins_item"},
            --boat
            {chance = 0.8,  item = "mastupgrade_lightningrod_item"},
            {chance = 0.8,  item = "mastupgrade_lamp_item"},
            {chance = 0.8,  item = "boat_item"},
            {chance = 0.8,  item = "boat_grass_item"},
            {chance = 0.8,  item = "boatpatch"},
            {chance = 0.8,  item = "boat_grass_item"},
            {chance = 0.8,  item = "steeringwheel_item"},
            {chance = 0.8,  item = "boat_rotator_kit"},
            {chance = 0.8,  item = "mast_item"},
            {chance = 0.8,  item = "boat_magnet_beacon"},
            {chance = 0.8,  item = "boat_magnet_kit"},
            --heal
            {chance = 1,    item = "healingsalve_acid"},
            {chance = 0.33, item = "slurtleslime"}, --蛞蝓龟黏液
            {chance = 0.67, item = "glommerfuel"}, --格罗姆黏液
            --materials
            {chance = 0.55, item = "palmcone_scale"}, -- Palmcone Scale, 2-4
            {chance = 0.33, item = "feather_robin_winter"},
            {chance = 0.33, item = "feather_canary"},
            {chance = 0.4,  item = "wagpunk_bits"},
            {chance = 0.88,   item = "moonrocknugget"},
            {chance = 0.88,   item = "lightninggoathorn"},
            {chance = 0.88,  item = "refined_dust"}, --尘土块
            --animals
            {chance = 1.4,  item = "robin_winter"},
            {chance = 1.4,  item = "robin"},
            {chance = 1.4,  item = "lightflier"},
            --cloth
            {chance = 0.67, item = "armorslurper"}, --饥饿腰带
            -- important
            {chance = 0.77, item = "deer_antler"}, --鹿角
            {chance = 0.85, item = "honeycomb"}, -- 蜜脾
            {chance = 0.33, item = "beeswax"}, -- 蜂蜡
            {chance = 0.33, item = "royal_jelly"}, -- 蜂王浆
            {chance = 0.15, item = "hivehat"},
            {chance = 0.15, item = "jellybean"},
            {chance = 0.15, item = "deerclops_eyeball"},
            {chance = 0.55, item = "fossil_piece"}, --化石碎片
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
        end
    end
    if TheWorld.state.cycles > 60 then
        local EXTRA_LOOT = {
            -- seed
            {chance = 0.8,  item = "sapling_moon"}, --月亮树苗
            {chance = 0.8,  item = "rock_avocado_bush"},
            {chance = 0.4,  item = "monkeytail"},
            {chance = 0.4,  item = "bananabush"},
            {chance = 0.8,  item = "garlic_seeds"},
            {chance = 0.8,  item = "onion_seeds"},
            {chance = 0.8,  item = "pepper_seeds"},
            -- vege
            {chance = 0.8,  item = "garlic_cooked"},
            {chance = 0.8,  item = "onion_cooked"},
            {chance = 0.8,  item = "pepper_cooked"},
            {chance = 0.8,  item = "garlic"},
            {chance = 0.8,  item = "onion"},
            {chance = 0.8,  item = "pepper"}, --辣椒
            {chance = 0.2,  item = "moon_cap"},
            {chance = 0.7,  item = "powcake"}, --芝士蛋糕
            {chance = 0.2,  item = "fig"}, --无花果
            --tools
            {chance = 0.5,  item = "brush"},
            {chance = 1.5,  item = "archive_resonator_item"}, --星象探测仪
            {chance = 0.5,  item = "pumpkin_lantern"},
            {chance = 0.5,  item = "bathbomb"},
            {chance = 0.5,  item = "megaflare"},
            {chance = 1,    item = "moonglassaxe"}, --玻璃斧
            {chance = 0.33, item = "carpentry_blade_moonglass"}, --月光玻璃锯片
            --wall
            {chance = 1.2,  item = "wall_dreadstone_item"},
            {chance = 1.2,  item = "wall_scrap_item"},
            --combat
            {chance = 0.6,  item = "ruins_bat"},
            {chance = 0.6,  item = "ruinshat"},
            {chance = 0.6,  item = "armorruins"},
            {chance = 0.6,  item = "nightsword"},
            {chance = 0.6,  item = "armor_sanity"},
            {chance = 0.6,  item = "slurtlehat"},
            {chance = 0.67, item = "multitool_axe_pickaxe"}, -- 多用斧镐
            {chance = 0.6,  item = "thulecite"}, -- 铥矿
            {chance = 0.6,  item = "thulecite_pieces"}, -- 铥矿碎片
            {chance = 0.6,  item = "glasscutter"}, -- 玻璃刀
            --cloth
            {chance = 1.2,  item = "molehat"},
            {chance = 1.2,  item = "deserthat"},
            --gem
            {chance = 0.05, item = "opalpreciousgem"},
            {chance = 0.2,  item = "yellowgem"},
            {chance = 0.2,  item = "orangegem"},
            {chance = 0.2,  item = "greengem"},
            {chance = 0.4,  item = "telestaff"},
            {chance = 0.4,  item = "yellowstaff"},
            {chance = 0.4,  item = "orangestaff"},
            {chance = 0.4,  item = "greenstaff"},
            {chance = 0.4,  item = "purpleamulet"},
            {chance = 0.4,  item = "yellowamulet"},
            {chance = 0.4,  item = "orangeamulet"},
            {chance = 0.4,  item = "greenamulet"},
            --important
            {chance = 0.15, item = "dragon_scales"},
            {chance = 0.05, item = "dragonflyfurnace_blueprint"},
            {chance = 0.15, item = "spidereggsack"},
            {chance = 0.2,  item = "armordragonfly"},
            {chance = 0.05, item = "bundlewrap_blueprint"},
            {chance = 0.15, item = "mandrake"},
            {chance = 0.15, item = "mast_malbatross_item"},
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
        end
    end
    if TheWorld.state.cycles > 90 then
        local EXTRA_LOOT = {
            -- seeds
            {chance = 0.8,  item = "durian_seeds"}, --榴莲
            {chance = 0.8,  item = "asparagus_seeds"}, --芦笋
            {chance = 0.8,  item = "pomegranate_seeds"}, --石榴
            {chance = 0.8,  item = "durian_cooked"}, -- 榴莲熟
            {chance = 0.8,  item = "asparagus_cooked"}, -- 芦笋熟
            {chance = 0.8,  item = "pomegranate_cooked"}, -- 石榴熟
            {chance = 0.4,  item = "rock_avocado_fruit_sprout"},
            {chance = 0.4,  item = "bullkelp_beachedroot"},
            -- vege
            {chance = 0.8,  item = "durian"},
            {chance = 0.8,  item = "asparagus"},
            {chance = 0.8,  item = "pomegranate"},
            --animals
            {chance = 1.111, item = "canary"}, --金丝雀
            {chance = 0.333, item = "oceanfish_medium_8_inv"}, --冰鲷鱼
            {chance = 0.333, item = "oceanfish_small_8_inv"}, --炽热太阳鱼
            {chance = 0.667, item = "oceanfish_small_9_inv"}, --口水鱼
            --important
            {chance = 0.15, item = "bootleg"},
            {chance = 0.15, item = "staff_tornado"},
            {chance = 0.01, item = "krampus_sack"},
            {chance = 0.15, item = "featherfan"},
            {chance = 0.15, item = "eyeturret_item"},
            {chance = 0.15, item = "shroom_skin"},
            {chance = 0.05, item = "sleepbomb"},
            {chance = 0.04, item = "mushroom_light_blueprint"},
            {chance = 0.04, item = "mushroom_light2_blueprint"},
            {chance = 0.04, item = "townportal_blueprint"},
            {chance = 0.04, item = "trident_blueprint"},
            {chance = 0.04, item = "trident"},
            {chance = 0.24, item = "shadowheart"}, --暗影心房
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
        end
    end
    if TheWorld.state.cycles > 120 then
        local EXTRA_LOOT = {
            -- seeds
            {chance = 0.8,  item = "dragonfruit_seeds"},
            {chance = 0.8,  item = "watermelon_seeds"},
            {chance = 0.1,  item = "ancienttree_seed"},
            --vege
            {chance = 0.8,  item = "dragonfruit_cooked"},
            {chance = 0.8,  item = "watermelon_cooked"},
            {chance = 0.8,  item = "dragonfruit"},
            {chance = 0.8,  item = "watermelon"},
            {chance = 1.1,  item = "cactus_flower"},
            {chance = 1.1,  item = "cactus_meat"},
            {chance = 1.3,  item = "ancientfruit_nightvision"}, --夜莓
            {chance = 1.1,  item = "succulent_picked"},
            {chance = 1.1,  item = "mandrakesoup"},
            --meat
            {chance = 0.6,  item = "trunk_summer"},
            {chance = 0.5,  item = "flowersalad"},
            {chance = 0.5,  item = "plantmeat"},
            {chance = 0.5,  item = "plantmeat_cooked"},
            --gem
            {chance = 1.5,  item = "moonrockidol"},
            {chance = 1.5,  item = "ancientfruit_gem"}, --晶洞果
            --tools
            {chance = 0.5,  item = "oceanfishinglure_spoon_red"},
            {chance = 0.5,  item = "oceanfishinglure_spoon_green"},
            {chance = 0.5,  item = "oceanfishinglure_spinner_red"},
            {chance = 0.5,  item = "oceanfishinglure_spinner_green"},
            {chance = 0.5,  item = "oceanfishinglure_hermit_rain"},
            {chance = 0.5,  item = "oceanfishinglure_hermit_snow"},
            {chance = 0.5,  item = "oceanfishinglure_hermit_drowsy"},
            {chance = 0.5,  item = "oceanfishinglure_hermit_heavy"},
            {chance = 0.5,  item = "supertacklecontainer"},
            {chance = 0.5,  item = "oceanfishingbobber_ball"},
            {chance = 0.5,  item = "oceanfishingbobber_oval"},
            {chance = 0.5,  item = "oceanfishingbobber_crow"},
            {chance = 0.5,  item = "oceanfishingbobber_robin"},
            {chance = 0.5,  item = "oceanfishingbobber_robin_winter"},
            {chance = 0.5,  item = "oceanfishingbobber_canary"},
            {chance = 0.5,  item = "oceanfishingbobber_goose"},
            {chance = 0.5,  item = "oceanfishingbobber_malbatross"},
            {chance = 0.5,  item = "chum"},
            --combat
            {chance = 1.88, item = "gunpowder"},
            --cloth
            {chance = 1.25, item = "antlionhat"}, --刮地皮头盔
            -- important
            {chance = 0.6,  item = "dreadstone"}, -- 绝望石
            {chance = 0.1,  item = "moonstorm_static_item"}, -- 约束静电
            {chance = 1.2,  item = "moonglass_charged"}, -- 注能月亮碎片
            {chance = 1.2,  item = "moonstorm_spark"}, -- 月熠
            {chance = 0.5,  item = "moonstorm_goggleshat"}, -- 星象护目镜
            {chance = 0.08, item = "chestupgrade_stacksize"}, --弹性空间制造器
            {chance = 0.08, item = "icepack"},
            {chance = 0.05, item = "red_mushroomhat_blueprint"},
            {chance = 0.05, item = "green_mushroomhat_blueprint"},
            {chance = 0.05, item = "blue_mushroomhat_blueprint"},
            {chance = 0.09, item = "alterguardianhatshard"},
            {chance = 1.25, item = "fireflies"},
        }
        for _, loot in ipairs(EXTRA_LOOT) do
            table.insert(possible_loot, loot)
        end
    end
end

local function MakeLoot(inst)
     ---- 基础奖励
    local possible_loot =
    {
        -- base
        {chance = 11,   item = "cutgrass"},
        {chance = 11,   item = "twigs"},
        {chance = 7,   item = "log"},
        {chance = 7,   item = "rocks"},
        {chance = 2,   item = "nitre"},
        {chance = 2,   item = "flint"},
        -- wendy_use
        {chance = 3,    item = "petals"},
        {chance = 1,    item = "petals_evil"},
        {chance = 2,    item = "butterfly"},
        {chance = 2,    item = "butterflywings"},
        {chance = 2,    item = "moonbutterfly"},
        {chance = 2,    item = "moonbutterflywings"},
        {chance = 2,    item = "spidergland"},
        {chance = 2,    item = "ice"},
        {chance = 1,    item = "bluemooneye"},
        {chance = 1,    item = "reviver"},
        {chance = 1,    item = "honey"},
        {chance = 1,    item = "stinger"},
        {chance = 1,    item = "ash"},
        {chance = 1,    item = "ghostflowerhat"},
        -- seed
        {chance = 1,    item = "seeds"},
        {chance = 0.4,  item = "bullkelp_beachedroot"},
        {chance = 0.8,  item = "dug_sapling"},
        {chance = 0.8,  item = "dug_grass"},
        {chance = 0.8,  item = "acorn"}, --桦栗果
        {chance = 0.8,  item = "pinecone"},
        {chance = 0.8,  item = "dug_berrybush"},
        {chance = 0.8,  item = "dug_marsh_bush"},
        {chance = 0.4,  item = "carrot_seeds"},
        {chance = 0.4,  item = "corn_seeds"},
        {chance = 0.4,  item = "potato_seeds"},
        {chance = 0.4,  item = "marblebean"},
        -- vege
        {chance = 0.4,  item = "foliage"}, --蕨类
        {chance = 1,    item = "berries"},
        {chance = 1,    item = "carrot"},
        {chance = 1,    item = "carrot_cooked"},
        {chance = 1,    item = "corn"},
        {chance = 1,    item = "corn_cooked"},
        {chance = 1,    item = "potato"},
        {chance = 1,    item = "potato_cooked"},
        {chance = 0.3,  item = "red_cap"},
        {chance = 0.3,  item = "green_cap"},
        {chance = 0.3,  item = "blue_cap"},
        {chance = 0.6,  item = "shroombait"}, -- 酿夜帽
        -- meat
        {chance = 0.4,  item = "rottenegg"},
        {chance = 0.8,  item = "spoiled_fish"},
        {chance = 0.8,  item = "spoiled_fish_small"},
        {chance = 0.6,  item = "fishmeat"},
        {chance = 0.6,  item = "batnose"},
        {chance = 0.6,  item = "barnacle"}, -- 藤壶
        {chance = 0.15, item = "butter"},
        {chance = 0.5,  item = "batwing"},
        {chance = 0.5,  item = "bird_egg"},
        {chance = 0.6,  item = "meat_dried"}, -- 晾肉干
        {chance = 0.6,  item = "smallmeat_dried"},
        {chance = 1.2,  item = "monstermeat_dried"},
        {chance = 1.2,  item = "bonesoup"}, --骨头汤
        {chance = 0.6,  item = "drumstick"}, --鸟腿
        -- tools
        {chance = 1,    item = "shovel"},
        {chance = 1,    item = "goldenshovel"},
        {chance = 1,    item = "torch"},
        {chance = 1,    item = "hammer"},
        {chance = 1,    item = "heatrock"},
        {chance = 1,    item = "messagebottleempty"},
        {chance = 0.67, item = "featherpencil"},
        {chance = 0.67, item = "blowdart_pipe"}, --吹箭
        {chance = 0.67, item = "blowdart_fire"}, --火焰吹箭
        {chance = 0.67, item = "blowdart_sleep"}, --催眠吹箭
        {chance = 0.67, item = "blowdart_yellow"}, --闪电吹箭
        {chance = 0.67, item = "boomerang"},
        {chance = 0.33, item = "razor"},
        {chance = 0.67, item = "sewing_kit"},
        {chance = 0.67, item = "grass_umbrella"},
        {chance = 0.67, item = "birdtrap"},
        {chance = 0.67, item = "trap"},
        {chance = 0.67, item = "trap_teeth"},
        {chance = 0.67, item = "beemine"},
        {chance = 1,    item = "bugnet"}, --捕虫网
        {chance = 1,    item = "miniflare"}, --信号弹
        {chance = 0.33, item = "fertilizer"}, --便便桶
        {chance = 0.22, item = "rabbitkinghorn"},
        {chance = 0.67, item = "oar_driftwood"},
        {chance = 0.67, item = "oar"},
        {chance = 0.33, item = "wateringcan"},
        {chance = 0.33, item = "minerhat"},
        {chance = 0.33, item = "reskin_tool"},
        {chance = 0.33, item = "pig_coin"},
        {chance = 1,    item = "giftwrap"}, -- 空包
        {chance = 0.67, item = "record"}, -- 唱片
        {chance = 0.67, item = "phonograph"}, -- 留声机
        --wall
        {chance = 1.2,  item = "wall_hay_item"},
        {chance = 1.2,  item = "wall_wood_item"},
        {chance = 1.2,  item = "wall_stone_item"},
        {chance = 1.2,  item = "fence_item"},
        {chance = 1.2,  item = "minisign_item"},
        {chance = 0.3,  item = "fence_gate_item"},
        --turf
        {chance = 1.5,  item = "turf_carpetfloor"},
        {chance = 1.5,  item = "turf_carpetfloor2"},
        {chance = 1.5,  item = "turf_woodfloor"},
        {chance = 1.5,  item = "turf_checkerfloor"},
        {chance = 1.5,  item = "turf_road"},
        --heal
        {chance = 0.33, item = "lifeinjector"},
        {chance = 1,    item = "healingsalve"},
        {chance = 1,    item = "tillweedsalve"},
        {chance = 1,    item = "bandage"},
        {chance = 1,    item = "bedroll_straw"},
        {chance = 1,    item = "bedroll_furry"},
        -- cloth
        {chance = 0.67, item = "winterhat"},
        {chance = 0.67, item = "tophat"},
        {chance = 0.67, item = "catcoonhat"},
        {chance = 0.67, item = "bushhat"},
        {chance = 0.67, item = "beehat"},
        {chance = 0.67, item = "goggleshat"},
        {chance = 0.67, item = "reflectivevest"},
        {chance = 0.67, item = "raincoat"},
        {chance = 0.67, item = "featherhat"},
        {chance = 0.67, item = "beefalohat"},
        {chance = 0.67, item = "rabbithat"},
        {chance = 0.12, item = "plantregistryhat"}, --耕作先驱帽
        {chance = 0.12, item = "minerhat"}, --矿工帽
        -- combat
        {chance = 0.33, item = "waterplant_bomb"}, -- 种壳
        {chance = 0.67, item = "cookiecutterhat"}, -- 饼干头
        {chance = 0.67, item = "footballhat"}, -- 橄榄球头盔
        {chance = 0.67, item = "armorwood"}, -- 木甲
        {chance = 0.33, item = "armormarble"}, -- 大理石甲
        {chance = 0.67, item = "spear"}, -- 长矛
        {chance = 1.67, item = "tentaclespike"}, -- 触手尖刺
        {chance = 0.67, item = "hambat"}, -- 火腿棒
        {chance = 0.67, item = "nightstick"}, -- 晨星锤
        {chance = 0.67, item = "batbat"}, -- 蝙蝠棒
        {chance = 0.03, item = "panflute"}, -- 排箫
        -- blue print
        {chance = 0.1,  item = "pirate_flag_pole_blueprint"}, -- Blueprint (rare), Moon Quay Pirate Banner
        {chance = 0.1,  item = "polly_rogershat_blueprint"},
        {chance = 1,    item = "blueprint"},
        ---- materials
        {chance = 0.4,  item = "nightmarefuel"},
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
        {chance = 1,    item = "beefalowool"},
        {chance = 0.67, item = "papyrus"},
        {chance = 0.67, item = "tentaclespots"},
        {chance = 1,    item = "marble"},
        {chance = 1,    item = "guano"},
        {chance = 1,    item = "poop"},
        {chance = 1,    item = "manrabbit_tail"},
        {chance = 1,    item = "pigskin"},
        ---- animals
        {chance = 2.222, item = "spider"},
        {chance = 1.111, item = "spider_warrior"},
        {chance = 2.222, item = "mole"},
        {chance = 1.111, item = "carrat"},
        {chance = 1.111, item = "rabbit"},
        {chance = 1.111, item = "bee"},
        {chance = 1.111, item = "killerbee"},
        {chance = 1.111, item = "mosquito"},
        {chance = 1.111, item = "fireflies"},
        {chance = 1.111, item = "crow"},
        {chance = 1.111, item = "puffin"},
        {chance = 1.111, item = "wobster_sheller_land"},
        {chance = 1.111, item = "wobster_moonglass_land"},
        {chance = 1,    item = "bat"}, --洞穴地面都有
        {chance = 1.111, item = "pondeel"}, --活鳗鱼
        ---- toy
        {chance = 0.22, item = "trinket_1"},
        {chance = 0.22, item = "trinket_2"},
        {chance = 0.22, item = "trinket_3"},
        {chance = 0.22, item = "trinket_4"},
        {chance = 0.22, item = "trinket_5"},
        {chance = 0.22, item = "trinket_6"},
        {chance = 0.22, item = "trinket_7"},
        {chance = 0.22, item = "trinket_8"},
        {chance = 0.22, item = "trinket_9"},
        {chance = 0.22, item = "trinket_10"},
        {chance = 0.22, item = "trinket_11"},
        {chance = 0.22, item = "trinket_12"},
        {chance = 0.22, item = "trinket_13"},
        {chance = 0.22, item = "trinket_14"},
        -- {chance = 0.1, item = "trinket_15"}, --白色主教
        -- {chance = 0.1, item = "trinket_16"}, --黑色主教
        {chance = 0.22, item = "trinket_17"},
        {chance = 0.22, item = "trinket_18"},
        {chance = 0.22, item = "trinket_19"},
        {chance = 0.22, item = "trinket_20"},
        {chance = 0.22, item = "trinket_21"},
        {chance = 0.22, item = "trinket_22"},
        {chance = 0.22, item = "trinket_23"},
        {chance = 0.22, item = "trinket_24"},
        {chance = 0.22, item = "trinket_25"},
        {chance = 0.22, item = "trinket_26"},
        {chance = 0.22, item = "trinket_27"},
        -- {chance = 0.1, item = "trinket_28"}, --白色战车
        -- {chance = 0.1, item = "trinket_29"}, --黑色战车
        -- {chance = 0.1, item = "trinket_30"}, --白色骑士
        -- {chance = 0.1, item = "trinket_31"}, --黑色骑士
    }

    ---- 特殊奖励
    AddChess(inst, possible_loot)
    AddSunkenChest(inst, possible_loot)

    ---- 天数奖励
    AddDays(inst, possible_loot)

    ---- 裂隙奖励
    AddRift(inst, possible_loot)

    local totalchance = 0
    for m, n in ipairs(possible_loot) do
        totalchance = totalchance + n.chance
    end

    local loots = {}
    local next_loot = nil
    local next_chance = nil
    local num_loots = math.random(1, 4)
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

    inst.AnimState:SetHaunted(true)
    -- Lost toys are permanently haunted.
    inst:AddTag("haunted")

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

            local gift = SpawnPrefab("gift")
            local loots = MakeLoot(inst)
            gift.AnimState:SetHaunted(true)
            gift:AddTag("haunted")

            gift.components.unwrappable:WrapItems(loots)
            gift.Transform:SetPosition(inst.Transform:GetWorldPosition())
            SpawnPrefab("carnival_confetti_fx").Transform:SetPosition(gift.Transform:GetWorldPosition())

            gift:DoTaskInTime(5, function()
                if gift:IsValid() then
                    gift.AnimState:SetHaunted(false)
                    gift:RemoveTag("haunted")
                end
            end)

            inst:Hide()
		end
		if inst.AnimState:IsCurrentAnimation("appear") then
			-- print("smallghost_giver appear")
			inst.AnimState:PlayAnimation("quest_completed", false)
            if inst._hotcold_fx == nil then
                inst._hotcold_fx = SpawnPrefab("hotcold_fx")
                inst._hotcold_fx.entity:SetParent(inst.entity)
                inst._hotcold_fx.entity:AddFollower():FollowSymbol(inst.GUID, "smallghost_hair", 0, 0.2, 0)
            end
		end
	end)

	return inst
end


return Prefab("smallghost_giver", shadow_fn, assets)
