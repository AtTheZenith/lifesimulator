---Minimal general-purpose inheritable class for movement.

local const = require 'src.constants'
local object = require 'src.classes.base.object'
local vector = require 'src.classes.vector'
local worldQuery = require 'src.slick.worldQuery'

---@class entity: object
---@field speed number
---@field truespeed number
---@field movedirection vector
---@field lastcollisions slick.worldQueryResponse[]?
---@field lastcollisioncount number?
---@field query slick.worldQuery?
---@field type string
local entity = setmetatable({}, object)
entity.__index = entity
entity.type = 'entity'

---Generic collision filter. Dynamic objects slide by default.
---@param other any
---@return string
function entity:filter(other)
  return 'slide'
end

---Creates a new entity to be displayed on screen.
---All the following arguments are *optional*.
---@param args {position: vector?, size: vector?, radius: number?, speed: number?, image: love.Image?, world: slick.world?, bodytype: ("circle"|"rectangle")?}? **table**  containing the following arguments:
--- `position`: **vector**  The entity's position.
--- `size`: **vector**      The entity's size.
--- `radius`: **number**    The entity's radius.
--- `speed`: **number**     The entity's speed
--- `image`: **love.image** The entity's sprite.
--- `world`: **slick.world** The collision world.
--- `bodytype`: **string**  The collision body type.
---@return entity
function entity:new(args)
  args = args or {}
  ---dependent on parent class
  local new = object.new(self, args)
  ---@cast new entity
  ---independent of parent class
  new.speed = args.speed or 160
  new.movedirection = vector:new(0, 0)

  if new.world then
    new.query = worldQuery.new(new.world)
  end

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
  local goal = self.position + self.movedirection * self.speed * delta

  if self.world and self.world:has(self) then
    -- Physical movement using slick
    local actualX, actualY, collisions, len = self.world:move(self, goal.x, goal.y, function(item, other)
      return self:filter(other)
    end, self.query)
    self.position:set(actualX, actualY)

    -- Store collisions for subclasses to process
    self.lastcollisions = collisions
    self.lastcollisioncount = len
  else
    -- Fallback for non-physical movement
    self.position = goal
  end
end

return entity
