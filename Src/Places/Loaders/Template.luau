--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Player Variables \\--
shared.Character = shared.LocalPlayer.Character or shared.LocalPlayer.CharacterAdded:Wait()
shared.Humanoid = nil

--// Functions \\--
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
                Script._mspaint_custom_captions.Parent = if gethui then gethui() else game:GetService("CoreGui")
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

shared.Load("Utils", "ConnectionsFuncs")

--// Tabs \\--
Script.Tabs = {
    Main = shared.Window:AddTab("Main"),
}

shared.Load("Tabs", "Main")

--// Metamethod hooks \\--

--// Connections \\--
shared.Connect:GiveSignal(shared.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

--// Load \\--
task.spawn(Script.Functions.SetupCharacterConnection, shared.Character)

--// Unload \\--
shared.Library:OnUnload(function()
    print("Unloading " .. shared.ScriptName .. "...")
end)

getgenv().mspaint_loaded = true