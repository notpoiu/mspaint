--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.ChildCheck(child)
    if not child:IsA("Model") then return end

    if Toggles.BatteryESP.Value and child.Name == "battery" then
        Script.Functions.BatteryESP(child)
    elseif Toggles.LockerESP.Value and child.Name == "hidelocker" then
        Script.Functions.LockerESP(child)
    elseif Toggles.TableESP.Value and child.Name == "hidetable" then
        Script.Functions.TableESP(child)
    end
end