local MurderElixirUsage = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("murderelixirusage")
end)

function MurderElixirUsage:OnRemoveFromEntity()
    self.inst:RemoveTag("murderelixirusage")
end

return MurderElixirUsage
