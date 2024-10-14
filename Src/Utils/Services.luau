local cloneref = (cloneref or function(instance: any) return instance end)

local Services = {}
function Services:GetService(serviceName: string)
    if shared[serviceName] then return shared[serviceName] end

    local service = cloneref(game:GetService(serviceName))
    shared[serviceName] = service

    return service
end

function Services:GetServices(serviceNames: table)
    for _, serviceName: string in ipairs(serviceNames) do
        Services:GetService(serviceName)
    end
end

return Services