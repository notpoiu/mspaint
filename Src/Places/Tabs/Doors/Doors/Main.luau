--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local Tabs = Script.Tabs

--// Main \\--
local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player") do
    PlayerGroupBox:AddToggle("EnableSpeedHack", {
        Text = "Enable Speed Hack",
        Default = false
    })

    PlayerGroupBox:AddSlider("WalkSpeed", {
        Text = "Walk Speed",
        Default = 15,
        Min = 0,
        Max = 22,
        Rounding = 0,
        Compact = true
    })

    PlayerGroupBox:AddSlider("LadderSpeed", {
        Text = "Ladder Speed",
        Default = 15,
        Min = 0,
        Max = 75,
        Rounding = 0,
        Compact = true
    })

    PlayerGroupBox:AddToggle("EnableJump", {
        Text = "Enable Jump",
        Default = false,
        Visible = not Script.IsFools
    })
    PlayerGroupBox:AddSlider("JumpBoost", {
        Text = "Jump Boost",
        Default = 5,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Compact = true,
        Visible = not Script.IsFools
    })

    PlayerGroupBox:AddToggle("NoAccel", {
        Text = "No Acceleration",
        Default = false
    })

    PlayerGroupBox:AddDivider()

    PlayerGroupBox:AddToggle("InstaInteract", {
        Text = "Instant Interact",
        Default = false
    })

    PlayerGroupBox:AddToggle("FastClosetExit", {
        Text = "Fast Closet Exit",
        Default = false
    })

    PlayerGroupBox:AddDivider()

    PlayerGroupBox:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false
    }):AddKeyPicker("NoclipKey", {
        Mode = "Toggle",
        Default = "N",
        Text = "Noclip",
        SyncToggleState = true
    })

    PlayerGroupBox:AddToggle("Fly", {
        Text = "Fly",
        Default = false
    }):AddKeyPicker("FlyKey", {
        Mode = "Toggle",
        Default = "F",
        Text = "Fly",
        SyncToggleState = true
    })
    
    PlayerGroupBox:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = 15,
        Min = 10,
        Max = 22,
        Rounding = 1,
        Compact = true,
    })
end

local ReachGroupBox = Tabs.Main:AddLeftGroupbox("Reach") do
    ReachGroupBox:AddToggle("DoorReach", {
        Text = "Door Reach",
        Default = false
    })

    ReachGroupBox:AddToggle("PromptClip", {
        Text = "Prompt Clip",
        Default = false
    })

    ReachGroupBox:AddSlider("PromptReachMultiplier", {
        Text = "Prompt Reach Multiplier",
        Default = 1,
        Min = 1,
        Max = 2,
        Rounding = 1
    })
end

