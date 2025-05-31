-- Debugger configuration
if arg[2] == "debug" then
	lldebugger = require("lldebugger").start()
end

local love_errorhandler = love.errorhandler

-- main.lua
local player = require("src.player")
local const = require("src.const")

function love.load()
	player.load()
end

function love.update(dt)
	player.update(dt)
end

function love.draw()
	player.draw()
end

-- End of file
function love.errorhandler(msg)
	if lldebugger then
		error(msg, 2)
	else
		return love_errorhandler(msg)
	end
end
