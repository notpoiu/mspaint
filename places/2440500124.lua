if not getgenv().mspaint_loaded then
    getgenv().mspaint_loaded = true
else return end


--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables \\--
local fireTouch = firetouchinterest or firetouchtransmitter

local Script = {
    Binded = {}, -- ty geo for idea :smartindividual:
    Connections = {},
    ESPTable = {
        Door = {},
        Entity = {},
        Gold = {},
        Guiding = {},
        Item = {},
        Objective = {},
        Player = {},
        HidingSpot = {},
        None = {}
    },
    Functions = {},
    Temp = {
        AnchorFinished = {},
        Guidance = {},
        FlyBody = nil,
    }
}

local EntityName = {"BackdoorRush", "BackdoorLookman", "RushMoving", "AmbushMoving", "Eyes", "Screech", "Halt", "JeffTheKiller", "A60", "A120"}
local SideEntityName = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"}
local ShortNames = {
    ["BackdoorRush"] = "Blitz",
    ["JeffTheKiller"] = "Jeff The Killer"
}
local EntityNotify = {
    ["GloombatSwarm"] = "Gloombats in next room!"
}
local HidingPlaceName = {
    ["Hotel"] = "Closets",
    ["Backdoor"] = "Closets",
    ["Fools"] = "Closets",

    ["Rooms"] = "Lockers",
    ["Mines"] = "Lockers"
}

