local const = require 'src.const'
local food = require 'src.classes.food'
local utils = require 'src.utils'

local colliding = utils.colliding
local handlecollision = utils.handlecollision

---@class tracker
---@field type string
---@field objects any[]
local tracker = {}
tracker.__index = tracker

---Creates a new tracker instance.
---@return tracker
function tracker:new()
  local new = setmetatable({}, self)

  ---@type string
  new.type = 'normal'
  new.objects = {}

  return new
end

---Adds an object to the objects list.
---@param object any
function tracker:add(object)
  table.insert(self.objects, object)
end

---Removes an object from the objects list.
---@param object any
function tracker:remove(object)
  local objects = self.objects
  for i = 1, #objects do
    if objects[i] == object then
      objects[i] = objects[#objects]
      objects[#objects] = nil
      return
    end
  end
end

---Gets an object at the specific index.
---@param index number
---@return any
function tracker:get(index)
  return self.objects[index]
end

---Wrapper for iterating over the object list.
---@param func fun(v: any)
function tracker:iterate(func)
  for _, v in next, self.objects do
    func(v)
  end
end

---Iterates over every possible pair in the objects list in an O(n²) efficiency.
---@param func fun(v1: any, v2: any)
function tracker:pairwise(func)
  local objects = self.objects
  for i = 1, #objects do
    for j = i + 1, #objects do
      func(objects[i], objects[j])
    end
  end
end

---Clears all destroyed objects from the objects list.
function tracker:clean()
  local objects = self.objects
  for i = #objects, 1, -1 do
    if objects[i].destroyed then
      objects[i] = objects[#objects]
      objects[#objects] = nil
    end
  end
end

---Draws all objects on screen.
function tracker:draw()
  for _, v in next, self.objects do
    v:draw()
  end
end

---@class bottracker: tracker
local bottracker = setmetatable({}, { __index = tracker })
bottracker.__index = bottracker

---Creates a new tracker for the `bot` type.
---@return bottracker
function bottracker:new()
  local new = tracker.new(self)
  new.type = 'bot'
  ---@cast new bottracker
  return new
end

---Updates all bots based on elapsed time.
---@param delta number Elapsed time.
function bottracker:update(delta)
  for _, v in next, self.objects do
    v:update(delta)
    if v.energy <= 0 then
      v:destroy()
      self:remove(v)
    end
  end
end

---Reproduce tick for every bot in the tracker.
function bottracker:reproducecycle()
  local offspring = {}
  for _, v in next, self.objects do
    local new = v:reproduce()
    if new then
      table.insert(offspring, new)
    end
  end
  for _, v in next, offspring do
    table.insert(self.objects, v)
  end
end

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
function foodtracker:consumecycle(entities)
  for _, bot in next, entities.objects do
    for _, food in next, self.objects do
      if colliding(bot, food) then
        handlecollision(bot, food)
        food:feed(bot)
        self:remove(food)
      end
    end
  end
end

return { tracker = tracker, bottracker = bottracker, foodtracker = foodtracker }
