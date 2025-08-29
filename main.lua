local bot = require 'src.bot'
local const = require 'src.const'
local food = require 'src.food'
local helper = require 'src.helper'
local tracker = require 'src.tracker'
local color = helper.color
local bottracker = tracker.bottracker
local foodtracker = tracker.foodtracker

local image = const.images.object
local botimage1 = const.images.bluebot
local botimage2 = const.images.orangebot
local foodimage = const.images.food

---Trackers
local bt
local ft

function love.load()
  ---Window Setup
  love.window.setTitle(const.windowtitle)
  love.window.setMode(800, 500, { borderless = false, resizable = true })
  love.graphics.setBackgroundColor(color(60, 60, 60, 60))

  ---Tracker Setup
  bt = bottracker:new()
  ft = foodtracker:new()
end

function love.update(delta)
  ---Spawn food and make the bot
  ---chase it, spawn another one
  ---if bot consumes it.
  if #bt.objects == 0 then
    bt:add(bot:new {
      x = math.random(800),
      y = math.random(500),
      team = math.random(2),
      energy = 1,
      image = (math.random(2) == 1 and botimage1 or botimage2),
    })
  end

  if #ft.objects == 0 then
    ft:add(food:new {
      x = math.random(800),
      y = math.random(500),
      size = math.random(),
      energy = 1,
      image = foodimage,
    })
  end

  ---Chase food.
  bt:iterate(function(b)  
    local closestfood = nil
    local closestdist = math.huge
    for _, f in next, ft.objects do
      local dist = helper.getmagnitude(f.x - b.x, f.y - b.y)
      if dist < closestdist then
        closestdist = dist
        closestfood = f
      end
    end
    if closestfood then
      b:move(closestfood.x - b.x, closestfood.y - b.y)
    else
      b:move(0, 0)
    end
  end)

  ---Chores
  bt:update(delta)
  ft:consumecycle(bt)

  bt:clean()
  ft:clean()
end

function love.draw()
  bt:draw()
  ft:draw()
end
