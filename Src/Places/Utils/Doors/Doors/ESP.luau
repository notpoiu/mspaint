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

    table.insert(Script.ESPTable[args.Type], ESPInstance)

    return ESPInstance
end

function Script.Functions.DoorESP(room)
    local door = room:WaitForChild("Door", 5)

    if door then
        local doorNumber = tonumber(room.Name) + 1
        if Script.IsMines then
            doorNumber += 100
        end

        local opened = door:GetAttribute("Opened")
        local locked = room:GetAttribute("RequiresKey")

        local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
        local doorIdx = Script.Functions.RandomString()

        local doorEsp = Script.Functions.ESP({
            Type = "Door",
            Object = door:WaitForChild("Door"),
            Text = string.format("Door %s %s", doorNumber, doorState),
            Color = Options.DoorEspColor.Value,

            OnDestroy = function()
                if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
            end
        })

        Script.FeatureConnections.Door[doorIdx] = door:GetAttributeChangedSignal("Opened"):Connect(function()
            if doorEsp then doorEsp.SetText(string.format("Door %s [Opened]", doorNumber)) end
            if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
        end)
    end
end 

function Script.Functions.ObjectiveESP(child)
    -- Backdoor
    if child.Name == "TimerLever" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = string.format("Timer Lever [+%s]", child.TakeTimer.TextLabel.Text),
            Color = Options.ObjectiveEspColor.Value
        })
    -- Backdoor + Hotel
    elseif child.Name == "KeyObtain" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Key",
            Color = Options.ObjectiveEspColor.Value
        })
    -- Hotel
    elseif child.Name == "ElectricalKeyObtain" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Electrical Key",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "LeverForGate" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Gate Lever",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "LiveHintBook" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Book",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "LiveBreakerPolePickup" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Breaker",
            Color = Options.ObjectiveEspColor.Value
        })
    -- Mines
    elseif child.Name == "MinesGenerator" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Generator",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "MinesGateButton" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Gate Power Button",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "FuseObtain" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Fuse",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "MinesAnchor" then
        local sign = child:WaitForChild("Sign", 5)

        if sign and sign:FindFirstChild("TextLabel") then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = string.format("Anchor %s", sign.TextLabel.Text),
                Color = Options.ObjectiveEspColor.Value
            })
        end
    elseif child.Name == "WaterPump" then
        local wheel = child:WaitForChild("Wheel", 5)
        local onFrame = child:FindFirstChild("OnFrame", true)

        if wheel and (onFrame and onFrame.Visible) then
            local pumpIdx = Script.Functions.RandomString()

            local pumpEsp = Script.Functions.ESP({
                Type = "Objective",
                Object = wheel,
                Text = "Water Pump",
                Color = Options.ObjectiveEspColor.Value,

                OnDestroy = function()
                    if Script.FeatureConnections.Pump[pumpIdx] then Script.FeatureConnections.Pump[pumpIdx]:Disconnect() end
                end
            })

            Script.FeatureConnections.Pump[pumpIdx] = onFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if pumpEsp then pumpEsp.Destroy() end
            end)
        end
    else 
        return false
    end

    return true
end

function Script.Functions.EntityESP(entity)
    Script.Functions.ESP({
        Type = "Entity",
        Object = entity,
        Text = Script.Functions.GetShortName(entity.Name),
        Color = Options.EntityEspColor.Value,
        IsEntity = entity.Name ~= "JeffTheKiller",
    })
end

function Script.Functions.SideEntityESP(entity)
    if entity.Name == "Snare" and not entity:FindFirstChild("Hitbox") then return end

    Script.Functions.ESP({
        Type = "SideEntity",
        Object = entity,
        Text = Script.Functions.GetShortName(entity.Name),
        TextParent = entity.PrimaryPart,
        Color = Options.EntityEspColor.Value,
    })
end

function Script.Functions.ItemESP(item, dropped)
    Script.Functions.ESP({
        Type = dropped and "DroppedItem" or "Item",
        Object = item,
        Text = Script.Functions.GetShortName(item.Name),
        Color = Options.ItemEspColor.Value
    })
end

function Script.Functions.ChestESP(chest)
    local text = chest.Name:gsub("Box", ""):gsub("_Vine", ""):gsub("_Small", ""):gsub("Locked", "")
    local locked = chest:GetAttribute("Locked")
    local state = if locked then "[Locked]" else ""

    Script.Functions.ESP({
        Type = "Chest",
        Object = chest,
        Text = string.format("%s %s", text, state),
        Color = Options.ChestEspColor.Value
    })
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
end

function Script.Functions.HidingSpotESP(spot)
    Script.Functions.ESP({
        Type = "HidingSpot",
        Object = spot,
        Text = if spot:GetAttribute("LoadModule") == "Bed" then "Bed" else Script.HidingPlaceName[Script.Floor.Value],
        Color = Options.HidingSpotEspColor.Value
    })
end

function Script.Functions.GoldESP(gold)
    Script.Functions.ESP({
        Type = "Gold",
        Object = gold,
        Text = string.format("Gold [%s]", gold:GetAttribute("GoldValue")),
        Color = Options.GoldEspColor.Value
    })
end

function Script.Functions.GuidingLightEsp(guidance)
    local part = guidance:Clone()
    part.Anchored = true
    part.Size = Vector3.new(3, 3, 3)
    part.Transparency = 0.5
    part.Name = "_Guidance"

    part:ClearAllChildren()
    part.Parent = shared.Workspace

    Script.Temp.Guidance[guidance] = part

    local guidanceEsp = Script.Functions.ESP({
        Type = "Guiding",
        Object = part,
        Text = "Guidance",
        Color = Options.GuidingLightEspColor.Value
    })

    guidance.AncestryChanged:Connect(function()
        if not guidance:IsDescendantOf(workspace) then
            if Script.Temp.Guidance[guidance] then Script.Temp.Guidance[guidance] = nil end
            if part then part:Destroy() end
            if guidanceEsp then guidanceEsp.Destroy() end
        end
    end)
end