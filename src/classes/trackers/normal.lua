local const = require 'src.constants'
local food = require 'src.classes.food'
local utils = require 'src.utilitiess'

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

return tracker
