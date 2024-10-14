local Logs = {
    Debug = true, --or getgenv().mspaint_dev_mode,

    FirstTime = true,
    Folder = "mspaint/logs",
    FileName = nil
}
Logs.FileHelper = wax.shared.FileHelper.new(Logs.Folder)

--// Functions \\--
function TableToMessage(tbl: table)
    for idx, val in ipairs(tbl) do
        tbl[idx] = tostring(val)
    end
    
    return table.concat(tbl, " ")
end

function GenerateLogFileName()
    local date = os.date("*t")
    return string.format(
        "log_%04d-%02d-%02d_%02d-%02d-%02d.log",
        date.year, date.month, date.day,
        date.hour, date.min, date.sec
    )
end

function Log(prefix: string, func, ...)
    local message = string.format("[%s] ", prefix) .. TableToMessage({ ... })
    local printer = func or print
    printer(message)

    task.spawn(function()
        if wax.shared.ExecutorSupport["_SupportsFileSystem"] then
            if not Logs.FileName then 
                Logs.FileName = GenerateLogFileName() 
            end
        
            Logs.FileHelper.AppendFile(Logs.FileName, message)
        end
    end)
end

function Logs:Log(...) Log("INFO", print, ...) end
function Logs:Warn(...) Log("WARN", warn, ...) end
function Logs:Error(...) Log("ERROR", error, ...) end
function Logs:Debug(...) 
    if not Logs.Debug then return end
    Log("DEBUG", print, ...) 
end

return Logs