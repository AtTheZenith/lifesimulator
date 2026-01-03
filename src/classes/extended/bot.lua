---Bot class for simulations.

local const = require 'src.constants'
local entity = require 'src.classes.base.entity'
local utils = require 'src.utilities'
local vector = require 'src.classes.vector'
local clamp = utils.clamp

---@class bot: entity
---@field range number
---@field energy number
---@field team number
---@field type "bot"
---@field target bot | food | nil
local bot = setmetatable({}, entity)
bot.__index = bot
bot.type = 'bot'

---Creates a new bot instance.
---All the following arguments are *optional*.
---@param args {position: vector?, size: vector?, speed: number?, range: number?, energy: number?, team: number?, image: love.Image?, world: slick.world?, bodytype: string?, radius: nil}? **table**  containing the following arguments:
--- `position`: **vector**              The bot's position.
--- `size`: **vector**                  The bot's size.
--- `speed`: **number**                 The bot's speed.
--- `range`: **number**                 The bot's range.
--- `energy`: **number**                The starting energy.
--- `team`: **number**                  The bot's team.
--- `image`: **love.image**             The bot sprite.
--- `world`: **slick.world**            The collision world.
---@return bot
function bot:new(args)
  args = args or {}
  args.bodytype = 'rectangle'
  local size = args.size or vector:new(40, 40)
  size.x = clamp(size.x, 40 * const.minbotsize, 40 * const.maxbotsize)
  size.y = clamp(size.y, 40 * const.minbotsize, 40 * const.maxbotsize)
  args.size = size
  local new = entity.new(self, args)
  ---@cast new bot

  new.range = clamp(args.range or 90, 90 * const.minbotrange, 90 * const.maxbotrange)
  new.energy = (args.energy or 0.5) * const.maxenergy
  new.team = args.team or 0
  new.target = nil

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

---Collision filter for bots.
---@param other any
---@return string
function bot:filter(other)
  if other.type == 'food' then
    return 'cross'
  end
  return 'slide'
end

---Updates the bot after an elapsed amount of time.
---@param delta number The elapsed amount of time.
function bot:update(delta)
  entity.update(self, delta)

  -- Process collisions (e.g. eating food)
  local collisions = self.lastcollisions
  if collisions then
    for i = 1, self.lastcollisioncount do
      local col = collisions[i]
      if col.other.type == 'food' and not col.other.destroyed then
        col.other:feed(self)
      end
    end
  end

  self:consume(
    (
      self.size.x
      + self.movedirection:length() * self.speed
      + math.sqrt(self.range)
    )
    * delta
    * -1
  )
end

---Creates a new bot with mutated attributes.
---@return bot?
function bot:reproduce()
  if self.energy > const.reproductionmin then
    self:consume(-const.reproductioncost)
    return bot:new {
      position = self.position,
      size = self.size + (math.random() * 4 - 2),
      speed = self.speed + (math.random() * 6 - 3),
      range = self.range + (math.random() * 6 - 3),
      energy = self.energy / 2 / const.maxenergy,
      team = math.random(3),
      world = self.world,
    }
  end
end

return bot
