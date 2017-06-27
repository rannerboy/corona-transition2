local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

local MAX_PERSPECTIVE_FACTOR = 0.4

return {
    getStartValue = function(target, params)     
        return 0
    end,

    getEndValue = function(target, params)        
        return params.degrees
    end,

    onValue = function(target, params, value)        
        local radians = toRadians(value)
        
        if (params.horizontalFlip) then
            local radius = target.width/2
            local xOffset = radius - (radius * math.cos(radians))
            --print(yOffset)
            target.path.x1 = xOffset
            target.path.x2 = xOffset
            target.path.x3 = -xOffset
            target.path.x4 = -xOffset
            
            -- Skew the y coordinates to create perspective            
            local depthOffset = radius * math.sin(radians)            
            local yOffset = (depthOffset / radius) * target.height/2  * params.perspective
            --print("xOffset = " .. xOffset)
            target.path.y1 = yOffset
            target.path.y2 = -yOffset
            target.path.y3 = yOffset
            target.path.y4 = -yOffset
        else        
            -- Vertical flip
            local radius = target.height/2
            local yOffset = radius - (radius * math.cos(radians))
            
            target.path.y1 = yOffset
            target.path.y4 = yOffset
            target.path.y2 = -yOffset
            target.path.y3 = -yOffset
            
            -- Skew the x coordinates to create perspective            
            local depthOffset = radius * math.sin(radians)
            --print("depth offset = " .. depthOffset)          
            
            local xOffset = (depthOffset / radius) * target.width/2 * params.perspective
            --print("xOffset = " .. xOffset)
            target.path.x1 = xOffset
            target.path.x2 = -xOffset
            target.path.x3 = xOffset
            target.path.x4 = -xOffset
        end
    end,
 
    getParams = function(target, params)  
        params.horizontalFlip = (params.direction == "horizontal")
        
        if ((params.perspective ~= nil) and (params.perspective >= 0) and (params.perspective <= 1)) then
            params.perspective = MAX_PERSPECTIVE_FACTOR * params.perspective
        else
            -- Default perspective
            params.perspective = MAX_PERSPECTIVE_FACTOR * 0.5
        end
        print (params.perspective)
        return params
    end,

    cancelWhen = function(target, params)
        return target.x == nil or target.y == nil
    end
}