local FlowerMutation = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("flowermutation")
end)

function FlowerMutation:OnRemoveFromEntity()
    self.inst:RemoveTag("flowermutation")
end

return FlowerMutation
