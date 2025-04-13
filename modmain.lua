GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄

Assets = {
	-- Asset("ANIM", "anim/ui_beard_3x1.zip"),

    -- Asset("IMAGE", "images/inventoryimages/boat_shield_item.tex"),
	-- Asset("ATLAS", "images/inventoryimages/boat_shield_item.xml"),

}

PrefabFiles = {
	-- 注册新的 prefab
    "smallghost_giver",
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
if GetModConfigData("GhostflowerSetting") then
    modimport("scripts/ghostflower_update.lua")
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