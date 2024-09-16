local compatibility_mode = false do
    local executor_name = identifyexecutor and identifyexecutor() or "your executor"

    -- Known executors that do not support the functions
    if executor_name == "Solara" then compatibility_mode = true end

    -- Function replacement
    if not fireproximityprompt or executor_name == "Solara" then
        function newinstance(itype, iparent, iproperties)
          if not itype or typeof(itype) ~= 'string' then return; end
          if typeof(iparent) ~= 'Instance' then iparent = nil; end
          local i = Instance.new(itype, iparent)
          if iproperties and typeof(iproperties) == 'table' then for property, value in pairs(iproperties) do
              pcall(function()
                  i[property] = value
              end)
          end; end
          return i
        end
        
        function posprompt(prompt, enabled)
          local camcf, part = workspace.CurrentCamera.CFrame, nil
          if prompt.Parent.Name == '_pxpart' then part = prompt.Parent; end
          if prompt.Parent:FindFirstChild('_pxpart') then part = prompt.Parent:FindFirstChild('_pxpart'); end
          if not part then
              part = newinstance('Part', prompt.Parent, {Name = '_pxpart', Transparency = 1, CanCollide = false, CanTouch = false, CanQuery = false, Size = Vector3.new(0.5, 0.5, 0.5), Shape = 'Ball', Anchored = true})
          end
          part.CFrame = camcf + (camcf.lookVector * 1.4)
          if enabled == true then prompt.Parent = part; end
          if enabled == false and prompt.Parent.Name == '_pxpart' then prompt.Parent = prompt.Parent.Parent; end
        end
        
        function _fireproxp(obj)
          local oldenabled, oldrlos = obj.Enabled, obj.RequiresLineOfSight
          obj.Enabled = true; obj.RequiresLineOfSight = false
          local PromptTime = obj.HoldDuration
          obj.HoldDuration = 0; posprompt(obj, true)
          wait()
          obj:InputHoldBegin()
          obj:InputHoldEnd()
          posprompt(obj, false); obj.HoldDuration = PromptTime; obj.Enabled = oldenabled; obj.RequiresLineOfSight = oldrlos
        end
        
        fireproximityprompt = _fireproxp
        getgenv().fireproximityprompt = _fireproxp
    end
    
    function test(name: string, func: () -> (), ...)
        if compatibility_mode then return end

        local success, error_msg = pcall(func, ...)
        
        if not success then
            compatibility_mode = true
            print("mspaint: " .. executor_name .. " does not support " .. name .. ", falling back to compatibility mode")
        end
        
        return success
    end
        
    test("require", function() require(game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("ModuleScript", true)) end)
    test("hookmetamethod", function()
        -- From UNC Env Check
        local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
        local ref = hookmetamethod(object, "__index", function() return true end)
        assert(object.test == true, "Failed to hook a metamethod and change the return value")
        assert(ref() == false, "Did not return the original function")
        
        local method, ref; ref = hookmetamethod(game, "__namecall", function(...)
            if not method then
                method = getnamecallmethod()
            end
            return ref(...)
        end)
        
        game:GetService("Lighting")
        assert(method == "GetService", "Did not get the correct method (GetService)")
    end)

    test("firesignal", function()
        local event = Instance.new("BindableEvent")
        
        local fired = false
        event.Event:Connect(function(value) fired = value end)

        if firesignal then
            firesignal(event.Event, true)
            task.wait()
        end
        
        if not fired then
            for _, connection in pairs(getconnections(event.Event)) do
                connection:Fire(true)
            end

            task.wait()
        end

        event:Destroy()
        assert(fired, "Failed to fire a BindableEvent")
    end)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/" .. (compatibility_mode and "solara" or "main") .. "/places/" .. game.GameId .. ".lua"))()
