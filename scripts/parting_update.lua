local AstroWraithBadge = require "widgets/astrowraithbadge"

---- 添加制作配方
AddRecipe2("wendy_last_food",
{
    Ingredient("bananapop", 1),
    Ingredient("nightmarefuel", 2),
    Ingredient("ghostflower", 3)
},
TECH.NONE,
{
    product = "wendy_last_food", -- 唯一id
    actionstr = "SOULCHILLIFY", -- 动作id
    atlas = "images/inventoryimages/wendy_last_food.xml",
    image = "wendy_last_food.tex",
    builder_tag = "ghostlyfriend",
    builder_skill= "wendy_avenging_ghost",
    description = "wendy_last_food", -- 描述的id，而非本身
    numtogive = 1,
}
)
AddRecipeToFilter("wendy_last_food", "CHARACTER")


AddPrefabPostInit("wendy", function(inst)
    inst:AddComponent("astrowraith")
end)

-- 修改 astrowraithbadge 位置，保证存活的时候也不遮挡
AddClassPostConstruct("widgets/statusdisplays", function(self)
    self.astrowraithbadge = self:AddChild(AstroWraithBadge(self.owner, nil, "wendy_ghost_power" ))
    self.astrowraithbadge:SetPosition(-140, 20)
    self.astrowraithbadge:Hide()
end)

AddClientModRPCHandler("WendyValueMonster", "UpdateGhostPowerBadge", function(count, max)
    -- print("UpdateGhostPowerBadgeRPC", count, max)
    local badge = ThePlayer.HUD and ThePlayer.HUD.controls and ThePlayer.HUD.controls.status and ThePlayer.HUD.controls.status.astrowraithbadge
    -- print("UpdateGhostPowerBadge", badge, ThePlayer.HUD.controls)
    if badge then
        if count > 0 then
            badge:Show()
            badge:SetValues(nil, count, max)
        else
            badge:Hide()
        end
    end
end)

-- 惊吓驯化的牛
local function panicBeefalo(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local nearby_ents = TheSim:FindEntities(x, y, z, 10.0, { "beefalo" }, { "player", "INLIMBO" })

    for _, ent in ipairs(nearby_ents) do
        if ent ~= inst and
            ent.components.domesticatable and
            ent.components.domesticatable.domestication and
            ent.components.domesticatable.domestication > 0 and
            ent.components.locomotor
        then

            ent:StopBrain()

            local ex, ey, ez = ent.Transform:GetWorldPosition()
            local dx = x - ex    -- 注意这里是 x - ex
            local dz = z - ez    -- 注意这里是 z - ez
            local angle = math.atan2(-dz, -dx) * (180 / math.pi)  -- 反向方向

            ent:PushEvent("locomote")
            ent.components.locomotor:RunInDirection(angle)

            ent:DoTaskInTime(2.5, function()
                if ent.components.locomotor then
                    ent.components.locomotor:Stop()
                    ent:RestartBrain()
                end
            end)
        end
    end
end

AddStategraphState('wilson',
    State{
        name = "parting",
        tags = { "busy", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst)
            panicBeefalo(inst)
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