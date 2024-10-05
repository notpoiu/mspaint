--!native
--!optimize 2

if not ExecutorSupport then print("[mspaint] Loading stopped, please use the official loadstring for mspaint. (ERROR: ExecutorSupport == nil)") return end
if getgenv().mspaint_loaded then print("[mspaint] Loading stopped. (ERROR: Already loaded)") return end

--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Loading Wait \\--
if not game:IsLoaded() then game.Loaded:Wait() end
if Players.LocalPlayer and Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") and Players.LocalPlayer.PlayerGui.LoadingUI.Enabled then
    repeat task.wait() until not game.Players.LocalPlayer.PlayerGui.LoadingUI.Enabled
end

--// Variables \\--
local Script = {
    Binded = {}, -- ty geo for idea :smartindividual:
    Connections = {},
    FeatureConnections = {
        Character = {},
        Clip = {},
        Door = {},
        Humanoid = {},
        Player = {},
        RootPart = {},
    },

    ESPTable = {
        Chest = {},
        Door = {},
        Entity = {},
        SideEntity = {},
        Gold = {},
        Guiding = {},
        Item = {},
        Objective = {},
        Player = {},
        HidingSpot = {},
        None = {}
    },

    Functions = {
        Minecart = {},
        Notifs = {Linoria = {}, Doors = {}}
    },

    Lagback = {
        Detected = false,
        Threshold = 1,
        Anchors = 0,
        LastAnchored = 0,
        LastSpeed = 0,
        LastFlySpeed = 0,
    },

    Temp = {
        AnchorFinished = {},
        AutoWardrobeEntities = {},
        Bridges = {},
        FlyBody = nil,
        Guidance = {},
        PaintingDebounce = false,
        UsedBreakers = {},
    },

    FakeRevive = {
        Debounce = false,
        Enabled = false,
        Connections = {}
    }
}

local WhitelistConfig = {
    [45] = {firstKeep = 3, lastKeep = 2},
    [46] = {firstKeep = 2, lastKeep = 2},
    [47] = {firstKeep = 2, lastKeep = 2},
    [48] = {firstKeep = 2, lastKeep = 2},
    [49] = {firstKeep = 2, lastKeep = 4},
}

local SuffixPrefixes = {
    ["Backdoor"] = "",
    ["Ceiling"] = "",
    ["Moving"] = "",
    ["Ragdoll"] = "",
    ["Rig"] = "",
    ["Wall"] = "",
    ["Clock"] = " Clock",
    ["Key"] = " Key",
    ["Pack"] = " Pack",
    ["Pointer"] = " Pointer",
    ["Swarm"] = " Swarm",
}
local PrettyFloorName = {
    ["Fools"] = "Super Hard Mode",
}


local EntityTable = {
    ["Names"] = {"BackdoorRush", "BackdoorLookman", "RushMoving", "AmbushMoving", "Eyes", "JeffTheKiller", "A60", "A120"},
    ["SideNames"] = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"},
    ["ShortNames"] = {
        ["BackdoorRush"] = "Blitz",
        ["JeffTheKiller"] = "Jeff The Killer"
    },
    ["NotifyMessage"] = {
        ["GloombatSwarm"] = "Gloombats in next room!"
    },
    ["Avoid"] = {
        "RushMoving",
        "AmbushMoving"
    },
    ["NotifyReason"] = {
        ["A60"] = {
            ["Image"] = "12350986086",
        },
        ["A120"] = {
            ["Image"] = "12351008553",
        },
        ["BackdoorRush"] = {
            ["Image"] = "11102256553",
        },
        ["RushMoving"] = {
            ["Image"] = "11102256553",
        },
        ["AmbushMoving"] = {
            ["Image"] = "10938726652",
        },
        ["Eyes"] = {
            ["Image"] = "10865377903",
            ["Spawned"] = true
        },
        ["BackdoorLookman"] = {
            ["Image"] = "16764872677",
            ["Spawned"] = true
        },
        ["JeffTheKiller"] = {
            ["Image"] = "98993343",
            ["Spawned"] = true
        },
        ["GloombatSwarm"] = {
            ["Image"] = "79221203116470",
            ["Spawned"] = true
        }
    },
    ["NoCheck"] = {
        "Eyes",
        "BackdoorLookman",
        "JeffTheKiller"
    },
    ["InfCrucifixVelocity"] = {
        ["RushMoving"] = {
            threshold = 52,
            minDistance = 55,
        },
        ["RushNew"] = {
            threshold = 52,
            minDistance = 55,
        },    
        ["AmbushMoving"] = {
            threshold = 70,
            minDistance = 80,
        }
    },
    ["AutoWardrobe"] = {
        ["Entities"] = {
            "RushMoving",
            "AmbushMoving",
            "BackdoorRush",
            "A60",
            "A120",
        },
        ["Distance"] = {
            ["RushMoving"] = {
                Distance = 100,
                Loader = 175
            },
            ["BackdoorRush"] = {
                Distance = 100,
                Loader = 175
            },
    
            ["AmbushMoving"] = {
                Distance = 155,
                Loader = 200
            },
            ["A60"] = {
                Distance = 200,
                Loader = 200
            },
            ["A120"] = {
                Distance = 200,
                Loader = 200
            }
        }
    }
}

local HidingPlaceName = {
    ["Hotel"] = "Closet",
    ["Backdoor"] = "Closet",
    ["Fools"] = "Closet",
    ["Retro"] = "Closet",

    ["Rooms"] = "Locker",
    ["Mines"] = "Locker"
}
local CutsceneExclude = {
    "FigureHotelChase",
    "Elevator1",
    "MinesFinale"
}
local SlotsName = {
    "Oval",
    "Square",
    "Tall",
    "Wide"
}

local PromptTable = {
    GamePrompts = {},

    Aura = {
        ["ActivateEventPrompt"] = false,
        ["AwesomePrompt"] = true,
        ["FusesPrompt"] = true,
        ["HerbPrompt"] = false,
        ["LeverPrompt"] = true,
        ["LootPrompt"] = false,
        ["ModulePrompt"] = true,
        ["SkullPrompt"] = false,
        ["UnlockPrompt"] = true,
        ["ValvePrompt"] = false,
        ["PropPrompt"] = true
    },
    AuraObjects = {
        "Lock",
        "Button"
    },

    Clip = {
        "AwesomePrompt",
        "FusesPrompt",
        "HerbPrompt",
        "HidePrompt",
        "LeverPrompt",
        "LootPrompt",
        "ModulePrompt",
        "Prompt",
        "PushPrompt",
        "SkullPrompt",
        "UnlockPrompt",
        "ValvePrompt"
    },
    ClipObjects = {
        "LeverForGate",
        "LiveBreakerPolePickup",
        "LiveHintBook",
        "Button",
    },

    Excluded = {
        Prompt = {
            "HintPrompt",
            "InteractPrompt"
        },

        Parent = {
            "KeyObtainFake",
            "Padlock"
        },

        ModelAncestor = {
            "DoorFake"
        }
    }
}

local RBXGeneral = TextChatService.TextChannels.RBXGeneral

--// Exploits Variables \\--
local fireTouch = firetouchinterest or firetouchtransmitter
local firePrompt = ExecutorSupport["fireproximityprompt"] and fireproximityprompt or _fireproximityprompt
local forceFirePrompt = ExecutorSupport["fireproximityprompt"] and fireproximityprompt or _forcefireproximityprompt
local isnetowner = ExecutorSupport["isnetworkowner"] and isnetworkowner or _isnetworkowner

--// Player Variables \\--
local camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local playerScripts = localPlayer.PlayerScripts

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local alive = localPlayer:GetAttribute("Alive")
local humanoid: Humanoid
local rootPart: BasePart
local collision
local collisionClone
local velocityLimiter

--// DOORS Variables \\--
local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local latestRoom = gameData:WaitForChild("LatestRoom")

local liveModifiers = ReplicatedStorage:WaitForChild("LiveModifiers")

local isMines = floor.Value == "Mines"
local isRooms = floor.Value == "Rooms"
local isHotel = floor.Value == "Hotel"
local isBackdoor = floor.Value == "Backdoor"
local isFools = floor.Value == "Fools"
local isRetro = floor.Value == "Retro"

local floorReplicated = if not isFools then ReplicatedStorage:WaitForChild("FloorReplicated") else nil
local remotesFolder = if not isFools then ReplicatedStorage:WaitForChild("RemotesFolder") else ReplicatedStorage:WaitForChild("EntityInfo")

--// Player DOORS Variables \\--
local currentRoom = localPlayer:GetAttribute("CurrentRoom") or 0
local nextRoom = currentRoom + 1

local mainUI = playerGui:WaitForChild("MainUI")
local mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local mainGameSrc = if ExecutorSupport["require"] then require(mainGame) else nil
local controlModule = if ExecutorSupport["require"] then require(playerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")) else nil

--// Other Variables \\--
local speedBypassing = false

local lastSpeed = 0
local bypassed = false

local MinecartPathNodeColor = {
    Disabled = nil,
    Red = Color3.new(1, 0, 0),
    Yellow = Color3.new(1, 1, 0),
    Purple = Color3.new(1, 0, 1),
    Green = Color3.new(0, 1, 0),
    Cyan = Color3.new(0, 1, 1),
    Orange = Color3.new(1, 0.5, 0),
    White = Color3.new(1, 1, 1),
}

local MinecartPathfind = {
    -- ground chase [41 to 44]
    -- minecart chase [45 to 49]
}

--// Types \\--
type ESP = {
    Color: Color3,
    IsEntity: boolean,
    IsDoubleDoor: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

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

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = getgenv().Linoria.Options
local Toggles = getgenv().Linoria.Toggles

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MS-ESP/refs/heads/main/source.lua"))()

local Window = Library:CreateWindow({
    Title = "mspaint v2 | DOORS",
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
    Exploits = Window:AddTab("Exploits"),
    Visuals = Window:AddTab("Visuals"),
    Floor = Window:AddTab("Floor"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

--// Captions \\--
local _mspaint_custom_captions = Instance.new("ScreenGui") do
    local Frame = Instance.new("Frame", _mspaint_custom_captions)
    local TextLabel = Instance.new("TextLabel", Frame)
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint", TextLabel)

    _mspaint_custom_captions.Parent = ReplicatedStorage
    _mspaint_custom_captions.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Library.MainColor
    Frame.BorderColor3 = Library.AccentColor
    Frame.BorderSizePixel = 2
    Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
    Frame.Size = UDim2.new(0, 200, 0, 75)

    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.Code
    TextLabel.Text = ""
    TextLabel.TextColor3 = Library.FontColor
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true

    UITextSizeConstraint.MaxTextSize = 35

    function Script.Functions.Captions(caption: string)
        if _mspaint_custom_captions.Parent == ReplicatedStorage then _mspaint_custom_captions.Parent = gethui() or game:GetService("CoreGui") or playerGui end
        TextLabel.Text = caption
    end

    function Script.Functions.HideCaptions()
        _mspaint_custom_captions.Parent = ReplicatedStorage
    end
end

--// Functions \\--
getgenv()._internal_unload_mspaint = function()
    Library:Unload()
end

function Script.Functions.RandomString()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
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

function Script.Functions.UpdateRPC()
    if not getgenv().BloxstrapRPC then return end

    local roomNumberPrefix = "Room "
    local prettifiedRoomNumber = currentRoom

    if isBackdoor then
        prettifiedRoomNumber = -50 + currentRoom
    end

    if isMines then
        prettifiedRoomNumber += 100
    end

    prettifiedRoomNumber = tostring(prettifiedRoomNumber)

    if isRooms then
        roomNumberPrefix = "A-"
        prettifiedRoomNumber = string.format("%03d", prettifiedRoomNumber)
    end

    BloxstrapRPC.SetRichPresence({
        details = "Playing DOORS [ mspaint v2 ]",
        state = roomNumberPrefix .. prettifiedRoomNumber .. " (" .. (PrettyFloorName[floor.Value] and PrettyFloorName[floor.Value] or ("The " .. floor.Value) ) .. ")",
        largeImage = {
            hoverText = "Using mspaint v2"
        },
        smallImage = {
            assetId = 6925817108,
            hoverText = localPlayer.Name
        }
    })
end

--// Notification Functions \\--
do
    function Script.Functions.Warn(message: string)
        warn("WARN - mspaint:", message)
    end

    function Script.Functions.Notifs.Doors.Notify(unsafeOptions)
        assert(typeof(unsafeOptions) == "table", "Expected a table as options argument but got " .. typeof(unsafeOptions))
        if not mainUI then return end
        
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Title = "No Title",
            Description = "No Text",
            Reason = "",
            NotificationType = "NOTIFICATION",
            Image = "6023426923",
            Color = nil,
            Time = nil,
    
            TweenDuration = 0.8
        })
    
    
        local acheivement = mainUI.AchievementsHolder.Achievement:Clone()
        acheivement.Size = UDim2.new(0, 0, 0, 0)
        acheivement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
        acheivement.Name = "LiveAchievement"
        acheivement.Visible = true
    
        acheivement.Frame.TextLabel.Text = options.NotificationType
    
        if options.Color ~= nil then
            acheivement.Frame.TextLabel.TextColor3 = options.Color
            acheivement.Frame.UIStroke.Color = options.Color
            acheivement.Frame.Glow.ImageColor3 = options.Color
        end
        
        acheivement.Frame.Details.Desc.Text = tostring(options.Description)
        acheivement.Frame.Details.Title.Text = tostring(options.Title)
        acheivement.Frame.Details.Reason.Text = tostring(options.Reason or "")
    
        if options.Image:match("rbxthumb://") or options.Image:match("rbxassetid://") then
            acheivement.Frame.ImageLabel.Image = tostring(options.Image or "rbxassetid://0")
        else
            acheivement.Frame.ImageLabel.Image = "rbxassetid://" .. tostring(options.Image or "0")
        end
    
        acheivement.Parent = mainUI.AchievementsHolder
        acheivement.Sound.SoundId = "rbxassetid://10469938989"
    
        acheivement.Sound.Volume = 1
    
        if Toggles.NotifySound.Value then
            acheivement.Sound:Play()
        end
    
        task.spawn(function()
            acheivement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", options.TweenDuration, true)
        
            task.wait(0.8)
        
            acheivement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
        
            TweenService:Create(acheivement.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                ImageTransparency = 1
            }):Play()
        
            if options.Time ~= nil then
                if typeof(options.Time) == "number" then
                    task.wait(options.Time)
                elseif typeof(options.Time) == "Instance" then
                    options.Time.Destroying:Wait()
                end
            else
                task.wait(5)
            end
        
            acheivement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
            task.wait(0.5)
            acheivement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
            task.wait(0.5)
            acheivement:Destroy()
        end)
    end
    
    function Script.Functions.Notifs.Doors.Warn(options)
        assert(typeof(options) == "table", "Expected a table as options argument but got " .. typeof(options))
    
        options["NotificationType"] = "WARNING"
        options["Color"] = Color3.new(1, 0, 0)
        options["TweenDuration"] = 0.3
    
        Script.Functions.Notifs.Doors.Notify(options)
    end
    
    function Script.Functions.Notifs.Linoria.Notify(unsafeOptions)
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Description = "No Message",
            Time = nil
        })
    
        Library:Notify(options.Description, options.Time or 5)
    
        if Toggles.NotifySound.Value then
            local sound = Instance.new("Sound", SoundService) do
                sound.SoundId = "rbxassetid://4590662766"
                sound.Volume = 2
                sound.PlayOnRemove = true
                sound:Destroy()
            end
        end
    end
    
    function Script.Functions.Notifs.Linoria.Log(unsafeOptions, condition: boolean | nil)
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Description = "No Message",
            Time = nil
        })
    
        if condition ~= nil and not condition then return end
        Library:Notify(options.Description, options.Time or 5)
    end
    
    function Script.Functions.Alert(options)
        repeat task.wait() until getgenv().mspaint_loaded
    
        if Options.NotifyStyle.Value == "Linoria" then
            local linoriaMessage = options["LinoriaMessage"] or options.Description
            options.Description = linoriaMessage
            
            Script.Functions.Notifs.Linoria.Notify(options)
        elseif Options.NotifyStyle.Value == "Doors" and not options.Warning then
            Script.Functions.Notifs.Doors.Notify(options)
        elseif Options.NotifyStyle.Value == "Doors" and options.Warning then
            options["Warning"] = nil
    
            Script.Functions.Notifs.Doors.Warn(options)
        end
    end
    
    function Script.Functions.Log(options, condition: boolean | nil)
        repeat task.wait() until getgenv().mspaint_loaded
        
        if Options.NotifyStyle.Value == "Linoria" then
            local linoriaMessage = options["LinoriaMessage"] or options.Description
            options.Description = linoriaMessage
            
            Script.Functions.Notifs.Linoria.Log(options, condition)
        elseif Options.NotifyStyle.Value == "Doors" then
            if not condition and typeof(condition) == "boolean" then return end
    
            options["NotificationType"] = "LOGGING"
            options["Color"] = Color3.fromRGB(0, 102, 255)
    
            Script.Functions.Notifs.Doors.Notify(options)
        end
    end
end

--// Player Functions \\--
do
    function Script.Functions.DistanceFromCharacter(position: Instance | Vector3, getPositionFromCamera: boolean | nil)
        if not position then return 9e9 end
        if typeof(position) == "Instance" then
            position = position:GetPivot().Position
        end
    
        if getPositionFromCamera and (camera or workspace.CurrentCamera) then
            local cameraPosition = camera and camera.CFrame.Position or workspace.CurrentCamera.CFrame.Position
    
            return (cameraPosition - position).Magnitude
        end
    
        if rootPart then
            return (rootPart.Position - position).Magnitude
        elseif camera then
            return (camera.CFrame.Position - position).Magnitude
        end
    
        return 9e9
    end

    function Script.Functions.IsInViewOfPlayer(instance: Instance, range: number | nil, exclude: table | nil)
        if not instance then return false end
        if not collision then return false end
    
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
        local filter = exclude or {}
        table.insert(filter, character)
    
        raycastParams.FilterDescendantsInstances = filter
    
        local direction = (instance:GetPivot().Position - collision.Position).unit * (range or 9e9)
        local raycast = workspace:Raycast(collision.Position, direction, raycastParams)
    
        if raycast and raycast.Instance then
            if raycast.Instance:IsDescendantOf(instance) or raycast.Instance == instance then
                return true
            end
    
            return false
        end
    
        return false
    end
end

