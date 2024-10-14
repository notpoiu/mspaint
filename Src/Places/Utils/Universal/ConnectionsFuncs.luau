--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.SetupChildConnection()
    for _, child in pairs(shared.Workspace:GetDescendants()) do
        task.spawn(Script.Functions.ChildCheck, child)
    end

    shared.Connections["ChildConnection"] = shared.Workspace.DescendantAdded:Connect(function(child)
        task.delay(0.1, Script.Functions.ChildCheck, child)
    end)
end

function Script.Functions.SetupCharacterConnection(newCharacter)
    shared.Character = newCharacter
    shared.Humanoid = shared.Character:WaitForChild("Humanoid")
    if shared.Humanoid then
        Script.LastSpeed = shared.Humanoid.WalkSpeed

        shared.Connect:GiveSignal(shared.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if shared.Humanoid.WalkSpeed ~= Options.WalkSpeed.Value then
                Script.LastSpeed = shared.Humanoid.WalkSpeed
                if Toggles.SpeedHack.Value then shared.Humanoid.WalkSpeed = Options.WalkSpeed.Value end
            end
        end))


        shared.Connect:GiveSignal(shared.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if not shared.Humanoid.UseJumpPower then return end
            if shared.Humanoid.JumpPower ~= Options.JumpPower.Value then
                Script.LastJumpPower = shared.Humanoid.JumpPower
                if Toggles.JumpPowerHack.Value then shared.Humanoid.JumpPower = Options.JumpPower.Value end
            end
        end))
        shared.Connect:GiveSignal(shared.Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
            if shared.Humanoid.UseJumpPower then return end
            if shared.Humanoid.JumpHeight ~= Options.JumpPower.Value then
                Script.LastJumpPower = shared.Humanoid.JumpHeight
                if Toggles.JumpPowerHack.Value then shared.Humanoid.JumpHeight = Options.JumpPower.Value end
            end
        end))
    end

    shared.RootPart = shared.Character:WaitForChild("HumanoidRootPart")
end

function Script.Functions.SetupOtherPlayerConnection(player: Player)
    if player.Character then
        if Toggles.PlayerESP and Toggles.PlayerESP.Value then
            Script.Functions.PlayerESP(player.Character)
        end
    end

    shared.Connect:GiveSignal(player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Toggles.PlayerESP and Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player.Character)
            end
        end)
    end))
end

function Script.Functions.SetupBloxstrapRPCConnection()
    shared.Connect:GiveSignal(shared.Players.PlayerAdded:Connect(function(player)
        Script.Functions.UpdateBloxstrapRPC()
    end))

    shared.Connect:GiveSignal(shared.Players.PlayerRemoving:Connect(function(player)
        Script.Functions.UpdateBloxstrapRPC()
    end))
end