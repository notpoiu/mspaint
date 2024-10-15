local ControlModule = if wax.shared.ExecutorSupport["require"] and shared.PlayerScripts:FindFirstChild("PlayerModule") then wax.require(shared.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")) else { replaced = true }

if ControlModule.replaced == true then
    ControlModule = {
        replaced = true,

        GamepadMoveVector = Vector3.zero,
        ThumbstickMoveVector = Vector3.zero,
        ThumbstickRadius = 15,
        TouchInput = nil,
        TouchStartPosition = nil,
    }

    function ControlModule:GetMoveVector(): Vector3
        local x, z = 0, 0

        if shared.UserInputService:IsKeyDown(Enum.KeyCode.W) then z -= 1 end
        if shared.UserInputService:IsKeyDown(Enum.KeyCode.S) then z += 1 end
        if shared.UserInputService:IsKeyDown(Enum.KeyCode.A) then x -= 1 end
        if shared.UserInputService:IsKeyDown(Enum.KeyCode.D) then x += 1 end

        return Vector3.new(x, 0, z) + ControlModule.ThumbstickMoveVector + ControlModule.GamepadMoveVector
    end

    shared.Connect:GiveSignal(shared.UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if gameProcessed then return end
    
        if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1  then
            ControlModule.GamepadMoveVector = Vector3.new(input.Position.X, 0, -input.Position.Y)
        end
    end))
    
    shared.Connect:GiveSignal(shared.UserInputService.TouchStarted:Connect(function(input)
        ControlModule.TouchInput = input
        ControlModule.TouchStartPosition = input.Position
    end))
    
    shared.Connect:GiveSignal(shared.UserInputService.TouchMoved:Connect(function(input)
        if input ~= ControlModule.TouchInput then return end
        
        if ControlModule.TouchStartPosition and input.Position then
            local moveDirection = (input.Position - ControlModule.TouchStartPosition).Unit
            local distance = (input.Position - ControlModule.TouchStartPosition).Magnitude
    
            if distance > ControlModule.ThumbstickRadius then
                distance = ControlModule.ThumbstickRadius
            end
    
            local adjustedDistance = distance / ControlModule.ThumbstickRadius
            ControlModule.ThumbstickMoveVector = Vector3.new(moveDirection.X * adjustedDistance, 0, moveDirection.Y * adjustedDistance)
        end
    end))
    
    shared.Connect:GiveSignal(shared.UserInputService.TouchEnded:Connect(function(input)
        if input ~= ControlModule.TouchInput then return end
        
        ControlModule.ThumbstickMoveVector = Vector3.new(0, 0, 0)
        ControlModule.TouchInput = nil
    end))
end

return ControlModule