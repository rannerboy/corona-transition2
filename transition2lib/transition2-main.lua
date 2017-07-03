--[[
This is the main algorithm for the transition2 library.
Should NOT be altered when just implementing new custom transition functions.

Markus Ranner 2017
--]]

-- The transition2 module that will be populated with functions
local transition2 = {}

-- Keep a table of references to all ongoing extended transitions, grouped by tag to make it easy to pause/resume/cancel all transitions for a specific tag
local transitionsByTag = {
    untagged = {} -- All transitions that are not tagged
}

local function cleanUpTransition(transitionRef)
    if (transitionRef) then
        if (transitionRef.enterFrameListener) then
            Runtime:removeEventListener("enterFrame", transitionRef.enterFrameListener)
        end
        -- Unset cross reference
        if (transitionRef.target and transitionRef.target.transitionRefs) then
            transitionRef.target.transitionRefs[transitionRef] = nil
        end
        -- Unset reference in table indexed by tag
        if (transitionsByTag[transitionRef.tag]) then
            transitionsByTag[transitionRef.tag][transitionRef] = nil
        end
    end
end

local function calculateParams(transitionExtension, params)
    if (transitionExtension.getParams) then  
        -- We also allow params to be a function to be able to recalculate params between iterations
        if (type(params) == "function") then            
            return transitionExtension.getParams(target, params())
        else
            return transitionExtension.getParams(target, params)
        end
    else 
        return params
    end
end

