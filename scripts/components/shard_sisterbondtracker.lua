local shard_sisterbondtracker = Class(function(self, inst)
    self.inst = inst
    local _world = TheWorld
    local _ismastershard = _world.ismastershard
    local _shard_id = tostring(TheShard:GetShardId()) or "unknown"

    local _sisterbond_net = net_string(inst.GUID, "shard_sisterbondtracker._sisterbond_net", "sisterbonddirty")
    local _ghosthealth_net = net_string(inst.GUID, "shard_sisterbondtracker._ghosthealth_net", "ghosthealthdirty")

    inst.entity:SetPristine()

    --------------------------------------------------------------------------
    -- 通用方法：用于广播 payload 到 net_string
    --------------------------------------------------------------------------
    local function BroadcastNetData(netvar, eventname, payload)
        payload.source_shardid = _shard_id
        local json_data = json.encode(payload)
        netvar:set(json_data)
        print(string.format(
            "[shard_sisterbondtracker] shard[%s] 通过 %s 广播更新: userid=%s, value=%s",
            _shard_id, eventname, payload.userid, tostring(payload.value)
        ))
    end

    --------------------------------------------------------------------------
    -- 监听 sync_other_sisterbond 同步请求并广播 net_string
    --------------------------------------------------------------------------
    local function OnAnySisterBondUpdate(src, data)
        print("[shard_sisterbondtracker] 监听到 sync_other_sisterbond 事件")
        if not data or not data.userid or data.sisterBond == nil then
            print("[shard_sisterbondtracker][error] 无效数据", data and dumptable(data) or "nil")
            return
        end

        BroadcastNetData(_sisterbond_net, "sisterbonddirty", {
            userid = data.userid,
            value = data.sisterBond,
        })
    end

    --------------------------------------------------------------------------
    -- 监听 sync_other_ghosthealth 同步请求并广播 net_string
    --------------------------------------------------------------------------
    local function OnAnyGhostHealthUpdate(src, data)
        print("[shard_sisterbondtracker] 监听到 sync_other_ghosthealth 事件")
        if not data or not data.userid or data.ghostCurrentHealth == nil then
            print("[shard_sisterbondtracker][error] 无效数据", data and dumptable(data) or "nil")
            return
        end

        BroadcastNetData(_ghosthealth_net, "ghosthealthdirty", {
            userid = data.userid,
            value = data.ghostCurrentHealth,
        })
    end

    --------------------------------------------------------------------------
    -- 处理广播的 sisterbonddirty net_string 更新
    --------------------------------------------------------------------------
    local function OnSisterBondDirty()
        local str = _sisterbond_net:value()
        if not str or str == "" then return end

        local data = json.decode(str)
        if not data or not data.userid or data.value == nil then return end
        if data.source_shardid == _shard_id then return end

        print(string.format(
            "[shard_sisterbondtracker][%s] 收到 sisterbonddirty from shard[%s]: userid=%s, value=%s",
            _shard_id, data.source_shardid, data.userid, tostring(data.value)
        ))

        _world:PushEvent("sisterbond_update_remote", {
            userid = data.userid,
            sisterBond = data.value,
        })
    end

    --------------------------------------------------------------------------
    -- 处理广播的 ghosthealthdirty net_string 更新
    --------------------------------------------------------------------------
    local function OnGhostHealthDirty()
        local str = _ghosthealth_net:value()
        if not str or str == "" then return end

        local data = json.decode(str)
        if not data or not data.userid or data.value == nil then return end
        if data.source_shardid == _shard_id then return end

        print(string.format(
            "[shard_sisterbondtracker][%s] 收到 ghosthealthdirty from shard[%s]: userid=%s, value=%s",
            _shard_id, data.source_shardid, data.userid, tostring(data.value)
        ))

        _world:PushEvent("ghosthealth_update_remote", {
            userid = data.userid,
            ghostCurrentHealth = data.value,
        })
    end

    --------------------------------------------------------------------------
    -- 初始化监听
    --------------------------------------------------------------------------
    inst:ListenForEvent("sync_other_sisterbond", OnAnySisterBondUpdate, _world)
    inst:ListenForEvent("sync_other_ghosthealth", OnAnyGhostHealthUpdate, _world)

    TheWorld:DoTaskInTime(0, function()
        inst:ListenForEvent("sisterbonddirty", OnSisterBondDirty)
        inst:ListenForEvent("ghosthealthdirty", OnGhostHealthDirty)
    end)
end)

return shard_sisterbondtracker
