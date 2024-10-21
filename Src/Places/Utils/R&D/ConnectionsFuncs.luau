--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.SetupCharacterConnection(newCharacter)
    shared.Character = newCharacter
    shared.Humanoid = shared.Character:WaitForChild("Humanoid")
    shared.RootPart = shared.Character:WaitForChild("HumanoidRootPart")
end

function Script.Functions.SetupLightingConnection()
    shared.Connect:GiveSignal(shared.Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if shared.Lighting.Ambient ~= Script.CurrentAmbient and shared.Lighting.Ambient ~= Color3.new(1, 1, 1) then
            Script.CurrentAmbient = shared.Lighting.Ambient
        end

        if Toggles.Fullbright.Value then
            shared.Lighting.Ambient = Color3.new(1, 1, 1)
        end
    end))

    shared.Connect:GiveSignal(shared.Lighting.ChildAdded:Connect(function(child)
        if Toggles.NoBlur.Value and child:IsA("Blur") then
            child.Enabled = false
        end
    end))
end

function Script.Functions.SetupRoomConnection(room)
    if Script.LoadedRooms[room] then return end
    Script.LoadedRooms[room] = true

    if Toggles.DoorESP.Value then
        Script.Functions.DoorESP(room)
    end

    for _, child in pairs(room:GetDescendants()) do
        task.spawn(Script.Functions.ChildCheck, child)
    end

    shared.Connections[room] = room.DescendantAdded:Connect(function(child)
        task.delay(0.1, Script.Functions.ChildCheck, child)
    end)
end

function Script.Functions.SetupUIConnection(GUI)
    Script.MainUI = GUI or shared.PlayerGui:WaitForChild("MainGui")
    
    if Toggles.NoFlashlightShadow.Value then
        local slender = Script.MainUI:WaitForChild("slender")
        if slender then
            slender.ImageTransparency = 1
            for _, bar in pairs(slender:GetChildren()) do
                bar.Visible = false
            end
        end
    end
end