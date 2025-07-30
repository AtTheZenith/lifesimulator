local const = require 'src.const'
local helper = require 'src.helper'

---@class tracker
---@field type string
---@field objects any[]
---@field private customfunctions any
local tracker = {}
tracker.__index = tracker

---Creates a new tracker instance.
---@param args? {type: string?} **table**  containing the following arguments:
--- `type`: [optional] The type of tracker, purely for decoration.
---@return tracker
function tracker:new(args)
  local new = setmetatable({}, self)
  args = setmetatable(args or {}, {
    __index = function()
      return false
    end,
  })

  ---@type string
  new.type = args.type and args.type:lower() or ''
  new.objects = {}

  return new
end

---@param object any
function tracker:add(object)
  table.insert(self.objects, object)
end

---@param object any
function tracker:remove(object)
  for i, v in next, self.objects do
    if v == object then
      table.remove(self.objects, i)
      break
    end
  end
end
---@param index number
---@return any
function tracker:get(index)
  return self.objects[index]
end

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

---@class bottracker: tracker
local bottracker = setmetatable({}, { __index = tracker })
bottracker.__index = bottracker

---@return bottracker
function bottracker:new()
  local new = tracker.new(self, { type = 'food' })
  ---@cast new bottracker
  return new
end

---Updates all bots based on elapsed time.
---@param delta number Elapsed time.
function bottracker:update(delta)
  for _, v in next, self.objects do
    v:update(delta)
  end
end

--- Draws all bots on screen.
function bottracker:draw(...)
  for _, v in next, self.objects do
    v:draw(...)
  end
end

--- Reproduce tick for every bot in the tracker.
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
  local new = tracker.new(self, { type = 'food' })
  ---@cast new foodtracker
  return new
end

function foodtracker:generate(x, y, size, energy) end

function foodtracker:consumecycle(entities) end

function foodtracker:draw()
  for _, v in next, self.objects do
    v:draw()
  end
end

return { tracker = tracker, bottracker = bottracker, foodtracker = foodtracker }
