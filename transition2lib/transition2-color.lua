--[[

Fades a display object from one color into another.
Stroke and fill can be disabled separately.

Example usage:

local transition = require("transition2")

transition.color(displayObject, {
    startColor = {1, 1, 0, 1}, -- Yellow
    endColor = {1, 0, 0, 1}, -- Red
    time = 500,
    stroke = true, -- Enable stroke color fade
    fill = false, -- Disable fill color fade
    reverse = true, -- Will fade back from endColor to startColor when done
    iterations = 0, -- Repeat forever    
})

Markus Ranner 2017

--]]
return {
    getStartValue = function(displayObject, params)     
        return params.startColor
    end,

    getEndValue = function(displayObject, params)
        return params.endColor
    end,

    onValue = function(displayObject, params, value, isReverseCycle)
        -- Stroke and fill can be disabled separately, but are enabled by default
        local enableStroke = (params.stroke == nil) and true or params.stroke
        local enableFill = (params.fill == nil) and true or params.fill
        
        local r, g, b, a = unpack(value)
        if (enableFill and displayObject.setFillColor) then
            displayObject:setFillColor(r, g, b, a)
        end
        if (enableStroke and displayObject.setStrokeColor) then
            displayObject:setStrokeColor(r, g, b, a)
        end
    end,
    
    cancelWhen = function(displayObject, params)
        -- If the setFillColor no longer exists, the display object has been removed and there is no need for the transition to go on
        return not displayObject.setFillColor        
    end,
    
    getParams = function(displayObject, params)
        params = params or {}
        params.static = false
        return params
    end
}