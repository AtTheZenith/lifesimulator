local const = require 'src.const'
local utils = require 'src.utils'
local object = require 'src.classes.object'
local magnitude = utils.getmagnitude
local point = utils.point

---@class entity: object
---@field speed number
---@field truespeed number
---@field movedirection point
local entity = setmetatable({}, object)
entity.__index = entity

---Creates a new entity to be displayed on screen.
---All the following arguments are *optional*.
---@param args {x: number?, y: number?, size: number?, speed: number?, image: love.Image?}? **table**  containing the following arguments:
--- `x` & `y`: **number**     The 2D position.
--- `size`: **number**      The entity's size.
--- `speed`: **number**     The entity's speed
--- `image`: **love.image** The entity's sprite.
---@return object
function entity:new(args)
  args = args or {}
  local new = object.new(self, args)
  ---@cast new entity
  new.speed = args.speed or 1
  new.truespeed = new.speed * const.trueentityspeed
  new.movedirection = point:new(0, 0)
  return new
end

---Changes the entity's direction of movement.
---@param x number The *x* vector.
---@param y number The *y* vector.
function entity:move(x, y)
  local mag = magnitude(x, y)
  mag = mag == 0 and 1 or mag
  self.movedirection.x = x / mag
  self.movedirection.y = y / mag
end

---Updates the entity after an elapsed amount of time.
---@param delta number The elapsed amount of time.
function entity:update(delta)
  self.x = self.x + self.movedirection.x * self.truespeed * delta
  self.y = self.y + self.movedirection.y * self.truespeed * delta
end

return entity
