--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/MS-ESP/refs/heads/main/source.lua"))()
shared.ESPLibrary = ESPLibrary

type ESP = {
    Color: Color3,
    IsInvisible: boolean,
    Object: Instance,
    Offset: Vector3,
    MaxDistance: number,
    Text: string,
    TextParent: Instance,
    Type: string,
    OnDestroy: () -> (),
}

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        Color = args.Color or Color3.new(),
        MaxDistance = args.MaxDistance or 5000,
        Offset = args.Offset or Vector3.zero,
        IsInvisible = args.IsInvisible or false,
        Type = args.Type or "None",
        OnDestroy = args.OnDestroy or nil,

        Humanoid = nil
    }

    if ESPManager.IsInvisible and ESPManager.Object.PrimaryPart then
        if ESPManager.Object.PrimaryPart.Transparency == 1 then
            ESPManager.Object.PrimaryPart.Transparency = 0.99
        end

        local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
        if not humanoid then humanoid = Instance.new("Humanoid", ESPManager.Object) end
        ESPManager.Humanoid = humanoid
    end

    local ESPInstance = ESPLibrary.ESP.Highlight({
        Name = ESPManager.Text,
        Model = ESPManager.Object,
        MaxDistance = ESPManager.MaxDistance,
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
            if ESPManager.Object.PrimaryPart and ESPManager.IsInvisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
            if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
        end
    })

    table.insert(Script.ESPTable[args.Type], ESPInstance)

    return ESPInstance
end

function Script.Functions.DoorESP(room)
    local door = room:WaitForChild("door", 5)

    if door then
        local clickDetector = door:FindFirstChild("ClickDetector")
        if not clickDetector then return end

        local roomNumber = if tonumber(room.Name) then room.Name else tostring(workspace.roomnumber.Value + 1)

        local doorEsp = Script.Functions.ESP({
            Type = "Door",
            Object = door,
            Text = string.format("Door %s", roomNumber),
            Color = Options.DoorEspColor.Value,

            OnDestroy = function()
                if Script.FeatureConnections.Door[door] then Script.FeatureConnections.Door[door]:Disconnect() end
            end
        })

        Script.FeatureConnections.Door[door] = clickDetector.AncestryChanged:Connect(function(_, parent)
            if parent then return end
            
            if doorEsp then doorEsp.Destroy() end
            if Script.FeatureConnections.Door[door] then Script.FeatureConnections.Door[door]:Disconnect() end
        end)
    end
end

function Script.Functions.EntityESP(entity, entityName)
    local isInvisible = entity:IsA("BasePart") and entity.Transparency == 1
    local entityModel = if isInvisible then Instance.new("Model") else entity

    if isInvisible then
        local entityClone = entity:Clone()
        
        entityClone.Parent = entityModel
        entityModel.Parent = shared.Workspace
    
        entityModel.PrimaryPart = entityClone
        entityClone:ClearAllChildren()
        Instance.new("SpecialMesh", entityClone)

        shared.Connections[entity] = shared.RunService.Heartbeat:Connect(function()
            if entity:IsDescendantOf(workspace) then
                entityModel:PivotTo(entity:GetPivot())
            else
                entityModel:Destroy()
                shared.Connect:DisconnectSignal(shared.Connections[entity])
            end
        end)
    end

    Script.Functions.ESP({
        Type = "Entity",
        Object = entityModel,
        Text = entityName,
        Color = Options.EntityEspColor.Value,
        IsInvisible = isInvisible,
    })
end

function Script.Functions.BatteryESP(battery)
    Script.Functions.ESP({
        Type = "Battery",
        Object = battery,
        Text = "Battery",
        Color = Options.BatteryEspColor.Value,
        MaxDistance = 300
    })
end

function Script.Functions.LockerESP(hideLocker)
    local jack = hideLocker:FindFirstChild("jack")
    local extra = if jack then " [Shell]" else ""

    local lockerEsp = Script.Functions.ESP({
        Type = "Locker",
        Object = hideLocker,
        Text = string.format("Locker%s", extra),
        Color = Options.LockerEspColor.Value,
        MaxDistance = 200,

        OnDestroy = function()
            if Script.FeatureConnections.Shell[jack] then Script.FeatureConnections.Shell[jack]:Disconnect() end
        end
    })

    if jack then
        Script.FeatureConnections.Shell[jack] = jack.AncestryChanged:Connect(function(_, parent)
            if parent then return end

            if lockerEsp then lockerEsp.Destroy() end
            if Script.FeatureConnections.Shell[jack] then Script.FeatureConnections.Shell[jack]:Disconnect() end
        end)
    end
end

function Script.Functions.TableESP(hideTable)
    Script.Functions.ESP({
        Type = "Table",
        Object = hideTable:FindFirstChild("spot"),
        Text = "Table",
        Color = Options.TableEspColor.Value,
        IsInvisible = true,
        MaxDistance = 250
    })
end