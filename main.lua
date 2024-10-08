local branch = getgenv().mspaint_dev_mode and "dev" or "main"

local HttpService = game:GetService("HttpService")
local baseURL = "https://raw.githubusercontent.com/notpoiu/mspaint/" .. branch

export type gameMapping = {
    exclusions: table?,
    main: string
}

if not getgenv().ExecutorSupport then
    loadstring(game:HttpGet(baseURL .. "/executorTest.lua"))()
end

if not getgenv().BloxstrapRPC then
    local BloxstrapRPC = {}

    export type RichPresence = {
        details:     string?,
        state:       string?,
        timeStart:   number?,
        timeEnd:     number?,
        smallImage:  RichPresenceImage?,
        largeImage:  RichPresenceImage?
    }

    export type RichPresenceImage = {
        assetId:    number?,
        hoverText:  string?,
        clear:      boolean?,
        reset:      boolean?
    }

    function BloxstrapRPC.SendMessage(command: string, data: any)
        local json = HttpService:JSONEncode({
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

    getgenv().BloxstrapRPC = BloxstrapRPC
end

local mapping: gameMapping = HttpService:JSONDecode(game:HttpGet(baseURL .. "/mappings/" .. game.GameId .. ".json"))
local scriptPath = mapping.main

if mapping.exclusions and mapping.exclusions[tostring(game.PlaceId)] then
    scriptPath = mapping.exclusions[tostring(game.PlaceId)]
end

loadstring(game:HttpGet(baseURL .. scriptPath))()


-- Addons (this is BETA, expect stuff to change) --
if getgenv().mspaint_disable_addons then return end
task.spawn(function()
    local supportsFileSystem = (ExecutorSupport["isfile"] and ExecutorSupport["delfile"] and ExecutorSupport["listfiles"] and ExecutorSupport["writefile"] and ExecutorSupport["makefolder"] and ExecutorSupport["isfolder"])
    
    if not supportsFileSystem then
        warn("[mspaint] Your executor doesn't support the FileSystem API. Addons will not work.")
        return
    end

    if not isfolder("mspaint/addons") then
        print("[mspaint] Addons folder doesn't exist. Creating...")
        makefolder("mspaint/addons")
        return
    end
    
    repeat task.wait() until getgenv().mspaint_loaded == true
    print("[mspaint] Loading addons...")

    -- Functions
    local function getGameAddonPath(path: string)
        return string.match(path, "/places/(.-)%.lua")
    end

    local function AddAddonElement(LinoriaElement, AddonName, Element)
        if not LinoriaElement then
            warn("[mspaint] Element '" .. tostring(Element.Name) .. " (" .. tostring(Element.Type) .. ")' didn't load: Invalid Linoria element.")
            return
        end

        if typeof(Element) ~= "table" then
            warn("[mspaint] Element '" .. tostring(Element.Name) .. " (" .. tostring(Element.Type) .. ")' didn't load: Invalid data.")
            return
        end 

        if typeof(Element.Type) ~= "string" then 
            warn("[mspaint] Element '" .. tostring(Element.Name) .. " (" .. tostring(Element.Type) .. ")' didn't load: Invalid name.")
            return 
        end

        if typeof(AddonName) ~= "string" then 
            warn("[mspaint] Element '" .. tostring(Element.Name) .. " (" .. tostring(Element.Type) .. ")' didn't load: Invalid addon name.")
            return 
        end

        if Element.Type:sub(1, 3) == "Add" then Element.Type = Element.Type:sub(4) end

        -- Elements with no Arguments
        if Element.Type == "Divider" then
            return LinoriaElement:AddDivider()
        end

        if Element.Type == "DependencyBox" then
            return LinoriaElement:AddDependencyBox()
        end

        if typeof(Element.Name) ~= "string" then 
            warn("[mspaint] Element '" .. tostring(Element.Name) .. " (" .. tostring(Element.Type) .. ")' didn't load: Invalid name.")
            return 
        end

        -- Elements with Arguments
        if typeof(Element.Arguments) == "table" then
            if Element.Type == "Label" then
                return LinoriaElement:AddLabel(table.unpack(Element.Arguments))
            end

            if Element.Type == "Toggle" then
                return LinoriaElement:AddToggle(AddonName .. "_" .. Element.Name, Element.Arguments)
            end
            
            if Element.Type == "Button" then
                return LinoriaElement:AddButton(Element.Arguments)
            end
            
            if Element.Type == "Slider" then
                return LinoriaElement:AddSlider(AddonName .. "_" .. Element.Name, Element.Arguments)
            end
            
            if Element.Type == "Input" then
                return LinoriaElement:AddInput(AddonName .. "_" .. Element.Name, Element.Arguments)
            end
            
            if Element.Type == "Dropdown" then
                return LinoriaElement:AddInput(AddonName .. "_" .. Element.Name, Element.Arguments)
            end
            
            if Element.Type == "ColorPicker" then
                return LinoriaElement:AddColorPicker(AddonName .. "_" .. Element.Name, Element.Arguments)        
            end
            
            if Element.Type == "KeyPicker" then
                return LinoriaElement:AddKeyPicker(AddonName .. "_" .. Element.Name, Element.Arguments)
            end
        end

        warn("[mspaint] Element '" .. tostring(Element.Name) .. " (" .. tostring(Element.Type) .. ")' didn't load: Invalid element type.")
    end

    local gameAddonPath = getGameAddonPath(scriptPath)
    print("[mspaint] Game addon path: " .. gameAddonPath)
    
    local AddonTab, LastGroupbox = nil, "Right"

    local function createAddonTab(hasAddons: boolean)
        if not AddonTab then
            AddonTab = getgenv().Library.Window:AddTab("Addons [BETA]")
        end
        
        AddonTab:UpdateWarningBox({
            Visible = true,
            Title = "WARNING",
            Text =  (if not hasAddons then "Your addons FOLDER is empty!" else "This tab is for UN-OFFICIAL addons made for mspaint. We are not responsible for what addons you will use. You are putting yourself AT RISK since you are executing third-party scripts.")
        })
    end

    local containAddonsLoaded = false
    createAddonTab(false)
    
    for _, file in pairs(listfiles("mspaint/addons")) do
        print("[mspaint] Loading addon '" .. string.gsub(file, "mspaint/addons/", "") .. "'...")
        if file:sub(#file - 3) ~= ".lua" and file:sub(#file - 4) ~= ".luau" and file:sub(#file - 7) ~= ".lua.txt" then continue end

        local success, errorMessage = pcall(function()
            local fileContent = readfile(file)
            local addon = loadstring(fileContent)()

            if typeof(addon.Name) ~= "string" or typeof(addon.Elements) ~= "table" then
                warn("Addon '" .. string.gsub(file, "mspaint/addons/", "") .. "' didn't load: Invalid Name/Elements.")
                return 
            end

            if typeof(addon.Game) == "string" then
                if addon.Game ~= gameAddonPath and addon.Game ~= "*" then
                    warn("Addon '" .. string.gsub(file, "mspaint/addons/", "") .. "' didn't load: Wrong game.")
                    return
                end
            elseif typeof(addon.Game) == "table" then
                if not table.find(addon.Game, gameAddonPath) then
                    warn("Addon '" .. string.gsub(file, "mspaint/addons/", "") .. "' didn't load: Wrong game.")
                    return
                end
            else
                warn("Addon '" .. string.gsub(file, "mspaint/addons/", "") .. "' didn't load: Invalid GameId.")
                return
            end

            addon.Name = addon.Name:gsub("%s+", "")
            if typeof(addon.Title) ~= "string" then
                addon.Title = addon.Name;
            end

            if not AddonTab then createAddonTab(true) end
            
            local AddonGroupbox = LastGroupbox == "Right" and AddonTab:AddLeftGroupbox(addon.Title) or AddonTab:AddRightGroupbox(addon.Title);
            LastGroupbox = LastGroupbox == "Right" and "Left" or "Right";
            if typeof(addon.Description) == "string" then
                AddonGroupbox:AddLabel(addon.Description, true)
            end

            local function loadElements(linoriaMainElement, elements)
                for _, element in pairs(elements) do                      
                    local linoriaElement = AddAddonElement(linoriaMainElement, addon.Name, element)
                    if linoriaElement ~= nil and typeof(element.Elements) == "table" then
                        loadElements(linoriaElement, element.Elements)
                    end  
                end
            end

            loadElements(AddonGroupbox, addon.Elements)
        end)

        if not success then
            warn("[mspaint] Failed to load addon '" .. string.gsub(file, "mspaint/addons/", "") .. "':", errorMessage)
        else
            containAddonsLoaded = true
        end
    end
    
    createAddonTab(containAddonsLoaded) -- change the warning text
end)