--// ESP Functions \\--
do
    function Script.Functions.ESP(args: ESP)
        if not args.Object then return Script.Functions.Warn("ESP Object is nil") end
    
        local ESPManager = {
            Object = args.Object,
            Text = args.Text or "No Text",
            Color = args.Color or Color3.new(),
            Offset = args.Offset or Vector3.zero,
            IsEntity = args.IsEntity or false,
            IsDoubleDoor = args.IsDoubleDoor or false,
            Type = args.Type or "None",
            OnDestroy = args.OnDestroy or nil,
    
            Invisible = false,
            Humanoid = nil
        }
    
        if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
            if ESPManager.Object.PrimaryPart.Transparency == 1 then
                ESPManager.Invisible = true
                ESPManager.Object.PrimaryPart.Transparency = 0.99
            end
    
            local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
            if not humanoid then humanoid = Instance.new("Humanoid", ESPManager.Object) end
            ESPManager.Humanoid = humanoid
        end
    
        local ESPInstance = ESPLibrary.ESP.Highlight({
            Name = ESPManager.Text,
            Model = ESPManager.Object,
            StudsOffset = ESPManager.Offset,
    
            FillColor = ESPManager.Color,
            OutlineColor = ESPManager.Color,
            TextColor = ESPManager.Color,
            TextSize = Options.ESPTextSize.Value or 16,

            FillTransparency = Options.ESPFillTransparency.Value,
            OutlineTransparency = Options.ESPOutlineTransparency.Value,
    
            Tracer = {
                Enabled = Toggles.ESPTracer.Value,
                From = Options.ESPTracerStart.Value,
                Color = ESPManager.Color
            },
    
            OnDestroy = ESPManager.OnDestroy or function()
                if ESPManager.Object.PrimaryPart and ESPManager.Invisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
                if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
            end
        })
    
        table.insert(Script.ESPTable[args.Type], ESPInstance)
    
        return ESPInstance
    end
    
    function Script.Functions.DoorESP(room)
        local door = room:WaitForChild("Door", 5)
    
        if door then
            local doorNumber = tonumber(room.Name) + 1
            if isMines then
                doorNumber += 100
            end
    
            local opened = door:GetAttribute("Opened")
            local locked = room:GetAttribute("RequiresKey")
    
            local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
            local doorIdx = Script.Functions.RandomString()
    
            local doorEsp = Script.Functions.ESP({
                Type = "Door",
                Object = door:WaitForChild("Door"),
                Text = string.format("Door %s %s", doorNumber, doorState),
                Color = Options.DoorEspColor.Value,
    
                OnDestroy = function()
                    if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
                end
            })
    
            Script.FeatureConnections.Door[doorIdx] = door:GetAttributeChangedSignal("Opened"):Connect(function()
                if doorEsp then doorEsp.SetText(string.format("Door %s [Opened]", doorNumber)) end
                if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
            end)
        end
    end 
    
    function Script.Functions.ObjectiveESP(child)
        -- Backdoor
        if child.Name == "TimerLever" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = string.format("Timer Lever [+%s]", child.TakeTimer.TextLabel.Text),
                Color = Options.ObjectiveEspColor.Value
            })
        -- Backdoor + Hotel
        elseif child.Name == "KeyObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Key",
                Color = Options.ObjectiveEspColor.Value
            })
        -- Hotel
        elseif child.Name == "ElectricalKeyObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Electrical Key",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LeverForGate" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Gate Lever",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LiveHintBook" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Book",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LiveBreakerPolePickup" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Breaker",
                Color = Options.ObjectiveEspColor.Value
            })
        -- Mines
        elseif child.Name == "MinesGenerator" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Generator",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "MinesGateButton" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Gate Power Button",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "FuseObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Fuse",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "MinesAnchor" then
            local sign = child:WaitForChild("Sign", 5)
    
            if sign and sign:FindFirstChild("TextLabel") then
                Script.Functions.ESP({
                    Type = "Objective",
                    Object = child,
                    Text = string.format("Anchor %s", sign.TextLabel.Text),
                    Color = Options.ObjectiveEspColor.Value
                })
            end
        elseif child.Name == "WaterPump" then
            local wheel = child:WaitForChild("Wheel", 5)
    
            if wheel then
                Script.Functions.ESP({
                    Type = "Objective",
                    Object = wheel,
                    Text = "Water Pump",
                    Color = Options.ObjectiveEspColor.Value
                })
            end
        end
    end
    
    function Script.Functions.EntityESP(entity)
        Script.Functions.ESP({
            Type = "Entity",
            Object = entity,
            Text = Script.Functions.GetShortName(entity.Name),
            Color = Options.EntityEspColor.Value,
            IsEntity = entity.Name ~= "JeffTheKiller",
        })
    end
    
    function Script.Functions.SideEntityESP(entity)
        if entity.Name == "Snare" and not entity:FindFirstChild("Hitbox") then return end
    
        Script.Functions.ESP({
            Type = "SideEntity",
            Object = entity,
            Text = Script.Functions.GetShortName(entity.Name),
            TextParent = entity.PrimaryPart,
            Color = Options.EntityEspColor.Value,
        })
    end
    
    function Script.Functions.ItemESP(item)
        Script.Functions.ESP({
            Type = "Item",
            Object = item,
            Text = Script.Functions.GetShortName(item.Name),
            Color = Options.ItemEspColor.Value
        })
    end
    
    function Script.Functions.ChestESP(chest)
        local text = chest.Name:gsub("Box", ""):gsub("_Vine", ""):gsub("_Small", "")
        local locked = chest:GetAttribute("Locked")
        local state = if locked then "[Locked]" else ""
    
        Script.Functions.ESP({
            Type = "Chest",
            Object = chest,
            Text = string.format("%s %s", text, state),
            Color = Options.ChestEspColor.Value
        })
    end
    
    function Script.Functions.PlayerESP(player: Player)
        if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end
    
        local playerEsp = Script.Functions.ESP({
            Type = "Player",
            Object = player.Character,
            Text = string.format("%s [%.1f]", player.DisplayName, humanoid.Health),
            TextParent = player.Character.PrimaryPart,
            Color = Options.PlayerEspColor.Value
        })
    
        Script.FeatureConnections.Player[player.Name] = player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth > 0 then
                playerEsp.SetText(string.format("%s [%.1f]", player.DisplayName, newHealth))
            else
                if Script.FeatureConnections.Player[player.Name] then Script.FeatureConnections.Player[player.Name]:Disconnect() end
                playerEsp.Destroy()
            end
        end)
    end
    
    function Script.Functions.HidingSpotESP(spot)
        Script.Functions.ESP({
            Type = "HidingSpot",
            Object = spot,
            Text = if spot:GetAttribute("LoadModule") == "Bed" then "Bed" else HidingPlaceName[floor.Value],
            Color = Options.HidingSpotEspColor.Value
        })
    end
    
    function Script.Functions.GoldESP(gold)
        Script.Functions.ESP({
            Type = "Gold",
            Object = gold,
            Text = string.format("Gold [%s]", gold:GetAttribute("GoldValue")),
            Color = Options.GoldEspColor.Value
        })
    end
    
    function Script.Functions.GuidingLightEsp(guidance)
        local part = guidance:Clone()
        part.Anchored = true
        part.Size = Vector3.new(3, 3, 3)
        part.Transparency = 0.5
        part.Name = "_Guidance"
    
        part:ClearAllChildren()
        part.Parent = Workspace
    
        Script.Temp.Guidance[guidance] = part
    
        local guidanceEsp = Script.Functions.ESP({
            Type = "Guiding",
            Object = part,
            Text = "Guidance",
            Color = Options.GuidingLightEspColor.Value
        })
    
        guidance.AncestryChanged:Connect(function()
            if not guidance:IsDescendantOf(workspace) then
                if Script.Temp.Guidance[guidance] then Script.Temp.Guidance[guidance] = nil end
                if part then part:Destroy() end
                if guidanceEsp then guidanceEsp.Destroy() end
            end
        end)
    end
end

--// Assets Functions \\--
do
    function Script.Functions.GetShortName(entityName: string)
        if EntityTable.ShortNames[entityName] then
            return EntityTable.ShortNames[entityName]
        end
    
        for suffix, fix in pairs(SuffixPrefixes) do
            entityName = entityName:gsub(suffix, fix)
        end
    
        return entityName
    end

    function Script.Functions.PromptCondition(prompt)
        local modelAncestor = prompt:FindFirstAncestorOfClass("Model")
        return 
            prompt:IsA("ProximityPrompt") and (
                not table.find(PromptTable.Excluded.Prompt, prompt.Name) 
                and not table.find(PromptTable.Excluded.Parent, prompt.Parent and prompt.Parent.Name or "") 
                and not (table.find(PromptTable.Excluded.ModelAncestor, modelAncestor and modelAncestor.Name or ""))
            )
    end

    function Script.Functions.ItemCondition(item)
        return item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID")
    end

    function Script.Functions.ChildCheck(child)
        if Script.Functions.PromptCondition(child) then
            task.defer(function()
                if not child:GetAttribute("Hold") then child:SetAttribute("Hold", child.HoldDuration) end
                if not child:GetAttribute("Distance") then child:SetAttribute("Distance", child.MaxActivationDistance) end
                if not child:GetAttribute("Enabled") then child:SetAttribute("Enabled", child.Enabled) end
                if not child:GetAttribute("Clip") then child:SetAttribute("Clip", child.RequiresLineOfSight) end
            end)
    
            task.defer(function()
                child.MaxActivationDistance = child:GetAttribute("Distance") * Options.PromptReachMultiplier.Value
        
                if Toggles.InstaInteract.Value then
                    child.HoldDuration = 0
                end
        
                if Toggles.PromptClip.Value and Script.Functions.PromptCondition(child) then
                    child.RequiresLineOfSight = false
                end
            end)
    
            table.insert(PromptTable.GamePrompts, child)
        end
    
        if child:IsA("Model") then
            if child.Name == "ElevatorBreaker" and Toggles.AutoBreakerSolver.Value then
                Script.Functions.SolveBreakerBox(child)
            end
    
            if isMines and Toggles.TheMinesAnticheatBypass.Value and child.Name == "Ladder" then
                Script.Functions.ESP({
                    Type = "None",
                    Object = child,
                    Text = "Ladder",
                    Color = Color3.new(0, 0, 1)
                })
            end
    
            if child.Name == "Snare" and Toggles.AntiSnare.Value then
                child:WaitForChild("Hitbox", 5).CanTouch = false
            end
            if child.Name == "GiggleCeiling" and Toggles.AntiGiggle.Value then
                child:WaitForChild("Hitbox", 5).CanTouch = false
            end
            if (child:GetAttribute("LoadModule") == "DupeRoom" or child:GetAttribute("LoadModule") == "SpaceSideroom") and Toggles.AntiDupe.Value then
                Script.Functions.DisableDupe(child, true, child:GetAttribute("LoadModule") == "SpaceSideroom")
            end
    
            if (isHotel or isFools) and (child.Name == "ChandelierObstruction" or child.Name == "Seek_Arm") and Toggles.AntiSeekObstructions.Value then
                for i,v in pairs(child:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanTouch = false end
                end
            end
    
            if isFools then
                if Toggles.FigureGodmodeFools.Value and child.Name == "FigureRagdoll" then
                    for i, v in pairs(child:GetDescendants()) do
                        if v:IsA("BasePart") then
                            if not v:GetAttribute("Clip") then v:SetAttribute("Clip", v.CanCollide) end
    
                            v.CanTouch = false
    
                            -- woudn't want figure to just dip into the ground
                            task.spawn(function()
                                repeat task.wait() until (latestRoom.Value == 50 or latestRoom.Value == 100)
                                task.wait(5)
                                v.CanCollide = false
                            end)
                        end
                    end
                end
            end
        elseif child:IsA("BasePart") then        
            if child.Name == "Egg" and Toggles.AntiGloomEgg.Value then
                child.CanTouch = false
            end
    
            if Toggles.AntiLag.Value then
                if not child:GetAttribute("Material") then child:SetAttribute("Material", child.Material) end
                if not child:GetAttribute("Reflectance") then child:SetAttribute("Reflectance", child.Reflectance) end
        
                child.Material = Enum.Material.Plastic
                child.Reflectance = 0
            end
    
            if isMines then
                if Toggles.AntiBridgeFall.Value and child.Name == "PlayerBarrier" and child.Size.Y == 2.75 and (child.Rotation.X == 0 or child.Rotation.X == 180) then
                    local clone = child:Clone()
                    clone.CFrame = clone.CFrame * CFrame.new(0, 0, -5)
                    clone.Color = Color3.new(1, 1, 1)
                    clone.Name = "AntiBridge"
                    clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, 11)
                    clone.Transparency = 0
                    clone.Parent = child.Parent
                    
                    table.insert(Script.Temp.Bridges, clone)
                end
            end
        elseif child:IsA("Decal") and Toggles.AntiLag.Value then
            if not child:GetAttribute("Transparency") then child:SetAttribute("Transparency", child.Transparency) end
    
            if not table.find(SlotsName, child.Name) then
                child.Transparency = 1
            end
        end
    end

    function Script.Functions.IsPromptInRange(prompt: ProximityPrompt)
        return Script.Functions.DistanceFromCharacter(prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model") or prompt.Parent) <= prompt.MaxActivationDistance
    end
    
    function Script.Functions.GetNearestAssetWithCondition(condition: () -> ())
        local nearestDistance = math.huge
        local nearest
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if not room:FindFirstChild("Assets") then continue end
    
            for i, v in pairs(room.Assets:GetChildren()) do
                if condition(v) and Script.Functions.DistanceFromCharacter(v) < nearestDistance then
                    nearestDistance = Script.Functions.DistanceFromCharacter(v)
                    nearest = v
                end
            end
        end
    
        return nearest
    end

    function Script.Functions.GetAllPromptsWithCondition(condition)
        assert(typeof(condition) == "function", "Expected a function as condition argument but got " .. typeof(condition))
        
        local validPrompts = {}
        for _, prompt in pairs(PromptTable.GamePrompts) do
            if not prompt or not prompt:IsDescendantOf(workspace) then continue end
    
            local success, returnData = pcall(function()
                return condition(prompt)
            end)
    
            assert(success, "An error has occured while running condition function.\n" .. tostring(returnData))
            assert(typeof(returnData) == "boolean", "Expected condition function to return a boolean")
            
            if returnData then
                table.insert(validPrompts, prompt)
            end
        end
    
        return validPrompts
    end
    
    function Script.Functions.GetNearestPromptWithCondition(condition)
        local prompts = Script.Functions.GetAllPromptsWithCondition(condition)
    
        local nearestPrompt = nil
        local oldHighestDistance = math.huge
        for _, prompt in pairs(prompts) do
            local promptParent = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model")
    
            if promptParent and Script.Functions.DistanceFromCharacter(promptParent) < oldHighestDistance then
                nearestPrompt = prompt
                oldHighestDistance = Script.Functions.DistanceFromCharacter(promptParent)
            end
        end
    
        return nearestPrompt
    end
end

--// Entities Functions \\--
do
    function Script.Functions.DisableDupe(dupeRoom, value, isSpaceRoom)
        if isSpaceRoom then
            local collision = dupeRoom:WaitForChild("Collision", 5)
            
            if collision then
                collision.CanCollide = value
                collision.CanTouch = not value
            end
        else
            local doorFake = dupeRoom:WaitForChild("DoorFake", 5)
            
            if doorFake then
                doorFake:WaitForChild("Hidden", 5).CanTouch = not value
        
                local lock = doorFake:WaitForChild("Lock", 5)
                if lock and lock:FindFirstChild("UnlockPrompt") then
                    lock.UnlockPrompt.Enabled = not value
                end
            end
        end
    end

    function Script.Functions.DeleteSeek(collision: BasePart)
        if not rootPart then return end
    
        task.spawn(function()
            local attemps = 0
            repeat task.wait() attemps += 1 until collision.Parent or attemps > 200
            
            if collision:IsDescendantOf(workspace) and (collision.Parent and collision.Parent.Name == "TriggerEventCollision") then
                Script.Functions.Alert({
                    Title = "Delete Seek FE",
                    Description = "Deleting Seek trigger...",
                    Reason = "",
                })
    
                task.delay(4, function()
                    if collision:IsDescendantOf(workspace) then
                        Script.Functions.Alert({
                            Title = "Delete Seek FE",
                            Description = "Failed to delete Seek trigger!",
                            Reason = "",
                        })
                    end
                end)
                
                if fireTouch then
                    rootPart.Anchored = true
                    task.delay(0.25, function() rootPart.Anchored = false end)
    
                    repeat
                        if collision:IsDescendantOf(workspace) then fireTouch(collision, rootPart, 1) end
                        task.wait()
                        if collision:IsDescendantOf(workspace) then fireTouch(collision, rootPart, 0) end
                        task.wait()
                    until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                else
                    collision:PivotTo(CFrame.new(rootPart.Position))
                    rootPart.Anchored = true
                    repeat task.wait() until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                    rootPart.Anchored = false
                end
                
                if not collision:IsDescendantOf(workspace) then
                    Script.Functions.Log({
                        Title = "Delete Seek FE",
                        Description = "Deleted Seek trigger successfully!",
                    })
                end
            end
        end)
    end

    function Script.Functions.AvoidEntity(value: boolean, oldNoclip: boolean)
        if not rootPart or not collision then return end
    
        local lastCFrame = rootPart.CFrame
        task.wait()
        if value then
            Toggles.Noclip:SetValue(true)
            collision.Position += Vector3.new(0, 24, 0)
            task.wait()
            character:PivotTo(lastCFrame)
        else
            collision.Position -= Vector3.new(0, 24, 0)
            task.wait()
            character:PivotTo(lastCFrame)
            Toggles.Noclip:SetValue(oldNoclip or false)
        end
    end
end

--// Automatization Functions \\--
do
    function Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt: ProximityPrompt)
        if not workspace.CurrentRooms:FindFirstChild(currentRoom) then return {targetWardrobePrompt.Parent} end
    
        local ignore = { targetWardrobePrompt.Parent }
    
        if workspace.CurrentRooms[currentRoom]:FindFirstChild("Assets") then
            for _, asset in pairs(workspace.CurrentRooms[currentRoom].Assets:GetChildren()) do
                if asset.Name == "Pillar" then table.insert(ignore, asset) end
            end
        end
    
        return ignore
    end
    
    function Script.Functions.AutoWardrobe(child, index: number | nil) -- child = entity, ty upio
        if not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace) then
            index = index or table.find(Script.Temp.AutoWardrobeEntities, child)
            if index then
                table.remove(Script.Temp.AutoWardrobeEntities, index)
            end
    
            return
        end
    
        local NotifPrefix = "Auto " .. HidingPlaceName[floor.Value];
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Looking for a hiding place",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Looking for a hiding spot..."
            }, Toggles.AutoWardrobeNotif.Value)
        end)
    
        local entityIndex = #Script.Temp.AutoWardrobeEntities + 1
        Script.Temp.AutoWardrobeEntities[entityIndex] = child
    
        -- Get wardrobe
        local distance = EntityTable.AutoWardrobe.Distance[child.Name].Distance;
        local targetWardrobeChecker = function(prompt)
            if not prompt.Parent then return false end
            if not prompt.Parent:FindFirstChild("HiddenPlayer") then return false end
            if prompt.Parent:FindFirstChild("Main") and prompt.Parent.Main:FindFirstChild("HideEntityOnSpot") then
                if prompt.Parent.Main.HideEntityOnSpot.Whispers.Playing == true then return false end -- Hide
            end
    
            return prompt.Name == "HidePrompt" and (prompt.Parent:GetAttribute("LoadModule") == "Wardrobe" or prompt.Parent:GetAttribute("LoadModule") == "Bed" or prompt.Parent.Name == "Rooms_Locker") and not prompt.Parent.HiddenPlayer.Value and (Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance * Options.PromptReachMultiplier.Value)
        end
        local targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
        local getPrompt = function()
            if not targetWardrobePrompt or Script.Functions.DistanceFromCharacter(targetWardrobePrompt:FindFirstAncestorWhichIsA("Model"):GetPivot().Position) > 15 then
                repeat task.wait()
                    targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
                until targetWardrobePrompt ~= nil or character:GetAttribute("Hiding") or (not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace)) or Library.Unloaded
    
                if (not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace)) or Library.Unloaded then
                    return
                end
            end
        end
        getPrompt()
    
        -- Hide Checks
        if character:GetAttribute("Hiding") then return end
        if not Toggles.AutoWardrobe.Value or not alive or Library.Unloaded then return end  
    
        -- Hide
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Starting...",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Starting..."
            }, Toggles.AutoWardrobeNotif.Value)
        end)
        
        local exclusion = Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt)
        local atempts, maxAtempts = 0, 60
        local isSafeCheck = function(addMoreDist)
            local isSafe = true
            for _, entity in pairs(Script.Temp.AutoWardrobeEntities) do
                if isSafe == false then break end
    
                local distanceEntity = EntityTable.AutoWardrobe.Distance[child.Name].Distance;

                local entityDeleted = (entity == nil or entity.Parent == nil)
                local inView = Script.Functions.IsInViewOfPlayer(entity.PrimaryPart, distanceEntity + (addMoreDist == true and 15 or 0), exclusion)
                local isClose = Script.Functions.DistanceFromCharacter(entity:GetPivot().Position) < distanceEntity + (addMoreDist == true and 15 or 0);
    
                isSafe = entityDeleted == true and true or (inView == false and isClose == false);
                if isSafe == false then break end
            end
    
            return isSafe
        end
        local waitForSafeExit; waitForSafeExit = function()
            if child.Name == "A120" then
                repeat task.wait() until not child:IsDescendantOf(workspace) or (child.PrimaryPart and child.PrimaryPart.Position.Y < -10) or (not alive or not character:GetAttribute("Hiding"))
            else   
                local didPlayerSeeEntity = false
                task.spawn(function()
                    repeat task.wait()
                        if not alive or not child or not child:IsDescendantOf(workspace) then break end
    
                        if character:GetAttribute("Hiding") and Script.Functions.IsInViewOfPlayer(child.PrimaryPart, distance, exclusion) then
                            didPlayerSeeEntity = true
                            break
                        end
                    until false == true
                end)
    
                repeat task.wait(.15)
                    local isSafe = isSafeCheck()
                    if didPlayerSeeEntity == true and isSafe == true then
                        task.spawn(function() 
                            Script.Functions.Log({
                                Title = NotifPrefix,
                                Description = "Exiting the locker, entity is far away.",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is far away."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)
    
                        break
                    else
                        if isSafe == true and not child:IsDescendantOf(workspace) then 
                            task.spawn(function() 
                                Script.Functions.Log({
                                    Title = NotifPrefix,
                                    Description = "Exiting the locker, entity is deleted.",
                                    
                                    LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is deleted."
                                }, Toggles.AutoWardrobeNotif.Value)
                            end)
    
                            break 
                        end          
                    end
    
                    if not alive then  
                        if Toggles.AutoWardrobeNotif.Value then Script.Functions.Log("[" .. NotifPrefix .. "] Stopping (you died).") end             
                        task.spawn(function() 
                            Script.Functions.Log({
                                Title = NotifPrefix,
                                Description = "Stopping (you died)",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Stopping (you died)."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)

                        break 
                    end                             
                until false == true          
            end
    
            return true
        end
        local hide = function()
            if (character:GetAttribute("Hiding") and rootPart.Anchored) then return false end
    
            getPrompt()
            repeat task.wait()
                atempts += 1
    
                forceFirePrompt(targetWardrobePrompt)
            until atempts > maxAtempts or not alive or (character:GetAttribute("Hiding") and rootPart.Anchored)
    
            if atempts > maxAtempts or not alive then return false end
            return true
        end
    
        if child.Name == "AmbushMoving" then
            local LastPos = child:GetPivot().Position
            local IsMoving = false
            task.spawn(function()
                repeat task.wait(0.01)
                    local diff = (LastPos - child:GetPivot().Position) / 0.01
                    LastPos = child:GetPivot().Position
                    IsMoving = diff.Magnitude > 0
                until not child or not child:IsDescendantOf(workspace)
            end)
    
            repeat task.wait()
                task.spawn(function() 
                    Script.Functions.Log({
                        Title = NotifPrefix,
                        Description = "Waiting for Ambush to be close enough...",
        
                        LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for Ambush to be close enough...",
                    }, Toggles.AutoWardrobeNotif.Value)
                end)
    
                repeat task.wait() until (IsMoving == true and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) <= distance) or (not child or not child:IsDescendantOf(workspace))
                if not child or not child:IsDescendantOf(workspace) then break end
                
                local success = hide()
                if success then
                    task.spawn(function() 
                        Script.Functions.Log({
                            Title = NotifPrefix,
                            Description = "Waiting for it to be safe to exit...",
        
                            LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for it to be safe to exit...",
                        }, Toggles.AutoWardrobeNotif.Value)
                    end)
    
                    repeat task.wait() until (IsMoving == false and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) >= distance) or (not child or not child:IsDescendantOf(workspace));
                    if not child or not child:IsDescendantOf(workspace) then break end
    
                    remotesFolder.CamLock:FireServer()
                end
            until (not child or not child:IsDescendantOf(workspace)) or not alive
        else
            repeat task.wait() until isSafeCheck(true, true) == false
    
            repeat
                local success = hide()
                if success then
                    local finished = waitForSafeExit()
                    repeat task.wait() until finished == true        
                    remotesFolder.CamLock:FireServer()
                end
                
                task.wait()
            until isSafeCheck()
        end
    
        table.remove(Script.Temp.AutoWardrobeEntities, entityIndex)
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Finished.",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Finished.",
            }, Toggles.AutoWardrobeNotif.Value)
        end)
    end

    --// Breakers \\--
    function Script.Functions.EnableBreaker(breaker, value)
        breaker:SetAttribute("Enabled", value)
    
        if value then
            breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = -0.2
            breaker.Light.Material = Enum.Material.Neon
            breaker.Light.Attachment.Spark:Emit(1)
            breaker.Sound.Pitch = 1.3
        else
            breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = 0.2
            breaker.Light.Material = Enum.Material.Glass
            breaker.Sound.Pitch = 1.2
        end
    
        breaker.Sound:Play()
    end

    function Script.Functions.SolveBreakerBox(breakerBox)
        if not breakerBox then return end
    
        local code = breakerBox:FindFirstChild("Code", true)
        local correct = breakerBox:FindFirstChild("Correct", true)
    
        repeat task.wait() until code.Text ~= "..." or not breakerBox:IsDescendantOf(workspace)
        if not breakerBox:IsDescendantOf(workspace) then return end
    
        Script.Functions.Alert({
            Title = "Auto Breaker Solver",
            Description = "Solving the breaker box...",
            Reason = ""
        })
    
        if Options.AutoBreakerSolverMethod.Value == "Legit" then
            Script.Temp.UsedBreakers = {}
            if Script.Connections["Reset"] then Script.Connections["Reset"]:Disconnect() end
            if Script.Connections["Code"] then Script.Connections["Code"]:Disconnect() end
    
            local breakers = {}
            for _, breaker in pairs(breakerBox:GetChildren()) do
                if breaker.Name == "BreakerSwitch" then
                    local id = string.format("%02d", breaker:GetAttribute("ID"))
                    breakers[id] = breaker
                end
            end
    
            if code:FindFirstChild("Frame") then
                Script.Functions.AutoBreaker(code, breakers)
    
                Script.Connections["Reset"] = correct:GetPropertyChangedSignal("Playing"):Connect(function()
                    if correct.Playing then table.clear(Script.Temp.UsedBreakers) end
                end)
    
                Script.Connections["Code"] = code:GetPropertyChangedSignal("Text"):Connect(function()
                    task.delay(0.1, Script.Functions.AutoBreaker, code, breakers)
                end)
            end
        else
            repeat task.wait(0.1)
                remotesFolder.EBF:FireServer()
            until not workspace.CurrentRooms["100"]:FindFirstChild("DoorToBreakDown")
    
            Script.Functions.Alert({
                Title = "Auto Breaker Solver",
                Description = "The breaker box has been successfully solved.",
            })
        end
    end
    
    function Script.Functions.AutoBreaker(code, breakers)
        local newCode = code.Text
        if not tonumber(newCode) and newCode ~= "??" then return end
    
        local isEnabled = code.Frame.BackgroundTransparency == 0
    
        local breaker = breakers[newCode]
    
        if newCode == "??" and #Script.Temp.UsedBreakers == 9 then
            for i = 1, 10 do
                local id = string.format("%02d", i)
    
                if not table.find(Script.Temp.UsedBreakers, id) then
                    breaker = breakers[id]
                end
            end
        end
    
        if breaker then
            table.insert(Script.Temp.UsedBreakers, newCode)
            if breaker:GetAttribute("Enabled") ~= isEnabled then
                Script.Functions.EnableBreaker(breaker, isEnabled)
            end
        end
    end

    --// Padlocks \\--
    function Script.Functions.GetPadlockCode(paper: Tool)
        if paper:FindFirstChild("UI") then
            local code = {}
    
            for _, image: ImageLabel in pairs(paper.UI:GetChildren()) do
                if image:IsA("ImageLabel") and tonumber(image.Name) then
                    code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] = {tonumber(image.Name), "_"}
                end
            end
    
            for _, image: ImageLabel in pairs(playerGui.PermUI.Hints:GetChildren()) do
                if image.Name == "Icon" then
                    if code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] then
                        code[image.ImageRectOffset.X .. image.ImageRectOffset.Y][2] = image.TextLabel.Text
                    end
                end
            end
    
            local normalizedCode = {}
            for _, num in pairs(code) do
                normalizedCode[num[1]] = num[2]
            end
    
            return table.concat(normalizedCode)
        end
    
        return "_____"
    end
