---- 添加制作配方
AddRecipe2("wendy_last_food",
{
    Ingredient("bananapop", 1),
    Ingredient("nightmarefuel", 1),
    Ingredient("ghostflower", 1)
},
TECH.NONE,
{
    product = "wendy_last_food", -- 唯一id
    actionstr = "INFUSE", -- 动作id
    atlas = "images/inventoryimages/wendy_last_food.xml",
    image = "wendy_last_food.tex",
    builder_tag = "ghostlyfriend",
    builder_skill= "wendy_avenging_ghost",
    description = "wendy_last_food", -- 描述的id，而非本身
    numtogive = 1,
}
)
AddRecipeToFilter("wendy_last_food", "CHARACTER")

AddStategraphState('wilson',
    State{
        name = "parting",
        tags = { "busy", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            SpawnPrefab("attune_out_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            SpawnPrefab("abigailsummonfx").Transform:SetPosition(inst.Transform:GetWorldPosition())

            local x, y, z = inst.Transform:GetWorldPosition()
            ---- 新增尸体保持原位拿东西
            local keeper = SpawnPrefab("wendy_last_keeper")
            -- local name = inst.prefab
            -- if name == "wanda" then
            --     print("WandaSetBuild")
            --     inst.AnimState:SetBuild(name.."_none")
            -- else
            --     inst.AnimState:SetBuild("wilson")
            -- end
            -- keeper.AnimState:PlayAnimation("death")
            -- keeper.AnimState:PushAnimation("death_idle", true)
            keeper.Transform:SetPosition(x, y, z)
            keeper.components.follower:SetLeader(inst)
            keeper.components.skinner:CopySkinsFromPlayer(inst)
            inst.components.inventory:TransferInventory(keeper)

            ---- 从commonDeath提前弄过来
            inst.components.health:SetInvincible(true)
            inst.components.health.canheal = false
            ---- 补上
            inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/death_voice")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_PARTING"))

                    local x, y, z = inst.Transform:GetWorldPosition()
                    ---- 变成灵魂前移   
                    inst:AddDebuff("wendy_last_food_buff", "wendy_last_food_buff") --加buff就是变灵魂
                    local angle = inst.Transform:GetRotation() * math.pi / 180 + math.pi / 2 -- 获取当前旋转角度（转为弧度）
                    local offset_x = math.cos(angle) * -0 -- 向前移动 0 单位
                    local offset_z = math.sin(angle) * -0
                    inst.Physics:Teleport(x + offset_x, y, z + offset_z)
                end
            end),
        },
    }
)