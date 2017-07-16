--[[
Moves a display object in a sinus wave pattern

Example usage:

local transition = require("transition2")

transition.moveSine(displayObject, {
    radiusX = 400,
    radiusY = 200,
    time = 5000,
    startDegreesX = 180, -- Default = 0
    deltaDegreesX = 180, -- Default = 360
    startDegreesY = 90, -- Default = 0    
    deltaDegreesY = -270, -- Default = 360
    iterations = 0, -- Loop forever
    
    --
    -- forceCentering    
    -- true (default): Display object will always start moving from its current position, regardless of startDegreesX/Y
    -- false: If set to false the sine path will always be centered around the display object. This will cause the display object to "jump" into start position if startDegreesX/Y are not multiples of 180.
    --
    forceCentering = true,
})

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")

return {
    getStartValue = function(displayObject, params)        
        return {
            x = params.startDegreesX,
            y = params.startDegreesY
        }
    end,

    getEndValue = function(displayObject, params)
        return {
            x = params.deltaDegreesX + params.startDegreesX,
            y = params.deltaDegreesY + params.startDegreesY
        }
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        local degrees = value        
        
        if (params.radiusX ~= 0) then
            local offsetX = (params.radiusX * math.sin(utils.toRadians(degrees.x)))            
            -- FIXME: Inefficient to calculate start offset for every value. 
            local startOffsetX = params.forceCentering and 0 or (params.radiusX * math.sin(utils.toRadians(params.startDegreesX)))
            displayObject.x = params.startX + offsetX
        end
        
        if (params.radiusY ~= 0) then
            local offsetY = (params.radiusY * math.sin(utils.toRadians(degrees.y)))
            -- FIXME: Inefficient to calculate start offset for every value. 
            local startOffsetY = params.forceCentering and 0 or (params.radiusY * math.sin(utils.toRadians(params.startDegreesY)))
            displayObject.y = params.startY + offsetY - startOffsetY
        end
    end,
 
    getParams = function(displayObject, params)        
        params.transition = easing.linear
        params.transitionReverse = easing.linear
        params.reverse = false
        params.time = params.time or 500  
        params.startX = displayObject.x
        params.startY = displayObject.y
        params.startDegreesX = params.startDegreesX and (params.startDegreesX % 360) or 0
        params.deltaDegreesX = params.deltaDegreesX or 360
        params.startDegreesY = params.startDegreesY and (params.startDegreesY % 360) or 0
        params.deltaDegreesY = params.deltaDegreesY or 360
        params.radiusX = params.radiusX or 0
        params.radiusY = params.radiusY or 0
        params.static = false
        
        -- If we want to recalculate new position for each iteration we must also change the calculated start X/Y values
        if (params.recalculateOnIteration) then
            local wrappedIterationComplete = params.onIterationComplete
            params.onIterationComplete = function(obj, params)            
                params.startX = obj.x
                params.startY = obj.y
                
                if (wrappedIterationComplete) then
                    wrappedIterationComplete(obj, params)
                end
            end            
        end
 
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        -- This will cancel the transition if the display object no longer has x and y values
        return displayObject.x == nil or displayObject.y == nil
    end
}