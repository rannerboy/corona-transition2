--[[
Falling leaf

TODO: Add comments and example 

transition.fallingLeaf(displayObject, {
    speed = 0.25, -- A value between 0-1. Default = 0.5.
    loopLength = 0.75, -- A value between 0-1. Default = 0.5.
    intensity = 0.75, -- Affects horizontal movement and rotation. A value between 0-1. Default = 0.5.
    
    randomHorizontalDirection = true,
    rotate = false, -- Default = true. Applies rotation to the object.
    zRotate = false, -- Default = true. Applies zRotate transition with shading.
})

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")

local DEFAULT_SPEED = 0.25
local DEFAULT_VERTICAL_INTENSITY = 0.5
local DEFAULT_HORIZONTAL_INTENSITY = 0.5

-- FIXME: Should only be affected by vertical intensity, not speed
local function getBaseDeltaY(speed)
    local MIN_DELTA_Y = 25
    local MAX_DELTA_Y = 500
    
    local baseDeltaY = ((MAX_DELTA_Y - MIN_DELTA_Y) * speed) + MIN_DELTA_Y
        
    return baseDeltaY
end

local function getBaseDeltaX(horizontalIntensity)
    local MIN_DELTA_X = 25
    local MAX_DELTA_X = 300
    
    local baseDeltaX = ((MAX_DELTA_X - MIN_DELTA_X) * horizontalIntensity) + MIN_DELTA_X
    
    return baseDeltaX
end

local function getTime(speed)
    local MIN_TIME = 1000
    local MAX_TIME = 3000
    
    -- Time will increase as speed increases
    local time = ((MAX_TIME - MIN_TIME) * speed) + MIN_TIME    
    
    return time
end

return function(transition2)
    return function (obj, params)
        
        -- FIXME: Handle all onX functions and pass them on to other transition functions
        -- FIXME: Handle cancelWhen function and pass it on
        
        -- Params decoding
        local speed = utils.getValidIntervalValue(params.speed, 0, 1, DEFAULT_SPEED)
        local baseDeltaY = getBaseDeltaY(speed)        
        
        local horizontalIntensity = utils.getValidIntervalValue(params.horizontalIntensity, 0, 1, DEFAULT_HORIZONTAL_INTENSITY)
        local baseDeltaX = getBaseDeltaX(horizontalIntensity)
        
        local time = getTime(speed)
        
        local randomHorizontalDirection = params.randomHorizontalDirection or false
        local rotationEnabled = (params.rotate ~= false)
        local zRotationEnabled = (params.zRotate ~= false)
        
        -- State variables
        local verticalDirection = "down"        
        local horizontalDirection = (math.random(1, 2) == 1) and "right" or "left"
        
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
                -- FIXME: This time calculation doesn't feel very good
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
                    -- FIXME: Allow four different settings: alternate(default)/left/right/random
                    -- Calculate new direction of horizontal movement
                    if (randomHorizontalDirection) then
                        horizontalDirection = (math.random(1, 2) == 1) and "right" or "left"
                    else
                        horizontalDirection = (horizontalDirection == "left") and "right" or "left"
                    end
                                        
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
                    -- FIXME: rotation should depend on rotationIntensity
                    local rotationDelta = 90 + 720 * (math.random(1,2) == 1 and 1 or -1) * horizontalIntensity
                    
                    params.rotation = obj.rotation + rotationDelta
                end,
                iterations = 0,
                reverse = true,
                transition = easing.inOutSine,
                recalculateOnIteration = true,
            })                    
        end
        
        -- FIXME: zRotate speed should depend on intensity
        -- Apply zRotate
        if (false and zRotationEnabled) then
            -- FIXME: Allow a separate zRotate params object to be passed in to fallingLeaf() to customize the zRotation and overwrite default settings.
            transition.zRotate(obj, {
                time = time,                 
                reverse = true,
                iterations = 0,
                shading = true, -- FIXME: Make it possible to disable shading
                onIterationStart = function(obj, params) 
                    params.degrees = math.random(-360, 360)
                end,
                shadingDarknessIntensity = 0.5,
                shadingBrightnessIntensity = 0,
                recalculateOnIteration = true,
            })
        end
    end
end