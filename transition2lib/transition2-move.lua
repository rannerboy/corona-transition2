--[[

Moves an object to/by the specified x and y coordinates over a specified time.

Used to override two functions:

transition.moveTo(): https://docs.coronalabs.com/api/library/transition/moveTo.html
transition.moveBy(): https://docs.coronalabs.com/api/library/transition/moveBy.html

Example usage:

local transition = require("transition2")

transition.moveTo( obj, { x=200, y=400, time=2000 } )
transition.moveBy( obj, { x=-100, y=800, time=2000 } )

Markus Ranner 2017

--]]
return {
    getStartValue = function(displayObject, params)     
        return {
            x = displayObject.x,
            y = displayObject.y,
        }
    end,

    getEndValue = function(displayObject, params)
        return {
            x = (params.delta and (displayObject.x + (params.x or 0)) or (params.x or displayObject.x)),
            y = (params.delta and (displayObject.y + (params.y or 0)) or (params.y or displayObject.y)),
        }
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        displayObject.x = value.x
        displayObject.y = value.y
    end,
    
    getParams = function(displayObject, params) 
        local params = params or {}               
        
        params.static = false
        
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        return not displayObject.x
    end    
}