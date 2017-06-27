local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

local function scaleStroke(target, params, depthOffsetRatio)
    if ((not params.disableStrokeScaling) and params.originalStrokeWidth) then
        target.strokeWidth = params.originalStrokeWidth * (1 - math.abs(depthOffsetRatio))                
    end
end

return {
    getStartValue = function(target, params)             
        return 0        
    end,

    getEndValue = function(target, params)        
        return params.degrees
    end,

    onValue = function(target, params, value)            
        local radians = toRadians(value)
        
        if (params.horizontal) then            
            local radius = target.width/2 - target.strokeWidth
            local xOffset = radius - (radius * math.cos(radians))
            target.path.x1 = xOffset
            target.path.x2 = xOffset
            target.path.x3 = -xOffset
            target.path.x4 = -xOffset
            
            -- Skew the y coordinates to create perspective            
            local depthOffset = radius * math.sin(radians)            
            local depthOffsetRatio = (depthOffset / radius)
            local yOffset =  depthOffsetRatio * target.height/2  * params.perspective
            if (target.height > target.width) then
                yOffset = yOffset * (target.width/target.height)
            end
            target.path.y1 = yOffset
            target.path.y2 = -yOffset
            target.path.y3 = yOffset
            target.path.y4 = -yOffset
            
            -- Change the stroke width with the perspective
            scaleStroke(target, params, depthOffsetRatio)            
        else        
            -- Vertical flip
            local radius = target.height/2 - target.strokeWidth
            local yOffset = radius - (radius * math.cos(radians))
            
            target.path.y1 = yOffset
            target.path.y4 = yOffset
            target.path.y2 = -yOffset
            target.path.y3 = -yOffset
            
            -- Skew the x coordinates to create perspective            
            local depthOffset = radius * math.sin(radians) 
            local depthOffsetRatio = (depthOffset / radius)
            local xOffset = (depthOffset / radius) * target.width/2 * params.perspective 
            if (target.width > target.height) then
                xOffset = xOffset * (target.height/target.width)
            end
            target.path.x1 = xOffset
            target.path.x2 = -xOffset
            target.path.x3 = xOffset
            target.path.x4 = -xOffset
            
            -- Change the stroke width with the perspective
            scaleStroke(target, params, depthOffsetRatio)
        end
    end,
 
    getParams = function(target, params)  
        local MAX_PERSPECTIVE_FACTOR = 0.4
        
        params.horizontal = (params.horizontal == true)
        
        if ((params.perspective ~= nil) and (params.perspective >= 0) and (params.perspective <= 1)) then
            params.perspective = MAX_PERSPECTIVE_FACTOR * params.perspective
        else
            -- Default perspective
            params.perspective = MAX_PERSPECTIVE_FACTOR * 0.5
        end
        
        -- Remember the original stroke width to be able to change it along with the perspective
        params.originalStrokeWidth = target.strokeWidth or 0
        params.disableStrokeScaling = (params.disableStrokeScaling == true)
        
        return params
    end,

    cancelWhen = function(target, params)
        return target.x == nil or target.y == nil
    end
}