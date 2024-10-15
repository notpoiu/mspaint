if getgenv().mspaint_loading then print("[mspaint] Loading stopped. (ERROR: Loading)"); return end
if getgenv().mspaint_loaded then print("[mspaint] Loading stopped. (ERROR: Already loaded)"); return end

getgenv().mspaint_loading = true

--// Loading Wait \\--
if not game:IsLoaded() then game.Loaded:Wait() end

--// Services \\--
local Services = require("Utils/Services")
Services:GetServices({
    "Players",
    "UserInputService",
    "TextChatService",
    "ProximityPromptService",
    "PathfindingService",

    "CoreGui",
    "StarterGui",

    "Workspace",
    "Lighting",
    "ReplicatedStorage",

    "HttpService",
    "RunService",
    "SoundService",
    "TeleportService",
    "TweenService",
    "MarketplaceService"
})

--// Utils \\--
if not wax.shared.ExecutorSupport then
    wax.shared.ExecutorSupport = require("Utils/ExecutorSupport")
end

if not wax.shared.BloxstrapRPC then
    wax.shared.BloxstrapRPC = require("Utils/BloxstrapRPC")
end

if not wax.shared.FileHelper then
    wax.shared.FileHelper = require("Utils/FileHelper")
end

--// mspaint Loader \\--
if not wax.shared.GotPlace then
    wax.shared.GotPlace = true

    shared.ScriptName = "Universal"
    shared.ScriptLoader = "Universal"
    
    local Mappings = require("Mappings")
    
    local MappingID = Mappings[game.GameId]
    if MappingID then
        local Folder = MappingID["Folder"]
        local Name = MappingID["Name"] or Folder
        local GameExclusions = MappingID["Exclusions"] or {}
        local Exclusion = GameExclusions[game.PlaceId]
        
        shared.ScriptName = Name
        shared.ScriptLoader = Folder .. "/" .. MappingID["Main"]

        shared.Mapping = MappingID
        shared.ScriptFolder = Folder
        shared.ScriptExclusion = Exclusion
    
        if Exclusion then
            shared.ScriptName = Name .. " (" .. Exclusion .. ")"
            shared.ScriptLoader = Folder .. "/" .. Exclusion
        end
    end
end

--// Global functions \\--
shared.Script = {
    Functions = {}
}
shared.Hooks = {}

shared.Script.Functions.EnforceTypes = function(args, template)
    args = if typeof(args) == "table" then args else {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or (value ~= nil and typeof(argValue) ~= typeof(value)) then
            args[key] = value
        elseif typeof(value) == "table" then
            args[key] = shared.Script.Functions.EnforceTypes(argValue, value)
        end
    end

    return args
end

shared.Load = require("Utils/Loader")
shared.Logs = require("Utils/Logs")
shared.Connect = require("Utils/Connections")

--// Player Variables \\--
shared.Camera = workspace.CurrentCamera

shared.LocalPlayer = shared.Players.LocalPlayer
shared.PlayerGui = shared.LocalPlayer.PlayerGui
shared.PlayerScripts = shared.LocalPlayer.PlayerScripts

shared.Fly = require("Utils/Universal/Fly")
shared.ControlModule = require("Utils/Universal/ControlModule")

local TextChannels = shared.TextChatService:FindFirstChild("TextChannels")
if TextChannels and TextChannels:FindFirstChild("RBXGeneral") then
    shared.RBXGeneral = TextChannels.RBXGeneral
end

--// Load \\--
local UICreator = require("Utils/GUI/Creator")
shared.Window = UICreator:CreateWindow()

require("Places/Loaders/" .. shared.ScriptLoader)

UICreator:CreateSettingsTab()
require("Utils/GUI/Addons")

getgenv().mspaint_loading = false