local constants = require 'src.constants'
local sprite = require 'src.classes.base.sprite'
local slick = require 'src.slick'
local vector = require 'src.classes.vector'

---@class object: sprite
---@field world slick.world?
---@field slickentity slick.entity?
---@field radius number?
---@field type string
local object = setmetatable({}, sprite)
object.__index = object
object.type = 'object'

---Creates a new object instance.
---All the following arguments are *optional*.
---@param args {position: vector?, size: vector?, radius: number?, image: love.Image?, world: slick.world?, bodytype: ("circle"|"rectangle")?}? **table**  containing the following arguments:
--- `position`: **vector**  The object's position.
--- `size`: **vector**      The object's size (for rectangle).
--- `radius`: **number**    The object's radius (for circle).
--- `image`: **love.image** The object's sprite.
--- `world`: **slick.world** The collision world.
--- `bodytype`: **string**  The collision body type ('circle' or 'rectangle'). Defaults to 'circle'.
---@return object
function object:new(args)
  args = args or {}

  if not args.world then error('"world" argument not passed to object:new.') end

  ---Set default arguments
  local bodytype = args.bodytype or "circle"

  if bodytype == "rectangle" then
    args.image = args.image or constants.images.object
    args.size = args.size or vector:new(args.image:getWidth(), args.image:getHeight())
  else
    args.image = args.image or constants.images.circle
    args.radius = args.radius or args.image:getWidth() / 2
    args.size = args.size or vector:new(args.radius * 2, args.radius * 2)
  end

  ---Create object
  local new = sprite.new(self, args)
  ---@cast new object

  ---Add to physics world
  if args.world then
    new.world = args.world
    local shape

    if args.bodytype == "rectangle" then
      shape = slick.newRectangleShape(0, 0, args.size.x, args.size.y)
    else
      shape = slick.newCircleShape(args.radius, args.radius, args.radius)
    end

    new.slickentity = new.world:add(new, new.position.x, new.position.y, shape)
  end

  return new
end

---Disables draw function, flags the object as destroyed, and removes from physics.
function object:destroy()
  sprite.destroy(self)
  if self.world and self.world:has(self) then
    self.world:remove(self)
  end
end

return object
