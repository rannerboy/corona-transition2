local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

local function isRectPath(obj)    
    return obj and (obj.x1 ~= nil) and (obj.y1 ~= nil) and (obj.x2 ~= nil) and (obj.y2 ~= nil) and (obj.x3 ~= nil) and (obj.y3 ~= nil) and (obj.x4 ~= nil) and (obj.y4 ~= nil)
end

local function hasRectPath(obj)
    return obj and obj.path and isRectPath(obj.path)
end

local function isFillEffect(target)
    return type(target) == "userdata"
end

-- Performs a shallow copy of a table. 
-- @return A new table
function copyTable(source)
    local dest
    if (type(source) == "table") then
        dest = {}
        for k, v in pairs(source) do
            dest[k] = v
        end
    else -- Non-table types are just returned
        dest = source
    end
    return dest
end

return {
   toRadians = toRadians, 
   isRectPath = isRectPath,
   hasRectPath = hasRectPath,
   copyTable = copyTable,
   isFillEffect = isFillEffect,
}