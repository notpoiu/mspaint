--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
Script.PresetHelper = wax.shared.FileHelper.new("mspaint/doors/presets")
Script.ElevatorPresetData = {}
Script.ElevatorPresets = {}

-- Functions
function Script.Functions.CreatePreset(name: string, data: table)
    local presetData = Script.Functions.EnforceTypes(data, {
        Floor = "Hotel",
        MaxPlayers = 1,
        Modifiers = nil,
        FriendsOnly = true
    })

    Script.PresetHelper.CreateFile(name .. ".json", shared.HttpService:JSONEncode(presetData))
end

function Script.Functions.LoadPresets()
    table.clear(Script.ElevatorPresets)
    table.clear(Script.ElevatorPresetData)

    for _, file in pairs(Script.PresetHelper.GetFilesClean()) do
        local success, ret = pcall(function()
            local data = Script.PresetHelper.ReadFile(file .. ".json")
            return shared.HttpService:JSONDecode(data)
        end)

        if success then
            Script.ElevatorPresetData[file] = Script.Functions.EnforceTypes(ret, {
                Floor = "Hotel",
                MaxPlayers = 1,
                Modifiers = nil,
                FriendsOnly = true
            })

            table.insert(Script.ElevatorPresets, file)
        else
            shared.Notify:Alert({
                Description = "Failed to load preset: " .. file
            })
        end
    end

    Options.Elevator_PresetList:SetValues(Script.ElevatorPresets)
    Options.Elevator_PresetList:SetValue(nil)
end

function Script.Functions.LoadPreset(name: string)
    local success, ret = pcall(function()
        local data = Script.PresetHelper.ReadFile(name .. ".json")
        return shared.HttpService:JSONDecode(data)
    end)

    if not success then
        shared.Notify:Alert({
            Description = "Failed to load preset: " .. name .. ".json"
        })
        return
    end

    local presetData = Script.Functions.EnforceTypes(ret, {
        Floor = "Hotel",
        MaxPlayers = 1,
        Modifiers = nil,
        FriendsOnly = true
    })

    local data = {
        ["FriendsOnly"] = presetData.FriendsOnly,
        ["Destination"] = presetData.Floor,
        ["Mods"] = presetData.Modifiers or {},
        ["MaxPlayers"] = tostring(presetData.MaxPlayers)
    }

    Script.CreateElevator:FireServer(data)

    shared.Notify:Alert({
        Description = "Loaded elevator preset: " .. name
    })
end