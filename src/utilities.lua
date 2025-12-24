---Utility library for lifesimulator.

---Utility functions.
local utils = {}

--FUNCTIONS:
---Clamps a number between any two numbers.
---@param value number
---@param min number
---@param max number
---@return number
function utils.clamp(value, min, max)
  return math.min(max, math.max(min, value))
end

---Convert 24-bit colors to float based colors.
---@param r number Red
---@param g number Green
---@param b number Blue
---@param a? number *[optional]* Alpha
---@return number, number, number, number?
function utils.color(r, g, b, a)
  if a then
    return r / 255, g / 255, b / 255, a / 255
  else
    return r / 255, g / 255, b / 255
  end
end

return utils
