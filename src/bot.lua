local const = require 'src.const'
local helper = require 'src.helper'
local color = helper.color
local magnitude = helper.getmagnitude
local distance = helper.getdistance

---@class bot
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
  new.movedirection = {
    x = 0,
    y = 0,
    __index = function(t, k)
      if k == 1 then
        return t.x
      elseif k == 2 then
        return t.y
      end
    end,
  }
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

---Positions the bot at the given *x* & *y* vectors.
---@param x number The *x* vector.
---@param y number The *y* vector.
---@overload fun(x: point)
function bot:position(x, y)
  if type(x) == 'table' then
    x, y = x.x or x[1], x.y or x[2]
  end
  self.x, self.y = x, y
end

---Adds energy to the current energy level.
---@param energy number Amount of energy consumed.
---@param reset? boolean [optional]: if reset then bot.energy = energy end
function bot:consume(energy, reset)
  if not reset then
    self.energy = self.energy + energy
  else
    self.energy = energy
  end
end

---Changes the bot's direction of movement.
---@param x number The *x* vector.
---@param y number The *y* vector.
function bot:move(x, y)
  local mag = magnitude(x, y)
  mag = mag == 0 and 1 or mag
  self.movedirection.x = x / mag
  self.movedirection.y = y / mag
end

---Updates the bot after an elapsed amount of time.
---@param delta number The elapsed amount of time.
function bot:update(delta)
  self.x = self.x + self.movedirection.x * self.truespeed * delta
  self.y = self.y + self.movedirection.y * self.truespeed * delta
  self:consume(
    (
      self.size * self.size * 10
      + magnitude(self.movedirection) * self.speed * self.speed * 2
      + self.range * self.range * math.sqrt(self.range) * 3
    )
      * delta
      * -2
  )
end

---Draws the bot on the screen.
function bot:draw()
  ---@type number, number, number
  local r, g, b
  if self.team == 1 then
    r, g, b = 35, 35, 255
  elseif self.team == 2 then
    r, g, b = 255, 35, 35
  else
    r, g, b = 255, 255, 255
  end
  love.graphics.setColor(color(r, g, b, 255))
  love.graphics.rectangle('fill', self.x, self.y, self.truesize, self.truesize)
end

---Creates a new bot with mutated attributes.
---@return bot
function bot:reproduce()
  self:consume(-const.reproductioncost)
  return bot:new {
    x = self.x,
    y = self.y,
    size = self.size + (math.random() / 5 - 0.1),
    speed = self.speed + (math.random() / 2.5 - 0.2),
    range = self.range + (math.random() / 5 - 0.1),
    energy = self.energy / 2 / const.maxenergy,
    team = math.random(3),
  }
end

return bot
