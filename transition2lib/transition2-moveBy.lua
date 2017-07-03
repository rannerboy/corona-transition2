--[[

Moves an object by the specified x and y coordinate amount over a specified time.

Overrides transition.moveBy(): https://docs.coronalabs.com/api/library/transition/moveBy.html

Example usage:

local transition = require("transition2")

transition.moveBy(obj, { x=200, y=400, time=2000 })

Markus Ranner 2017

--]]
local utils = require("transition2lib.utils")
local move = require("transition2lib.transition2-move")

local moveBy = utils.copyTable(move)

moveBy.getParams = function(displayObject, params)
    params.delta = true
    
    return move.getParams(displayObject, params)
end    

return moveBy