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
Script.ESPTable = {
    Player = {},
    None = {}
}

shared.Character = shared.LocalPlayer.Character or shared.LocalPlayer.CharacterAdded:Wait()
Script.GameName = "a roblox experience"

--// Functions \\--
function Script.Functions.UpdateBloxstrapRPC()
    if not wax.shared.BloxstrapRPC then return end

    wax.shared.BloxstrapRPC.SetRichPresence({
        details = "Playing " .. Script.GameName .. " [ mspaint v2 ]",
        state = #shared.Players:GetPlayers() .. " players in the server",
        largeImage = {
            hoverText = "Using mspaint v2"
        },
        smallImage = {
            assetId = 6925817108,
            hoverText = shared.LocalPlayer.Name
        }
    })
end

shared.Load("Utils", "Assets")
shared.Load("Utils", "ESP")

shared.Load("Utils", "ConnectionsFuncs")

--// Tabs \\--
Script.Tabs = {
    Main = shared.Window:AddTab("Main"),
    Visuals = shared.Window:AddTab("Visuals")
}

shared.Load("Tabs", "Main")
shared.Load("Tabs", "Visuals")

--// Code \\--

--// Players Connection \\--
for _, player in pairs(shared.Players:GetPlayers()) do
    if player == shared.LocalPlayer then continue end
    Script.Functions.SetupOtherPlayerConnection(player)
end
shared.Connect:GiveSignal(shared.Players.PlayerAdded:Connect(Script.Functions.SetupOtherPlayerConnection))

--// Local Player Connection \\--
shared.Connect:GiveSignal(shared.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

shared.Connect:GiveSignal(shared.ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.InstaInteract.Value then
        shared.fireproximityprompt(prompt)
    end
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
    end
end))

--// Load \\--
local success, gameName = pcall(function()
    return shared.MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

if success then Script.GameName = gameName end
Script.Functions.UpdateBloxstrapRPC()

task.spawn(Script.Functions.SetupCharacterConnection, shared.Character)
task.spawn(Script.Functions.SetupChildConnection)
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
end)

getgenv().mspaint_loaded = true