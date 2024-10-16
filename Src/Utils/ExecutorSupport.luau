local ExecutorSupport = {}
local ExecutorSupportInfo = {}

local executorName = string.split(identifyexecutor() or "None", " ")[1]
local brokenFeatures = {
    ["Arceus"] = { "require" },
    ["Codex"] = { "require" },
    ["VegaX"] = { "require" },
}

function test(name: string, func: () -> (), shouldCallback: boolean)
    if typeof(brokenFeatures[executorName]) == "table" and table.find(brokenFeatures[executorName], name) then return false end -- garbage executor 🤯
    
    local success, errorMessage = false, nil
    if shouldCallback ~= false then
        success, errorMessage = pcall(func)
    else
        success = typeof(func) == "function"
    end
    
    ExecutorSupportInfo[name] = string.format("%s [%s]%s", (if success then "✅" else "❌"), name, (if errorMessage then (": " .. tostring(errorMessage)) else ""))
    ExecutorSupport[name] = success
    return success
end

test("readfile", readfile, false)
test("listfiles", listfiles, false)
test("writefile", writefile, false)
test("makefolder", makefolder, false)
test("appendfile", appendfile, false)
test("isfile", isfile, false)
test("isfolder", isfolder, false)
test("delfile", delfile, false)
test("delfolder", delfolder, false)
test("loadfile", loadfile, false)

test("queue_on_teleport", queue_on_teleport, false)
test("getcallingscript", getcallingscript, false)

test("require", function()
    --wax.require(shared.Players.LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChildWhichIsA("ModuleScript", true))
    wax.require(shared.Players.LocalPlayer:WaitForChild("PlayerScripts", math.huge):WaitForChild("PlayerModule", 5))
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
test("hookfunction", function()
    local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(test ~= ref, "Original function should not be same as the reference")
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
    local prompt = Instance.new("ProximityPrompt", Instance.new("Part", shared.Workspace))
    local triggered = false

    prompt.Triggered:Once(function() triggered = true end)

    fireproximityprompt(prompt)
    task.wait(0.1)

    prompt.Parent:Destroy()
    assert(triggered, "Failed to fire proximity prompt")
end)

--// Fixes \\--
if not canFirePrompt then
    local function fireProximityPrompt(prompt: ProximityPrompt, lookToPrompt, doNotDoInstant)
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
        prompt.RequiresLineOfSight = false
        if doNotDoInstant ~= true then
            prompt.HoldDuration = 0
        end

        if lookToPrompt == true then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, promptPosition)
            connection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, promptPosition)
            end)

            task.wait()
        end

        prompt:InputHoldEnd()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()

        if connection then connection:Disconnect() end

        prompt.Enabled = originalEnabled
        prompt.HoldDuration = originalHold
        prompt.RequiresLineOfSight = originalLineOfSight
        if lookToPrompt == true then workspace.CurrentCamera.CFrame = originalCamCFrame end
    end

    shared.fireproximityprompt = function(...)
        return fireProximityPrompt(...)
    end

    shared.forcefireproximityprompt = function(prompt)
        return fireProximityPrompt(prompt, true)
    end
else
    shared.fireproximityprompt = fireproximityprompt
    shared.forcefireproximityprompt = fireproximityprompt
end

if not isnetworkowner then
    function isnetowner(part: BasePart)
        if not part:IsA("BasePart") then
            return error("BasePart expected, got " .. typeof(part))
        end

        return part.ReceiveAge == 0
    end
    
    shared.isnetworkowner = isnetowner
else
    shared.isnetworkowner = isnetworkowner
end

shared.firetouch = firetouchinterest or firetouchtransmitter

--// Load \\--
ExecutorSupport["_ExecutorName"] = executorName
ExecutorSupport["_SupportsFileSystem"] = (ExecutorSupport["isfile"] and ExecutorSupport["delfile"] and ExecutorSupport["listfiles"] and ExecutorSupport["writefile"] and ExecutorSupport["makefolder"] and ExecutorSupport["isfolder"])

for name, result in pairs(ExecutorSupport) do
    if ExecutorSupportInfo[name] then 
        print(ExecutorSupportInfo[name]) 
    elseif name:gsub("_", "") ~= name then
        print("🛠️ [" .. tostring(name) .. "]", tostring(result))
    else
        print("❓ [" .. tostring(name) .. "]", tostring(result))
    end
end

return ExecutorSupport