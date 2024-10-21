--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
Script.FeatureConnections = {
    Character = {},
    Humanoid = {},
    Player = {},
    RootPart = {},
}

Script.AutoFarmStagePositions = {}

Script.BoatStages = workspace:WaitForChild("BoatStages")
Script.NormalStages = Script.BoatStages:WaitForChild("NormalStages")
Script.ClaimGold = workspace:WaitForChild("ClaimRiverResultsGold")

Script.DisableAutoFarm = false

Script.AutoFarmPart = Instance.new("Part"); do
    Script.AutoFarmPart.CanCollide = false
    Script.AutoFarmPart.Anchored = true
    Script.AutoFarmPart.Transparency = 1
end

shared.Character = shared.LocalPlayer.Character or shared.LocalPlayer.CharacterAdded:Wait()

--// Functions \\--
function Script.Functions.UpdateBloxstrapRPC()
    if not wax.shared.BloxstrapRPC then return end

    wax.shared.BloxstrapRPC.SetRichPresence({
        details = "Playing BABFT [ mspaint v3 ]",
        state = #shared.Players:GetPlayers() .. " players in the server",
        largeImage = {
            hoverText = "Using mspaint v3"
        },
        smallImage = {
            assetId = 6925817108,
            hoverText = shared.LocalPlayer.Name
        }
    })
end

function Script.Functions.SetupAutoFarmVariables()
    for i = 1, 10 do
        table.insert(Script.AutoFarmStagePositions, Script.NormalStages:FindFirstChild("CaveStage" .. tostring(i)).DarknessPart.Position)
    end

    table.insert(Script.AutoFarmStagePositions, Script.NormalStages.TheEnd.GoldenChest.Trigger.Position + Vector3.new(0, 350, 0))
    table.insert(Script.AutoFarmStagePositions, Script.NormalStages.TheEnd.GoldenChest.Trigger.Position)
end

function Script.Functions.AutoFarm()
    if not shared.Character then return end
    if not Toggles.AutoFarm.Value then return end

    for idx, stagePosition in pairs(Script.AutoFarmStagePositions) do
        if not Toggles.AutoFarm.Value or shared.Library.Unloaded then break end

        if idx >= 11 and Options.AutoFarmPriority.Value == "Gold" then
            Script.ClaimGold:FireServer()
            Script.DisableAutoFarm = true
            
            shared.Humanoid.Health = 0
            break
        end

        Script.DisableAutoFarm = false
        Script.AutoFarmPart.Position = shared.Character:GetPivot().Position

        -- TODO: move from tween to lerping
        local partTween = shared.TweenService:Create(Script.AutoFarmPart, TweenInfo.new((shared.Character:GetPivot().Position - stagePosition).Magnitude / (Options.AutoFarmSpeed.Value * 100), Enum.EasingStyle.Linear), {
            Position = stagePosition
        })

        partTween:Play()
        partTween.Completed:Wait()

        if Options.AutoFarmPriority.Value == "Gold" then
            Script.ClaimGold:FireServer()
        end

        if idx == 12 then
            Script.DisableAutoFarm = true

            local newCharacter = shared.LocalPlayer.CharacterAdded:Wait()
            Script.AutoFarmPart.Position = newCharacter:GetPivot().Position
            
            task.wait(0.25)
        end
    end
end

shared.Load("Utils", "ConnectionsFuncs")

--// Tabs \\--
Script.Tabs = {
    Main = shared.Window:AddTab("Main"),
}

shared.Load("Tabs", "Main")

--// Local Player Connection \\--
shared.Connect:GiveSignal(shared.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

--// Run Service \\--
shared.Connect:GiveSignal(shared.RunService.RenderStepped:Connect(function()
    if shared.Character then
        if shared.Humanoid then
            if Toggles.SpeedHack.Value then shared.Humanoid.WalkSpeed = Options.WalkSpeed.Value end
            if Toggles.JumpPowerHack.Value then shared.Humanoid.JumpPower = Options.JumpPower.Value end
        end

        if Toggles.Noclip.Value then
            for _, part in pairs(shared.Character:GetDescendants()) do
                if not part:IsA("BasePart") then continue end
                part.CanCollide = false
            end        
        end
        
        if Toggles.AutoFarm.Value and Script.AutoFarmPart and not Script.DisableAutoFarm then
            if shared.Character.PrimaryPart then
                shared.Character.PrimaryPart.Velocity = Vector3.zero
            end

            shared.Character:PivotTo(Script.AutoFarmPart.CFrame)
        end
    end
end))

--// Load \\--
Script.Functions.UpdateBloxstrapRPC()

task.spawn(Script.Functions.SetupAutoFarmVariables)
task.spawn(Script.Functions.SetupCharacterConnection, shared.Character)
task.spawn(Script.Functions.SetupBloxstrapRPCConnection)

--// Unload \\--
shared.Library:OnUnload(function()
    if wax.shared.BloxstrapRPC then
        wax.shared.BloxstrapRPC.SetRichPresence({
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

    for _, category in pairs(Script.FeatureConnections) do
        for _, connection in pairs(category) do
            connection:Disconnect()
        end
    end

    Script.AutoFarmPart:Destroy()

    shared.Twerk:Disable()
end)

getgenv().mspaint_loaded = true