local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
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
        
        if (params.vertical) then
            local radius = target.height/2
            local yOffset = radius - (radius * math.cos(radians))
            --print(yOffset)
            target.path.y1 = yOffset
            target.path.y4 = yOffset
            target.path.y2 = -yOffset
            target.path.y3 = -yOffset
        end
    end,
 
    getParams = function(target, params)        
    end,

    cancelWhen = function(target, params)
        return target.x == nil or target.y == nil
    end
}