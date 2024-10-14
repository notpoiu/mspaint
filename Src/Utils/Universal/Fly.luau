local Fly = {
    FlyBody = nil,
    FlyGyro = nil,
    Enabled = false, 
    Speed = 15
}

function Fly:Setup()
    local flyBody = Instance.new("BodyVelocity")
    flyBody.Velocity = Vector3.zero
    flyBody.MaxForce = Vector3.one * 9e9

    local flyGyro = Instance.new("BodyGyro")
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.one * 9e9

    Fly.FlyBody = flyBody
    Fly.FlyGyro = flyGyro

    shared.Connections["Fly"] = shared.RunService.RenderStepped:Connect(function()
        if not Fly.Enabled or (if shared.Library then shared.Library.Unloaded == true else true) then return end

        local velocity = Vector3.zero
        local moveVector = shared.ControlModule:GetMoveVector()
        velocity = -((shared.Camera.CFrame.LookVector * moveVector.Z) - (shared.Camera.CFrame.RightVector * moveVector.X))

        if shared.UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity += shared.Camera.CFrame.UpVector end
        if shared.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity -= shared.Camera.CFrame.UpVector end
        
        Fly.FlyBody.Velocity = velocity * Fly.Speed
        Fly.FlyGyro.CFrame = shared.Camera.CFrame
    end)
end

function Fly:Stop()
    if shared.Humanoid then shared.Humanoid.PlatformStand = false end

    shared.Connect:DisconnectSignal(shared.Connections["Fly"])
    if Fly.FlyBody then Fly.FlyBody:Destroy() end
    if Fly.FlyGyro then Fly.FlyGyro:Destroy() end
end

function Fly:Set(value: boolean)
    if not shared.RootPart then
        return warn("shared.RootPart is nil.")
    end

    Fly.Enabled = value
    if shared.Humanoid then shared.Humanoid.PlatformStand = value end
    Fly.FlyBody.Parent = if value then shared.RootPart else nil
    Fly.FlyGyro.Parent = if value then shared.RootPart else nil
end

function Fly:Enable() Fly:Set(true) end
function Fly:Disable() Fly:Set(false) end
function Fly:Toggle() Fly:Set(not Fly.Enabled) end

function Fly:SetSpeed(speed: number)
    Fly.Speed = speed
end

return Fly