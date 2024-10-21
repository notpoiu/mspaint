--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
Script.LoadedRooms = {}
Script.FeatureConnections = {
    Door = {},
    Shell = {},
    Room = {}
}
Script.ESPTable = {
    Door = {},
    Entity = {},
    Battery = {},
    Locker = {},
    Player = {},
    Table = {},
    None = {}
}

Script.EntityNames = {
    ["monster"] = "A-60",
    ["monster2"] = "A-120",
    ["Spirit"] = "Pnevma"
}

Script.CurrentAmbient = shared.Lighting.Ambient

Script._mspaint_custom_captions = Instance.new("ScreenGui") do
    local Frame = Instance.new("Frame", Script._mspaint_custom_captions)
    local TextLabel = Instance.new("TextLabel", Frame)
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint", TextLabel)

    Script._mspaint_custom_captions.Parent = shared.ReplicatedStorage
    Script._mspaint_custom_captions.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = shared.Library.MainColor
    Frame.BorderColor3 = shared.Library.AccentColor
    Frame.BorderSizePixel = 2
    Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
    Frame.Size = UDim2.new(0, 200, 0, 75)
    shared.Library:AddToRegistry(Frame, {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "AccentColor"
    })

    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.Code
    TextLabel.Text = ""
    TextLabel.TextColor3 = shared.Library.FontColor
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true
    shared.Library:AddToRegistry(TextLabel, {
        TextColor3 = "FontColor"
    })

    UITextSizeConstraint.MaxTextSize = 35

    function Script.Functions.HideCaptions()
        Script._mspaint_custom_captions.Parent = shared.ReplicatedStorage
    end

    local CaptionsLastUsed = os.time()
    function Script.Functions.Captions(caption: string)
        CaptionsLastUsed = os.time()

        if Script._mspaint_custom_captions.Parent == shared.ReplicatedStorage then
            local success = pcall(function()
                Script._mspaint_custom_captions.Parent = if gethui then gethui() else shared.CoreGui
            end)

            if not success then
                Script._mspaint_custom_captions.Parent = shared.PlayerGui
            end 
        end
        
        TextLabel.Text = caption

        task.spawn(function()
            task.wait(5)
            if os.time() - CaptionsLastUsed >= 5 then
                Script.Functions.HideCaptions()
            end
        end)
    end
end

--// Player Variables \\--
shared.Character = shared.LocalPlayer.Character or shared.LocalPlayer.CharacterAdded:Wait()
shared.Humanoid = nil

Script.MainUI = shared.PlayerGui:WaitForChild("MainGui")

--// Functions \--
function Script.Functions.RandomString()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

shared.Load("Utils", "Assets")
shared.Load("Utils", "Chat")
shared.Load("Utils", "ESP")

shared.Load("Utils", "ConnectionsFuncs")

--// Tabs \\--
Script.Tabs = {
    Main = shared.Window:AddTab("Main"),
    Visuals = shared.Window:AddTab("Visuals")
}

shared.Load("Tabs", "Main")
shared.Load("Tabs", "Visuals")

--// Metamethod hooks \\--
if wax.shared.ExecutorSupport["hookmetamethod"] and wax.shared.ExecutorSupport["getnamecallmethod"] then
    shared.Hooks.mtHook = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local namecall = getnamecallmethod()
    
        if getcallingscript() and namecall == "SetCore" and args[1] == "DevConsoleVisible" and args[2] == false then
            args[2] = game:GetService("StarterGui"):GetCore("DevConsoleVisible")
            return shared.Hooks.mtHook(self, table.unpack(args))
        end
    
        return shared.Hooks.mtHook(self, ...)
    end)
end

--// Connections \\--
shared.Connect:GiveSignal(shared.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

shared.Connect:GiveSignal(shared.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "MainGui" then
        task.delay(1, Script.Functions.SetupUIConnection, child)
    end
end))

shared.Connect:GiveSignal(workspace.rooms.ChildAdded:Connect(function(room)
    Script.Functions.SetupRoomConnection(room)
end))
shared.Connect:GiveSignal(workspace.next.ChildAdded:Connect(function(room)
    Script.Functions.SetupRoomConnection(room)
end))

--// Entity Handler
shared.Connect:GiveSignal(workspace.ChildAdded:Connect(function(child)
    local entityName = Script.EntityNames[child.Name]
    if not entityName then return end

    if child:FindFirstChild("wind") then
        entityName = "A-200"
    end

    if Toggles.EntityESP.Value then
        Script.Functions.EntityESP(child, entityName)
    end

    if Toggles.NotifyEntity.Value then
        shared.Notify:Alert({
            Title = "ENTITIES",
            Description = entityName .. " has spawned!"
        })
    
        if Toggles.NotifyChat.Value then
            Script.Functions.Chat(string.format("%s %s", entityName, Options.NotifyEntityMessage.Value))
        end
    end
end))

shared.Connect:GiveSignal(shared.RunService.RenderStepped:Connect(function()
    if shared.Character then
        if shared.Humanoid then
            if Toggles.SpeedHack.Value then shared.Humanoid.WalkSpeed = Options.WalkSpeed.Value end
        end
    end

    if wax.shared.ExecutorSupport["getrenv"] then
        if Toggles.InfStamina.Value then
            getrenv()._G.stamina = 100
        end
    
        if Toggles.InfFlashlight.Value then
            getrenv()._G.flashlightcharge = 100
        end
    end
end))

--// Load \\--
Instance.new("BoolValue", shared.LocalPlayer).Name = "cheats"
task.spawn(Script.Functions.SetupCharacterConnection, shared.Character)
task.spawn(Script.Functions.SetupLightingConnection)
task.spawn(Script.Functions.SetupUIConnection)

--// Unload \\--
shared.Library:OnUnload(function()
    if shared.Hooks.mtHook then hookmetamethod(game, "__namecall", shared.Hooks.mtHook) end

    local slender = Script.MainUI and Script.MainUI:FindFirstChild("slender")
    if slender then
        slender.ImageTransparency = 0
        for _, bar in pairs(slender:GetChildren()) do
            bar.Visible = true
        end
    end

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Destroy()
        end
    end

    for _, category in pairs(Script.FeatureConnections) do
        for _, connection in pairs(category) do
            connection:Disconnect()
        end
    end

    print("Unloading " .. shared.ScriptName .. "...")
end)

getgenv().mspaint_loaded = true