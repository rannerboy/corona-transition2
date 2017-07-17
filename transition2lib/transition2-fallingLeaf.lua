--[[
Falling leaf

TODO: Add comments and example 

transition.fallingLeaf(displayObject, {
    speed = 0.25, -- A value between 0-1. Default = 0.5.
    
    deltaX = 150, -- Default = 200
    randomHorizontalDirection = true,
    rotate = false, -- Default = true. Applies rotation to the object.
    zRotate = false, -- Default = true. Applies zRotate transition with shading.
})

Markus Ranner 2017

--]]

local DEFAULT_SPEED = 0.5
local DEFAULT_TIME = 1500

local function getValidSpeed(speed)
    if (speed == nil) then
        return DEFAULT_SPEED
    elseif (speed < 0) then
        return 0
    elseif(speed > 1) then
        return 1
    else
        return speed
    end    
end

local function getBaseDeltaY(speed)
    local MIN_DELTA_Y = 25
    local MAX_DELTA_Y = 400
    
    local targetDeltaY = ((MAX_DELTA_Y - MIN_DELTA_Y) * speed) + MIN_DELTA_Y
    
    print("targetDeltaY = " .. targetDeltaY)
    
    return targetDeltaY
end

local function getBaseDeltaX(windIntensity)
    -- FIXME
    return 100
end

local function getValidWindIntensity(windIntensity)
    -- FIXME
    return 0.5
end

local function getTime(speed)
    local MIN_TIME = 1000
    local MAX_TIME = 3000
    
    -- Time will increase as speed increases
    local time = ((MAX_TIME - MIN_TIME) * speed) + MIN_TIME
    print("time = " .. time)
    
    return time
end

return function(transition2)
    return function (obj, params)
        
        -- FIXME: Handle all onX functions and pass them on to other transition functions
        -- FIXME: Handle cancelWhen function and pass it on
        
        -- Params decoding
        local speed = getValidSpeed(params.speed)
        local baseDeltaY = getBaseDeltaY(speed)        
        
        local windIntensity = getValidWindIntensity(params.windIntensity)
        local baseDeltaX = getBaseDeltaX(windIntensity)
        
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
            local radiusY = baseDeltaY * (math.random(80, 120) / 100)
            if (verticalDirection == "up") then
                -- If going up, then reduce radius to a fraction of base radius
                radiusY = radiusY * (math.random(0, 10) / 100)
            end
            
            transition2.moveSine(obj, {
                time = (verticalDirection == "down") and time or time/3,
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
            
            local radiusX = baseDeltaX
            
            transition2.moveSine(obj, {
                time = time * 2 * math.random(5, 20) / 10,
                radiusX = radiusX,
                deltaDegreesX = 180,
                startDegreesX = (horizontalDirection == "right") and 270 or 90,
                iterations = 1,                
                onIterationComplete = function(obj, params)                    
                    -- FIXME: Add randomization to radiusX
                    
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
                    params.rotation = obj.rotation + math.random(-360, 360)
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