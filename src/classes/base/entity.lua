local const = require 'src.constants'
local object = require 'src.classes.base.object'
local vector = require 'src.classes.vector'

---@class entity: object
---@field speed number
---@field truespeed number
---@field movedirection vector
local entity = setmetatable({}, object)
entity.__index = entity

---Creates a new entity to be displayed on screen.
---All the following arguments are *optional*.
---@param args {position: vector?, size: number?, speed: number?, image: love.Image?}? **table**  containing the following arguments:
--- `position`: **vector**  The entity's position.
--- `size`: **number**      The entity's size.
--- `speed`: **number**     The entity's speed
--- `image`: **love.image** The entity's sprite.
---@return entity
function entity:new(args)
  args = args or {}
  local new = object.new(self, args)
  ---@cast new entity
  new.speed = args.speed or 1
  new.truespeed = new.speed * const.trueentityspeed
  new.movedirection = vector:new(0, 0)
  return new
end

---Changes the entity's direction of movement.
---@param direction vector Direction vector.
function entity:move(direction)
  self.movedirection = direction:normal()
end

---Updates the entity after an elapsed amount of time.
---@param delta number The elapsed amount of time.
function entity:update(delta)
  self.position = self.position + self.movedirection * self.truespeed * delta
end

return entity
