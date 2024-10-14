local FileHelper = {}

function FileHelper.new(basepath: string)
    local self = setmetatable({}, {
        __index = function(self, key)
            local accessed = rawget(self, key)

            if typeof(accessed) == "function" then
                return function(...)
                    if not shared.ExecutorSupport["_SupportsFileSystem"] then return end
                    
                    return accessed(self, ...)
                end
            end

            return accessed
        end
    })

    self.BasePath = basepath

    self.BuildPresetStructure = function()
        if not isfolder(self.BasePath) then
            makefolder(self.BasePath)
        end
    end

    self.CreateFile = function(name: string, data: string)
        self.BuildPresetStructure()
        writefile(self.BasePath .. "/" .. name, data)
    end

    self.AppendFile = function(name: string, data: string)
        self.BuildPresetStructure()
        appendfile(self.BasePath .. "/" .. name, data)
    end

    self.GetFiles = function()
        return listfiles(self.BasePath)
    end

    self.ReadFile = function(name: string)
        return readfile(self.BasePath .. "/" .. name)
    end

    self.IsFile = function(name: string)
        return isfile(self.BasePath .. "/" .. name)
    end

    self.DeleteFile = function(name: string)
        delfile(self.BasePath .. "/" .. name)
    end

    self.GetFilesClean = function()
        local files = {}
        for _, file in pairs(listfiles(self.BasePath)) do
            local name = FileHelper.GetFileNameFromPath(file)
            if name then
                table.insert(files, name)
            end
        end

        return files
    end

    self.GetFileNameFromPath = function(path: string, extention: string | nil)
        return FileHelper.GetFileNameFromPath(path, extention)
    end

    return self
end

function FileHelper.GetFileNameFromPath(path: string, extention: string | nil)
    local fileExtension = extention or ".json"

    if path:sub(-#fileExtension) == fileExtension then
        path = path:gsub("\\", "/")

        local pos = path:find("/[^/]*$")
        if pos then
            return path:sub(pos + 1, -#fileExtension - 1)
        end
    end
    
    return nil
end

return FileHelper