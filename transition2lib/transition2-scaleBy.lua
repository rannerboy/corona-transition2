--[[

Scales an object by the specified xScale and yScale amounts over a specified time.

Overrides transition.scaleBy(): https://docs.coronalabs.com/api/library/transition/scaleBy.html

Example usage:

local transition = require("transition2")

transition.scaleBy( square, { xScale=2.0, yScale=1.5, time=2000 } )

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")
local scale = require("transition2lib.transition2-scale")

local scaleTo = utils.copyTable(scale)

scaleTo.getParams = function(displayObject, params)
    params.delta = true
    
    return scale.getParams(displayObject, params)
end    

return scaleTo