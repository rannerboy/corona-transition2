--[[

Overrides the default transition.to() function: https://docs.coronalabs.com/api/library/transition/to.html

Markus Ranner 2017

--]]


local utils = require("utils")

local function isFillEffect(target)
    return type(target) == "userdata"
end

local SIMPLE_PROPS = { "x", "y", "rotation", "alpha", "xScale", "yScale", "width", "height", "size" }
local RECT_PATH_PROPS = { "x1", "y1", "x2", "y2", "x3", "y3", "x4", "y4" }

return {
    getStartValue = function(target, params)
        local startValue = {}
                
        if (isFillEffect(target)) then
            -- For fill effects, we accept any numeric params since they may differ a lot between effects           
            -- FIXME: Should exclude time, delay and other numeric params here
            for propName, propValue in pairs(params) do
                if (type(propValue) == "number") then
                    if (params._isFromModeEnabled) then
                        startValue[propName] = (params.delta and ((target[propName] or 0) + propValue) or propValue)
                    else
                        startValue[propName] = target[propName] or 0
                    end
                end
            end
        elseif (utils.isRectPath(target)) then            
            -- For rect paths, we check only the (x1,y1)...(x4,y4) props
            for i = 1, #RECT_PATH_PROPS do
                local propName = RECT_PATH_PROPS[i]
                if (params[propName] ~= nil) then
                    if (params._isFromModeEnabled) then
                        startValue[propName] = (params.delta and (target[propName] + params[propName]) or params[propName])
                    else
                        startValue[propName] = target[propName] or 0                       
                    end
                end
            end 
        else       
            -- Regular display object
            for i = 1, #SIMPLE_PROPS do
                local propName = SIMPLE_PROPS[i]
                if (params[propName] ~= nil) then
                    if (params._isFromModeEnabled) then
                        startValue[propName] = (params.delta and (target[propName] + params[propName]) or params[propName])
                    else
                        startValue[propName] = target[propName] or 0
                    end
                end
            end
        end
        
        --[[
        for k,v in pairs(startValue) do
            print("startValue[" .. k .. "] = " .. tostring(v))
        end
        --]]
        return startValue
    end,

    getEndValue = function(target, params)
        local endValue = {}
        
        if (isFillEffect(target)) then
            -- For fill effects, we accept any numeric params since they may differ a lot between effects           
            -- FIXME: Should exclude time, delay and other numeric params here
            for propName, propValue in pairs(params) do
                if (type(propValue) == "number") then
                    if (params._isFromModeEnabled) then
                        endValue[propName] = target[propName] or 0
                    else
                        endValue[propName] = (params.delta and ((target[propName] or 0) + propValue) or propValue)
                    end
                end
            end
        elseif (utils.isRectPath(target)) then
            -- For rect paths, we only check the (x1,y1)...(x4,y4) props
            for i = 1, #RECT_PATH_PROPS do
                local propName = RECT_PATH_PROPS[i]
                if (params[propName] ~= nil) then                    
                    if (params._isFromModeEnabled) then
                        endValue[propName] = target[propName] or 0
                    else
                        endValue[propName] = (params.delta and (target[propName] + params[propName]) or params[propName])
                    end
                end
            end
        else        
            -- Regular display object
            for i = 1, #SIMPLE_PROPS do
                local propName = SIMPLE_PROPS[i]
                if (params[propName] ~= nil) then
                    if (params._isFromModeEnabled) then
                        endValue[propName] = target[propName] or 0
                    else
                        endValue[propName] = (params.delta and ((target[propName] or 0) + params[propName]) or params[propName])
                    end
                end
            end
        end
        
        --[[
        for k,v in pairs(endValue) do
            print("endValue[" .. k .. "] = " .. tostring(v))
        end
        --]]
        
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
    
        -- This is a little hack to allow transition2.from() to share implementation with transition.to().
        params._isFromModeEnabled = params._isFromModeEnabled or false
    
        return params
    end,
    
    cancelWhen = function(target, params)
        -- TODO: Is there any way to know if a fill effect is no longer valid so that we can auto-cancel transition?
        
        if (utils.isRectPath(target)) then
            return target.x1 == nil
        elseif (not isFillEffect(target)) then
            return target.x == nil
        end
    end
}