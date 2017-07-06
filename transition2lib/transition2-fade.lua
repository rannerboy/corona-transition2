--[[

Fades an object to/by alpha over the specified time.

Used to override two functions:

transition.fadeIn(): https://docs.coronalabs.com/api/library/transition/fadeIn.html
transition.fadeOut(): https://docs.coronalabs.com/api/library/transition/fadeOut.html

Example usage:

local transition = require("transition2")

transition.fadeIn( obj, { time=2000 } )
transition.fadeOut( obj, { time=2000 } )

Markus Ranner 2017

--]]
return {
    getStartValue = function(displayObject, params)     
        return displayObject.alpha
    end,

    getEndValue = function(displayObject, params)        
        return (params.alpha or displayObject.alpha)
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        displayObject.alpha = value
    end,
    
    getParams = function(displayObject, params)                 
        params = params or {}
                
        params.delta = false
        params.static = false
        
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        return not displayObject.alpha
    end    
}