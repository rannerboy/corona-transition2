local function toRadians(degrees)
    return ((degrees % 360) * math.pi / 180)
end

local function isRectPath(obj)
    return obj and obj.path and (obj.path.x1 ~= nil) and (obj.path.y1 ~= nil) and (obj.path.x2 ~= nil) and (obj.path.y2 ~= nil) and (obj.path.x3 ~= nil) and (obj.path.y3 ~= nil) and (obj.path.x4 ~= nil) and (obj.path.y4 ~= nil)
end

return {
   toRadians = toRadians, 
   isRectPath = isRectPath,
}