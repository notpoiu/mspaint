--!native
--!optimize 2

if not ExecutorSupport then print("[mspaint] Loading stopped, please use the official loadstring for mspaint. (ERROR: ExecutorSupport == nil)") return end
if getgenv().mspaint_loaded then print("[mspaint] Loading stopped. (ERROR: Already loaded)") return end
getgenv().mspaint_loaded = true

--// Services \\--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

--// Loading Wait \\--
if not game.IsLoaded then game.Loaded:Wait() end
if Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") and Players.LocalPlayer.PlayerGui.LoadingUI.Enabled then
    repeat task.wait() until not game.Players.LocalPlayer.PlayerGui.LoadingUI.Enabled
end

--// Variables \\--
local Script = {
    CurrentBadge = 0,
    Achievements = {
        "SurviveWithoutHiding",
        "SurviveGloombats",
        "SurviveSeekMinesSecond",
        "TowerHeroesGoblino",
        "EscapeBackdoor",
        "SurviveFiredamp",
        "CrucifixDread",
        "EnterRooms",
        "EncounterVoid",
        "Join",
        "DeathAmt100",
        "UseCrucifix",
        "EncounterSpider",
        "SurviveHalt",
        "SurviveRush",
        "DeathAmt10",
        "Revive",
        "PlayFriend",
        "SurviveNest",
        "CrucifixFigure",
        "CrucifixAmbush",
        "PlayerBetrayal",
        "SurviveEyes",
        "KickGiggle",
        "EscapeMines",
        "GlowstickGiggle",
        "DeathAmt1",
        "SurviveSeek",
        "UseRiftMutate",
        "CrucifixGloombatSwarm",
        "SurviveScreech",
        "SurviveDread",
        "SurviveSeekMinesFirst",
        "CrucifixHalt",
        "TowerHeroesVoid",
        "JoinLSplash",
        "CrucifixDupe",
        "EncounterGlitch",
        "JeffShop",
        "CrucifixScreech",
        "SurviveGiggle",
        "EscapeHotelMod1",
        "SurviveDupe",
        "CrucifixRush",
        "EscapeBackdoorHunt",
        "EscapeHotel",
        "CrucifixGiggle",
        "EscapeFools",
        "UseRift",
        "SpecialQATester",
        "EscapeRetro",
        "TowerHeroesHard",
        "EnterBackdoor",
        "EscapeRooms1000",
        "EscapeRooms",
        "EscapeHotelMod2",
        "EncounterMobble",
        "CrucifixGrumble",
        "UseHerbGreen",
        "CrucifixSeek",
        "JeffTipFull",
        "SurviveFigureLibrary",
        "TowerHeroesHotel",
        "CrucifixEyes",
        "BreakerSpeedrun",
        "SurviveAmbush",
        "SurviveHide",
        "JoinAgain"
    },
    Functions = {}
}

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local playerGui = localPlayer.PlayerGui
local mainUI = playerGui:WaitForChild("MainUI")
local lobbyFrame = mainUI:WaitForChild("LobbyFrame")
local achievementsFrame = lobbyFrame:WaitForChild("Achievements")

local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")

local lobbyElevators = workspace:WaitForChild("Lobby"):WaitForChild("LobbyElevators")

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = getgenv().Linoria.Options
local Toggles = getgenv().Linoria.Toggles

local Window = Library:CreateWindow({
	Title = "mspaint v2",
	Center = true,
	AutoShow = true,
	Resizable = true,
    NotifySide = "Right",
	ShowCustomCursor = true,
	TabPadding = 2,
	MenuFadeTime = 0
})

