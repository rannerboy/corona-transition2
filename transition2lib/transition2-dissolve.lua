return function(transition2)
    return function (obj1, obj2, time, delay)        
        local defaultTime = 1000        
        
        transition2.fadeOut(obj1, {
            time = time or defaultTime,
            delay = delay,
            onStart = function()
                obj1.alpha = 1
            end
        }) 
        transition2.fadeIn(obj2, {
            time = time or defaultTime,
            delay = delay,
            onStart = function()
                obj2.alpha = 0
            end
        }) 
    end
end