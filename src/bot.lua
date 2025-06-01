local const = require("src.const")

---@class Bot
---@field x number
---@field y number
---@field movedirection {x: number, y: number}
---@field image love.ImageData
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

function bot:new(args)
  local new = setmetatable({}, bot)
  args.__index = function()
    return 1
  end

  new.x = args.x
  new.y = args.y
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
