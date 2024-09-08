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
    Connections = {},
    ESPTable = {
        Door = {},
        Entity = {},
        Gold = {},
        Item = {},
        Objective = {},
        Player = {},
        None = {}
    },
    Functions = {}
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
        ["LeverPrompt"] = true,
        ["LootPrompt"] = false,
        ["ModulePrompt"] = true,
        ["SkullPrompt"] = false,
        ["UnlockPrompt"] = true,
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

local localPlayer = Players.LocalPlayer

local playerGui = localPlayer.PlayerGui
local mainUI = playerGui:WaitForChild("MainUI")
local mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local mainGameSrc = require(mainGame)

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
	TabPadding = 4,
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
        Type = args.Type or "None",

        RSConnection = nil,
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart.Transparency == 1 then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

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

        highlight.FillColor = newColor
        highlight.OutlineColor = newColor

        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        if ESPManager.IsEntity and ESPManager.Object and ESPManager.Object.PrimaryPart then
            ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
        end

        if highlight then highlight:Destroy() end
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

        highlight.Enabled = Toggles.ESPHighlight.Value
        highlight.FillTransparency = Options.ESPFillTransparency.Value
        highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
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
        local doors = 0
        for _, door in pairs(door:GetChildren()) do
            if door.Name == "Door" then
                doors += 1
            end
        end

        local doorEsp = Script.Functions.ESP({
            Type = "Door",
            Object = doors > 1 and door or door:WaitForChild("Door"),
            Text = locked and string.format("Door %s [Locked]", room.Name + 1) or string.format("Door %s", room.Name + 1),
            Color = Options.DoorEspColor.Value
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

function Script.Functions.ChildCheck(child, includeESP)
    if child:IsA("ProximityPrompt") and not table.find(PromptTable.Excluded, child.Name) then
        if not child:GetAttribute("Hold") then child:SetAttribute("Hold", child.HoldDuration) end
        if not child:GetAttribute("Distance") then child:SetAttribute("Distance", child.MaxActivationDistance) end
        if not child:GetAttribute("Enabled") then child:SetAttribute("Enabled", child.Enabled) end
        if not child:GetAttribute("Clip") then child:SetAttribute("Clip", child.RequiresLineOfSight) end

        table.insert(PromptTable.GamePrompts, child)

        child.MaxActivationDistance = child:GetAttribute("Distance") * Options.PromptReachMultiplier.Value

        if Toggles.InstaInteract.Value then
            child.HoldDuration = 0
        end

        if Toggles.PromptClip.Value and (table.find(PromptTable.Clip, child.Name) or table.find(PromptTable.Objects, child.Parent.Name)) then
            child.RequiresLineOfSight = false
            if child.Name == "ModulePrompt" then
                child.Enabled = true

                child:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if Toggles.PromptClip.Value then
                        child.Enabled = true
                    end
                end)
            end
        end
    end

    if child:IsA("Model") then
        if mainGameSrc.stopcam and child.Name == "ElevatorBreaker" and Toggles.AutoBreakerSolver.Value then
            local autoConnections = {}
            local using = false

            if not child:GetAttribute("Solving") then
                child:SetAttribute("Solving", true)
                using = true 

                local code = child:FindFirstChild("Code", true)

                local breakers = {}
                for _, breaker in pairs(child:GetChildren()) do
                    if breaker.Name == "BreakerSwitch" then
                        local id = string.format("%02d", breaker:GetAttribute("ID"))
                        breakers[id] = breaker
                    end
                end

                if code and code:FindFirstChild("Frame") then
                    local correct = child.Box.Correct
                    local used = {}
                    
                    autoConnections["Reset"] = correct:GetPropertyChangedSignal("Playing"):Connect(function()
                        if correct.Playing then
                            table.clear(used)
                        end
                    end)

                    autoConnections["Code"] = code:GetPropertyChangedSignal("Text"):Connect(function()
                        task.wait(0.1)
                        local newCode = code.Text
                        local isEnabled = code.Frame.BackgroundTransparency == 0

                        local breaker = breakers[newCode]

                        if newCode == "??" and #used == 9 then
                            for i = 1, 10 do
                                local id = string.format("%02d", i)

                                if not table.find(used, id) then
                                    breaker = breakers[id]
                                end
                            end
                        end

                        if breaker then
                            table.insert(used, newCode)
                            if breaker:GetAttribute("Enabled") ~= isEnabled then
                                Script.Functions.EnableBreaker(breaker, isEnabled)
                            end
                        end
                    end)
                end
            end

            repeat
                task.wait()
            until not child or not mainGameSrc.stopcam or not Toggles.AutoBreakerSolver.Value or not using

            if child then child:SetAttribute("Solving", nil) end
        end

        if (child:GetAttribute("Pickup") or child:GetAttribute("PropType")) and not child:GetAttribute("FuseID") then
            if Toggles.ItemESP.Value then
                Script.Functions.ItemESP(child)
            end
        end

        if child.Name == "Snare" and Toggles.AntiSnare.Value then
            child:WaitForChild("Hitbox", 5).CanTouch = false
        end
        if child.Name == "GiggleCeiling" and Toggles.AntiGiggle.Value then
            child:WaitForChild("Hitbox", 5).CanTouch = false
        end

        if child:GetAttribute("LoadModule") == "DupeRoom" and Toggles.AntiDupe.Value then
            Script.Functions.DisableDupe(child, true)
        end

        if child.Name == "GoldPile" and Toggles.GoldESP.Value then
            Script.Functions.GoldESP(child)
        end

        if isHotel and (child.Name == "ChandelierObstruction" or child.Name == "Seek_Arm") and Toggles.AntiSeekObstructions.Value then
            for i,v in pairs(child:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
    elseif child:IsA("BasePart") then        
        if child.Name == "Egg" and Toggles.AntiGloomEgg.Value then
            child.CanTouch = false
        end
    end

    if includeESP then
        if Toggles.ObjectiveESP.Value then
            task.spawn(Script.Functions.ObjectiveESPCheck, child)
        end
    end

    if Toggles.EntityESP.Value then
        if table.find(SideEntityName, child.Name) then
            if not child.PrimaryPart then
                local waiting = 0

                repeat
                    waiting += task.wait()
                until child.PrimaryPart or waiting > 3
                task.wait(0.1)
            end

            Script.Functions.ESP({
                Type = "Entity",
                Object = child,
                Text = Script.Functions.GetShortName(child.Name),
                TextParent = child.PrimaryPart,
                Color = Options.EntityEspColor.Value
            })
        end
    end
end

function Script.Functions.SetupRoomConnection(room)
    for _, child in pairs(room:GetDescendants()) do
        task.spawn(Script.Functions.ChildCheck, child, false)
    end

    room.DescendantAdded:Connect(function(child)
        task.delay(0.1, Script.Functions.ChildCheck, child, true)
        
        task.spawn(function()
            if child.Name == "TriggerEventCollision" and Toggles.DeleteSeek.Value and character then
                Script.Functions.Alert("Deleting Seek, do not open the next door...", child:FindFirstChildOfClass("BasePart"))
                
                if fireTouch then
                    repeat
                        for _, v in pairs(child:GetChildren()) do
                            fireTouch(v, rootPart, 1)
                            task.wait()
                            fireTouch(v, rootPart, 0)
                            task.wait()
                        end
                    until #child:GetChildren() == 0 or not Toggles.DeleteSeek.Value
                else
                    child:PivotTo(CFrame.new(rootPart.Position))
                    rootPart.Anchored = true
    
                    repeat task.wait() until #child:GetChildren() == 0 or not Toggles.DeleteSeek.Value
                end
                
                Script.Functions.Alert("Deleted Seek successfully! You can open the next door", 5)
            end
        end)
    end)
end

function Script.Functions.SetupCharacterConnection(newCharacter)
    character = newCharacter
    if character then
        Script.Connections["ChildAdded"] = character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                task.wait(0.1)
                local code = Script.Functions.GetPadlockCode(child)
                local output, count = string.gsub(code, "_", "x")

                if Toggles.AutoLibrarySolver.Value and tonumber(code) then
                    remotesFolder.PL:FireServer(code)
                end

                if Toggles.NotifyPadlock.Value and count < 5 then
                    Script.Functions.Alert(string.format("Library Code: %s", output))
                end
            end
        end)

        Script.Connections["Hiding"] = character:GetAttributeChangedSignal("Hiding"):Connect(function()
            if not character:GetAttribute("Hiding") then return end
    
            if Toggles.HidingTransparency.Value then
                for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end
    
                    if obj.Value == character then
                        task.spawn(function()
                            local affectedParts = {}
                            for _, part in pairs(obj.Parent:GetChildren()) do
                                if not part:IsA("BasePart") then continue end
    
                                part.Transparency = Options.HidingTransparency.Value
                                table.insert(affectedParts, part)
                            end
    
                            repeat task.wait()
                                for _, part in pairs(affectedParts) do
                                    task.wait()
                                    part.Transparency = Options.HidingTransparency.Value
                                end
                            until not character:GetAttribute("Hiding") or not Toggles.HidingTransparency.Value
                            
                            for _, part in pairs(affectedParts) do
                                part.Transparency = 0
                            end
                        end)
    
                        break
                    end
                end
            end
        end)
    end

    humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        Script.Connections["Jump"] = humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
            if not Toggles.SpeedBypass.Value and latestRoom.Value < 100 then
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

        Script.Connections["Died"] = humanoid.Died:Connect(function()
            if collisionClone then
                collisionClone:Destroy()
            end
        end)
    end

    rootPart = character:WaitForChild("HumanoidRootPart")

    collision = character:WaitForChild("Collision")
    if collision then
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

    player.CharacterAdded:Connect(function(newCharacter)
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

                if Toggles.AutoLibrarySolver.Value and tonumber(code) then
                    remotesFolder.PL:FireServer(code)
                end

                if Toggles.NotifyPadlock.Value and count < 5 then
                    Script.Functions.Alert(string.format("Library Code: %s", output))
                end
            end
        end)
    end)
