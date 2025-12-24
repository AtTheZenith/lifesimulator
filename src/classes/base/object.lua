local const = require 'src.constants'
local vector = require 'src.classes.vector'

---@class object
---@field destroyed boolean
---@field position vector
---@field size number
---@field truesize number
---@field image love.Image
local object = {}
object.__index = object

---Creates a new object to be displayed on screen.
---All the following arguments are *optional*.
---@param args {position: vector?, size: number?, image: love.Image?}? **table**  containing the following arguments:
--- `x` & `y`: **number**   The 2D position.
--- `size`: **number**      The object's size.
--- `image`: **love.image** The object's sprite.
---@return object
function object:new(args)
  args = args or {}

  local new = setmetatable({}, self)
  local pos = args.position and args.position:clone() or vector.ZERO
  new.position = pos
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
---@param vector vector The *x* vector.
function object:setposition(vector)
  self.position = vector:clone()
end

---Returns the object's position.
---@return vector
function object:getposition() -- this is redundant oml
  return self.position:clone()
end

---Draws the object on the screen.
function object:draw()
  local x, y = self.position:get()
  love.graphics.draw(self.image, x, y)
end

---Disables draw function and flags the object as destroyed.
function object:destroy()
  self.destroyed = true
  self.draw = function() end
end

return object
