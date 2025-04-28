local SoulChain = Class(function(self, inst)
    self.inst = inst
    self.fx_list = {}
    self.total_fx = 25

    -- 启动更新，实时更新链子位置
    self.inst:StartUpdatingComponent(self)
end)

function SoulChain:OnUpdate()
    print("SoulChain:OnUpdate")

    -- 获取目标（owner）
    local target = self.inst:GetOwner()
    if not (self.inst and self.inst:IsValid() and target and target:IsValid()) then
        self:Cleanup()  -- 清理链子特效
        return
    end

    -- 每次更新时重新生成链子特效并设置位置
    self:GenerateChainFX(target)

end

function SoulChain:SetChainTransparency(alpha)
    -- 设置链条所有特效的透明度
    for _, fx in ipairs(self.fx_list) do
        if fx and fx:IsValid() then
            fx.AnimState:SetMultColour(1, 1, 1, alpha)  -- alpha值控制透明度，0为完全透明，1为完全不透明
        end
    end
end

function SoulChain:GenerateChainFX(target)
    -- 获取inst和target的全局位置
    local inst_pos = self.inst:GetPosition()
    local target_pos = target:GetPosition()
    local offset = target_pos - inst_pos

    -- 计算距离
    local offset_x = target_pos.x - inst_pos.x
    local offset_z = target_pos.z - inst_pos.z
    local distance = math.sqrt(offset_x * offset_x + offset_z * offset_z) -- 使用欧几里得距离

    -- 如果距离小于1，将所有链条特效设置为透明
    if distance < 1 then
        self:SetChainTransparency(0)  -- 设置链条全部透明
        return
    end

    -- 清理之前的链子特效
    self:Cleanup()

    -- 重新生成链子特效
    for i = 1, self.total_fx do
        local fx = SpawnPrefab("soul_link")
        if fx then
            -- 设置链条的位置（均匀分布）
            local t = i / (self.total_fx + 1)
            local x = inst_pos.x + offset.x * t
            local z = inst_pos.z + offset.z * t
            local y = 0 + 3 * t -- 高度从0到3

            -- 设置特效位置
            fx.Transform:SetPosition(x, y, z)

            -- 使用一个时间变化来控制透明度
            local time_factor = math.sin(GetTime() * 2 * math.pi + t * 2) * 0.5 + 0.5  -- 计算一个平滑的透明度变化
            fx.AnimState:SetMultColour(1, 1, 1, time_factor)  -- 通过透明度调整特效，范围0到1

            -- 将新生成的特效加入到列表
            table.insert(self.fx_list, fx)
        end
    end
end

function SoulChain:Cleanup()
    if self.fx_list then
        -- 清理所有特效
        for _, fx in ipairs(self.fx_list) do
            if fx and fx:IsValid() then
                fx:Remove()
            end
        end
        self.fx_list = {}  -- 清空链子特效列表
    end
end

function SoulChain:OnRemoveFromEntity()
    self:Cleanup()  -- 当组件从实体中移除时，清理链子特效
end

return SoulChain
