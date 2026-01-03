local bot = require 'src.classes.extended.bot'
local bottracker = require 'src.classes.extended.bottracker'
local const = require 'src.constants'
local vector = require 'src.classes.vector'
local slick = require 'src.slick'

local world, tracker1
local function load()
  ---Init world
  world = slick.newWorld(const.windowsize.x, const.windowsize.y)

  ---Init tracker
  tracker1 = bottracker:new(world)

  --- Init bots
  for i = 1, 50 do
    tracker1:add(bot:new {
      position = vector:new(400 + (i % 20) * 50, 300 + math.floor(i / 20) * 50),
      team = math.random(2),
      world = world,
    })
  end
  tracker1:iterate(function(v)
    v:consume(100, true)
  end)
end

---Start cycle
local time = love.timer.getTime()
local x = 200
local function update(delta)
  if love.timer.getTime() > time + 2 then
    time = love.timer.getTime()
    x = x == 200 and 600 or 200
  end
  local target = vector:new(x, 300)

  tracker1:iterate(function(v)
    v:move(vector:new(math.random() * 2 - 1, math.random() * 2 - 1))
    v:consume(100, true)
  end)

  tracker1:update(delta)
  tracker1:clean()
end

local function draw()
  tracker1:draw()
end

return {
  name = 'Collision Tester',
  load = load,
  update = update,
  draw = draw,
}
