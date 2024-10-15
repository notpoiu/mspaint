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
    
        ESPTab:AddToggle("ObjectiveESP", {
            Text = "Objective",
            Default = false,
        }):AddColorPicker("ObjectiveEspColor", {
            Default = Color3.new(0, 1, 0),
        })
    
        ESPTab:AddToggle("EntityESP", {
            Text = "Entity",
            Default = false,
        }):AddColorPicker("EntityEspColor", {
            Default = Color3.new(1, 0, 0),
        })
    
        ESPTab:AddToggle("ItemESP", {
            Text = "Item",
            Default = false,
        }):AddColorPicker("ItemEspColor", {
            Default = Color3.new(1, 0, 1),
        })
    
        ESPTab:AddToggle("ChestESP", {
            Text = "Chest",
            Default = false,
        }):AddColorPicker("ChestEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("PlayerESP", {
            Text = "Player",
            Default = false,
        }):AddColorPicker("PlayerEspColor", {
            Default = Color3.new(1, 1, 1),
        })
    
        ESPTab:AddToggle("HidingSpotESP", {
            Text = Script.HidingPlaceName[Script.Floor.Value],
            Default = false,
        }):AddColorPicker("HidingSpotEspColor", {
            Default = Color3.new(0, 0.5, 0),
        })
    
        ESPTab:AddToggle("GoldESP", {
            Text = "Gold",
            Default = false,
        }):AddColorPicker("GoldEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("GuidingLightESP", {
            Text = "Guiding Light",
            Default = false,
        }):AddColorPicker("GuidingLightEspColor", {
            Default = Color3.new(0, 0.5, 1),
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
    AmbientGroupBox:AddSlider("Brightness", {
        Text = "Brightness",
        Default = 0,
        Min = 0,
        Max = 3,
        Rounding = 1,
    })

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

local NotifyTabBox = Tabs.Visuals:AddRightTabbox() do
    local NotifyTab = NotifyTabBox:AddTab("Notifier") do
        NotifyTab:AddDropdown("NotifyEntity", {
            AllowNull = true,
            Values = {"Blitz", "Lookman", "Rush", "Ambush", "Eyes", "Halt Room", "A60", "A120", "Jeff The Killer", "Gloombat Swarm", "Void/Glitch"},
            Default = {},
            Multi = true,

            Text = "Notify Entities"
        })

        NotifyTab:AddToggle("NotifyPadlock", {
            Text = "Notify Library Code",
            Default = false,
        })

        NotifyTab:AddToggle("NotifyOxygen", {
            Text = "Notify Oxygen",
            Default = false,
        })

        NotifyTab:AddToggle("NotifyHideTime", {
            Text = "Notify Hide Time",
            Default = false,
        })
    end

    local NotifySettingsTab = NotifyTabBox:AddTab("Settings") do
        NotifySettingsTab:AddToggle("NotifyChat", {
            Text = "Notify Chat",
            Tooltip = "Entity and Padlock Code",
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

        NotifySettingsTab:AddDropdown("NotifyStyle", {
            AllowNull = false,
            Values = {"Linoria", "Doors"},
            Default = "Linoria",
            Multi = false,

            Text = "Notification Style"
        })
    end
end

local SelfTabBox = Tabs.Visuals:AddRightTabbox() do
    local SelfTab = SelfTabBox:AddTab("Self") do
        SelfTab:AddToggle("ThirdPerson", {
            Text = "Third Person",
            Default = false
        }):AddKeyPicker("ThirdPersonKey", {
            Default = "V",
            Text = "Third Person",
            Mode = "Toggle",
            SyncToggleState = not shared.Library.IsMobile -- ????
        })
        
        SelfTab:AddSlider("FOV", {
            Text = "Field of View",
            Default = 70,
            Min = 70,
            Max = 120,
            Rounding = 0
        })
        
        SelfTab:AddToggle("NoCamBob", {
            Text = "No Camera Bobbing",
            Default = false,
            Visible = wax.shared.ExecutorSupport["require"]
        })
    
        SelfTab:AddToggle("NoCamShake", {
            Text = "No Camera Shake",
            Default = false,
            Visible = wax.shared.ExecutorSupport["require"]
        })
    
        SelfTab:AddToggle("NoCutscenes", {
            Text = "No Cutscenes",
            Default = false,
        })
    
        SelfTab:AddToggle("TranslucentHidingSpot", {
            Text = "Translucent " .. Script.HidingPlaceName[Script.Floor.Value],
            Default = false
        })
        
        SelfTab:AddSlider("HidingTransparency", {
            Text = "Hiding Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 1,
            Compact = true,
        })
    end

    local EffectsTab = SelfTabBox:AddTab("Effects") do
        EffectsTab:AddToggle("NoGlitchEffect", {
            Text = "No Glitch Effect",
            Default = false
        })

        EffectsTab:AddToggle("NoVoidEffect", {
            Text = "No Void Effect",
            Default = false
        })

        EffectsTab:AddToggle("NoSpiderJumpscare", {
            Text = "No Spider Jumpscare",
            Default = false
        })
    end
end

--// ESP \\--
Toggles.DoorESP:OnChanged(function(value)
    if value then
        if workspace.CurrentRooms[Script.CurrentRoom]:FindFirstChild("Door") then
            Script.Functions.DoorESP(workspace.CurrentRooms[Script.CurrentRoom])
        end

        if workspace.CurrentRooms[Script.NextRoom]:FindFirstChild("Door") then
            Script.Functions.DoorESP(workspace.CurrentRooms[Script.NextRoom])
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

Toggles.ObjectiveESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom)
        if currentRoomModel then
            for _, asset in pairs(currentRoomModel:GetDescendants()) do
                task.spawn(Script.Functions.ObjectiveESP, asset)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Objective) do
            esp.Destroy()
        end
    end
end)

Options.ObjectiveEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Objective) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.EntityESP:OnChanged(function(value)
    if value then
        for _, entity in pairs(workspace:GetChildren()) do
            if table.find(Script.EntityTable.Names, entity.Name) then
                Script.Functions.EntityESP(entity)
            end
        end

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom)
        if currentRoomModel then
            for _, entity in pairs(currentRoomModel:GetDescendants()) do
                if table.find(Script.EntityTable.SideNames, entity.Name) then
                    Script.Functions.SideEntityESP(entity)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Entity) do
            esp.Destroy()
        end
        for _, esp in pairs(Script.ESPTable.SideEntity) do
            esp.Destroy()
        end
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

