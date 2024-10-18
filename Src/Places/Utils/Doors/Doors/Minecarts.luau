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

--@Internal nodes sorted by @GetNodes or @Pathfind
type tSortedNodes = {
    real: table,
    fake: table,
    room: number,
}

local function tGroupTrackNew(startNode: Part | nil): tGroupTrack
    local create: tGroupTrack = {
        nodes = startNode and {startNode} or {},
        hasStart = false,
        hasEnd   = false,
    }
    return create
end

--@Internal funtion
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

--@Internal function
--@Return #boolean. True if the pathfind algorithm was ran.
local function HasAlreadyPathfind(nodesFolder: Folder): boolean
    local hasPathfind = nodesFolder:GetAttribute("_mspaint_nodes_pathfind")
    return hasPathfind
end

--@Internal function
local function HasNodesToPathfind(room: Model)
    local roomNumber = tonumber(room.Name)
    --Make room number restrictions to avoid useless mapping.
    local seekChaseMinecartRooms = (roomNumber >= 42 and roomNumber <= 49)
    local seekChaseDuctsRoom     = (roomNumber >= 95 and roomNumber <= 100)
    local result = (seekChaseMinecartRooms or seekChaseDuctsRoom)
    Script.Functions.Minecart.debug("[HasNodesToPathfind]: " .. tostring(result) .. " - " .. room.Name)
    return result
end

--@Internal funtion
local function sortNodes(nodes: table, reversed: boolean) -- Sort nodes by their number
    table.sort(nodes, function(a, b)
        local Anumber, _ = (a.Name):gsub("[^%d+]", "")
        local Bnumber, _ = (b.Name):gsub("[^%d+]", "")
        if reversed then
            return tonumber(Anumber) > tonumber(Bnumber) --example: 100 to 0
        end
        return tonumber(Anumber) < tonumber(Bnumber) --example: 0 to 100
    end)
    return nodes
end

