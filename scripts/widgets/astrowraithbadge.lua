local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-------------------------------------------------------------------------------------------------------

local AstroWraithBadge = Class(Badge, function(self, owner, colour, iconbuild, bonuscolor)
    Badge._ctor(self, nil, owner, colour, iconbuild, true, nil, true, bonuscolor)

	self.OVERRIDE_SYMBOL_BUILD = {} -- modders can add symbols-build pairs to this table by calling SetBuildForSymbol
	self.default_symbol_build = iconbuild

    self.bufficon = self.underNumber:AddChild(UIAnim())
    self.bufficon:GetAnimState():SetBank("wendy_ghost_power")
    self.bufficon:GetAnimState():SetBuild("wendy_ghost_power")
    self.bufficon:GetAnimState():PlayAnimation("frame")
	self.bufficon:GetAnimState():AnimateWhilePaused(false)
    self.bufficon:SetClickable(false)
	self.buffsymbol = 0
	self:Hide()
    self:StartUpdating()
end)

function AstroWraithBadge:SetBuildForSymbol(build, symbol)
	self.OVERRIDE_SYMBOL_BUILD[symbol] = build
end

function AstroWraithBadge:SetValues(symbol, time, max_time)
	local percent = time/max_time
	if percent > 0 then
		self:Show()
	else
		self:Hide()
	end
	self:SetPercent(percent,max_time)
end

function AstroWraithBadge:OnUpdate(dt)
end

return AstroWraithBadge
