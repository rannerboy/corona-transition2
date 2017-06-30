--[[

Markus Ranner 2017

--]]

local utils = require("utils")
local to = require("transition2-to")

local from = utils.copyTable(to)

from.getParams = function(displayObject, params)    
    params._isFromModeEnabled = true
    return to.getParams(displayObject, params)
end    

return from