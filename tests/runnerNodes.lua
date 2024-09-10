getgenv().SetClipboard = function(node, tablename, spaces)
    if type(node) == "table" then
        local cache, stack, output = {},{},{}
        local depth = 1
        local space
        if spaces == true or nil then
            space = "\n"
        elseif spaces == nil then
            space = "\n"
        else
            space = ""
        end
        local output_str = "{"..space
        while true do
            local size = 0
            for k,v in pairs(node) do
                size = size + 1
            end
            local cur_index = 1
            for k,v in pairs(node) do
                if (cache[node] == nil) or (cur_index >= cache[node]) then
                    if (string.find(output_str,"}",output_str:len())) then
                        output_str = output_str .. ","..space
                    elseif not (string.find(output_str,space,output_str:len())) then
                        output_str = output_str .. space
                    end
                    table.insert(output,output_str)
                    output_str = ""
                    local key
                    if (type(k) == "number" or type(k) == "boolean") then
                        key = "["..tostring(k).."]"
                    else
                        key = "[\""..tostring(k).."\"]"
                    end

                    if (type(v) == "number" or type(v) == "boolean") then
                        output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                    elseif (type(v) == "table") then
                        output_str = output_str .. string.rep('\t',depth) .. key .. " = {"..space
                        table.insert(stack,node)
                        table.insert(stack,v)
                        cache[node] = cur_index+1
                        break
                    else
                        output_str = output_str .. string.rep('\t',depth) .. key .. " = \""..tostring(v).."\""
                    end

                    if (cur_index == size) then
                        output_str = output_str .. space .. string.rep('\t',depth-1) .. "}"
                    else
                        output_str = output_str .. ","
                    end
                else
                    if (cur_index == size) then
                        output_str = output_str .. space .. string.rep('\t',depth-1) .. "}"
                    end
                end

                cur_index = cur_index + 1
            end
            if (size == 0) then
                output_str = output_str .. space .. string.rep('\t',depth-1) .. "}"
            end
            if (#stack > 0) then
                node = stack[#stack]
                stack[#stack] = nil
                depth = cache[node] == nil and depth + 1 or depth - 1
            else
                break
            end
        end
        table.insert(output,output_str)
        output_str = table.concat(output)
        if spaces == false then
            output_str = output_str:gsub("    ", "")
            task.wait()
            output_str = output_str:gsub(" ", "")
        end
        if tablename == nil then
            setclipboard("local tabel = " .. output_str)
        else
            setclipboard("local "..tostring(tablename).." = " .. output_str)
        end
    else
        setclipboard(node)
    end
end

task.wait()

game:GetService("ReplicatedStorage").RemotesFolder.SendRunnerNodes.OnClientEvent:Connect(function(buffers, folder, id)
    local module = require(game:GetService("ReplicatedStorage").NodeObject.MinecartNodes)
    
    local decoded = module.Decode(buffers, folder, id)
    if decoded then
        print("got:", decoded)
        SetClipboard(decoded)
    end
end)