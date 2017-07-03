--[[

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")

local SIMPLE_PROPS = { "x", "y", "rotation", "alpha", "xScale", "yScale", "width", "height", "size" }
local RECT_PATH_PROPS = { "x1", "y1", "x2", "y2", "x3", "y3", "x4", "y4" }

local to = require("transition2lib.transition2-to")

local from = utils.copyTable(to)

-- This implementation is quite ugly but allows us to reuse the to() implementation without any changes
-- The from() function feels very weird overall. Does anyone ever even use it? :-)
from.getParams = function(target, params)
    
    -- Get target values from display object
    -- Switch values between params and target object to be able to use a to() transition instead
    --
    -- NOTE! Should probably do this in params.onStart() function instead, so that target object isn't modified until after delay. 
    -- But, since this is how the orginal transition.from() function handles it, we must do the same...
    if (utils.isRectPath(target)) then        
        for i = 1, #RECT_PATH_PROPS do
            local propName = RECT_PATH_PROPS[i]
            if (params[propName] ~= nil) then
                params[propName], target[propName] = target[propName], params[propName]                
            end
        end
    elseif (utils.isUserData(target))  then
        -- If user data (e.g. fill effect) we accept any numeric props, but exclude control props to not mess up transition
        for propName, propValue in pairs(params) do            
            if ((type(propValue) == "number") and (not utils.isTransitionControlProp(propName))) then
                target[propName], params[propName] = params[propName], target[propName]                
            end
        end    
    else
        -- Regular display object
        for i = 1, #SIMPLE_PROPS do
            local propName = SIMPLE_PROPS[i]
            if (params[propName] ~= nil) then
                target[propName], params[propName] = params[propName], target[propName]
            end
        end
    end
    
    return to.getParams(displayObject, params)
end    

return from