local PromptTable = {
    GamePrompts = {},

    Aura = {
        ["ActivateEventPrompt"] = false,
        ["FusesPrompt"] = true,
        ["HerbPrompt"] = false,
        ["LeverPrompt"] = true,
        ["LootPrompt"] = true,
        ["ModulePrompt"] = false,
        ["SkullPrompt"] = false,
        ["UnlockPrompt"] = false,
        ["ValvePrompt"] = false,
    },

    AuraObjects = {
        "Lock",
        "Button"
    },

    Clip = {
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

    Objects = {
        "LeverForGate",
        "LiveBreakerPolePickup",
        "LiveHintBook",
        "Button",
    },

    Excluded = {
        "HintPrompt",
        "InteractPrompt"
    }
}

local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local latestRoom = gameData:WaitForChild("LatestRoom")

local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local playerGui = localPlayer.PlayerGui
local mainUI = playerGui:WaitForChild("MainUI")
local mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local mainGameSrc = require(mainGame)

local playerScripts = localPlayer.PlayerScripts
local controlModule = require(playerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local alive = localPlayer:GetAttribute("Alive")
local humanoid
local rootPart
local collision
local collisionClone

local isMines = floor.Value == "Mines"
local isRooms = floor.Value == "Rooms"
local isHotel = floor.Value == "Hotel"
local isBackdoor = floor.Value == "Backdoor"
local isFools = floor.Value == "Fools"

local lastSpeed = 0

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

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

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

--// Functions \\--

function Script.Functions.Warn(message: string)
    warn("WARN - mspaint:", message)
end

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        IsDoubleDoor = args.IsDoubleDoor or false,
        Type = args.Type or "None",

        Highlights = {},
        Humanoid = nil,
        RSConnection = nil,
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart.Transparency == 1 then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        ESPManager.Humanoid = Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    if ESPManager.IsDoubleDoor then
        for _, door in pairs(ESPManager.Object:GetChilren()) do
            if not door.Name == "Door" then continue end

            local highlight = Instance.new("Highlight") do
                highlight.Adornee = door
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = ESPManager.Color
                highlight.FillTransparency = Options.ESPFillTransparency.Value
                highlight.OutlineColor = ESPManager.Color
                highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
                highlight.Enabled = Toggles.ESPHighlight.Value
                highlight.Parent = door
            end

            table.insert(ESPManager.Highlights, highlight)
        end
    else
        local highlight = Instance.new("Highlight") do
            highlight.Adornee = ESPManager.Object
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = ESPManager.Color
            highlight.FillTransparency = Options.ESPFillTransparency.Value
            highlight.OutlineColor = ESPManager.Color
            highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
            highlight.Enabled = Toggles.ESPHighlight.Value
            highlight.Parent = ESPManager.Object
        end

        table.insert(ESPManager.Highlights, highlight)
    end
    

    local billboardGui = Instance.new("BillboardGui") do
        billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
		billboardGui.AlwaysOnTop = true
		billboardGui.ClipsDescendants = false
		billboardGui.Size = UDim2.new(0, 1, 0, 1)
		billboardGui.StudsOffset = ESPManager.Offset
        billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
	end

    local textLabel = Instance.new("TextLabel") do
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Oswald
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Text = ESPManager.Text
		textLabel.TextColor3 = ESPManager.Color
		textLabel.TextSize = Options.ESPTextSize.Value
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.75
        textLabel.Parent = billboardGui
	end

    function ESPManager.SetColor(newColor: Color3)
        ESPManager.Color = newColor

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.FillColor = newColor
            highlight.OutlineColor = newColor
        end

        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        if ESPManager.IsEntity and ESPManager.Object then
            if ESPManager.Object.PrimaryPart then
                ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
            end
            if ESPManager.Humanoid then
                ESPManager.Humanoid:Destroy()
            end
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end
    end

    ESPManager.RSConnection = RunService.RenderStepped:Connect(function()
        if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
            ESPManager.Destroy()
            return
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.Enabled = Toggles.ESPHighlight.Value
            highlight.FillTransparency = Options.ESPFillTransparency.Value
            highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        end
        textLabel.TextSize = Options.ESPTextSize.Value

        if Toggles.ESPDistance.Value then
            textLabel.Text = string.format("%s\n[%s]", ESPManager.Text, math.floor(Script.Functions.DistanceFromCharacter(ESPManager.Object)))
        else
            textLabel.Text = ESPManager.Text
        end
    end)

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.DoorESP(room)
    local door = room:WaitForChild("Door")
    local locked = room:GetAttribute("RequiresKey")

    if door and not door:GetAttribute("Opened") then
        local doorNumber = tonumber(room.Name) + 1
        if isMines then
            doorNumber += 100
        end

        local doors = 0
        for _, door in pairs(door:GetChildren()) do
            if door.Name == "Door" then
                doors += 1
            end
        end

        local isDoubleDoor = doors > 1
        local doorEsp = Script.Functions.ESP({
            Type = "Door",
            Object = isDoubleDoor and door or door:WaitForChild("Door"),
            Text = locked and string.format("Door %s [Locked]", doorNumber) or string.format("Door %s", doorNumber),
            Color = Options.DoorEspColor.Value,
            IsDoubleDoor = isDoubleDoor
        })

        door:GetAttributeChangedSignal("Opened"):Connect(function()
            doorEsp.Destroy()
        end)
    end
end 

function Script.Functions.ObjectiveESP(room)
    if room:GetAttribute("RequiresKey") then
        local key = room:FindFirstChild("KeyObtain", true)

        if key then
            Script.Functions.ESP({
                Type = "Objective",
                Object = key,
                Text = string.format("Key %s", room.Name + 1),
                Color = Options.ObjectiveEspColor.Value
            })
        end
    elseif room:GetAttribute("RequiresGenerator") then
        local generator = room:FindFirstChild("MinesGenerator", true)
        local gateButton = room:FindFirstChild("MinesGateButton", true)

        if generator then
            Script.Functions.ESP({
                Type = "Objective",
                Object = generator,
                Text = "Generator",
                Color = Options.ObjectiveEspColor.Value
            })
        end

        if gateButton then
            Script.Functions.ESP({
                Type = "Objective",
                Object = gateButton,
                Text = "Gate Power Button",
                Color = Options.ObjectiveEspColor.Value
            })
        end
    elseif room:FindFirstChild("Gate") ~= nil then
        local lever = room:FindFirstChild("LeverForGate", true)

        if lever then
            Script.Functions.ESP({
                Type = "Objective",
                Object = lever,
                Text = "Gate Lever",
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

function Script.Functions.ItemESP(item)
    Script.Functions.ESP({
        Type = "Item",
        Object = item,
        Text = Script.Functions.GetShortName(item.Name),
        Color = Options.ItemEspColor.Value
    })
end


function Script.Functions.GuidingLightEsp(guidance)
    local part = guidance:Clone()
    part.Anchored = true
    part.Size = Vector3.new(2, 2, 2)
    part:ClearAllChildren()
    
    local model = Instance.new("Model")
    model.Name = "_Guidance"
    model.PrimaryPart = part

    part.Parent = model
    model.Parent = workspace

    Script.Temp.Guidance[guidance] = model

    local guidanceEsp = Script.Functions.ESP({
        Type = "Guiding",
        Object = model,
        Text = "Guidance",
        Color = Options.GuidingLightEspColor.Value,
        IsEntity = true
    })

    guidance.AncestryChanged:Connect(function()
        if not guidance:IsDescendantOf(workspace) then
            if Script.Temp.Guidance[guidance] then Script.Temp.Guidance[guidance] = nil end
            if guidanceEsp then guidanceEsp.Destroy() end
            model:Destroy()
        end
    end)
end

function Script.Functions.GoldESP(gold)
    Script.Functions.ESP({
        Type = "Gold",
        Object = gold,
        Text = string.format("Gold [%s]", gold:GetAttribute("GoldValue")),
        Color = Options.GoldEspColor.Value
    })
end

function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%s]", player.DisplayName, player.Character.Humanoid.Health),
        TextParent = player.Character.PrimaryPart,
        Color = Options.PlayerEspColor.Value
    })

    player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.Text = string.format("%s [%s]", player.DisplayName, newHealth)
        else
            playerEsp.Destroy()
        end
    end)
