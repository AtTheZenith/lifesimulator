local object = require 'src.classes.base.object'
local slick = require 'src.slick'

---@class barrier: object
---@field type string
local barrier = setmetatable({}, object)
barrier.__index = barrier
barrier.type = 'barrier'

---Creates a new barrier instance.
---@param args {position: vector?, size: vector?, radius: nil, image: love.Image?, world: slick.world?, bodytype: nil}?
---@return barrier
function barrier:new(args)
  args = args or {}
  args.bodytype = 'rectangle'
  local new = object.new(self, args)
  ---@cast new barrier

  return new
end

return barrier
