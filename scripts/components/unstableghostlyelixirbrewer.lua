
local UnstableGhostlyElixirBrewer = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("unstableghostlyelixirbrewer")
end)

function UnstableGhostlyElixirBrewer:OnRemoveFromEntity()
    self.inst:RemoveTag("unstableghostlyelixirbrewer")
end

return UnstableGhostlyElixirBrewer