Toggles.ItemESP:OnChanged(function(value)
    if value then
        for _, item in pairs(workspace.Drops:GetChildren()) do
            if Script.Functions.ItemCondition(item) then
                Script.Functions.ItemESP(item, true)
            end
        end

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom)
        if currentRoomModel then
            for _, item in pairs(currentRoomModel:GetDescendants()) do
                if Script.Functions.ItemCondition(item) then
                    Script.Functions.ItemESP(item)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.DroppedItem) do
            esp.Destroy()
        end

        for _, esp in pairs(Script.ESPTable.Item) do
            esp.Destroy()
        end
    end
end)

Options.ItemEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.DroppedItem) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end

    for _, esp in pairs(Script.ESPTable.Item) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ChestESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom)
        if currentRoomModel then
            for _, chest in pairs(currentRoomModel:GetDescendants()) do
                if chest:GetAttribute("Storage") == "ChestBox" or chest.Name == "Toolshed_Small" then
                    Script.Functions.ChestESP(chest)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Chest) do
            esp.Destroy()
        end
    end
end)

Options.ChestEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Chest) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.PlayerESP:OnChanged(function(value)
    if value then
        for _, player in pairs(shared.Players:GetPlayers()) do
            if player == shared.LocalPlayer or not player.Character then continue end
            
            Script.Functions.PlayerESP(player.Character)
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
    for _, esp in pairs(Script.ESPTable.Player) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.HidingSpotESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom)
        if currentRoomModel then
            for _, wardrobe in pairs(currentRoomModel:GetDescendants()) do
                if wardrobe:GetAttribute("LoadModule") == "Wardrobe" or wardrobe:GetAttribute("LoadModule") == "Bed" or wardrobe.Name == "Rooms_Locker" or wardrobe.Name == "RetroWardrobe" then
                    Script.Functions.HidingSpotESP(wardrobe)
                end
            end
        end 
    else
        for _, esp in pairs(Script.ESPTable.HidingSpot) do
            esp.Destroy()
        end
    end
