--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script

--// Functions \\--
function Script.Functions.CalculateHideTime(room: number)
    for _, range in ipairs(Script.HideTimeValues) do
        if room >= range.min and room <= range.max then
            return math.round(range.a * (room - range.b) + range.c)
        end
    end    

    return nil
end

function Script.Functions.GetShortName(entityName: string)
    if Script.EntityTable.ShortNames[entityName] then
        return Script.EntityTable.ShortNames[entityName]
    end

    for suffix, fix in pairs(Script.SuffixPrefixes) do
        entityName = entityName:gsub(suffix, fix)
    end

    return entityName
end

function Script.Functions.DisableDupe(dupeRoom, value, isSpaceRoom)
    if isSpaceRoom then
        local collision = dupeRoom:WaitForChild("Collision", 5)
        
        if collision then
            collision.CanCollide = value
            collision.CanTouch = not value
        end
    else
        local doorFake = dupeRoom:WaitForChild("DoorFake", 5)
        
        if doorFake then
            doorFake:WaitForChild("Hidden", 5).CanTouch = not value
    
            local lock = doorFake:WaitForChild("Lock", 5)
            if lock and lock:FindFirstChild("UnlockPrompt") then
                lock.UnlockPrompt.Enabled = not value
            end
        end
    end
end

function Script.Functions.DeleteSeek(collision: BasePart)
    if not shared.RootPart then return end

    task.spawn(function()
        local attemps = 0
        repeat task.wait() attemps += 1 until collision.Parent or attemps > 200
        
        if collision:IsDescendantOf(workspace) and (collision.Parent and collision.Parent.Name == "TriggerEventCollision") then
            shared.Notify:Alert({
                Title = "Delete Seek FE",
                Description = "Deleting Seek trigger...",
                Reason = "",
            })

            task.delay(4, function()
                if collision:IsDescendantOf(workspace) then
                    shared.Notify:Alert({
                        Title = "Delete Seek FE",
                        Description = "Failed to delete Seek trigger!",
                        Reason = "",
                    })
                end
            end)
            
            if shared.firetouch then
                shared.RootPart.Anchored = true
                task.delay(0.25, function() shared.RootPart.Anchored = false end)

                repeat
                    if collision:IsDescendantOf(workspace) then shared.firetouch(collision, shared.RootPart, 1) end
                    task.wait()
                    if collision:IsDescendantOf(workspace) then shared.firetouch(collision, shared.RootPart, 0) end
                    task.wait()
                until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
            else
                collision:PivotTo(CFrame.new(shared.RootPart.Position))
                shared.RootPart.Anchored = true
                repeat task.wait() until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                shared.RootPart.Anchored = false
            end
            
            if not collision:IsDescendantOf(workspace) then
                shared.Notify:Log({
                    Title = "Delete Seek FE",
                    Description = "Deleted Seek trigger successfully!",
                })
            end
        end
    end)
end

function Script.Functions.AvoidEntity(value: boolean, oldNoclip: boolean)
    if not shared.RootPart or not Script.Collision then return end

    local lastCFrame = shared.RootPart.CFrame
    task.wait()
    if value then
        Toggles.Noclip:SetValue(true)
        Script.Collision.Position += Vector3.new(0, 24, 0)
        task.wait()
        Script.Collision:PivotTo(lastCFrame)
    else
        Script.Collision.Position -= Vector3.new(0, 24, 0)
        task.wait()
        Script.Collision:PivotTo(lastCFrame)
        Toggles.Noclip:SetValue(oldNoclip or false)
    end
end