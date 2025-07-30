local const = require 'src.const'
local helper = require 'src.helper'

---@class object
---@field x number
---@field y number
---@field size number
---@field truesize number
---@field image love.Image
---@field position fun(self: object, x: number, y: number)
local object = {}
object.__index = object

---Creates a new object to be displayed on screen.
---All the following arguments are *optional*.
---@param args {x: number?, y: number?, size: number?, image: love.Image?}? **table**  containing the following arguments:
--- `x` & `y`: **number**   The 2D position.
--- `size`: **number**      The object's size.
--- `image`: **love.image** The object's sprite.
---@return object
function object:new(args)
  args = args or {}

  local new = setmetatable({}, self)
  new.x = args.x or 0
  new.y = args.y or 0
  new.size = args.size or 1
  new.truesize = new.size * const.trueobjectsize
  new.image = const.images.object
  if args.image then
    new.image = args.image
  end

  return new
end

---Positions the object at the given *x* & *y* vectors.
---@param x number The *x* vector.
---@param y number The *y* vector.
---@overload fun(x: point)
function object:position(x, y)
  if type(x) == 'table' then
    x, y = x.x or x[1], x.y or x[2]
  end
  self.x, self.y = x, y
end

---Draws the object on the screen.
function object:draw()
  love.graphics.draw(self.image, self.x, self.y, 0, self.size, self.size)
end

return object