end)

Options.HidingSpotEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.HidingSpot) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.GoldESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom)
        if currentRoomModel then
            for _, gold in pairs(currentRoomModel:GetDescendants()) do
                if gold.Name == "GoldPile" then
                    Script.Functions.GoldESP(gold)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Gold) do
            esp.Destroy()
        end
    end
end)

Options.GoldEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Gold) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.GuidingLightESP:OnChanged(function(value)
    if value then
        for _, guidance in pairs(shared.Camera:GetChildren()) do
            if guidance:IsA("BasePart") and guidance.Name == "Guidance" then
                Script.Functions.GuidingLightEsp(guidance)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Guiding) do
            esp.Destroy()
        end
    end
end)

Options.GuidingLightEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Guiding) do
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
Options.Brightness:OnChanged(function(value)
    shared.Lighting.Brightness = value
end)

Toggles.Fullbright:OnChanged(function(value)
    if value then
        shared.Lighting.Ambient = Color3.new(1, 1, 1)
    else
        if Script.Alive then
            shared.Lighting.Ambient = workspace.CurrentRooms[shared.LocalPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
        else
            shared.Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
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
    shared.Lighting.Brightness = Options.Brightness.Value
end))

shared.Connect:GiveSignal(shared.Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Toggles.Fullbright.Value then
        shared.Lighting.Ambient = Color3.new(1, 1, 1)
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

Toggles.AntiLag:OnChanged(function(value)
    for _, object in pairs(workspace.CurrentRooms:GetDescendants()) do
        if object:IsA("BasePart") then
            if not object:GetAttribute("Material") then object:SetAttribute("Material", object.Material) end
            if not object:GetAttribute("Reflectance") then object:SetAttribute("Reflectance", object.Reflectance) end

            object.Material = value and Enum.Material.Plastic or object:GetAttribute("Material")
            object.Reflectance = value and 0 or object:GetAttribute("Reflectance")
        elseif object:IsA("Decal") then
            if not object:GetAttribute("Transparency") then object:SetAttribute("Transparency", object.Transparency) end

            if not table.find(Script.SlotsName, object.Name) then
                object.Transparency = value and 1 or object:GetAttribute("Transparency")
            end
        end
    end

    workspace.Terrain.WaterReflectance = if value then 0 else 1
    workspace.Terrain.WaterTransparency = if value then 0 else 1
    workspace.Terrain.WaterWaveSize = if value then 0 else 0.05
    workspace.Terrain.WaterWaveSpeed = if value then 0 else 8
    shared.Lighting.GlobalShadows = not value
end)

--// Notifier \\--
if Script.IsBackdoor then
    local clientRemote = Script.FloorReplicated.ClientRemote
    local haste_incoming_progress = nil

    shared.Connect:GiveSignal(clientRemote.Haste.Remote.OnClientEvent:Connect(function(value)
        if not value and Toggles.NotifyEntity.Value then
            haste_incoming_progress = Instance.new("Part", shared.Workspace) do
                haste_incoming_progress.Anchored = true
                haste_incoming_progress.CanCollide = false
                haste_incoming_progress.Name = "_internal_mspaint_haste"
                haste_incoming_progress.Transparency = 1
            end

            shared.Notify:Alert({
                Title = "ENTITIES",
                Description = "Haste is incoming, please find a lever ASAP!",
                Time = haste_incoming_progress,

                Warning = true
            })

            repeat task.wait() until not haste_incoming_progress or not Toggles.NotifyEntity.Value or not shared.Character:GetAttribute("Alive")
            if haste_incoming_progress then haste_incoming_progress:Destroy() end
        end
        
        if value and haste_incoming_progress then
            haste_incoming_progress:Destroy()
        end
    end))
end

shared.Connect:GiveSignal(Script.RemotesFolder.HideMonster.OnClientEvent:Connect(function()
    if Script.IsBackdoor or Script.IsRooms or Script.IsRetro then return end

    local hideTime = Script.Functions.CalculateHideTime(Script.CurrentRoom) or math.huge
    local finalTime = tick() + math.round(hideTime)

    if Toggles.NotifyHideTime.Value and hideTime ~= math.huge then
        while shared.Character:GetAttribute("Hiding") and Script.Alive and not shared.Library.Unloaded and Toggles.NotifyHideTime.Value do
            local remainingTime = math.max(0, finalTime - tick())

            if wax.shared.ExecutorSupport["firesignal"] then
                firesignal(Script.RemotesFolder.Caption.OnClientEvent, string.format("%.1f", remainingTime))
            else
                Script.Functions.Captions(string.format("%.1f", remainingTime))
            end

            task.wait()
        end
    end
end))

Options.NotifyVolume:OnChanged(function(value)
    shared.NotifyVolume = value
end)

Options.NotifySide:OnChanged(function(value)
    shared.Library.NotifySide = value
end)

Options.NotifyStyle:OnChanged(function(value)
    shared.NotifyStyle = value
end)

Toggles.NoCutscenes:OnChanged(function(value)
    if Script.MainGame then
        local cutscenes = Script.MainGame:FindFirstChild("Cutscenes", true)
        if cutscenes then
            for _, cutscene in pairs(cutscenes:GetChildren()) do
                if table.find(Script.CutsceneExclude, cutscene.Name) then continue end
    
                local defaultName = cutscene.Name:gsub("_", "")
                cutscene.Name = value and "_" .. defaultName or defaultName
            end
        end
    end

    if Script.FloorReplicated then
        for _, cutscene in pairs(Script.FloorReplicated:GetChildren()) do
            if not cutscene:IsA("ModuleScript") or table.find(Script.CutsceneExclude, cutscene.Name) then continue end

            local defaultName = cutscene.Name:gsub("_", "")
            cutscene.Name = value and "_" .. defaultName or defaultName
        end
    end
end)

Toggles.TranslucentHidingSpot:OnChanged(function(value)
    if value and shared.Character:GetAttribute("Hiding") then
        for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
            if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end

            if obj.Value == shared.Character then
                task.spawn(function()
                    local affectedParts = {}
                    for _, v in pairs(obj.Parent:GetChildren()) do
                        if not v:IsA("BasePart") then continue end

                        v.Transparency = Options.HidingTransparency.Value
                        table.insert(affectedParts, v)
                    end

                    repeat task.wait()
                        for _, part in pairs(affectedParts) do
                            task.wait()
                            part.Transparency = Options.HidingTransparency.Value
                        end
                    until not shared.Character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                    
                    for _, v in pairs(affectedParts) do
                        v.Transparency = 0
                    end
                end)

                break
            end
        end
    end
end)

--// Self \\--
Toggles.NoGlitchEffect:OnChanged(function(value)
    if not Script.EntityModules then return end
    local module = Script.EntityModules:FindFirstChild("Glitch") or Script.EntityModules:FindFirstChild("_Glitch")

    if module then
        module.Name = if value then "_Glitch" else "Glitch"
    end
end)

Toggles.NoVoidEffect:OnChanged(function(value)
    if not Script.EntityModules then return end
    local module = Script.EntityModules:FindFirstChild("Void") or Script.EntityModules:FindFirstChild("_Void")

    if module then
        module.Name = if value then "_Void" else "Void"
    end
end)

Toggles.NoSpiderJumpscare:OnChanged(function(value)
    if not Script.MainGame then return end
    local module = Script.MainGame:FindFirstChild("SpiderJumpscare", true) or Script.MainGame:FindFirstChild("_SpiderJumpscare", true)

    if module then
        module.Name = if value then "_SpiderJumpscare" else "SpiderJumpscare"
    end
end)