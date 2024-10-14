--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.DistanceFromCharacter(position: Instance | Vector3, getPositionFromCamera: boolean | nil)
    if not position then return 9e9 end
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end

    if getPositionFromCamera and (shared.Camera or workspace.CurrentCamera) then
        local cameraPosition = if shared.Camera then shared.Camera.CFrame.Position else workspace.CurrentCamera.CFrame.Position

        return (cameraPosition - position).Magnitude
    end

    if shared.RootPart then
        return (shared.RootPart.Position - position).Magnitude
    elseif shared.Camera then
        return (shared.Camera.CFrame.Position - position).Magnitude
    end

    return 9e9
end

function Script.Functions.IsInViewOfPlayer(instance: Instance, range: number | nil, exclude: table | nil)
    if not instance then return false end
    if not Script.Collision then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local filter = exclude or {}
    table.insert(filter, shared.Character)

    raycastParams.FilterDescendantsInstances = filter

    local direction = (instance:GetPivot().Position - Script.Collision.Position).unit * (range or 9e9)
    local raycast = workspace:Raycast(Script.Collision.Position, direction, raycastParams)

    if raycast and raycast.Instance then
        if raycast.Instance:IsDescendantOf(instance) or raycast.Instance == instance then
            return true
        end

        return false
    end

    return false
end