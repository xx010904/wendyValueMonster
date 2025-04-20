GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄

Assets = {
	Asset("ANIM", "anim/lotus.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_speed.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_slowregen.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_shield.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_revive.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_retaliation.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_fastregen.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_cloud_attack.zip"),

	Asset("ANIM", "anim/unstable_ghostlyelixir_revive.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_revive.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_speed.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_speed.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_attack.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_attack.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_retaliation.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_retaliation.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_shield.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_shield.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_fastregen.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_fastregen.zip"),
    Asset("ANIM", "anim/unstable_ghostlyelixir_slowregen.zip"),
	Asset("ANIM", "anim/swap_unstable_ghostlyelixir_slowregen.zip"),

    Asset("IMAGE", "images/inventoryimages/lotusflower_gestalt.tex"),
	Asset("ATLAS", "images/inventoryimages/lotusflower_gestalt.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_revive.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_revive.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_speed.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_speed.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_attack.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_attack.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_retaliation.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_retaliation.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_shield.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_shield.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_fastregen.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_fastregen.xml"),
    Asset("IMAGE", "images/inventoryimages/unstable_ghostlyelixir_slowregen.tex"),
	Asset("ATLAS", "images/inventoryimages/unstable_ghostlyelixir_slowregen.xml"),
}

PrefabFiles = {
	-- 注册新的 prefab
    "smallghost_giver",
    "abigail_gestalt_buff",
    "abigail_gestalt_lotus",
    "abigail_lutos_mutate_fx",
    "moondial_lotus_fx",
    "abigail_tether",
    "abigail_tether_charge",
    "unstable_ghostlyelixirs",
    "unstable_ghostlyelixir_clouds",
    "unstable_ghostlyelixir_cloud_brusts",
    "unstable_ghostlyelixir_buffs",
    -- 其他 prefab 名称...
}

-- RegisterInventoryItemAtlas("images/inventoryimages/oar_wathgrithr_lightning_charged.xml", "oar_wathgrithr_lightning_charged.tex")
-- RegisterInventoryItemAtlas("images/inventoryimages/oar_wathgrithr_lightning.xml", "oar_wathgrithr_lightning.tex")


--Make Global
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local net_entity = GLOBAL.net_entity

--Require


GLOBAL.global("modvalueconfig")
if GLOBAL.modvalueconfig == nil then GLOBAL.modvalueconfig = {} end
GLOBAL.modvalueconfig.languageSetting = GetModConfigData("languageSetting")

-- 本地化
local lan = (_G.LanguageTranslator.defaultlang == "zh") and "zh" or "en"
if GetModConfigData("languageSetting") == "default" then
    if lan == "zh" then
        modimport("languages/chs")
    else
        modimport("languages/en")
    end
elseif GetModConfigData("LanguageSetting") == "chinese" then
    modimport("languages/chs")
elseif GetModConfigData("LanguageSetting") == "english" then
    modimport("languages/en")
end

-- 这将执行 xxx.lua 中的所有代码
if GetModConfigData("PipspookSetting") then
    modimport("scripts/pipspook_update.lua")
end
if GetModConfigData("ElixirSetting") then
    modimport("scripts/elixir_update.lua")
end
if GetModConfigData("SisturnSetting") then
    modimport("scripts/sisturn_update.lua")
end
if GetModConfigData("CraftingSetting") then
    modimport("scripts/crafting_update.lua")
end
if GetModConfigData("PartingSetting") then
    modimport("scripts/parting_update.lua")
end
if GetModConfigData("BunkerSetting") then
    modimport("scripts/bunker_update.lua")
end
if GetModConfigData("CallingSetting") then
    modimport("scripts/calling_update.lua")
end
if GetModConfigData("LunarSetting") then
    modimport("scripts/lunar_update.lua")
end
if GetModConfigData("ShadowSetting") then
    modimport("scripts/shadow_update.lua")
end