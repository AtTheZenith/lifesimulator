local const = require("src.const")
local helper = require("src.helper")

---@class Bot
---@field x number
---@field y number
---@field movedirection {x: number, y: number}
---@field size number
---@field speed number
---@field range number
---@field energy number
---@field team number
---@field truesize number
---@field truespeed number
---@field truerange number
local bot = {}
bot.__index = bot

---Creates a new Bot instance.
---All the following arguments are *optional*.
---@param args table **table**  containing the following arguments:
--- `x` & `y`: **number**                 The 2D position.
--- `size` & `speed` & `range`: **number**  The bot's size, speed, range.
--- `energy`: **number**                The starting energy.
--- `team`: **number**                  The bot's team.
function bot:new(args)
  local new = setmetatable({}, bot)
  args = setmetatable(args or {}, {
    __index = function()
      return 1
    end,
  })

  new.x = args.x
  new.y = args.y
  new.movedirection = { 0, 0 }
  new.size = args.size
  new.truesize = args.size * const.truebotsize
  new.speed = args.speed
  new.truespeed = args.speed * const.truebotspeed
  new.range = args.range
  new.truerange = args.range * const.truebotrange
  new.energy = args.energy * const.maxenergy
  new.team = args.team

  return new
end

---Changes the bot's direction of movement.
---@param x number The *x* vector.
---@param y number The *y* vector.
function bot:move(x, y)
  local mag = helper.getmagnitude(x, y)
  self.movedirection.x = x / mag
  self.movedirection.y = y / mag
end

---Updates the bot after an elapsed amount of time.
---@param dt number The elapsed amount of time.
function bot:update(dt)
  self.x = self.x + self.movedirection.x * self.truespeed * dt
  self.y = self.y + self.movedirection.y * self.truespeed * dt
end

return bot