local function doExtendedTransition(transitionExtension, target, params)
    
    -- Just fail silently if the target object is nil. Can't check for table type here because that will exclude RectPath objects
    if (target == nil) then       
        return false
    end
    
    -- Override params
    local calculatedParams = calculateParams(transitionExtension, params)
    
    -- Create a new transition reference to that will be returned from the transition extension function
    -- This reference holds a the entire config (and some state) for a transition and will be used to uniquely identify each transition
    local transitionRef = {
        isExtendedTransition = true, -- To be checked by pause/resume/cancel
        time = calculatedParams.time or 500,        
        delay = calculatedParams.delay or 0,
        iterations = calculatedParams.iterations or 1,
        iterationDelay = calculatedParams.iterationDelay or 0,
        tag = calculatedParams.tag or "untagged",
        reverse = transitionExtension.reverse or calculatedParams.reverse or false,
        enterFrameListener = nil, -- Will be set further down
        isPaused = false, -- Can be flipped by calling transition2.pause() and transition2.resume()
        target = target,
        -- Start/end values will be set every time a new iteration starts
        startValue = nil,
        endValue = nil,
        easingFunc = calculatedParams.transition or easing.linear,
        easingReverseFunc = calculatedParams.transitionReverse or calculatedParams.transition or easing.linear,
        onComplete = calculatedParams.onComplete,
        onStart = calculatedParams.onStart,
        onPause = calculatedParams.onPause,
        onResume = calculatedParams.onResume,
        onCancel = calculatedParams.onCancel,
        onRepeat = calculatedParams.onRepeat,
        onIterationStart = calculatedParams.onIterationStart,
        onIterationComplete = calculatedParams.onIterationComplete,
        cancelWhen = function()
            -- The cancelWhen function can be set both in params and in the transition config, so we check both to see if at least one is fulfilled.
            return (
                (calculatedParams.cancelWhen and calculatedParams.cancelWhen())
                or
                (transitionExtension.cancelWhen and transitionExtension.cancelWhen(target, calculatedParams))
            )
        end
    }
    
    -- Save transition reference on target object. Use ref as key for quick indexing and resetting
    -- NOTE! If target is a RectPath it will be read-only, so we must do a double nil check just because of that
    target.transitionRefs = target.transitionRefs or {}
    if (target.transitionRefs) then
        target.transitionRefs[transitionRef] = true
    end
    
    -- Save transition reference in table indexed by tag
    transitionsByTag[transitionRef.tag] = transitionsByTag[transitionRef.tag] or {}
    transitionsByTag[transitionRef.tag][transitionRef] = true    
    
    -- Keep track of which iteration is currently running
    local currentIteration = 1
    -- Keep track of which part of the cycle the transition is currently in
    local isReverseCycle = false    
    
    -- Initialize timing variables
    local lastFrameTimestamp = nil -- This will not be set until transition is actually started, after a possible delay 
    local currentTransitionTime = 0
    local totalTransitionTime = 0 -- This is used to get better timing accuracy for transitions that loop over many iterations
    
    -- Create the enter frame listener that will handle the transition and store it on the transition reference
    transitionRef.enterFrameListener = function(event)
        -- Automatically cancel the transition if some conditions have been met
        if (transitionRef.cancelWhen()) then
            cleanUpTransition(transitionRef)
            if(transitionRef.onCancel) then
                transitionRef.onCancel(transitionRef.target)
            end
            return
        end
        
        -- Calculate time since last frame and update timestamp for last frame
        local now = system.getTimer()
        local deltaTimeSinceLastFrame = (now - lastFrameTimestamp)
        lastFrameTimestamp = now
        
        -- If transition is paused we do nothing more, but the lastFrameTimestamp will still be updated so that we can 
        -- continue calculating total transition time when transition is resumed again
        if (transitionRef.isPaused) then
            return
        end
        
        currentTransitionTime = currentTransitionTime + deltaTimeSinceLastFrame
        totalTransitionTime = totalTransitionTime + deltaTimeSinceLastFrame
        
        -- We must do slightly different timing calculations depending on if transition reverse is activated or not
        local isTransitionDone = false
        if (transitionRef.reverse) then
            isTransitionDone = totalTransitionTime >= ((currentIteration * transitionRef.time * 2) - (isReverseCycle and 0 or transitionRef.time))
        else
            isTransitionDone = totalTransitionTime >= (currentIteration * transitionRef.time)
        end
        
        if (not isTransitionDone) then            
            -- Make sure to handle table values as well as single numeric values
            local nextValue = nil
            if (type(transitionRef.startValue) == "table") then
                nextValue = {}
                for k, v in pairs(transitionRef.startValue) do
                    nextValue[k] = transitionRef.easingFunc(currentTransitionTime, transitionRef.time, transitionRef.startValue[k], transitionRef.endValue[k] - transitionRef.startValue[k])
                end
            else 
                nextValue = transitionRef.easingFunc(currentTransitionTime, transitionRef.time, transitionRef.startValue, transitionRef.endValue - transitionRef.startValue)
            end
            
            -- Pass the next value(s) to the handling function of the transition implementation
            transitionExtension.onValue(target, calculatedParams, nextValue, isReverseCycle)
        else
            -- Finally, just make sure that we have reached the correct end value            
            -- We have to check a special case here, i.e. easing.continuousLoop which will end at the startValue instead of at the endValue...
            local finalValue = transitionRef.endValue
            if (transitionRef.easingFunc == easing.continuousLoop) then
                finalValue = transitionRef.startValue
            end
            transitionExtension.onValue(target, calculatedParams, finalValue, isReverseCycle)            
                           
            -- If transition should be reversed, we reverse it and start over by resetting current transition time
            if (transitionRef.reverse and not isReverseCycle) then
                isReverseCycle = true
                transitionRef.startValue, transitionRef.endValue = transitionRef.endValue, transitionRef.startValue                
                transitionRef.easingFunc, transitionRef.easingReverseFunc = transitionRef.easingReverseFunc, transitionRef.easingFunc
                currentTransitionTime = 0
            else      
                -- Make a callback at the end of each iteration
                -- This is not the same as onRepeat. onIterationComplete will be called at the end of EACH iteration, and before any iterationDelay.
                if (transitionRef.onIterationComplete) then
                    transitionRef.onIterationComplete(target, calculatedParams)
                end
                
                -- Check if we are done with our iterations
                -- Note! iterations == 0 means endless iterations
                if ((transitionRef.iterations > 0) and (currentIteration >= transitionRef.iterations)) then
                    
                    cleanUpTransition(transitionRef)
                    
                    if (transitionRef.onComplete) then
                        transitionRef.onComplete(target)
                    end
                else
                    -- Start a new iteration
                    
                    local function startNextIteration()
                        currentIteration = currentIteration + 1
                        currentTransitionTime = 0    
                        isReverseCycle = false
                        
                        -- Make callbacks if callback functions are defined
                        if (transitionRef.onRepeat) then
                            transitionRef.onRepeat(target, calculatedParams)
                        end
                        
                        -- Before starting a new iteration we must recalculate params in case target object properties have been changed by onRepeat or onIterationComplete.
                        calculatedParams = calculateParams(transitionExtension, params)
                        
                        -- Note that we must call getStartValue and getEndValue here in case onIterationComplete have modified params
                        transitionRef.startValue = transitionExtension.getStartValue(target, calculatedParams)
                        transitionRef.endValue = transitionExtension.getEndValue(target, calculatedParams)
                        
                        -- After params have been calculated we move on to start the next iteration
                        if (transitionRef.onIterationStart) then
                            transitionRef.onIterationStart(target, calculatedParams)
                        end                        
                       
                        -- If doing reverse transition we must restore some values before starting the next iteration
                        if (transitionRef.reverse) then
                            transitionRef.easingFunc, transitionRef.easingReverseFunc = transitionRef.easingReverseFunc, transitionRef.easingFunc
                        end
                    end
                                        
                    -- Delay start of next generation is specified in params
                    if (transitionRef.iterationDelay and transitionRef.iterationDelay > 0) then
                        transitionRef.isPaused = true
                        timer.performWithDelay(transitionRef.iterationDelay, function()
                            transitionRef.isPaused = false
                            startNextIteration()
                        end)
                    else
                        startNextIteration()
                    end
                end
            end
        end
    end
    
    -- Start transition
    timer.performWithDelay(transitionRef.delay, function()            
        -- First make callbacks that might affect params
        if (transitionRef.onStart) then
            transitionRef.onStart(target)
        end
        if (transitionRef.onIterationStart) then
            transitionRef.onIterationStart(target, params)
        end
        
        -- Then recalculate params
        calculatedParams = calculateParams(transitionExtension, params)
        
        -- Then get the start/end values
        transitionRef.startValue = transitionExtension.getStartValue(target, calculatedParams)
        transitionRef.endValue = transitionExtension.getEndValue(target, calculatedParams)
        
        -- Finally, attach the enter frame listener to allow the transition to start
        lastFrameTimestamp = system.getTimer()
        Runtime:addEventListener("enterFrame", transitionRef.enterFrameListener)
    end)
    
    return transitionRef
