--[[

Moves a display object using a "bungy strech" effect.
Requires the target display object to have a path with four nodes (x1, y1) to (x4, y4), like images and rects.

Example usage:

local transition = require("transition2")

transition.moveBungy(displayObject, {
    time = 750,
    offsetY = 200,
    offsetX = 0,    
    iterations = 0,    
    iterationDelay = 100,
    
    -- Note! reverse has no effect since it is already used internally to create the bungy effect
    reverse = true,
})

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")

return {
    getStartValue = function(displayObject, params)        
        return {
            x = 0,
            y = 0,
        }
    end,

    getEndValue = function(displayObject, params)
        return {
            x = (params.offsetX ~= nil) and params.offsetX or 0,
            y = (params.offsetY ~= nil) and params.offsetY or 0
        }
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        if (not utils.hasRectPath(displayObject)) then
            return
        end
        
        local offset = value        
        local path = displayObject.path
        
        if (params.offsetX) then            
             if (not isReverseCycle) then
                local offsetValue = offset.x
                
                if (params.offsetX > 0) then
                    path.x3 = offsetValue
                    path.x4 = offsetValue
                else 
                    path.x1 = offsetValue
                    path.x2 = offsetValue
                end
            else              
                local offsetValue = params.offsetX - offset.x
                
                if (params.offsetX > 0) then
                    path.x1 = offsetValue
                    path.x2 = offsetValue
                else
                    path.x3 = offsetValue
                    path.x4 = offsetValue
                end
            end
        end
        
        if (params.offsetY) then
            if (not isReverseCycle) then
                local offsetValue = offset.y
                
                if (params.offsetY > 0) then
                    path.y2 = offsetValue
                    path.y3 = offsetValue
                else 
                    path.y1 = offsetValue
                    path.y4 = offsetValue
                end
            else              
                local offsetValue = params.offsetY - offset.y
                
                if (params.offsetY > 0) then
                    path.y1 = offsetValue
                    path.y4 = offsetValue
                else
                    path.y2 = offsetValue
                    path.y3 = offsetValue
                end
            end
        end
    end,
 
    getParams = function(displayObject, params)        
        params.time = (params.time ~= nil) and (params.time/2) or 500
        params.transition = easing.outBack
        params.transitionReverse = easing.outBack
        params.reverse = true        
        
        -- After each iteration we move the entire display object and reset the offset for the path nodes.
        -- By doing this we have better control of where the entire display object is after the transision is complete.
        local customOnIterationComplete = params.onIterationComplete
        params.onIterationComplete = function(displayObject)
            displayObject.x = displayObject.x + (params.offsetX or 0)
            displayObject.y = displayObject.y + (params.offsetY or 0)
            
            for i = 1, 4 do
                displayObject.path["y" .. i] = 0
                displayObject.path["x" .. i] = 0
            end
            
            if(customOnIterationComplete) then
                customOnIterationComplete(displayObject)
            end
        end
        
        params.static = false
        
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        -- This will cancel the transition if the display object no longer has x and y values
        return displayObject.x == nil or displayObject.y == nil
    end
}