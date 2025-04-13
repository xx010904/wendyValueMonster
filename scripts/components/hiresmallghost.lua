local HireSmallGhost = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("hiresmallghost")
end)

function HireSmallGhost:OnRemoveFromEntity()
    self.inst:RemoveTag("hiresmallghost")
end

return HireSmallGhost
