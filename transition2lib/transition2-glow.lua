--[[
Glows a display object indefinitely back and forth between two colors

Example:

local transition = require("transition2")

transition.glow(displayObject, {
    startColor = {1, 1, 0, 1}, -- Yellow
    endColor = {1, 0, 0, 1}, -- Red
    time = 1000,
    stroke = true, -- Enable stroke color glow
    fill = false, -- Disable fill color glow
})

Markus Ranner 2017

--]]

local utils = require("transition2lib.utils")
local color = require("transition2lib.transition2-color")

local glow = utils.copyTable(color)

--[[
Params:
    time - Optional. Time in ms for a full glow cycle (startColor->endColor->startColor). Default is 2000 ms
    startColor - Required. The start color for the glow effect { r, g, b, a }
    endColor - Required. The end color for the glow effect { r, g, b, a }
    stroke - Optional. Set to false to disable stroke glow
    fill - Optional. Set to false to disable fill glow        
--]]
glow.getParams = function(displayObject, params)
    params.time = (params.time ~= nil) and (params.time/2) or 1000
    params.reverse = true
    params.iterations = 0
    params.transition = easing.inOutSine
    params.transitionReverse = easing.inOutSine
    params.static = false
    
    -- Pass the glow specific params into the getParams function of the color transition
    return color.getParams(displayObject, params)
end    

return glow