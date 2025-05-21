-- player_uid_data.lua

local PlayerUIDData = {}

-- 存储数据：绑定到玩家 userid
PlayerUIDData.data = {}

-- 设置值
function PlayerUIDData:Set(userid, key, value)
    if userid == nil or value == nil then return end
    self.data[userid] = self.data[userid] or {}
    self.data[userid][key] = value
end

-- 获取值（可设置默认值）
function PlayerUIDData:Get(userid, key, default)
    if userid == nil then return default end
    return (self.data[userid] and self.data[userid][key]) or default
end

-- 获取整张表（如果你需要）
function PlayerUIDData:GetAll(userid)
    return self.data[userid]
end

return PlayerUIDData
