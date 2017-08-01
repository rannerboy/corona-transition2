--[[
Applies a falling leaf effect to a display object

NOTE: fallingLeaf does not return any transition handle since there are actually several transitions going on.
This means that pause(), resume() or cancel() can't be used with a transition ref as param. Using tags will work, for example transition.pause("leaf").

Example usage:

transition.fallingLeaf(displayObject, {
    delay = 500, -- Initial delay in ms. Default = 0.
    speed = 0.25, -- A value between 0-1. Default = 0.5.
    verticalIntensity = 0.75, -- A value between 0-1. Default = 0.5.
    horizontalIntensity = 0.75, -- A value between 0-1. Default = 0.5.    
    
    horizontalDirection, = One of {"alternate", "right", "left", "random" }. Default = "alternate".
    
    randomness = 0.75, -- A value between 0-1. A larger value means more randomness. Default = 0.5.
    
    rotate = false, -- Default = true. Applies rotation to the object.
    zRotate = false, -- Default = true. Applies zRotate transition with specified zRotateParams.
    rotationIntensity = 0.75, -- A value between 0-1. Default = 0.5. Applies to both 2d rotation and zRotate.
    zRotateParams = {
        -- The parameters below are the only ones from zRotate that can be customized.
        -- For default values and usage, see zRotate() docs.
        shading = true, -- Default = true
        shadingDarknessIntensity = 0.5,
        shadingBrightnessIntensity = 1,
        perspective = 0.5,
        disableStrokeScaling = true,
    },    
    
    tag = "leaf",
    
    cancelWhen = function() (leaf.y > (display.contentHeight + leaf.height)) end,
    
    onStart = function(target) print("onStart") end,    
    onPause = function(target) print("onComplete") end,    
    onResume = function(target) print("onResume") end,
    onCancel = function(target) print("onCancel") end,
    
    -- NOTE! The following params are NOT supported
    -- onComplete
    -- onIterationStart
    -- onIterationComplete
})

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")

local DEFAULT_SPEED = 0.5
local DEFAULT_VERTICAL_INTENSITY = 0.5
local DEFAULT_HORIZONTAL_INTENSITY = 0.5
local DEFAULT_ROTATION_INTENSITY = 0.5
local DEFAULT_HORIZONTAL_DIRECTION_OPTION = "alternate"
local DEFAULT_RANDOMNESS = 0.5

local function getBaseDeltaY(verticalIntensity)
    local MIN_DELTA_Y = 25
    local MAX_DELTA_Y = 600
    
    local baseDeltaY = ((MAX_DELTA_Y - MIN_DELTA_Y) * verticalIntensity) + MIN_DELTA_Y
        
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

local function randomizeRotationDelta(rotationIntensity, randomness)
    local rotationDirection = (math.random(1,2) == 1 and 1 or -1)
    local minAngle = 90 + (rotationIntensity * 720)
    local randomAngle = minAngle + ((180 + (math.random(-180, 180) * randomness)) * rotationIntensity)
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
        local zRotateParams = params.zRotateParams or {}
        
        local horizontalDirectionOption = getValidHorizontalDirectionOption(params.horizontalDirection)
        
        local randomness = utils.getValidIntervalValue(params.randomness, 0, 1, DEFAULT_RANDOMNESS)
        
        -- State variables
        local verticalDirection = "down"    
        local horizontalDirection = getInitialHorizontalDirection(horizontalDirectionOption)
                
        local moveVertical
        moveVertical = function()
            
            -- Randomize radiusY by at most 30%
            local radiusY = baseDeltaY + (math.random(-30, 30) / 100 * baseDeltaY * randomness)
            --print("radiusY = " .. radiusY)
            if (verticalDirection == "up") then
                -- If going up, then reduce radius to a fraction of base radius (0-10%)
                local randomFactor = randomness * (math.random(-5, 5) / 100)                
                radiusY = radiusY * (0.05 + randomFactor)
            end
            
            transition2.moveSine(obj, {
                time = (verticalDirection == "down") and time or time/2.5, -- Shorter time when going up makes the movement look a lot better. 
                radiusY = radiusY,
                deltaDegreesY = 180,
                startDegreesY = (verticalDirection == "down") and 270 or 90,
                iterations = 1,
                onIterationComplete = function(obj, params)                     
                    -- Flip direction and start new moveSine transition
                    verticalDirection = (verticalDirection == "down") and "up" or "down"                    
                    moveVertical()
                end,
                cancelWhen = params.cancelWhen,                
                tag = params.tag,
                
                -- Note! These onX functions will only be applied here and not to any other transition functions. This to avoid calling them more than once.
                onCancel = params.onCancel,
                onPause = params.onPause,
                onResume = params.onResume,                
            })
        end
        
        local moveHorizontal
        moveHorizontal = function()
            
            -- Randomize radiusX quite a lot
            local radiusX = baseDeltaX + (math.random(-50, 50) / 100 * baseDeltaX * randomness)            
            --print("radiusX = " .. radiusX)
            local randomizedTime = time * 1.5 * (1 + (math.random(-5, 5) / 10 * randomness))
            --print("horizontal time = " .. randomizedTime)
            
            transition2.moveSine(obj, {
                time = randomizedTime,
                radiusX = radiusX,
                deltaDegreesX = 180,
                startDegreesX = (horizontalDirection == "right") and 270 or 90,
                iterations = 1,                
                onIterationComplete = function(obj, params)                    
                    -- Calculate new direction of horizontal movement                    
                    horizontalDirection = getNextHorizontalDirection(horizontalDirection, horizontalDirectionOption)
                    moveHorizontal()
                end,
                cancelWhen = params.cancelWhen,
                tag = params.tag,
            })
        end
                
        local function rotate()
            if (rotationEnabled) then
                transition2.to(obj, {
                    time = time,
                    onIterationStart = function(obj, params)
                        local currentRotation = obj.rotation
                        if (currentRotation) then                            
                            params.rotation = currentRotation + randomizeRotationDelta(rotationIntensity, randomness)
                        end
                    end,
                    iterations = 0,
                    reverse = true,
                    transition = easing.inOutSine,
                    recalculateOnIteration = true,
                    cancelWhen = params.cancelWhen,
                    tag = params.tag,
                })                    
            end
            
            -- Apply zRotate
            if (zRotationEnabled) then            
                transition2.zRotate(obj, {
                    time = time,                 
                    reverse = true,
                    iterations = 0,
                    horizontal = math.random(1,2) == 1,
                    shading = (zRotateParams.shading ~= false),
                    onIterationStart = function(obj, params) 
                        params.degrees = randomizeRotationDelta(rotationIntensity, randomness)
                        params.horizontal = math.random(1,2) == 1
                    end,
                    shadingDarknessIntensity = zRotateParams.shadingDarknessIntensity,
                    shadingBrightnessIntensity = zRotateParams.shadingBrightnessIntensity,
                    perspective = zRotateParams.perspective,
                    disableStrokeScaling = zRotateParams.disableStrokeScaling,
                    recalculateOnIteration = true,
                    transition = easing.inOutSine,
                    cancelWhen = params.cancelWhen,
                    tag = params.tag,
                })
            end
        end
        
        timer.performWithDelay(params.delay or 0, function()
            if (params.onStart) then
                params.onStart(obj)
            end
            moveVertical()
            moveHorizontal()
            rotate()
        end)
    end
end