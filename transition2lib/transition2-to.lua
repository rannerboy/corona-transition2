--[[

TODO: doc

Markus Ranner 2017

--]]

--[[
[filterParameter] (optional)
Number. Applicable only if the target is a fill.effect applied to a ShapeObject. In this case, [filterParameter] indicates an effect property associated with the specific filter effect, for example ShapeObject.fill.effect.intensity. See the Filters, Generators, Composites guide for which filter parameters apply to each filter.
--]]

local utils = require("utils")

local SIMPLE_PROPS = { "x", "y", "rotation", "alpha", "xScale", "yScale", "width", "height", "size" }
local RECT_PATH_PROPS = { "x1", "y1", "x2", "y2", "x3", "y3", "x4", "y4" }

return {
    getStartValue = function(target, params)
        local startValue = {}
        
        for i = 1, #SIMPLE_PROPS do
            local propName = SIMPLE_PROPS[i]
            if (params[propName] ~= nil) then
                startValue[propName] = target[propName] or 0
            end
        end
        
        -- For rect paths, we check the (x1,y1)...(x4,y4) props
        if (utils.isRectPath(target)) then            
            for i = 1, #RECT_PATH_PROPS do
                local propName = RECT_PATH_PROPS[i]
                if (params[propName] ~= nil) then                    
                    startValue[propName] = target[propName] or 0
                    --print(startValue[propName])
                end
            end 
        end
        
        return startValue
    end,

    getEndValue = function(target, params)
        local endValue = {}
        
        for i = 1, #SIMPLE_PROPS do
            local propName = SIMPLE_PROPS[i]
            if (params[propName] ~= nil) then
                endValue[propName] = (params.delta and ((target[propName] or 0) + params[propName]) or params[propName])
            end
        end
        
        -- For rect paths, we check the (x1,y1)...(x4,y4) props
        if (utils.isRectPath(target)) then
            for i = 1, #RECT_PATH_PROPS do
                local propName = RECT_PATH_PROPS[i]
                if (params[propName] ~= nil) then                    
                    endValue[propName] = (params.delta and (target[propName] + params[propName]) or params[propName])
                end
            end
        end
        
        return endValue        
    end,

    onValue = function(target, params, value, isReverseCycle)
        for propName, propValue in pairs(value) do
            target[propName] = propValue
        end
    end,
 
    getParams = function(target, params)                
        params.time = params.time or 500
        params.transition = params.transition or easing.linear
        params.delta = (params.delta == true)            
    
        return params
    end,
    
    cancelWhen = function(target, params)
        ---[[
        print("cancelWhen here...")
        if (utils.isRectPath(target)) then
            return target.x1 == nil
        else
            -- Normal display object
            return target.x == nil
        end
        --]]
    end
}