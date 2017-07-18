# What is transition2?

**transition2 is a full rewrite of the [Corona transition library](https://docs.coronalabs.com/api/library/transition/index.html)**. It replicates every function of the transition library and also includes a set of new transition functions, such as color(), moveSine() and zRotate(). A number of new parameters have also been introduced together with an easy way to auto-cancel transitions that are no longer valid. Last but not least, transition2 can be easily extended with your own custom transition functions. Unleash your imagination. :-)

The current documentation is rather brief, but go ahead and have a look at the source code for better understanding, it's fairly well commented.

You can also check out [this topic in the Corona forums](https://forums.coronalabs.com/topic/69305-transition2-a-customizable-extension-to-the-transition-library/) to see some live examples, make feature requests, report bugs, or just let me know what you think about transition2. Thanks!

## Installing

Clone corona-transition2 and place **transition2.lua** and the entire **transition2lib** folder at the root of your Corona project.

**NOTE!** If you're not placing transition2 directly at the root of your Corona project, make sure to change the require statements in **transition2.lua**, and probably also in most Lua files in the transition2lib folder...

Require transition2 into a local variable to have full control of which transition2 functions to use, like this:

```lua
-- In some Lua file:
local transition2 = require("transition2")
transition2.to(...)
transition2.moveSine(...)

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

There is currently no version handling at all, and breaking changes can be pushed to master branch at any time without notice. So make sure to test your code well in case you decide to replace your current version of transition2 with the latest one.

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
    
    -- Setting recalculateOnIteration=true forces start/end values to be recalculated before each iteration starts.
    -- This is necessary to be able to change properties on the target object or to change the params between iterations,
    -- for properties that affect how the transition plays out.
    -- Otherwise any changes made will be overwritten by the precalculated transition values at the start of each iteration.
    -- Default is false, to make functions like to() behave like its legacy counterpart where values are not recalculated between iterations.
    -- See onIterationStart below for example usage.
    recalculateOnIteration = true,
    
    -- onIterationStart will be called BEFORE EACH iteration, including the first one.
    -- It will be executed AFTER iterationDelay, just when a new iteration is started.
    -- Like onRepeat, it accepts transition params as a second param, to allow params to be changed between iterations.
    onIterationStart = function(target, params)
        -- Change the endColor
        -- Note! This requires that recalculateOnIteration=true (see above), or else the change will have no effect
        -- since the startColor/endColor values have already been precalculated when the transition first started.
        params.endColor = { math.random(), math.random(), math.random(), 1 }
        
        -- Randomize if we should apply transition to either stroke or fill for each iteration. Also randomize the stroke width.
        -- These changes can be done without setting recalculateOnIteration=true,
        -- because none of stroke/fill/strokeWidth directly affect the values in transition (which are only startColor/endColor).
        params.stroke = (math.random(1, 2) == 1)
        params.fill = not params.stroke
        target.strokeWidth = math.random(1, 10)
    end,
    
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
Every function of the original transition library has been replicated in transition2.
Each function offers the same basic parameter list,
so you can use them exactly like you did with the original transition library.
--]]
local transitionTo = transition.to(displayObject, {
    transition = easing.continuousLoop,
    time = 1000,
    y = displayObject.y - 100,
    iterations = 0,    
    tag = "tag2",
})

--[[
pause(), resume() and cancel() have also been implemented in transition2
to work just like they do in the original transition library.
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
## Replicated legacy functions
Every transition function of the original transition library has been replicated by a new transition2 implementation. The goal is for each of them to behave exactly like the corresponding function in the transition library and offer the same list of parameters. That way, the transition library can be exchanged with transition2 without any code changes.

The reason for implementing new functions instead of just forwarding the function calls to the transition library is that the new transition2 functions can be equipped with additional parameters and functionality.

Each replicated legacy function will offer all of the transition2 specific parameters listed in the basic usage example above. For example, when calling transition2.to() you'll be able to use parameters like reverse, transitionReverse, onIterationStart and onIterationComplete.

The transition2 functions also implement automatic transition cancelling. For example, each to() transition for a display object will be cancelled as soon as the display object has been removed. No need to keep track of transition refs and cancel them manually!

The auto-cancel functionality can be easily verified like this:

```lua
transition.blink(displayObject, {
    time = 1000,
    onCancel = function() print("blink was cancelled.") end
})
timer.performWithDelay(3000, function() displayObject:removeSelf() end)
```

### blink()
Blinks a display object in and out over a specified time, repeating indefinitely.

Replaces: [https://docs.coronalabs.com/api/library/transition/blink.html](https://docs.coronalabs.com/api/library/transition/blink.html)

```lua
transition.blink(displayObject, {
    time = 500 -- Default = 1000
})
```

### cancel()
The transition.cancel() function will cancel one of the following, depending on the passed parameter:
* All transitions in progress, when called with no parameters.
* A specific transition, when called with a transition reference.
* All transitions on a specific display object, when called with a display object reference.
* All transitions with a specific tag, when called with a string parameter representing a tag.

Replaces: [https://docs.coronalabs.com/api/library/transition/cancel.html](https://docs.coronalabs.com/api/library/transition/cancel.html)

### dissolve()

Performs a dissolve transition between two display objects.

Replaces: [https://docs.coronalabs.com/api/library/transition/dissolve.html](https://docs.coronalabs.com/api/library/transition/dissolve.html)

Syntax:
```lua
transition.dissolve( object1, object2, time, delay )
```

**Note!** dissolve() does not support the new transition2 params like reverse, onIterationStart, cancelWhen etcetera. This because it is totally different to all other transition functions and doesn't even accept a params object as parameter. It has only been implemented in transition2 for backwards compatibility with the transition library in case the dependency between transition2 and transition is cut.

### fadeIn()

Fades an object to alpha of 1.0 over the specified time.

Replaces: [https://docs.coronalabs.com/api/library/transition/fadeIn.html](https://docs.coronalabs.com/api/library/transition/fadeIn.html)

### fadeOut()

Fades an object to alpha of 0.0 over the specified time.

Replaces: [https://docs.coronalabs.com/api/library/transition/fadeOut.html](https://docs.coronalabs.com/api/library/transition/fadeOut.html)

### from()

Similar to transition.to() except that the starting property values are specified in the parameters table and the final values are the corresponding property values of the object prior to the call.

Replaces: [https://docs.coronalabs.com/api/library/transition/from.html](https://docs.coronalabs.com/api/library/transition/from.html)

### moveBy()

Moves an object by the specified x and y coordinate amount over a specified time.

Replaces: [https://docs.coronalabs.com/api/library/transition/moveBy.html](https://docs.coronalabs.com/api/library/transition/moveBy.html)

### moveTo()

Moves an object to the specified x and y coordinate amount over a specified time.

Replaces: [https://docs.coronalabs.com/api/library/transition/moveTo.html](https://docs.coronalabs.com/api/library/transition/moveTo.html)

### pause()

The transition.pause() function pauses one of the following, depending on the passed parameter:
* All transitions in progress, when called with no parameters.
* A specific transition, when called with a transition reference.
* All transitions on a specific display object, when called with a display object reference.
* All transitions with a specific tag, when called with a string parameter representing a tag.

Replaces: [https://docs.coronalabs.com/api/library/transition/pause.html](https://docs.coronalabs.com/api/library/transition/pause.html)

### resume()

The transition.resume() function resumes one of the following, depending on the passed parameter:
* All paused transitions, when called with no parameters.
* A specific paused transition, when called with a transition reference.
* All paused transitions on a specific display object, when called with a display object reference.
* All paused transitions with a specific tag, when called with a string parameter representing a tag.

Replaces: [https://docs.coronalabs.com/api/library/transition/resume.html](https://docs.coronalabs.com/api/library/transition/resume.html)

### scaleBy()

Scales an object by the specified xScale and yScale amounts over a specified time.

Replaces: [https://docs.coronalabs.com/api/library/transition/scaleBy.html](https://docs.coronalabs.com/api/library/transition/scaleBy.html)

### scaleTo()

Scales an object to the specified xScale and yScale amounts over a specified time.

Replaces: [https://docs.coronalabs.com/api/library/transition/scaleTo.html](https://docs.coronalabs.com/api/library/transition/scaleTo.html)

### to()

Animates (transitions) a display object using an optional easing algorithm. Use this to move, rotate, fade, or scale an object over a specific period of time.

Replaces: [https://docs.coronalabs.com/api/library/transition/to.html](https://docs.coronalabs.com/api/library/transition/to.html)

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

-- OR override global transition

transition = require("transition2")
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
### fallingLeaf()

A complex convenience function that makes a display object fall from it's current position towards the bottom of the screen in gentle, randomized sinus wave patterns. Trying to imitate the movement of a falling leaf blowing in the wind.

NOTE! Does not return a transition handle, so you have to use the tag param if you want to be able to control a single fallingLeaf transition with pause/cancel/resume.

```lua
transition.fallingLeaf(displayObject, {
    delay = 500, -- Initial delay in ms. Default = 0.
    speed = 0.25, -- A value between 0-1. Default = 0.5.
    verticalIntensity = 0.75, -- A value between 0-1. Default = 0.5.
    horizontalIntensity = 0.75, -- A value between 0-1. Default = 0.5.    
    
    horizontalDirection, = One of {"alternate", "right", "left", "random" }. Default = "alternate".
    
    randomness = 0.75, -- A value between 0-1. A larger value means more randomness. Default = 0.5.
    
    rotate = false, -- Default = true. Applies rotation to the object.
    zRotate = false, -- Default = true. Applies zRotate transition with specified zRotateParams.
    rotationIntensity = 0.75, -- A value between 0-1. Default = 0.5. Applies to both 2d rotation and zRotate.
    zRotateParams = {
        -- The parameters below are the only ones from zRotate that can be customized.
        -- For default values and usage, see zRotate() docs.
        shading = true, -- Default = true
        shadingDarknessIntensity = 0.5,
        shadingBrightnessIntensity = 1,
        perspective = 0.5,
        disableStrokeScaling = true,
    },    
    
    tag = "leaf",
    
    cancelWhen = function() (leaf.y > (display.contentHeight + leaf.height)) end,
    
    onStart = function(target) print("onStart") end,    
    onPause = function(target) print("onComplete") end,    
    onResume = function(target) print("onResume") end,
    onCancel = function(target) print("onCancel") end,
    
    -- NOTE! The following params are NOT supported
    -- onComplete
    -- onIterationStart
    -- onIterationComplete
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
### waterBalloon()
Transforms the xScale and yScale of a display object back and forth repeatedly,
to create an effect similar to that of a water balloon changing shape. 

```lua
transition.waterBalloon(displayObject, {
    time = 500,
    intensity = 0.4 -- A value between 0-1. Default = 0.25.
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
    shading = true, -- Applies a shading effect as the object rotates away
    shadingDarknessIntensity = 0.75, -- A value between 0-1. Default = 1. Requires shading=true.
    shadingBrightnessIntensity = 0.25, -- A value between 0-1. Default = 0. Requires shading=true.
    static = false, -- Optional, default = false. Set to true to apply final rotation immediately without doing an actual transition. If static=true, params like time, iterations etcetera have no effect.
})
```

## Creating custom transitions
To implement your own custom transition, see **transition2-template.lua** and already implemented transitions like **transition2-color.lua** and **transition2-bounce.lua**.

Then expose your transition function by including it in **transition2.lua**.

The file **transition2-main.lua** is the main algorithm for the transition2 library and should *NOT* be touched when implementing custom transitions.