end

function Script.Functions.GetShortName(entityName: string)
    if ShortNames[entityName] then
        return ShortNames[entityName]
    end

    local suffixPrefix = {
        ["Backdoor"] = "",
        ["Ceiling"] = "",
        ["Moving"] = "",
        ["Ragdoll"] = "",
        ["Rig"] = "",
        ["Wall"] = "",
        ["Pack"] = " Pack",
        ["Swarm"] = " Swarm",
    }

    for suffix, fix in pairs(suffixPrefix) do
        entityName = entityName:gsub(suffix, fix)
    end

    return entityName
end

function Script.Functions.DistanceFromCharacter(position: Instance | Vector3)
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end

    if not alive then
        return (workspace.CurrentCamera.CFrame.Position - position).Magnitude
    end

    return (rootPart.Position - position).Magnitude
end

function Script.Functions.DisableDupe(dupeRoom, value)
    local doorFake = dupeRoom:WaitForChild("DoorFake", 5)

    if doorFake then
        doorFake:WaitForChild("Hidden", 5).CanTouch = not value

        local lock = doorFake:WaitForChild("LockPart", 5)
        if lock and lock:FindFirstChild("UnlockPrompt") then
            lock.UnlockPrompt.Enabled = not value
        end
    end
end

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

function Script.Functions.Alert(message: string, time_obj: number)
    Library:Notify(message, time_obj or 5)

    if Toggles.NotifySound.Value then
        local sound = Instance.new("Sound", workspace) do
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = 2
            sound.PlayOnRemove = true
            sound:Destroy()
        end
    end