end

--// Minecarts \\--
do
    local function changeNodeColor(node: Model, color: Color3): Model
        if color == nil then
            node.Color = MinecartPathNodeColor.Yellow
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
        table.insert(MinecartPathfind, buildPathfind) --add to table
    
        Script.Functions.Minecart.DrawNodes()
    
        if Toggles.MinecartTeleport.Value and (lastRoom >= 45 and lastRoom <= 49) then
            Script.Functions.Minecart.NodeDestroy(tonumber(room.Name))
            Script.Functions.Minecart.Teleport(tonumber(room.Name))
        end
    end
    
    function Script.Functions.Minecart.NodeDestroy(roomNum: number)
        local roomConfig = WhitelistConfig[roomNum]
        if not roomConfig then return end
    
        local _firstKeep = roomConfig.firstKeep
        local _lastKeep  = roomConfig.lastKeep
    
        local realNodes = nil
        local fakeNodes = nil
        for _, path: tPathfind in ipairs(MinecartPathfind) do
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
                Script.Functions.Alert({
                    Title = "Minecart Teleport",
                    Description = "Minecart teleport is ready! Waiting for the minecart...",
    
                    Time = progressPart
                })

                local minecartRig
                local minecartRoot
                repeat task.wait(0.1) 
                    minecartRig = camera:FindFirstChild("MinecartRig")
                    if not minecartRig then continue end
                    minecartRoot = minecartRig:FindFirstChild("Root")
                until minecartRig and minecartRoot

                if workspace:FindFirstChild("_internal_mspaint_minecart_teleport") then workspace:FindFirstChild("_internal_mspaint_minecart_teleport"):Destroy() end
                task.wait(3)

                for _, path: tPathfind in ipairs(MinecartPathfind) do
                    local roomOfThePath = path.room_number
    
                    if roomOfThePath >= 45 then -- ignore ground chase
                        local getLastNode = path.real[#path.real]
    
                        repeat 
                            task.wait()
                            minecartRoot.CFrame = getLastNode.CFrame
                        until workspace.CurrentRooms[tostring(currentRoom)]:WaitForChild("Door"):GetAttribute("Opened")
                        task.wait(2)
                        if currentRoom == 49 then break end
                    end
                end
            end)
        end
    end
    
    
    --If ESP Toggle is changed, you can call this function directly.
    function Script.Functions.Minecart.DrawNodes()
        local pathESP_enabled = Toggles.MinecartPathVisualiser.Value
        local espRealColor = pathESP_enabled and MinecartPathNodeColor.Green or MinecartPathNodeColor.Disabled
        
        for idx, path: tPathfind in ipairs(MinecartPathfind) do
            if path.esp and pathESP_enabled then continue end -- if status is unchanged.
    
            --[ESP] Draw the real path
            local realPath = path.real
            for _, _real in pairs(realPath) do
                changeNodeColor(_real, espRealColor)
            end
    
            path.esp = pathESP_enabled --update if path esp status was changed.
        end
    end
end

--// Connections Functions \\--
do
    function Script.Functions.CameraCheck(child)
        if child:IsA("BasePart") and child.Name == "Guidance" and Toggles.GuidingLightESP.Value then
            Script.Functions.GuidingLightEsp(child)
        end
    end

    function Script.Functions.SetupCameraConnection(camera)
        for _, child in pairs(camera:GetChildren()) do
            task.spawn(Script.Functions.CameraCheck, child)
        end
    
        Script.Connections["CameraChildAdded"] = camera.ChildAdded:Connect(function(child)
            task.spawn(Script.Functions.CameraCheck, child)
        end)
    end
    
    function Script.Functions.SetupCurrentRoomConnection(room)
        if Script.Connections["CurrentRoom"] then
            Script.Connections["CurrentRoom"]:Disconnect()
        end
    
        Script.Connections["CurrentRoom"] = room.DescendantAdded:Connect(function(child)
            if Toggles.ItemESP.Value and Script.Functions.ItemCondition(child) then
                Script.Functions.ItemESP(child)
            elseif Toggles.GoldESP.Value and child.Name == "GoldPile" then
                Script.Functions.GoldESP(child)
            end
        end)
    end
    
    function Script.Functions.SetupRoomConnection(room)
        for _, child in pairs(room:GetDescendants()) do
            task.spawn(function()
                if Toggles.DeleteSeek.Value and rootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
    
            task.spawn(Script.Functions.ChildCheck, child)
        end
    
        Script.Connections[room.Name .. "DescendantAdded"] = room.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if Toggles.DeleteSeek.Value and rootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
    
            task.delay(0.1, Script.Functions.ChildCheck, child)
        end)
    end
    
    function Script.Functions.SetupDropConnection(drop)
        if Toggles.ItemESP.Value then
            Script.Functions.ItemESP(drop)
        end
    
        task.spawn(function()
            local prompt = drop:WaitForChild("ModulePrompt", 3)
    
            if prompt then
                table.insert(PromptTable.GamePrompts, prompt)
            end
        end)
    end
    
    function Script.Functions.SetupCharacterConnection(newCharacter)
        character = newCharacter
        if character then
            if Toggles.EnableJump.Value then
                character:SetAttribute("CanJump", true)
            end
    
            for _, oldConnection in pairs(Script.FeatureConnections.Character) do
                oldConnection:Disconnect()
            end
    
            Script.FeatureConnections.Character["ChildAdded"] = character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                    task.wait(0.1)
                    local code = Script.Functions.GetPadlockCode(child)
                    local output, count = string.gsub(code, "_", "x")
                    local padlock = workspace:FindFirstChild("Padlock", true)
    
                    if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                        remotesFolder.PL:FireServer(code)
                    end
    
                    if Toggles.NotifyPadlock.Value and count < 5 then
                        Script.Functions.Alert({
                            Title = "Library Code",
                            Description = string.format("Library Code: %s", output),
                        })
    
                        if Toggles.NotifyChat.Value and count == 0 then
                            RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                        end
                    end
                end
            end)
    
            Script.FeatureConnections.Character["CanJump"] = character:GetAttributeChangedSignal("CanJump"):Connect(function()
                if not character:GetAttribute("CanJump") and Toggles.EnableJump.Value then
                    character:SetAttribute("CanJump", true)
                end
            end)
    
            Script.FeatureConnections.Character["Crouching"] = character:GetAttributeChangedSignal("Crouching"):Connect(function()
                if not character:GetAttribute("Crouching") and Toggles.AntiHearing.Value then
                    remotesFolder.Crouch:FireServer(true)
                end
            end)
    
            Script.FeatureConnections.Character["Hiding"] = character:GetAttributeChangedSignal("Hiding"):Connect(function()
                if not character:GetAttribute("Hiding") then return end
        
                if Toggles.TranslucentHidingSpot.Value then
                    for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                        if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end
        
                        if obj.Value == character then
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
                                until not character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                                
                                for _, part in pairs(affectedParts) do
                                    part.Transparency = 0
                                end
                            end)
        
                            break
                        end
                    end
                end
            end)
    
            Script.FeatureConnections.Character["Oxygen"] = character:GetAttributeChangedSignal("Oxygen"):Connect(function()
                if character:GetAttribute("Oxygen") < 100 and Toggles.NotifyOxygen.Value then
                    if ExecutorSupport["firesignal"] then
                        firesignal(remotesFolder.Caption.OnClientEvent, string.format("Oxygen: %.1f", character:GetAttribute("Oxygen")))
                    else
                        Script.Functions.Captions(string.format("Oxygen: %.1f", character:GetAttribute("Oxygen")))
                    end
                end
            end)
        end
    
        humanoid = character:WaitForChild("Humanoid")
        if humanoid then
            for _, oldConnection in pairs(Script.FeatureConnections.Humanoid) do
                oldConnection:Disconnect()
            end
    
            Script.FeatureConnections.Humanoid["Move"] = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                if Toggles.FastClosetExit.Value and humanoid.MoveDirection.Magnitude > 0 and character:GetAttribute("Hiding") then
                    remotesFolder.CamLock:FireServer()
                end
            end)
    
            Script.FeatureConnections.Humanoid["Jump"] = humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                if not Toggles.SpeedBypass.Value and latestRoom.Value < 100 and not Script.FakeRevive.Enabled then
                    if humanoid.JumpHeight > 0 then
                        lastSpeed = Options.SpeedSlider.Value
                        Options.SpeedSlider:SetMax(3)
                    elseif lastSpeed > 0 then
                        Options.SpeedSlider:SetMax(7)
                        Options.SpeedSlider:SetValue(lastSpeed)
                        lastSpeed = 0
                    end
                end
            end)
    
            Script.FeatureConnections.Humanoid["Died"] = humanoid.Died:Connect(function()
                if collisionClone then
                    collisionClone:Destroy()
                end
    
                if velocityLimiter then
                    velocityLimiter:Destroy()
                end
            end)
    
            if isFools then
                local HoldingAnimation = Instance.new("Animation") do
                    HoldingAnimation.AnimationId = "rbxassetid://10479585177"
                    Script.Temp.ItemHoldTrack = humanoid:LoadAnimation(HoldingAnimation)
                end
    
                local ThrowAnimation = Instance.new("Animation") do
                    ThrowAnimation.AnimationId = "rbxassetid://10482563149"
                    Script.Temp.ItemThrowTrack = humanoid:LoadAnimation(ThrowAnimation)
                end
            end
        end
    
        rootPart = character:WaitForChild("HumanoidRootPart")
        if rootPart then
            local flyBody = Instance.new("BodyVelocity")
            flyBody.Velocity = Vector3.zero
            flyBody.MaxForce = Vector3.one * 9e9
    
            Script.Temp.FlyBody = flyBody
    
            if Toggles.NoAccel.Value then
                Script.Temp.NoAccelValue = rootPart.CustomPhysicalProperties.Density
                
                local existingProperties = rootPart.CustomPhysicalProperties
                rootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
            end
    
            velocityLimiter = Instance.new("LinearVelocity", character)
            velocityLimiter.Enabled = false
            velocityLimiter.MaxForce = math.huge
            velocityLimiter.VectorVelocity = Vector3.new(0, 0, 0)
            velocityLimiter.RelativeTo = Enum.ActuatorRelativeTo.World
            velocityLimiter.Attachment0 = rootPart:WaitForChild("RootAttachment")
    
            Script.FeatureConnections.RootPart["Anchored"] = rootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
                local lastAnchoredDelta = os.time() - Script.Lagback.LastAnchored
    
                if rootPart.Anchored and Toggles.LagbackDetection.Value and Toggles.SpeedBypass.Value and not Script.Lagback.Detected then
                    Script.Lagback.Anchors += 1
                    Script.Lagback.LastAnchored = os.time()
    
                    if Script.Lagback.Anchors >= 2 and lastAnchoredDelta <= Script.Lagback.Threshold then
                        Script.Lagback.Detected = true
                        Script.Lagback.Anchors = 0
                        Script.Lagback.LastSpeed = Options.SpeedSlider.Value
                        Script.Lagback.LastFlySpeed = Options.FlySpeed.Value
    
                        Script.Functions.Alert({
                            Title = "Lagback Detection",
                            Description = "Fixing Lagback...",
                        })
                        Toggles.SpeedBypass:SetValue(false)
                        local cframeChanged = false
    
                        if rootPart.Anchored == true then lastCheck = os.time(); repeat task.wait() until rootPart.Anchored == false or (os.time() - lastCheck) > 5 end
                        task.spawn(function() lastCheck = os.time(); rootPart:GetPropertyChangedSignal("CFrame"):Wait(); cframeChanged = true; end)
                        repeat task.wait() until cframeChanged or (os.time() - lastCheck) > 5
                        if rootPart.Anchored == true then lastCheck = os.time(); repeat task.wait() until rootPart.Anchored == false or (os.time() - lastCheck) > 5 end
    
                        Toggles.SpeedBypass:SetValue(true)
                        Options.SpeedSlider:SetValue(Script.Lagback.LastSpeed)
                        Options.FlySpeed:SetValue(Script.Lagback.LastFlySpeed)
                        Script.Lagback.Detected = false
                        Script.Functions.Alert({
                            Title = "Lagback Detection",
                            Description = "Fixed Lagback!"
                        })
                    end
                end
            end)
        end
    
        collision = character:WaitForChild("Collision")
        if collision then
            if Toggles.UpsideDown.Value then
                collision.Rotation = Vector3.new(collision.Rotation.X, collision.Rotation.Y, -90)
            end
    
            collisionClone = collision:Clone()
            collisionClone.CanCollide = false
            collisionClone.Massless = true
            collisionClone.Name = "CollisionClone"
            if collisionClone:FindFirstChild("CollisionCrouch") then
                collisionClone.CollisionCrouch:Destroy()
            end
    
            collisionClone.Parent = character
        end
    
        if isMines then
            if character then
                Script.Connections["AnticheatBypassTheMines"] = character:GetAttributeChangedSignal("Climbing"):Connect(function()                                
                    if Toggles.TheMinesAnticheatBypass.Value and character:GetAttribute("Climbing") then
                        task.wait(1)
                        character:SetAttribute("Climbing", false)
        
                        bypassed = true
    
                        for _, ladderEsp in pairs(Script.ESPTable.None) do
                            ladderEsp.Destroy()
                        end
    
                        Options.SpeedSlider:SetMax(45)
                        Options.FlySpeed:SetMax(75)
    
                        Script.Functions.Alert({
                            Title = "Anticheat Bypass",
                            Description = "Bypassed the anticheat successfully!",
                            Reason = "This will only last until the next cutscene!",
    
                            LinoriaMessage = "Bypassed the anticheat successfully! This will only last until the next cutscene",
    
                            Time = 7
                        })
                        if workspace:FindFirstChild("_internal_mspaint_acbypassprogress") then workspace:FindFirstChild("_internal_mspaint_acbypassprogress"):Destroy() end
                    end
                end)
            end
    
            if humanoid then
                humanoid.MaxSlopeAngle = Options.MaxSlopeAngle.Value
            end
        end
    end
    
    function Script.Functions.SetupOtherPlayerConnection(player: Player)
        if player.Character then
            if Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player)
            end
        end
    
        Library:GiveSignal(player.CharacterAdded:Connect(function(newCharacter)
            task.delay(0.1, function()
                if Toggles.PlayerESP.Value then
                    Script.Functions.PlayerESP(player)
                end
            end)
    
            Script.Connections[player.Name .. "ChildAdded"] = newCharacter.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                    task.wait(0.1)
                    local code = Script.Functions.GetPadlockCode(child)
                    local output, count = string.gsub(code, "_", "x")
                    local padlock = workspace:FindFirstChild("Padlock", true)
    
                    if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                        remotesFolder.PL:FireServer(code)
                    end
    
                    if Toggles.NotifyPadlock.Value and count < 5 then
                        Script.Functions.Alert({
                            Title = "Padlock Code",
                            Description = string.format("Library Code: %s", output),
                            Reason = (tonumber(code) and "Solved the library padlock code" or "You are still missing some books"),
                        })
    
                        if Toggles.NotifyChat.Value and count == 0 then
                            RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                        end
                    end
                end
            end)
        end))
    end
