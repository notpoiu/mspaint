local Connect = {}
shared.Connections = {}

function Connect:GiveSignal(signal: RBXScriptConnection | RBXScriptSignal)
    table.insert(shared.Connections, signal)
end

function Connect:DisconnectSignal(signal: RBXScriptConnection | RBXScriptSignal)
    if not signal then return end

    if signal.Connected then
        signal:Disconnect()
    end
end

return Connect