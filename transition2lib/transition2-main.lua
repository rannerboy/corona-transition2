--[[
This is the main algorithm for the transition2 library.
Should NOT be altered when just implementing new custom transition functions.

Markus Ranner 2017
--]]
local utils = require("transition2lib.utils")

-- The transition2 module that will be populated with functions
local transition2 = {}

local enterFrameListener = nil

-- Keep a table of references to all ongoing extended transitions, grouped by tag to make it easy to pause/resume/cancel all transitions for a specific tag
local transitionsByTag = {
    untagged = {} -- All transitions that are not tagged
}
-- A simple array of all ongoing transitions, for performance reasons
local transitions = {}

-- A "lock variable" used when adding or removing transitions from state
local locked = false

local addTransition
addTransition = function(transitionRef)
    if (not locked) then
        locked = true
    
        transitionsByTag[transitionRef.tag] = transitionsByTag[transitionRef.tag] or {}
        transitionsByTag[transitionRef.tag][transitionRef] = true    
        transitions[#transitions + 1] = transitionRef
        
        locked = false
    else
        -- Try again shortly...
        timer.performWithDelay(20, function() addTransition(transitionRef) end)
    end
end

local function cleanUpTransition(transitionRef)
    if (transitionRef) then
        -- Immediately flag transition as cancelled so that it won't be processed anymore by the enter frame listner
        transitionRef.isCancelled = true
        
        -- Then wait for lock to be available before actually doing the cleaning up
        local removeTransition
        removeTransition = function()
            if (not locked) then
                locked = true
                
                -- Unset cross reference from target->transitionRef
                if (transitionRef.target and transitionRef.target.transitionRefs) then
                    transitionRef.target.transitionRefs[transitionRef] = nil
                end
                
                -- Unset reference in table indexed by tag                                
                if (transitionsByTag[transitionRef.tag]) then
                    transitionsByTag[transitionRef.tag][transitionRef] = nil
                end                
                
                -- Note! Removal from the transitions array is done by the enter frame listener when it traverses the array and finds cancelled transitions
                -- Can't do it here without looping through the array which would be inefficient.
                
                locked = false
            else
                -- Try again shortly...
                timer.performWithDelay(20, removeTransition)
            end
        end
        removeTransition()
    end
end

local function getNextValue(transitionRef)
    local nextValue = nil
    if (type(transitionRef.startValue) == "table") then
        nextValue = {}
        for k, v in pairs(transitionRef.startValue) do
            nextValue[k] = transitionRef.easingFunc(transitionRef.currentTransitionTime, transitionRef.time, transitionRef.startValue[k], transitionRef.endValue[k] - transitionRef.startValue[k])
        end
    else 
        nextValue = transitionRef.easingFunc(transitionRef.currentTransitionTime, transitionRef.time, transitionRef.startValue, transitionRef.endValue - transitionRef.startValue)
    end
    return nextValue
end

-- This is the function that will be called on each frame for each transition
local transitionHandler = function(transitionRef)
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
    local deltaTimeSinceLastFrame = (now - transitionRef.lastFrameTimestamp)
    transitionRef.lastFrameTimestamp = now
    
    -- If transition is paused we do nothing more, but the lastFrameTimestamp will still be updated so that we can 
    -- continue calculating total transition time when transition is resumed again
    if (transitionRef.isPaused) then
        return
    end
    
    transitionRef.currentTransitionTime = transitionRef.currentTransitionTime + deltaTimeSinceLastFrame
    transitionRef.totalTransitionTime = transitionRef.totalTransitionTime + deltaTimeSinceLastFrame
    
    -- We must do slightly different timing calculations depending on if transition reverse is activated or not
    local isTransitionDone = false
    if (transitionRef.reverse) then
        isTransitionDone = transitionRef.totalTransitionTime >= ((transitionRef.currentIteration * transitionRef.time * 2) - (transitionRef.isReverseCycle and 0 or transitionRef.time))
    else
        isTransitionDone = transitionRef.totalTransitionTime >= (transitionRef.currentIteration * transitionRef.time)
    end
    
    if (not isTransitionDone) then            
        -- Make sure to handle table values as well as single numeric values
        local nextValue = getNextValue(transitionRef)        
        
        -- Pass the next value(s) to the handling function of the transition implementation
        transitionRef.transitionExtension.onValue(transitionRef.target, transitionRef.params, nextValue, transitionRef.isReverseCycle)
        if (transitionRef.onValue) then
            transitionRef.onValue(transitionRef.target, nextValue)
        end
    else
        -- Finally, just make sure that we have reached the correct end value            
        -- We have to check a special case here, i.e. easing.continuousLoop which will end at the startValue instead of at the endValue...
        local finalValue = transitionRef.endValue
        if (transitionRef.easingFunc == easing.continuousLoop) then
            finalValue = transitionRef.startValue
        end
        transitionRef.transitionExtension.onValue(transitionRef.target, transitionRef.params, finalValue, transitionRef.isReverseCycle)            
        if (transitionRef.onValue) then
            transitionRef.onValue(transitionRef.target, finalValue)
        end
                       
        -- If transition should be reversed, we reverse it and start over by resetting current transition time
        if (transitionRef.reverse and not transitionRef.isReverseCycle) then
            transitionRef.isReverseCycle = true
            transitionRef.startValue, transitionRef.endValue = transitionRef.endValue, transitionRef.startValue
            transitionRef.easingFunc, transitionRef.easingReverseFunc = transitionRef.easingReverseFunc, transitionRef.easingFunc
            transitionRef.currentTransitionTime = 0
        else      
            -- Make a callback at the end of each iteration
            -- This is not the same as onRepeat. onIterationComplete will be called at the end of EACH iteration, and before any iterationDelay.
            if (transitionRef.onIterationComplete) then
                transitionRef.onIterationComplete(transitionRef.target, transitionRef.params)
            end
            
            -- Check if we are done with our iterations
            -- Note! iterations == 0 means endless iterations
            if ((transitionRef.iterations > 0) and (transitionRef.currentIteration >= transitionRef.iterations)) then
                
                cleanUpTransition(transitionRef)
                
                if (transitionRef.onComplete) then
                    transitionRef.onComplete(transitionRef.target)
                end
            else
                -- Start a new iteration
                
                local function startNextIteration()
                    transitionRef.currentIteration = transitionRef.currentIteration + 1
                    transitionRef.currentTransitionTime = 0    
                    transitionRef.isReverseCycle = false
                    
                    -- Make callbacks if callback functions are defined
                    if (transitionRef.onRepeat) then
                        transitionRef.onRepeat(transitionRef.target, transitionRef.params)
                    end
                    if (transitionRef.onIterationStart) then
                        transitionRef.onIterationStart(transitionRef.target, transitionRef.params)
                    end
                    
                    -- We check to see if we should recalculate start/end values in case any of the onX functions have made changes to data that affects param calculations, or direct changes to the params themselves.
                    -- Not that recalculateOnIteration = true must be explicitly set. This is because of legacy reasons, for example to make the to() rewrite behave lite the original to() function.
                    if (transitionRef.params.recalculateOnIteration) then
                        transitionRef.startValue = transitionRef.transitionExtension.getStartValue(transitionRef.target, transitionRef.params)
                        transitionRef.endValue = transitionRef.transitionExtension.getEndValue(transitionRef.target, transitionRef.params)
                    elseif (transitionRef.reverse) then     
                        -- If we haven't already recalculated start/end values, we must switch them back if we're completing a reverse transition
                        transitionRef.startValue, transitionRef.endValue = transitionRef.endValue, transitionRef.startValue
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

enterFrameListener = function(event) 
    -- Wait for lock to be released and then acquire it asap
    while (locked) do
    end
    locked = true
    
    -- Loop backwards to be able to remove cancelled transitions
    for i = #transitions, 1, -1 do
        local t = transitions[i]
        if (t.isCancelled) then
            table.remove(transitions, i)
        elseif (t.isStarted) then
            transitionHandler(t)
        end
    end
    
    locked = false
end

Runtime:addEventListener("enterFrame", enterFrameListener)

local function doExtendedTransition(transitionExtension, target, params)
    
    -- Just fail silently if the target object is nil. Can't check for table type here because that will exclude RectPath objects
    if (target == nil) then       
        return false
    end
    
    -- Override params
    -- We make a copy of the table to avoid weird side effects if the params table is modified by the getParams() function
    params = utils.copyTable(params)
    if (transitionExtension.getParams) then
        params = transitionExtension.getParams(target, params)
    end    
    
    -- Create a new transition reference to that will be returned from the transition extension function
    -- This reference holds a the entire config (and some state) for a transition and will be used to uniquely identify each transition
    local transitionRef = {
        isExtendedTransition = true, -- To be checked by pause/resume/cancel
        transitionExtension = transitionExtension,
        params = params, -- We need to keep a reference to the params object to pass it on to the onX functions from the global enter frame listener
        time = params.time or 500,        
        delay = params.delay or 0,
        iterations = params.iterations or 1,
        iterationDelay = params.iterationDelay or 0,
        tag = params.tag or "untagged",
        reverse = transitionExtension.reverse or params.reverse or false,
        isPaused = false, -- Can be flipped by calling transition2.pause() and transition2.resume()
        isStarted = false, -- Will be set to true after initial setup and possible delay
        target = target,
        -- Start/end values will be set every time a new iteration starts
        startValue = nil,
        endValue = nil,
        easingFunc = params.transition or easing.linear,
        easingReverseFunc = params.transitionReverse or params.transition or easing.linear,
        onValue = params.onValue,
        onComplete = params.onComplete,
        onStart = params.onStart,
        onPause = params.onPause,
        onResume = params.onResume,
        onCancel = params.onCancel,
        onRepeat = params.onRepeat,
        onIterationStart = params.onIterationStart,
        onIterationComplete = params.onIterationComplete,        
        cancelWhen = function()
            -- The cancelWhen function can be set both in params and in the transition config, so we check both to see if at least one is fulfilled.
            return (
                (params.cancelWhen and params.cancelWhen())
                or
                (transitionExtension.cancelWhen and transitionExtension.cancelWhen(target, params))
            )
        end,
        
        -- Keep track of which iteration is currently running
        currentIteration = 1,
        -- Keep track of which part of the cycle the transition is currently in
        isReverseCycle = false,    
    
        -- Initialize timing variables
        lastFrameTimestamp = nil, -- This will not be set until transition is actually started, after a possible delay 
        currentTransitionTime = 0,
        totalTransitionTime = 0, -- This is used to get better timing accuracy for transitions that loop over many iterations
    }
    
    if (params.static == true) then
        -- For static transitions, we just apply the end value immediately
        -- No actual transition will be started and handled by the enter frame listener.
        timer.performWithDelay(transitionRef.delay, function()            
            local endValue = transitionExtension.getEndValue(target, params)
            transitionExtension.onValue(target, params, endValue, false)
            if (transitionRef.onValue) then
                transitionRef.onValue(target, endValue)
            end
        end)
    else
        -- Save transition reference on target object. Use ref as key for quick indexing and resetting
        -- NOTE! If target is a RectPath it will be read-only, so we must do a double nil check just because of that
        target.transitionRefs = target.transitionRefs or {}
        if (target.transitionRefs) then
            target.transitionRefs[transitionRef] = true
        end
        
        addTransition(transitionRef)
            
        -- Start transition
        timer.performWithDelay(transitionRef.delay, function()            
            -- First make callbacks that might affect params
            if (transitionRef.onStart) then
                transitionRef.onStart(target)
            end
            if (transitionRef.onIterationStart) then
                transitionRef.onIterationStart(target, params)
            end
            
            -- Then get the start/end values
            transitionRef.startValue = transitionExtension.getStartValue(target, params)
            transitionRef.endValue = transitionExtension.getEndValue(target, params)
            
            -- Finally, flag the transition ref as started to allow shared enter frame listener to run it
            transitionRef.lastFrameTimestamp = system.getTimer()
            transitionRef.isStarted = true
        end)
    end
    
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
        -- FIXME: Test this
        for i = 1, #transitions do
            params.controlTransitionRef(transitions[i])
        end
        --[[
        for tag,_ in pairs(transitionsByTag) do            
            controlTransitionsForTag(tag)
        end
        --]]
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
