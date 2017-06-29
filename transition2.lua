--[[
transition2 is an extensible wrapper for the existing Corona transition library

Create custom transitions easily and use them together with already existing transitions.

To implement your own custom transition, see transition2-template.lua and example transitions like transition2-color.lua and transition2-bounce.lua.
Then add them to the config passed into the transition2() function below.

transition2 supports pause()/resume()/cancel() just like the default transition module. All existing transition functions of the original transition module
can also be used on transition2, like transition2.to() and transition2.blink()

Markus Ranner 2017
--]]
package.path = package.path .. ";./?.lua;./transition2lib/?.lua;"

local transition2 = require("transition2-main")

return transition2({        
    -- Transition functions
    color = require("transition2-color"),
    bounce = require("transition2-bounce"),
    moveSine = require("transition2-moveSine"),   
    moveBungy = require("transition2-moveBungy"),   
    zRotate = require("transition2-zRotate"),
    blink = require("transition2-blink"),
    
    -- Convenience functions (specialized versions of transitions)
    glow = require("transition2-glow"),       
})