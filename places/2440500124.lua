--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables \\--
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
local SideEntityName = {"FigureRagdoll", "GiggleCeiling", "Snare"}
local ShortNames = {
    ["BackdoorRush"] = "Blitz",
    ["JeffTheKiller"] = "Jeff The Killer"
}

local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local floorName = floor.Value

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
	Title = "mspaint.lua",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	TabPadding = 8,
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

        highlight.FillTransparency = Options.ESPFillTransparency.Value
        highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        textLabel.TextSize = Options.ESPTextSize.Value
    end)

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.DoorESP(room)
    local door = room:WaitForChild("Door")
    local locked = room:GetAttribute("RequiresKey")

    if door and not door:GetAttribute("Opened") then
        local doorEsp = Script.Functions.ESP({
            Type = "Door",
            Object = door:WaitForChild("Door"),
            Text = locked and string.format("Door %s [Locked]", room.Name + 1) or string.format("Door %s", room.Name + 1),
            Color = Options.DoorEspColor.Value
        })

        door:GetAttributeChangedSignal("Opened"):Connect(function()
            doorEsp.Destroy()
        end)
    end
end 

function Script.Functions.ObjectiveESP(room)
    print("called in room:", room.Name)
    local loaded = false
    task.spawn(function() if room:WaitForChild("Assets", 5) then loaded = true end  end)
    if not loaded then return end

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

function Script.Functions.RoomESP(room)
    task.spawn(function()
        local waitLoad = room:GetAttribute("RequiresGenerator") == true or room.Name == "50"

        if Toggles.DoorESP.Value then
            Script.Functions.DoorESP(room)
        end
        
        if Toggles.ObjectiveESP.Value then
            task.delay(waitLoad and 3 or 1, Script.Functions.ObjectiveESP, room)
        end
    end)
end

function Script.Functions.ChildCheck(room, child)
    if Toggles.InstaInteract.Value and child:IsA("ProximityPrompt") then
        child:SetAttribute("Hold", child.HoldDuration)
        child.HoldDuration = 0
    end

    if child:IsA("Model") then
        if (child:GetAttribute("Pickup") or child:GetAttribute("PropType")) and not child:GetAttribute("FuseID") then
            if Toggles.ItemESP.Value then
                Script.Functions.ItemESP(child)
            end
        end

        if Toggles.EntityESP.Value then
            if table.find(SideEntityName, child.Name) then
                if not child.PrimaryPart then
                    local attemps = 0

                    repeat
                        task.wait()
                    until child.PrimaryPart or attemps > 1000
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

        if child.Name == "GoldPile" and Toggles.GoldESP.Value then
            Script.Functions.GoldESP(child)
        end
    end
end

function Script.Functions.SetupRoomConnection(room)
    for _, child in pairs(room:GetDescendants()) do
        task.spawn(Script.Functions.ChildCheck, room, child)
    end

    room.DescendantAdded:Connect(function(child)
        if Toggles.ObjectiveESP.Value and child.Name == "FuseObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Fuse",
                Color = Options.ObjectiveEspColor.Value
            })
        end

        task.delay(0.1, Script.Functions.ChildCheck, room, child)
    end)
end

function Script.Functions.SetupCharacterConnection(newCharacter)
    character = newCharacter

    humanoid = character:WaitForChild("Humanoid")

    if humanoid then
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
end

function Script.Functions.GetShortName(entityName: string)
    if ShortNames[entityName] then
        return ShortNames[entityName]
    end

    return tostring(entityName):gsub("Backdoor", ""):gsub("Ceiling", ""):gsub("Moving", ""):gsub("Wall", ""):gsub("Pack", " Pack")
end

function Script.Functions.DistanceFromCharacter(position: Instance | Vector3)
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end

    return (rootPart.Position - position).Magnitude
end

function Script.Functions.Alert(message: string, time_obj: Instance | number)
    Library:Notify(message, time_obj or 5)

    local sound = Instance.new("Sound", workspace) do
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound.PlayOnRemove = true
        sound:Destroy()
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

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
    MiscGroupBox:AddButton({
        Text = "Play Again",
        Func = function()
            remotesFolder.PlayAgain:FireServer()
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
end

local BypassGroupBox = Tabs.Exploits:AddRightGroupbox("Bypass") do
    BypassGroupBox:AddToggle("SpeedBypass", {
        Text = "Speed Bypass",
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
end

local ESPSettingsGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP Settings") do
    ESPSettingsGroupBox:AddSlider("ESPTextSize", {
        Text = "Text Size",
        Default = 22,
        Min = 16,
        Max = 26,
        Rounding = 0
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
end

local AmbientGroupBox = Tabs.Visuals:AddRightGroupbox("Ambient") do
    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })
end

--// Features Callback \\--

Toggles.InstaInteract:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if value then
                prompt:SetAttribute("Hold", prompt.HoldDuration)
                prompt.HoldDuration = 0
            else
                prompt.HoldDuration = prompt:GetAttribute("Hold") or 0
            end
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
            Script.Functions.ObjectiveESP(room)

            if floorName == "Mines" then
                for _, fuse in pairs(room:GetDescendants()) do
                    if fuse.Name == "FuseObtain" then
                        Script.Functions.ESP({
                            Type = "Objective",
                            Object = fuse,
                            Text = "Fuse",
                            Color = Options.ObjectiveEspColor.Value
                        })
                    end
                end
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

--// Connections \\--

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        if table.find(EntityName, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 2000 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    local entityName = Script.Functions.GetShortName(child)

                    if Toggles.EntityESP.Value then
                        Script.Functions.EntityESP(child)  
                    end

                    Script.Functions.Alert(entityName .. " has spawned!")
                end
            end)
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

Library:GiveSignal(localPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

Library:GiveSignal(localPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    alive = localPlayer:GetAttribute("Alive")
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Toggles.Fullbright.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end))

Library:GiveSignal(RunService.RenderStepped:Connect(function()
    if character then
        character:SetAttribute("SpeedBoostBehind", Options.SpeedSlider.Value)

        if rootPart then
            rootPart.CanCollide = not Toggles.Noclip.Value
        end

        if collision then
            collision.CanCollide = not Toggles.Noclip.Value
            if collision:FindFirstChild("CollisionCrouch") then
                collision.CollisionCrouch.CanCollide = not Toggles.Noclip.Value
            end
        end

        if character:FindFirstChild("UpperTorso") then
            character.UpperTorso.CanCollide = not Toggles.Noclip.Value
        end
        if character:FindFirstChild("LowerTorso") then
            character.LowerTorso.CanCollide = not Toggles.Noclip.Value
        end
    end
end))

--// Script Load \\--

task.spawn(Script.Functions.SetupCharacterConnection, character)

--// Library Load \\--

Library:OnUnload(function()
    if character then
        character:SetAttribute("SpeedBoostBehind", 0)
    end

    if mainGame then
        local module = mainGame:FindFirstChild("_Screech", true)

        if module then
            module.Name = "Screech"
        end
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
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

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