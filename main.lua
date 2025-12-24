local const = require 'src.constants'
local utils = require 'src.utilitiess'
local color = utils.color

local modes = {
  foodchaser = require 'src.modes.foodtester',
  collisiontester = require 'src.modes.collisiontester',
}

local currentmode = modes.collisiontester

function love.load()
  ---Window setup
  love.window.setTitle(const.windowtitle)
  love.window.setMode(const.windowsize[1], const.windowsize[2], { borderless = false, resizable = true })
  love.graphics.setBackgroundColor(color(60, 60, 60, 60))
end

function love.update(delta)
  ---Update dimensions
  local w, h = love.window.getMode()
  const.windowsize[1], const.windowsize[2] = w, h

  currentmode.update(delta)
end

function love.draw()
  currentmode.draw()
end
