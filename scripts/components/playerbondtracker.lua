local PlayerBondTracker = Class(function(self, inst)
    self.inst = inst
    self.SyncSisterBond = false
    self.playerbonddata = {}  -- 结构: { [userid] = { sisterBond = 1, ghostcurrenthealth = 150, ... } }
end)

-- 设置某个玩家的属性
function PlayerBondTracker:SetBondData(userid, key, value)
    if userid == nil then return end
    self.playerbonddata[userid] = self.playerbonddata[userid] or {}
    self.playerbonddata[userid][key] = value
    -- print(string.format("[Bond] Set %s: %s = %s", userid, key, tostring(value)))

    if self.SyncSisterBond then
        if not userid or key == nil or value == nil then
            print("[playerbondtracker][warn] 设置 bond 失败: 参数无效")
            return
        end

        print(string.format(
            "[playerbondtracker] 设置 bond 数据: userid=%s, key=%s, value=%s",
            userid, key, tostring(value)
        ))

        -- 当前只支持同步 sisterbond
        if key == "sisterBond" then
            print("[playerbondtracker] 自己的更新完毕，开始同步别人的")
            TheWorld:PushEvent("sync_other_sisterbond", {
                userid = userid,
                sisterBond = value,
            })
            print("[playerbondtracker] 已触发完毕 sync_other_sisterbond 事件")
        end
    end
end

-- 接收远程同步数据（由 shard_sisterbondtracker 广播后触发）
function PlayerBondTracker:OnRemoteUpdate(userid, key, value)
    if not userid or not key or value == nil then
        print("[playerbondtracker][warn] 接收远程同步失败: 参数无效")
        return
    end

    self.playerbonddata[userid] = self.playerbonddata[userid] or {}
    self.playerbonddata[userid][key] = value

    print(string.format(
        "[playerbondtracker] 从 shard 同步到 bond 数据: userid=%s, key=%s, value=%s",
        userid, key, tostring(value)
    ))
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
