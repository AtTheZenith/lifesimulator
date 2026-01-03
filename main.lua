local const = require 'src.constants'
local modes = require 'src.modes.modes'
local utils = require 'src.utilities'
local color = utils.color

local currentmode = modes.diffusion

function love.load()
  ---Window setup
  love.window.setTitle(const.windowtitle)
  love.window.setMode(const.windowsize.x, const.windowsize.y, { borderless = false, resizable = true })
  love.graphics.setBackgroundColor(color(60, 60, 60, 60))

  currentmode.load()
  currentmode.update(0.67)
end

function love.resize(w, h)
  const.windowsize.x, const.windowsize.y = w, h
end

-- function love.update(dt)
--   print(dt)
--   currentmode.update(dt)
-- end

love.update = currentmode.update
love.draw = currentmode.draw
