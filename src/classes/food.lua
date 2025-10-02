local bot = require 'src.classes.bot'
local const = require 'src.const'
local object = require 'src.classes.object'

---@class food: object
---@field energy number
local food = setmetatable({}, object)
food.__index = food

---Creates a new food instance.
---All the following arguments are *optional*.
---@param args {x: number?, y: number?, size: number?, energy: number?, image: love.Image?}? **table**  containing the following arguments:
--- `x` & `y`: **number**                 The 2D position.
--- `size`: **number**                  The bot's size, speed, range.
--- `energy`: **number**                The starting energy.
--- `team`: **number**                  The bot's team.
--- `image`: **love.image**             The food sprite.
---@return food
function food:new(args)
  args = args or {}
  local new = object.new(self, args)
  ---@cast new food

  new.size = args.size or 1
  new.truesize = new.size * const.trueobjectsize
  new.energy = (args.energy or 1) * const.foodenergy

  return new
end

---@param bot bot
function food:feed(bot)
  bot:consume(self.energy)
  self.energy = 0
  self:destroy()
end

return food
