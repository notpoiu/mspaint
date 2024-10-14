local BloxstrapRPC = {}

type RichPresence = {
    details:     string?,
    state:       string?,
    timeStart:   number?,
    timeEnd:     number?,
    smallImage:  RichPresenceImage?,
    largeImage:  RichPresenceImage?
}

type RichPresenceImage = {
    assetId:    number?,
    hoverText:  string?,
    clear:      boolean?,
    reset:      boolean?
}

function BloxstrapRPC.SendMessage(command: string, data: any)
    local json = shared.HttpService:JSONEncode({
        command = command, 
        data = data
    })
    
    print("[BloxstrapRPC] " .. json)
end

function BloxstrapRPC.SetRichPresence(data: RichPresence)
    if data.timeStart ~= nil then
        data.timeStart = math.round(data.timeStart)
    end
    
    if data.timeEnd ~= nil then
        data.timeEnd = math.round(data.timeEnd)
    end
    
    BloxstrapRPC.SendMessage("SetRichPresence", data)
end 

return BloxstrapRPC