end

function Script.Functions.HidingSpotESP(spot)
    Script.Functions.ESP({
        Type = "HidingSpot",
        Object = spot,
        Text = HidingPlaceName[floor.Value],
        Color = Options.HidingSpotEspColor.Value
    })
end

function Script.Functions.RoomESP(room)
    local waitLoad = room:GetAttribute("RequiresGenerator") == true or room.Name == "50"

    if Toggles.DoorESP.Value then
        Script.Functions.DoorESP(room)
    end
    
    if Toggles.ObjectiveESP.Value then
        task.delay(waitLoad and 3 or 1, Script.Functions.ObjectiveESP, room)
    end
end

function Script.Functions.ObjectiveESPCheck(child)
    if child.Name == "LiveHintBook" then
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

--[[function Script.Functions.FindTool(name: string)
    local function check_player(player)
        local function check_validity(obj)
            return obj:FindFirstChild(name) and obj:FindFirstAncestor(name):IsA("Tool")
        end

        local targetTool
        if player.Character and check_validity(player.Character) then
            targetTool = player.Character:FindFirstChild(name)
        end

        if #player.Backpack:GetChildren() ~= 0 and check_validity(player.Backpack) then
            targetTool = player.Backpack:FindFirstChild(name)
        end

        return targetTool
    end

    local tool = check_player(localPlayer)
    if not tool then
        for _, player in pairs(Players:GetPlayers()) do
            if tool ~= nil then break end

            tool = check_player(player)
        end
    end

    return tool
end]]

function Script.Functions.CameraCheck(child)
    if child:IsA("BasePart") and child.Name == "Guidance" and Toggles.GuidingLightESP.Value then
        Script.Functions.GuidingLightEsp(child)
    end
end

function Script.Functions.ChildCheck(child, includeESP)
    if child:IsA("ProximityPrompt") and not table.find(PromptTable.Excluded, child.Name) then
        if not child:GetAttribute("Hold") then child:SetAttribute("Hold", child.HoldDuration) end
        if not child:GetAttribute("Distance") then child:SetAttribute("Distance", child.MaxActivationDistance) end
        if not child:GetAttribute("Enabled") then child:SetAttribute("Enabled", child.Enabled) end
        if not child:GetAttribute("Clip") then child:SetAttribute("Clip", child.RequiresLineOfSight) end

        table.insert(PromptTable.GamePrompts, child)

        child.MaxActivationDistance = child:GetAttribute("Distance") *
