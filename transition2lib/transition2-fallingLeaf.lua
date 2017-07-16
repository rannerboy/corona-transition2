--[[
Falling leaf

TODO: Add comments and example 

transition.fallingLeaf(displayObject, {
    time = 2000, -- Default = 1500. The time for one vertical iteration.
    deltaY = 100, -- Default = 200
    deltaX = 150, -- Default = 200
    randomHorizontalDirection = true,
    disableSlowStart = true, -- Default = true. A slow start means that deltaX/Y will be gradually increased from 0 to specified param values
    rotate = false, -- Default = true. Applies rotation to the object.
    zRotate = false, -- Default = true. Applies zRotate transition with shading.
})

Markus Ranner 2017

--]]
return function(transition2)
    return function (obj, params)
        
        -- FIXME: Handle all onX functions and pass them on to other transition functions
        -- FIXME: Handle cancelWhen function and pass it on
        
        local SLOW_START_MIN_FACTOR = 0.5
        local SLOW_START_INCREASE_FACTOR = 1.2
        
        -- Params decoding
        local maxRadiusY = params.deltaY or 200
        local maxRadiusX = params.deltaX or 300
        local radiusY = params.disableSlowStart and maxRadiusY or (SLOW_START_MIN_FACTOR * maxRadiusY)
        local radiusX = params.disableSlowStart and maxRadiusX or (SLOW_START_MIN_FACTOR * maxRadiusX)        
        local time = (params.time or 1500)
        local randomHorizontalDirection = params.randomHorizontalDirection or false
        local rotationEnabled = (params.rotate ~= false)
        local zRotationEnabled = (params.zRotate ~= false)
        
        -- State variables
        local verticalDirection = "down"        
        local horizontalDirection = (math.random(1, 2) == 1) and "right" or "left"
        local isSlowStart = (params.disableSlowStart ~= true)
        
        local moveVertical
        moveVertical = function()
            transition2.moveSine(obj, {
                time = (verticalDirection == "down") and time or time/1.5,
                radiusY = (verticalDirection == "down") and radiusY or (radiusY * math.random(0, 10) / 100),
                deltaDegreesY = 180,
                startDegreesY = (verticalDirection == "down") and 270 or 90,
                iterations = 1,
                recalculateOnIteration = true,
                onIterationComplete = function(obj, params) 
                    -- Increase radiusY during slow start
                    if (isSlowStart) then
                        radiusY = radiusY * SLOW_START_INCREASE_FACTOR                        
                        if (radiusY >= maxRadiusY) then
                            isSlowStart = false
                            radiusY = maxRadiusY
                        end        
                        --[[
                        time = time * 1.1
                        if (time >= maxTime) then
                            time = maxTime
                        end 
                        --]]
                    end                   
                    
                    verticalDirection = (verticalDirection == "down") and "up" or "down"
                    moveVertical()
                end
            })
        end
        
        local moveHorizontal
        moveHorizontal = function()
            transition2.moveSine(obj, {
                time = time * 2 * math.random(5, 20) / 10,
                radiusX = radiusX,
                deltaDegreesX = 180,
                startDegreesX = (horizontalDirection == "right") and 270 or 90,
                iterations = 1,
                recalculateOnIteration = true,
                onIterationComplete = function(obj, params)                    
                    
                    -- Increase radiusX during slow start
                    -- FIXME: BUG! Since time is not the same for vertical and horizontal cycle, the max radiusX will never be reached here
                    if (isSlowStart) then
                        radiusX = radiusX * SLOW_START_INCREASE_FACTOR   
                        print(radiusX)
                        if (radiusX >= maxRadiusX) then                            
                            radiusX = maxRadiusX
                        end        
                    end
                                        
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