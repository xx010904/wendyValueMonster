local GraveBunker = Class(function(self, inst)
	self.inst = inst
	inst:AddTag("gravebunker")
end)

function GraveBunker:OnRemoveFromEntity()
    self.inst:RemoveTag("gravebunker")
end

function GraveBunker:DoBunk(doer)
	doer.usingbunker = self.inst
	self.inst:AddTag("hashider")
end

function GraveBunker:DoLeave(doer)
	doer.usingbunker = nil
	self.inst:RemoveTag("hashider")
end

return GraveBunker
