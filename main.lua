local bot = require 'src.bot'
local const = require 'src.const'

local helper = require 'src.helper'
local color = helper.color
local magnitude = helper.getmagnitude
local distance = helper.getdistance

---@type bot[]
local bots = {}
function love.load()
  love.graphics.setBackgroundColor(helper.color(60, 60, 60))
  local thing = bot:new {
    x = 300,
    y = 300,
    team = math.random(2),
  }
  for _ = 1, 100000 do
    thing = thing:reproduce()
    table.insert(bots, thing)
  end
end

function love.update(delta)
  print(1 / delta)
  for _, v in next, bots do
    v:move(1 - math.random() * 2, 1 - math.random() * 2)
    v:update(delta)
  end
end

function love.draw()
  for _, v in next, bots do
    v:draw()
  end
end
