local bot = require 'src.classes.bot'
local const = require 'src.constants'
local food = require 'src.classes.food'
local utils = require 'src.utilitiess'
local tracker = require 'src.classes.tracker'
local vector = require 'src.classes.vector'
local color = utils.color
local bottracker = tracker.bottracker
local foodtracker = tracker.foodtracker

local image = const.images.object
local botimage1 = const.images.bluebot
local botimage2 = const.images.orangebot
local foodimage = const.images.food

---Trackers
---@type bottracker
local bt = bottracker:new()
---@type foodtracker
local ft = foodtracker:new()

local function update(delta)
  ---Spawn food and make the bot
  ---chase it, spawn another one
  ---if bot consumes it.
  if #bt.objects == 0 then
    bt:add(bot:new {
      position = vector:new(math.random(const.windowsize[1]), math.random(const.windowsize[2])),
      team = math.random(2),
      energy = 1,
      image = (math.random(2) == 1 and botimage1 or botimage2),
    })
  end

  ---If no food, then make
  ---a new food object.
  if #ft.objects == 0 then
    ft:add(food:new {
      x = math.random(const.windowsize[1]),
      y = math.random(const.windowsize[2]),
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
      local dist = utils.getmagnitude(f.x - b.x, f.y - b.y)
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

local function draw()
  bt:draw()
  ft:draw()
end

return { name = 'Food Chaser', load = load, update = update, draw = draw }
