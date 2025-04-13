AddPrefabPostInit("ghostflower", function(inst)
    inst:AddComponent("hiresmallghost")
end)

AddPrefabPostInit("smallghost", function(inst)
    inst.taskTime = 0
end)

local SOILMUST = {"soil"}
local SOILMUSTNOT = {"merm_soil_blocker","farm_debris","NOBLOCK"}

local function collectdigsites(inst, digsites, tile)
    local cent = Vector3(TheWorld.Map:GetTileCenterPoint(tile[1], 0, tile[2]))
    local soils = TheSim:FindEntities(cent.x, 0, cent.z, 2, SOILMUST, SOILMUSTNOT)
    
    if #soils < 9 then
        local dist = 4/3
        for dx=-dist,dist,dist do
            local dobreak = false
            for dz=-dist,dist,dist do
                local localsoils = TheSim:FindEntities(cent.x+dx,0, cent.z+dz, 0.21, SOILMUST, SOILMUSTNOT)
                if #localsoils < 1 and TheWorld.Map:CanTillSoilAtPoint(cent.x+dx,0,cent.z+dz) then
                    table.insert(digsites,{pos = Vector3(cent.x+dx,0,cent.z+dz), tile = tile })
                end
            end
        end
    end 
    return digsites
end

local function findtillpos(inst)
    local tiles = {}
    
    if not inst.digtile then

        -- collect garden tiles in a 9x9 grid
        local RANGE = 4
        local pos = Vector3(inst.Transform:GetWorldPosition())

        for x=-RANGE,RANGE,1 do
            for z=-RANGE,RANGE,1 do
                local tx = pos.x + (x*4)
                local tz = pos.z + (z*4)
                local tile = TheWorld.Map:GetTileAtPoint(tx, 0, tz)
                if tile == WORLD_TILES.FARMING_SOIL then
                    table.insert(tiles,{tx,tz})
                end
            end
        end
    else
        table.insert(tiles,inst.digtile)
    end

    -- find diggable places in those tiles.
    local digsites = {}
    for i,tile in ipairs(tiles)do
        digsites = collectdigsites(inst,digsites, tile)
    end

    if #digsites > 0 then
        local pos = digsites[math.random(1,#digsites)].pos
        inst.digtile = digsites[math.random(1,#digsites)].tile
        return pos
    end

    inst.digtile = nil
end

local function doFarmWork(inst)
    inst:StopBrain()
    if inst.taskTime <= 0 then
        if inst._farm_task then
            inst._farm_task:Cancel()
            inst._farm_task = nil
            inst:RestartBrain()
        end
        return
    end
    local FARM_DEBRIS_TAGS = { "farm_debris" }
    local x, y, z = inst.Transform:GetWorldPosition()
    local farm_debris = TheSim:FindEntities(x, 0, z, 16, FARM_DEBRIS_TAGS)
    if #farm_debris > 0 then
        local target_pos = farm_debris[1]:GetPosition()
        inst.components.locomotor:StopMoving()
        inst.AnimState:PlayAnimation("dissipate", false)
        inst.Physics:Teleport(target_pos.x, target_pos.y, target_pos.z)
        inst.AnimState:PushAnimation("appear", false)
        farm_debris[1].components.workable:WorkedBy(inst, 1)
    else
        local pt = findtillpos(inst)
        if pt then
            if TheWorld.Map:CanTillSoilAtPoint(pt.x, 0, pt.z, false) then
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("dissipate", false)
                inst.Physics:Teleport(pt.x, pt.y, pt.z)
                inst.AnimState:PushAnimation("appear", false)
                TheWorld.Map:CollapseSoilAtPoint(pt.x, 0, pt.z)
                SpawnPrefab("farm_soil").Transform:SetPosition(pt:Get())
            end
        end
    end
    inst.taskTime = inst.taskTime - 1
end


---- 雇佣小惊吓动作
-- 定义
local HIRE_PIPSPOOK = Action({priority=1, rmb=false, distance=1, mount_valid=true })
HIRE_PIPSPOOK.id = "HIRE_PIPSPOOK"
HIRE_PIPSPOOK.str = STRINGS.ACTIONS.HIRE_PIPSPOOK
HIRE_PIPSPOOK.fn = function(act)
    -- act.target.taskTime = 60
    -- act.target._farm_task = act.target:DoPeriodicTask(1.6, doFarmWork)
    -- 干掉一个
    if act.invobject and act.invobject.components.stackable then
        act.invobject.components.stackable:Get():Remove()
    end    
    local lagTime = 10
    act.target:LinkToPlayer(act.doer)
    act.target:StopBrain()
    act.target:ListenForEvent("animover", function(inst)
        if inst.AnimState:IsCurrentAnimation("quest_completed") then
            print("act.target dissipate123")
            inst:Hide()
            inst.DynamicShadow:SetSize(0.0, 0.0)
            inst.Physics:Teleport(0, 0, 0)
            inst.components.locomotor:StopMoving()
            -- 延迟删除是因为墓碑马上会生成
            inst:DoTaskInTime(lagTime, function(inst)
                if inst and inst:IsValid() then
                    inst:Remove()
                end
            end)
        end
    end)
    act.target.AnimState:PlayAnimation("quest_completed", false)

    act.doer:DoTaskInTime(lagTime, function(inst)
        if inst and inst:IsValid() then
            local x, y, z = inst.Transform:GetWorldPosition()
            local offset = Vector3(math.random(-8, 8), 0, math.random(-8, 8))
            local spawn_pos = Vector3(x, y, z) + offset
            local smallghost = SpawnPrefab("smallghost_giver")
            smallghost.Transform:SetPosition(spawn_pos:Get())
        end
    end)
    return true
end
AddAction(HIRE_PIPSPOOK)

-- 定义动作选择器
--args: inst, doer, target, actions, right
AddComponentAction("USEITEM", "hiresmallghost", function(inst, doer, target, actions, right)
    if doer and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_smallghost_3") and target.prefab == "smallghost" and target.taskTime <= 0 then
        table.insert(actions, ACTIONS.HIRE_PIPSPOOK)
    end
end)

-- Stategraph
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.HIRE_PIPSPOOK, function(inst, action) return "give" end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.HIRE_PIPSPOOK, function(inst, action) return "give" end))