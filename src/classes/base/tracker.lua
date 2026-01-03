---Minimal general-purpose inheritable class for tracking items.

---@class tracker
---@field type string
---@field objects any[]
---@field world slick.world?
local tracker = {}
tracker.__index = tracker

---Creates a new tracker instance.
---@param world slick.world?
---@return tracker
function tracker:new(world)
  local new = setmetatable({}, self)

  ---@type string
  new.type = 'normal'
  new.objects = {}
  new.world = world

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

---Removes an object at a specific index. O(1).
---@param index vector
function tracker:removeindex(index)
  local objects = self.objects
  local len = #objects
  if index < 1 or index > len then return end

  objects[index] = objects[len]
  objects[len] = nil
end

---Gets an object at the specific index.
---@param index vector
---@return any
function tracker:get(index)
  return self.objects[index]
end

---Wrapper for iterating over the object list.
---@param func fun(v: any)
function tracker:iterate(func)
  local objects = self.objects
  for i = 1, #objects do
    func(objects[i])
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
  local objects = self.objects
  for i = 1, #objects do
    objects[i]:draw()
  end
end

return tracker
