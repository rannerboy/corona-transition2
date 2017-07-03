--[[
Moves a display object horizontally in a pattern similar to that of ocean waves

Example usage:

local transition = require("transition2")

transition2.oceanWaves(displayObject, {
    -- TODO
})

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")

return {
    getStartValue = function(displayObject, params)        
        return 0
    end,

    getEndValue = function(displayObject, params)
        return 180
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        local degrees = value        
        
        if (params.height > 0) then
            local offsetY = (params.height/2 * math.sin(utils.toRadians(degrees)))
            print("offsetY = " .. offsetY)
            displayObject.y = params.startY - offsetY
            
            local rotation = 0
            if (degrees <= 90) then
                rotation = (degrees <= 45) and (-degrees*2) or (-(90-degrees)*2)
            else
            end
            print("rotation = " .. rotation)
            displayObject.rotation = rotation
        end
        
        if (params.length > 0) then
            --local offsetY = (params.radiusY * math.sin(utils.toRadians(degrees.y)))
            --displayObject.y = params.startY + offsetY
        end
    end,
 
    getParams = function(displayObject, params)        
        params.transition = easing.inOutSine
        params.reverse = false
        params.time = params.time or 500 
        params.height = 400
        params.length = 200
        params.startY = displayObject.y
        params.iterations = 0
 
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        return displayObject.x == nil or displayObject.y == nil
    end
}