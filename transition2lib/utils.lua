local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

local function isRectPath(obj)    
    return obj and (obj.x1 ~= nil) and (obj.y1 ~= nil) and (obj.x2 ~= nil) and (obj.y2 ~= nil) and (obj.x3 ~= nil) and (obj.y3 ~= nil) and (obj.x4 ~= nil) and (obj.y4 ~= nil)
end

local function hasRectPath(obj)
    return obj and obj.path and isRectPath(obj.path)
end

local function isUserData(target)
    return type(target) == "userdata"
end

--[[
Takes a numeric value and makes sure that it is inside of the given interval.
--]]
local function getValidIntervalValue(value, intervalStart, intervalEnd, defaultValue)
    if (value == nil) then
        return defaultValue
    elseif (value < intervalStart) then
        return intervalStart
    elseif(value > intervalEnd) then
        return intervalEnd
    else
        return value
    end
end

-- Performs a shallow copy of a table. 
-- @return A new table
local function copyTable(source)
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

local function isTransitionControlProp(propName) 
    local controlProps = {
        time = true,
        iterations = true,
        tag = true,
        transition = true,        
        delay = true,
        delta = true,
        onStart = true,
        onComplete = true,
        onPause = true,
        onResume = true,
        onCancel = true,
        onRepeat = true,
        
        iterationDelay = true,        
        onIterationStart = true,
        onIterationComplete = true,
        reverse = true,
        transitionReverse = true,
        cancelWhen = true,
        recalculateOnIteration = true,
    }
    
    return controlProps[propName] or false
end

return {
   toRadians = toRadians, 
   isRectPath = isRectPath,
   hasRectPath = hasRectPath,
   getValidIntervalValue = getValidIntervalValue,
   copyTable = copyTable,
   isUserData = isUserData,
   isTransitionControlProp = isTransitionControlProp,
}