end

--// Main \\--

local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player") do
    PlayerGroupBox:AddSlider("SpeedSlider", {
        Text = "Speed Boost",
        Default = 0,
        Min = 0,
        Max = 7,
        Rounding = 1
    })

    PlayerGroupBox:AddSlider("VelocityLimiter", {
        Text = "Velocity Limiter",
        Default = 25,
        Min = 0,
        Max = 25,
        Rounding = 1
    })

    PlayerGroupBox:AddToggle("NoAccel", {
        Text = "No Acceleration",
        Default = false
    })

    PlayerGroupBox:AddToggle("InstaInteract", {
        Text = "Instant Interact",
        Default = false
    })

    PlayerGroupBox:AddToggle("FastClosetExit", {
        Text = "Fast Closet Exit",
        Default = false
    })

    PlayerGroupBox:AddDivider()

    PlayerGroupBox:AddToggle("EnableJump", {
        Text = "Enable Jump",
        Default = false,
        Visible = not isFools,
    })

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
        Mode = Library.IsMobile and "Toggle" or "Hold",
        Default = "R",
        Text = "Auto Interact",
        SyncToggleState = Library.IsMobile
    })

    AutomationGroupBox:AddDivider()
    AutomationGroupBox:AddToggle("AutoWardrobeNotif", {
        Text = "Auto " .. HidingPlaceName[floor.Value] .. " Notifications",
        Default = false
    })

    AutomationGroupBox:AddToggle("AutoWardrobe", {
        Text = "Auto " .. HidingPlaceName[floor.Value],
        Default = false,
        Tooltip = "Might fail with multiple entities (Rush & Ambush, 3+ Rush spawns)",
        Visible = not isRetro
    }):AddKeyPicker("AutoWardrobeKey", {
        Mode = "Toggle",
        Default = "Q",
        Text = "Auto " .. HidingPlaceName[floor.Value],
        SyncToggleState = true
    })
    AutomationGroupBox:AddDivider()

    AutomationGroupBox:AddToggle("AutoHeartbeat", {
        Text = "Auto Heartbeat Minigame",
        Default = false,
        Visible = ExecutorSupport["getnamecallmethod"]
    })

    if isHotel or isFools then
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
                for _, player in pairs(Players:GetPlayers()) do
                    if not player.Character then continue end
                    local tool = player.Character:FindFirstChildOfClass("Tool")

                    if tool and tool.Name:match("LibraryHintPaper") then
                        local code = Script.Functions.GetPadlockCode(tool)
                        local padlock = workspace:FindFirstChild("Padlock", true)

                        if tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                            remotesFolder.PL:FireServer(code)
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
    elseif isMines then
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
            remotesFolder.Revive:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Play Again",
        Func = function()
            remotesFolder.PlayAgain:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Lobby",
        Func = function()
            remotesFolder.Lobby:FireServer()
        end,
        DoubleClick = true
    })
end

--// Exploits \\--

local AntiEntityGroupBox = Tabs.Exploits:AddLeftGroupbox("Anti-Entity") do
    AntiEntityGroupBox:AddToggle("AntiHalt", {
        Text = "Anti-Halt",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiScreech", {
        Text = "Anti-Screech",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiDupe", {
        Text = "Anti-" .. (isBackdoor and "Vacuum" or "Dupe"),
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiEyes", {
        Text = "Anti-" .. (isBackdoor and "Lookman" or "Eyes"),
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiSnare", {
        Text = "Anti-Snare",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiHearing", {
        Text = "Anti-Figure Hearing",
        Default = false,
        Visible = not isFools
    })
end

local TrollingGroupBox = Tabs.Exploits:AddLeftGroupbox("Trolling") do
    TrollingGroupBox:AddToggle("SpamOtherTools", {
        Text = "Spam Other Tools",
        Default = false
    }):AddKeyPicker("SpamOtherTools", {
        Default = "X",
        Text = "Spam Other Tools",
        Mode = Library.IsMobile and "Toggle" or "Hold",
        SyncToggleState = Library.IsMobile
    })

    TrollingGroupBox:AddToggle("UpsideDown", {
        Text = "Upside Down",
        Default = false
    })
end

local BypassGroupBox = Tabs.Exploits:AddRightGroupbox("Bypass") do
    BypassGroupBox:AddDropdown("SpeedBypassMethod", {
        AllowNull = false,
        Values = {"Massless", --[["Size"]]},
        Default = "Massless",
        Multi = false,

        Text = "Speed Bypass Method"
    })
    
    BypassGroupBox:AddSlider("SpeedBypassDelay", {
        Text = "Bypass Delay",
        Default = 0.21,
        Min = 0.2,
        Max = 0.22,
        Rounding = 2,
        Compact = true
    })

    BypassGroupBox:AddToggle("SpeedBypass", {
        Text = "Speed Bypass",
        Default = false
    })

    BypassGroupBox:AddToggle("LagbackDetection", {
        Text = "Lagback Detection",
        Default = false
    })

    BypassGroupBox:AddDivider()
    
    BypassGroupBox:AddToggle("InfItems", {
        Text = "Infinite Items",
        Default = false,
        Visible = not isFools
    })

    BypassGroupBox:AddToggle("FakeRevive", {
        Text = "Fake Revive",
        Default = false
    })

    BypassGroupBox:AddToggle("DeleteSeek", {
        Text = "Delete Seek (FE)",
        Default = false
    })
end


--// Visuals \\--

local ESPTabBox = Tabs.Visuals:AddLeftTabbox() do
    local ESPTab = ESPTabBox:AddTab("ESP") do
        ESPTab:AddToggle("DoorESP", {
            Text = "Door",
            Default = false,
        }):AddColorPicker("DoorEspColor", {
            Default = Color3.new(0, 1, 1),
        })
    
        ESPTab:AddToggle("ObjectiveESP", {
            Text = "Objective",
            Default = false,
        }):AddColorPicker("ObjectiveEspColor", {
            Default = Color3.new(0, 1, 0),
        })
    
        ESPTab:AddToggle("EntityESP", {
            Text = "Entity",
            Default = false,
        }):AddColorPicker("EntityEspColor", {
            Default = Color3.new(1, 0, 0),
        })
    
        ESPTab:AddToggle("ItemESP", {
            Text = "Item",
            Default = false,
        }):AddColorPicker("ItemEspColor", {
            Default = Color3.new(1, 0, 1),
        })
    
        ESPTab:AddToggle("ChestESP", {
            Text = "Chest",
            Default = false,
        }):AddColorPicker("ChestEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("PlayerESP", {
            Text = "Player",
            Default = false,
        }):AddColorPicker("PlayerEspColor", {
            Default = Color3.new(1, 1, 1),
        })
    
        ESPTab:AddToggle("HidingSpotESP", {
            Text = HidingPlaceName[floor.Value],
            Default = false,
        }):AddColorPicker("HidingSpotEspColor", {
            Default = Color3.new(0, 0.5, 0),
        })
    
        ESPTab:AddToggle("GoldESP", {
            Text = "Gold",
            Default = false,
        }):AddColorPicker("GoldEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("GuidingLightESP", {
            Text = "Guiding Light",
            Default = false,
        }):AddColorPicker("GuidingLightEspColor", {
            Default = Color3.new(0, 0.5, 1),
        })
    end

    local ESPSettingsTab = ESPTabBox:AddTab("Settings") do
        ESPSettingsTab:AddToggle("ESPHighlight", {
            Text = "Enable Highlight",
            Default = true,
        })

        ESPSettingsTab:AddToggle("ESPTracer", {
            Text = "Enable Tracer",
            Default = true,
        })
    
        ESPSettingsTab:AddToggle("ESPRainbow", {
            Text = "Rainbow ESP",
            Default = false,
        })
    
        ESPSettingsTab:AddToggle("ESPDistance", {
            Text = "Show Distance",
            Default = true
        })
    
        ESPSettingsTab:AddSlider("ESPFillTransparency", {
            Text = "Fill Transparency",
            Default = 0.75,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPOutlineTransparency", {
            Text = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPTextSize", {
            Text = "Text Size",
            Default = 22,
            Min = 16,
            Max = 26,
            Rounding = 0
        })

        ESPSettingsTab:AddDropdown("ESPTracerStart", {
            AllowNull = false,
            Values = {"Bottom", "Center", "Top", "Mouse"},
            Default = "Bottom",
            Multi = false,

            Text = "Tracer Start Position"
        })
    end
end

local AmbientGroupBox = Tabs.Visuals:AddLeftGroupbox("Ambient") do
    AmbientGroupBox:AddSlider("Brightness", {
        Text = "Brightness",
        Default = 0,
        Min = 0,
        Max = 3,
        Rounding = 1,
    })

    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })

    AmbientGroupBox:AddToggle("NoFog", {
        Text = "No Fog",
        Default = false,
    })

    AmbientGroupBox:AddToggle("AntiLag", {
        Text = "Anti-Lag",
        Default = false,
    })
end

local NotifyTabBox = Tabs.Visuals:AddRightTabbox() do
    local NotifyTab = NotifyTabBox:AddTab("Notifier") do
        NotifyTab:AddDropdown("NotifyEntity", {
            AllowNull = true,
            Values = {"Blitz", "Lookman", "Rush", "Ambush", "Eyes", "A60", "A120", "Jeff The Killer", "Gloombat Swarm"},
            Default = {},
            Multi = true,

            Text = "Notify Entities"
        })

        NotifyTab:AddToggle("NotifyPadlock", {
            Text = "Notify Library Code",
            Default = false,
        })

        NotifyTab:AddToggle("NotifyOxygen", {
            Text = "Notify Oxygen",
            Default = false,
        })
    end

    local NotifySettingsTab = NotifyTabBox:AddTab("Settings") do
        NotifySettingsTab:AddToggle("NotifyChat", {
            Text = "Notify Chat",
            Tooltip = "Entity and Padlock Code",
            Default = false,
        })

        NotifySettingsTab:AddDivider()
        
        NotifySettingsTab:AddToggle("NotifySound", {
            Text = "Play Alert Sound",
            Default = true,
        })

        NotifySettingsTab:AddDropdown("NotifySide", {
            AllowNull = false,
            Values = {"Left", "Right"},
            Default = "Right",
            Multi = false,

            Text = "Notification Side"
        })

        NotifySettingsTab:AddDropdown("NotifyStyle", {
            AllowNull = false,
            Values = {"Linoria", "Doors"},
            Default = "Linoria",
            Multi = false,

            Text = "Notification Style"
        })
    end
end

local SelfGroupBox = Tabs.Visuals:AddRightGroupbox("Self") do
    SelfGroupBox:AddToggle("ThirdPerson", {
        Text = "Third Person",
        Default = false
    }):AddKeyPicker("ThirdPersonKey", {
        Default = "V",
        Text = "Third Person",
        Mode = "Toggle",
        SyncToggleState = not Library.IsMobile -- ????
    })
    
    SelfGroupBox:AddSlider("FOV", {
        Text = "Field of View",
        Default = 70,
        Min = 70,
        Max = 120,
        Rounding = 0
    })
    
    SelfGroupBox:AddToggle("NoCamShake", {
        Text = "No Camera Shake",
        Default = false,
        Visible = ExecutorSupport["require"]
    })

    SelfGroupBox:AddToggle("NoCutscenes", {
        Text = "No Cutscenes",
        Default = false,
    })

    SelfGroupBox:AddToggle("TranslucentHidingSpot", {
        Text = "Translucent " .. HidingPlaceName[floor.Value],
        Default = false
    })
    
    SelfGroupBox:AddSlider("HidingTransparency", {
        Text = "Hiding Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Compact = true,
    })
end

