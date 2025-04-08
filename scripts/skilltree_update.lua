if true then
    -- 登记技能树，重载一下，不然描述不更新
    local BuildSkillsData = require("prefabs/skilltree_wendy") -- 角色的技能树文件
    local defs = require("prefabs/skilltree_defs")

    local data = BuildSkillsData(defs.FN)

    -- 技能树用到的图标
    -- table.insert(Assets, Asset("ATLAS", "images/skilltree/wilson_alchemy_reverse_1.xml"))
    -- RegisterSkilltreeIconsAtlas("images/skilltree/wilson_alchemy_reverse_1.xml", "wilson_alchemy_reverse_1.tex")

    defs.CreateSkillTreeFor("wendy", data.SKILLS)
    defs.SKILLTREE_ORDERS["wendy"] = data.ORDERS

end

