--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local Tabs = Script.Tabs

--// Floor \\--
if Script.IsHotel then
    local Hotel_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
        Hotel_AntiEntityGroupBox:AddToggle("AntiSeekObstructions", {
            Text = "Anti-Seek Obstructions",
            Default = false
        })
    end

    local Hotel_BypassGroupBox = Tabs.Floor:AddLeftGroupbox("Bypass") do
        Hotel_BypassGroupBox:AddToggle("AvoidRushAmbush", {
            Text = "Avoid Rush/Ambush",
            Tooltip = "Doesn't work for greenhouse :(",
            Default = false,
            Risky = true
        })
    end

    local Hotel_FarmGroupBox = Tabs.Floor:AddLeftGroupbox("Farm") do
        Hotel_FarmGroupBox:AddToggle("KnobFarm", {
            Text = "Knob Farm",
            Tooltip = "Only works in Room 100 and figure is spawned",
            Default = false
        })
    end

    local Hotel_ModifiersGroupBox = Tabs.Floor:AddRightGroupbox("Modifiers") do
        Hotel_ModifiersGroupBox:AddToggle("NoVoiceActing", {
            Text = "No Voice Acting",
            Default = false
        })

        Hotel_ModifiersGroupBox:AddToggle("AntiA90", {
            Text = "Anti-A90",
            Default = false
        })

        Hotel_ModifiersGroupBox:AddToggle("NoJammin", {
            Text = "No Jammin",
            Default = false
        })
    end

    Toggles.AntiSeekObstructions:OnChanged(function(value)
        for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                for _, obj in pairs(v:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanTouch = not value end
                end
            end
        end
    end)

    Toggles.KnobFarm:OnChanged(function(value)
        local reviveCutscene = shared.ReplicatedStorage:FindFirstChild("ReviveCutscene", true) or shared.ReplicatedStorage:FindFirstChild("_ReviveCutscene", true)
    
        if reviveCutscene then
            reviveCutscene.Name = if value then "_ReviveCutscene" else "ReviveCutscene"
        end

        if value then
            task.spawn(function()
                while task.wait(0.25) and Toggles.KnobFarm.Value and not shared.Library.Unloaded do
                    repeat task.wait() until Script.LatestRoom.Value == 100 or not (Toggles.KnobFarm.Value and not shared.Library.Unloaded)
                    if not (Toggles.KnobFarm.Value and not shared.Library.Unloaded) then break end

                    if not Script.Alive then
                        Script.RemotesFolder.Revive:FireServer()
                        repeat task.wait(0.1) until Script.Alive
                    end

                    local figure = workspace.CurrentRooms:FindFirstChild("FigureRig", true)
                    if figure then
                        repeat
                            task.wait()
                            shared.Character:PivotTo(figure.Root.CFrame)
                        until not Script.Alive or not (Toggles.KnobFarm.Value and not shared.Library.Unloaded)
                        if not (Toggles.KnobFarm.Value and not shared.Library.Unloaded) then break end

                        task.wait()
                        Script.RemotesFolder.Statistics:FireServer()
                    end
                end
            end)
        end
    end)

    Toggles.NoVoiceActing:OnChanged(function(value)
        local voiceActing = shared.ReplicatedStorage:FindFirstChild("VoiceActing")
        if not voiceActing then return end

        local voicelines = voiceActing:FindFirstChild("Voicelines") or voiceActing:FindFirstChild("_Voicelines")
        if voicelines then
            voicelines.Name = if value then "_Voicelines" else "Voicelines"
        end
    end)

    Toggles.AntiA90:OnChanged(function(value)
        if not Script.MainGame then return end
        local module = Script.MainGame:FindFirstChild("A90", true) or Script.MainGame:FindFirstChild("_A90", true)
    
        if module then
            module.Name = value and "_A90" or "A90"
        end
    end)

    Toggles.NoJammin:OnChanged(function(value)
        if not Script.LiveModifiers:FindFirstChild("Jammin") then return end

        if Script.MainGame then
            local jamSound = Script.MainGame:FindFirstChild("Jam", true)
            if jamSound then jamSound.Playing = not value end
        end

        local jamminEffect = shared.SoundService:FindFirstChild("Jamming", true)
        if jamminEffect then jamminEffect.Enabled = not value end
    end)
elseif Script.IsMines then
    local Mines_MovementGroupBox = Tabs.Floor:AddLeftGroupbox("Movement") do
        Mines_MovementGroupBox:AddSlider("MaxSlopeAngle", {
            Text = "Max Floor Angle",
            Default = 45,
            Min = 0,
            Max = 90,
            Rounding = 0
        })
    end

    local Mines_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
        Mines_AntiEntityGroupBox:AddToggle("AntiGiggle", {
            Text = "Anti-Giggle",
            Default = false
        })

        Mines_AntiEntityGroupBox:AddToggle("AntiGloomEgg", {
            Text = "Anti-Gloom Egg",
            Default = false
        })

        Mines_AntiEntityGroupBox:AddToggle("AntiBridgeFall", {
            Text = "Anti-Bridge Fall",
            Default = false
        })

        Mines_AntiEntityGroupBox:AddToggle("AntiPipeGap", {
            Text = "Anti-Pipe Gap",
            Default = false
        })

        Mines_AntiEntityGroupBox:AddToggle("AntiSeekFlood", {
            Text = "Anti-Seek Flood",
            Default = false
        })
    end

    local Mines_AutomationGroupBox = Tabs.Floor:AddRightGroupbox("Automation") do
        Mines_AutomationGroupBox:AddButton({
            Text = "Beat Door 200",
            Func = function()
                if Script.LatestRoom.Value < 99 then
                    shared.Notify:Alert({
                        Title = "Beat Door 200",
                        Description = "You haven't reached door 200...",
                        Time = 5
                    })

                    return
                end

                local bypassing = Toggles.SpeedBypass.Value
                local startPos = shared.RootPart.CFrame

                Toggles.SpeedBypass:SetValue(false)

                local damHandler = workspace.CurrentRooms[Script.LatestRoom.Value]:FindFirstChild("_DamHandler")

                if damHandler then
                    if damHandler:FindFirstChild("PlayerBarriers1") then
                        for _, pump in pairs(damHandler.Flood1.Pumps:GetChildren()) do
                            shared.Character:PivotTo(pump.Wheel.CFrame)
                            task.wait(0.25)
                            shared.forcefireproximityprompt(pump.Wheel.ValvePrompt)
                            task.wait(0.25)
                        end

                        task.wait(8)
                    end

                    if damHandler:FindFirstChild("PlayerBarriers2") then
                        for _, pump in pairs(damHandler.Flood2.Pumps:GetChildren()) do
                            shared.Character:PivotTo(pump.Wheel.CFrame)
                            task.wait(0.25)
                            shared.forcefireproximityprompt(pump.Wheel.ValvePrompt)
                            task.wait(0.25)
                        end

                        task.wait(8)
                    end

                    if damHandler:FindFirstChild("PlayerBarriers3") then
                        for _, pump in pairs(damHandler.Flood3.Pumps:GetChildren()) do
                            shared.Character:PivotTo(pump.Wheel.CFrame)
                            task.wait(0.25)
                            shared.forcefireproximityprompt(pump.Wheel.ValvePrompt)
                            task.wait(0.25)
                        end

                        task.wait(10)
                    end
                end

                local generator = workspace.CurrentRooms[shared.LatestRoom.Value]:FindFirstChild("MinesGenerator", true)

                if generator then
                    shared.Character:PivotTo(generator.PrimaryPart.CFrame)
                    task.wait(0.25)
                    shared.forcefireproximityprompt(generator.Lever.LeverPrompt)
                    task.wait(0.25)
                end

                Toggles.SpeedBypass:SetValue(bypassing)
                shared.Character:PivotTo(startPos)
            end
        })

        Mines_AutomationGroupBox:AddToggle("TheMinesAnticheatBypass", {
            Text = "Anticheat Bypass",
            Default = false
        })
    end

    local Mines_BypassGroupBox = Tabs.Floor:AddRightGroupbox("Bypass") do
        Mines_BypassGroupBox:AddToggle("MinecartTeleport", {
            Text = "Minecart Teleport",
            Default = false
        })

        Mines_BypassGroupBox:AddToggle("MinecartTeleportDebug", {
            Text = "Minecart Teleport Debug",
            Default = false,
            Visible = false,
        })
    end
    
    local Mines_VisualGroupBox = Tabs.Floor:AddRightGroupbox("Visuals") do
        Mines_VisualGroupBox:AddToggle("MinecartPathVisualiser", {
            Text = "Visualize Correct Seek Path",
            Default = false
        })
    end

    Toggles.TheMinesAnticheatBypass:OnChanged(function(value)
        if value then
            local progressPart = Instance.new("Part", shared.Workspace) do
                progressPart.Anchored = true
                progressPart.CanCollide = false
                progressPart.Name = "_internal_mspaint_acbypassprogress"
                progressPart.Transparency = 1
            end

            if shared.Library.IsMobile then
                shared.Notify:Alert({
                    Title = "Anticheat bypass",
                    Description = "To bypass the ac, you must interact with a ladder.",
                    Reason = "Ladder ESP has been enabled, do not move while on the ladder.",

                    LinoriaMessage = "To bypass the anticheat, you must interact with a ladder. Ladder ESP has been enabled.\nDo not move while on the ladder.",
                    Time = progressPart
                })
            else
                shared.Notify:Alert({
                    Title = "Anticheat bypass",
                    Description = "To bypass the ac, you must interact with a ladder.",
                    Reason = "Ladder ESP has been enabled, do not move while on the ladder.",

                    LinoriaMessage = "To bypass the anticheat, you must interact with a ladder. Ladder ESP has been enabled.\nDo not move while on the ladder.",
                    Time = progressPart
                })
            end
            

            -- Ladder ESP
            for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                if v:IsA("Model") and v.Name == "Ladder" then
                    Script.Functions.ESP({
                        Type = "None",
                        Object = v,
                        Text = "Ladder",
                        Color = Color3.new(0, 0, 1)
                    })
                end
            end
        else
            if workspace:FindFirstChild("_internal_mspaint_acbypassprogress") then workspace:FindFirstChild("_internal_mspaint_acbypassprogress"):Destroy() end

            for _, ladderEsp in pairs(Script.ESPTable.None) do
                ladderEsp.Destroy()
            end

            if Script.Bypassed and not Script.FakeRevive.Enabled then
                Script.RemotesFolder.ClimbLadder:FireServer()
                Script.Bypassed = false
                
                Options.WalkSpeed:SetMax(Toggles.SpeedBypass.Value and 75 or (Toggles.EnableJump.Value and 18 or 22))
                Options.FlySpeed:SetMax(Toggles.SpeedBypass.Value and 75 or 22)
            end
        end
    end)

    Options.MaxSlopeAngle:OnChanged(function(value)
        if shared.Humanoid then
            shared.Humanoid.MaxSlopeAngle = value
        end
    end)

    Toggles.AntiGiggle:OnChanged(function(value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, giggle in pairs(room:GetChildren()) do
                if giggle.Name == "GiggleCeiling" then
                    giggle:WaitForChild("Hitbox", 5).CanTouch = not value
                end
            end
        end
    end)

    -- this shits bad, but it doesnt go through all parts, so its optimized :cold_face:
    Toggles.AntiGloomEgg:OnChanged(function(value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, gloomPile in pairs(room:GetChildren()) do
                if gloomPile.Name == "GloomPile" then
                    for _, gloomEgg in pairs(gloomPile:GetDescendants()) do
                        if gloomEgg.Name == "Egg" then
                            gloomEgg.CanTouch = not value
                        end
                    end
                end
            end
        end
    end)

    Toggles.AntiBridgeFall:OnChanged(function(value)
        if value then
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if not room:FindFirstChild("Parts") then continue end

                for _, bridge in pairs(room.Parts:GetChildren()) do
                    if bridge.Name == "Bridge" then
                        for _, barrier in pairs(bridge:GetChildren()) do
                            if not (barrier.Name == "PlayerBarrier" and barrier.Size.Y == 2.75 and (barrier.Rotation.X == 0 or barrier.Rotation.X == 180)) then continue end

                            local clone = barrier:Clone()
                            clone.CFrame = clone.CFrame * CFrame.new(0, 0, -5)
                            clone.Color = Color3.new(1, 1, 1)
                            clone.Name = "AntiBridge"
                            clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, 11)
                            clone.Transparency = 0
                            clone.Parent = bridge
                            
                            table.insert(Script.Temp.Bridges, clone)
                        end
                    end
                end
            end
        else
            for _, bridge in pairs(Script.Temp.Bridges) do
                bridge:Destroy()
            end
        end
    end)

    Toggles.AntiPipeGap:OnChanged(function(value)
        if value then
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if not room:FindFirstChild("Assets") then continue end

                for _, killBrick in pairs(room.Assets:GetChildren()) do
                    if killBrick.Name == "KillBrick" then
                        local clone = killBrick:Clone()
                        clone.Color = Color3.new(1, 1, 1)
                        clone.Name = "AntiPipeGap"
                        clone.Position += Vector3.new(0, 20, 0)
                        clone.Size = Vector3.new(9, 4, clone.Size.Z)
                        clone.Transparency = 0
                        clone.Parent = killBrick.Parent
                        
                        table.insert(Script.Temp.PipeBridges, clone)
                    end
                end
            end
        else
            for _, bridge in pairs(Script.Temp.PipeBridges) do
                bridge:Destroy()
            end
        end
    end)

    Toggles.AntiSeekFlood:OnChanged(function(value)
        local room = workspace.CurrentRooms:FindFirstChild("100")
        
        if room and room:FindFirstChild("_DamHandler") then
            local seekFlood = room._DamHandler:FindFirstChild("SeekFloodline")
            if seekFlood then
                seekFlood.CanCollide = value
            end
        end
    end)

    Toggles.MinecartPathVisualiser:OnChanged(function(value)
        Script.Functions.Minecart.DrawNodes()
    end)
elseif Script.IsBackdoor then
    local Backdoors_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
        Backdoors_AntiEntityGroupBox:AddToggle("AntiHasteJumpscare", {
            Text = "Anti Haste Jumpscare",
            Default = false
        })
    end

    local Backdoors_VisualGroupBox = Tabs.Floor:AddRightGroupbox("Visual") do
        Backdoors_VisualGroupBox:AddToggle("HasteClock", {
            Text = "Haste Clock",
            Default = true
        })
    end

    Toggles.AntiHasteJumpscare:OnChanged(function(value)
        local clientRemote = shared.ReplicatedStorage.FloorReplicated.ClientRemote
        local internal_temp_mspaint = clientRemote:FindFirstChild("_mspaint")
        
        if not internal_temp_mspaint then internal_temp_mspaint = Instance.new("Folder", clientRemote); internal_temp_mspaint.Name = "_mspaint" end

        if value then
            for i,v in pairs(clientRemote.Haste:GetChildren()) do
                if v:IsA("RemoteEvent") then continue end

                v.Parent = internal_temp_mspaint
            end
        else
            for i,v in pairs(internal_temp_mspaint:GetChildren()) do
                v.Parent = clientRemote.Haste
            end
        end
    end)

    Toggles.HasteClock:OnChanged(function(value)
        if not value then
            Script.Functions.HideCaptions()
        end
    end)

    function Script.Functions.TimerFormat(seconds: number)
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        return string.format("%02d:%02d", minutes, remainingSeconds)
    end

    shared.Connect:GiveSignal(Script.FloorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(function()
        if Toggles.HasteClock.Value and Script.FloorReplicated.ScaryStartsNow.Value then
            Script.Functions.Captions(Script.Functions.TimerFormat(Script.FloorReplicated.DigitalTimer.Value))
        end
    end))
elseif Script.IsRooms then
    local Rooms_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
        Rooms_AntiEntityGroupBox:AddToggle("AntiA90", {
            Text = "Anti-A90",
            Default = false
        })
    end

    local Rooms_AutomationGroupBox = Tabs.Floor:AddRightGroupbox("Automation") do
        Rooms_AutomationGroupBox:AddToggle("AutoRooms", {
            Text = "Auto Rooms",
            Default = false
        })

        Rooms_AutomationGroupBox:AddLabel("Recommended Settings:\nSpeed Bypass and Noclip disabled", true)

        Rooms_AutomationGroupBox:AddDivider()

        Rooms_AutomationGroupBox:AddToggle("AutoRoomsDebug", { 
            Text = "Show Debug Info",
            Default = false
        })
        
        Rooms_AutomationGroupBox:AddToggle("ShowAutoRoomsPathNodes", { 
            Text = "Show Pathfinding Nodes",
            Default = false
        })

    end

    Toggles.AntiA90:OnChanged(function(value)
        if Toggles.AutoRooms.Value and not value then
            shared.Notify:Alert({
                Title = "Auto Rooms",
                Description = "Anti A-90 is required for Auto Rooms to work!",
                Reason = "Anti A-90 has been enabled",
            })
            
            Toggles.AntiA90:SetValue(true)
        end

        if not Script.MainGame then return end
        local module = Script.MainGame:FindFirstChild("A90", true) or Script.MainGame:FindFirstChild("_A90", true)
    
        if module then
            module.Name = value and "_A90" or "A90"
        end
    end)

    function Script.Functions.GetAutoRoomsPathfindingGoal(): BasePart
        local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
        if entity and entity.PrimaryPart.Position.Y > -10 then
            local GoalLocker = Script.Functions.GetNearestAssetWithCondition(function(asset)
                return asset.Name == "Rooms_Locker" and not asset.HiddenPlayer.Value and asset.PrimaryPart.Position.Y > -10
            end)

            return GoalLocker.PrimaryPart
        end

        return workspace.CurrentRooms[Script.LatestRoom.Value].RoomExit
    end

    local _internal_mspaint_pathfinding_nodes = Instance.new("Folder", shared.Workspace) do
        _internal_mspaint_pathfinding_nodes.Name = "_internal_mspaint_pathfinding_nodes"
    end

    local _internal_mspaint_pathfinding_block = Instance.new("Folder", shared.Workspace) do
        _internal_mspaint_pathfinding_block.Name = "_internal_mspaint_pathfinding_block"
    end

    Toggles.ShowAutoRoomsPathNodes:OnChanged(function(value)
        for _, node in pairs(_internal_mspaint_pathfinding_nodes:GetChildren()) do
            node.Transparency = value and 0.5 or 1
        end
        for _, nodeBlock in pairs(_internal_mspaint_pathfinding_block:GetChildren()) do
            nodeBlock.Transparency = value and 0.9 or 1
        end
    end)

    shared.Connect:GiveSignal(shared.RunService.RenderStepped:Connect(function()
        if not Toggles.AutoRooms.Value then return end

        local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
        local isEntitySpawned = (entity and entity.PrimaryPart.Position.Y > -10)
        
        if isEntitySpawned and not shared.RootPart.Anchored then
            local pathfindingGoal = Script.Functions.GetAutoRoomsPathfindingGoal()

            if Script.Functions.IsPromptInRange(pathfindingGoal.Parent.HidePrompt) then
                shared.forcefireproximityprompt(pathfindingGoal.Parent.HidePrompt)
            end
        elseif not isEntitySpawned and shared.RootPart.Anchored then
            for i = 1, 10 do
                Script.RemotesFolder.CamLock:FireServer()
            end
        end
    end))

    Toggles.AutoRooms:OnChanged(function(value)
        local hasResetFailsafe = false

        local function nodeCleanup()
            _internal_mspaint_pathfinding_nodes:ClearAllChildren()
            _internal_mspaint_pathfinding_block:ClearAllChildren()
            hasResetFailsafe = true
        end

        local function moveToCleanup()
            if shared.Humanoid then
                shared.Humanoid:Move(shared.RootPart.Position)
                shared.Humanoid.WalkToPart = nil
                shared.Humanoid.WalkToPoint = shared.RootPart.Position
            end
            nodeCleanup()
        end

        if value then
            Toggles.AntiA90:SetValue(true)
            local lastRoomValue = 0

            local function createNewBlockedPoint(point: PathWaypoint)
                local block = Instance.new("Part", _internal_mspaint_pathfinding_block)
                local pathMod = Instance.new("PathfindingModifier", block)
                pathMod.Label = "_ms_pathBlock"

                block.Name = "_mspaint_blocked_path"
                block.Shape = Enum.PartType.Block

                local sizeY = 10
                
                block.Size = Vector3.new(1, sizeY, 1)
                block.Color = Color3.fromRGB(255, 130, 30)
                block.Material = Enum.Material.Neon
                block.Position = point.Position + Vector3.new(0, sizeY / 2, 0)
                block.Anchored = true
                block.CanCollide = false
                block.Transparency = Toggles.ShowAutoRoomsPathNodes.Value and 0.9 or 1
            end

            local function doAutoRooms()
                local pathfindingGoal = Script.Functions.GetAutoRoomsPathfindingGoal()

                if Script.LatestRoom.Value ~= lastRoomValue then
                    _internal_mspaint_pathfinding_block:ClearAllChildren()
                    lastRoomValue = Script.LatestRoom.Value
                end
                
                shared.Notify:Log({
                    Title = "Auto Rooms",
                    Description = "Calculated Objective Successfully!\nObjective: " .. pathfindingGoal.Parent.Name .. "\nCreating path...",
                }, Toggles.AutoRoomsDebug.Value)

                local path = shared.PathfindingService:CreatePath({
                    AgentCanJump = false,
                    AgentCanClimb = false,
                    WaypointSpacing = 2,
                    AgentRadius = 1,
                    Costs = {
                        _ms_pathBlock = 8 --cost will increase the more stuck you get.
                    }
                })

                shared.Notify:Log({
                    Title = "Auto Rooms",
                    Description = "Computing Path to " .. pathfindingGoal.Parent.Name .. "...",
                }, Toggles.AutoRoomsDebug.Value)

                path:ComputeAsync(shared.RootPart.Position - Vector3.new(0, 2.5, 0), pathfindingGoal.Position)
                local waypoints = path:GetWaypoints()
                local waypointAmount = #waypoints

                if path.Status == Enum.PathStatus.Success then
                    hasResetFailsafe = true
                    task.spawn(function()
                        task.wait(0.1)
                        hasResetFailsafe = false
                        if shared.Humanoid and Script.Collision then
                            local checkFloor = shared.Humanoid.FloorMaterial
                            local isStuck = checkFloor == Enum.Material.Air or checkFloor == Enum.Material.Concrete
                            if isStuck then
                                repeat task.wait()
                                    Script.Collision.CanCollide = false
                                    Script.Collision.CollisionCrouch.CanCollide = true
                                until not isStuck or hasResetFailsafe
                                Script.Collision.CanCollide = true
                            end
                            hasResetFailsafe = true
                        end
                    end)

                    shared.Notify:Log({
                        Title = "Auto Rooms",
                        Description = "Computed path successfully with " .. waypointAmount .. " waypoints!",
                    }, Toggles.AutoRoomsDebug.Value)

                    _internal_mspaint_pathfinding_nodes:ClearAllChildren()

                    for i, waypoint in pairs(waypoints) do
                        local node = Instance.new("Part", _internal_mspaint_pathfinding_nodes) do
                            node.Name = "_internal_node_" .. i
                            node.Size = Vector3.new(1, 1, 1)
                            node.Position = waypoint.Position
                            node.Anchored = true
                            node.CanCollide = false
                            node.Shape = Enum.PartType.Ball
                            node.Color = Color3.new(1, 0, 0)
                            node.Transparency = Toggles.ShowAutoRoomsPathNodes.Value and 0.5 or 1
                        end
                    end

                    local lastWaypoint = nil
                    for i, waypoint in pairs(waypoints) do
                        local moveToFinished = false
                        local recalculate = false
                        local waypointConnection = shared.Humanoid.MoveToFinished:Connect(function() moveToFinished = true end)
                        if not moveToFinished or not Toggles.AutoRooms.Value then
                            shared.Humanoid:MoveTo(waypoint.Position)
                            
                            local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
                            local isEntitySpawned = (entity and entity.PrimaryPart.Position.Y > -10)

                            if isEntitySpawned and not shared.RootPart.Anchored and pathfindingGoal.Parent.Name ~= "Rooms_Locker" then
                                waypointConnection:Disconnect()

                                if not Toggles.AutoRooms.Value then
                                    nodeCleanup()
                                    break
                                else
                                    if _internal_mspaint_pathfinding_nodes:FindFirstChild("_internal_node_" .. i) then
                                        _internal_mspaint_pathfinding_nodes:FindFirstChild("_internal_node_" .. i):Destroy()
                                    end
                                end

                                break
                            end

                            task.delay(1.5, function()
                                if moveToFinished then return end
                                if (not Toggles.AutoRooms.Value or shared.Library.Unloaded) then return moveToCleanup() end

                                repeat task.wait(0.25) until (not shared.Character:GetAttribute("Hiding") and not shared.Character.PrimaryPart.Anchored)

                                shared.Notify:Alert({
                                    Title = "Auto Rooms",
                                    Description = "Seems like you are stuck, trying to recalculate path...",
                                    Reason = "Failed to move to waypoint",
                                })

                                recalculate = true
                                if lastWaypoint == nil and waypointAmount > 1 then
                                    waypoint = waypoints[i+1]
                                else
                                    waypoint = waypoints[i-1]
                                end

                                createNewBlockedPoint(waypoint)
                            end)
                        end

                        repeat task.wait() until moveToFinished or not Toggles.AutoRooms.Value or recalculate or shared.Library.Unloaded
                        lastWaypoint = waypoint

                        waypointConnection:Disconnect()

                        if not Toggles.AutoRooms.Value then
                            nodeCleanup()
                            break
                        else
                            if _internal_mspaint_pathfinding_nodes:FindFirstChild("_internal_node_" .. i) then
                                _internal_mspaint_pathfinding_nodes:FindFirstChild("_internal_node_" .. i):Destroy()
                            end
                        end

                        if recalculate then break end
                    end
                else
                    shared.Notify:Log({
                        Title = "Auto Rooms",
                        Description = "Pathfinding failed with status " .. tostring(path.Status)   
                    }, Toggles.AutoRoomsDebug.Value)
                end
            end

            -- Movement
            while Toggles.AutoRooms.Value and not shared.Library.Unloaded do
                if Script.LatestRoom.Value == 1000 then
                    shared.Notify:Alert({
                        Title = "Auto Rooms",
                        Description = "You have reached A-1000",
                        Reason = "A-1000 reached by mspaint autorooms",
                    })

                    break
                end

                doAutoRooms()
            end
            
            -- Unload Auto Rooms
            moveToCleanup()
        end
    end)
elseif Script.IsFools then
    local Fools_TrollingGroupBox = Tabs.Floor:AddLeftGroupbox("Trolling") do
        Fools_TrollingGroupBox:AddToggle("GrabBananaJeffToggle",{
            Text = "Grab Banana / Jeff",
            Default = false
        }):AddKeyPicker("GrabBananaJeff", {
            Default = "H",
            Mode = "Hold",
            Text = "Grab Banana / Jeff",
        })
    
        Fools_TrollingGroupBox:AddLabel("Throw"):AddKeyPicker("ThrowBananaJeff", {
            Default = "G",
            Mode = "Hold",
            Text = "Throw"
        })

        Fools_TrollingGroupBox:AddSlider("ThrowStrength", {
            Text = "Throw Strength",
            Default = 1,
            Min = 1,
            Max = 10,
            Rounding = 1,
            Compact = true
        })

        function Script.Functions.ThrowBananaJeff()
            local target = Script.Temp.HoldingItem

            Script.Tracks.ItemHoldTrack:Stop()
            Script.Tracks.ItemThrowTrack:Play()

            task.wait(0.35)

            if target:FindFirstChildWhichIsA("BodyGyro") then
                target:FindFirstChildWhichIsA("BodyGyro"):Destroy()
            end

            local velocity = shared.LocalPlayer:GetMouse().Hit.LookVector * 0.5 * 200 * Options.ThrowStrength.Value
            local spawnPos = shared.Camera.CFrame:ToWorldSpace(CFrame.new(0,0,-3) * CFrame.lookAt(Vector3.new(0, 0, 0), shared.Camera.CFrame.LookVector))
            
            target.CFrame = spawnPos
            target.Velocity = velocity

            if target:FindFirstAncestorWhichIsA("Model").Name == "JeffTheKiller" then
                for _,i in ipairs(target:FindFirstAncestorWhichIsA("Model"):GetDescendants()) do
                    if i:IsA("BasePart") then
                        i.CanTouch = not Toggles.AntiJeffClient.Value
                        i.CanCollide = i:GetAttribute("Clip") or true
                    end
                end
            else
                target.CanTouch = not Toggles.AntiBananaPeel.Value
                target.CanCollide = target:GetAttribute("Clip") or true
            end

            Script.Temp.HoldingItem = nil
        end
    end

    local Fools_AntiEntityGroupBox = Tabs.Floor:AddRightGroupbox("Anti-Entity") do
        Fools_AntiEntityGroupBox:AddToggle("AntiSeekObstructions", {
            Text = "Anti-Seek Obstructions",
            Default = false
        })

        Fools_AntiEntityGroupBox:AddToggle("AntiBananaPeel", {
            Text = "Anti-Banana",
            Default = false
        })

        Fools_AntiEntityGroupBox:AddToggle("AntiJeffClient", {
            Text = "Anti-Jeff",
            Default = false
        })
    end

    local Fools_BypassGroupBox = Tabs.Floor:AddRightGroupbox("Bypass") do
        Fools_BypassGroupBox:AddToggle("InfRevives", {
            Text = "Infinite Revives",
            Default = false
        })

        Fools_BypassGroupBox:AddToggle("AntiJeffServer", {
            Text = "Anti-Jeff (FE)",
            Default = false
        })

        Fools_BypassGroupBox:AddDivider()

        Fools_BypassGroupBox:AddToggle("GodmodeNoclipBypassFools", {
            Text = "Godmode",
            Default = false
        })

        Fools_BypassGroupBox:AddToggle("FigureGodmodeFools", {
            Text = "Figure Godmode",
            Default = false
        })
    end

    Toggles.AntiSeekObstructions:OnChanged(function(value)
        for i, v in pairs(workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                for _, obj in pairs(v:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanTouch = not value end
                end
            end
        end
    end)
    
    Toggles.AntiBananaPeel:OnChanged(function(value)
        for _, peel in pairs(workspace:GetChildren()) do
            if peel.Name == "BananaPeel" then
                peel.CanTouch = not value
            end
        end
    end)

    Toggles.AntiJeffClient:OnChanged(function(value)
        for _, jeff in pairs(workspace:GetChildren()) do
            if jeff:IsA("Model") and jeff.Name == "JeffTheKiller" then
                for i, v in pairs(jeff:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = not value
                    end
                end
            end
        end
    end)

    Toggles.AntiJeffServer:OnChanged(function(value)
        if value then
            for _, jeff in pairs(workspace:GetChildren()) do
                if jeff:IsA("Model") and jeff.Name == "JeffTheKiller" then
                    task.spawn(function()
                        repeat task.wait() until shared.isnetworkowner(jeff.PrimaryPart)
                        jeff:FindFirstChildOfClass("Humanoid").Health = 0
                    end)
                end
            end
        end
    end)

    Toggles.InfRevives:OnChanged(function(value)
        if value and not shared.LocalPlayer:GetAttribute("Alive") then
            Script.RemotesFolder.Revive:FireServer()
        end
    end)

    Toggles.GodmodeNoclipBypassFools:OnChanged(function(value)
        if value and shared.Humanoid and Script.Collision then
            shared.Humanoid.HipHeight = 3.01
            task.wait()
            Script.Collision.Position = Script.Collision.Position - Vector3.new(0, 8, 0)
            task.wait()
            shared.Humanoid.HipHeight = 3
            
            -- don't want to put collision up when you load the script 
            -- im sorry deivid
            task.spawn(function()
                repeat task.wait() until not Toggles.GodmodeNoclipBypassFools.Value
                shared.Humanoid.HipHeight = 3.01
                task.wait()
                Script.Collision.Position = Script.Collision.Position + Vector3.new(0, 8, 0)
                task.wait()
                shared.Humanoid.HipHeight = 3
            end)
        end
    end)

    Toggles.FigureGodmodeFools:OnChanged(function(value)
        if value and not Toggles.GodmodeNoclipBypassFools.Value then Toggles.GodmodeNoclipBypassFools:SetValue(true); shared.Notify:Alert({Title = "Figure Godmode", Description = "Godmode/Noclip Bypass is required to use figure godmode", Reason = "Godmode/Noclip Bypass not enabled"}) end
        if Script.LatestRoom.Value ~= 50 or Script.LatestRoom.Value ~= 100 then return end

        for _, figure in pairs(workspace.CurrentRooms:GetDescendants()) do
            if figure:IsA("Model") and figure.Name == "FigureRagdoll" then
                for i, v in pairs(figure:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if not v:GetAttribute("Clip") then v:SetAttribute("Clip", v.CanCollide) end

                        v.CanTouch = not value
                        v.CanCollide = not value
                    end
                end
            end
        end
    end)
end