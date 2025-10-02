local bot = require 'src.classes.bot'
local const = require 'src.const'
local utils = require 'src.utils'
local tracker = require 'src.classes.tracker'
local color = utils.color
local bottracker = tracker.bottracker
local foodtracker = tracker.foodtracker

local image = const.images.object

---@type bottracker
local tracker1 = bottracker:new()

tracker1:add(bot:new {
  x = 400,
  y = 300,
  team = math.random(2),
})
for _ = 1, 10 do
  tracker1:iterate(function(v)
    v:move(math.random() * 2 - 1, math.random() * 2 - 1)
  end)
  tracker1:update(0.001)
  tracker1:iterate(function(v)
    v:consume(9000, true)
  end)
  tracker1:reproducecycle()
end

local time = love.timer.getTime()
local x = 200
local function update(delta)
  if love.timer.getTime() > time + 2 then
    time = love.timer.getTime()
    x = x == 200 and 600 or 200
  end
  tracker1:iterate(function(v)
    v:move(x - v.x, 300 - v.y)
    v:update(delta)
  end)
  tracker1:pairwise(utils.handlecollision)
end

local function draw()
  tracker1:draw()
end

return {
  name = 'Collision Tester',
  update = update,
  draw = draw,
}
