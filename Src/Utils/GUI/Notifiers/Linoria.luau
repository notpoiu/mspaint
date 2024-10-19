local Linoria = {}

function Linoria:Alert(options)
    if not shared.Library then return warn("No Linoria library") end
    Linoria:Notify(options)

    if shared.CheckToggle("NotifySound", true) then
        local sound = Instance.new("Sound", shared.SoundService) do
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = shared.NotifyVolume
            sound.PlayOnRemove = true
            sound:Destroy()
        end
    end
end

function Linoria:Notify(options)
    if not shared.Library then return warn("No Linoria library") end
    
    options = shared.Script.Functions.EnforceTypes(options, {
        Description = "No Message",
        Time = 5,
    })

    shared.Library:Notify(options.Description, options.Time)
end

return Linoria