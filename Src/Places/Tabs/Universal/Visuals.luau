--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local Tabs = Script.Tabs

--// Visuals \\--
local ESPTabBox = Tabs.Visuals:AddLeftTabbox() do
    local ESPTab = ESPTabBox:AddTab("ESP") do
        ESPTab:AddToggle("PlayerESP", {
            Text = "Player",
            Default = false,
        }):AddColorPicker("PlayerEspColor", {
            Default = Color3.new(1, 1, 1),
        })
    end

    local ESPSettingsTab = ESPTabBox:AddTab("Settings") do
        ESPSettingsTab:AddToggle("ESPTeamColor", {
            Text = "Team Color",
            Default = false,
        })

        ESPSettingsTab:AddToggle("ESPRainbow", {
            Text = "Rainbow ESP",
            Default = false,
        })

        ESPSettingsTab:AddDivider()

        ESPSettingsTab:AddToggle("ESPHighlight", {
            Text = "Enable Highlight",
            Default = true
        })

        ESPSettingsTab:AddSlider("ESPFillTransparency", {
            Text = "Fill Transparency",
            Default = 0.75,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPOutlineTransparency", {
            Text = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2
        })

        ESPSettingsTab:AddDivider()

        ESPSettingsTab:AddToggle("ESPDistance", {
            Text = "Show Distance",
            Default = true
        })
    
        ESPSettingsTab:AddSlider("ESPTextSize", {
            Text = "Text Size",
            Default = 22,
            Min = 16,
            Max = 26,
            Rounding = 0
        })
    
        ESPSettingsTab:AddDivider()

        ESPSettingsTab:AddToggle("ESPTracer", {
            Text = "Enable Tracer",
            Default = false
        })

        ESPSettingsTab:AddDropdown("ESPTracerStart", {
            AllowNull = false,
            Values = {"Bottom", "Center", "Top", "Mouse"},
            Default = "Bottom",
            Multi = false,

            Text = "Tracer Start Position"
        })

        ESPSettingsTab:AddDivider()

        ESPSettingsTab:AddToggle("ESPArrow", {
            Text = "Enable Arrow",
            Default = false
        })

        ESPSettingsTab:AddSlider("ESPArrowCenterOffset", {
            Text = "Arrow Center Offset",
            Default = 300,
            Min = 0,
            Max = 500,
            Rounding = 0
        })
    end
end

local AmbientGroupBox = Tabs.Visuals:AddRightGroupbox("Ambient") do
    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })

    AmbientGroupBox:AddToggle("NoFog", {
        Text = "No Fog",
        Default = false,
    })

    AmbientGroupBox:AddToggle("AntiLag", {
        Text = "Anti-Lag",
        Default = false,
    })
end

--// ESP \\--
Toggles.PlayerESP:OnChanged(function(value)
    if value then
        for _, player in pairs(shared.Players:GetPlayers()) do
            if not (player ~= shared.LocalPlayer and player.Character) then continue end
            
            Script.Functions.PlayerESP(player)
        end
    else
        for _, connection in pairs(Script.FeatureConnections.Player) do
            connection:Disconnect()
        end
        for _, esp in pairs(Script.ESPTable.Player) do
            esp.Destroy()
        end
    end
end)

Options.PlayerEspColor:OnChanged(function(value)
    if Toggles.ESPTeamColor then return end
    for _, esp in pairs(Script.ESPTable.Player) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

--// ESP Settings \\--
Toggles.ESPTeamColor:OnChanged(function(value)
    for player, esp in pairs(Script.ESPTable.Player) do
        local color = if value then player.TeamColor.Color else Options.PlayerEspColor.Value
        esp.Update({
            FillColor = color,
            OutlineColor = color,
            TextColor = color,
        })
    end
end)

Toggles.ESPRainbow:OnChanged(function(value)
    shared.ESPLibrary.Rainbow.Set(value)
end)

Toggles.ESPHighlight:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.SetVisible(value, false)
        end
    end
end)

Options.ESPFillTransparency:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ FillTransparency = value })
        end
    end
end)

Options.ESPOutlineTransparency:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ OutlineTransparency = value })
        end
    end
end)

Toggles.ESPDistance:OnChanged(function(value)
    shared.ESPLibrary.Distance.Set(value)
end)

Options.ESPTextSize:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ TextSize = value })
        end
    end
end)

Toggles.ESPTracer:OnChanged(function(value)
    shared.ESPLibrary.Tracers.Set(value)
end)

Options.ESPTracerStart:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ Tracer = { From = value } })
        end
    end
end)

Toggles.ESPArrow:OnChanged(function(value)
    shared.ESPLibrary.Arrows.Set(value)
end)

Options.ESPArrowCenterOffset:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ Arrow = { CenterOffset = value } })
        end
    end
end)

--// Ambient \\--
Toggles.Fullbright:OnChanged(function(value)
    if not value then Script.LastBright = shared.Lighting.Brightness end

    shared.Lighting.Brightness = if value then 2 else shared.Lighting.Brightness
    shared.Lighting.GlobalShadows = value
end)

Toggles.NoFog:OnChanged(function(value)
    if not shared.Lighting:GetAttribute("FogStart") then shared.Lighting:SetAttribute("FogStart", shared.Lighting.FogStart) end
    if not shared.Lighting:GetAttribute("FogEnd") then shared.Lighting:SetAttribute("FogEnd", shared.Lighting.FogEnd) end

    shared.Lighting.FogStart = value and 0 or shared.Lighting:GetAttribute("FogStart")
    shared.Lighting.FogEnd = value and math.huge or shared.Lighting:GetAttribute("FogEnd")

    local fog = shared.Lighting:FindFirstChildOfClass("Atmosphere")
    if fog then
        if not fog:GetAttribute("Density") then fog:SetAttribute("Density", fog.Density) end

        fog.Density = value and 0 or fog:GetAttribute("Density")
    end
end)

shared.Connect:GiveSignal(shared.Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if Toggles.Fullbright.Value then
        shared.Lighting.Brightness = 2
    end
end))

shared.Connect:GiveSignal(shared.Lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
    if Toggles.NoFog.Value then
        shared.Lighting.FogStart = 0
    end
end))

shared.Connect:GiveSignal(shared.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if Toggles.NoFog.Value then
        shared.Lighting.FogEnd = math.huge
    end
end))

shared.Connect:GiveSignal(shared.Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
    if Toggles.Fullbright.Value then
        shared.Lighting.GlobalShadows = Toggles.Fullbright.Value
    end
end))

Toggles.AntiLag:OnChanged(function(value)
    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") then
            if not object:GetAttribute("Material") then object:SetAttribute("Material", object.Material) end
            if not object:GetAttribute("Reflectance") then object:SetAttribute("Reflectance", object.Reflectance) end

            object.Material = value and Enum.Material.Plastic or object:GetAttribute("Material")
            object.Reflectance = value and 0 or object:GetAttribute("Reflectance")
        elseif object:IsA("Decal") then
            if not object:GetAttribute("Transparency") then object:SetAttribute("Transparency", object.Transparency) end
            object.Transparency = value and 1 or object:GetAttribute("Transparency")
        end
    end

    workspace.Terrain.WaterReflectance = if value then 0 else 1
    workspace.Terrain.WaterTransparency = if value then 0 else 1
    workspace.Terrain.WaterWaveSize = if value then 0 else 0.05
    workspace.Terrain.WaterWaveSpeed = if value then 0 else 8
    shared.Lighting.GlobalShadows = not value
end)