local AutomationGroupBox = Tabs.Main:AddRightGroupbox("Automation") do
    AutomationGroupBox:AddToggle("AutoInteract", {
        Text = "Auto Interact",
        Default = false
    }):AddKeyPicker("AutoInteractKey", {
        Mode = shared.Library.IsMobile and "Toggle" or "Hold",
        Default = "R",
        Text = "Auto Interact",
        SyncToggleState = shared.Library.IsMobile
    })

    AutomationGroupBox:AddDropdown("AutoInteractIgnore", {
        AllowNull = true,
        Values = {"Jeff Items", "Unlock w/ Lockpick", "Paintings", "Gold", "Light Source Items", "Skull Prompt"},
        Default = {"Jeff Items"},
        Multi = true,

        Text = "Ignore List"
    })

    AutomationGroupBox:AddDivider()

    AutomationGroupBox:AddToggle("AutoWardrobeNotif", {
        Text = "Auto " .. Script.HidingPlaceName[Script.Floor.Value] .. " Notifications",
        Default = false
    })

    AutomationGroupBox:AddToggle("AutoWardrobe", {
        Text = "Auto " .. Script.HidingPlaceName[Script.Floor.Value],
        Default = false,
        Tooltip = "Might fail with multiple entities (Rush & Ambush, 3+ Rush spawns)",
        Visible = not Script.IsRetro,
        Risky = true
    }):AddKeyPicker("AutoWardrobeKey", {
        Mode = "Toggle",
        Default = "Q",
        Text = "Auto " .. Script.HidingPlaceName[Script.Floor.Value],
        SyncToggleState = true
    })
    AutomationGroupBox:AddDivider()

    AutomationGroupBox:AddToggle("AutoHeartbeat", {
        Text = "Auto Heartbeat Minigame",
        Default = false,
        Visible = wax.shared.ExecutorSupport["getnamecallmethod"]
    })

    if Script.IsHotel or Script.IsFools then
        AutomationGroupBox:AddToggle("AutoLibrarySolver", {
            Text = "Auto Library Code",
            Default = false
        })

        AutomationGroupBox:AddSlider("AutoLibraryDistance", {
            Text = "Unlock Distance",
            Default = 20,
            Min = 1,
            Max = 100,
            Rounding = 0,
            Compact = true
        })

        AutomationGroupBox:AddDivider()

        AutomationGroupBox:AddDropdown("AutoBreakerSolverMethod", {
            AllowNull = false,
            Values = {"Legit", "Exploit"},
            Default = "Legit",
            Multi = false,

            Text = "Auto Breaker Solver Method"
        })

        AutomationGroupBox:AddToggle("AutoBreakerSolver", {
            Text = "Auto Breaker Box",
            Default = false
        })

        Toggles.AutoLibrarySolver:OnChanged(function(value)
            if value then
                for _, player in pairs(shared.Players:GetPlayers()) do
                    if not player.Character then continue end
                    local tool = player.Character:FindFirstChildOfClass("Tool")

                    if tool and tool.Name:match("LibraryHintPaper") then
                        local code = Script.Functions.GetPadlockCode(tool)
                        local padlock = workspace:FindFirstChild("Padlock", true)

                        if tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                            Script.RemotesFolder.PL:FireServer(code)
                        end
                    end
                end
            end
        end)

        Toggles.AutoBreakerSolver:OnChanged(function(value)
            if value then
                local elevatorBreaker = workspace.CurrentRooms:FindFirstChild("ElevatorBreaker", true)
                if not elevatorBreaker then return end
    
                Script.Functions.SolveBreakerBox(elevatorBreaker)
            end
        end)
    elseif Script.IsMines then
        AutomationGroupBox:AddToggle("AutoAnchorSolver", {
            Text = "Auto Anchor Solver",
            Default = false
        })
    end
end

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
    MiscGroupBox:AddButton({
        Text = "Revive",
        Func = function()
            Script.RemotesFolder.Revive:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Play Again",
        Func = function()
            Script.RemotesFolder.PlayAgain:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Lobby",
        Func = function()
            Script.RemotesFolder.Lobby:FireServer()
        end,
        DoubleClick = true
    })
end

--// Player \\--
Toggles.EnableJump:OnChanged(function(value)
    if Script.IsFools then return end

    if shared.Character then
        shared.Character:SetAttribute("CanJump", value)
    end

    if not value and shared.CheckToggle("SpeedBypass", true) and Options.WalkSpeed.Max ~= 22 and not Script.FakeRevive.Enabled then
        Options.WalkSpeed:SetMax(22)
    end
end)

Options.JumpBoost:OnChanged(function(value)
    if Script.IsFools or not Toggles.EnableJump.Value then return end
    shared.Humanoid.JumpHeight = value
end)

Toggles.NoAccel:OnChanged(function(value)
    if not shared.RootPart then return end

    if value then
        Script.Temp.NoAccelValue = shared.RootPart.CustomPhysicalProperties.Density
        
        local existingProperties = shared.RootPart.CustomPhysicalProperties
        shared.RootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    else
        local existingProperties = shared.RootPart.CustomPhysicalProperties
        shared.RootPart.CustomPhysicalProperties = PhysicalProperties.new(Script.Temp.NoAccelValue, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    end
end)

Toggles.InstaInteract:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if value then
                if not prompt:GetAttribute("Hold") then prompt:SetAttribute("Hold", prompt.HoldDuration) end
                prompt.HoldDuration = 0
            else
                prompt.HoldDuration = prompt:GetAttribute("Hold") or 0
            end
        end
    end
end)

Toggles.Fly:OnChanged(function(value)
    if not shared.Fly.FlyBody then shared.Fly:Setup() end

    shared.Fly:Set(value)
end)

Options.FlySpeed:OnChanged(function(value)
    shared.Fly:SetSpeed(value)
end)

--// Reach \\--
Toggles.PromptClip:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do        
        if Script.Functions.PromptCondition(prompt) then
            if value then
                prompt.RequiresLineOfSight = false
            else
                prompt.RequiresLineOfSight = prompt:GetAttribute("Clip") or true
            end
        end
    end
end)

Options.PromptReachMultiplier:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if Script.Functions.PromptCondition(prompt) then
            if not prompt:GetAttribute("Distance") then prompt:SetAttribute("Distance", prompt.MaxActivationDistance) end

            prompt.MaxActivationDistance = prompt:GetAttribute("Distance") * value
        end
    end
end)