--[[
Moves a display object in a sinus wave pattern

Example usage:

local transition = require("transition2")

transition.moveSine(displayObject, {
    radiusX = 400,
    radiusY = 200,
    time = 5000,
    startDegreesX = 180,
    startDegreesY = 90,
    iterations = 0, -- Loop forever
})

Markus Ranner 2017

--]]

local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

return {
    getStartValue = function(displayObject, params)        
        return {
            x = params.startDegreesX,
            y = params.startDegreesY
        }
    end,

    getEndValue = function(displayObject, params)
        return {
            x = 360 + params.startDegreesX,
            y = 360 + params.startDegreesY
        }
    end,

    onValue = function(displayObject, params, value)
        local degrees = value        
        
        if (params.radiusX ~= 0) then
            local offsetX = (params.radiusX * math.sin(toRadians(degrees.x)))
            displayObject.x = params.startX + offsetX
        end
        
        if (params.radiusY ~= 0) then
            local offsetY = (params.radiusY * math.sin(toRadians(degrees.y)))
            displayObject.y = params.startY + offsetY
        end
    end,
 
    getParams = function(displayObject, params)        
        params.transition = easing.linear
        params.transitionReverse = easing.linear
        params.reverse = false
        params.time = params.time or 500 
        params.startY = displayObject.y
        params.startX = displayObject.x
        params.startDegreesX = params.startDegreesX and (params.startDegreesX % 360) or 0
        params.startDegreesY = params.startDegreesY and (params.startDegreesY % 360) or 0
        params.radiusX = params.radiusX or 0
        params.radiusY = params.radiusY or 0
 
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        -- This will cancel the transition if the display object no longer has x and y values
        return displayObject.x == nil or displayObject.y == nil
    end
}