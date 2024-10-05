--!native
--!optimize 2

if not ExecutorSupport then print("[mspaint] Loading stopped, please use the official loadstring for mspaint. (ERROR: ExecutorSupport == nil)") return end
if getgenv().mspaint_loaded then print("[mspaint] Loading stopped. (ERROR: Already loaded)") return end

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
    Functions = {File = {}},
    ElevatorPresetData = {},
    ElevatorPresets = {}
}

local supportsFileSystem = (ExecutorSupport["isfile"] and ExecutorSupport["delfile"] and ExecutorSupport["listfiles"] and ExecutorSupport["writefile"] and ExecutorSupport["makefolder"] and ExecutorSupport["isfolder"])

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local playerGui = localPlayer.PlayerGui
local mainUI = playerGui:WaitForChild("MainUI")
local lobbyFrame = mainUI:WaitForChild("LobbyFrame")
local achievementsFrame = lobbyFrame:WaitForChild("Achievements")
local createElevatorFrame = lobbyFrame:WaitForChild("CreateElevator")

local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")
local createElevator = remotesFolder:WaitForChild("CreateElevator")

local lobbyElevators = workspace:WaitForChild("Lobby"):WaitForChild("LobbyElevators")

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = getgenv().Linoria.Options
local Toggles = getgenv().Linoria.Toggles

