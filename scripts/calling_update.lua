AddPrefabPostInit("abigail", function(inst)
    if inst and inst.ListenForEvent then
        inst:ListenForEvent("do_ghost_hauntat", function(inst, pos)
            if (inst.sg and inst.sg:HasStateTag("nocommand"))
                    or (inst.components.health and inst.components.health:IsDead()) then
                return
            end

            -- 获取位置坐标
            local px, py, pz = pos:Get()

            -- 获取与 player 的距离
            local player = inst._playerlink
            if player and player:IsValid() then
                local player_x, player_y, player_z = player.Transform:GetWorldPosition()
                local distance = math.sqrt((px - player_x)^2 + (pz - player_z)^2)

                -- 如果 player 和 pos 的距离小于等于2
                if distance <= 2 then
                    -- 获取 player 和 inst 的当前血量百分比
                    local player_health_percentage = player.components.health:GetPercent()
                    local inst_health_percentage = inst.components.health:GetPercent()

                    -- 交换 player 和 inst 的血量百分比
                    if player.components.health then
                        player.components.health:SetPercent(inst_health_percentage)
                        player.sg:GoToState("hit")
                    end
                    if inst.components.health then
                        inst.components.health:SetPercent(player_health_percentage)
                        inst.sg:GoToState("hit")
                    end
                    inst._haunt_target = nil
                end
            end
        end)
    end
end)

