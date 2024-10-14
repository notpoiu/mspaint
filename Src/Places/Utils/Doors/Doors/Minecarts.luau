--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

type tPathfind = {
    esp: boolean,
    room_number: number, -- the room number
    real: table,
    fake: table,
    destroyed: boolean -- if the pathfind was destroyed for the Teleport
}

type tGroupTrack = {
    nodes: table,
    hasStart: boolean,
    hasEnd: boolean,
}

--// Functions \\--
local function changeNodeColor(node: Model, color: Color3): Model
    if color == nil then
        node.Color = Script.MinecartPathNodeColor.Yellow
        node.Transparency = 1
        node.Size = Vector3.new(1.0, 1.0, 1.0)
        return
    end
    node.Color = color
    node.Material = Enum.Material.Neon
    node.Transparency = 0
    node.Shape = Enum.PartType.Ball
    node.Size = Vector3.new(0.7, 0.7, 0.7)
    return node
end

local function tPathfindNew(n: number)
    local create: tPathfind = {
        esp = false,
        room_number = n,
        real = {},
        fake = {},
        destroyed = false
    }
    return create
end

local function tGroupTrackNew(startNode: Part | nil): tGroupTrack
    local create: tGroupTrack = {
        nodes = startNode and {startNode} or {},
        hasStart = false,
        hasEnd   = false,
    }
    return create
end

function Script.Functions.Minecart.Pathfind(room: Model, lastRoom: number)
    if not (lastRoom >= 40 and lastRoom <= 49) and not (lastRoom >= 95 and lastRoom <= 100) then return end
    
    local nodes = room:WaitForChild("RunnerNodes", 5.0) --well, skill issue ig
    if (nodes == nil) then return end

    nodes = nodes:GetChildren()

    local numOfNodes = #nodes
    if numOfNodes <= 1 then return end --This is literally impossible but... umm. acutally, yea why not.

    --[[
        Pathfind is a computational expensive process to make, 
        however we don't have node loops, 
        so we can ignore a few verifications.
        If you want to understand how this is working, search for "Pathfiding Algorithms"

        The shortest explanation i can give is that, this is a custom pathfinding to find "gaps" between
        nodes and creating "path" groups. With the groups estabilished we can make the correct validations.
    ]]
    --Distance weights [DO NOT EDIT, unless something breaks...]
    local _shortW = 4
    local _longW = 24

    local doorModel = room:WaitForChild("Door", 5) -- Will be used to find the correct last node.

    local _startNode = nodes[1]
    local _lastNode = nil --we need to find this node.

    local _gpID = 1
    local stackNode = {} --Group all track groups here.
    stackNode[_gpID] = tGroupTrackNew()
    
    --Ensure sort all nodes properly (reversed)
    table.sort(nodes, function(a, b)
        local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
        local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
        return tonumber(_Asub) > tonumber(_Bsub)
    end)

    local _last = 1
    for i= _last + 1, numOfNodes, 1 do
        local nodeA: Part = nodes[_last]
        local nodeB: Part = _lastNode and nodes[i] or doorModel

        local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude

        local isEndNode = distance <= _shortW
        local isNodeNear = (distance > _shortW and distance <= _longW)

        local _currNodeTask = "Track"
        if isNodeNear or isEndNode then
            if not _lastNode then -- this will only be true, once.
                _currNodeTask = "End"
                _lastNode = nodeA
            end
        else
            _currNodeTask = "Fake"
        end

        --check if group is diff, ignore "End" or "Start" tasks
        if (_currNodeTask == "Fake" or _currNodeTask == "End") and _lastNode then
            _gpID += 1
            stackNode[_gpID] = tGroupTrackNew()
            if _currNodeTask == "End" then
                stackNode[_gpID].hasEnd = true
            end
        end
        table.insert(stackNode[_gpID].nodes, nodeA)

        _last = i
    end
    stackNode[_gpID].hasStart = true --after the reversed path finding, the last group has the start node.
    table.insert(stackNode[_gpID].nodes, _startNode)
    local hasMoreThanOneGroup = _gpID > 1

    local _closestNodes = {} --unwanted nodes if any
    local hasIncorrectPath = false -- if this is true, we're cooked. No path for you ):
    if hasMoreThanOneGroup then
        for _gpI, v: tGroupTrack in ipairs(stackNode) do
            _closestNodes[_gpI] = {}
            if _gpI <= 1 then continue end

            table.sort(v.nodes, function(a,b)
                local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
                local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
                return tonumber(_Asub) < tonumber(_Bsub)
            end)

            local _gplast = 1
            local hasNodeJump = false
            for _gpS=_gplast+1, #v.nodes, 1 do
                local nodeA: Part = v.nodes[_gplast]
                local nodeB: Part = v.nodes[_gpS]

                local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude

                hasNodeJump = (distance >= _longW)
                if not hasNodeJump then _gplast = _gpS continue end

                local nodeSearchPath = nodeB

                --Search again with the nodeSearchPath
                local closestDistance = math.huge

                local _gpFlast = #v.nodes
                for i = _gpFlast - 1, 1, -1 do
                    local fnode = v.nodes[_gpFlast]
                    local Sdistance = (nodeSearchPath:GetPivot().Position - fnode:GetPivot().Position).Magnitude
                    _gpFlast = i

                    if Sdistance == 0.00 then continue end --node is self

                    if Sdistance <= closestDistance then
                        closestDistance = Sdistance
                        table.insert(_closestNodes[_gpI], fnode)
                        table.remove(v.nodes, _gpFlast + 1)
                        continue
                    end
                    break
                end

                local _FoundAmount = #_closestNodes[_gpI]
                if _FoundAmount < 1 then 
                    hasIncorrectPath = true
                end
                break
            end
        end
    end

    if hasIncorrectPath then return end

    --finally, draw the correct path. gg
    local realNodes = {} --our precious nodes finally here :pray:
    local fakeNodes = {} --we hate you but ok
    for _gpFI, v: tGroupTrack in ipairs(stackNode) do
        local finalWrongNode = false
        if _gpFI == 1 and hasMoreThanOneGroup then
            finalWrongNode = true 
        end

        for _, vfinal in ipairs(v.nodes) do
            if finalWrongNode then
                table.insert(fakeNodes, vfinal)
                continue
            end
            table.insert(realNodes, vfinal)
        end

        --Draw wrong path calculated on DeepPath.
        for _, nfinal in ipairs(_closestNodes[_gpFI]) do
            table.insert(fakeNodes, nfinal)
        end
    end

    table.sort(realNodes, function(a, b)
        local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
        local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
        return tonumber(_Asub) < tonumber(_Bsub)
    end)

    --build pathfind
    local buildPathfind = tPathfindNew(lastRoom)
    buildPathfind.real = realNodes
    buildPathfind.fake = fakeNodes
    table.insert(Script.MinecartPathfind, buildPathfind) --add to table

    Script.Functions.Minecart.DrawNodes()

    if Toggles.MinecartTeleport.Value and (lastRoom >= 45 and lastRoom <= 49) then
        Script.Functions.Minecart.NodeDestroy(tonumber(room.Name))
        Script.Functions.Minecart.Teleport(tonumber(room.Name))
    end