end

--// Main \\--
 
print("reached main")

local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player") do
    PlayerGroupBox:AddSlider("SpeedSlider", {
        Text = "Speed Boost",
        Default = 0,
        Min = 0,
        Max = 7,
        Rounding = 1
    })

    PlayerGroupBox:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false
    })

    PlayerGroupBox:AddToggle("InstaInteract", {
        Text = "Instant Interact",
        Default = false
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
        Default = "R",
        Mode = "Hold",
        Text = "Auto Interact",
    })

    AutomationGroupBox:AddToggle("AutoHeartbeat", {
        Text = "Auto Heartbeat Minigame",
        Default = false
    })

    if isHotel or isFools then
        AutomationGroupBox:AddToggle("AutoLibrarySolver", {
            Text = "Auto Library Code",
            Default = false
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
                        local output, count = string.gsub(code, "_", "x")

                        if tonumber(code) then
                            remotesFolder.PL:FireServer()
                        end

                        if count < 5 and Toggles.NotifyPadlock.Value then
                            Script.Functions.Alert(string.format("Library Code: %s", output))
                        end
                    end
                end
            end
        end)

        Toggles.AutoBreakerSolver:OnChanged(function(value)
            local autoConnections = {}
            local using = false

            if mainGameSrc.stopcam and workspace.CurrentRooms:FindFirstChild("100") then
                local elevatorBreaker = workspace.CurrentRooms["100"]:FindFirstChild("ElevatorBreaker")

                if elevatorBreaker and not elevatorBreaker:GetAttribute("Solving") then
                    elevatorBreaker:SetAttribute("Solving", true)
                    using = true 

                    local code = elevatorBreaker:FindFirstChild("Code", true)

                    local breakers = {}
                    for _, breaker in pairs(elevatorBreaker:GetChildren()) do
                        if breaker.Name == "BreakerSwitch" then
                            local id = string.format("%02d", breaker:GetAttribute("ID"))
                            breakers[id] = breaker
                        end
                    end

                    if code and code:FindFirstChild("Frame") then
                        local correct = elevatorBreaker.Box.Correct
                        local used = {}
                        
                        autoConnections["Reset"] = correct:GetPropertyChangedSignal("Playing"):Connect(function()
                            if correct.Playing then
                                table.clear(used)
                            end
                        end)

                        autoConnections["Code"] = code:GetPropertyChangedSignal("Text"):Connect(function()
                            task.wait(0.1)
                            local newCode = code.Text
                            local isEnabled = code.Frame.BackgroundTransparency == 0

                            local breaker = breakers[newCode]

                            if newCode == "??" and #used == 9 then
                                for i = 1, 10 do
                                    local id = string.format("%02d", i)

                                    if not table.find(used, id) then
                                        breaker = breakers[id]
                                    end
                                end
                            end

                            if breaker then
                                table.insert(used, newCode)
                                if breaker:GetAttribute("Enabled") ~= isEnabled then
                                    Script.Functions.EnableBreaker(breaker, isEnabled)
                                end
                            end
                        end)
                    end
                end

                repeat
                    task.wait()
                until not elevatorBreaker or not mainGameSrc.stopcam or not Toggles.AutoBreakerSolver.Value or not using

                if elevatorBreaker then elevatorBreaker:SetAttribute("Solving", nil) end
            end

            for _, connection in pairs(autoConnections) do
                connection:Disconnect()
            end
        end)
    elseif isMines then
        AutomationGroupBox:AddToggle("MinecartSpam", {
            Text = "Spam Minecart Interact",
            Default = false
        }):AddKeyPicker("MinecartSpamKey", {
            Default = "Q",
            Mode = "Hold",
            Text = "Spam Minecart Interact",
        })

        AutomationGroupBox:AddToggle("AutoAnchorSolver", {
            Text = "Auto Anchor Solver",
            Default = false
        })
    end
end

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
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
        Text = "Anti-Dupe",
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
end

local BypassGroupBox = Tabs.Exploits:AddRightGroupbox("Bypass") do
    BypassGroupBox:AddToggle("SpeedBypass", {
        Text = "Speed Bypass",
        Default = false
    })
    
    BypassGroupBox:AddToggle("DeleteSeek", {
        Text = "Delete Seek (FE)",
        Default = false
    })
end


--// Visuals \\--

local ESPGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP") do
    ESPGroupBox:AddToggle("DoorESP", {
        Text = "Door",
        Default = false,
    }):AddColorPicker("DoorEspColor", {
        Default = Color3.new(0, 1, 1),
    })

    ESPGroupBox:AddToggle("ObjectiveESP", {
        Text = "Objective",
        Default = false,
    }):AddColorPicker("ObjectiveEspColor", {
        Default = Color3.new(0, 1, 0),
    })

    ESPGroupBox:AddToggle("EntityESP", {
        Text = "Entity",
        Default = false,
    }):AddColorPicker("EntityEspColor", {
        Default = Color3.new(1, 0, 0),
    })

    ESPGroupBox:AddToggle("ItemESP", {
        Text = "Item",
        Default = false,
    }):AddColorPicker("ItemEspColor", {
        Default = Color3.new(1, 0, 1),
    })

    ESPGroupBox:AddToggle("GoldESP", {
        Text = "Gold",
        Default = false,
    }):AddColorPicker("GoldEspColor", {
        Default = Color3.new(1, 1, 0),
    })

    ESPGroupBox:AddToggle("PlayerESP", {
        Text = "Player",
        Default = false,
    }):AddColorPicker("PlayerEspColor", {
        Default = Color3.new(1, 1, 1),
    })
end

local ESPSettingsGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP Settings") do
    ESPSettingsGroupBox:AddToggle("ESPHighlight", {
        Text = "Enable Highlight",
        Default = true,
    })

    ESPSettingsGroupBox:AddToggle("ESPDistance", {
        Text = "Show Distance",
        Default = true,
    })

    ESPSettingsGroupBox:AddSlider("ESPFillTransparency", {
        Text = "Fill Transparency",
        Default = 0.75,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    ESPSettingsGroupBox:AddSlider("ESPOutlineTransparency", {
        Text = "Outline Transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    ESPSettingsGroupBox:AddSlider("ESPTextSize", {
        Text = "Text Size",
        Default = 22,
        Min = 16,
        Max = 26,
        Rounding = 0
    })
end

local AmbientGroupBox = Tabs.Visuals:AddRightGroupbox("Ambient") do
    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })
end

local NotifyTabBox = Tabs.Visuals:AddRightTabbox() do
    local NotifyTab = NotifyTabBox:AddTab("Notifier") do
        NotifyTab:AddToggle("NotifyEntity", {
            Text = "Notify Entity",
            Default = false,
        })

        NotifyTab:AddToggle("NotifyPadlock", {
            Text = "Notify Library Code",
            Default = false,
        })
    end

    local NotifySettingsTab = NotifyTabBox:AddTab("Settings") do
        NotifySettingsTab:AddToggle("NotifySound", {
            Text = "Play Alert Sound",
            Default = true,
        })
    end
end

local SelfGroupBox = Tabs.Visuals:AddRightGroupbox("Self") do
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
    })

    SelfGroupBox:AddToggle("HidingTransparency", {
        Text = "Translucent " .. HidingPlaceName[floor.Value],
        Default = false
    })

    SelfGroupBox:AddSlider("HidingTransparency", {
        Text = "Hiding Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 1
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

            Toggles.AntiSeekObstructions:OnChanged(function(value)
                for i, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                        for _, obj in pairs(v:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanTouch = not value end
                        end
                    end
                end
            end)
        end
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
                Text = "Anti-GloomEgg",
                Default = false
            })
        end

        local Mines_AutomationGroupBox = Tabs.Floor:AddRightGroupbox("Automation") do
            Mines_AutomationGroupBox:AddButton({
                Text = "Beat Door 200",
                Func = function()
                    if latestRoom.Value < 100 then Script.Functions.Alert("You haven't reached door 200...") end

                    local bypassing = Toggles.SpeedBypass.Value
                    local startPos = rootPart.CFrame

                    Toggles.SpeedBypass:SetValue(false)

                    local damHandler = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("_DamHandler")

                    if damHandler then
                        if damHandler:FindFirstChild("PlayerBarriers1") then
                            for _, pump in pairs(damHandler.Flood1.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                fireproximityprompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            repeat task.wait() until not mainGameSrc.stopcam
                        end

                        if damHandler:FindFirstChild("PlayerBarriers2") then
                            for _, pump in pairs(damHandler.Flood2.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                fireproximityprompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            repeat task.wait() until not mainGameSrc.stopcam
                        end

                        if damHandler:FindFirstChild("PlayerBarriers3") then
                            for _, pump in pairs(damHandler.Flood3.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                fireproximityprompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end
                        end
                    end

                    local generator = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("MinesGenerator", true)

                    if generator then
                        character:PivotTo(generator.PrimaryPart.CFrame)
                        task.wait(0.25)
                        fireproximityprompt(generator.Lever.LeverPrompt)
                        task.wait(0.25)
                    end

                    Toggles.SpeedBypass:SetValue(bypassing)
                    character:PivotTo(startPos)
                end
            })
        end
        
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

Toggles.PromptClip:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            print(prompt.Parent.Name, not table.find(PromptTable.Excluded, prompt.Name), table.find(PromptTable.Clip, prompt.Name) or table.find(PromptTable.Objects, prompt.Parent.Name))
        end
        
        if prompt:IsA("ProximityPrompt") and not table.find(PromptTable.Excluded, prompt.Name) and (table.find(PromptTable.Clip, prompt.Name) or table.find(PromptTable.Objects, prompt.Parent.Name)) then
            if value then
                if not prompt:GetAttribute("Enabled") then prompt:SetAttribute("Enabled", prompt.Enabled) end
                if not prompt:GetAttribute("Clip") then prompt:SetAttribute("Clip", prompt.RequiresLineOfSight) end

                prompt.RequiresLineOfSight = false
                if prompt.Name == "ModulePrompt" then
                    prompt.Enabled = true
    
                    prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
                        if Toggles.PromptClip.Value then
                            prompt.Enabled = true
                        end
                    end)
                end
            else
                prompt.Enabled = prompt:GetAttribute("Enabled") or true
                prompt.RequiresLineOfSight = prompt:GetAttribute("Clip") or true
            end
        end
    end
end)

Options.PromptReachMultiplier:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and not table.find(PromptTable.Excluded, prompt.Name) then
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
            if dupeRoom:GetAttribute("LoadModule") == "DupeRoom" then
                task.spawn(function() Script.Functions.DisableDupe(dupeRoom, value) end)
            end
        end
    end
end)

Toggles.AntiSnare:OnChanged(function(value)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if not room:FindFirstChild("Assets") then continue end

        for _, snare in pairs(room.Assets:GetChildren()) do
            if snare.Name == "SS" then
                snare:WaitForChild("Hitbox", 5).CanTouch = not value
            end
        end
    end
end)

Toggles.SpeedBypass:OnChanged(function(value)
    if value then
        Options.SpeedSlider:SetMax(30)

        while Toggles.SpeedBypass.Value and collisionClone do
            collisionClone.Massless = not collisionClone.Massless
            task.wait(0.225)
        end
    else
        Options.SpeedSlider:SetMax(7)
        if collisionClone then collisionClone.Massless = true end
    end
end)

Toggles.DoorESP:OnChanged(function(value)
    if value then
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            Script.Functions.DoorESP(room)
        end
    else
        for _, esp in pairs(Script.ESPTable.Door) do
            esp.Destroy()
        end
    end
end)

Options.DoorEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Door) do
        esp.SetColor(value)
    end