--// Floor \\--
task.spawn(function()
    if isHotel then
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

        local Hotel_ModifiersGroupBox = Tabs.Floor:AddRightGroupbox("Modifiers") do
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

        Toggles.AntiA90:OnChanged(function(value)
            if not mainGame then return end
            local module = mainGame:FindFirstChild("A90", true) or mainGame:FindFirstChild("_A90", true)
        
            if module then
                module.Name = value and "_A90" or "A90"
            end
        end)

        Toggles.NoJammin:OnChanged(function(value)
            if not liveModifiers:FindFirstChild("Jammin") then return end

            if mainGame then
                local jamSound = mainGame:FindFirstChild("Jam", true)
                if jamSound then jamSound.Playing = not value end
            end

            local jamminEffect = SoundService:FindFirstChild("Jamming", true)
            if jamminEffect then jamminEffect.Enabled = not value end
        end)
    elseif isMines then
        local Mines_MovementGroupBox = Tabs.Floor:AddLeftGroupbox("Movement") do
            Mines_MovementGroupBox:AddToggle("FastLadder", {
                Text = "Fast Ladder",
                Default = false
            })

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
        end

        local Mines_AutomationGroupBox = Tabs.Floor:AddRightGroupbox("Automation") do
            Mines_AutomationGroupBox:AddButton({
                Text = "Beat Door 200",
                Func = function()
                    if latestRoom.Value < 99 then
                        Script.Functions.Alert({
                            Title = "Beat Door 200",
                            Description = "You haven't reached door 200...",
                            Time = 5
                        })

                        return
                    end

                    local bypassing = Toggles.SpeedBypass.Value
                    local startPos = rootPart.CFrame

                    Toggles.SpeedBypass:SetValue(false)

                    local damHandler = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("_DamHandler")

                    if damHandler then
                        if damHandler:FindFirstChild("PlayerBarriers1") then
                            for _, pump in pairs(damHandler.Flood1.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                forceFirePrompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            task.wait(8)
                        end

                        if damHandler:FindFirstChild("PlayerBarriers2") then
                            for _, pump in pairs(damHandler.Flood2.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                forceFirePrompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            task.wait(8)
                        end

                        if damHandler:FindFirstChild("PlayerBarriers3") then
                            for _, pump in pairs(damHandler.Flood3.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                forceFirePrompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            task.wait(10)
                        end
                    end

                    local generator = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("MinesGenerator", true)

                    if generator then
                        character:PivotTo(generator.PrimaryPart.CFrame)
                        task.wait(0.25)
                        forceFirePrompt(generator.Lever.LeverPrompt)
                        task.wait(0.25)
                    end

                    Toggles.SpeedBypass:SetValue(bypassing)
                    character:PivotTo(startPos)
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
                Text = "Show Correct Minecart Path",
                Default = false
            })
        end

        Toggles.TheMinesAnticheatBypass:OnChanged(function(value)
            if value then
                local progressPart = Instance.new("Part", Workspace) do
                    progressPart.Anchored = true
                    progressPart.CanCollide = false
                    progressPart.Name = "_internal_mspaint_acbypassprogress"
                    progressPart.Transparency = 1
                end

                if Library.IsMobile then
                    Script.Functions.Alert({
                        Title = "Anticheat bypass",
                        Description = "To bypass the ac, you must interact with a ladder.",
                        Reason = "Ladder ESP has been enabled, do not move while on the ladder.",

                        LinoriaMessage = "To bypass the anticheat, you must interact with a ladder. Ladder ESP has been enabled.\nDo not move while on the ladder.",
                        Time = progressPart
                    })
                else
                    Script.Functions.Alert({
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

                if bypassed and not Script.FakeRevive.Enabled then
                    remotesFolder.ClimbLadder:FireServer()
                    bypassed = false
                    
                    Options.SpeedSlider:SetMax(Toggles.SpeedBypass.Value and 45 or (Toggles.EnableJump.Value and 3 or 7))
                    Options.FlySpeed:SetMax(Toggles.SpeedBypass.Value and 75 or 22)
                end
            end
        end)

        Options.MaxSlopeAngle:OnChanged(function(value)
            if humanoid then
                humanoid.MaxSlopeAngle = value
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

        Toggles.MinecartPathVisualiser:OnChanged(function(value)
            Script.Functions.Minecart.DrawNodes()
        end)
    elseif isBackdoor then
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
            local clientRemote = ReplicatedStorage.FloorReplicated.ClientRemote
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

        Library:GiveSignal(floorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(function()
            if Toggles.HasteClock.Value and floorReplicated.ScaryStartsNow.Value then
                Script.Functions.Captions(Script.Functions.TimerFormat(floorReplicated.DigitalTimer.Value))
            end
        end))
    elseif isRooms then
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
                Script.Functions.Alert({
                    Title = "Auto Rooms",
                    Description = "Anti A-90 is required for Auto Rooms to work!",
                    Reason = "Anti A-90 has been enabled",
                })
                
                Toggles.AntiA90:SetValue(true)
            end

            if not mainGame then return end
            local module = mainGame:FindFirstChild("A90", true) or mainGame:FindFirstChild("_A90", true)
        
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

            return workspace.CurrentRooms[latestRoom.Value].Door.Door
        end

        local _internal_mspaint_pathfinding_nodes = Instance.new("Folder", Workspace) do
            _internal_mspaint_pathfinding_nodes.Name = "_internal_mspaint_pathfinding_nodes"
        end

        Toggles.ShowAutoRoomsPathNodes:OnChanged(function(value)
            for _, node in pairs(_internal_mspaint_pathfinding_nodes:GetChildren()) do
                node.Transparency = value and 0.5 or 1
            end
        end)

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not Toggles.AutoRooms.Value then return end

            local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
            local isEntitySpawned = (entity and entity.PrimaryPart.Position.Y > -10)
            
            if isEntitySpawned and not rootPart.Anchored then
                local pathfindingGoal = Script.Functions.GetAutoRoomsPathfindingGoal()

                if Script.Functions.IsPromptInRange(pathfindingGoal.Parent.HidePrompt) then
                    forceFirePrompt(pathfindingGoal.Parent.HidePrompt)
                end
            elseif not isEntitySpawned and rootPart.Anchored then
                for i = 1, 10 do
                    remotesFolder.CamLock:FireServer()
                end
            end
        end))

        Toggles.AutoRooms:OnChanged(function(value)
            local function moveToCleanup()
                if humanoid then
                    humanoid:Move(rootPart.Position)
                    humanoid.WalkToPart = nil
                    humanoid.WalkToPoint = rootPart.Position
                end
            end

            if value then
                Toggles.AntiA90:SetValue(true)

                local function doAutoRooms()
                    local pathfindingGoal = Script.Functions.GetAutoRoomsPathfindingGoal()

                    Script.Functions.Log({
                        Title = "Auto Rooms",
                        Description = "Calculated Objective Successfully!\nObjective: " .. pathfindingGoal.Parent.Name .. "\nCreating path...",
                    }, Toggles.AutoRoomsDebug.Value)

                    local path = PathfindingService:CreatePath({
                        AgentCanJump = false,
                        AgentCanClimb = false,
                        WaypointSpacing = 2,
                        AgentRadius = 1
                    })

                    Script.Functions.Log({
                        Title = "Auto Rooms",
                        Description = "Computing Path to " .. pathfindingGoal.Parent.Name .. "...",
                    }, Toggles.AutoRoomsDebug.Value)

                    path:ComputeAsync(rootPart.Position - Vector3.new(0, 2.5, 0), pathfindingGoal.Position)
                    local waypoints = path:GetWaypoints()

                    if path.Status == Enum.PathStatus.Success then
                        Script.Functions.Log({
                            Title = "Auto Rooms",
                            Description = "Computed path successfully with " .. #waypoints .. " waypoints!",
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

                        for i, waypoint in pairs(waypoints) do
                            local moveToFinished = false
                            local recalculate = false
                            local waypointConnection = humanoid.MoveToFinished:Connect(function() moveToFinished = true end)

                            if not moveToFinished or not Toggles.AutoRooms.Value then
                                humanoid:MoveTo(waypoint.Position)
                                
                                task.delay(1.5, function()
                                    if moveToFinished then return end
                                    if (not Toggles.AutoRooms.Value or Library.Unloaded) then return moveToCleanup() end

                                    repeat task.wait() until (not character:GetAttribute("Hiding") and not character.PrimaryPart.Anchored)

                                    Script.Functions.Alert({
                                        Title = "Auto Rooms",
                                        Description = "Seems like you are stuck, trying to recalculate path...",
                                        Reason = "Failed to move to waypoint",
                                    })

                                    recalculate = true
                                end)
                            end

                            repeat task.wait() until moveToFinished or not Toggles.AutoRooms.Value or recalculate or Library.Unloaded

                            waypointConnection:Disconnect()

                            if not Toggles.AutoRooms.Value then
                                _internal_mspaint_pathfinding_nodes:ClearAllChildren()
                                break
                            else
                                if _internal_mspaint_pathfinding_nodes:FindFirstChild("_internal_node_" .. i) then
                                    _internal_mspaint_pathfinding_nodes:FindFirstChild("_internal_node_" .. i):Destroy()
                                end
                            end

                            if recalculate then break end
                        end
                    else
                        Script.Functions.Log({
                            Title = "Auto Rooms",
                            Description = "Pathfinding failed with status " .. tostring(path.Status)   
                        }, Toggles.AutoRoomsDebug.Value)
                    end
                end

                -- Movement
                while Toggles.AutoRooms.Value and not Library.Unloaded do
                    if latestRoom.Value == 1000 then
                        Script.Functions.Alert({
                            Title = "Auto Rooms",
                            Description = "You have reached A-1000",
                            Reason = "A-1000 reached by mspaint autorooms",
                        })

                        break
                    end

                    doAutoRooms()
                end
                
                -- Unload Auto Rooms
                _internal_mspaint_pathfinding_nodes:ClearAllChildren()
                moveToCleanup()
            end
        end)
    elseif isFools then
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

                Script.Temp.ItemHoldTrack:Stop()
                Script.Temp.ItemThrowTrack:Play()

                task.wait(0.35)

                if target:FindFirstChildWhichIsA("BodyGyro") then
                    target:FindFirstChildWhichIsA("BodyGyro"):Destroy()
                end

                local velocity = localPlayer:GetMouse().Hit.LookVector * 0.5 * 200 * Options.ThrowStrength.Value
                local spawnPos = camera.CFrame:ToWorldSpace(CFrame.new(0,0,-3) * CFrame.lookAt(Vector3.new(0, 0, 0), camera.CFrame.LookVector))
                
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
                            repeat task.wait() until isnetowner(jeff.PrimaryPart)
                            jeff:FindFirstChildOfClass("Humanoid").Health = 0
                        end)
                    end
                end
            end
        end)

        Toggles.InfRevives:OnChanged(function(value)
            if value and not localPlayer:GetAttribute("Alive") then
                remotesFolder.Revive:FireServer()
            end
        end)

        Toggles.GodmodeNoclipBypassFools:OnChanged(function(value)
            if value and humanoid and collision then
                humanoid.HipHeight = 3.01
                task.wait()
                collision.Position = collision.Position - Vector3.new(0, 8, 0)
                task.wait()
                humanoid.HipHeight = 3
                
                -- don't want to put collision up when you load the script 
                -- im sorry deivid
                task.spawn(function()
                    repeat task.wait() until not Toggles.GodmodeNoclipBypassFools.Value
                    humanoid.HipHeight = 3.01
                    task.wait()
                    collision.Position = collision.Position + Vector3.new(0, 8, 0)
                    task.wait()
                    humanoid.HipHeight = 3
                end)
            end
        end)

        Toggles.FigureGodmodeFools:OnChanged(function(value)
            if value and not Toggles.GodmodeNoclipBypassFools.Value then Toggles.GodmodeNoclipBypassFools:SetValue(true); Script.Functions.Alert({Title = "Figure Godmode", Description = "Godmode/Noclip Bypass is required to use figure godmode", Reason = "Godmode/Noclip Bypass not enabled"}) end
            if latestRoom.Value ~= 50 or latestRoom.Value ~= 100 then return end

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
end)

--// Features Callback \\--
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

Toggles.NoAccel:OnChanged(function(value)
    if not rootPart then return end

    if value then
        Script.Temp.NoAccelValue = rootPart.CustomPhysicalProperties.Density
        
        local existingProperties = rootPart.CustomPhysicalProperties
        rootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    else
        local existingProperties = rootPart.CustomPhysicalProperties
        rootPart.CustomPhysicalProperties = PhysicalProperties.new(Script.Temp.NoAccelValue, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    end
end)

Toggles.EnableJump:OnChanged(function(value)
    if isFools then return end

    if character then
        character:SetAttribute("CanJump", value)
    end

    if not value and not Toggles.SpeedBypass.Value and Options.SpeedSlider.Max ~= 7 and not Script.FakeRevive.Enabled then
        Options.SpeedSlider:SetMax(7)
    end
end)

Toggles.Fly:OnChanged(function(value)
    if not rootPart then return end

    if humanoid then
        humanoid.PlatformStand = value
    end

    Script.Temp.FlyBody.Parent = value and rootPart or nil

    if value then
        Script.Connections["Fly"] = RunService.RenderStepped:Connect(function()
            local velocity = Vector3.zero

            if controlModule then
                local moveVector = controlModule:GetMoveVector()
                velocity = -((camera.CFrame.LookVector * moveVector.Z) - (camera.CFrame.RightVector * moveVector.X))
            else
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity += camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity -= camera.CFrame.RightVector end
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity += camera.CFrame.UpVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity -= camera.CFrame.UpVector end
            
            Script.Temp.FlyBody.Velocity = velocity * Options.FlySpeed.Value
        end)
    else
        if Script.Connections["Fly"] then
            Script.Connections["Fly"]:Disconnect()
        end
    end
end)

Toggles.PromptClip:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do        
        if Script.Functions.PromptCondition(prompt) then
            if value then
                prompt.RequiresLineOfSight = false
            else
                if prompt:GetAttribute("Enabled") and prompt:GetAttribute("Clip") then
                    prompt.Enabled = prompt:GetAttribute("Enabled")
                    prompt.RequiresLineOfSight = prompt:GetAttribute("Clip")
                end
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

Toggles.AntiHalt:OnChanged(function(value)
    if not entityModules then return end
    local module = entityModules:FindFirstChild("Shade") or entityModules:FindFirstChild("_Shade")

    if module then
        module.Name = value and "_Shade" or "Shade"
    end
end)

Toggles.AntiScreech:OnChanged(function(value)
    if not mainGame then return end
    local module = mainGame:FindFirstChild("Screech", true) or mainGame:FindFirstChild("_Screech", true)

    if module then
        module.Name = value and "_Screech" or "Screech"
    end
end)

Toggles.AntiDupe:OnChanged(function(value)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        for _, dupeRoom in pairs(room:GetChildren()) do
            if dupeRoom:GetAttribute("LoadModule") == "DupeRoom" or dupeRoom:GetAttribute("LoadModule") == "SpaceSideroom" then
                task.spawn(function() Script.Functions.DisableDupe(dupeRoom, value, dupeRoom:GetAttribute("LoadModule") == "SpaceSideroom") end)
            end
        end
    end
end)

Toggles.AntiSnare:OnChanged(function(value)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if not room:FindFirstChild("Assets") then continue end

        for _, snare in pairs(room.Assets:GetChildren()) do
            if snare.Name == "Snare" then
                snare:WaitForChild("Hitbox", 5).CanTouch = not value
            end
        end
    end
end)

Toggles.AntiHearing:OnChanged(function(value)
    if isFools then return end
    remotesFolder.Crouch:FireServer(value)
end)

Toggles.UpsideDown:OnChanged(function(value)
    if not collision then return end
    
    -- im sorry deivid
    if value then
        local rotation = collision.Rotation
        collision.Rotation = Vector3.new(rotation.X, rotation.Y, -90)

        task.spawn(function()
            repeat task.wait() until not Toggles.UpsideDown.Value or Library.Unloaded
            
            if collision then
                rotation = collision.Rotation
    
                collision.Rotation = Vector3.new(rotation.X, rotation.Y, 90)
            end
        end)
    end
end)

function Script.Functions.SpeedBypass()
    if speedBypassing then return end
    speedBypassing = true

    local SpeedBypassMethod = Options.SpeedBypassMethod.Value

    local function cleanup()
        -- reset if changed speed bypass method
        speedBypassing = false

        if collisionClone then
            if SpeedBypassMethod == "Massless" then
                collisionClone.Massless = true
            elseif SpeedBypassMethod == "Size" then
                collisionClone.Size = Vector3.new(3, 5.5, 3)
            end
            
            if Toggles.SpeedBypass.Value and Options.SpeedBypassMethod.Value ~= SpeedBypassMethod and not Script.FakeRevive.Enabled then
                Script.Functions.SpeedBypass()
            end
        end
    end

    task.spawn(function()
        if SpeedBypassMethod == "Massless" then
            while Toggles.SpeedBypass.Value and collisionClone and Options.SpeedBypassMethod.Value == SpeedBypassMethod and not Library.Unloaded and not Script.FakeRevive.Enabled do
                collisionClone.Massless = not collisionClone.Massless
                task.wait(Options.SpeedBypassDelay.Value)
            end
    
            cleanup()
        elseif SpeedBypassMethod == "Size" then
            while Toggles.SpeedBypass.Value and collisionClone and Options.SpeedBypassMethod.Value == SpeedBypassMethod and not Library.Unloaded and not Script.FakeRevive.Enabled do
                collisionClone.Size = Vector3.new(3, 5.5, 3)
                task.wait(Options.SpeedBypassDelay.Value)
                collisionClone.Size = Vector3.new(1.5, 2.75, 1.5)
                task.wait(Options.SpeedBypassDelay.Value)
            end
    
            cleanup()
        end
    end)
end

Toggles.SpeedBypass:OnChanged(function(value)
    if value then
        Options.SpeedSlider:SetMax(45)
        Options.FlySpeed:SetMax(75)
        
        Script.Functions.SpeedBypass()
    else
        if Script.FakeRevive.Enabled then return end

        local speed = if bypassed then 45 elseif Toggles.EnableJump.Value then 3 else 7

        Options.SpeedSlider:SetMax(speed)
        Options.FlySpeed:SetMax((isMines and Toggles.TheMinesAnticheatBypass.Value and bypassed) and 75 or 22)
    end
end)

Toggles.FakeRevive:OnChanged(function(value)
    if value and alive and character and not Script.FakeRevive.Enabled then
        if latestRoom and latestRoom.Value == 0 then
            Script.Functions.Alert({
                Title = "Fake Revive",
                Description = "You have to open the next door to use fake revive",
                Reason = "You are in the first room"
            })
            repeat task.wait() until latestRoom.Value > 0
        end

        Script.Functions.Alert({
            Title = "Fake Revive",
            Description = "Please find a way to die or wait for around 20 seconds\nfor fake revive to work.",
            Reason = "You are not yet dead",
            Time = 20
        })
        
        local oxygenModule = mainGame:FindFirstChild("Oxygen")
        local healthModule = mainGame:FindFirstChild("Health")
        local cameraModule = mainGame:FindFirstChild("Camera")
        local inventoryModule = mainGame:FindFirstChild("Inventory")

        if oxygenModule and healthModule then
            task.delay(0.5, function()
                if not Toggles.FakeRevive.Value then return end

                oxygenModule.Enabled = false
                healthModule.Enabled = false
                inventoryModule.Enabled = false
            end)
        end

        repeat task.wait(.25)
            remotesFolder.Underwater:FireServer(true)
        until not alive or not Toggles.FakeRevive.Value

        if alive and not Toggles.FakeRevive.Value then
            remotesFolder.Underwater:FireServer(false)
            Script.Functions.Alert({
                Title = "Fake Revive",
                Description = "Fake revive has been disabled, was unable to kill player.",
                Reason = "You are not yet dead",
            })
            oxygenModule.Enabled = true
            healthModule.Enabled = true
            return
        end

        Toggles.SpeedBypass:SetValue(false)
        Options.SpeedSlider:SetMax(45)
        Options.FlySpeed:SetMax(75)

        Script.FakeRevive.Enabled = true
        workspace.Gravity = 0

        if cameraModule then
            cameraModule.Enabled = false
        end

        task.wait(0.1)
        for _, hotbarItem in pairs(mainUI.MainFrame.Hotbar:GetChildren()) do
            if not hotbarItem:IsA("TextButton") then continue end
            hotbarItem.Visible = false
        end

        local tool = Instance.new("Tool") do
            tool.RequiresHandle = false
            tool.Name = "AttachTool"
            tool.Parent = character

            humanoid.Name = "old_Humanoid"
            local newHumanoid = humanoid:Clone()
            newHumanoid.Parent = character
            newHumanoid.Name = "Humanoid"

            task.wait()

            humanoid:Destroy()
            camera.CameraSubject = character
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

            local determined_cframe = rootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
            rootPart.CFrame = determined_cframe
            
            local atempts = 0
            repeat task.wait()
                atempts = atempts + 1
                rootPart.CFrame = determined_cframe
            until (tool.Parent ~= character or not rootPart or not rootPart.Parent or atempts > 250) and atempts > 2
            tool:Destroy()
        end

        -- setup character
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "UpperTorso" and part.Name ~= "Collision" and part.Parent.Name ~= "Collision" then 
                --v.CanCollide = false
                part.Massless = true
                part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 1, 1)
            end
        end

        for _, weld in pairs(character:GetChildren()) do
            if weld:IsA("Weld") then
                weld:Destroy()
            end
        end

        camera:Destroy()
        task.wait(.1)
        workspace.CurrentCamera.CameraSubject = character:FindFirstChildWhichIsA('Humanoid')
        workspace.CurrentCamera.CameraType = "Custom"
        localPlayer.CameraMinZoomDistance = 0.5
        localPlayer.CameraMaxZoomDistance = 400
        localPlayer.CameraMode = "Classic"
        character.Head.Anchored = false
        camera = workspace.CurrentCamera

        -- setup fake char
        local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
        humanoidDescription.HeightScale = 1.2

        local previewCharacter = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15) do
            previewCharacter.Parent = Workspace
            previewCharacter.Name = "PreviewCharacter"

            previewCharacter.HumanoidRootPart.Anchored = true
            character.UpperTorso.CanCollide = false
        end

        Script.FakeRevive.Connections["HidingFix"] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if UserInputService:GetFocusedTextBox() then return end
            if gameProcessed then return end

            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
                if character:GetAttribute("Hiding") then
                    for i = 1, 50 do
                        task.wait()
                        remotesFolder.CamLock:FireServer()
                    end
                end
            end
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["HidingFix"])

        -- animation setup
        task.spawn(function()
            local anims = character:WaitForChild("Animations", 10) or previewCharacter:WaitForChild("Animations", 10);
            local crouch, oldCrouchSpeed = previewCharacter.Humanoid:LoadAnimation(anims.Crouch), 0;
            local walk, idle = previewCharacter.Humanoid:LoadAnimation(anims.Forward), previewCharacter.Humanoid:LoadAnimation(anims.Idle);
            local interact = previewCharacter.Humanoid:LoadAnimation(anims.Interact);
            oldCrouchSpeed = crouch.Speed;

            local function playWalkingAnim(key)
                repeat
                    if idle.isPlaying then idle:Stop() end

                    if character:GetAttribute("Crouching") then
                        if not crouch.isPlaying then crouch:Play() crouch:AdjustSpeed(oldCrouchSpeed) end
                        if walk.isPlaying then walk:Stop() end
                    else
                        if crouch.isPlaying then crouch:Stop() end
                        if not walk.isPlaying then walk:Play() end
                    end

                    task.wait(.5)
                until not UserInputService:IsKeyDown(key) and not UserInputService:GetFocusedTextBox()
            end

            Script.FakeRevive.Connections["AnimationHandler"] = UserInputService.InputBegan:Connect(function(input)
                if UserInputService:GetFocusedTextBox() then return end
                if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
                    playWalkingAnim(input.KeyCode)
                end
            end)

            Library:GiveSignal(Script.FakeRevive.Connections["AnimationHandler"])

            Script.FakeRevive.Connections["AnimationHandler2"] = UserInputService.InputEnded:Connect(function(input)
                if UserInputService:GetFocusedTextBox() then return end

                if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
                    task.wait(.1)
                    if walk.isPlaying then walk:Stop() end
                    if character:GetAttribute("Crouching") then 
                        if not crouch.isPlaying then crouch:Play() end
                        crouch:AdjustSpeed(0)
                    else 
                        if crouch.isPlaying then crouch:Stop() end 
                    end
                    if not idle.isPlaying then idle:Play() end
                end
            end)

            Library:GiveSignal(Script.FakeRevive.Connections["AnimationHandler2"])

            -- Tool Handler (kinda broken) --
            if character:WaitForChild("RightHand", math.huge) then
                local rightGrip = Instance.new("Weld", character.RightHand)
                rightGrip.C0 = CFrame.new(0, -0.15, -1.5, 1, 0, -0, 0, 0, 1, 0, -1, 0)
                rightGrip.Part0 = character.RightHand
        
                local toolsAnim = {}
                local currentTool = nil
                local doorInteractables = { "Key", "Lockpick" }

                Script.FakeRevive.Connections["ToolAnimHandler"] = character.ChildAdded:Connect(function(tool)
                    if tool:IsA("Tool") then
                        for _, anim in pairs(toolsAnim) do
                            anim:Stop()
                        end
        
                        table.clear(toolsAnim)
        
                        local anims = tool:WaitForChild("Animations")
                        currentTool = tool
        
                        for i, v in pairs(anims:GetChildren()) do
                            if v:IsA("Animation") then
                                toolsAnim[v.Name] = previewCharacter.Humanoid:LoadAnimation(v)
                            end
                        end
        
                        if toolsAnim.idle then toolsAnim.idle:Play(0.4, 1, 1) end
                        if toolsAnim.equip then toolsAnim.equip:Play(0.05, 1, 1) end
        
                        local toolHandle = tool:WaitForChild("Handle", 3)
                        if toolHandle and character:FindFirstChild("RightHand") then
                            rightGrip.Parent = character.RightHand
                            rightGrip.C1 = tool.Grip
                            rightGrip.Part1 = toolHandle        
                        end
        
                        local animation_state = false
                        tool.Activated:Connect(function()
                            if table.find(doorInteractables, tool.Name) then return end
        
                            local anim = toolsAnim.use or (tool:GetAttribute("LightSource") and toolsAnim.open)
        
                            if anim then
                                if ExecutorSupport["require"] then require(tool.ToolModule).fire() end
                                local toolRemote = tool:FindFirstChild("Remote")
                                if toolRemote then
                                    toolRemote:FireServer()
                                end

                                if tool:GetAttribute("LightSource") then
                                    if animation_state then
                                        anim:Stop()
                                    else
                                        anim:Play()
                                    end
                                    
                                    animation_state = not animation_state
                                    return
                                end
        
                                anim:Play()
                            end
                        end)
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimHandler"])
        
                -- Prompts handler
                local holding, holdStart, startDurability = false, 0, 0
                Script.FakeRevive.Connections["ToolAnimHandler2"] = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                    if (currentTool and table.find(doorInteractables, currentTool.Name)) and (prompt.Name == "UnlockPrompt" and prompt.Parent.Name == "Lock") then
                        holding = true; holdStart = tick(); startDurability = currentTool:GetAttribute("Durability")
                        
                        toolsAnim.use:Play()
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimHandler2"])

                Script.FakeRevive.Connections["ToolAnimInteractHandler"] = ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
                    if (currentTool and table.find(doorInteractables, currentTool.Name)) and (prompt.Name == "UnlockPrompt" and prompt.Parent.Name == "Lock") then
                        if holdStart == 0 then return end
        
                        if startDurability and currentTool:GetAttribute("Durability") < startDurability then
                            toolsAnim.use:Stop()
                            toolsAnim.usebreak:Play()
        
                            return
                        end
                        
                        if holding and tick() - holdStart > prompt.HoldDuration then
                            holding = false; holdStart = 0
        
                            toolsAnim.use:Stop()
                            toolsAnim.usefinish:Play()
                            
                            return
                        end
        
                        holding = false; holdStart = 0
        
                        toolsAnim.use:Stop()
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimInteractHandler"])
                
                Script.FakeRevive.Connections["ToolAnimUnequipHandler"] = character.ChildRemoved:Connect(function(v)
                    if v:IsA("Tool") then
                        rightGrip.Part1 = nil
                        rightGrip.C1 = CFrame.new()
                        rightGrip.Parent = nil
        
                        for _, anim in pairs(toolsAnim) do
                            anim:Stop()
                        end
        
                        currentTool = nil
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimUnequipHandler"])
            end
        end)

        -- movement code
        local function generateCharacterCFrame(obj)
            local obj_pos = obj.Position
            return CFrame.new(obj_pos, obj_pos - (Vector3.new(camera.CFrame.Position.X, obj_pos.Y, camera.CFrame.Position.Z) - obj_pos).unit)
        end

        local function usePreviewCharacter(doStepped)
            -- fuck you roblox for using head instead of primarypart or char:GetPivot() 
            -- mstudio45 2023 ^^
            if ExecutorSupport["hookmetamethod"] and ExecutorSupport["getnamecallmethod"] then
                _fixDistanceFromCharacter = hookmetamethod(localPlayer, "__namecall", function(self, ...)
                    local method = getnamecallmethod();
                    local args = {...}
                
                    if method == "DistanceFromCharacter" then
                        if typeof(args[1]) == "Vector3" then
                            return Script.Functions.DistanceFromCharacter(args[1])
                        end
                        
                        return 9999;
                    end
                
                    return _fixDistanceFromCharacter(self, ...)
                end)
            end

            if doStepped ~= false then
                Library:Notify("You are not longer visible to others because you have lost Network Ownership of your character.", 5);

                for _,v in pairs(previewCharacter:GetDescendants()) do
                    if v:IsA("BasePart") then 
                        v.CanCollide = false
                    end
                end

                for _, connection in pairs(Script.FakeRevive.Connections) do
                    connection:Disconnect()
                end
                
                table.clear(Script.FakeRevive.Connections)
            end

            if previewCharacter:FindFirstChild("Humanoid") then previewCharacter.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
            
            Toggles.Fly:SetValue(true)

            Library:GiveSignal(RunService.RenderStepped:Connect(function()
                if doStepped ~= false then previewCharacter:PivotTo(generateCharacterCFrame(character:GetPivot())) end
                if rootPart then 
                    rootPart.Transparency = (doStepped ~= false) and 1 or 0
                    rootPart.CanCollide = false
                end
            end))
        end

        if character:FindFirstChild("LeftFoot") then character.LeftFoot.CanCollide = true end
        if character:FindFirstChild("RightFoot") then character.RightFoot.CanCollide = true end
        
        Script.FakeRevive.Connections["mainStepped"] = RunService.RenderStepped:Connect(function()
            -- deivid gonna get mad at this line :content:
            if character:FindFirstChild("Humanoid") then character.Humanoid.WalkSpeed = 15 + Options.SpeedSlider.Value end
            

            if rootPart and rootPart.Position.Y < -150 then
                rootPart.Position = workspace.SpawnLocation.Position
            end

            if character:FindFirstChild("UpperTorso") then
                character.UpperTorso.CanCollide = false 
            else
                if character:FindFirstChild("HumanoidRootPart") then 
                    local totalParts = 0
                    for _, v in pairs(character:GetChildren()) do if v:IsA("BasePart") then totalParts = totalParts + 1 end end
                    if totalParts <= 2 then
                        task.spawn(usePreviewCharacter)
                        Script.FakeRevive.Connections["mainStepped"]:Disconnect()

                        for _, connection in pairs(Script.FakeRevive.Connections) do
                            connection:Disconnect()
                        end
                        
                        table.clear(Script.FakeRevive.Connections)
                        return
                    end
                end
            end

            if not character:FindFirstChild("HumanoidRootPart") then
                Library:Notify("You have completely lost Network Ownership of your character which resulted of breaking Fake Death.", 5);
                task.spawn(usePreviewCharacter, false)
                Script.FakeRevive.Connections["mainStepped"]:Disconnect()

                for _, connection in pairs(Script.FakeRevive.Connections) do
                    connection:Disconnect()
                end
                
                table.clear(Script.FakeRevive.Connections)
                return
            end
            
            previewCharacter:PivotTo(generateCharacterCFrame(rootPart.CFrame * CFrame.new(0,1000,0)))

            local charPartCFrames = {}
            for _, part in ipairs(previewCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    charPartCFrames[part.Name..part.ClassName] = part.CFrame
                end
            end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "RagdollCollision" then
                        part.CFrame = (charPartCFrames[part.Parent.Name .. part.Parent.ClassName] - Vector3.new(0,1000,0))
                        part.CanCollide = true
                    else
                        if charPartCFrames[part.Name..part.ClassName] then
                            part.CFrame = (charPartCFrames[part.Name..part.ClassName] - Vector3.new(0,1000,0))
                        end
                    end
                    
                    if part.Name ~= "HumanoidRootPart" then
                        if part.Parent == character or part.Parent:IsA("Accessory") then
                            part.LocalTransparencyModifier = 0
                        end

                        part.AssemblyAngularVelocity = Vector3.zero
                        part.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["mainStepped"])

        task.wait(0.1)
        local function fixUI()
            local setComponentVisibility = {
                mainUI.HodlerRevive,
                mainUI.Statistics,
                
                mainUI.DeathPanelDead,
                mainUI.DeathPanel,

                mainUI.MainFrame.Healthbar,

                ["visible_real"] = mainUI.MainFrame.PromptFrame.CenterImage,
                ["deivid_ballers_fake"] = mainUI.MainFrame.PromptFrame.Holder,

                mainUI.MainFrame.Hotbar,
                mainUI.MainFrame.InventoryCap,
                mainUI.MainFrame.InventoryLeftArrow,
                mainUI.MainFrame.InventoryRightArrow,
            }

            for i,v in pairs(setComponentVisibility) do
                local target_visibility = (typeof(i) == "string" and true or false)

                v:GetPropertyChangedSignal("Visible"):Connect(function()
                    v.Visible = target_visibility
                end)

                v.Visible = target_visibility
            end

            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        end

        task.spawn(fixUI)

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseIcon = "rbxassetid://2833720882"

        task.wait()
        character.HumanoidRootPart.Anchored = false

        if mainGameSrc then mainGameSrc.dead = false end
        
        ProximityPromptService.Enabled = true
        Script.FakeRevive.Connections["ProximityPromptEnabler"] = ProximityPromptService:GetPropertyChangedSignal("Enabled"):Connect(function()
            ProximityPromptService.Enabled = true
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["ProximityPromptEnabler"])

        workspace.Gravity = 90

        -- ESP Fix :smartindividual:
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            task.spawn(function()
                local roomDetectPart = room:WaitForChild(room.Name, math.huge)
                if roomDetectPart then
                    roomDetectPart.Size = Vector3.new(roomDetectPart.Size.X, roomDetectPart.Size.Y * 250, roomDetectPart.Size.Z)

                    local touchEvent = roomDetectPart.Touched:Connect(function(hit)
                        if hit.Parent == localPlayer.Character and not Script.FakeRevive.Debounce then
                            Script.FakeRevive.Debounce = true
                            localPlayer:SetAttribute("CurrentRoom", tonumber(room.Name))
                            
                            task.wait(0.075)
                            Script.FakeRevive.Debounce = false
                        end
                    end)
                    
                    table.insert(Script.FakeRevive.Connections, touchEvent)
                    Library:GiveSignal(touchEvent)
                end
            end)
        end

        Script.FakeRevive.Connections["CurrentRoomFix"] = workspace.CurrentRooms.ChildAdded:Connect(function(room)
            local roomDetectPart = room:WaitForChild(room.Name, math.huge)

            if roomDetectPart then
                roomDetectPart.Size = Vector3.new(roomDetectPart.Size.X, roomDetectPart.Size.Y * 100, roomDetectPart.Size.Z)

                local touchEvent = roomDetectPart.Touched:Connect(function(hit)
                    if hit.Parent == localPlayer.Character and not Script.FakeRevive.Debounce then
                        Script.FakeRevive.Debounce = true
                        localPlayer:SetAttribute("CurrentRoom", tonumber(room.Name))

                        task.wait(0.075)
                        Script.FakeRevive.Debounce = false
                    end
                end)
                
                table.insert(Script.FakeRevive.Connections, touchEvent)
                Library:GiveSignal(touchEvent)
            end
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["CurrentRoomFix"])

        Script.Functions.Alert({
            Title = "Fake Revive",
            Description = "Fake Revive is now initialized, have fun!",
            Reason = 'You are now "dead"',
        })
    end
end)

Toggles.DoorESP:OnChanged(function(value)
    if value then
        if workspace.CurrentRooms[currentRoom]:FindFirstChild("Door") then
            Script.Functions.DoorESP(workspace.CurrentRooms[currentRoom])
        end

        if workspace.CurrentRooms[nextRoom]:FindFirstChild("Door") then
            Script.Functions.DoorESP(workspace.CurrentRooms[nextRoom])
        end
    else
        for _, connection in pairs(Script.FeatureConnections.Door) do
            connection:Disconnect()
        end

        for _, esp in pairs(Script.ESPTable.Door) do
            esp.Destroy()
        end
    end
end)

Options.DoorEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Door) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ObjectiveESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, asset in pairs(currentRoomModel:GetDescendants()) do
                task.spawn(Script.Functions.ObjectiveESP, asset)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Objective) do
            esp.Destroy()
        end
    end
end)

Options.ObjectiveEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Objective) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.EntityESP:OnChanged(function(value)
    if value then
        for _, entity in pairs(workspace:GetChildren()) do
            if table.find(EntityTable.Names, entity.Name) then
                Script.Functions.EntityESP(entity)
            end
        end

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, entity in pairs(currentRoomModel:GetDescendants()) do
                if table.find(EntityTable.SideNames, entity.Name) then
                    Script.Functions.SideEntityESP(entity)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Entity) do
            esp.Destroy()
        end
        for _, esp in pairs(Script.ESPTable.SideEntity) do
            esp.Destroy()
        end
    end
end)

Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ItemESP:OnChanged(function(value)
    if value then
        for _, item in pairs(workspace.Drops:GetChildren()) do
            if Script.Functions.ItemCondition(item) then
                Script.Functions.ItemESP(item)
            end
        end

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, item in pairs(currentRoomModel:GetDescendants()) do
                if Script.Functions.ItemCondition(item) then
                    Script.Functions.ItemESP(item)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Item) do
            esp.Destroy()
        end
    end
end)

