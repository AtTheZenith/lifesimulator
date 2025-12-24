local const = require 'src.constants'
local food = require 'src.classes.food'
local tracker = require 'src.classes.trackers.normal' 

---@class foodtracker: tracker
local foodtracker = setmetatable({}, { __index = tracker })
foodtracker.__index = foodtracker

---@return foodtracker
function foodtracker:new()
  local new = tracker.new(self)
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
  self:add(food:new { x = x, y = y, size = size, energy = energy, image = const.images.food })
end

---Handles the consumption of food by bots.
---@param entities bottracker
function foodtracker:consumecycle(entities) end