end)

Toggles.ObjectiveESP:OnChanged(function(value)
    if value then
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            task.spawn(Script.Functions.ObjectiveESP, room)
            
            for _, child in pairs(room:GetDescendants()) do
                task.spawn(Script.Functions.ObjectiveESPCheck, child)
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
        esp.SetColor(value)
    end
end)

Toggles.EntityESP:OnChanged(function(value)
    if value then
        for _, entity in pairs(workspace.CurrentRooms:GetDescendants()) do
            if table.find(SideEntityName, entity.Name) then
                Script.Functions.ESP({
                    Type = "Entity",
                    Object = entity,
                    Text = Script.Functions.GetShortName(entity.Name),
                    TextParent = entity.PrimaryPart,
                    Color = Options.EntityEspColor.Value
                })
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Entity) do
            esp.Destroy()
        end
    end
end)

Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.SetColor(value)
    end
end)

Toggles.ItemESP:OnChanged(function(value)
    if value then
        for _, item in pairs(workspace.CurrentRooms:GetDescendants()) do
            if item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID") then
                Script.Functions.ItemESP(item)
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
        esp.SetColor(value)
    end
end)

Toggles.GoldESP:OnChanged(function(value)
    if value then
        for _, gold in pairs(workspace.CurrentRooms:GetDescendants()) do
            if gold.Name == "GoldPile" then
                Script.Functions.GoldESP(gold)
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
        esp.SetColor(value)
    end
end)

