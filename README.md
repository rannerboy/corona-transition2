# corona-transition2

transition2 is an extension to the [Corona transition library](https://docs.coronalabs.com/api/library/transition/index.html). It comes with a some new transition functions and can easily be extended with your own custom transition functions.

The current documentation is rather brief, but go ahead and have a look at the source code for better understanding, it's fairly well commented.

## Installing

Clone corona-transition2 and place **transition2.lua** and the entire **transition2lib** folder in the root of your Corona project.

**NOTE!** If you're not placing transition2 directly at the root of your Corona project, make sure to change the require statements in **transition2.lua**.

Require transition2 into a local variable to have full control of which transition2 functions to use, like this:

```lua
-- In some Lua file:
local transition = require("transition2")
transition.to(...)
transition.moveSine(...)

-- In another Lua file
transition.to(...) --> Will call original transition library
transition.moveSine(...) --> ERROR: Undefined function moveSine

-- I think you get the picture...
```

Or, if you're a daredevil, just override the global transition variable in your **main.lua** to run every single transition through transition2 and hope for the best. :-)

```lua
-- In main.lua
transition = require("transition2")

-- Then, in whatever Lua file of your project
transition.to(...) --> transition2.to(...)
transition.moveSine(...) --> transition2.moveSine(...)
transition.blink(...) --> transition2.blink(...)
transition.cancel(...) --> transition2.cancel(...)
-- Yeah, I bet you got that part too... :-)
```

## Important note

Please note that transition2 is work in progress. There might be bugs, performance can likely be improved, and the number of new transition functions to choose from is still quite limited.

Just grab the source code as is and make your own modifications if you need to. I'd be really happy for any feedback, especially in case you run into any bugs or other problems. And if you decide to implement your own custom transition function it would be awesome if you want to share it so I can make it part of the default transition2 library!

## Basic usage

```lua
local transition = require("transition2")

-- This variable will be used to demonstrate auto-cancel of transitions
local shouldCancel = false

--[[
Applies a color fade effect to a display object.
Most params here are optional and are only included to show what's possible to do.
--]]
transition.color(displayObject, {
    -- These params are specific for the color transition
    startColor = {1, 1 ,1, 1}, -- White
    endColor = {1, 0.5, 0, 1}, -- Orange
    stroke = false,
    fill = true,
    
    --[[
    
    Below are general parameters that can be applied to all transition2 functions
    A couple of them are transition2 specific, but most of them work just like for the original Corona transition library    
    
    --]]
    time = 1000,
    delay = 1000,        
    iterations = 0,    
    transition = easing.inSine,    
    tag = "tag1",    
    onStart = function(target) print("onStart") end,    
    onComplete = function(target) print("onComplete") end,
    onPause = function(target) print("onComplete") end,    
    onResume = function(target) print("onResume") end,
    onCancel = function(target) print("onCancel") end,    
    
    -- onRepeat will be called BETWEEN EACH iteration, except for the last one.
    -- It will be exectued AFTER iterationDelay, just when a new iteration is started.
    --
    -- Accepts transition params as a second param, to allow params to be changed between iterations.
    -- Note that only transition specific params can (or should) be changed this way. For example, changing params.time will have no effect.
    onRepeat = function(target, params) print("onRepeat") end,    
    
    --[[
    
    transition2 specific params below
    
    --]]    
    
    -- iterationDelay will only occur between iterations, i.e. not before the first iteration or after the last iteration.
    iterationDelay = 500,
    
    -- onIterationStart will be called BEFORE EACH iteration, including the first one.
    -- It will be executed AFTER iterationDelay, just when a new iteration is started.
    -- Like onRepeat, it accepts transition params as a second param, to allow params to be changed between iterations.
    onIterationStart = function(target, params) print("onIterationStart") end,
    
    -- onIterationComplete will be called AFTER EACH iteration, including the last one.
    -- It will be executed BEFORE iterationDelay, just when an iteration is completed.
    -- Like onRepeat and onIterationStart, it accepts transition params as a second param, to allow params to be changed between iterations.
    onIterationComplete = function(target, params) print("onIterationComplete") end,
    
    -- Setting reverse = true makes the transition reverse back to its start value after the end value is reached
    reverse = true,
    
    -- Optionally, a separate transition algorithm can be used for the reverse part of the transition cycle.
    transitionReverse = easing.outQuint,
    
    -- If cancelWhen is set it will be called on every frame and when it returns true the transition will be automatically cancelled.
    cancelWhen = function()
        return (shouldCancel == true)
    end
})

--[[
Some of the functions from the original transition library have been overridden (see next section for complete list).
The overriding functions offer the same basic parameter list as the overridden ones,
so you can use them exactly like you did with the original transition library.

The transition functions that have not yet been overridden (e.g. dissolve/fadeIn/fadeOut)
are completely unaffected by transition2.
--]]
local transitionTo = transition.to(displayObject, {
    transition = easing.continuousLoop,
    time = 1000,
    y = displayObject.y - 100,
    iterations = 0,    
    tag = "tag2",
})

--[[
pause(), resume() and cancel() have been overriden in transition2
but they should work just like they do in the original transition library
--]]

timer.performWithDelay(2000, function()
    -- Pause all transitions using tags
    transition.pause("tag1")
    transition.pause("tag2")
    
    timer.performWithDelay(2000, function()
        -- Resume all transitions
        transition.resume()
    end)
end)

timer.performWithDelay(10000, function() 
    -- This will auto-cancel the color transition
    shouldCancel = true
    
    -- Manually cancel a specific transition ref
    transition.cancel(transitionTo)
end)
```
## Overridden transition functions
The following functions overrides the transition functions of the original transition library. The goal is for each of them to behave exactly like the corresponding function in the transition library and offer the same list of parameters. That way, the transition library can be exchanged with transition2 without any code changes.

The reason for overriding instead of just forwarding the function calls is that the overriding functions can be equipped with additional functionality.

Each overriding function will in addition to the overridden function's parameters also offer the transition2 specific parameters listed in the basic usage example above. For example, when calling transition.to() you'll be able to use parameters like reverse, transitionReverse, onIterationStart and onIterationComplete.

The overriding functions also implement automatic transition cancelling. For example, each to() transition for a display object will be cancelled as soon as the display object has been removed. No need to keep track of transition refs and cancel them manually!

This auto-cancel functionality can easily be verified like this:

```lua
transition.blink(displayObject, {
    time = 1000,
    onCancel = function() print("blink was cancelled.") end
})
timer.performWithDelay(3000, function() displayObject:removeSelf() end)
```

### blink()
Blinks a display object in and out over a specified time, repeating indefinitely.

Overrides: [https://docs.coronalabs.com/api/library/transition/blink.html](https://docs.coronalabs.com/api/library/transition/blink.html)

```lua
transition.blink(displayObject, {
    time = 500 -- Default = 1000
})
```

### to()

Animates (transitions) a display object using an optional easing algorithm. Use this to move, rotate, fade, or scale an object over a specific period of time.

Overrides: [https://docs.coronalabs.com/api/library/transition/to.html](https://docs.coronalabs.com/api/library/transition/to.html)

```lua
transition.to(displayObject, {
    time = 1000,
    x = 200,
    y = -200,
    delta = true,
    iterations = 0,
    reverse = true,
    transition = easing.inSine,
    transitionReverse = easing.outSine    
})

-- Transitioning a RectPath
transition.to(anotherDisplayObject.path, {
    x1 = 100,
    y1 = -100,
    x4 = -100,
    y4 = 100,
    time = 1000
})    
```

## New transition functions

TODO: Full parameter references will be added later... For now, see the examples or view the source code for each transition for details. All examples assume that you've overriden the default transition library through:

```lua
local transition = require("transition2")
```

### bounce()
Bounces a display object.

```lua
transition.bounce(displayObject, { 
    height = 400, -- Set to negative value to bounce downwards
    time = 1000,        
    iterations = 0,
})
```

### color()
Transitions the fill and/or stroke color of a display object smoothly from one color to another.

```lua
transition.color(displayObject, {
    startColor = {1, 1, 0, 1}, -- Yellow
    endColor = {1, 0, 0, 1}, -- Red
    time = 500,
    stroke = true, -- Enable stroke color fade
    fill = false, -- Disable fill color fade
    reverse = true, -- Will fade back from endColor to startColor when done
    iterations = 0, -- Repeat forever    
})
```

### glow()
A convenience function that uses the color() transition to create a glowing effect.

```lua
transition.glow(displayObject, {
    startColor = {1, 1, 0, 1}, -- Yellow
    endColor = {1, 0, 0, 1}, -- Red
    time = 1000,
    stroke = true, -- Enable stroke color glow
    fill = false, -- Disable fill color glow
})
```

### moveBungy()
Moves a display object using a "bungy strech" effect in x and/or y direction. Requires the target display object to have a path with four nodes ((x1, y1), ..., (x4, y4)), like images and rects.

```lua
transition.moveBungy(displayObject, {
    time = 750,
    offsetY = 200,
    offsetX = 0,    
    iterations = 0,    
    iterationDelay = 100,
})
```

### moveSine()
Moves a display object along a sine wave path. Radius can be specified for the x axis, y axis, or both. Combine one moveSine() transition for the x axis with one for the y axis to make your display object move in more complex patterns.

```lua
transition.moveSine(displayObject, {
    radiusX = 400,
    radiusY = 200,
    time = 5000,
    startDegreesX = 180,
    startDegreesY = 90,
})
```

### zRotate()
Rotates a display object in the z dimension, either horizontally or vertically.
Requires the target display object to have a path with four nodes ((x1, y1), ..., (x4, y4)), like images and rects.

```lua
transition.zRotate(displayObject, {
    degrees = 360,
    time = 2000,
    iterations = 0,    
    transition = easing.inOutSine,
    reverse = true,  
    perspective = 0.25, -- A value between 0-1. Defaults to 0.5.
    horizontal = true, -- Set to true for horizontal rotation (around the y axis). Default is vertical rotation (around the x axis)
    disableStrokeScaling = true, -- Set to true to disable scaling of strokes. Defaults is false, i.e. strokes are scaled.
})
```

## Creating custom transitions
To implement your own custom transition, see **transition2-template.lua** and already implemented transitions like **transition2-color.lua** and **transition2-bounce.lua**.

Then expose your transition function by including it in **transition2.lua**.

The file **transition2-main.lua** is the main algorithm for the transition2 library and should *NOT* be touched when implementing custom transitions.
