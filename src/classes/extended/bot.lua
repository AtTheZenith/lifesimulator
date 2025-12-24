local const = require 'src.constants'
local entity = require 'src.classes.base.entity'
local utils = require 'src.utilitiess'
local clamp = utils.clamp
local magnitude = utils.getmagnitude

---@class bot: entity
---@field range number
---@field energy number
---@field team number
---@field truerange number
local bot = setmetatable({}, entity)
bot.__index = bot

---Creates a new bot instance.
---All the following arguments are *optional*.
---@param args {position: vector?, size: number?, speed: number?, range: number?, energy: number?, team: number?, image: love.Image?}? **table**  containing the following arguments:
--- `position`: **vector**              The bot's position.
--- `size`: **number**                  The bot's size.
--- `speed`: **number**                 The bot's speed.
--- `range`: **number**                 The bot's range.
--- `energy`: **number**                The starting energy.
--- `team`: **number**                  The bot's team.
--- `image`: **love.image**             The bot sprite.
---@return bot
function bot:new(args)
  args = args or {}
  local new = entity.new(self, args)
  ---@cast new bot

  new.size = clamp(args.size or 1, const.minbotsize, const.maxbotsize)
  new.truesize = new.size * const.trueobjectsize
  new.range = clamp(args.range or 1, const.minbotrange, const.maxbotrange)
  new.truerange = new.range * const.truebotrange
  new.energy = (args.energy or 1) * const.maxenergy
  new.team = args.team or 0

  return new
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

---Updates the bot after an elapsed amount of time.
---@param delta number The elapsed amount of time.
function bot:update(delta)
  self.position = self.position + self.movedirection * self.truespeed * delta
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

---Creates a new bot with mutated attributes.
---@return bot?
function bot:reproduce()
  if self.energy > const.reproductionmin then
    self:consume(-const.reproductioncost)
    return bot:new {
      position = self.position,
      size = self.size + (math.random() / 5 - 0.1),
      speed = self.speed + (math.random() / 2.5 - 0.2),
      range = self.range + (math.random() / 5 - 0.1),
      energy = self.energy / 2 / const.maxenergy,
      team = math.random(3),
    }
  end
end

return bot