Options.ItemEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Item) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ChestESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, chest in pairs(currentRoomModel:GetDescendants()) do
                if chest:GetAttribute("Storage") == "ChestBox" or chest.Name == "Toolshed_Small" then
                    Script.Functions.ChestESP(chest)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Chest) do
            esp.Destroy()
        end
    end
end)

Options.ChestEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Chest) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.PlayerESP:OnChanged(function(value)
    if value then
        for _, player in pairs(Players:GetPlayers()) do
            if player == localPlayer or not player.Character then continue end
            
            Script.Functions.PlayerESP(player)
        end
    else
        for _, connection in pairs(Script.FeatureConnections.Player) do
            connection:Disconnect()
        end
        for _, esp in pairs(Script.ESPTable.Player) do
            esp.Destroy()
        end
    end
end)

Options.PlayerEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Player) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.HidingSpotESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, wardrobe in pairs(currentRoomModel:GetDescendants()) do
                if wardrobe:GetAttribute("LoadModule") == "Wardrobe" or wardrobe:GetAttribute("LoadModule") == "Bed" or wardrobe.Name == "Rooms_Locker" or wardrobe.Name == "RetroWardrobe" then
                    Script.Functions.HidingSpotESP(wardrobe)
                end
            end
        end 
    else
        for _, esp in pairs(Script.ESPTable.HidingSpot) do
            esp.Destroy()
        end
    end
end)

Options.HidingSpotEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.HidingSpot) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.GoldESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, gold in pairs(currentRoomModel:GetDescendants()) do
                if gold.Name == "GoldPile" then
                    Script.Functions.GoldESP(gold)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Gold) do
            esp.Destroy()
        end
    end
end)

Options.GoldEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Gold) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.GuidingLightESP:OnChanged(function(value)
    if value then
        for _, guidance in pairs(camera:GetChildren()) do
            if guidance:IsA("BasePart") and guidance.Name == "Guidance" then
                Script.Functions.GuidingLightEsp(guidance)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Guiding) do
            esp.Destroy()
        end
    end
end)

Options.GuidingLightEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Guiding) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ESPHighlight:OnChanged(function(value)
    warn("changing highlight to", value)

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.SetVisible(value, false)
        end
    end
end)

Toggles.ESPTracer:OnChanged(function(value)
    ESPLibrary.Tracers.Set(value)
end)

Toggles.ESPRainbow:OnChanged(function(value)
    ESPLibrary.Rainbow.Set(value)
end)

Toggles.ESPDistance:OnChanged(function(value)
    ESPLibrary.Distance.Set(value)
end)

Options.ESPFillTransparency:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ FillTransparency = value })
        end
    end
end)

Options.ESPOutlineTransparency:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ OutlineTransparency = value })
        end
    end
end)

