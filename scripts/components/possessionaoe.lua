local PossessionAOE = Class(function(self, inst)
    self.inst = inst
    self.enabled = false
    self.task = nil
    self.base_damage = 15
    self.radius = 4
end)

local function GetTimeBasedDamage(inst)
    local finalDamage = 15
    local attack_anim = "attack1"
	if TheWorld.state.isday then
		finalDamage = TUNING.ABIGAIL_DAMAGE.day
		attack_anim = "attack1"
	elseif TheWorld.state.isdusk then
		finalDamage = TUNING.ABIGAIL_DAMAGE.dusk
		attack_anim = "attack2"
	elseif TheWorld.state.isnight then
		finalDamage = TUNING.ABIGAIL_DAMAGE.night
		attack_anim = "attack3"
	end
    inst.ghost_attack_fx.AnimState:PlayAnimation(attack_anim .. "_pre")
    inst.ghost_attack_fx.AnimState:PushAnimation(attack_anim .. "_loop")
    inst.ghost_attack_fx.AnimState:PushAnimation(attack_anim .. "_pst")
    return finalDamage
end

function PossessionAOE:DoAOEAttack()
    if not self.inst:IsValid() then return end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, y, z, self.radius, { "_combat" }, {
        "player", "FX", "INLIMBO", "ghost", "abigail", "wall", "noattack",
    })

    local damage = GetTimeBasedDamage(self.inst)

    self.inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/attack_LP", "angry")
    -- self.inst.AnimState:SetMultColour(207/255, 92/255, 92/255, 1)

    for _, target in ipairs(targets) do
        if target ~= self.inst and target.components.health and not target.components.health:IsDead() then
            target.components.combat:GetAttacked(self.inst, damage, nil, nil, nil)
            -- self.inst.components.combat:DoAttack(target, nil, nil, nil, damage)
        end
    end
end

function PossessionAOE:Enable()
    if self.enabled then return end
    self.enabled = true

    self.inst.ghost_attack_fx = SpawnPrefab("abigail_attack_fx")
    self.inst:AddChild(self.inst.ghost_attack_fx)

    self.inst.ghost_attack_fx.Light:SetIntensity(.6)
    self.inst.ghost_attack_fx.Light:SetRadius(.5)
    self.inst.ghost_attack_fx.Light:SetFalloff(.6)
    self.inst.ghost_attack_fx.Light:Enable(true)
    self.inst.ghost_attack_fx.Light:SetColour(180 / 255, 195 / 255, 225 / 255)

    self.task = self.inst:DoPeriodicTask(1, function() self:DoAOEAttack() end)
end

function PossessionAOE:Disable()
    if self.inst.ghost_attack_fx then
        self.inst.ghost_attack_fx:Remove()
        self.inst.ghost_attack_fx = nil
    end

    if not self.enabled then return end
    self.enabled = false
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function PossessionAOE:IsEnabled()
    return self.enabled
end

function PossessionAOE:OnRemoveFromEntity()
    self:Disable()
end

return PossessionAOE
