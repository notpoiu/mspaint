--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.Chat(message: string)
    local chatEvents = shared.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    local sayMessage = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")

    if sayMessage then
        sayMessage:FireServer(message, "All")
    end
end