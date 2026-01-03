---Minimal general-purpose inheritable class for drawing on-screen.
---Identifies as a base for all world objects (Barrier, Object, Entity).

local const = require 'src.constants'
local vector = require 'src.classes.vector'

---@class sprite
---@field destroyed boolean
---@field position vector
---@field size vector
---@field image love.Image
---@field type string
local sprite = {}
sprite.__index = sprite
sprite.type = 'sprite'

---Creates a new sprite to be displayed on screen.
---All the following arguments are *optional*.
---@param args {position: vector?, size: vector?, image: love.Image?}? **table**  containing the following arguments:
--- `position`: **vector**   The 2D position.
--- `size`: **vector**      The sprite's size.
--- `image`: **love.Image** The sprite's image.
---@return sprite
function sprite:new(args)
  args = args or {}

  local new = setmetatable({}, self)
  ---@cast new sprite
  local pos = args.position and args.position:clone() or vector.ZERO
  new.position = pos
  new.image = const.images.object
  if args.image then
    new.image = args.image
  end
  new.size = args.size or vector:new(new.image:getWidth(), new.image:getHeight())
  new.destroyed = false

  return new
end

---Positions the sprite at the given *x* & *y* vectors.
---@param vector vector The *x* vector.
function sprite:setposition(vector)
  self.position = vector:clone()
end

---Returns the sprite's position.
---@return vector
function sprite:getposition() -- this is redundant oml
  return self.position:clone()
end

---Draws the sprite on the screen.
function sprite:draw()
  local x, y = self.position:get()
  love.graphics.draw(self.image, x, y, 0, self.size.x / self.image:getWidth(), self.size.y / self.image:getHeight())
end

---Disables draw function and flags the sprite as destroyed.
function sprite:destroy()
  self.destroyed = true
  self.draw = function() end
end

return sprite
