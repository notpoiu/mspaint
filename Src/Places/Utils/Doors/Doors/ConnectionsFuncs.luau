--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.CameraCheck(child)
    if child:IsA("BasePart") and child.Name == "Guidance" and Toggles.GuidingLightESP.Value then
        Script.Functions.GuidingLightEsp(child)
    end
end

function Script.Functions.SetupCameraConnection(camera)
    for _, child in pairs(camera:GetChildren()) do
        task.spawn(Script.Functions.CameraCheck, child)
    end

    shared.Connections["CameraChildAdded"] = camera.ChildAdded:Connect(function(child)
        task.spawn(Script.Functions.CameraCheck, child)
    end)
end

function Script.Functions.SetupCurrentRoomConnection(room)
    if shared.Connections["CurrentRoom"] then
        shared.Connections["CurrentRoom"]:Disconnect()
    end

    shared.Connections["CurrentRoom"] = room.DescendantAdded:Connect(function(child)
        if not Toggles.ItemESP or not Toggles.GoldESP then return end

        if Toggles.ItemESP ~= nil then
            if Toggles.ItemESP.Value and Script.Functions.ItemCondition(child) then
                Script.Functions.ItemESP(child)
            end
        end

        if Toggles.GoldESP ~= nil then
            if Toggles.GoldESP.Value and child.Name == "GoldPile" then
                Script.Functions.GoldESP(child)
            end
        end
    end)
end