local Window = Library:CreateWindow({
    Title = "mspaint v2 | DOORS (Lobby)",
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

function Script.Functions.EnforceTypes(args, template)
    args = type(args) == "table" and args or {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or (value ~= nil and type(argValue) ~= type(value)) then
            args[key] = value
        elseif type(value) == "table" then
            args[key] = Script.Functions.EnforceTypes(argValue, value)
        end
    end

    return args
end

function Script.Functions.File.BuildPresetStructure()
    if not isfolder("mspaint/doors/presets") then
        makefolder("mspaint/doors/presets")
    end
end

function Script.Functions.File.CreatePreset(name: string, data: table)
    local presetData = Script.Functions.EnforceTypes(data, {
        Floor = "Hotel",
        MaxPlayers = 1,
        Modifiers = nil,
        FriendsOnly = true
    })

    Script.Functions.File.BuildPresetStructure()
    writefile("mspaint/doors/presets/" .. name .. ".json", HttpService:JSONEncode(presetData))
end

function Script.Functions.File.GetFileNameFromPath(path: string, extention: string | nil)
    local fileExtension = extention or ".json"

    if path:sub(-#fileExtension) == fileExtension then
        path = path:gsub("\\", "/")

        local pos = path:find("/[^/]*$")
        if pos then
            return path:sub(pos + 1, -#fileExtension - 1)
        end
    end

    return nil
end

function Script.Functions.File.LoadPresets()
    table.clear(Script.ElevatorPresets)
    table.clear(Script.ElevatorPresetData)

    for _, file in pairs(listfiles("mspaint/doors/presets")) do
        local success, ret = pcall(function()
            local data = readfile(file)
            return HttpService:JSONDecode(data)
        end)

        if success then
            local name = Script.Functions.File.GetFileNameFromPath(file)

            Script.ElevatorPresetData[name] = Script.Functions.EnforceTypes(ret, {
                Floor = "Hotel",
                MaxPlayers = 1,
                Modifiers = nil,
                FriendsOnly = true
            })

            table.insert(Script.ElevatorPresets, name)
        else
            print("Failed to load preset: " .. file)
        end
    end

    Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
    Options.Elevator_PresetList:SetValue(nil)
end

function Script.Functions.LoadPreset(name: string)
    Script.Functions.File.BuildPresetStructure()

    local success, ret = pcall(function()
        local data = readfile("mspaint/doors/presets/" .. name .. ".json")
        return HttpService:JSONDecode(data)
    end)

    if not success then
        Script.Functions.Alert("Failed to load preset: " .. name .. ".json")
        return
    end

    local presetData = Script.Functions.EnforceTypes(ret, {
        Floor = "Hotel",
        MaxPlayers = 1,
        Modifiers = nil,
        FriendsOnly = true
    })

    local data = {
        ["FriendsOnly"] = presetData.FriendsOnly,
        ["Destination"] = presetData.Floor,
        ["Mods"] = presetData.Modifiers or {},
        ["MaxPlayers"] = tostring(presetData.MaxPlayers)
    }

    createElevator:FireServer(data)

    Script.Functions.Alert("Loaded elevator preset: " .. name)
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


    OtherGroupbox:AddDivider()

    OtherGroupbox:AddButton("Create Retro Elevator", function()
        local data = {
            ["FriendsOnly"] = createElevatorFrame.Settings.FriendsOnly:GetAttribute("Setting"),
            ["Destination"] = "Hotel",
            ["Mods"] = {},
            ["MaxPlayers"] = createElevatorFrame.Settings.MaxPlayers.Toggle.Text
        }

        for _, modifier in pairs(createElevatorFrame.Modifiers:GetChildren()) do
            if modifier:GetAttribute("Enabled") then
                table.insert(data.Mods, modifier.Name)
            end
        end

        table.insert(data.Mods, "RetroMode")

        createElevator:FireServer(data)
    end)
end

if supportsFileSystem then
    local PresetGroupbox = Tabs.Main:AddLeftGroupbox("Presets") do
        PresetGroupbox:AddInput('Elevator_PresetName', { Text = 'Preset name' })
        PresetGroupbox:AddButton({
            Text = "Create Preset",
            Func = function()
                if isfile("mspaint/doors/presets/" .. Options.Elevator_PresetName.Value .. ".json") then
                    Script.Functions.Alert("Preset already exists!")
                    return
                end
    
                local presetData = {
                    Floor = "Hotel",
                    MaxPlayers = 1,
                    Modifiers = {},
                    FriendsOnly = true
                }
    
                for _, floor in pairs(createElevatorFrame.Floors:GetChildren()) do
                    if floor:IsA("TextLabel") and floor.Visible then
                        presetData.Floor = floor.Name
                        break
                    end
                end
    
                for _, modifier in pairs(createElevatorFrame.Modifiers:GetChildren()) do
                    if modifier:GetAttribute("Enabled") then
                        table.insert(presetData.Modifiers, modifier.Name)    
                    end
                end
    
                presetData.MaxPlayers = tonumber(createElevatorFrame.Settings.MaxPlayers.Toggle.Text)
                presetData.FriendsOnly = createElevatorFrame.Settings.FriendsOnly:GetAttribute("Setting")
    
                Script.Functions.File.CreatePreset(Options.Elevator_PresetName.Value, presetData)
                Script.Functions.Alert('Created elevator preset "' .. Options.Elevator_PresetName.Value .. '" with ' .. #presetData.Modifiers .. " modifiers")
    
                Script.Functions.File.LoadPresets()
                Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
                Options.Elevator_PresetList:SetValue(nil)
            end
        })
    
        PresetGroupbox:AddDivider()
    
        PresetGroupbox:AddDropdown('Elevator_PresetList', { Text = 'Preset list', Values = Script.ElevatorPresets, AllowNull = true })
        PresetGroupbox:AddButton('Load Preset', function()
            Script.Functions.LoadPreset(Options.Elevator_PresetList.Value)
        end)
    
        PresetGroupbox:AddButton('Override Preset', function()
            local presetData = {
                Floor = "Hotel",
                MaxPlayers = 1,
                Modifiers = {},
                FriendsOnly = true
            }
    
            for _, floor in pairs(createElevatorFrame.Floors:GetChildren()) do
                if floor:IsA("TextLabel") and floor.Visible then
                    presetData.Floor = floor.Name
                    break
                end
            end
    
            for _, modifier in pairs(createElevatorFrame.Modifiers:GetChildren()) do
                if modifier:GetAttribute("Enabled") then
                    table.insert(presetData.Modifiers, modifier.Name)    
                end
            end
    
            presetData.MaxPlayers = tonumber(createElevatorFrame.Settings.MaxPlayers.Toggle.Text)
            presetData.FriendsOnly = createElevatorFrame.Settings.FriendsOnly:GetAttribute("Setting")
    
            Script.Functions.Alert("Overrided preset: " .. Options.Elevator_PresetList.Value)
    
            Script.Functions.File.CreatePreset(Options.Elevator_PresetList.Value, HttpService:JSONEncode(presetData))
            
            Script.Functions.File.LoadPresets()
            Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
            Options.Elevator_PresetList:SetValue(nil)
        end)
    
        PresetGroupbox:AddButton('Delete Preset', function()
            if not isfile("mspaint/doors/presets/" .. Options.Elevator_PresetList.Value .. ".json") then
                Script.Functions.Alert("Preset does not exist!")
                return
            end
    
            local success, err = pcall(function()
                delfile("mspaint/doors/presets/" .. Options.Elevator_PresetList.Value .. ".json")
            end)
    
            if not success then
                Script.Functions.Alert("Failed to delete preset: " .. Options.Elevator_PresetList.Value)
                return
            end
    
            Script.Functions.Alert("Deleted preset: " .. Options.Elevator_PresetList.Value)
            
            Script.Functions.File.LoadPresets()
            Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
            Options.Elevator_PresetList:SetValue(nil)
        end)
    
        PresetGroupbox:AddButton('Refresh Presets', function()
            Script.Functions.File.LoadPresets()
            Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
            Options.Elevator_PresetList:SetValue(nil)
        end)
    
    end
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

Script.Functions.File.BuildPresetStructure()
Script.Functions.File.LoadPresets()

getgenv().mspaint_loaded = true