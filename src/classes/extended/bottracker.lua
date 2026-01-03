---Extended class for tracking bots.

local bot = require 'src.classes.extended.bot'
local tracker = require 'src.classes.base.tracker'

---@class bottracker: tracker
local bottracker = setmetatable({}, { __index = tracker })
bottracker.__index = bottracker

---Creates a new tracker for the `bot` type.
---@param world slick.world?
---@return bottracker
function bottracker:new(world)
  local new = tracker.new(self, world)
  new.type = 'bot'
  ---@cast new bottracker
  return new
end

---Updates all bots based on elapsed time.
---@param delta number Elapsed time.
function bottracker:update(delta)
  local objects = self.objects
  for i = 1, #objects do
    local v = objects[i]
    v:update(delta)
    if v.energy <= 0 then
      v:destroy()
    end
  end
end

---Reproduce tick for every bot in the tracker.
function bottracker:reproducecycle()
  local objects = self.objects
  local len = #objects
  for i = 1, len do
    local new = objects[i]:reproduce()
    if new then
      table.insert(objects, new)
    end
  end
end

return bottracker
