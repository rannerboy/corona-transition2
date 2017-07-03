--[[

Moves an object to the specified x and y coordinates over a specified time.

Overrides transition.moveTo(): https://docs.coronalabs.com/api/library/transition/moveTo.html

Example usage:

local transition = require("transition2")

transition.moveTo(obj, { x=200, y=400, time=2000 })

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")
local move = require("transition2lib.transition2-move")

local moveTo = utils.copyTable(move)

moveTo.getParams = function(displayObject, params)
    params.delta = false
    
    return move.getParams(displayObject, params)
end    

return moveTo