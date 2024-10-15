--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/MS-ESP/refs/heads/main/source.lua"))()
shared.ESPLibrary = ESPLibrary

type ESP = {
    Color: Color3,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
    Player: Player,
}

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        Type = args.Type or "None",
        Player = args.Player or false,
        OnDestroy = args.OnDestroy or nil,

        Invisible = false,
        Humanoid = nil
    }

    local ESPInstance = ESPLibrary.ESP.Highlight({
        Name = ESPManager.Text,
        Model = ESPManager.Object,
        StudsOffset = ESPManager.Offset,

        FillColor = ESPManager.Color,
        OutlineColor = ESPManager.Color,
        TextColor = ESPManager.Color,
        TextSize = Options.ESPTextSize.Value or 16,

        FillTransparency = Options.ESPFillTransparency.Value,
        OutlineTransparency = Options.ESPOutlineTransparency.Value,

        Tracer = {
            Enabled = true,
            From = Options.ESPTracerStart.Value,
            Color = ESPManager.Color
        },
        
        Arrow = {
            Enabled = true,
            CenterOffset = Options.ESPArrowCenterOffset.Value,
            Color = ESPManager.Color
        },

        OnDestroy = ESPManager.OnDestroy or function()
            if ESPManager.Object.PrimaryPart and ESPManager.Invisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
            if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
        end
    })
    
    if ESPManager.Player then
        Script.ESPTable[ESPManager.Type][ESPManager.Player] = ESPInstance
    else
        table.insert(Script.ESPTable[ESPManager.Type], ESPInstance)
    end

    return ESPInstance
end

function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%.1f]", player.Name, player.Character.Humanoid.Health),
        TextParent = player.Character.PrimaryPart,
        Player = player,
        Color = if Toggles.ESPTeamColor.Value then player.TeamColor.Color else Options.PlayerEspColor.Value
    })

    Script.FeatureConnections.Player[player.Name .. "TeamColor"] = player:GetPropertyChangedSignal("TeamColor"):Connect(function()
        if Toggles.ESPTeamColor.Value then
            playerEsp.Update({
                FillColor = player.TeamColor.Color,
                OutlineColor = player.TeamColor.Color,
                TextColor = player.TeamColor.Color,
            })
        end
    end)

    Script.FeatureConnections.Player[player.Name .. "Health"] = player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.SetText(string.format("%s [%.1f]", player.Name, newHealth))
        else
            if Script.FeatureConnections.Player[player.Name .. "Health"] then Script.FeatureConnections.Player[player.Name .. "Health"]:Disconnect() end
            playerEsp.Destroy()
        end
    end)
end