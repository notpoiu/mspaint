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

function Script.Functions.SetupBloxstrapRPCConnection()
    shared.Connect:GiveSignal(shared.Players.PlayerAdded:Connect(function(player)
        Script.Functions.UpdateBloxstrapRPC()
    end))

    shared.Connect:GiveSignal(shared.Players.PlayerRemoving:Connect(function(player)
        Script.Functions.UpdateBloxstrapRPC()
    end))
end