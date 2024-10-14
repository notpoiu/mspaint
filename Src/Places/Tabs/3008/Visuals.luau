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

        ESPTab:AddToggle("EmployeeESP", {
            Text = "Employee",
            Default = false,
        }):AddColorPicker("EmployeeEspColor", {
            Default = Color3.new(1, 0, 0),
        })

        ESPTab:AddToggle("ItemESP", {
            Text = "Item",
            Default = false,
        }):AddColorPicker("ItemEspColor", {
            Default = Color3.new(1, 0, 1),
        })
    end

    local ESPSettingsTab = ESPTabBox:AddTab("Settings") do
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

local SelfGroupBox = Tabs.Visuals:AddRightGroupbox("Self") do
    SelfGroupBox:AddSlider("FOV", {
        Text = "Field of View",
        Default = 90,
        Min = 50,
        Max = 120,
        Rounding = 0
    })
    
    SelfGroupBox:AddToggle("NoCamShake", {
        Text = "No Camera Shake",
        Default = false
    })

    SelfGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false
    })

    SelfGroupBox:AddToggle("NoFog", {
        Text = "No Fog",
        Default = false
    })

    if wax.shared.ExecutorSupport["require"] then
        SelfGroupBox:AddDivider()
    end

    SelfGroupBox:AddToggle("DeathWaypoint", {
        Text = "Death Waypoint",
        Default = false,
        Visible = wax.shared.ExecutorSupport["require"]
    })

    SelfGroupBox:AddToggle("PersonalWatch", {
        Text = "Personal Watch",
        Default = false,
        Visible = wax.shared.ExecutorSupport["require"]
    })

    SelfGroupBox:AddSlider("MaxWaypoints", {
        Text = "Max Waypoints",
        Default = if wax.shared.ExecutorSupport["require"] then require(Script.WaypointsMenu).waypoint_limit else 4,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Compact = true,
        Visible = wax.shared.ExecutorSupport["require"]
    })
end

--// ESP \\--
Toggles.PlayerESP:OnChanged(function(value)
    if not value then
        for _, connection in pairs(Script.FeatureConnections.Player) do
            connection:Disconnect()
        end
        for _, esp in pairs(Script.ESPTable.Player) do
            esp.Destroy()
        end
    end
end)

Toggles.EmployeeESP:OnChanged(function(value)
    if not value then
        for _, esp in pairs(Script.ESPTable.Employee) do
            esp.Destroy()
        end
    end
end)

Toggles.ItemESP:OnChanged(function(value)
    if not value then
        for _, esp in pairs(Script.ESPTable.Item) do
            esp.Destroy()
        end
    end
end)

--// ESP Settings \\--
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

--// Self \\--
Options.FOV:OnChanged(function(value)
    Script.Settings:SetAttribute("FieldOfView", value)
end)

Toggles.NoCamShake:OnChanged(function(value)
    Script.Settings:SetAttribute("CameraShake", not value)
end)

Toggles.Fullbright:OnChanged(function(value)
    if value then
        shared.Lighting.Ambient = Color3.new(1, 1, 1)
        shared.Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        shared.Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    else
        shared.Lighting.Ambient = Script.CurrentAmbient
        shared.Lighting.ColorShift_Bottom = Script.CurrentColorShift_Bottom
        shared.Lighting.ColorShift_Top = Script.CurrentColorShift_Top
    end
end)

Toggles.NoFog:OnChanged(function(value)
    if value then
        shared.Lighting.FogEnd = 9e9

        if shared.Lighting:FindFirstChild("FoggyDay_Atmosphere") then
            shared.Lighting["FoggyDay_Atmosphere"].Density = 0
        end
    else
        shared.Lighting.FogEnd = Script.DefaultFogEnd

        if shared.Lighting:FindFirstChild("FoggyDay_Atmosphere") and Script["CurrentFoggyDayDensity"] then
            shared.Lighting["FoggyDay_Atmosphere"].Density = Script.CurrentFoggyDayDensity
        end
    end
end)

Toggles.PersonalWatch:OnChanged(function(value)
    if wax.shared.ExecutorSupport["require"] then
        if value then
            Script.Calendar["Gamepass_Clock"].Visible = true
            while Toggles.PersonalWatch.Value and task.wait() do
                Script.Calendar["Gamepass_Clock"].Text = require(shared.ReplicatedStorage.Modules.Date).GetTimeInClockFormat(Script.TimeLeft.Value)
                
                if Script.TimeLeft.Value == 5 then
                    Script.Calendar["Gamepass_Clock"].Countdown.Playing = true
                end
            end
        else
            Script.Calendar["Gamepass_Clock"].Visible = Script.GamePassClockVisible
        end
    end
end)

Toggles.DeathWaypoint:OnChanged(function(value)
    if wax.shared.ExecutorSupport["require"] then
        require(Script.WaypointsMenu).create_death = value
        require(Script.WaypointsMenu).death_waypoint = value
    end
end)

Options.MaxWaypoints:OnChanged(function(value)
    if wax.shared.ExecutorSupport["require"] then
        require(Script.WaypointsMenu).waypoint_limit = value
    end
end)