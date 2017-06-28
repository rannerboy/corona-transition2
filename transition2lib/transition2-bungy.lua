--[[

Example usage:

local transition = require("transition2")

TODO:

transition.bungy(displayObject, {
    time = 5000,
    iterations = 0,
})

Markus Ranner 2017

--]]

local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

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
        params.transition = easing.outBack
        params.transitionReverse = easing.outBack
        params.reverse = true        
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        -- This will cancel the transition if the display object no longer has x and y values
        return displayObject.x == nil or displayObject.y == nil
    end
}