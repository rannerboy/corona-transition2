--[[
Falling leaf

TODO: Add comments and example 

transition.fallingLeaf(displayObject, {
    speed = 0.25, -- A value between 0-1. Default = 0.5.
    verticalIntensity = 0.75, -- A value between 0-1. Default = 0.5.
    horizontalIntensity = 0.75, -- A value between 0-1. Default = 0.5.    
    
    horizontalDirection, = One of {"alternate", "right", "left", "random" }. Default = "alternate".
    rotate = false, -- Default = true. Applies rotation to the object.
    zRotate = false, -- Default = true. Applies zRotate transition with shading.
    rotationIntensity = 0.75, -- A value between 0-1. Default = 0.5.
})

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")

local DEFAULT_SPEED = 0.5
local DEFAULT_VERTICAL_INTENSITY = 0.5
local DEFAULT_HORIZONTAL_INTENSITY = 0.5
local DEFAULT_ROTATION_INTENSITY = 0.5
local DEFAULT_HORIZONTAL_DIRECTION_OPTION = "alternate"

local function getBaseDeltaY(verticalIntensity)
    local MIN_DELTA_Y = 25
    local MAX_DELTA_Y = 600
    
    local baseDeltaY = ((MAX_DELTA_Y - MIN_DELTA_Y) * (1 - verticalIntensity)) + MIN_DELTA_Y
        
    return baseDeltaY
end

local function getBaseDeltaX(horizontalIntensity)
    local MIN_DELTA_X = 25
    local MAX_DELTA_X = 300
    
    local baseDeltaX = ((MAX_DELTA_X - MIN_DELTA_X) * horizontalIntensity) + MIN_DELTA_X
    
    return baseDeltaX
end

local function getTime(speed)
    local MIN_TIME = 500
    local MAX_TIME = 4000
    
    -- Time will increase as speed increases
    local time = ((MAX_TIME - MIN_TIME) * (1 - speed)) + MIN_TIME    
    
    return time
end

local function randomizeRotationDelta(rotationIntensity)
    local rotationDirection = (math.random(1,2) == 1 and 1 or -1)
    local minAngle = 90 + (rotationIntensity * 360)
    local randomAngle = minAngle + (math.random(0, 360) * rotationIntensity)
    local rotationDelta =  rotationDirection * randomAngle
    return rotationDelta
end

local function getValidHorizontalDirectionOption(option)
    local validOptions = { left = true, right = true, alternate = true, random = true }
    
    if ((option == nil) or not validOptions[option]) then
        return DEFAULT_HORIZONTAL_DIRECTION_OPTION
    else
        return option
    end
end

local function getInitialHorizontalDirection(option)
    if (option == "alternate" or option == "random") then
        return (math.random(1, 2) == 1) and "left" or "right"
    else
        return option -- Always left or right
    end
end

local function getNextHorizontalDirection(currentHorizontalDirection, option)
    if (option == "alternate") then
        return ((currentHorizontalDirection == "right") and "left" or "right")
    elseif (option == "random") then
        return (math.random(1, 2) == 1) and "left" or "right"
    else
        return currentHorizontalDirection -- Always left or right
    end
end

return function(transition2)
    return function (obj, params)
        
        -- FIXME: Handle all onX functions and pass them on to other transition functions
        -- FIXME: Handle cancelWhen function and pass it on
        
        -- Params decoding
        local speed = utils.getValidIntervalValue(params.speed, 0, 1, DEFAULT_SPEED)
        
        local verticalIntensity = utils.getValidIntervalValue(params.verticalIntensity, 0, 1, DEFAULT_VERTICAL_INTENSITY)
        local baseDeltaY = getBaseDeltaY(verticalIntensity)        
        
        local horizontalIntensity = utils.getValidIntervalValue(params.horizontalIntensity, 0, 1, DEFAULT_HORIZONTAL_INTENSITY)
        local baseDeltaX = getBaseDeltaX(horizontalIntensity)
        
        local time = getTime(speed)
        
        local rotationIntensity = utils.getValidIntervalValue(params.rotationIntensity, 0, 1, DEFAULT_ROTATION_INTENSITY)
        local rotationEnabled = (params.rotate ~= false)
        local zRotationEnabled = (params.zRotate ~= false)
        
        local horizontalDirectionOption = getValidHorizontalDirectionOption(params.horizontalDirection)
        
        -- State variables
        local verticalDirection = "down"    
        local horizontalDirection = getInitialHorizontalDirection(horizontalDirectionOption)
        
        local moveVertical
        moveVertical = function()
            
            -- Randomize radiusY slightly
            -- FIXME: Make randomization customizable in params
            local radiusY = baseDeltaY * (math.random(80, 120) / 100)
            if (verticalDirection == "up") then
                -- If going up, then reduce radius to a fraction of base radius
                radiusY = radiusY * (math.random(0, 10) / 100)
            end
            
            transition2.moveSine(obj, {
                time = (verticalDirection == "down") and time or time/2.5,
                radiusY = radiusY,
                deltaDegreesY = 180,
                startDegreesY = (verticalDirection == "down") and 270 or 90,
                iterations = 1,
                onIterationComplete = function(obj, params)                     
                    -- Flip direction and start new moveSine transition
                    verticalDirection = (verticalDirection == "down") and "up" or "down"                    
                    moveVertical()
                end
            })
        end
        
        local moveHorizontal
        moveHorizontal = function()
            
            -- Randomize radiusX quite a lot
            -- FIXME: Make randomization customizable in params
            local radiusX = baseDeltaX * (math.random(50, 150) / 100)            
            
            transition2.moveSine(obj, {
                time = time * 1.5 * math.random(5, 15) / 10,
                --time = time,
                radiusX = radiusX,
                deltaDegreesX = 180,
                startDegreesX = (horizontalDirection == "right") and 270 or 90,
                iterations = 1,                
                onIterationComplete = function(obj, params)                    
                    -- Calculate new direction of horizontal movement                    
                    horizontalDirection = getNextHorizontalDirection(horizontalDirection, horizontalDirectionOption)
                    moveHorizontal()
                end
            })
        end
        
        moveVertical()
        moveHorizontal()
                
        
                
        if (rotationEnabled) then
            transition.to(obj, {
                time = time,
                onIterationStart = function(obj, params)
                    params.rotation = obj.rotation + randomizeRotationDelta(rotationIntensity)
                end,
                iterations = 0,
                reverse = true,
                transition = easing.inOutSine,
                recalculateOnIteration = true,
            })                    
        end
        
        -- Apply zRotate
        if (zRotationEnabled) then
            -- FIXME: Allow a separate zRotate params object to be passed in to fallingLeaf() to customize the zRotation and overwrite default settings.
            transition.zRotate(obj, {
                time = time,                 
                reverse = true,
                iterations = 0,
                horizontal = math.random(1,2) == 1,
                shading = true, -- FIXME: Make it possible to disable shading
                onIterationStart = function(obj, params) 
                    params.degrees = randomizeRotationDelta(rotationIntensity)
                    params.horizontal = math.random(1,2) == 1
                end,
                shadingDarknessIntensity = 0.5,
                shadingBrightnessIntensity = 0,
                recalculateOnIteration = true,
                transition = easing.inOutSine,
            })
        end
    end
end