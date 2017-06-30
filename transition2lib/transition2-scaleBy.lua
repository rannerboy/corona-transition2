--[[

Markus Ranner 2017

--]]

local utils = require("utils")
local scale = require("transition2-scale")

local scaleTo = utils.copyTable(scale)

scaleTo.getParams = function(displayObject, params)
    params.delta = true
    
    return scale.getParams(displayObject, params)
end    

return scaleTo