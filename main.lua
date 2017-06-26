local transition = require("transition2")

display.setStatusBar(display.HiddenStatusBar)

local white = {1, 1, 1, 1}
local orange = {1, 0.5, 0, 1}

local coronaLogo = display.newImageRect("corona.png", 458, 144)
coronaLogo:setFillColor(unpack(orange))
coronaLogo.x = display.contentCenterX
coronaLogo.y = display.contentHeight - coronaLogo.height/2

transition.glow(coronaLogo, {
    startColor = white,
    endColor = orange,
    time = 2000,
})
transition.bounce(coronaLogo, {
    height = display.contentHeight - 300,
    time = 2000,
    iterations = 0,
})
transition.to(coronaLogo, {
    rotation = 360,    
    time = 2000,
    iterations = 0,
})
transition.to(coronaLogo, {
    xScale = 2.5,    
    yScale = 2.5,    
    transition = easing.continuousLoop,
    time = 2000,
    iterations = 0,
})