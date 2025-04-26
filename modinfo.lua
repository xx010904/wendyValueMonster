local isCh = locale == "zh" or locale == "zhr"
version = "1.0"
name = isCh and "数值怪温蒂" or "Wendy the Value Monster"
author = "XJS"
description = isCh and 
 "技能树的每个分组都加了新的效果，具体可以查看配置项。\n封面是阿比盖尔~" or 
 "The skill tree has added new effects to each group, which can be viewed in the configuration options. \nThe cover is Abigail~"
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


configuration_options =
{
    {
		-- done
        name = "languageSetting",
        label = isCh and "语言" or "Language",
        hover = isCh and "选择语言" or "Select Language",
        options =
        {
            {description = "中文", data = "chinese", hover = "中文"},
            {description = "English", data = "english", hover = "English"},
        },
        default = "default",
    },
	{
		--done
		name = "PipspookSetting",
		label = isCh and "小惊吓任务" or "Pipspook Task",
		hover = isCh and "反过来给小惊吓安排任务。"
			or "Assign tasks to Pipspook in reverse.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		--done
		name = "ElixirSetting",
		label = isCh and "灵药浓缩" or "Concentrated Elixir",
		hover = isCh and "制造不稳定的高浓度灵药。"
			or "To craft a unstable, high-potency elixir.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "SisturnSetting",
		label = isCh and "姐妹骨灰盒IV" or "Sisturn IV",
		hover = isCh and "暂时不知道。"
			or "I don't know for now.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		--done
		name = "CraftingSetting",
		label = isCh and "积累荣耀" or "Accumulated Glory",
		hover = isCh and "温蒂每次从多年生植物祭坛复活时，阿比盖尔因对温蒂的保护欲增强而变得更强。"
			or "Each time Wendy revives at the Perennial Altar, Abigail grows stronger from her protectiveness.",
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
		hover = isCh and "制作最后的晚餐，吃下这餐，暂时灵魂出窍。"
			or "Make the last supper, eat this meal, temporarily out of body.",
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
		hover = isCh and "可以钻进装饰好的墓碑躲起来，让大惊吓保护你。"
			or "Slip into a decorated Headstone and let Bigspooks shield you.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "CallingSetting",
		label = isCh and "唤魂" or "The Calling",
		hover = isCh and "召唤数个亡魂环绕地点并造成伤害。"
			or "Summons several souls to surround the area and deal damage.",
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
		hover = isCh and "满月日可以在月晷旁边采集月灵莲花，月灵莲花能变异阿比盖尔为普通或者虚影形态。"
			or "Gestalt Lotus can be gathered on full moon days near the Moon Dial. It can mutate Abigail between her normal and Gestalt forms.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
	{
		name = "ShadowSetting",
		label = isCh and "驱灵" or "Exorcism",
		hover = isCh and "暗影阿比盖尔死亡时释放体内的蝴蝶灵魂。"
			or "The Shadow Abigail releases the butterfly souls inside when she dies.",
		options =
		{
			{ description = isCh and "开启" or "Enable", data = true, hover = isCh and "开启" or "Enable" },
			{ description = isCh and "不开" or "Disable", data = false, hover = isCh and "不开" or "Disable" },
		},
		default = true,
	},
}
