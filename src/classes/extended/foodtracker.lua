local const = require 'src.constants'
local food = require 'src.classes.extended.food'
local tracker = require 'src.classes.base.tracker'
local vector = require 'src.classes.vector'

---@class foodtracker: tracker
local foodtracker = setmetatable({}, { __index = tracker })
foodtracker.__index = foodtracker

---@param world slick.world?
---@return foodtracker
function foodtracker:new(world)
  local new = tracker.new(self, world)
  new.type = 'food'
  ---@cast new foodtracker
  return new
end

---Creates a food object and tracks it.
---@param x number
---@param y number
---@param size number
---@param energy number
function foodtracker:generate(x, y, size, energy)
  self:add(food:new { position = vector:new(x, y), size = size, energy = energy, image = const.images.food, world = self.world })
end

---Handles the consumption of food by bots.
---@param entities bottracker
function foodtracker:consumecycle(entities) end

return foodtracker
