--[[

Blinks a display object in and out over a specified time, repeating indefinitely.

Mimics and overrides the blink() function of the original transition library.
Override was done to offer the additional params offered by transition2, and to make sure that blink is auto-cancelled when display object has been removed.

Example usage:

local transition = require("transition2")

transition.blink(displayObject, {
    time = 500 -- Default = 1000
})

Markus Ranner 2017

--]]
return {
    getStartValue = function(displayObject, params)     
        return 1
    end,

    getEndValue = function(displayObject, params)
        return 0
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        displayObject.alpha = value
    end,
    
    getParams = function(displayObject, params) 
        local params = params or {}
        
        params.transition = easing.inSine
        params.reverse = false
        params.iterations = 0
        params.iterationDelay = nil
        params.time = params.time or 1000
        params.static = false
        
        return params
    end,
    
    cancelWhen = function(displayObject, params)
        return not displayObject.alpha
    end    
}