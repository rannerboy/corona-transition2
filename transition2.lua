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

local createTransition2 = require("transition2lib.transition2-main")

local transition2 = createTransition2({        
    -- New transition functions
    color = require("transition2lib.transition2-color"),
    bounce = require("transition2lib.transition2-bounce"),
    moveSine = require("transition2lib.transition2-moveSine"),   
    moveBungy = require("transition2lib.transition2-moveBungy"),   
    zRotate = require("transition2lib.transition2-zRotate"),
    waterBalloon = require("transition2lib.transition2-waterBalloon"),    
    
    -- Convenience functions (specialized versions of transitions)
    glow = require("transition2lib.transition2-glow"),  
    
    -- Overridden transition library functions
    blink = require("transition2lib.transition2-blink"),
    to = require("transition2lib.transition2-to"),
    from = require("transition2lib.transition2-from"),
    scaleTo = require("transition2lib.transition2-scaleTo"),
    scaleBy = require("transition2lib.transition2-scaleBy"),
    fadeIn = require("transition2lib.transition2-fadeIn"),
    fadeOut = require("transition2lib.transition2-fadeOut"),
    moveTo = require("transition2lib.transition2-moveTo"),
    moveBy = require("transition2lib.transition2-moveBy"),    
})


-- Transitions that use one or more other transition functions and contain special logic
transition2.fallingLeaf = require("transition2lib.transition2-fallingLeaf")(transition2)

-- Dissolve is the only legacy function that is handled as a special case since it has a completely different signature than other transition functions.
-- It is only implemented because of backwards compatibility with the transition library.
transition2.dissolve = require("transition2lib.transition2-dissolve")(transition2)

return transition2