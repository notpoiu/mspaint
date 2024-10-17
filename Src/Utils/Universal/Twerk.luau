local Twerk = {
    TwerkAnimation = nil,
    TwerkTrack = nil,
}

function Twerk:Setup()
    if not Twerk.TwerkAnimation then
        Twerk.TwerkAnimation = Instance.new("Animation")
        Twerk.TwerkAnimation.AnimationId = "rbxassetid://12874447851"
    end
    if not shared.Humanoid then return end

    Twerk.TwerkTrack = shared.Humanoid:LoadAnimation(Twerk.TwerkAnimation)
    Twerk.TwerkTrack.Looped = true
end

function Twerk:Set(value: boolean)
    if not shared.Humanoid then return end
    
    if not Twerk.TwerkAnimation then Twerk:Setup() end
    if not Twerk.TwerkTrack then return end

    if value then
        Twerk.TwerkTrack:Play()
    else
        Twerk.TwerkTrack:Stop()
    end
end

function Twerk:Enable() Twerk:Set(true) end
function Twerk:Disable() Twerk:Set(false) end

return Twerk