local bot = require("src.bot")
local const = require("src.const")
local helper = require("src.helper")

---@type Bot
local bot1
function love.load()
  love.graphics.setBackgroundColor(helper.color3(60, 60, 60))
  bot1 = bot:new({
    x = 300,
    y = 300,
  })
end

function love.update(dt)
  bot1:move(1 - math.random() * 2, 1 - math.random() * 2)
  bot1:update(dt)
  print(bot1.x, bot1.y)
end

function love.draw() end