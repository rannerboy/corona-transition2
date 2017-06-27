# corona-transition2

transition2 is an extension to the [Corona transition library](https://docs.coronalabs.com/api/library/transition/index.html). It comes with a few new transition functions and can easily be extended with your own custom transition functions.

The current documentation is very brief. Have a look at the source code for better understanding, it's fairly well commented.

**NOTE!** If you're not placing transition2 directly at the root of your Corona project, make sure to change the require statements in **transition2.lua**.

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
    -- iterationDelay will occur between each iteration, but not before the first one.
    iterationDelay = 500,
    transition = easing.inSine,    
    tag = "tag1",    
    onStart = function(target) print("onStart") end,    
    onComplete = function(target) print("onComplete") end,
    onPause = function(target) print("onComplete") end,    
    onResume = function(target) print("onResume") end,
    onCancel = function(target) print("onCancel") end,    
    -- onRepeat will be called BETWEEN EACH iteration, not after the last one.
    -- It will be exectued AFTER iterationDelay, just when a new iteration is started.
    onRepeat = function(target) print("onRepeat") end,
    -- onIterationComplete will be called AFTER EACH iteration, even the last one.
    -- It will be executed BEFORE iterationDelay, just when an iteration is completed.
    onIterationComplete = function(target) print("onIterationComplete") end,
    
    --[[
    transition2 specific params
    --]]    
    
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

TODO: Examples and parameter references will be added later...

### bounce()
Bounces a display object.

### color()
Transitions the fill and/or stroke color of a display object smoothly from one color to another.

### glow()
A convenience function that uses the color() transition to create a glowing effect.

### moveSine()
Moves a display object along a sine wave path. Radius can be specified for the x axis, y axis, or both. Combine one moveSine() transition for the x axis with one for the y axis to make your display object move in more complex patterns.

### zRotate()
Rotates a display object in the z dimension, either horizontally or vertically.
Requires the target display object to have a path with four nodes ((x1, y1), ..., (x4, y4)), like images and rects.

## Creating custom transitions

To implement your own custom transition, see **transition2-template.lua** and already implemented transitions like **transition2-color.lua** and **transition2-bounce.lua**.

Then expose your transition function by including it in **transition2.lua**.

The file **transition2-main.lua** is the main algorithm for the transition2 library and should *NOT* be touched when implementing custom transitions.
