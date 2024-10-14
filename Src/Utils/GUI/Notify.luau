local Notify = {}

local Linoria = require("Notifiers/Linoria")
local Doors = require("Notifiers/Doors")

function Notify:Notify(options)
    if shared.NotifyStyle == "Linoria" then
        local linoriaMessage = options["LinoriaMessage"] or options.Description
        options.Description = linoriaMessage

        Linoria:Notify(options)
    elseif shared.NotifyStyle == "Doors" and shared.ScriptName == "DOORS" then
        options["Warning"] = nil
        Doors:Notify(options)
    end
end

function Notify:Alert(options)
    if shared.NotifyStyle == "Linoria" then
        local linoriaMessage = options["LinoriaMessage"] or options.Description
        options.Description = linoriaMessage

        Linoria:Alert(options)
    elseif shared.NotifyStyle == "Doors" and shared.ScriptName == "DOORS" then
        if options.Warning then
            options["Warning"] = nil
            Doors:Alert(options)
        else
            Doors:Notify(options)
        end
    end
end

function Notify:Log(options) Notify:Notify(options) end

return Notify