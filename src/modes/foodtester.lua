local bot = require 'src.classes.extended.bot'
local bottracker = require 'src.classes.extended.bottracker'
local const = require 'src.constants'
local food = require 'src.classes.extended.food'
local foodtracker = require 'src.classes.extended.foodtracker'
local utils = require 'src.utilities'
local vector = require 'src.classes.vector'

local image = const.images.object
local botimage1 = const.images.bluebot
local botimage2 = const.images.orangebot
local foodimage = const.images.food

local slick = require 'src.slick'

local world, bt, ft
local function load()
  ---Init world
  world = slick.newWorld(const.windowsize.x, const.windowsize.y)

  ---Trackers
  bt = bottracker:new(world)
  ft = foodtracker:new(world)
end

local function update(delta)
  ---Spawn food and make the bot
  ---chase it, spawn another one
  ---if bot consumes it.

  if #bt.objects < 30 then
    bt:add(bot:new {
      position = vector:new(math.random(const.windowsize.x), math.random(const.windowsize.y)),
      range = 120,
      team = math.random(2),
      energy = const.maxenergy,
      image = (math.random(2) == 1 and botimage1 or botimage2),
      world = world,
    })
  end

  if #ft.objects < 30 then
    ft:add(food:new {
      position = vector:new(math.random(const.windowsize.x), math.random(const.windowsize.y)),
      image = foodimage,
      world = world,
    })
  end

  ---Chase food.
  bt:iterate(function(b)
    ---@cast b bot
    if not b.target or b.target.destroyed then
      local closestfood = nil
      local closestdist = math.huge

      local results, len = world:queryCircle(b.position.x, b.position.y, b.range, function(item)
        return item.type == 'food'
      end)

      for i = 1, len do
        local f = results[i].item
        local dist = (f.position - b.position):length()
        if dist < closestdist then
          closestdist = dist
          closestfood = f
        end
      end
      b.target = closestfood
    end

    if b.target then
      b:move(b.target.position - b.position)
    else
      b:move(vector.ZERO)
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
