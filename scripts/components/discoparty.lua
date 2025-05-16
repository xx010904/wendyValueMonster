local DiscoParty = Class(function(self, inst)
    self.inst = inst
    self._task = nil
    self.lights = {}
    self.fx_index = math.random(1, 5) -- 初始随机从第几个 FX 开始
    self.color_index = math.random(1, 6)
end)

local fx_list = {
    "tree_petal_fx_chop",
    "tree_petal_fx_chop",
    "tree_petal_fx_chop",
    "tree_petal_fx_chop",
    "tree_petal_fx_chop",
    "tree_petal_fx_chop",
}

local color_cycle = {
    {1, 0.3, 0.3}, -- 红
    {0.3, 1, 0.3}, -- 绿
    {0.3, 0.3, 1}, -- 蓝
    {1, 1, 0.3},   -- 黄
    {1, 0.3, 1},   -- 紫
    {0.3, 1, 1},   -- 青
}

local function SetupInstLight(inst)
    if not inst.Light then
        inst.entity:AddLight()
    end
    inst.Light:SetIntensity(0.8)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(5)
    inst.Light:Enable(true)
end

local function UpdateInstDiscoLight(inst, color_index)
    local color = color_cycle[color_index] or {1,1,1}
    inst.Light:SetColour(color[1], color[2], color[3])
    inst.AnimState:SetMultColour(color[1], color[2], color[3], 1)
end



local function SpawnDiscoFX(inst, fx_index)
    local x, y, z = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab(fx_list[fx_index])
    fx.Transform:SetPosition(x + math.random(-1, 1), y, z + math.random(-1, 1))

    local lightfx = SpawnPrefab("chesterlight")
    lightfx.Transform:SetPosition(x, y, z)
    lightfx.entity:SetParent(inst.entity)
    lightfx.Light:SetRadius(3 + math.random())
    lightfx.Light:SetIntensity(0.6 + math.random() * 0.3)
    lightfx.Light:SetFalloff(0.4 + math.random() * 0.4)
    lightfx.Light:SetColour(math.random(), math.random(), math.random())
    lightfx:DoTaskInTime(1.5 + math.random(), function() lightfx:Remove() end)
end

function DiscoParty:StartDisco()
    if self._task then return end

    SetupInstLight(self.inst)
    self.inst.SoundEmitter:PlaySound("dontstarve/music/music_FE", "disco_music")

    self._task = self.inst:DoPeriodicTask(0.4, function()
        UpdateInstDiscoLight(self.inst, self.color_index)
        SpawnDiscoFX(self.inst, self.fx_index)
        if math.random() < 0.1 then
            self.inst.AnimState:PlayAnimation("dance_bop", true)
        end

        -- 循环下一个 color & fx
        self.color_index = (self.color_index % #color_cycle) + 1
        self.fx_index = (self.fx_index % #fx_list) + 1
    end)
end

function DiscoParty:StopDisco()
    if self._task then
        self._task:Cancel()
        self._task = nil
    end

    self.inst.SoundEmitter:KillSound("disco_music")

    for _, light in ipairs(self.lights) do
        if light and light:IsValid() then
            light:Remove()
        end
    end
    self.lights = {}

    if self.inst.Light then
        self.inst.Light:Enable(false)
    end
    self.inst.AnimState:SetMultColour(1, 1, 1, 1)
end

return DiscoParty