Options.ESPTextSize:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ TextSize = value })
        end
    end
end)

Options.ESPTracerStart:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ Tracer = { From = value } })
        end
    end
end)

Options.Brightness:OnChanged(function(value)
    Lighting.Brightness = value
end)

Toggles.Fullbright:OnChanged(function(value)
    if value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        if alive then
            Lighting.Ambient = workspace.CurrentRooms[localPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
end)

Toggles.NoFog:OnChanged(function(value)
    if not Lighting:GetAttribute("FogStart") then Lighting:SetAttribute("FogStart", Lighting.FogStart) end
    if not Lighting:GetAttribute("FogEnd") then Lighting:SetAttribute("FogEnd", Lighting.FogEnd) end

    Lighting.FogStart = value and 0 or Lighting:GetAttribute("FogStart")
    Lighting.FogEnd = value and math.huge or Lighting:GetAttribute("FogEnd")

    local fog = Lighting:FindFirstChildOfClass("Atmosphere")
    if fog then
        if not fog:GetAttribute("Density") then fog:SetAttribute("Density", fog.Density) end

        fog.Density = value and 0 or fog:GetAttribute("Density")
    end
end)

Toggles.AntiLag:OnChanged(function(value)
    for _, object in pairs(workspace.CurrentRooms:GetDescendants()) do
        if object:IsA("BasePart") then
            if not object:GetAttribute("Material") then object:SetAttribute("Material", object.Material) end
            if not object:GetAttribute("Reflectance") then object:SetAttribute("Reflectance", object.Reflectance) end

            object.Material = value and Enum.Material.Plastic or object:GetAttribute("Material")
            object.Reflectance = value and 0 or object:GetAttribute("Reflectance")
        elseif object:IsA("Decal") then
            if not object:GetAttribute("Transparency") then object:SetAttribute("Transparency", object.Transparency) end

            if not table.find(SlotsName, object.Name) then
                object.Transparency = value and 1 or object:GetAttribute("Transparency")
            end
        end
    end

    workspace.Terrain.WaterReflectance = value and 0 or 1
    workspace.Terrain.WaterTransparency = value and 0 or 1
    workspace.Terrain.WaterWaveSize = value and 0 or 0.05
    workspace.Terrain.WaterWaveSpeed = value and 0 or 8
    Lighting.GlobalShadows = not value
end)

Options.NotifySide:OnChanged(function(value)
    Library.NotifySide = value
end)

Toggles.NoCutscenes:OnChanged(function(value)
    if mainGame then
        local cutscenes = mainGame:FindFirstChild("Cutscenes", true)
        if cutscenes then
            for _, cutscene in pairs(cutscenes:GetChildren()) do
                if table.find(CutsceneExclude, cutscene.Name) then continue end
    
                local defaultName = cutscene.Name:gsub("_", "")
                cutscene.Name = value and "_" .. defaultName or defaultName
            end
        end
    end

    if floorReplicated then
        for _, cutscene in pairs(floorReplicated:GetChildren()) do
            if not cutscene:IsA("ModuleScript") or table.find(CutsceneExclude, cutscene.Name) then continue end

            local defaultName = cutscene.Name:gsub("_", "")
            cutscene.Name = value and "_" .. defaultName or defaultName
        end
    end
end)

Toggles.TranslucentHidingSpot:OnChanged(function(value)
    if value and character:GetAttribute("Hiding") then
        for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
            if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end

            if obj.Value == character then
                task.spawn(function()
                    local affectedParts = {}
                    for _, v in pairs(obj.Parent:GetChildren()) do
                        if not v:IsA("BasePart") then continue end

                        v.Transparency = Options.HidingTransparency.Value
                        table.insert(affectedParts, v)
                    end

                    repeat task.wait()
                        for _, part in pairs(affectedParts) do
                            task.wait()
                            part.Transparency = Options.HidingTransparency.Value
                        end
                    until not character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                    
                    for _, v in pairs(affectedParts) do
                        v.Transparency = 0
                    end
                end)

                break
            end
        end
    end
end)

--// Connections \\--

if ExecutorSupport["hookmetamethod"] and ExecutorSupport["getnamecallmethod"] then
    mtHook = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local namecallMethod = getnamecallmethod()
    
        if namecallMethod == "FireServer" then
            if self.Name == "ClutchHeartbeat" and Toggles.AutoHeartbeat.Value then
                return
            elseif self.Name == "Crouch" and Toggles.AntiHearing.Value then
                args[1] = true
                return mtHook(self, unpack(args))
            end
        elseif namecallMethod == "Destroy" and self.Name == "RunnerNodes" then
            return
        end
    
        return mtHook(self, ...)
    end)
end

if isBackdoor then
    local clientRemote = floorReplicated.ClientRemote
    local haste_incoming_progress = nil

    Library:GiveSignal(clientRemote.Haste.Remote.OnClientEvent:Connect(function(value)
        if not value and Toggles.NotifyEntity.Value then
            haste_incoming_progress = Instance.new("Part", Workspace) do
                haste_incoming_progress.Anchored = true
                haste_incoming_progress.CanCollide = false
                haste_incoming_progress.Name = "_internal_mspaint_haste"
                haste_incoming_progress.Transparency = 1
            end

            Script.Functions.Alert({
                Title = "ENTITIES",
                Description = "Haste is incoming, please find a lever ASAP!",
                Time = haste_incoming_progress,

                Warning = true
            })

            repeat task.wait() until not haste_incoming_progress or not Toggles.NotifyEntity.Value or not character:GetAttribute("Alive")
            if haste_incoming_progress then haste_incoming_progress:Destroy() end
        end
        
        if value and haste_incoming_progress then
            haste_incoming_progress:Destroy()
        end
    end))
end

Library:GiveSignal(ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player ~= localPlayer or not character or isFools then return end
    
    local isDoorLock = prompt.Name == "UnlockPrompt" and prompt.Parent.Name == "Lock" and not prompt.Parent.Parent:GetAttribute("Opened")
    local isSkeletonDoor = prompt.Name == "SkullPrompt" and prompt.Parent.Name == "SkullLock" and not (prompt.Parent:FindFirstChild("Door") and prompt.Parent.Door.Transparency == 1)
    local isChestBox = prompt.Name == "ActivateEventPrompt" and prompt.Parent.Name == "ChestBoxLocked" and prompt.Parent:GetAttribute("Locked")
    local isRoomsDoorLock = prompt.Parent.Parent.Parent.Name == "RoomsDoor_Entrance" and prompt.Enabled
    
    if isDoorLock or isSkeletonDoor or isChestBox or isRoomsDoorLock then
        local equippedTool = character:FindFirstChildOfClass("Tool")
        local toolId = equippedTool and equippedTool:GetAttribute("ID")

        if Toggles.InfItems.Value and equippedTool and equippedTool:GetAttribute("UniversalKey") then
            task.wait(isChestBox and 0.15 or 0)
            remotesFolder.DropItem:FireServer(equippedTool)

            task.spawn(function()
                equippedTool.Destroying:Wait() 
                task.wait(0.15)

                local itemPickupPrompt = Script.Functions.GetNearestPromptWithCondition(function(prompt)
                    return prompt.Name == "ModulePrompt" and prompt.Parent:GetAttribute("Tool_ID") == toolId
                end)

                if itemPickupPrompt then
                    firePrompt(itemPickupPrompt)
                end
            end)
        end
    end
end))

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        local shortName = Script.Functions.GetShortName(child.Name)

        if table.find(EntityTable.Names, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 750 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    if isHotel and Toggles.AvoidRushAmbush.Value and table.find(EntityTable.Avoid, child.Name) then
                        local oldNoclip = Toggles.Noclip.Value
                        local distance = Script.Functions.DistanceFromCharacter(child)

                        task.spawn(function()
                            repeat 
                                RunService.Heartbeat:Wait()
                                distance = Script.Functions.DistanceFromCharacter(child)
                            until distance <= 150 or not child:IsDescendantOf(workspace)

                            if child:IsDescendantOf(workspace) then
                                Script.Functions.AvoidEntity(true)
                                repeat task.wait() until not child:IsDescendantOf(workspace)
                                Script.Functions.AvoidEntity(false, oldNoclip)
                            end
                        end)
                    end

                    if table.find(EntityTable.AutoWardrobe.Entities, child.Name) then
                        local distance = EntityTable.AutoWardrobe.Distance[child.Name].Loader

                        task.spawn(function()
                            repeat RunService.Heartbeat:Wait() until not child:IsDescendantOf(workspace) or Script.Functions.DistanceFromCharacter(child) <= distance

                            if child:IsDescendantOf(workspace) and Toggles.AutoWardrobe.Value then
                                Script.Functions.AutoWardrobe(child)
                            end
                        end)
                    end
                    
                    if isFools and child.Name == "RushMoving" then
                        shortName = child.PrimaryPart.Name:gsub("New", "")
                    end

                    if Toggles.EntityESP.Value then
                        Script.Functions.EntityESP(child)  
                    end

                    if Options.NotifyEntity.Value[shortName] == true then
                        Script.Functions.Alert({
                            Title = "ENTITIES",
                            Description = shortName .. " has spawned!",
                            Reason = (not EntityTable.NotifyReason[child.Name].Spawned and "Go find a hiding place!" or nil),
                            Image = EntityTable.NotifyReason[child.Name].Image,

                            Warning = true
                        })

                        if Toggles.NotifyChat.Value then
                            RBXGeneral:SendAsync(shortName .. " has spawned!")
                        end
                    end
                end
            end)
        elseif EntityTable.NotifyMessage[child.Name] and Options.NotifyEntity.Value[shortName] then
            Script.Functions.Alert({
                Title = "ENTITIES",
                Description = shortName .. " has spawned!",
                Reason = (not EntityTable.NotifyReason[child.Name].Spawned and "Go find a hiding place!" or nil),
                Image = EntityTable.NotifyReason[child.Name].Image,

                Warning = true
            })

            if Toggles.NotifyChat.Value then
                RBXGeneral:SendAsync(EntityTable.NotifyMessage[child.Name])     
            end
        end

        if isFools then
            if Toggles.AntiBananaPeel.Value and child.Name == "BananaPeel" then
                child.CanTouch = false
            end

            if Toggles.AntiJeffClient.Value and child.Name == "JeffTheKiller" then
                for i, v in pairs(child:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = false
                    end
                end
            end

            if Toggles.AntiJeffServer.Value and child.Name == "JeffTheKiller" then
                task.spawn(function()
                    repeat task.wait() until isnetowner(child.PrimaryPart)
                    child:FindFirstChildOfClass("Humanoid").Health = 0
                end)
            end
        end

        if (child.Name == "RushMoving" or child.Name == "AmbushMoving") and Toggles.InfItems.Value and alive and character then
            task.wait(1.5)
            
            local hasStoppedMoving = false --entity has stoped
            local lastPosition = child:GetPivot().Position
            local lastVelocity = Vector3.new(0, 0, 0)

            local frameCount = 0
            local nextTimer = tick()
            local maxSavedFrames = 10 --after that we can ignore velocity by 0
            local currentSavedFrames = 0
            local physicsTickRate = (1 / 60) * 0.90 --usually is stable also wtf roblox why 60 Hz isn't (1 / 60) ????

            local oldFrameHz = 0
            local frameHz = 0
            local frameRate = 1 -- in seconds
            local nextTimerHz = tick()

            local entityName = child.Name

            local crucifixConnection; crucifixConnection = RunService.RenderStepped:Connect(function(deltaTime)
                if not Toggles.InfItems.Value or not alive or not character then crucifixConnection:Disconnect() return end

                local currentTimer = tick()
                frameCount += 1 
                frameHz += 1

                -- get the client FPS
                if currentTimer - nextTimerHz >= frameRate then
                    oldFrameHz = frameHz;
                    frameHz = 0
                    nextTimerHz = currentTimer
                    physicsTickRate = (1 / oldFrameHz) * 0.90
                end

                -- refresh rate (client) must be equal to the physics rate (server) for making the calculations properly.
                if physicsTickRate == 0 or not (currentTimer - nextTimer >= physicsTickRate) then
                    return
                end

                frameCount = 0
                nextTimer = currentTimer
            
                local currentPosition = child:GetPivot().Position
                -- Calculate velocity
                local velocity = (currentPosition - lastPosition) / deltaTime
                velocity = Vector3.new(velocity.X, 0, velocity.Z) -- Ignore Y
            
                -- Smooth velocity
                local smoothedVelocity = lastVelocity:Lerp(velocity, 0.3) --we do math stuff
                local entityVelocity = math.floor(smoothedVelocity.Magnitude)
            
                lastVelocity = smoothedVelocity
                lastPosition = currentPosition
            
            
                local inView = Script.Functions.IsInViewOfPlayer(child, EntityTable.InfCrucifixVelocity[entityName].minDistance)
                local distanceFromPlayer = (child:GetPivot().Position - character:GetPivot().Position).Magnitude
                local isInRangeOfPlayer = distanceFromPlayer <= EntityTable.InfCrucifixVelocity[entityName].minDistance
                --[[if currentSavedFrames < maxSavedFrames then
                    print(string.format("[In range: %s | In view: %s] [Hz: %d] - Entity velocity is: %.2f | Distance: %.2f | Delta: %.2f", tostring(isInRangeOfPlayer), tostring(inView), oldFrameHz, entityVelocity, distanceFromPlayer, 0))
                end]]
            
                if entityVelocity <= EntityTable.InfCrucifixVelocity[entityName].threshold then
                    if entityVelocity <= 0.5 and currentSavedFrames <= maxSavedFrames then
                        currentSavedFrames += 1
                    end
            
                    --switch and trigger a print
                    if not hasStoppedMoving then
                        --print("Entity has stopped moving!")
                        hasStoppedMoving = true
                    end
            
                    -- --ignore if raycast is false
                    if not inView then
                        return
                    end
            
                    --ignore if distance is greater than X
                    if not isInRangeOfPlayer then
                        return
                    end

                    if character:FindFirstChild("Crucifix") then
                        workspace.Drops.ChildAdded:Once(function(droppedItem)
                            if droppedItem.Name == "Crucifix" then
                                local targetProximityPrompt = droppedItem:WaitForChild("ModulePrompt", 3) or droppedItem:FindFirstChildOfClass("ProximityPrompt")
                                repeat task.wait()
                                    firePrompt(targetProximityPrompt)
                                until not droppedItem:IsDescendantOf(workspace)
                            end
                        end)

                        remotesFolder.DropItem:FireServer(character.Crucifix);
                    end

                    return
                end

                currentSavedFrames = 0
                if hasStoppedMoving then
                    --print("Entity started moving!")
                    hasStoppedMoving = false
                end
            end)
            
            local childRemovedConnection; childRemovedConnection = workspace.ChildRemoved:Connect(function(model: Model)
                if model ~= child then return end

                crucifixConnection:Disconnect()
                childRemovedConnection:Disconnect()
            end)

            Library:GiveSignal(crucifixConnection)
            Library:GiveSignal(childRemovedConnection)
        end

    end)
end))

for _, drop in pairs(workspace.Drops:GetChildren()) do
    task.spawn(Script.Functions.SetupDropConnection, drop)
end
Library:GiveSignal(workspace.Drops.ChildAdded:Connect(function(child)
    task.spawn(Script.Functions.SetupDropConnection, child)
end))

for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
    task.spawn(Script.Functions.SetupRoomConnection, room)
end
Library:GiveSignal(workspace.CurrentRooms.ChildAdded:Connect(function(room)
    task.spawn(Script.Functions.SetupRoomConnection, room)
    
    if isMines then
        task.spawn(Script.Functions.Minecart.Pathfind, room, tonumber(room.Name))
    end
end))


if camera then task.spawn(Script.Functions.SetupCameraConnection, camera) end
Library:GiveSignal(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        camera = workspace.CurrentCamera
        task.spawn(Script.Functions.SetupCameraConnection, camera)
    end
end))

for _, player in pairs(Players:GetPlayers()) do
    if player == localPlayer then continue end
    Script.Functions.SetupOtherPlayerConnection(player)
end
Library:GiveSignal(Players.PlayerAdded:Connect(function(player)
    if player == localPlayer then return end
    Script.Functions.SetupOtherPlayerConnection(player)
end))

Library:GiveSignal(localPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
    if Script.FakeRevive.Enabled then
        Script.FakeRevive.Enabled = false

        for _, connection in pairs(Script.FakeRevive.Connections) do
            connection:Disconnect()
        end
        
        table.clear(Script.FakeRevive.Connections)

        if Toggles.FakeRevive.Value then
            Script.Functions.Alert({
                Title = "Fake Revive",
                Description = "You have revived, fake revive has stopped working.",
                Reason = "Enable it again to start fake revive",

                LinoriaMessage = "Fake Revive has stopped working, enable it again to start fake revive",
            })
            Toggles.FakeRevive:SetValue(false)
        end

        if isMines and Toggles.EnableJump.Value then
            Options.SpeedSlider:SetMax((Toggles.TheMinesAnticheatBypass.Value and bypassed) and 45 or 3)
        else
            Options.SpeedSlider:SetMax((isMines and Toggles.TheMinesAnticheatBypass.Value and bypassed) and 45 or 7)
        end

        Options.FlySpeed:SetMax((isMines and Toggles.TheMinesAnticheatBypass.Value and bypassed) and 75 or 22)
    end
end))

Library:GiveSignal(localPlayer.OnTeleport:Connect(function(state)
    if (state == Enum.TeleportState.RequestedFromServer or state == state == Enum.TeleportState.Started) and Toggles.ExecuteOnTeleport.Value then
        queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/main/main.lua"))()]])
    end
end))

Library:GiveSignal(localPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    alive = localPlayer:GetAttribute("Alive")

    if not alive and isFools and Toggles.InfRevives.Value then
        task.delay(1.25, function()
            remotesFolder.Revive:FireServer()
        end)
    end
end))

if workspace.CurrentRooms:FindFirstChild(currentRoom) then
    task.spawn(Script.Functions.SetupCurrentRoomConnection, workspace.CurrentRooms[currentRoom])
