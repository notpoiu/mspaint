--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt: ProximityPrompt)
    if not workspace.CurrentRooms:FindFirstChild(Script.CurrentRoom) then return {targetWardrobePrompt.Parent} end
    local ignore = { targetWardrobePrompt.Parent }

    if workspace.CurrentRooms[Script.CurrentRoom]:FindFirstChild("Assets") then
        for _, asset in pairs(workspace.CurrentRooms[Script.CurrentRoom].Assets:GetChildren()) do
            if asset.Name == "Pillar" then table.insert(ignore, asset) end
        end
    end

    return ignore
end

function Script.Functions.AutoWardrobe(child, index: number | nil)
    -- Entity check
    if not child then return end
    if not child:IsDescendantOf(workspace) then return end

    -- Toggles check
    if not Toggles.AutoWardrobeNotif or not Toggles.AutoWardrobe then return end
    if not Toggles.AutoWardrobe.Value or not Script.Alive then
        index = index or table.find(Script.Temp.AutoWardrobeEntities, child)
        if index then
            table.remove(Script.Temp.AutoWardrobeEntities, index)
        end

        return
    end

    local NotifPrefix = "Auto " .. Script.HidingPlaceName[Script.Floor.Value];
    task.spawn(function() 
        shared.Notify:Log({
            Title = NotifPrefix,
            Description = "Looking for a hiding place",
    
            LinoriaMessage = "[" .. NotifPrefix .. "] Looking for a hiding spot..."
        }, Toggles.AutoWardrobeNotif.Value)
    end)

    local entityIndex = #Script.Temp.AutoWardrobeEntities + 1
    Script.Temp.AutoWardrobeEntities[entityIndex] = child

    -- Get wardrobe
    local distance = Script.EntityTable.AutoWardrobe.Distance[child.Name].Distance;
    local targetWardrobeChecker = function(prompt)
        if not prompt.Parent then return false end
        if not prompt.Parent:FindFirstChild("HiddenPlayer") then return false end
        if prompt.Parent:FindFirstChild("Main") and prompt.Parent.Main:FindFirstChild("HideEntityOnSpot") then
            if prompt.Parent.Main.HideEntityOnSpot.Whispers.Playing == true then return false end -- Hide
        end

        return prompt.Name == "HidePrompt" and (prompt.Parent:GetAttribute("LoadModule") == "Wardrobe" or prompt.Parent:GetAttribute("LoadModule") == "Bed" or prompt.Parent.Name == "Rooms_Locker") and not prompt.Parent.HiddenPlayer.Value and (Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance * Options.PromptReachMultiplier.Value)
    end
    local targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
    local getPrompt = function()
        if not targetWardrobePrompt or Script.Functions.DistanceFromCharacter(targetWardrobePrompt:FindFirstAncestorWhichIsA("Model"):GetPivot().Position) > 15 then
            repeat task.wait()
                targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
            until targetWardrobePrompt ~= nil or shared.Character:GetAttribute("Hiding") or (not Toggles.AutoWardrobe.Value or not Script.Alive or not child or not child:IsDescendantOf(workspace)) or shared.Library.Unloaded

            if (not Toggles.AutoWardrobe.Value or not Script.Alive or not child or not child:IsDescendantOf(workspace)) or shared.Library.Unloaded then
                return
            end
        end
    end
    getPrompt()

    -- Hide Checks
    if shared.Character:GetAttribute("Hiding") then return end
    if not Toggles.AutoWardrobe.Value or not Script.Alive or shared.Library.Unloaded then return end  

    -- Hide
    task.spawn(function() 
        shared.Notify:Log({
            Title = NotifPrefix,
            Description = "Starting...",
    
            LinoriaMessage = "[" .. NotifPrefix .. "] Starting..."
        }, Toggles.AutoWardrobeNotif.Value)
    end)
    
    local exclusion = Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt)
    local atempts, maxAtempts = 0, 60
    local isSafeCheck = function(addMoreDist)
        local isSafe = true
        for _, entity in pairs(Script.Temp.AutoWardrobeEntities) do
            if isSafe == false then break end

            local distanceEntity = Script.EntityTable.AutoWardrobe.Distance[child.Name].Distance;

            local entityDeleted = (entity == nil or entity.Parent == nil)
            local inView = Script.Functions.IsInViewOfPlayer(entity.PrimaryPart, distanceEntity + (addMoreDist == true and 15 or 0), exclusion)
            local isClose = Script.Functions.DistanceFromCharacter(entity:GetPivot().Position) < distanceEntity + (addMoreDist == true and 15 or 0)

            isSafe = entityDeleted == true and true or (inView == false and isClose == false);
            if isSafe == false then break end
        end

        return isSafe
    end
    local waitForSafeExit; waitForSafeExit = function()
        if child.Name == "A120" then
            repeat task.wait() until not child:IsDescendantOf(workspace) or (child.PrimaryPart and child.PrimaryPart.Position.Y < -10) or (not Script.Alive or not shared.Character:GetAttribute("Hiding"))
        else   
            local didPlayerSeeEntity = false
            task.spawn(function()
                repeat task.wait()
                    if not Script.Alive or not child or not child:IsDescendantOf(workspace) then break end

                    if shared.Character:GetAttribute("Hiding") and Script.Functions.IsInViewOfPlayer(child.PrimaryPart, distance, exclusion) then
                        didPlayerSeeEntity = true
                        break
                    end
                until false == true
            end)

            repeat task.wait(0.15)
                local isSafe = isSafeCheck()
                if didPlayerSeeEntity == true and isSafe == true then
                    task.spawn(function() 
                        shared.Notify:Log({
                            Title = NotifPrefix,
                            Description = "Exiting the locker, entity is far away.",
                            
                            LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is far away."
                        }, Toggles.AutoWardrobeNotif.Value)
                    end)

                    break
                else
                    if isSafe == true and not child:IsDescendantOf(workspace) then 
                        task.spawn(function() 
                            shared.Notify:Log({
                                Title = NotifPrefix,
                                Description = "Exiting the locker, entity is deleted.",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is deleted."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)

                        break 
                    end          
                end

                if not Script.Alive then  
                    if Toggles.AutoWardrobeNotif.Value then shared.Notify:Log("[" .. NotifPrefix .. "] Stopping (you died).") end             
                    task.spawn(function() 
                        shared.Notify:Log({
                            Title = NotifPrefix,
                            Description = "Stopping (you died)",
                            
                            LinoriaMessage = "[" .. NotifPrefix .. "] Stopping (you died)."
                        }, Toggles.AutoWardrobeNotif.Value)
                    end)

                    break 
                end                             
            until false == true          
        end

        return true
    end
    local hide = function()
        if (shared.Character:GetAttribute("Hiding") and shared.RootPart.Anchored) then return false end

        getPrompt()
        repeat task.wait()
            atempts += 1

            shared.forcefireproximityprompt(targetWardrobePrompt)
        until atempts > maxAtempts or not Script.Alive or (shared.Character:GetAttribute("Hiding") and shared.RootPart.Anchored)

        if atempts > maxAtempts or not Script.Alive then return false end
        return true
    end

    if child.Name == "AmbushMoving" then
        local LastPos = child:GetPivot().Position
        local IsMoving = false
        task.spawn(function()
            repeat task.wait(0.01)
                local diff = (LastPos - child:GetPivot().Position) / 0.01
                LastPos = child:GetPivot().Position
                IsMoving = diff.Magnitude > 0
            until not child or not child:IsDescendantOf(workspace)
        end)

        repeat task.wait()
            task.spawn(function() 
                shared.Notify:Log({
                    Title = NotifPrefix,
                    Description = "Waiting for Ambush to be close enough...",
    
                    LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for Ambush to be close enough...",
                }, Toggles.AutoWardrobeNotif.Value)
            end)

            repeat task.wait() until (IsMoving == true and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) <= distance) or (not child or not child:IsDescendantOf(workspace))
            if not child or not child:IsDescendantOf(workspace) then break end
            
            local success = hide()
            if success then
                task.spawn(function() 
                    shared.Notify:Log({
                        Title = NotifPrefix,
                        Description = "Waiting for it to be safe to exit...",
    
                        LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for it to be safe to exit...",
                    }, Toggles.AutoWardrobeNotif.Value)
                end)

                repeat task.wait() until (IsMoving == false and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) >= distance) or (not child or not child:IsDescendantOf(workspace));
                if not child or not child:IsDescendantOf(workspace) then break end

                Script.RemotesFolder.CamLock:FireServer()
            end
        until (not child or not child:IsDescendantOf(workspace)) or not Script.Alive
    else
        repeat task.wait() until isSafeCheck(true, true) == false

        repeat
            local success = hide()
            if success then
                local finished = waitForSafeExit()
                repeat task.wait() until finished == true        
                Script.RemotesFolder.CamLock:FireServer()
            end
            
            task.wait()
        until isSafeCheck()
    end

    table.remove(Script.Temp.AutoWardrobeEntities, entityIndex)
    task.spawn(function() 
        shared.Notify:Log({
            Title = NotifPrefix,
            Description = "Finished.",
    
            LinoriaMessage = "[" .. NotifPrefix .. "] Finished.",
        }, Toggles.AutoWardrobeNotif.Value)
    end)
end