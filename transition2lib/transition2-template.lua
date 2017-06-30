return {
    --[[
    @param target The target object for the transition, for example a display object
    @param params The params that were
    @return A single numberic value or a table of numberic values to represent the starting point for the transition.
    --]]
    getStartValue = function(target, params)             
    end,

    --[[
    @param target The target object for the transition, for example a display object
    @return A single numeric value or a table of numeric values to represent the end value for the transition. Must return the same data type as getStartValue()
    --]]
    getEndValue = function(target, params)        
    end,

    --[[
    @param target The target object for the transition, for example a display object
    @param params The transition params
    @param value Will have the same format that is returned from getStartValue() and getEndValue(), i.e. a single numeric value or a table of numeric values
    This function will be called for each new interpolated value during the transition. This is where you can modify your target object by setting properties or calling methods.    
    @param isReverseCycle true if transition is currently running in reverse cycle, false otherwise. Makes it possible to create different target behavior for normal/reverse part of transition cycle.
    --]]
    onValue = function(target, params, value, isReverseCycle)        
    end,
 
    --[[
    Overrides the params passed into the transition function by hard coding or calculating new param values.
    If no params need to be overridden, just return params as is.
    This function is only called at the beginning of the transition to get initial parameters.
    @param target The target object for the transition, for example a target object
    @return A params table
    --]]
    getParams = function(target, params)        
    end,

    --[[
    Optional.
    
    Cancel the transition when som specific conditions have been met.
    Return true if transition should be cancelled, false otherwise.
    This is mostly useful for transitions that loop for many iterations or forever (iterations == 0)
    --]]
    cancelWhen = function(target, params)
    end
}