Toggles.PlayerESP:OnChanged(function(value)
    if value then
        for _, player in pairs(Players:GetPlayers()) do
            if player == localPlayer or not player.Character then continue end
            
            Script.Functions.PlayerESP(player)
        end
    else
        for _, esp in pairs(Script.ESPTable.Player) do
            esp.Destroy()
        end
    end
end)

Options.PlayerEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Player) do
        esp.SetColor(value)
    end
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

Toggles.HidingTransparency:OnChanged(function(value)
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
                    until not character:GetAttribute("Hiding") or not Toggles.HidingTransparency.Value
                    
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

local mtHook; mtHook = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local namecallMethod = getnamecallmethod()

    if namecallMethod == "FireServer" and self.Name == "ClutchHeartbeat" and Toggles.AutoHeartbeat.Value then
        return
    elseif namecallMethod == "Destroy" and self.Name == "RunnerNodes" then
        return
    end

    return mtHook(self, ...)
end)

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        if table.find(EntityName, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 2000 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    local entityName = Script.Functions.GetShortName(child.Name)

                    if Toggles.EntityESP.Value then
                        Script.Functions.EntityESP(child)  
                    end

                    if Toggles.NotifyEntity.Value then
                        Script.Functions.Alert(entityName .. " has spawned!")
                    end
                end
            end)
        elseif EntityNotify[child.Name] and Toggles.NotifyEntity.Value then
            Script.Functions.Alert(EntityNotify[child.Name])
        end
    end)
