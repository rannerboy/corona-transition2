--[[
transition2 is an extensible wrapper for the existing Corona transition library

Create custom transitions easily and use them together with already existing transitions.

To implement your own custom transition, see transition2-template.lua and example transitions like transition2-color.lua and transition2-bounce.lua.
Then add them to the config passed into the transition2() function below.

transition2 supports pause()/resume()/cancel() just like the default transition module. All existing transition functions of the original transition library
can also be used on transition2. The ones that have not been overriden are forwarded instead.

Markus Ranner 2017
--]]
package.path = package.path .. ";./?.lua;./transition2lib/?.lua;"

local createTransition2 = require("transition2-main")

local transition2 = createTransition2({        
    -- New transition functions
    color = require("transition2-color"),
    bounce = require("transition2-bounce"),
    moveSine = require("transition2-moveSine"),   
    moveBungy = require("transition2-moveBungy"),   
    zRotate = require("transition2-zRotate"),
    
    -- Convenience functions (specialized versions of transitions)
    glow = require("transition2-glow"),  
    
    -- Overridden transition library functions
    blink = require("transition2-blink"),
    to = require("transition2-to"),
    scaleTo = require("transition2-scaleTo"),
})

-- Functions that are just forwarded to the original transition library
transition2.from = transition.from
transition2.dissolve = transition.dissolve
transition2.fadeIn = transition.fadeIn
transition2.fadeOut = transition.fadeOut
transition2.moveBy = transition.moveBy
transition2.moveTo = transition.moveTo
transition2.scaleBy = transition.scaleBy

return transition2