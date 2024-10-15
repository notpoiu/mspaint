--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

Script.AimbotRayParams = RaycastParams.new()
Script.AimbotRayParams.FilterType = Enum.RaycastFilterType.Exclude

--// Functions \\--
function Script.Functions.AimbotCondition(player: Player)
    if not (player ~= shared.LocalPlayer and player.Character and player.Character[Options.AimbotTargetPart.Value] and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end
    if Toggles.AimbotTeam.Value and shared.LocalPlayer.Team ~= nil and player.Team == shared.LocalPlayer.Team then return end

    return true
end

function Script.Functions.WallCheck(partPosition: Vector3)
    Script.AimbotRayParams.FilterDescendantsInstances = {shared.Character}
    return workspace:Raycast(shared.Camera.CFrame.Position, shared.Camera.CFrame.Position - partPosition, Script.AimbotRayParams) ~= nil
end

function Script.Functions.GetClosestFromMouse()
    local closestDistance = math.huge
    local closestCharacter = nil

    for _, player in pairs(shared.Players:GetPlayers()) do
        if not Script.Functions.AimbotCondition(player) then continue end

        local charPos, onScreen = shared.Camera:WorldToViewportPoint(player.Character[Options.AimbotTargetPart.Value].Position)
        if not onScreen then continue end

        if Toggles.AimbotWall.Value and Script.Functions.WallCheck(player.Character[Options.AimbotTargetPart.Value].Position) then continue end

        local playerDistance = (shared.UserInputService:GetMouseLocation() - Vector2.new(charPos.X, charPos.Y)).Magnitude

        if playerDistance < closestDistance then
            closestDistance = playerDistance
            closestCharacter = player.Character
        end
    end

    return closestCharacter
end

function Script.Functions.GetClosestFromCharacter()
    local closestDistance = math.huge
    local closestCharacter = nil

    for _, player in pairs(shared.Players:GetPlayers()) do
        if not Script.Functions.AimbotCondition(player) then continue end

        local _, onScreen = shared.Camera:WorldToViewportPoint(player.Character[Options.AimbotTargetPart.Value].Position)
        if not onScreen then continue end

        if Toggles.AimbotWall.Value and Script.Functions.WallCheck(player.Character[Options.AimbotTargetPart.Value].Position) then continue end

        local playerDistance = Script.Functions.DistanceFromCharacter(player.Character)

        if playerDistance < closestDistance then
            closestDistance = playerDistance
            closestCharacter = player.Character
        end
    end

    return closestCharacter
end