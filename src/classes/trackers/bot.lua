local bot = require 'src.classes.extended.bot'
local tracker = require 'src.classes.trackers.normal'

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