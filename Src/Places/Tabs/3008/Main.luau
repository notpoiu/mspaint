--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local Tabs = Script.Tabs

Script.LastSpeed = if shared.Humanoid then shared.Humanoid.WalkSpeed else 16

--// Main \\--
local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player") do
    PlayerGroupBox:AddToggle("SpeedHack", {
        Text = "Speed Hack",
        Default = false
    })

    PlayerGroupBox:AddSlider("WalkSpeed", {
        Text = "Walk Speed",
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Compact = true
    })

    PlayerGroupBox:AddToggle("JumpPowerHack", {
        Text = "Jump Power Hack",
        Default = false
    })

    PlayerGroupBox:AddSlider("JumpPower", {
        Text = "Jump Power",
        Default = 50,
        Min = 0,
        Max = 200,
        Rounding = 0,
        Compact = true
    })

    PlayerGroupBox:AddDivider()

    PlayerGroupBox:AddToggle("InstantInteract", {
        Text = "Instant Interact",
        Default = false,
        Visible = wax.shared.ExecutorSupport["hookfunction"] and wax.shared.ExecutorSupport["getcallingscript"]
    })

    PlayerGroupBox:AddToggle("NoFall", {
        Text = "No Fall",
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
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Compact = true
    })
end

local AutomationGroupBox = Tabs.Main:AddRightGroupbox("Automation") do
    AutomationGroupBox:AddToggle("AutoRespawn", {
        Text = "Auto Respawn",
        Default = false
    })

    AutomationGroupBox:AddToggle("AutoPush", {
        Text = "Auto Push Employees",
        Default = false
    })

    AutomationGroupBox:AddDivider()

    AutomationGroupBox:AddToggle("AutoTPWhistle", {
        Text = "Enable player whistle teleport",
        Default = false
    })

    AutomationGroupBox:AddDropdown("AutoTPWhistlePlayers", {
        SpecialType = "Player",
        Multi = true,
        Text = "Go to player(s)'s whistle."
    })
end

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
    MiscGroupBox:AddButton({
        Text = "Respawn",
        Func = function()
            Script.Functions.Respawn()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Rejoin",
        Func = function()
            if #shared.Players:GetPlayers() <= 1 then
                shared.TeleportService:Teleport(game.PlaceId, shared.LocalPlayer)
                return
            end

            shared.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, shared.LocalPlayer)
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Instant Leave",
        Func = function()
            task.delay(0.1, function() game:Shutdown() end)
            shared.LocalPlayer:Kick("Bye bye! :Content:")
        end,
        DoubleClick = true
    })
end

--// Player \\--
Toggles.SpeedHack:OnChanged(function(value)
    if not shared.Humanoid then return end

    if value then
        Script.LastSpeed = shared.Humanoid.WalkSpeed
    end

    shared.Humanoid.WalkSpeed = if value then Options.WalkSpeed.Value else Script.LastSpeed
end)

Options.WalkSpeed:OnChanged(function(value)
    if not shared.Humanoid then return end

    if shared.Humanoid.WalkSpeed ~= value then
        if Toggles.SpeedHack.Value then shared.Humanoid.WalkSpeed = value end
    end
end)

Toggles.JumpPowerHack:OnChanged(function(value)
    if not shared.Humanoid then return end

    if value then
        Script.LastJumpPower = if shared.Humanoid.UseJumpPower then shared.Humanoid.JumpPower else shared.Humanoid.JumpHeight
    end

    if shared.Humanoid.UseJumpPower then
        shared.Humanoid.JumpPower = if value then Options.JumpPower.Value else Script.LastJumpPower
    else
        shared.Humanoid.JumpHeight = if value then Options.JumpPower.Value else Script.LastJumpPower
    end
end)

Options.JumpPower:OnChanged(function(value)
    if not shared.Humanoid then return end

    if shared.Humanoid.UseJumpPower then
        if shared.Humanoid.JumpPower ~= value then
            if Toggles.JumpPowerHack.Value then shared.Humanoid.JumpPower = value end
        end
    else
        if shared.Humanoid.JumpHeight ~= value then
            if Toggles.JumpPowerHack.Value then shared.Humanoid.JumpHeight = value end
        end
    end
end)

Toggles.NoFall:OnChanged(function(value)
    local fallDamage = shared.Character and shared.Character:FindFirstChild("FallDamage")
    
    if fallDamage then
        fallDamage.Enabled = not value
    end
end)

Toggles.Noclip:OnChanged(function(value)
    if not shared.Character then return end

    for _, part in pairs(shared.Character:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        part.CanCollide = not value

        shared.Connect:GiveSignal(part:GetPropertyChangedSignal("CanCollide"):Connect(function()
            part.CanCollide = not Toggles.Noclip.Value
        end))
    end
end)

Toggles.Fly:OnChanged(function(value)
    if not shared.Fly.FlyBody then shared.Fly:Setup() end

    shared.Fly:Set(value)
end)

Options.FlySpeed:OnChanged(function(value)
    shared.Fly:SetSpeed(value)
end)

Toggles.AutoPush:OnChanged(function(value)
    if value then
        task.spawn(function()
            repeat task.wait(0.1)
                for _, employee in pairs(Script.Employees:GetChildren()) do
                    if Script.Functions.DistanceFromCharacter(employee) <= 20 and employee:FindFirstChild("Enemy") then
                        Script.Action:InvokeServer("ShoveEmployee", {
                            Humanoid = employee.Enemy
                        })
                    end
                end
            until not Toggles.AutoPush.Value or shared.Library.Unloaded
        end)
    end
end)