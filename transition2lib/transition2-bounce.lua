--[[

Bounces a display object from it's current y position

Example usage:

local transition = require("transition2")

transition.bounce(displayObject, {
    height = 400, -- Bounces upwards. Set to negative value to bounce downwards.
    width = 200, -- Bounces to the right. Set to negative value to bounce left.
    time = 1000,
    iterations = 0,
})

Markus Ranner 2017

--]]
return {
    getStartValue = function(displayObject, params)
        local values = {}
        if (params.height) then
            -- Default value for y is to protect against crashes if display object has been removed
            values.y = (displayObject.y or 0)
        end
        if (params.width) then
            -- Default value for x is to protect against crashes if display object has been removed
            values.x = (displayObject.x or 0)
        end
        return values
    end,

    getEndValue = function(displayObject, params)
        local values = {}
        if (params.height) then
            -- Default value for y is to protect against crashes if display object has been removed
            values.y = (displayObject.y or 0) - params.height
        end
        if (params.width) then
            -- Default value for x is to protect against crashes if display object has been removed
            values.x = (displayObject.x or 0) + params.width
        end
        return values
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        if (params.height) then
            displayObject.y = value.y
        end
        if (params.width) then
            displayObject.x = value.x
        end
    end,

    getParams = function(displayObject, params)
        params = params or {}
        params.transition = easing.outSine
        params.transitionReverse = easing.inSine
        params.reverse = true

        -- params.time specifies the time for a full bounce cycle, so we just divide by 2 to get time for half cycle
        params.time = (params.time ~= nil) and (params.time/2) or 500
        params.static = false

        return params
    end,

    cancelWhen = function(displayObject, params)
        -- This will cancel the transition if the display object no longer has x and y values
        return displayObject.x == nil or displayObject.y == nil
    end
}
