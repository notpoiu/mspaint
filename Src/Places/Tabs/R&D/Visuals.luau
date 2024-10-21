--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local Tabs = Script.Tabs

--// Visuals \\--
local ESPTabBox = Tabs.Visuals:AddLeftTabbox() do
    local ESPTab = ESPTabBox:AddTab("ESP") do
        ESPTab:AddToggle("DoorESP", {
            Text = "Door",
            Default = false,
        }):AddColorPicker("DoorEspColor", {
            Default = Color3.new(0, 1, 1),
        })

        ESPTab:AddToggle("EntityESP", {
            Text = "Entity",
            Default = false,
        }):AddColorPicker("EntityEspColor", {
            Default = Color3.new(1, 0, 0),
        })

        ESPTab:AddToggle("BatteryESP", {
            Text = "Battery",
            Default = false,
        }):AddColorPicker("BatteryEspColor", {
            Default = Color3.new(1, 1, 0),
        })

        ESPTab:AddToggle("LockerESP", {
            Text = "Locker",
            Default = false,
        }):AddColorPicker("LockerEspColor", {
            Default = Color3.new(0, 0.5, 0),
        })

        ESPTab:AddToggle("TableESP", {
            Text = "Table",
            Default = false,
        }):AddColorPicker("TableEspColor", {
            Default = Color3.new(0, 1, 0),
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

local AmbientGroupBox = Tabs.Visuals:AddLeftGroupbox("Ambient") do
    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })

    AmbientGroupBox:AddToggle("NoFlashlightShadow", {
        Text = "No Flashlight Shadow",
        Default = false,
    })

    AmbientGroupBox:AddToggle("NoBlur", {
        Text = "No Blur",
        Default = false,
    })
end

local NotifyTabBox = Tabs.Visuals:AddRightTabbox() do
    local NotifyTab = NotifyTabBox:AddTab("Notifier") do
        NotifyTab:AddToggle("NotifyEntity", {
            Text = "Notify Entities",
            Default = false,
        })
    end

    local NotifySettingsTab = NotifyTabBox:AddTab("Settings") do
        NotifySettingsTab:AddToggle("NotifyChat", {
            Text = "Notify Chat",
            Default = false,
        })

        NotifySettingsTab:AddInput("NotifyEntityMessage", {
            Default = "has spawned!",
            Numeric = false,
            Finished = true,
            ClearTextOnFocus = false,

            Text = "Entity Notifier Message"
        })

        NotifySettingsTab:AddDivider()
        
        NotifySettingsTab:AddToggle("NotifySound", {
            Text = "Play Alert Sound",
            Default = true,
        })

        NotifySettingsTab:AddSlider("NotifyVolume", {
            Text = "Notify Volume",
            Default = 2,
            Min = 0,
            Max = 5,
            Rounding = 1
        })

        NotifySettingsTab:AddDropdown("NotifySide", {
            AllowNull = false,
            Values = {"Left", "Right"},
            Default = "Right",
            Multi = false,

            Text = "Notification Side"
        })
    end
end

--// ESP \\--
Toggles.DoorESP:OnChanged(function(value)
    if value then
        for _, room in pairs(workspace.rooms:GetChildren()) do
            Script.Functions.DoorESP(room)
        end

        for _, room in pairs(workspace.next:GetChildren()) do
            Script.Functions.DoorESP(room)
        end
    else
        for _, connection in pairs(Script.FeatureConnections.Door) do
            connection:Disconnect()
        end

        for _, esp in pairs(Script.ESPTable.Door) do
            esp.Destroy()
        end
    end
end)

Options.DoorEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Door) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.BatteryESP:OnChanged(function(value)
    if value then
        for _, battery in pairs(workspace.rooms:GetDescendants()) do
            if battery.Name ~= "battery" then continue end
            Script.Functions.BatteryESP(battery)
        end

        for _, battery in pairs(workspace.next:GetDescendants()) do
            if battery.Name ~= "battery" then continue end
            Script.Functions.BatteryESP(battery)
        end
    else
        for _, esp in pairs(Script.ESPTable.Battery) do
            esp.Destroy()
        end
    end
end)

Toggles.LockerESP:OnChanged(function(value)
    if value then
        for _, hideLocker in pairs(workspace.rooms:GetDescendants()) do
            if hideLocker.Name ~= "hidelocker" then continue end
            Script.Functions.LockerESP(hideLocker)
        end

        for _, hideLocker in pairs(workspace.next:GetDescendants()) do
            if hideLocker.Name ~= "hidelocker" then continue end
            Script.Functions.LockerESP(hideLocker)
        end
    else
        for _, esp in pairs(Script.ESPTable.Locker) do
            esp.Destroy()
        end
    end
end)

Options.LockerEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Locker) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.TableESP:OnChanged(function(value)
    if value then
        for _, hideTable in pairs(workspace.rooms:GetDescendants()) do
            if hideTable.Name ~= "hidetable" then continue end
            Script.Functions.TableESP(hideTable)
        end

        for _, hideTable in pairs(workspace.next:GetDescendants()) do
            if hideTable.Name ~= "hidetable" then continue end
            Script.Functions.TableESP(hideTable)
        end
    else
        for _, esp in pairs(Script.ESPTable.Table) do
            esp.Destroy()
        end
    end
end)

Options.TableEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Table) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
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

--// Ambient \\--
Toggles.Fullbright:OnChanged(function(value)
    if value then
        shared.Lighting.Ambient = Color3.new(1, 1, 1)
    else
        shared.Lighting.Ambient = Script.CurrentAmbient
    end
end)

Toggles.NoFlashlightShadow:OnChanged(function(value)
    local slender = Script.MainUI and Script.MainUI:FindFirstChild("slender")

    if slender then
        slender.ImageTransparency = if value then 1 else 0
        for _, bar in pairs(slender:GetChildren()) do
            bar.Visible = not value
        end
    end
end)

Toggles.NoBlur:OnChanged(function(value)
    local blur = shared.Lighting:FindFirstChildOfClass("BlurEffect")

    if blur then
        blur.Enabled = not value
    end
end)

--// Notifier \\--
Options.NotifyVolume:OnChanged(function(value)
    shared.NotifyVolume = value
end)

Options.NotifySide:OnChanged(function(value)
    shared.Library.NotifySide = value
end)