# corona-transition2

transition2 is an extension to the [Corona transition library](https://docs.coronalabs.com/api/library/transition/index.html). It comes with a few new transition functions and can easily be extended with your own custom transition functions.

The current documentation is very brief. Have a look at the source code for better understanding, it's fairly well commented.

**NOTE!** If you're not placing transition2 directly at the root of your Corona project, make sure to change the require statements in **transition2.lua**.

## Important note

Please note that transition2 is work in progress. There might be bugs, performance can likely be improved, and the number of new transition functions to choose from is still very limited.

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
We can still call the original transition functions.
They are completely unaffected by transition2.
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

## Transition functions

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
