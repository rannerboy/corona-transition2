--[[
This is the main algorithm for the transition2 library.

Markus Ranner 2017
--]]
local transition = require("transition")

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
        if (transitionRef.target) then
            transitionRef.target.extTransitions[transitionRef] = nil
        end
        -- Unset reference in table indexed by tag
        if (transitionsByTag[transitionRef.tag]) then
            transitionsByTag[transitionRef.tag][transitionRef] = nil
        end
    end
end

local function doExtendedTransition(transitionExtension, target, params)
    
    -- Override params
    params = transitionExtension.getParams and transitionExtension.getParams(target, params) or params
    
    -- Get parameter values and set some default values
    local targetTransitionTime = params.time or 500
    local delay = params.delay or 0
    local iterationDelay = params.iterationDelay or 0
    local easingFunc = params.transition or easing.linear            
    local easingReverseFunc = params.transitionReverse or easingFunc
    local tag = params.tag or "untagged"    
    local iterations = params.iterations or 1     
    local reverse = transitionExtension.reverse or params.reverse or false    
    
    -- Create a new transition reference that will be returned from the transition extension function
    -- This reference will be used to uniquely identify the transition
    local transitionRef = {
        isExtendedTransition = true, -- To be checked by pause/resume/cancel
        tag = tag,
        enterFrameListener = nil, -- Will be set further down
        isPaused = false, -- Can be flipped by calling transition.pause() and transition.resume()
        target = target,
        -- Start/end values will be set every time a new iteration starts
        startValue = nil,
        endValue = nil,
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
        end
    }
    
    -- Save transition reference on target object. Use ref as key for quick indexing and resetting
    target.extTransitions = target.extTransitions or {}
    target.extTransitions[transitionRef] = true
    
    -- Save transition reference in table indexed by tag
    transitionsByTag[tag] = transitionsByTag[tag] or {}
    transitionsByTag[tag][transitionRef] = true    
    
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
        if (reverse) then
            isTransitionDone = totalTransitionTime >= ((currentIteration * targetTransitionTime * 2) - (isReverseCycle and 0 or targetTransitionTime))
        else
            isTransitionDone = totalTransitionTime >= (currentIteration * targetTransitionTime)
        end
        
        if (not isTransitionDone) then            
            -- Make sure to handle table values as well as single numeric values
            local nextValue = nil
            if (type(transitionRef.startValue) == "table") then
                nextValue = {}
                for k, v in pairs(transitionRef.startValue) do
                    nextValue[k] = easingFunc(currentTransitionTime, targetTransitionTime, transitionRef.startValue[k], transitionRef.endValue[k] - transitionRef.startValue[k])
                end
            else 
                nextValue = easingFunc(currentTransitionTime, targetTransitionTime, transitionRef.startValue, transitionRef.endValue - transitionRef.startValue)
            end
            
            -- Pass the next value(s) to the handling function of the transition implementation
            transitionExtension.onValue(target, params, nextValue)
        else
            -- Finally, just make sure that we have reached the correct end value
            transitionExtension.onValue(target, params, transitionRef.endValue)
                           
            -- If transition should be reversed, we reverse it and start over by resetting current transition time
            if (reverse and not isReverseCycle) then
                isReverseCycle = true
                transitionRef.startValue, transitionRef.endValue = transitionRef.endValue, transitionRef.startValue
                easingFunc, easingReverseFunc = easingReverseFunc, easingFunc
                currentTransitionTime = 0
            else      
                -- Make a callback at the end of each iteration
                -- This is not the same as onRepeat. onIterationComplete will be called at the end of EACH iteration, and before any iterationDelay.
                if (transitionRef.onIterationComplete) then
                    transitionRef.onIterationComplete(target, params)
                end
                
                -- Check if we are done with our iterations
                -- Note! iterations == 0 means endless iterations
                if ((iterations > 0) and (currentIteration >= iterations)) then
                    
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
                            transitionRef.onRepeat(target, params)
                        end
                        if (transitionRef.onIterationStart) then
                            transitionRef.onIterationStart(target, params)
                        end
                        
                        -- If doing reverse transition we must restore some values before starting the next iteration
                        if (reverse) then
                            -- Note that we must call getStartValue and getEndValue here in case onRepeat or onIterationComplete have modified params
                            transitionRef.startValue = transitionExtension.getStartValue(target, params)
                            transitionRef.endValue = transitionExtension.getEndValue(target, params)
                            
                            easingFunc, easingReverseFunc = easingReverseFunc, easingFunc
                        end
                    end
                                        
                    -- Delay start of next generation is specified in params
                    if (iterationDelay and iterationDelay > 0) then
                        transitionRef.isPaused = true
                        timer.performWithDelay(iterationDelay, function()
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
    timer.performWithDelay(delay, function()            
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
            params.oldControlFunc(whatToControl)
        else 
            -- Here we assume that we're handling a target object, so we control all transitions for that object only
            local target = whatToControl
            
            if (target.extTransitions) then
                for _, transitionRef in pairs(target.extTransitions) do
                    params.controlTransitionRef(target.transitionRef)
                end
            end
            
            params.oldControlFunc(target)
        end
    else
        -- Control all transitions
        for tag,_ in pairs(transitionsByTag) do
            controlTransitionsForTag(tag)
        end
        params.oldControlFunc()
    end
end

-- Override existing cancel function
local oldCancel = transition.cancel
transition.cancel = function(whatToCancel)
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
        oldControlFunc = oldCancel
    })    
end

-- Override pause
local oldPause = transition.pause
transition.pause = function(whatToPause)
    controlTransition(whatToPause, {
        controlTransitionRef = function(transitionRef)
            transitionRef.isPaused = true
            if (transitionRef.onPause) then
                transitionRef.onPause(transitionRef.target)
            end
        end,
        oldControlFunc = oldPause
    })
end

-- Override resume
local oldResume = transition.resume
transition.resume = function(whatToResume)    
    controlTransition(whatToResume, {
        controlTransitionRef = function(transitionRef)
            transitionRef.isPaused = false            
            if (transitionRef.onResume) then
                transitionRef.onResume(transitionRef.target)
            end
        end,
        oldControlFunc = oldResume
    })
end

-- Return a single function that accepts a config object 
-- The config object is parsed to set up all transitions that should be available as functions
-- See transition2.lua for example usage
return function(config) 
    for funcName, extension in pairs(config) do
        transition[funcName] = function(target, params)
            if (extension.transitionFunction) then               
                -- Convenience functions, so we just call an existing transition function with modified params
                return transition[extension.transitionFunction](target, extension.getParams(target, params))
            else                             
                return doExtendedTransition(extension, target, params)                
            end
        end
    end
        
    return transition
end
