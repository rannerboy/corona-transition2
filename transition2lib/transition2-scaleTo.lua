--[[

Scales an object to the specified xScale and yScale amounts over a specified time.

Overrides transition.scaleTo(): https://docs.coronalabs.com/api/library/transition/scaleTo.html

Example usage:

local transition = require("transition2")

transition.scaleTo( square, { xScale=2.0, yScale=1.5, time=2000 } )

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")
local scale = require("transition2lib.transition2-scale")

local scaleTo = utils.copyTable(scale)

scaleTo.getParams = function(displayObject, params)
    params.delta = false
    
    return scale.getParams(displayObject, params)
end    

return scaleTo