end
Library:GiveSignal(localPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    currentRoom = localPlayer:GetAttribute("CurrentRoom")
    nextRoom = currentRoom + 1
    task.spawn(Script.Functions.UpdateRPC)

    local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
    local nextRoomModel = workspace.CurrentRooms:FindFirstChild(nextRoom)

    if isMines and bypassed and currentRoomModel:GetAttribute("RawName") == "HaltHallway" then
        bypassed = false
        Script.Functions.Alert({
            Title = "Anticheat Bypass",
            Description = "Halt has broken anticheat bypass.",
            Reason = "Please go on a ladder again to fix it.",

            LinoriaMessage = "Halt has broken anticheat bypass, please go on a ladder again to fix it.",
        })

        Options.SpeedSlider:SetMax(Toggles.SpeedBypass.Value and 45 or (Toggles.EnableJump.Value and 3 or 7))
        Options.FlySpeed:SetMax(Toggles.SpeedBypass.Value and 75 or 22)
    end

    if Toggles.DoorESP.Value then
        for _, doorEsp in pairs(Script.ESPTable.Door) do
            doorEsp.Destroy()
        end

        if currentRoomModel then
            task.spawn(Script.Functions.DoorESP, currentRoomModel)
        end

        if nextRoomModel then
            task.spawn(Script.Functions.DoorESP, nextRoomModel)
        end
    end
    if Toggles.ObjectiveESP.Value then
        for _, objectiveEsp in pairs(Script.ESPTable.Objective) do
            objectiveEsp.Destroy()
        end
    end
    if Toggles.EntityESP.Value then
        for _, sideEntityESP in pairs(Script.ESPTable.SideEntity) do
            sideEntityESP.Destroy()
        end
    end
    if Toggles.ItemESP.Value then
        for _, itemEsp in pairs(Script.ESPTable.Item) do
            itemEsp.Destroy()
        end
    end
    if Toggles.ChestESP.Value then
        for _, chestEsp in pairs(Script.ESPTable.Chest) do
            chestEsp.Destroy()
        end
    end
    if Toggles.HidingSpotESP.Value then
        for _, hidingSpotEsp in pairs(Script.ESPTable.HidingSpot) do
            hidingSpotEsp.Destroy()
        end
    end
    if Toggles.GoldESP.Value then
        for _, goldEsp in pairs(Script.ESPTable.Gold) do
            goldEsp.Destroy()
        end
    end

    if currentRoomModel then
        for _, asset in pairs(currentRoomModel:GetDescendants()) do
            if Toggles.ObjectiveESP.Value then
                task.spawn(Script.Functions.ObjectiveESP, asset)
            end

            if Toggles.EntityESP.Value and table.find(EntityTable.SideNames, asset.Name) then    
                task.spawn(Script.Functions.SideEntityESP, asset)
            end
    
            if Toggles.ItemESP.Value and Script.Functions.ItemCondition(asset) then
                task.spawn(Script.Functions.ItemESP, asset)
            end

            if Toggles.ChestESP.Value and (asset:GetAttribute("Storage") == "ChestBox" or asset.Name == "Toolshed_Small") then
                task.spawn(Script.Functions.ChestESP, asset)
            end

            if Toggles.HidingSpotESP.Value and (asset:GetAttribute("LoadModule") == "Wardrobe" or asset:GetAttribute("LoadModule") == "Bed" or asset.Name == "Rooms_Locker" or asset.Name == "RetroWardrobe") then
                Script.Functions.HidingSpotESP(asset)
            end

            if Toggles.GoldESP.Value and asset.Name == "GoldPile" then
                Script.Functions.GoldESP(asset)
            end
        end
    
        Script.Functions.SetupCurrentRoomConnection(currentRoomModel)
    end
end))

Library:GiveSignal(playerGui.ChildAdded:Connect(function(child)
    if child.Name == "MainUI" then
        mainUI = child

        task.delay(1, function()
            if mainUI then
                mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")

                if mainGame then
                    if ExecutorSupport["require"] then mainGameSrc = require(mainGame) end

                    if mainGame:WaitForChild("Health", 5) then
                        if isHotel and Toggles.NoJammin.Value and liveModifiers:FindFirstChild("Jammin") then
                            local jamSound = mainGame:FindFirstChild("Jam", true)
                            if jamSound then jamSound.Playing = false end
                        end
                    end

                    if mainGame:WaitForChild("RemoteListener", 5) then
                        if Toggles.AntiScreech.Value then
                            local module = mainGame:FindFirstChild("Screech", true)
    
                            if module then
                                module.Name = "_Screech"
                            end
                        end
                        if (isHotel or isRooms) and Toggles.AntiA90.Value then
                            local module = mainGame:FindFirstChild("A90", true)
    
                            if module then
                                module.Name = "_A90"
                            end
                        end
                    end
                end
            end
        end)
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    Lighting.Brightness = Options.Brightness.Value
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Toggles.Fullbright.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
    if Toggles.NoFog.Value then
        Lighting.FogStart = 0
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if Toggles.NoFog.Value then
        Lighting.FogEnd = math.huge
    end
end))

Library:GiveSignal(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end

    if isFools and Library.IsMobile and input.UserInputType == Enum.UserInputType.Touch and Toggles.GrabBananaJeffToggle.Value then
        if Script.Temp.HoldingItem then
            return Script.Functions.ThrowBananaJeff()
        end

        local touchPos = input.Position
        local ray = workspace.CurrentCamera:ViewportPointToRay(touchPos.X, touchPos.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 500, RaycastParams.new())
        
        local target = result and result.Instance

        if target and isnetowner(target) then
            if target.Name == "BananaPeel" then
                Script.Temp.ItemHoldTrack:Play()

                if not target:FindFirstChildOfClass("BodyGyro") then
                    Instance.new("BodyGyro", target)
                end

                if not target:GetAttribute("Clip") then target:SetAttribute("Clip", target.CanCollide) end

                target.CanTouch = false
                target.CanCollide = false

                Script.Temp.HoldingItem = target
            elseif target:FindFirstAncestorWhichIsA("Model").Name == "JeffTheKiller" then
                Script.Temp.ItemHoldTrack:Play()

                local jeff = target:FindFirstAncestorWhichIsA("Model")

                for _, i in ipairs(jeff:GetDescendants()) do
                    if i:IsA("BasePart") then
                        if not i:GetAttribute("Clip") then i:SetAttribute("Clip", target.CanCollide) end

                        i.CanTouch = false
                        i.CanCollide = false
                    end
                end

                if not jeff.PrimaryPart:FindFirstChildOfClass("BodyGyro") then
                    Instance.new("BodyGyro", jeff.PrimaryPart)
                end

                Script.Temp.HoldingItem = jeff.PrimaryPart
            end
        end
    end
end))

Library:GiveSignal(RunService.RenderStepped:Connect(function()
    if not Toggles.ShowCustomCursor.Value and Library.Toggled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIcon = "rbxassetid://2833720882"
        UserInputService.MouseIconEnabled = true
    end

    local isThirdPersonEnabled = Toggles.ThirdPerson.Value and (Library.IsMobile or Options.ThirdPersonKey:GetState())
    if mainGameSrc then
        if isThirdPersonEnabled then
            camera.CFrame = mainGameSrc.finalCamCFrame * CFrame.new(1.5, -0.5, 6.5)
        end
        mainGameSrc.fovtarget = Options.FOV.Value

        if Toggles.NoCamShake.Value then
            mainGameSrc.csgo = CFrame.new()
        end
    elseif camera then
        if isThirdPersonEnabled then
            camera.CFrame = camera.CFrame * CFrame.new(1.5, -0.5, 6.5)
        end
        camera.FieldOfView = Options.FOV.Value
    end

    if character then
        if character:FindFirstChild("Head") and not (mainGameSrc and mainGameSrc.stopcam or rootPart.Anchored and not character:GetAttribute("Hiding")) then
            character:SetAttribute("ShowInFirstPerson", isThirdPersonEnabled)
            character.Head.LocalTransparencyModifier = isThirdPersonEnabled and 0 or 1
        end

        local speedBoostAssignObj = if isFools then humanoid else character
        if isMines and Toggles.FastLadder.Value and character:GetAttribute("Climbing") then
            character:SetAttribute("SpeedBoostBehind", 50)
        else
            speedBoostAssignObj:SetAttribute("SpeedBoostBehind", Options.SpeedSlider.Value)
        end

        if rootPart then
            rootPart.CanCollide = not Toggles.Noclip.Value

            if rootPart.AssemblyLinearVelocity.Magnitude > (Options.VelocityLimiter.Value * 10) then
                velocityLimiter.Enabled = true
            else
                velocityLimiter.Enabled = false
            end
        end
        
        if collision then
            if Toggles.Noclip.Value then
                collision.CanCollide = not Toggles.Noclip.Value
                if collision:FindFirstChild("CollisionCrouch") then
                    collision.CollisionCrouch.CanCollide = not Toggles.Noclip.Value
                end
            end
        end

        if character:FindFirstChild("UpperTorso") then
            character.UpperTorso.CanCollide = not Toggles.Noclip.Value
        end
        if character:FindFirstChild("LowerTorso") then
            character.LowerTorso.CanCollide = not Toggles.Noclip.Value
        end

        if Toggles.DoorReach.Value and workspace.CurrentRooms:FindFirstChild(latestRoom.Value) then
            local door = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("Door")

            if door and door:FindFirstChild("ClientOpen") then
                door.ClientOpen:FireServer()
            end
        end

        if Toggles.AutoInteract.Value and (Library.IsMobile or Options.AutoInteractKey:GetState()) then
            local prompts = Script.Functions.GetAllPromptsWithCondition(function(prompt)
                if isRetro and prompt.Parent.Parent.Name == "RetroWardrobe" then
                    return false
                end

                return PromptTable.Aura[prompt.Name] ~= nil
            end)

            for _, prompt: ProximityPrompt in pairs(prompts) do
                if not prompt.Parent then continue end
                if prompt.Parent:GetAttribute("JeffShop") then continue end
                if prompt.Parent:GetAttribute("PropType") == "Battery" and ((character:FindFirstChildOfClass("Tool") and character:FindFirstChildOfClass("Tool"):GetAttribute("RechargeProp") ~= "Battery") or character:FindFirstChildOfClass("Tool") == nil) then continue end 
                if prompt.Parent:GetAttribute("PropType") == "Heal" and humanoid and humanoid.Health == humanoid.MaxHealth then continue end
                if prompt:FindFirstAncestorOfClass("Model") and prompt:FindFirstAncestorOfClass("Model").Name == "DoorFake" then continue end

                task.spawn(function()
                    -- checks if distance can interact with prompt and if prompt can be interacted again
                    if Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance and (not prompt:GetAttribute("Interactions" .. localPlayer.Name) or PromptTable.Aura[prompt.Name] or table.find(PromptTable.AuraObjects, prompt.Parent.Name)) then
                        -- painting checks
                        if prompt.Parent.Name == "Slot" and prompt.Parent:GetAttribute("Hint") and character then
                            if Script.Temp.PaintingDebounce then return end
                            
                            local currentPainting = character:FindFirstChild("Prop")
                            if not currentPainting and prompt.Parent:FindFirstChild("Prop") and prompt.Parent:GetAttribute("Hint") ~= prompt.Parent.Prop:GetAttribute("Hint") then
                                return firePrompt(prompt)
                            end

                            if prompt.Parent:FindFirstChild("Prop") then 
                                if prompt.Parent:GetAttribute("Hint") == prompt.Parent.Prop:GetAttribute("Hint") then
                                    return
                                end
                            end

                            if prompt.Parent:GetAttribute("Hint") == currentPainting:GetAttribute("Hint") then
                                Script.Temp.PaintingDebounce = true

                                local oldHint = currentPainting:GetAttribute("Hint")
                                repeat task.wait()
                                    firePrompt(prompt)
                                until not character:FindFirstChild("Prop") or character:FindFirstChild("Prop"):GetAttribute("Hint") ~= oldHint

                                task.wait(0.15)
                                Script.Temp.PaintingDebounce = false
                            end                            
                            
                            return
                        end
                        
                        firePrompt(prompt)
                    end
                end)
            end
        end

        if Toggles.SpamOtherTools.Value and  (Library.IsMobile or Options.SpamOtherTools:GetState()) then
            for _, player in pairs(Players:GetPlayers()) do
                if player == localPlayer then continue end
                
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    tool:FindFirstChildOfClass("RemoteEvent"):FireServer()
                end
                
                local toolRemote = player.Character:FindFirstChild("Remote", true)
                if toolRemote then
                    toolRemote:FireServer()
                end
            end
        end

        if isMines then
            if Toggles.AutoAnchorSolver.Value and latestRoom.Value == 50 and mainUI.MainFrame:FindFirstChild("AnchorHintFrame") then
                local prompts = Script.Functions.GetAllPromptsWithCondition(function(prompt)
                    return prompt.Name == "ActivateEventPrompt" and prompt.Parent:IsA("Model") and prompt.Parent.Name == "MinesAnchor" and not prompt.Parent:GetAttribute("Activated")
                end)

                local CurrentGameState = {
                    DesignatedAnchor = mainUI.MainFrame.AnchorHintFrame.AnchorCode.Text,
                    AnchorCode = mainUI.MainFrame.AnchorHintFrame.Code.Text
                }

                for _, prompt in pairs(prompts) do
                    task.spawn(function()
                        local Anchor = prompt.Parent
                        local CurrentAnchor = Anchor.Sign.TextLabel.Text

                        if not (Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance) then return end
                        if CurrentAnchor ~= CurrentGameState.DesignatedAnchor then return end

                        local result = Anchor:FindFirstChildOfClass("RemoteFunction"):InvokeServer(CurrentGameState.AnchorCode)
                        if result then
                            Script.Functions.Alert({
                                Title = "Auto Anchor Solver",
                                Description = "Solved Anchor " .. CurrentAnchor .. " successfully!",
                                Reason = "Solved anchor with the code " .. CurrentGameState.AnchorCode,
                            })
                        end
                    end)
                end
            end
        end

        if isFools then
            local HoldingItem = Script.Temp.HoldingItem
            if HoldingItem and not isnetowner(HoldingItem) then
                Script.Functions.Alert({
                    Title = "Banana/Jeff Throw",
                    Description = "You are no longer holding the item due to network owner change!",
                })
                Script.Temp.HoldingItem = nil
            end
    
            if HoldingItem and Toggles.GrabBananaJeffToggle.Value then
                if HoldingItem:FindFirstChildOfClass("BodyGyro") then
                    HoldingItem.CanTouch = false
                    HoldingItem.CFrame = character.RightHand.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                end
            end
            
            if not Library.IsMobile then
                local isGrabbing = Options.GrabBananaJeff:GetState() and Toggles.GrabBananaJeffToggle.Value
                local isThrowing = Options.ThrowBananaJeff:GetState()
                
                if isThrowing and HoldingItem and isnetowner(HoldingItem) then
                    Script.Functions.ThrowBananaJeff()
                end
                
                local target = localPlayer:GetMouse().Target
                
                if not target then return end
                if isGrabbing and isnetowner(target) then
                    if target.Name == "BananaPeel" then
                        Script.Temp.ItemHoldTrack:Play()
    
                        if not target:FindFirstChildOfClass("BodyGyro") then
                            Instance.new("BodyGyro", target)
                        end
    
                        if not target:GetAttribute("Clip") then target:SetAttribute("Clip", target.CanCollide) end
    
                        target.CanTouch = false
                        target.CanCollide = false
    
                        Script.Temp.HoldingItem = target
                    elseif target:FindFirstAncestorWhichIsA("Model").Name == "JeffTheKiller" then
                        Script.Temp.ItemHoldTrack:Play()
    
                        local jeff = target:FindFirstAncestorWhichIsA("Model")
    
                        for _, i in ipairs(jeff:GetDescendants()) do
                            if i:IsA("BasePart") then
                                if not i:GetAttribute("Clip") then i:SetAttribute("Clip", target.CanCollide) end
    
                                i.CanTouch = false
                                i.CanCollide = false
                            end
                        end
    
                        if not jeff.PrimaryPart:FindFirstChildOfClass("BodyGyro") then
                            Instance.new("BodyGyro", jeff.PrimaryPart)
                        end
    
                        Script.Temp.HoldingItem = jeff.PrimaryPart
                    end
                end
            end
        end

        if Toggles.AntiEyes.Value and (workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("BackdoorLookman")) then
            if not isFools then
                -- lsplash meanie for removing other args in motorreplication
                remotesFolder.MotorReplication:FireServer(-649)
            else
                remotesFolder.MotorReplication:FireServer(0, -90, 0, false)
            end
        end
    end

    task.spawn(function()
        for guidance, part in pairs(Script.Temp.Guidance) do
            if not guidance:IsDescendantOf(workspace) then continue end
            part.CFrame = guidance.CFrame
        end
    end)
end))

--// Script Load \\--

task.spawn(Script.Functions.SetupCharacterConnection, character)

--// Library Load \\--

Library:OnUnload(function()
    -- disconnect hook
    if mtHook then hookmetamethod(game, "__namecall", mtHook) end
    if _fixDistanceFromCharacter then hookmetamethod(localPlayer, "__namecall", _fixDistanceFromCharacter) end

    if Script.FakeRevive.Enabled then
        for _, connection in pairs(Script.FakeRevive.Connections) do
            if connection.Connected then connection:Disconnect() end
        end

        table.clear(Script.FakeRevive.Connections)
    end

    if getgenv().BloxstrapRPC then
        BloxstrapRPC.SetRichPresence({
            details = "<reset>",
            state = "<reset>",
            largeImage = {
                reset = true
            },
            smallImage = {
                reset = true
            }
        })
    end

    if character then
        character:SetAttribute("CanJump", false)

        local speedBoostAssignObj = isFools and humanoid or character
        speedBoostAssignObj:SetAttribute("SpeedBoostBehind", 0)

        if velocityLimiter then
            velocityLimiter:Destroy()
        end
    end

    if alive then
        Lighting.Ambient = workspace.CurrentRooms[localPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
    end

    if entityModules then
        local module = entityModules:FindFirstChild("_Shade")

        if module then
            module.Name = "Shade"
        end
    end

    if mainGame then
        local module = mainGame:FindFirstChild("_Screech", true)

        if module then
            module.Name = "Screech"
        end
    end

    if mainGameSrc then
        mainGameSrc.fovtarget = 70
    else
        camera.FieldOfView = 70
    end

    if rootPart then
        local existingProperties = rootPart.CustomPhysicalProperties
        rootPart.CustomPhysicalProperties = PhysicalProperties.new(Script.Temp.NoAccelValue, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    end

    if isBackdoor then
        local clientRemote = floorReplicated.ClientRemote
        local internal_temp_mspaint = clientRemote:FindFirstChild("_mspaint")

        if internal_temp_mspaint and #internal_temp_mspaint:GetChildren() ~= 0 then
            for i,v in pairs(internal_temp_mspaint:GetChildren()) do
                v.Parent = clientRemote.Haste
            end
        end

        internal_temp_mspaint:Destroy()
    end

    if isMines then
        local acbypasspart = workspace:FindFirstChild("_internal_mspaint_acbypassprogress")
        if acbypasspart then acbypasspart:Destroy() end
    end

    if isRooms then
        if workspace:FindFirstChild("_internal_mspaint_pathfinding_nodes") then
            workspace:FindFirstChild("_internal_mspaint_pathfinding_nodes"):Destroy()
        end
    end

    if _mspaint_custom_captions then
        _mspaint_custom_captions:Destroy()
    end

    if collision then
        collision.CanCollide = if mainGameSrc then not mainGameSrc.crouching else not character:GetAttribute("Crouching")
        if collision:FindFirstChild("CollisionCrouch") then
            collision.CollisionCrouch.CanCollide = if mainGameSrc then mainGameSrc.crouching else character:GetAttribute("Crouching")
        end
    end

    if collisionClone then collisionClone:Destroy() end

    for _, antiBridge in pairs(Script.Temp.Bridges) do antiBridge:Destroy() end
    if Script.Temp.FlyBody then Script.Temp.FlyBody:Destroy() end

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Destroy()
        end
    end

    for _, connection in pairs(Script.Connections) do
        connection:Disconnect()
    end

    for _, category in pairs(Script.FeatureConnections) do
        for _, connection in pairs(category) do
            connection:Disconnect()
        end
    end

    print("Unloaded!")
    Library.Unloaded = true
    getgenv().mspaint_loaded = false
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local CreditsGroup = Tabs["UI Settings"]:AddRightGroupbox("Credits")

MenuGroup:AddToggle("ExecuteOnTeleport", { Default = false, Text = "Execute on Teleport", Visible = ExecutorSupport["queue_on_teleport"] })
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

Script.Functions.UpdateRPC()
getgenv().mspaint_loaded = true
