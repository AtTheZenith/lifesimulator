local bot = require 'src.bot'
local helper = require 'src.helper'
local color = helper.color

---@type bot[]
local bots = {}
function love.load()
  love.graphics.setBackgroundColor(color(60, 60, 60))
  local thing = bot:new {
    x = 400,
    y = 300,
    team = math.random(2),
  }
  for _ = 1, 1000 do
    thing:move(math.random() * 2 - 1, math.random() * 2 - 1)
    thing:update(0.001)
    thing = thing:reproduce()
    table.insert(bots, thing)
  end
end

local time = love.timer.getTime()
local x = 200
function love.update(delta)
  if love.timer.getTime() > time + 5 then
    time = love.timer.getTime()
    x = x == 200 and 600 or 200
  end
  for _, v in next, bots do
    v:move(x - v.x, 300 - v.y)
    v:update(delta)
  end
  for i = 1, #bots do
    local v1 = bots[i]
    for j = i + 1, #bots do
      local v2 = bots[j]
      helper.handlecollision(v1, v2)
    end
  end
end

function love.draw()
  for _, v in next, bots do
    v:draw()
  end
end
