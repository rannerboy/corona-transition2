--[[
Falling leaf

TODO: Add comments and example 

Markus Ranner 2017

--]]
return function(transition2)
    return function (obj, params)        
        -- FIXME: Add randomization to movement
        
        
        -- FIXME: Remove hard coded params
        local radiusY = 200
        local radiusX = 200
        local time = 1000
        local verticalDirection = "down"
        local horizontalDirection = "right"
        
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
                    verticalDirection = (verticalDirection == "down") and "up" or "down"
                    moveVertical()
                end
            })
        end
        
        local moveHorizontal
        moveHorizontal = function()
            transition2.moveSine(obj, {
                time = time * 2,
                radiusX = radiusX,
                deltaDegreesX = 180,
                startDegreesX = (horizontalDirection == "right") and 270 or 90,
                iterations = 1,
                recalculateOnIteration = true,
                onIterationComplete = function(obj, params)                    
                    horizontalDirection = (horizontalDirection == "right") and "left" or "right"
                    moveHorizontal()
                end
            })
        end
        
        moveVertical()
        moveHorizontal()
    end
end