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
        Max = 75,
        Rounding = 0,
        Compact = true
    })

    PlayerGroupBox:AddDivider()

    PlayerGroupBox:AddToggle("InfStamina", {
        Text = "Infinite Stamina",
        Default = false,
        Visible = wax.shared.ExecutorSupport["getrenv"]
    })

    PlayerGroupBox:AddToggle("InfFlashlight", {
        Text = "Infinite Flashlight",
        Default = false,
        Visible = wax.shared.ExecutorSupport["getrenv"]
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