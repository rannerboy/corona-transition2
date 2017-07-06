--[[

Scales an object to/by the specified xScale and yScale amounts over a specified time.

Used to override two functions:

transition.scaleTo(): https://docs.coronalabs.com/api/library/transition/scaleTo.html
transition.scaleBy(): https://docs.coronalabs.com/api/library/transition/scaleBy.html

Example usage:

local transition = require("transition2")

transition.scaleTo( square, { xScale=2.0, yScale=1.5, time=2000 } )
transition.scaleBy( square, { xScale=2.0, yScale=1.5, time=2000 } )

Markus Ranner 2017

--]]
return {
    getStartValue = function(displayObject, params)     
        return {
            x = displayObject.xScale,
            y = displayObject.yScale,
        }
    end,

    getEndValue = function(displayObject, params)
        return {
            x = (params.delta and (displayObject.xScale + (params.xScale or 0)) or (params.xScale or displayObject.xScale)),
            y = (params.delta and (displayObject.yScale + (params.yScale or 0)) or (params.yScale or displayObject.yScale)),
        }
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        displayObject.xScale = value.x
        displayObject.yScale = value.y
    end,
    
    getParams = function(displayObject, params) 
        local params = params or {}               
        params.static = false
        
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        return not displayObject.xScale
    end    
}