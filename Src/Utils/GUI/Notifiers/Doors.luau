local Doors = {}

--// Player Variables \\--
local mainUI

--// Functions \\--
function Doors:Notify(unsafeOptions)
    assert(typeof(unsafeOptions) == "table", "Expected a table as options argument but got " .. typeof(unsafeOptions))

    mainUI = mainUI or shared.PlayerGui:WaitForChild("MainUI", 2.5)
    if not mainUI then return end

    local options = shared.Script.Functions.EnforceTypes(unsafeOptions, {
        Title = "No Title",
        Description = "No Text",
        Reason = "",
        NotificationType = "NOTIFICATION",
        Image = "6023426923",
        Color = nil,
        Time = nil,

        TweenDuration = 0.8
    })

    local acheivement = mainUI.AchievementsHolder.Achievement:Clone()
    acheivement.Size = UDim2.new(0, 0, 0, 0)
    acheivement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
    acheivement.Name = "LiveAchievement"
    acheivement.Visible = true

    acheivement.Frame.TextLabel.Text = options.NotificationType

    if options.Color ~= nil then
        acheivement.Frame.TextLabel.TextColor3 = options.Color
        acheivement.Frame.UIStroke.Color = options.Color
        acheivement.Frame.Glow.ImageColor3 = options.Color
    end
    
    acheivement.Frame.Details.Desc.Text = tostring(options.Description)
    acheivement.Frame.Details.Title.Text = tostring(options.Title)
    acheivement.Frame.Details.Reason.Text = tostring(options.Reason or "")

    if options.Image:match("rbxthumb://") or options.Image:match("rbxassetid://") then
        acheivement.Frame.ImageLabel.Image = tostring(options.Image or "rbxassetid://0")
    else
        acheivement.Frame.ImageLabel.Image = "rbxassetid://" .. tostring(options.Image or "0")
    end

    acheivement.Parent = mainUI.AchievementsHolder
    acheivement.Sound.SoundId = "rbxassetid://10469938989"

    acheivement.Sound.Volume = 1

    if shared.Toggles.NotifySound.Value then
        acheivement.Sound:Play()
    end

    task.spawn(function()
        acheivement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", options.TweenDuration, true)
    
        task.wait(0.8)
    
        acheivement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
    
        shared.TweenService:Create(acheivement.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
            ImageTransparency = 1
        }):Play()
    
        if options.Time ~= nil then
            if typeof(options.Time) == "number" then
                task.wait(options.Time)
            elseif typeof(options.Time) == "Instance" then
                options.Time.Destroying:Wait()
            end
        else
            task.wait(5)
        end
    
        acheivement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
        task.wait(0.5)
        acheivement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
        task.wait(0.5)
        acheivement:Destroy()
    end)
end

function Doors:Alert(options)
    assert(typeof(options) == "table", "Expected a table as options argument but got " .. typeof(options))

    options["NotificationType"] = "WARNING"
    options["Color"] = Color3.new(1, 0, 0)
    options["TweenDuration"] = 0.3

    Doors:Notify(options)
end

function Doors:Warn(options) Doors:Alert(options) end

return Doors