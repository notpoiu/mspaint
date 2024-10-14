--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.EnableBreaker(breaker, value)
    breaker:SetAttribute("Enabled", value)

    if value then
        breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = -0.2
        breaker.Light.Material = Enum.Material.Neon
        breaker.Light.Attachment.Spark:Emit(1)
        breaker.Sound.Pitch = 1.3
    else
        breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = 0.2
        breaker.Light.Material = Enum.Material.Glass
        breaker.Sound.Pitch = 1.2
    end

    breaker.Sound:Play()
end

function Script.Functions.SolveBreakerBox(breakerBox)
    if not Options.AutoBreakerSolverMethod then return end
    if not breakerBox then return end

    local code = breakerBox:FindFirstChild("Code", true)
    local correct = breakerBox:FindFirstChild("Correct", true)

    repeat task.wait() until code.Text ~= "..." or not breakerBox:IsDescendantOf(workspace)
    if not breakerBox:IsDescendantOf(workspace) then return end

    shared.Notify:Alert({
        Title = "Auto Breaker Solver",
        Description = "Solving the breaker box...",
        Reason = ""
    })

    if Options.AutoBreakerSolverMethod.Value == "Legit" then
        Script.Temp.UsedBreakers = {}
        if shared.Connections["Reset"] then shared.Connections["Reset"]:Disconnect() end
        if shared.Connections["Code"] then shared.Connections["Code"]:Disconnect() end

        local breakers = {}
        for _, breaker in pairs(breakerBox:GetChildren()) do
            if breaker.Name == "BreakerSwitch" then
                local id = string.format("%02d", breaker:GetAttribute("ID"))
                breakers[id] = breaker
            end
        end

        if code:FindFirstChild("Frame") then
            Script.Functions.AutoBreaker(code, breakers)

            shared.Connections["Reset"] = correct:GetPropertyChangedSignal("Playing"):Connect(function()
                if correct.Playing then table.clear(Script.Temp.UsedBreakers) end
            end)

            shared.Connections["Code"] = code:GetPropertyChangedSignal("Text"):Connect(function()
                task.delay(0.1, Script.Functions.AutoBreaker, code, breakers)
            end)
        end
    else
        repeat task.wait(0.1)
            Script.RemotesFolder.EBF:FireServer()
        until not workspace.CurrentRooms["100"]:FindFirstChild("DoorToBreakDown")

        shared.Notify:Alert({
            Title = "Auto Breaker Solver",
            Description = "The breaker box has been successfully solved.",
        })
    end
end

function Script.Functions.AutoBreaker(code, breakers)
    local newCode = code.Text
    if not tonumber(newCode) and newCode ~= "??" then return end

    local isEnabled = code.Frame.BackgroundTransparency == 0
    local breaker = breakers[newCode]

    if newCode == "??" and #Script.Temp.UsedBreakers == 9 then
        for i = 1, 10 do
            local id = string.format("%02d", i)

            if not table.find(Script.Temp.UsedBreakers, id) then
                breaker = breakers[id]
            end
        end
    end

    if breaker then
        table.insert(Script.Temp.UsedBreakers, newCode)
        if breaker:GetAttribute("Enabled") ~= isEnabled then
            Script.Functions.EnableBreaker(breaker, isEnabled)
        end
    end
end