function Script.Functions.SetupRoomConnection(room)
    if Options.NotifyEntity ~= nil then
        if Options.NotifyEntity.Value["Halt Room"] and room:GetAttribute("RawName") == "HaltHallway" then
            shared.Notify:Alert({
                Title = "ENTITIES",
                Description = "Halt will spawn in next room!",
                Image = Script.EntityTable.NotifyReason["HaltRoom"].Image,

                Warning = true
            })
        end
    end

    for _, child in pairs(room:GetDescendants()) do
        if Toggles.DeleteSeek ~= nil then
            task.spawn(function()
                if Toggles.DeleteSeek.Value and shared.RootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
        end

        task.spawn(Script.Functions.ChildCheck, child)
    end

    shared.Connections[room.Name .. "DescendantAdded"] = room.DescendantAdded:Connect(function(child)
        if Toggles.DeleteSeek ~= nil then
            task.spawn(function()
                if Toggles.DeleteSeek.Value and shared.RootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
        end

        task.delay(0.1, Script.Functions.ChildCheck, child)
    end)
end

function Script.Functions.SetupDropConnection(drop)
    if Toggles.ItemESP ~= nil and Toggles.ItemESP.Value then
        Script.Functions.ItemESP(drop, true)
    end

    task.spawn(function()
        local prompt = drop:WaitForChild("ModulePrompt", 3)

        if prompt then
            table.insert(Script.PromptTable.GamePrompts, prompt)
        end
    end)
end

function Script.Functions.SetupCharacterConnection(newCharacter)
    shared.Character = newCharacter
    if shared.Character then
        if Toggles.EnableJump ~= nil and Toggles.EnableJump.Value then
            shared.Character:SetAttribute("CanJump", true)
        end

        for _, oldConnection in pairs(Script.FeatureConnections.Character) do
            oldConnection:Disconnect()
        end

        Script.FeatureConnections.Character["ChildAdded"] = shared.Character.ChildAdded:Connect(function(child)
            if not (child:IsA("Tool") and child.Name:match("LibraryHintPaper")) then return end

            task.wait(0.1)
            local code = Script.Functions.GetPadlockCode(child)
            local output, count = string.gsub(code, "_", "x")
            local padlock = workspace:FindFirstChild("Padlock", true)

            if Options.AutoLibraryDistance ~= nil and Toggles.AutoLibrarySolver ~= nil then
                if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                    Script.RemotesFolder.PL:FireServer(code)
                end
            end

            if (Toggles.NotifyPadlock ~= nil and Toggles.NotifyPadlock.Value) and count < 5 then
                shared.Notify:Alert({
                    Title = "Padlock Code",
                    Description = string.format("Library Code: %s", output),
                    Reason = if tonumber(code) then "Solved the library padlock code" else "You are still missing some books",
                })

                if Toggles.NotifyChat ~= nil and Toggles.NotifyChat.Value and count == 0 then
                    shared.RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                end
            end
        end)

        Script.FeatureConnections.Character["CanJump"] = shared.Character:GetAttributeChangedSignal("CanJump"):Connect(function()
            if not Toggles.EnableJump then return end
            if not Toggles.EnableJump.Value then return end

            if not shared.Character:GetAttribute("CanJump") then
                shared.Character:SetAttribute("CanJump", true)
            end
        end)

        Script.FeatureConnections.Character["Crouching"] = shared.Character:GetAttributeChangedSignal("Crouching"):Connect(function()
            if not Toggles.AntiHearing then return end
            if not Toggles.AntiHearing.Value then return end

            if not shared.Character:GetAttribute("Crouching") then
                Script.RemotesFolder.Crouch:FireServer(true)
            end
        end)

        Script.FeatureConnections.Character["Hiding"] = shared.Character:GetAttributeChangedSignal("Hiding"):Connect(function()
            if not shared.Character:GetAttribute("Hiding") then return end
            if not Toggles.TranslucentHidingSpot or not Options.HidingTransparency then return end
            if not Toggles.TranslucentHidingSpot.Value then return end

            for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end

                if obj.Value == shared.Character then
                    task.spawn(function()
                        local affectedParts = {}
                        for _, part in pairs(obj.Parent:GetChildren()) do
                            if not part:IsA("BasePart") or part.Name:match("Collision") then continue end

                            part.Transparency = Options.HidingTransparency.Value
                            table.insert(affectedParts, part)
                        end

                        repeat task.wait()
                            for _, part in pairs(affectedParts) do
                                task.wait()
                                part.Transparency = Options.HidingTransparency.Value
                            end
                        until not shared.Character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                        
                        for _, part in pairs(affectedParts) do
                            part.Transparency = 0
                        end
                    end)

                    break
                end
            end
        end)

        Script.FeatureConnections.Character["Oxygen"] = shared.Character:GetAttributeChangedSignal("Oxygen"):Connect(function()
            if not Toggles.NotifyOxygen then return end
            if not Toggles.NotifyOxygen.Value then return end
            if shared.Character:GetAttribute("Oxygen") >= 100 then return end

            if wax.shared.ExecutorSupport["firesignal"] then
                firesignal(Script.RemotesFolder.Caption.OnClientEvent, string.format("Oxygen: %.1f", shared.Character:GetAttribute("Oxygen")))
            else
                Script.Functions.Captions(string.format("Oxygen: %.1f", shared.Character:GetAttribute("Oxygen")))
            end
        end)
    end

    shared.Humanoid = shared.Character:WaitForChild("Humanoid")
    if shared.Humanoid then
        for _, oldConnection in pairs(Script.FeatureConnections.Humanoid) do
            oldConnection:Disconnect()
        end

        Script.FeatureConnections.Humanoid["Move"] = shared.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if not Toggles.FastClosetExit then return end

            if Toggles.FastClosetExit.Value and shared.Humanoid.MoveDirection.Magnitude > 0 and shared.Character:GetAttribute("Hiding") then
                Script.RemotesFolder.CamLock:FireServer()
            end
        end)

        Script.FeatureConnections.Humanoid["Jump"] = shared.Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
            if not Toggles.SpeedBypass then return end

            if not Toggles.SpeedBypass.Value and Script.LatestRoom.Value < 100 and not Script.FakeRevive.Enabled then
                if shared.Humanoid.JumpHeight > 0 then
                    Script.LastSpeed = Options.WalkSpeed.Value
                    Options.WalkSpeed:SetMax(18)
                elseif Script.LastSpeed > 0 then
                    Options.WalkSpeed:SetMax(22)
                    Options.WalkSpeed:SetValue(Script.LastSpeed)
                    Script.LastSpeed = 0
                end
            end
        end)

        Script.FeatureConnections.Humanoid["Died"] = shared.Humanoid.Died:Connect(function()
            if Script.CollisionClone then
                Script.CollisionClone:Destroy()
            end
        end)

        if Script.IsFools then
            local HoldingAnimation = Instance.new("Animation") do
                HoldingAnimation.AnimationId = "rbxassetid://10479585177"
                Script.Temp.ItemHoldTrack = shared.Humanoid:LoadAnimation(HoldingAnimation)
            end

            local ThrowAnimation = Instance.new("Animation") do
                ThrowAnimation.AnimationId = "rbxassetid://10482563149"
                Script.Temp.ItemThrowTrack = shared.Humanoid:LoadAnimation(ThrowAnimation)
            end
        end
    end

    shared.RootPart = shared.Character:WaitForChild("HumanoidRootPart")
    if shared.RootPart then
        if Toggles.NoAccel ~= nil then 
            if Toggles.NoAccel.Value then
                Script.Temp.NoAccelValue = shared.RootPart.CustomPhysicalProperties.Density
                
                local existingProperties = shared.RootPart.CustomPhysicalProperties
                shared.RootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
            end
        end

        Script.FeatureConnections.RootPart["Touched"] = shared.RootPart.Touched:Connect(function(touchedPart)
            if tonumber(touchedPart.Name) and touchedPart.Name == touchedPart.Parent.Name then
                shared.LocalPlayer:SetAttribute("CurrentRoom", tonumber(touchedPart.Name))
            end
        end)
    end

    Script.Collision = shared.Character:WaitForChild("Collision")
    if Script.Collision then
        if Toggles.UpsideDown ~= nil then
            if Toggles.UpsideDown.Value then
                Script.Collision.Rotation = Vector3.new(Script.Collision.Rotation.X, Script.Collision.Rotation.Y, -90)
            end
        end

        Script.CollisionClone = Script.Collision:Clone()
        Script.CollisionClone.CanCollide = false
        Script.CollisionClone.Massless = true
        Script.CollisionClone.Name = "CollisionClone"
        if Script.CollisionClone:FindFirstChild("CollisionCrouch") then
            Script.CollisionClone.CollisionCrouch:Destroy()
        end

        Script.CollisionClone.Parent = shared.Character
    end

    if Script.IsMines then
        if shared.Character then
            shared.Connections["AnticheatBypassTheMines"] = shared.Character:GetAttributeChangedSignal("Climbing"):Connect(function()
                if not Toggles.TheMinesAnticheatBypass then return end
                if not Toggles.TheMinesAnticheatBypass.Value then return end
                if not shared.Character:GetAttribute("Climbing") then return end

                task.wait(1)
                shared.Character:SetAttribute("Climbing", false)

                Script.Bypassed = true

                for _, ladderEsp in pairs(Script.ESPTable.None) do
                    ladderEsp.Destroy()
                end

                Options.WalkSpeed:SetMax(75)
                Options.FlySpeed:SetMax(75)

                shared.Notify:Alert({
                    Title = "Anticheat Bypass",
                    Description = "Bypassed the anticheat successfully!",
                    Reason = "This will only last until the next cutscene!",

                    LinoriaMessage = "Bypassed the anticheat successfully! This will only last until the next cutscene",

                    Time = 7
                })
                if workspace:FindFirstChild("_internal_mspaint_acbypassprogress") then workspace:FindFirstChild("_internal_mspaint_acbypassprogress"):Destroy() end
            end)
        end

        if shared.Humanoid then
            shared.Humanoid.MaxSlopeAngle = Options.MaxSlopeAngle.Value
        end
    end