--@Internal function
--@Return #table with a sorted array of real and fake nodes and the room number. 
--@Return #nil if there's no Nodes to be processed
local function PathfindGetNodes(room: Model): tSortedNodes | nil
    Script.Functions.Minecart.debug("[GetNodes] Starting getting nodes for: " .. room.Name)
    if not HasNodesToPathfind(room) then return end

    local Nodes = {
        real = {},
        fake = {}
    }
    local nodeArray = room:WaitForChild("RunnerNodes", 5.0)
    if (nodeArray == nil) then 
        Script.Functions.Minecart.debug("[GetNodes] No node has been found for the room: " .. room.Name)
        return
    end

    if not HasAlreadyPathfind(nodeArray) then 
        Script.Functions.Minecart.debug("[GetNodes] Pathfind not initialized for room: " .. room.Name)
        Script.Functions.Minecart.Pathfind(room, true)
        return 
    end

    Script.Functions.Minecart.debug("[GetNodes] Get real & fake nodes for room: " .. room.Name, " - nodes:" .. tostring(#nodeArray:GetChildren()))

    for _, node: Part in ipairs(nodeArray:GetChildren()) do
        --check for real nodes
        
        local realNumber = node:GetAttribute("_mspaint_real_node")
        if realNumber then table.insert(Nodes.real, node) continue end
        --check for fake nodes
        local fakeNumber = node:GetAttribute("_mspaint_fake_node")
        if fakeNumber then table.insert(Nodes.fake, node) end
    end

    --If there's no nodes, return the empty table
    if #Nodes.real <= 0 and #Nodes.fake <= 0 then 
        Script.Functions.Minecart.debug("[GetNodes] No node has been mapped yet for room: " .. room.Name)
        return
    end

    local sortedReal = sortNodes(Nodes.real)
    local sortedFake = sortNodes(Nodes.fake)

    local nodesList = {
        real = sortedReal,
        fake = sortedFake,
        roomNumber = tonumber(room.Name)
    }
    Script.Functions.Minecart.debug("[GetNodes] Successfully sent sorted nodes in room: " .. room.Name) 
    return nodesList
end

--@Internal function
--@Return nil. __Set the node attribute.__ Can only be called after the __@Pathfind function is completed.__
local function PathfindSetNodes(nodes: table, nameAttribute: string)
    Script.Functions.Minecart.debug("[SetNodes] Setting pathfind attributes") 
    for i, node: Part in ipairs(nodes) do
        node:SetAttribute(nameAttribute, i)
    end
end

local WhitelistConfig = {
    [45] = {firstKeep = 3, lastKeep = 2},
    [46] = {firstKeep = 2, lastKeep = 2},
    [47] = {firstKeep = 2, lastKeep = 2},
    [48] = {firstKeep = 2, lastKeep = 2},
    [49] = {firstKeep = 2, lastKeep = 4},
}

--@Internal function
local function NodeDestroy(nodesList: tSortedNodes)
    if not nodesList then return end

    print("[NodeDestroy] Attempting to destroy nodes in room: " .. tostring(nodesList.roomNumber))

    local roomConfig = WhitelistConfig[nodesList.roomNumber]

    local _firstKeep = roomConfig.firstKeep
    local _lastKeep  = roomConfig.lastKeep

    local _removeTotal = #nodesList.real - (_firstKeep + _lastKeep) --remove nodes that arent in the first or last
    for idx=1, _removeTotal do
        local node = nodesList.real[_firstKeep + 1]
        --changeNodeColor(node, MinecartPathNodeColor.Orange) --debug only
        node:Destroy()
        table.remove(nodesList.real, _firstKeep + 1)
    end

    --Destroy all the fake nodes
    for _, node in ipairs(nodesList.fake) do
        node:Destroy()
        table.remove(nodesList.fake, 1)
    end

    Script.Functions.Minecart.debug(string.format("[NodeDestroy] Task completed, remaining: Real nodes: %d | Fake nodes %s", #nodesList.real, #nodesList.fake))
end

--@Internal function
--@Return #boolean. True if the pathfind algorithm was ran.
local function HasAlreadyDestroyed(room: Model): boolean
    Script.Functions.Minecart.debug("[HasAlreadyDestroyed] Checking destroyed nodes on room: " .. room.Name)
    local nodesFolder = room:WaitForChild("RunnerNodes", 5.0)
    if (nodesFolder == nil) then 
        Script.Functions.Minecart.debug("[HasAlreadyDestroyed] No node has been found." )
        return
    end
    local result = nodesFolder:GetAttribute("_mspaint_player_teleported") ~= nil
    Script.Functions.Minecart.debug("[HasAlreadyDestroyed] Destroyed: " .. tostring(result))
    return result
end

--The Minecart Teleport Function, this will be called with @NodeDestroy.
--[[
    Use "_mspaint_player_teleported" to track the status of the Teleport meaning that:
    _mspaint_player_teleported = nil   ==> Node not destroyed
    _mspaint_player_teleported = false ==> Node destroyed
    _mspaint_player_teleported = true ==> Nodes was destroyed + Player sucessfully teleported.
]]
local MinecartFound = false
function Script.Functions.Minecart.Teleport(room: Model)
    if not Toggles.MinecartTeleport.Value then return end

    local roomNumber = tonumber(room.Name)
    if not (roomNumber >= 45 and roomNumber <= 49) then return end
    Script.Functions.Minecart.debug("[Teleport] Was called for room: " .. room.Name)

    if not HasAlreadyDestroyed(room) then
        local nodesList = PathfindGetNodes(room)
        if not nodesList then return end
        NodeDestroy(nodesList)
        room:SetAttribute("_mspaint_player_teleported", false)
    end

    local hasAlreadyTeleported = room:GetAttribute("_mspaint_player_teleported")
    Script.Functions.Minecart.debug("[Teleport] Player already teleported:" .. tostring(hasAlreadyTeleported))

    --Setup minecart teleport if room 45 is added.
    if roomNumber == 45 and not hasAlreadyTeleported then
        task.spawn(function()

            --Delete old notification
            if workspace:FindFirstChild("_internal_mspaint_minecart_teleport") then 
                workspace:FindFirstChild("_internal_mspaint_minecart_teleport"):Destroy() 
            end

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
        end)

        Script.Functions.Minecart.debug("[Teleport] Minecart Teleport initialization room:" .. room.Name)
        --LSplash actually fix your game omg...
        local minecartRigs = {}
        task.spawn(function()
            while not MinecartFound and not shared.Library.Unloaded do
                shared.RunService.RenderStepped:Wait()
                for idx, stuff: Instance in pairs(shared.Camera:GetChildren()) do
                    if stuff.Name ~= "MinecartRig" then continue end
                    table.insert(minecartRigs, stuff)
                    Script.Functions.Minecart.debug("[Teleport] MinecartRig found, adding to table")
                    repeat 
                        task.wait()
                    until not stuff:IsDescendantOf(shared.Camera) 
                    Script.Functions.Minecart.debug("[Teleport] MinecartRig fake removed.")
                    table.remove(minecartRigs, idx)
                end
            end
        end)

        while #minecartRigs == 0 and not shared.Library.Unloaded do 
            task.wait(0.5)
            Script.Functions.Minecart.debug("[Teleport] Room to Teleport: " .. tostring(Script.LatestRoom.Value))
        end

        Script.Functions.Minecart.debug("[Teleport] MinecartRig Found! Initializing Teleport...")

        if workspace:FindFirstChild("_internal_mspaint_minecart_teleport") then workspace:FindFirstChild("_internal_mspaint_minecart_teleport"):Destroy() end
        shared.Notify:Alert({
            Title = "Minecart Teleport",
            Description = "Minecart teleport started. Enjoy the ride!",

            Time = 10
        })

        task.wait(1.5)

        local startRoomNumber = math.min(49, Script.LatestRoom.Value)
        while startRoomNumber >= 45 and startRoomNumber <= 49 do
            if shared.Library.Unloaded then break end
            
            Script.Functions.Minecart.debug("[Teleport] Teleporting to last node on room: " .. startRoomNumber)
            local GetRoom = workspace.CurrentRooms[startRoomNumber]
            local nodesList = PathfindGetNodes(GetRoom)
            local getLastNode = nodesList.real[#nodesList.real]

            repeat
                shared.RunService.RenderStepped:Wait()
                for _, minecart in pairs(minecartRigs) do
                    minecart.PrimaryPart.CFrame = getLastNode.CFrame
                end
            until GetRoom:WaitForChild("Door"):GetAttribute("Opened")
            GetRoom:SetAttribute("_mspaint_player_teleported", true)

            startRoomNumber += 1
            MinecartFound = true
            task.wait(1.2)
        end
        Script.Functions.Minecart.debug("[Teleport] Finished!")
    end
end

--External function to be called.
function Script.Functions.Minecart.DrawNodes(room: Model)
    local nodesList = PathfindGetNodes(room)
    if not nodesList then return end

    local espRealColor = if Toggles.MinecartPathVisualiser.Value then Script.MinecartPathNodeColor.Green else Script.MinecartPathNodeColor.Disabled

    --[ESP] Draw the real path
    for _, realNode in ipairs(nodesList.real) do
        changeNodeColor(realNode, espRealColor)
    end

    --[ESP] Draw the fake path
    -- for idx, fakeNode in ipairs(nodesList.fake) do
    --     changeNodeColor(fakeNode, MinecartPathNodeColor.Red)
    -- end
end

--@Return nil. Map the nodes in the __RunnerNodes__ and call features functions (@DrawNode; @Teleport).
function Script.Functions.Minecart.Pathfind(room: Model, forcePathfind: boolean)
    if not HasNodesToPathfind(room) then return end

    if not forcePathfind then
        --wait until SendRunnerNodes is trigged
        local pathTimeout = tick() + 5
        repeat task.wait()
        until #Script.Functions.Minecart.pathfindQueue > 0 or tick() > pathTimeout
        pcall(table.remove, Script.Functions.Minecart.pathfindQueue, 1)
    end

    local nodesFolder = room:FindFirstChild("RunnerNodes")
    if (nodesFolder == nil) then return end

    local nodes = nodesFolder:GetChildren()

    local numOfNodes = #nodes
    if numOfNodes <= 0 then return end 

    if HasAlreadyPathfind(nodesFolder) then return end
    Script.Functions.Minecart.debug("[Pathfind] Initialized pathfind for room: " .. room.Name .. " - nodes: ", numOfNodes)

    --[[
        Pathfind is a computational expensive process to make, 
        however we don't have node loops, 
        so we can ignore a few verifications.
        If you want to understand how this is working, search for "Pathfiding Algorithms"

        The shortest explanation i can give is that, this is a custom pathfinding to find "gaps" between
        nodes and creating "path" groups. With the groups estabilished we can make the correct validations.

        -Bacalhauz
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
    nodes = sortNodes(nodes, true)

    local _last = 1
    for i=_last+1, numOfNodes, 1 do
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
        if  (_currNodeTask == "Fake" or _currNodeTask == "End") and _lastNode then
            _gpID += 1
            stackNode[_gpID] = tGroupTrackNew()
            if _currNodeTask == "End" then
                stackNode[_gpID].hasEnd = true
            end
        end
        table.insert(stackNode[_gpID].nodes, nodeA)

        --Use this to debug the nodeTask
        Script.Functions.Minecart.debug(string.format("[%s] - [%s] Distance between: %s <--> %s ==> %.2f", _gpID, _currNodeTask, nodeA.Name, nodeB.Name, distance))

        _last = i
        --_lastNodeTask = _currNodeTask
    end
    stackNode[_gpID].hasStart = true --after the reversed path finding, the last group has the start node.
    table.insert(stackNode[_gpID].nodes, _startNode)
    --if we only have one group, means that there's no fake path.
    local hasMoreThanOneGroup = _gpID > 1

    local _closestNodes = {} --unwanted nodes if any
    local hasIncorrectPath = false -- if this is true, we're cooked. No path for you ):
    if hasMoreThanOneGroup then
        Script.Functions.Minecart.debug()
        for _gpI, v: tGroupTrack in ipairs(stackNode) do
            _closestNodes[_gpI] = {}
            Script.Functions.Minecart.debug(string.format("[TrackGroup] Group %s has %s nodes. \t Start: %s | End: %s", _gpI, #v.nodes, tostring(v.hasStart), tostring(v.hasEnd)))

            if _gpI <= 1 then continue end
            Script.Functions.Minecart.debug(string.format("[TrackGroup] Group %s was selected to deep pathfinding", _gpI))

            --Sort table for the normal flow, A -> B (was B -> A before)
            v.nodes = sortNodes(v.nodes, false)

            --Finally, perform the clean up by removing wrong nodes when a "distance jump" is found
            local _gplast = 1
            local hasNodeJump = false
            for _gpS=_gplast+1, #v.nodes, 1 do
                local nodeA: Part = v.nodes[_gplast]
                local nodeB: Part = v.nodes[_gpS]

                local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude

                hasNodeJump = (distance >= _longW)
                if not hasNodeJump then _gplast = _gpS continue end
                Script.Functions.Minecart.debug(string.format("[%s] Distance between %s <--> %s ==> %.2f", _gpI, nodeA.Name, nodeB.Name, distance))

                --Ok, we found a node jump, now we need to know what should be the closest node
                --table.remove(v.nodes, _gpS)
                Script.Functions.Minecart.debug(string.format("[TrackGroup] Group %s with, %s will find his closest node now.", _gpI, nodeB.Name))
                local nodeSearchPath = nodeB

                --Search again with the nodeSearchPath
                local closestDistance = math.huge

                local _gpFlast = #v.nodes
                for i=_gpFlast-1, 1, -1 do

                    local fnode = v.nodes[_gpFlast]
                    local Sdistance = (nodeSearchPath:GetPivot().Position - fnode:GetPivot().Position).Magnitude
                    _gpFlast = i

                    if Sdistance == 0.00 then continue end --node is self
                    Script.Functions.Minecart.debug(string.format("  [%s] DeepPath ==> Distance between %s <--> %s ==> %.2f", _gpI, nodeSearchPath.Name, fnode.Name, Sdistance))

                    if Sdistance <= closestDistance then
                        closestDistance = Sdistance
                        table.insert(_closestNodes[_gpI], fnode)
                        table.remove(v.nodes, _gpFlast+1)
                        continue
                    end
                    break
                end
                --table.insert(v.nodes, _gpS, nodeSearchPath)

                local _FoundAmount = #_closestNodes[_gpI]
                if _FoundAmount > 1 then 
                    Script.Functions.Minecart.debug(string.format("[TrackGroup] Group %s with, closest node is: %s ", _gpI, _closestNodes[_gpI][_FoundAmount].Name))
                else
                    warn(string.format("[TrackGroup] Group %s ERROR: Unable to find closest node, path is likely broken.", _gpI))
                    hasIncorrectPath = true
                end
                break
            end
            if not hasNodeJump then
                Script.Functions.Minecart.debug(string.format("[TrackGroup] Group %s has a correct path! ", _gpI))
            end
        end

        for _gpI, v: tGroupTrack in ipairs(stackNode) do
            Script.Functions.Minecart.debug(string.format("[TrackGroup -- VERIFY] Group %s has %s nodes. \t Start: %s | End: %s", _gpI, #v.nodes, tostring(v.hasStart), tostring(v.hasEnd)))
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
    --our result is stored in the part itself in order.

    local nodesList: tSortedNodes = {
        real = sortNodes(realNodes, false),
        fake = sortNodes(fakeNodes, false)
    }

    nodesFolder:SetAttribute("_mspaint_nodes_pathfind", true)
    PathfindSetNodes(nodesList.real, "_mspaint_real_node")
    PathfindSetNodes(nodesList.fake, "_mspaint_fake_node")
    --Call any feature that requires the pathfind nodes--

    Script.Functions.Minecart.DrawNodes(room)
    Script.Functions.Minecart.Teleport(room)
end