end))

for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
    task.spawn(Script.Functions.SetupRoomConnection, room)
end
Library:GiveSignal(workspace.CurrentRooms.ChildAdded:Connect(function(room)
    task.spawn(Script.Functions.SetupRoomConnection, room)
    task.spawn(Script.Functions.RoomESP, room)
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
end))

Library:GiveSignal(localPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    alive = localPlayer:GetAttribute("Alive")
end))

Library:GiveSignal(playerGui.ChildAdded:Connect(function(child)
    if child.Name == "MainUI" then
        mainUI = child

        task.delay(1, function()
            if mainUI then
                mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")

                if mainGame then
                    mainGameSrc = require(mainGame)
                    if not mainGame:WaitForChild("RemoteListener", 5) then return end

                    if Toggles.AntiScreech.Value then
                        local module = mainGame:FindFirstChild("Screech", true)

                        if module then
                            module.Name = "_Screech"
                        end
                    end
                end
            end
        end)
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Toggles.Fullbright.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end))

Library:GiveSignal(RunService.RenderStepped:Connect(function()
    if mainGameSrc then
        mainGameSrc.fovtarget = Options.FOV.Value

        if Toggles.NoCamShake.Value then
            mainGameSrc.csgo = CFrame.new()
        end
    end

    if character then
        if isMines and Toggles.FastLadder.Value and character:GetAttribute("Climbing") then
            character:SetAttribute("SpeedBoostBehind", 50)
        else
            character:SetAttribute("SpeedBoostBehind", Options.SpeedSlider.Value)
        end
        
        if rootPart then
            rootPart.CanCollide = not Toggles.Noclip.Value
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

        if Toggles.AutoInteract.Value and Options.AutoInteractKey:GetState() then
            local prompts = Script.Functions.GetAllPromptsWithCondition(function(prompt)
                return PromptTable.Aura[prompt.Name] ~= nil
            end)

            for _, prompt in pairs(prompts) do
                task.spawn(function()
                    -- checks if distance can interact with prompt and if prompt can be interacted again
                    if Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance and (not prompt:GetAttribute("Interactions" .. localPlayer.Name) or PromptTable.Aura[prompt.Name] or table.find(PromptTable.AuraObjects, prompt.Parent.Name)) then
                        fireproximityprompt(prompt)
                    end
                end)
            end
        end

        if isMines and Toggles.AutoAnchorSolver.Value and latestRoom.Value == 50 and mainUI.MainFrame:FindFirstChild("AnchorHintFrame") then
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
                    
                    Anchor:FindFirstChildOfClass("RemoteFunction"):InvokeServer(CurrentGameState.AnchorCode)
                    Script.Functions.Alert("Solved Anchor " .. CurrentAnchor .. " successfully!", 5)
                end)
            end
        end

        if isMines and Toggles.MinecartSpam.Value and Options.MinecartSpamKey:GetState() then
            local prompt = Script.Functions.GetNearestPromptWithCondition(function(prompt)
                return prompt.Name == "PushPrompt" and prompt.Parent.Name == "Cart"
            end)

            if prompt then
                fireproximityprompt(prompt)
            end
        end

        if Toggles.AntiEyes.Value and workspace:FindFirstChild("Eyes") then
            -- lsplash meanie for removing other args in motorreplication
            remotesFolder.MotorReplication:FireServer(-650)
        end
    end
end))

--// Script Load \\--

task.spawn(Script.Functions.SetupCharacterConnection, character)

--// Library Load \\--

Library:OnUnload(function()
    -- disconnect hook
    if mtHook then hookmetamethod(game, "__namecall", mtHook) end

    if character then
        character:SetAttribute("SpeedBoostBehind", 0)
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
    end

    if collision then
        collision.CanCollide = not mainGameSrc.crouching
        if collision:FindFirstChild("CollisionCrouch") then
            collision.CollisionCrouch.CanCollide = mainGameSrc.crouching
        end
    end

    collisionClone:Destroy()

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Destroy()
        end
    end

    for _, connection in pairs(Script.Connections) do
        connection:Disconnect()
    end

	print("Unloaded!")
	Library.Unloaded = true
    getgenv().mspaint_loaded = false
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local CreditsGroup = Tabs["UI Settings"]:AddRightGroupbox("Credits")

MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

CreditsGroup:AddLabel("deividcomsono - script dev")
CreditsGroup:AddLabel("upio - script dev")

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("mspaint")
SaveManager:SetFolder("mspaint/doors")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()