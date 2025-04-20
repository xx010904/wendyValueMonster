local LutosMutation = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("lutosmutation")
end)

function LutosMutation:OnRemoveFromEntity()
    self.inst:RemoveTag("lutosmutation")
end

return LutosMutation
