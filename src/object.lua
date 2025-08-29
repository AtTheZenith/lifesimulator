local const = require 'src.const'

---@class object
---@field destroyed boolean
---@field x number
---@field y number
---@field size number
---@field truesize number
---@field image love.Image
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
  new.destroyed = false
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
  love.graphics.draw(self.image, self.x, self.y, 0)
end

---Disables draw function and flags the object as destroyed.
function object:destroy()
  self.destroyed = true
  self.draw = function() end
end

return object
