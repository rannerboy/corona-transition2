return  {
    transitionFunction = "color",
    
    --[[
    Params:
        time - Optional. Time in ms for a full glow cycle (startColor->endColor->startColor). Default is 2000 ms
        startColor - Required. The start color for the glow effect { r, g, b, a }
        endColor - Required. The end color for the glow effect { r, g, b, a }
        stroke - Optional. Set to false to disable stroke glow
        fill - Optional. Set to false to disable fill glow
    --]]
    getParams = function(displayObject, params)
        params.time = (params.time ~= nil) and (params.time/2) or 1000
        params.reverse = true
        params.iterations = 0
        params.transition = easing.inOutSine
        params.transitionReverse = easing.inOutSine
        return params
    end    
}