end

function Script.Functions.Minecart.NodeDestroy(roomNum: number)
    local roomConfig = Script.WhitelistConfig[roomNum]
    if not roomConfig then return end

    local _firstKeep = roomConfig.firstKeep
    local _lastKeep  = roomConfig.lastKeep

    local realNodes = nil
    local fakeNodes = nil
    for _, path: tPathfind in ipairs(Script.MinecartPathfind) do
        if path.room_number ~= roomNum then continue end
        if path.destroyed then continue end

        realNodes = path.real
        fakeNodes = path.fake
    end

    if realNodes then
        local _removeTotal = #realNodes - (_firstKeep + _lastKeep) --remove nodes that arent in the first or last
        for _ = 1, _removeTotal do
            local node = realNodes[_firstKeep + 1]
            node:Destroy()
            
            table.remove(realNodes, _firstKeep + 1)
        end
    else
        print("[NodeDestroy] Unable to destroy REAL nodes.")
    end

    if fakeNodes then
        --Destroy all the fake nodes
        for _, node in ipairs(fakeNodes) do
            node:Destroy()
        end
        fakeNodes = {} --if we now all the nodes will be destroyed then just make that.
    else
        print("[NodeDestroy] Unable to destroy FAKE nodes.")
    end

    print(string.format("[NodeDestroy] Task completed, remaining: Real nodes: %d | Fake nodes %s", #realNodes, #fakeNodes))
end

local isMinecartTeleporting = false --for debug purpouses.
function Script.Functions.Minecart.Teleport(roomNum: number)
    if roomNum == 45 and not isMinecartTeleporting then
        isMinecartTeleporting = true
        task.spawn(function()
            local progressPart = Instance.new("Part", workspace) do
                progressPart.Anchored = true
                progressPart.CanCollide = false
                progressPart.Name = "_internal_mspaint_minecart_teleport"
                progressPart.Transparency = 1
            end
            shared.Notify:Alert({
                Title = "Minecart Teleport",
                Description = "Minecart teleport is ready! Waiting for the minecart...",

                Time = progressPart
            })

            local minecartRig
            local minecartRoot
            repeat task.wait(0.1) 
                minecartRig = shared.Camera:FindFirstChild("MinecartRig")
                if not minecartRig then continue end
                minecartRoot = minecartRig:FindFirstChild("Root")
            until minecartRig and minecartRoot

            if workspace:FindFirstChild("_internal_mspaint_minecart_teleport") then workspace:FindFirstChild("_internal_mspaint_minecart_teleport"):Destroy() end
            task.wait(3)

            for _, path: tPathfind in ipairs(Script.MinecartPathfind) do
                local roomOfThePath = path.room_number

                if roomOfThePath >= 45 then -- ignore ground chase
                    local getLastNode = path.real[#path.real]

                    repeat 
                        task.wait()
                        minecartRoot.CFrame = getLastNode.CFrame
                    until workspace.CurrentRooms[tostring(Script.CurrentRoom)]:WaitForChild("Door"):GetAttribute("Opened")
                    task.wait(2)
                    if Script.CurrentRoom == 49 then break end
                end
            end
        end)
    end
end


--If ESP Toggle is changed, you can call this function directly.
function Script.Functions.Minecart.DrawNodes()
    local pathESP_enabled = Toggles.MinecartPathVisualiser.Value
    local espRealColor = if pathESP_enabled then Script.MinecartPathNodeColor.Green else Script.MinecartPathNodeColor.Disabled
    
    for idx, path: tPathfind in ipairs(Script.MinecartPathfind) do
        if path.esp and pathESP_enabled then continue end -- if status is unchanged.

        --[ESP] Draw the real path
        local realPath = path.real
        for _, _real in pairs(realPath) do
            changeNodeColor(_real, espRealColor)
        end

        path.esp = pathESP_enabled --update if path esp status was changed.
    end
end