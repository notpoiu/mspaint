local UICreator = {}

local repo = "https://raw.githubusercontent.com/deividcomsono/LinoriaLib/refs/heads/main/"

shared.Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

shared.Toggles = getgenv().Linoria.Toggles
shared.Options = getgenv().Linoria.Options

getgenv()._internal_unload_mspaint = function()
    getgenv().mspaint_loading = false
    getgenv().mspaint_loaded = false
    task.spawn(shared.Library.Unload)
end

function UICreator:CreateWindow()
    local Window = shared.Library:CreateWindow({
        Title = "mspaint v3 | " .. shared.ScriptName,
        Center = true,
        AutoShow = true,
        Resizable = true,
        NotifySide = "Right",
        ShowCustomCursor = true,
        TabPadding = 2,
        MenuFadeTime = 0
    })

    --// Notificatins \\--
    shared.NotifyStyle = "Linoria"
    shared.NotifyVolume = 2
    shared.Notify = require("Notify")

    --// Checker \\--
    shared.CheckToggle = function(toggleName: string, value: boolean)
        return shared.Toggles[toggleName] and shared.Toggles[toggleName].Value == value
    end
    shared.CheckOption = function(optionName: string, value: any)
        return shared.Options[optionName] and (typeof(shared.Options[optionName].Value) == "table" and shared.Options[optionName].Value[value] or shared.Options[optionName].Value == value)
    end

    --// Unload Handler \\--
    shared.Library:OnUnload(function()
        print("Unloading...")

        shared.Fly:Stop()

        for _, connection in pairs(shared.Connections) do
            connection:Disconnect()
        end

        getgenv().mspaint_loading = false
        getgenv().mspaint_loaded = false
        shared.Library.Unloaded = true
        print("Unloaded!")
    end)

    return Window
end

function UICreator:CreateSettingsTab()
    local SettingsTab = shared.Window:AddTab("UI Settings")

    local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")
    local CreditsGroup = SettingsTab:AddRightGroupbox("Credits")

    MenuGroup:AddToggle("ExecuteOnTeleport", { Default = false, Text = "Execute On Teleport" })
    MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "Open Keybind Menu", Callback = function(value) shared.Library.KeybindFrame.Visible = value end})
    MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) shared.Library.ShowCustomCursor = Value end})
    MenuGroup:AddDivider()
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    MenuGroup:AddButton("Join Discord", function()
        local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
        Inviter.Join("https://discord.com/invite/cfyMptntHr")
        Inviter.Prompt({
            name = "mspaint",
            invite = "https://discord.com/invite/cfyMptntHr",
        })
    end):AddButton("Copy Link", function()
        if setclipboard then
            setclipboard("https://discord.com/invite/cfyMptntHr")
            shared.Library:Notify("Copied discord link to clipboard!")
        else
            shared.Library:Notify("Discord link: https://discord.com/invite/cfyMptntHr", 10)
        end
    end)
    MenuGroup:AddButton("Unload", function() shared.Library:Unload() end)

    CreditsGroup:AddLabel("Developers:")
    CreditsGroup:AddLabel("upio - owner")
    CreditsGroup:AddLabel("deividcomsono - main script dev")
    CreditsGroup:AddLabel("mstudio45")
    CreditsGroup:AddLabel("bacalhauz")

    shared.Library.ToggleKeybind = shared.Options.MenuKeybind

    ThemeManager:SetLibrary(shared.Library)
    SaveManager:SetLibrary(shared.Library)

    SaveManager:IgnoreThemeSettings()

    SaveManager:SetFolder("mspaint/" .. string.lower(shared.ScriptLoader))

    SaveManager:BuildConfigSection(SettingsTab)
    ThemeManager:ApplyToTab(SettingsTab)

    SaveManager:LoadAutoloadConfig()

    shared.Connect:GiveSignal(shared.LocalPlayer.OnTeleport:Connect(function()
        if not shared.Toggles.ExecuteOnTeleport.Value or getgenv().queued_to_teleport then return end

        getgenv().queued_to_teleport = true
        queue_on_teleport([[ loadstring(game:HttpGet("https://github.com/notpoiu/mspaint/releases/latest/download/Script.luau"))() ]])
    end))

    return SettingsTab
end

return UICreator