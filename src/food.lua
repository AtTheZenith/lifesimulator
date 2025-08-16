local const = require 'src.const'
local object = require 'src.object'
local helper = require 'src.helper'
-- local point = helper.point
local clamp = helper.clamp
-- local color = helper.color
local magnitude = helper.getmagnitude

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
---@return bot
function food:new(args)
  args = args or {}
  local new = object.new(self, args)
  ---@cast new bot

  new.energy = (args.energy or 1) * const.maxenergy

  return new
end
