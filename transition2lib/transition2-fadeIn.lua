--[[

Fades an object to alpha of 1.0 over the specified time.

Overrides transition.fadeIn(): https://docs.coronalabs.com/api/library/transition/fadeIn.html

Example usage:

local transition = require("transition2")

transition.fadeIn(obj, { time=2000 })

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")
local fade = require("transition2lib.transition2-fade")

local fadeIn = utils.copyTable(fade)

fadeIn.getParams = function(displayObject, params)    
    params.alpha = 1    
    return fade.getParams(displayObject, params)
end    

return fadeIn