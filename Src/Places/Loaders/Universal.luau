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
Script.AimbotTween = nil

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


shared.Load("Utils", "Player")
shared.Load("Utils", "Assets")
shared.Load("Utils", "Aimbot")
shared.Load("Utils", "ESP")

shared.Load("Utils", "ConnectionsFuncs")

--// Tabs \\--
Script.Tabs = {
    Main = shared.Window:AddTab("Main"),
    Exploits = shared.Window:AddTab("Exploits"),
    Visuals = shared.Window:AddTab("Visuals")
}

shared.Load("Tabs", "Main")
shared.Load("Tabs", "Exploits")
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

        if Toggles.EnableAimbot.Value and (shared.Library.IsMobile or Options.EnableAimbotKey:GetState()) then
            local closest = nil
            if Options.AimbotClosestMethod.Value == "Mouse" then
                closest = Script.Functions.GetClosestFromMouse()
            elseif Options.AimbotClosestMethod.Value == "Character" then
                closest = Script.Functions.GetClosestFromCharacter()
            end

            if closest then
                if Toggles.AimbotSmooth.Value then
                    Script.AimbotTween = shared.TweenService:Create(shared.Camera, TweenInfo.new(Options.AimbotSmoothness.Value / 100, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                        CFrame = CFrame.new(shared.Camera.CFrame.Position, closest[Options.AimbotTargetPart.Value].Position)
                    })
                    Script.AimbotTween:Play()
                else
                    shared.Camera.CFrame = CFrame.new(shared.Camera.CFrame.Position, closest[Options.AimbotTargetPart.Value].Position)
                end
            end
        elseif Script.AimbotTween then
            Script.AimbotTween:Cancel()
            Script.AimbotTween = nil
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

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Destroy()
        end
    end

    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") then
            if not object:GetAttribute("Material") then object:SetAttribute("Material", object.Material) end
            if not object:GetAttribute("Reflectance") then object:SetAttribute("Reflectance", object.Reflectance) end

            object.Material = object:GetAttribute("Material")
            object.Reflectance = object:GetAttribute("Reflectance")
        elseif object:IsA("Decal") then
            if not object:GetAttribute("Transparency") then object:SetAttribute("Transparency", object.Transparency) end

            if not table.find(Script.SlotsName, object.Name) then
                object.Transparency = object:GetAttribute("Transparency")
            end
        end
    end

    workspace.Terrain.WaterReflectance = 1
    workspace.Terrain.WaterTransparency = 1
    workspace.Terrain.WaterWaveSize = 0.05
    workspace.Terrain.WaterWaveSpeed = 8
    shared.Lighting.GlobalShadows = true

    shared.Twerk:Disable()
end)

getgenv().mspaint_loaded = true