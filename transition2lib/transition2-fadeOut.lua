--[[

Fades an object to alpha of 0 over the specified time.

Overrides transition.fadeOut(): https://docs.coronalabs.com/api/library/transition/fadeOut.html

Example usage:

local transition = require("transition2")

transition.fadeOut(obj, { time=2000 })

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")
local fade = require("transition2lib.transition2-fade")

local fadeOut = utils.copyTable(fade)

fadeOut.getParams = function(displayObject, params)    
    params.alpha = 0
    return fade.getParams(displayObject, params)
end    

return fadeOut