--[[
Falling leaf

TODO: Add comments and example 

transition.fallingLeaf(displayObject, {
    time = 2000, -- Default = 1000. The time for one vertical iteration.
    deltaY = 100, -- Default = 200
    deltaX = 150, -- Default = 200
    randomHorizontalDirection = true,
    disableSlowStart = true, -- Default = true. A slow start means that deltaX/Y will be gradually increased from 0 to specified param values
})

Markus Ranner 2017

--]]
return function(transition2)
    return function (obj, params)        
        -- FIXME: Add randomization to movement
        
        local SLOW_START_MIN_FACTOR = 0.5
        local SLOW_START_INCREASE_FACTOR = 1.2
        
        -- FIXME: Remove hard coded params
        local maxRadiusY = params.deltaY or 200
        local maxRadiusX = params.deltaX or 200
        local radiusY = params.disableSlowStart and maxRadiusY or (SLOW_START_MIN_FACTOR * maxRadiusY)
        local radiusX = params.disableSlowStart and maxRadiusX or (SLOW_START_MIN_FACTOR * maxRadiusX)
        local maxTime = (params.time or 1000)
        local time = maxTime --params.disableSlowStart and maxTime or (0.5 * maxTime)
        local randomHorizontalDirection = params.randomHorizontalDirection or false
        
        -- State variables
        local verticalDirection = "down"        
        local horizontalDirection = "right"
        local isSlowStart = (params.disableSlowStart ~= true)
        
        local moveVertical
        moveVertical = function()
            transition2.moveSine(obj, {
                time = time,
                radiusY = (verticalDirection == "down") and radiusY or (radiusY * 0.25),
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
                time = time * 2 * math.random(9, 11) / 10,
                radiusX = radiusX,
                deltaDegreesX = 180,
                startDegreesX = (horizontalDirection == "right") and 270 or 90,
                iterations = 1,
                recalculateOnIteration = true,
                onIterationComplete = function(obj, params)                    
                    
                    -- Increase radiusX during slow start
                    if (isSlowStart) then
                        radiusX = radiusX * SLOW_START_INCREASE_FACTOR                       
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
    end
end