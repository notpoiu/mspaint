--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/MS-ESP/refs/heads/main/source.lua"))()
shared.ESPLibrary = ESPLibrary

type ESP = {
    Color: Color3,
    IsEntity: boolean,
    IsDoubleDoor: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string
}

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        IsDoubleDoor = args.IsDoubleDoor or false,
        Type = args.Type or "None",
        OnDestroy = args.OnDestroy or nil,

        Invisible = false,
        Humanoid = nil
    }

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
        if ESPManager.Object.PrimaryPart.Transparency == 1 then
            ESPManager.Invisible = true
            ESPManager.Object.PrimaryPart.Transparency = 0.99
        end

        local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
        if not humanoid then humanoid = Instance.new("Humanoid", ESPManager.Object) end
        ESPManager.Humanoid = humanoid
    end

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
            Enabled = Toggles.ESPTracer.Value,
            From = Options.ESPTracerStart.Value,
            Color = ESPManager.Color
        },
        
        Arrow = {
            Enabled = Toggles.ESPArrow.Value,
            CenterOffset = Options.ESPArrowCenterOffset.Value,
            Color = ESPManager.Color
        },

        OnDestroy = ESPManager.OnDestroy or function()
            if ESPManager.Object.PrimaryPart and ESPManager.Invisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
            if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
        end
    })

    table.insert(Script.ESPTable[args.Type], ESPInstance)

    return ESPInstance
end

function Script.Functions.PlayerESP(character: Model)
    if not (character and character.PrimaryPart and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0) then return end

    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = character,
        Text = string.format("%s [%.1f]", character.Name, character.Humanoid.Health),
        TextParent = character.PrimaryPart,
        Color = Options.PlayerEspColor.Value
    })

    Script.FeatureConnections.Player[character.Name] = character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.SetText(string.format("%s [%.1f]", character.Name, newHealth))
        else
            if Script.FeatureConnections.Player[character.Name] then Script.FeatureConnections.Player[character.Name]:Disconnect() end
            playerEsp.Destroy()
        end
    end)

    return playerEsp
end

function Script.Functions.EmployeeESP(employee: Model)
    if not (employee and employee.PrimaryPart and employee:FindFirstChild("Enemy")) then return end

    return Script.Functions.ESP({
        Type = "Employee",
        Object = employee,
        Text = employee.Name,
        TextParent = employee.PrimaryPart,
        Color = Options.EmployeeEspColor.Value
    })
end

function Script.Functions.ItemESP(item: Model)
    if not (item and item.PrimaryPart) then return end

    return Script.Functions.ESP({
        Type = "Item",
        Object = item,
        Text = item.Name,
        TextParent = item.PrimaryPart,
        Color = Options.ItemEspColor.Value
    })
end