local bot = require 'src.classes.extended.bot'
local const = require 'src.constants'
local object = require 'src.classes.base.object'

---@class food: object
---@field energy number
---@field type "food"
local food = setmetatable({}, object)
food.__index = food
food.type = 'food'

---Creates a new food instance.
---All the following arguments are *optional*.
---@param args {position: vector?, size: vector?, energy: number?, image: love.Image?, world: slick.world?, bodytype: string?, radius: nil}? **table**  containing the following arguments:
--- `position`: **vector**             The food's position.
--- `size`: **vector**                The food's size.
--- `energy`: **number**                The starting energy.
--- `image`: **love.image**             The food sprite.
--- `world`: **slick.world**            The collision world.
---@return food
function food:new(args)
  args = args or {}
  args.bodytype = "rectangle"
  local new = object.new(self, args)
  ---@cast new food

  new.energy = (args.energy or const.foodenergy)

  return new
end

---Feeds the food to a bot.
---@param bot bot
function food:feed(bot)
  bot:consume(self.energy)
  self.energy = 0
  self:destroy()
end

return food
