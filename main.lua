local bot = require 'src.bot'
local const = require 'src.const'
local helper = require 'src.helper'
local tracker = require 'src.tracker'
local color = helper.color
local bottracker = tracker.bottracker
local foodtracker = tracker.foodtracker

local image = const.images.object

---@type bottracker
local tracker1 = bottracker:new()
function love.load()
  --- Window Setup
  love.window.setTitle(const.windowtitle)
  love.window.setMode(const.dimensions[1], const.dimensions[2], { borderless = true, resizable = false })
  love.graphics.setBackgroundColor(color(60, 60, 60, 60))

  --- Bot Setup
  ---@type tracker
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
end

local time = love.timer.getTime()
local x = 200
function love.update(delta)
  if love.timer.getTime() > time + 2 then
    time = love.timer.getTime()
    x = x == 200 and 600 or 200
  end
  tracker1:iterate(function(v)
    v:move(x - v.x, 300 - v.y)
    v:update(delta)
  end)
  tracker1:pairwise(helper.handlecollision)
end

function love.draw()
  tracker1:draw(image)
end
