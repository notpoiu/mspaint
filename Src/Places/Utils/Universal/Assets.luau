--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.ChildCheck(child)
    if not (child:IsA("BasePart") or child:IsA("Decal")) then
        return
    end

    if child:IsA("BasePart") then
        if Toggles.AntiLag.Value then
            if not child:GetAttribute("Material") then child:SetAttribute("Material", child.Material) end
            if not child:GetAttribute("Reflectance") then child:SetAttribute("Reflectance", child.Reflectance) end
    
            child.Material = Enum.Material.Plastic
            child.Reflectance = 0
        end
    elseif child:IsA("Decal") and Toggles.AntiLag.Value then
        if not child:GetAttribute("Transparency") then child:SetAttribute("Transparency", child.Transparency) end
        child.Transparency = 1
    end
end