local Tabs = {
	Main = Window:AddTab("Main"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}


--// Functions \\--

getgenv()._internal_unload_mspaint = function()
    Library:Unload()
end

function Script.Functions.SetupVariables()
    if ExecutorSupport["require"] then
        for achievementName, _ in pairs(require(game:GetService("ReplicatedStorage").Achievements)) do
            if table.find(Script.Achievements, achievementName) then continue end
    
            table.insert(Script.Achievements, achievementName)
        end
    else
        local badgeList = achievementsFrame:WaitForChild("List", math.huge)

        if badgeList then
            repeat task.wait(.5) until #badgeList:GetChildren() ~= 0
            
            Library:GiveSignal(badgeList.ChildAdded:Connect(function(badge)
                if not badge:IsA("ImageButton") then return end
                if table.find(Script.Achievements, badge.Name) then return end
                table.insert(Script.Achievements, badge.Name)
            end))

            for _, badge in pairs(badgeList:GetChildren()) do
                if not badge:IsA("ImageButton") then continue end
                if table.find(Script.Achievements, badge.Name) then continue end

                table.insert(Script.Achievements, badge.Name)
            end
        end
    end
end

function Script.Functions.LoopAchievements()
    task.spawn(function()
        while Toggles.LoopAchievements.Value and not Library.Unloaded do
            if Script.CurrentBadge >= #Script.Achievements then Script.CurrentBadge = 0 end
            Script.CurrentBadge += 1

            local random = Script.Achievements[Script.CurrentBadge]
            remotesFolder.FlexAchievement:FireServer(random)

            task.wait(Options.LoopAchievementsSpeed.Value)
        end
    end)
end

function Script.Functions.Alert(message: string, duration: number | nil)
    Library:Notify(message, duration or 5)

    local sound = Instance.new("Sound", Workspace) do
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound.PlayOnRemove = true
        sound:Destroy()
    end
end

--// Main \\--

local SniperGroupbox = Tabs.Main:AddLeftGroupbox("Sniper") do
    SniperGroupbox:AddToggle("ElevatorSniper", {
        Text = "Elevator Sniper",
        Default = false
    })

    SniperGroupbox:AddDropdown("ElevatorSniperTarget", {
        SpecialType = "Player",
        Multi = false,

        Text = "Target"
    })
end

local OtherGroupbox = Tabs.Main:AddRightGroupbox("Other") do
    OtherGroupbox:AddToggle("LoopAchievements", {
        Text = "Loop Achievements",
        Default = false
    })

    OtherGroupbox:AddSlider("LoopAchievementsSpeed", {
        Text = "Speed",
        Default = 0.05,
        Min = 0.05,
        Max = 1,
        Rounding = 2,
        Compact = true
    })
end

--// Connections \\--

Toggles.LoopAchievements:OnChanged(function(value)
    if value then
        Script.Functions.LoopAchievements()
    end
end)

Library:GiveSignal(RunService.RenderStepped:Connect(function()
    if Toggles.ElevatorSniper.Value and Options.ElevatorSniperTarget.Value then
        local targetCharacter = workspace:FindFirstChild(Options.ElevatorSniperTarget.Value)
        if not targetCharacter then return end

        local targetElevatorID = targetCharacter:GetAttribute("InGameElevator")
        local currentElevatorID = character:GetAttribute("InGameElevator")
        if currentElevatorID == targetElevatorID then return end

        if targetElevatorID ~= nil then    
            local targetElevator = lobbyElevators:FindFirstChild("LobbyElevator-" .. targetElevatorID) 

            if not targetElevator then
                for _, elevator in pairs(lobbyElevators:GetChildren()) do
                    if elevator.Name:match(Options.ElevatorSniperTarget.Value) then
                        targetElevator = elevator
                    end
                end
            end

            if targetElevator then
                remotesFolder.ElevatorJoin:FireServer(targetElevator)
            end
        elseif currentElevatorID ~= nil then
            remotesFolder.ElevatorExit:FireServer()
        end
    end
end))

--// Script Load \\--
task.spawn(Script.Functions.SetupVariables)

--// Library Load \\--

Library:OnUnload(function()
	print("Unloaded!")
	Library.Unloaded = true
    getgenv().mspaint_loaded = false
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local CreditsGroup = Tabs["UI Settings"]:AddRightGroupbox("Credits")

MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Join Discord Server", function()
    local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
	Inviter.Join("https://discord.com/invite/cfyMptntHr")
	Inviter.Prompt({
		name = "mspaint",
		invite = "https://discord.com/invite/cfyMptntHr",
	})
end)
MenuGroup:AddButton("Unload", function() Library:Unload() end)

CreditsGroup:AddLabel("Developers:")
CreditsGroup:AddLabel("upio - owner")
CreditsGroup:AddLabel("deividcomsono - main script dev")
CreditsGroup:AddLabel("mstudio45")
CreditsGroup:AddLabel("bacalhauz")

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetFolder("mspaint/doors")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()