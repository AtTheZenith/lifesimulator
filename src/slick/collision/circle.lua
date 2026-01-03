local commonShape = require 'slick.collision.commonShape'
local transform = require 'slick.geometry.transform'

--- @class slick.collision.circle: slick.collision.commonShape
local circle = setmetatable({}, { __index = commonShape })
local metatable = { __index = circle }

--- @param entity slick.entity | slick.cache | nil
--- @param x number
--- @param y number
--- @param radius number
--- @param segments number?
--- @return slick.collision.circle
function circle.new(entity, x, y, radius, segments)
    local result = setmetatable(commonShape.new(entity), metatable)

    --- @cast result slick.collision.circle
    result:init(x, y, radius, segments)
    return result
end

--- @param x number
--- @param y number
--- @param radius number
--- @param segments number?
function circle:init(x, y, radius, segments)
    commonShape.init(self)

    local points = segments or math.max(math.floor(math.sqrt(radius * 20)), 8)
    local angleStep = (2 * math.pi) / points

    for i = 0, points - 1 do
        local angle = i * angleStep
        self:addPoints(x + radius * math.cos(angle), y + radius * math.sin(angle))
    end

    self:buildNormals()
    self:transform(transform.IDENTITY)
end

return circle
