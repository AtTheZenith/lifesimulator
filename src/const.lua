---@enum consts
local consts = {
  windowtitle = 'Life Simulator v0.6.0',
  framerate = 0,
  dimensions = { love.window.getDesktopDimensions(0) },

  trueobjectsize = 40,
  trueentityspeed = 120,
  truebotrange = 90,
  minbotsize = 0.5,
  maxbotsize = 3,
  minbotspeed = 0.5,
  maxbotspeed = 4,
  minbotrange = 0.5,
  maxbotrange = 5,

  foodsize = 10,
  foodstart = 200,
  foodcooldown = 0.03,

  maxenergy = 800,
  foodenergy = 200,
  botenergy = 300,
  reproductioncost = 320,
  reproductionmin = 750,
  minsizegap = 1.07,

  images = {
    object = love.graphics.newImage 'assets/object.png',
    bluebot = love.graphics.newImage 'assets/bot_1.png',
    orangebot = love.graphics.newImage 'assets/bot_2.png',
    food = love.graphics.newImage 'assets/food.png',
  },
}

return consts
