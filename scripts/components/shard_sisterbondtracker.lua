local shard_sisterbondtracker = Class(function(self, inst)
    -- assert(TheWorld.ismastersim, "shard_sisterbondtracker 只能在服务器运行")

    self.inst = inst
    local _world = TheWorld
    local _ismastershard = _world.ismastershard
    local _shard_id = tostring(TheShard:GetShardId()) or "unknown"

    local _sisterbond_net = net_string(inst.GUID, "shard_sisterbondtracker._sisterbond_net", "sisterbonddirty")

    inst.entity:SetPristine() -- 确保服务端能监听 dirty

    --------------------------------------------------------------------------
    -- 主或从 shard：监听世界事件，写入 net_string 触发广播
    --------------------------------------------------------------------------
    local function OnAnySisterBondUpdate(src, data)
        print("[shard_sisterbondtracker] 监听到 sync_other_sisterbond 事件 准备更新 net_string ")
        if not data or not data.userid or data.sisterBond == nil then
            print("[shard_sisterbondtracker][error] 无效数据", data and dumptable(data) or "nil")
            return
        end

        -- 附加 shard 来源 ID 再同步
        local payload = {
            userid = data.userid,
            sisterBond = data.sisterBond,
            source_shardid = _shard_id,
        }
        local json_data = json.encode(payload)
        _sisterbond_net:set(json_data) -- 广播

        print(string.format(
            "[shard_sisterbondtracker] shard[%s]的net变量已经设置, 已经开始广播 sisterbonddirty 事件更新: userid=%s, value=%s",
            _shard_id, data.userid, tostring(data.sisterBond)
        ))
    end

    --------------------------------------------------------------------------
    -- 所有 shard：监听 net_string 更新，解析并分发事件
    --------------------------------------------------------------------------
    local function OnSisterBondDirty()
        print("监听到 sisterbonddirty 事件 net_string 更新")
        local str = _sisterbond_net:value()
        if not str or str == "" then
            print("[shard_sisterbondtracker][warn] 空的 net_string")
            return
        end

        local data = json.decode(str)
        if not data or not data.userid or data.sisterBond == nil then
            print("[shard_sisterbondtracker][warn] 解码失败或数据不完整:", str)
            return
        end

        -- 来自自己的广播，忽略
        if data.source_shardid == _shard_id then
            print("[shard_sisterbondtracker] 收到自己 shard 发出的广播 sisterbonddirty，跳过")
            return
        end

        print(string.format(
            "[shard_sisterbondtracker][%s] 接收到来自 shard(%s) 的 sisterbonddirty: userid=%s, value=%s",
            _shard_id, tostring(data.source_shardid), data.userid, tostring(data.sisterBond)
        ))

        -- 转发为本 shard 的事件
        _world:PushEvent("sisterbond_update_remote", data)
    end

    -- 所有 shard 都监听事件并广播出去
    inst:ListenForEvent("sync_other_sisterbond", OnAnySisterBondUpdate, _world)

    -- 所有 shard 都监听广播变动
    inst:ListenForEvent("sisterbonddirty", OnSisterBondDirty)
end)

return shard_sisterbondtracker
