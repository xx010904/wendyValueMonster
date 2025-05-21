local isCh = locale == "zh" or locale == "zhr"
version = "1.0.1"
name = isCh and "数值怪阿比盖尔" or "The Value Monster: Abigail"
author = "XJS"
description = isCh and 
"技能树的每个分组都加了新的效果，具体可以查看配置项。\n封面是阿比盖尔~"..
"\n󰀐感谢赏玩！"..
"\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓"..
"\n󰀅完整更新日志可以在创意工坊查看"..
"\n"
or
"The skill tree has added new effects to each group, which can be viewed in the configuration options. \nThe cover is Abigail~"..
"\n󰀐Thanks to enjoy!"..
"\n\n〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓"..
"\n󰀅Full changelog available on the Workshop"..
"\n"

forumthread = ""
api_version = 10
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true
-- server_only_mod = true
client_only_mod = false
all_clients_require_mod = true


api_version_dst = 10
priority = -11

local function Subtitle(name)
	return {
		name = name,
		label = name,
		options = { {description = "", data = false}, },
		default = false,
	}
end
configuration_options =
{
    {
        name = "LanguageSetting",
        label = isCh and "语言" or "Language",
        hover = isCh and "选择语言" or "Select Language",
        options =
        {
			{description = "Default", data = "default", hover = "Default"},
            {description = "中文", data = "chinese", hover = "中文"},
            {description = "English", data = "english", hover = "English"},
        },
        default = "default",
    },
	{
		name = "PipspookSetting",
		label = isCh and "任务反派" or "Reverse Task Assignment",
		hover = isCh and "可以反过来给小惊吓安排任务，让她帮忙找寻稀有物品。"
			or "Assign tasks to Pipspook in reverse, asking her to find rare items.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "ElixirSetting",
		label = isCh and "不稳定化合物" or "Unstable Concoction",
		hover = isCh and "可以制造不稳定的高浓度灵药，对群体使用。"
			or "Craft unstable high-concentration elixirs that can be used on groups.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "SisturnSetting",
		label = isCh and "瘦肉姐妹骨灰罐" or "Fleshed Sisturn",
		hover = isCh and "可以将瘦肉投入骨灰罐，转化为阿比盖尔的肉盾值，并产出带盐骨灰与糟渣。"
			or "Feed Lean Meat into Sisturn to convert it into Abigail's Flesh Shield and yield Salted Ashes and Mockmuck.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "CraftingSetting",
		label = isCh and "多年生保护欲" or "Perennial Protective Instinct",
		hover = isCh and "温蒂每次从多年生植物祭坛复活时，阿比盖尔因对温蒂的保护欲增强而变得更强。"
			or "Wendy's resurrection from the Perennial Altar strengthens Abigail, as her protective instincts toward Wendy grow stronger.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "PartingSetting",
		label = isCh and "临别一餐" or "Parting Dinner",
		hover = isCh and "可以制作食用后灵魂出窍的临别香蕉冻，灵魂攻击可积蓄提升攻击力的鬼魂复仇之力。"
			or "Can craft a Parting Banana Pop that sends into spirit form on consumption; spirit attacks build Vengeful Spirit Power to boost damage.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		--done
		name = "BunkerSetting",
		label = isCh and "躲进墓碑" or "Headstone Bunker",
		hover = isCh and "可以钻进装饰好的墓碑躲起来，让大惊吓保护。"
			or "Slip into a decorated Headstone and let Bigspooks shield.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	-- {
	-- 	--done
	-- 	name = "CallingSetting",
	-- 	label = isCh and "灵魂隔断" or "Soul Sunder",
	-- 	hover = isCh and "阿比盖尔的作祟指令可以对温蒂使用，交换当前血量百分比。"
	-- 		or "Abigail can haunt Wendy to instantly swap their current health percentages.",
	-- 	options =
	-- 	{
	-- 		{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
	-- 		{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
	-- 	},
	-- 	default = true,
	-- },
	{
		--done
		name = "CallingSetting",
		label = isCh and "灵魂链接" or "Soul Link",
		hover = isCh and "阿比盖尔可以对温蒂作祟，链接彼此灵魂，所造成的伤害会为对方恢复生命。"
			or "Abigail can haunt Wendy, creating a soul link between them — damage dealt by one will heal the other.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		--done
		name = "LunarSetting",
		label = isCh and "月灵莲花" or "Gestalt Lotus",
		hover = isCh and "满月全天，可以用月晷将阿比盖尔之花转化为月灵莲花；月灵莲花可以切换阿比盖尔的鬼魂或虚影形态。"
			or "During a full moon, the moondial can transform Abigail's Flower into a Lunar Lotus, used to shift Abigail between her ghost and Gestalt forms.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "ShadowSetting",
		label = isCh and "谋杀" or "Murder",
		hover = isCh and "用灵药谋杀阿比盖尔，使温蒂被鬼灵的暗影笼罩，继承阿比盖尔的范围伤害与易伤增益。"
			or "Use a elixir to muder Abigail, leaving Wendy shadowed by her spirit; Wendy inherits Abigail's area damage and vulnerability buff.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	Subtitle(isCh and "其他配置" or "Other Settings"),
	{
		name = "DiscoLight",
		label = isCh and "蹦迪光效" or "Disco Light",
		hover = isCh and "钻墓碑的时候大惊吓的变化特效。" or "Bigspook transformation effects triggered when diving into a grave.",
		options =
		{
			{ description = isCh and "开" or "Enable", data = true, hover = isCh and "开启五彩斑斓的光效" or "Enables colorful, flashy bloom visuals." },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不变色" or "No color changes" },
		},
		default = false,
	},
	-- {
	-- 	name = "PersistenceProtectiveInstinct",
	-- 	label = isCh and "持久化保护欲" or "Persistent Protective Instinct",
	-- 	hover = isCh and "换人、变猴不会消除多年生保护欲。" or "Changing characters or turning into monkeys won't eliminate protective instincts.",
	-- 	options =
	-- 	{
	-- 		{ description = isCh and "开" or "Enable", data = true, hover = isCh and "持久化" or "Persistent" },
	-- 		{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不持久化" or "No Persistent" },
	-- 	},
	-- 	default = false,
	-- }
}
