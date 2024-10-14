--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local Tabs = Script.Tabs

---// Main \\--
local SniperGroupbox = Tabs.Main:AddLeftGroupbox("Sniper") do
    SniperGroupbox:AddToggle("ElevatorSniper", {
        Text = "Elevator Sniper",
        Default = false
    })

    SniperGroupbox:AddDropdown("ElevatorSniperTarget", {
        SpecialType = "Player",
        Multi = false,

        Text = "Target"
    })
end

local OtherGroupbox = Tabs.Main:AddRightGroupbox("Other") do
    OtherGroupbox:AddToggle("LoopAchievements", {
        Text = "Loop Achievements",
        Default = false
    })

    OtherGroupbox:AddSlider("LoopAchievementsSpeed", {
        Text = "Speed",
        Default = 0.05,
        Min = 0.05,
        Max = 1,
        Rounding = 2,
        Compact = true
    })

    OtherGroupbox:AddDivider()

    OtherGroupbox:AddButton("Create Retro Elevator", function()
        local data = {
            ["FriendsOnly"] = Script.CreateElevatorFrame.Settings.FriendsOnly:GetAttribute("Setting"),
            ["Destination"] = "Hotel",
            ["Mods"] = {
                "RetroMode"
            },
            ["MaxPlayers"] = Script.CreateElevatorFrame.Settings.MaxPlayers.Toggle.Text
        }

        Script.CreateElevator:FireServer(data)
    end)
end

if wax.shared.ExecutorSupport["_SupportsFileSystem"] then
    local PresetGroupbox = Tabs.Main:AddLeftGroupbox("Presets") do
        PresetGroupbox:AddInput('Elevator_PresetName', { Text = 'Preset name' })
        PresetGroupbox:AddButton({
            Text = "Create Preset",
            Func = function()
                if Script.PresetHelper.IsFile(Options.Elevator_PresetName.Value .. ".json") then
                    shared.Notify:Alert({
                        Description = "Preset already exists!"
                    })
                    return
                end
    
                local presetData = {
                    Floor = "Hotel",
                    MaxPlayers = 1,
                    Modifiers = {},
                    FriendsOnly = true
                }
    
                for _, floor in pairs(Script.CreateElevatorFrame.Floors:GetChildren()) do
                    if floor:IsA("TextLabel") and floor.Visible then
                        presetData.Floor = floor.Name
                        break
                    end
                end
    
                for _, modifier in pairs(Script.CreateElevatorFrame.Modifiers:GetChildren()) do
                    if modifier:GetAttribute("Enabled") then
                        table.insert(presetData.Modifiers, modifier.Name)    
                    end
                end
    
                presetData.MaxPlayers = tonumber(Script.CreateElevatorFrame.Settings.MaxPlayers.Toggle.Text)
                presetData.FriendsOnly = Script.CreateElevatorFrame.Settings.FriendsOnly:GetAttribute("Setting")
    
                Script.Functions.CreatePreset(Options.Elevator_PresetName.Value, presetData)
                shared.Notify:Alert({
                    Description = 'Created elevator preset "' .. Options.Elevator_PresetName.Value .. '" with ' .. #presetData.Modifiers .. " modifiers"
                })
    
                Script.Functions.LoadPresets()
                Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
                Options.Elevator_PresetList:SetValue(nil)
            end
        })
    
        PresetGroupbox:AddDivider()
    
        PresetGroupbox:AddDropdown('Elevator_PresetList', { Text = 'Preset list', Values = Script.ElevatorPresets, AllowNull = true })
        PresetGroupbox:AddButton('Load Preset', function()
            Script.Functions.LoadPreset(Options.Elevator_PresetList.Value)
        end)
    
        PresetGroupbox:AddButton('Override Preset', function()
            local presetData = {
                Floor = "Hotel",
                MaxPlayers = 1,
                Modifiers = {},
                FriendsOnly = true
            }
    
            for _, floor in pairs(Script.CreateElevatorFrame.Floors:GetChildren()) do
                if floor:IsA("TextLabel") and floor.Visible then
                    presetData.Floor = floor.Name
                    break
                end
            end
    
            for _, modifier in pairs(Script.CreateElevatorFrame.Modifiers:GetChildren()) do
                if modifier:GetAttribute("Enabled") then
                    table.insert(presetData.Modifiers, modifier.Name)    
                end
            end
    
            presetData.MaxPlayers = tonumber(Script.CreateElevatorFrame.Settings.MaxPlayers.Toggle.Text)
            presetData.FriendsOnly = Script.CreateElevatorFrame.Settings.FriendsOnly:GetAttribute("Setting")
    
            shared.Notify:Alert({
                Description = "Overrided preset: " .. Options.Elevator_PresetList.Value
            })
    
            Script.Functions.CreatePreset(Options.Elevator_PresetList.Value, presetData)
            
            Script.Functions.LoadPresets()
            Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
            Options.Elevator_PresetList:SetValue(nil)
        end)
    
        PresetGroupbox:AddButton('Delete Preset', function()
            if not Script.PresetHelper.IsFile(Options.Elevator_PresetList.Value .. ".json") then
                shared.Notify:Alert({
                    Description = "Preset does not exist!"
                })
                return
            end
    
            local success, err = pcall(function()
                Script.PresetHelper.DeleteFile(Options.Elevator_PresetList.Value .. ".json")
            end)
    
            if not success then
                shared.Notify:Alert({
                    Description = "Failed to delete preset: " .. Options.Elevator_PresetList.Value
                })
                return
            end
    
            shared.Notify:Alert({
                Description = "Deleted preset: " .. Options.Elevator_PresetList.Value
            })
            
            Script.Functions.LoadPresets()
            Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
            Options.Elevator_PresetList:SetValue(nil)
        end)
    
        PresetGroupbox:AddButton('Refresh Presets', function()
            Script.Functions.LoadPresets()
            Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
            Options.Elevator_PresetList:SetValue(nil)
        end)
    
    end
end

--// Sniper \\--
shared.Connect:GiveSignal(shared.RunService.RenderStepped:Connect(function()
    if Toggles.ElevatorSniper.Value and Options.ElevatorSniperTarget.Value then
        local targetCharacter = workspace:FindFirstChild(Options.ElevatorSniperTarget.Value)
        if not targetCharacter then return end

        local targetElevatorID = targetCharacter:GetAttribute("InGameElevator")
        local currentElevatorID = shared.Character:GetAttribute("InGameElevator")
        if currentElevatorID == targetElevatorID then return end

        if targetElevatorID ~= nil then    
            local targetElevator = Script.LobbyElevators:FindFirstChild("LobbyElevator-" .. targetElevatorID) 

            if not targetElevator then
                for _, elevator in pairs(Script.LobbyElevators:GetChildren()) do
                    if elevator.Name:match(Options.ElevatorSniperTarget.Value) then
                        targetElevator = elevator
                    end
                end
            end

            if targetElevator then
                Script.RemotesFolder.ElevatorJoin:FireServer(targetElevator)
            end
        elseif currentElevatorID ~= nil then
            Script.RemotesFolder.ElevatorExit:FireServer()
        end
    end
end))

--// Other \\--
Toggles.LoopAchievements:OnChanged(function(value)
    if value then
        Script.Functions.LoopAchievements()
    end
end)