end

function Script.Functions.SetupOtherPlayerConnection(player: Player)
    if player.Character then
        if Toggles.PlayerESP and Toggles.PlayerESP.Value then
            Script.Functions.PlayerESP(player.Character)
        end
    end

    shared.Connect:GiveSignal(player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Toggles.PlayerESP and Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player.Character)
            end
        end)

        shared.Connections[player.Name .. "ChildAdded"] = newCharacter.ChildAdded:Connect(function(child)
            if not (child:IsA("Tool") and child.Name:match("LibraryHintPaper")) then return end

            task.wait(0.1)
            local code = Script.Functions.GetPadlockCode(child)
            local output, count = string.gsub(code, "_", "x")
            local padlock = workspace:FindFirstChild("Padlock", true)

            if Options.AutoLibraryDistance ~= nil and Toggles.AutoLibrarySolver ~= nil then
                if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                    Script.RemotesFolder.PL:FireServer(code)
                end
            end

            if (Toggles.NotifyPadlock ~= nil and Toggles.NotifyPadlock.Value) and count < 5 then
                shared.Notify:Alert({
                    Title = "Padlock Code",
                    Description = string.format("Library Code: %s", output),
                    Reason = if tonumber(code) then "Solved the library padlock code" else "You are still missing some books",
                })

                if Toggles.NotifyChat ~= nil and Toggles.NotifyChat.Value and count == 0 then
                    shared.RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                end
            end
        end)
    end))
end