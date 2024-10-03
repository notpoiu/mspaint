if not game.IsLoaded then game.Loaded:Wait() end

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local executorSupport = {}
local executorName = string.split(identifyexecutor() or "None", " ")[1]
local brokenFeatures = {
    ["Arceus"] = { "require" },
    ["Codex"] = { "require" },
    ["VegaX"] = { "require" },
}

function test(name: string, func: () -> (), shouldCallback: boolean)
    if typeof(brokenFeatures[executorName]) == "table" and table.find(brokenFeatures[executorName], name) then return false end -- garbage executor 🤯
    
    local success = false
    if shouldCallback ~= false then
        success = pcall(func)
    else
        success = typeof(func) == "function"
    end
    
    executorSupport[name] = success
    return success
end

test("queue_on_teleport", queue_on_teleport, false)
test("require", function()
    require(Players.LocalPlayer:WaitForChild("PlayerScripts", math.huge):WaitForChild("PlayerModule", 5)) -- ReplicatedStorage:WaitForChild("ModuleScript")
end)
test("hookmetamethod", function()
    local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
    local ref = hookmetamethod(object, "__index", function() return true end)
    assert(object.test == true, "Failed to hook a metamethod and change the return value")
    assert(ref() == false, "Did not return the original function")
end)
test("getnamecallmethod", function()
    pcall(function()
        game:NAMECALL_METHODS_ARE_IMPORTANT()
    end)

    assert(getnamecallmethod() == "NAMECALL_METHODS_ARE_IMPORTANT", "getnamecallmethod did not return the real namecall method")
end)
test("firesignal", function()
    local event = Instance.new("BindableEvent")
    local fired = false

    event.Event:Once(function(value) fired = value end)
        
    firesignal(event.Event, true)
    task.wait(0.1)
    event:Destroy()

    assert(fired, "Failed to fire a BindableEvent")
end)
local canFirePrompt = test("fireproximityprompt", function()
    local triggered = false
        
    local prompt = Instance.new("ProximityPrompt", Instance.new("Part", Workspace))
    prompt.Parent.Anchored = true
    prompt.Parent.Transparency = 1
    prompt.Triggered:Once(function() triggered = true end)

    fireproximityprompt(prompt)
    task.wait(0.1)

    if not triggered then
        -- garbage fireproximityprompt test
        prompt.Parent.CFrame = Players.LocalPlayer.Character:GetPivot() * CFrame.new(0, 0, -4)
        task.wait(0.1)
        fireproximityprompt(prompt)
        task.wait(0.1)
    end

    prompt.Parent:Destroy()
    assert(triggered, "Failed to fire proximity prompt")
end)

--// Fixes \\--
if not canFirePrompt then
    function customFirepp(prompt: ProximityPrompt, lookToPrompt: boolean)
        if not prompt:IsA("ProximityPrompt") then
            return error("ProximityPrompt expected, got " .. typeof(prompt))
        end

        local connection
        local promptPosition = prompt.Parent:GetPivot().Position
    
        local originalEnabled = prompt.Enabled
        local originalHold = prompt.HoldDuration
        local originalLineOfSight = prompt.RequiresLineOfSight
        local originalCamCFrame = workspace.CurrentCamera.CFrame
    
        prompt.Enabled = true
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        
        if lookToPrompt then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, promptPosition)
            connection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, promptPosition)
            end)

            task.wait()
        end

        prompt:InputHoldEnd()
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()

        if connection then connection:Disconnect() end

        prompt.Enabled = originalEnabled
        prompt.HoldDuration = originalHold
        prompt.RequiresLineOfSight = originalLineOfSight
        workspace.CurrentCamera.CFrame = originalCamCFrame
    end
    
    getgenv().fireproximityprompt = customFirepp;
    getgenv().custom_fireproximityprompt = customFirepp;
end

if not isnetworkowner then
    function isnetowner(part: BasePart)
        if not part:IsA("BasePart") then
            return error("BasePart expected, got " .. typeof(part))
        end

        return part.ReceiveAge == 0
    end
    
    getgenv().isnetworkowner = isnetowner;
    getgenv().custom_isnetworkowner = isnetowner;
end

--// Load \\--

executorSupport["_ExecutorName"] = executorName
for name, result in pairs(executorSupport) do
    print(name .. ":", result)
end

getgenv().ExecutorSupport = executorSupport
return executorSupport
