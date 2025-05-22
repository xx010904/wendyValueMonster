local PlayerBondTracker = Class(function(self, inst)
    self.inst = inst
    self.playerbonddata = {}  -- 结构: { [userid] = { sisterBond = 1, ghostcurrenthealth = 150, ... } }
end)

-- 设置某个玩家的属性
function PlayerBondTracker:SetBondData(userid, key, value)
    if userid == nil then return end
    self.playerbonddata[userid] = self.playerbonddata[userid] or {}
    self.playerbonddata[userid][key] = value
    -- print(string.format("[Bond] Set %s: %s = %s", userid, key, tostring(value)))
end

-- 获取某个玩家的属性
function PlayerBondTracker:GetBondData(userid, key)
    return self.playerbonddata[userid] and self.playerbonddata[userid][key] or nil
end

-- 获取整张数据（如有需要）
function PlayerBondTracker:GetAllBondData(userid)
    return self.playerbonddata[userid]
end

-- 保存世界时调用
function PlayerBondTracker:OnSave()
    print("[Bond] OnSave player bond data")
    return {
        playerbonddata = self.playerbonddata,
    }
end

-- 读取存档时调用
function PlayerBondTracker:OnLoad(data)
    if data ~= nil and data.playerbonddata ~= nil then
        self.playerbonddata = data.playerbonddata
        print("[Bond] Loaded player bond data")
    end
end

return PlayerBondTracker