end

-- Function to cancel/pause/resume transitions
local function controlTransition(whatToControl, params)
    
    local function controlTransitionsForTag(tag) 
        if (transitionsByTag[tag]) then                
            for transitionRef,_  in pairs(transitionsByTag[tag]) do                                    
                params.controlTransitionRef(transitionRef)                
            end
        end
        
        if (params.controlTag) then
            params.controlTag(tag)
        end
    end
    
    if (whatToControl) then        
        if (whatToControl.isExtendedTransition) then
            -- This is a ref to one of our extended transitions, so we don't need to call original transition module
            params.controlTransitionRef(whatToControl)
        elseif (type(whatToControl) == "string") then
            -- A string value means that we should control all transitions for a specific tag
            local tag = whatToControl            
            controlTransitionsForTag(tag)
        else 
            -- Here we assume that we're handling a target object, so we control all transitions for that object only
            local target = whatToControl
            
            if (target.transitionRefs) then
                for _, transitionRef in pairs(target.transitionRefs) do
                    params.controlTransitionRef(target.transitionRef)
                end
            end
        end
    else
        -- Control all transitions
        for tag,_ in pairs(transitionsByTag) do
            controlTransitionsForTag(tag)
        end
    end
end

-- Override cancel
transition2.cancel = function(whatToCancel)
    controlTransition(whatToCancel, {
        controlTransitionRef = function(transitionRef)
            cleanUpTransition(transitionRef)            
            
            if(transitionRef.onCancel) then
                transitionRef.onCancel(transitionRef.target)
            end
        end,
        controlTag = function(tag)
            transitionsByTag[tag] = {}
        end,
    })    
end

-- Override pause
transition2.pause = function(whatToPause)
    controlTransition(whatToPause, {
        controlTransitionRef = function(transitionRef)
            transitionRef.isPaused = true
            if (transitionRef.onPause) then
                transitionRef.onPause(transitionRef.target)
            end
        end,
    })
end

-- Override resume
transition2.resume = function(whatToResume)    
    controlTransition(whatToResume, {
        controlTransitionRef = function(transitionRef)
            transitionRef.isPaused = false            
            if (transitionRef.onResume) then
                transitionRef.onResume(transitionRef.target)
            end
        end,
    })
end

-- Return a single function that accepts a config object 
-- The config object is parsed to set up all transitions that should be available as functions
-- See transition2.lua for example usage
return function(config) 
    for funcName, extension in pairs(config) do
        transition2[funcName] = function(target, params)
            return doExtendedTransition(extension, target, params)                
        end
    end
      
    return transition2
end
