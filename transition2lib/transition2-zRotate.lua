--[[

Rotates a display object in the z dimension.
Requires the target display object to have a path with four nodes (x1, y1) to (x4, y4), like images and rects.

Example usage:

local transition = require("transition2")

transition.zRotate(displayObject, {
    degrees = 360,
    time = 2000,
    iterations = 0,    
    transition = easing.inOutSine,
    reverse = true,  
    perspective = 0.25, -- A value between 0-1. Defaults to 0.5.
    horizontal = true, -- Set to true for horizontal rotation (around the y axis). Default is vertical rotation (around the x axis)
    disableStrokeScaling = true, -- Set to true to disable scaling of strokes. Defaults is false, i.e. strokes are scaled.
    shading = true, -- Applies a shading effect as the object rotates away
    shadingDarknessIntensity = 0.75, -- A value between 0-1. Default = 1. Requires shading=true.
    shadingBrightnessIntensity = 0.25, -- A value between 0-1. Default = 0. Requires shading=true.
})

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")

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

    onValue = function(target, params, value, isReverseCycle)            
        
        if (not utils.hasRectPath(target)) then
            return
        end
        
        local radians = utils.toRadians(value)
        
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
        
        if (params.shading) then
            local brightnessIntensity = -params.shadingDarknessIntensity + ((math.abs((90 - (value % 180))) / 90) * (params.shadingBrightnessIntensity + params.shadingDarknessIntensity))            
            target.fill.effect.intensity = brightnessIntensity
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
        
        -- Setup a brightness filter for the target object if shading should be applied
        if (params.shading) then
            target.fill.effect = "filter.brightness" 
            target.fill.effect.intensity = 0
            if ((params.shadingBrightnessIntensity == nil) or (params.shadingBrightnessIntensity < 0) or (params.shadingBrightnessIntensity > 1)) then
                -- Default to 0 if invalid parameter. 0 = normal brightness.
                params.shadingBrightnessIntensity = 0
            end
            if ((params.shadingDarknessIntensity == nil) or (params.shadingDarknessIntensity < 0) or (params.shadingDarknessIntensity > 1)) then
                -- Default to 1 if invalid parameter. 1 = full darkness (black).
                params.shadingDarknessIntensity = 1
            end            
        end
        
        return params
    end,

    cancelWhen = function(target, params)
        -- This will cancel the transition if the display object no longer has x and y values
        return target.x == nil or target.y == nil
    end
}