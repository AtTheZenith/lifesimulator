local vector = require 'src.classes.vector'

---Rectangle class (centered anchor).
---@class rect
---@field position vector The center of the rectangle
---@field width number
---@field height number
local rect = {}
rect.__index = rect

---Creates a new rectangle.
---@param position vector
---@param width number
---@param height number
---@return rect
function rect:new(position, width, height)
  local r = {
    position = position,
    width = width or 0,
    height = height or 0,
  }
  return setmetatable(r, self)
end

--   === PROPERTIES (Dynamic) ===

---@return vector
function rect:top()
  return vector:new(self.position.x, self.position.y - self.height / 2)
end

---@return vector
function rect:bottom()
  return vector:new(self.position.x, self.position.y + self.height / 2)
end

---@return vector
function rect:left()
  return vector:new(self.position.x - self.width / 2, self.position.y)
end

---@return vector
function rect:right()
  return vector:new(self.position.x + self.width / 2, self.position.y)
end

---@return vector
function rect:topleft()
  return vector:new(self.position.x - self.width / 2, self.position.y - self.height / 2)
end

---@return vector
function rect:topright()
  return vector:new(self.position.x + self.width / 2, self.position.y - self.height / 2)
end

---@return vector
function rect:bottomleft()
  return vector:new(self.position.x - self.width / 2, self.position.y + self.height / 2)
end

---@return vector
function rect:bottomright()
  return vector:new(self.position.x + self.width / 2, self.position.y + self.height / 2)
end

--   === FUNCTIONS ===

---Checks if a point is inside the rectangle.
---@param p vector
---@return boolean
function rect:contains(p)
  local topleft = self:topleft()
  local bottomright = self:bottomright()
  return p.x >= topleft.x and p.x <= bottomright.x and p.y >= topleft.y and p.y <= bottomright.y
end

---Checks if this rectangle intersects another.
---@param other rect
---@return boolean
function rect:intersects(other)
  local thistopleft = self:topleft()
  local thisbottomright = self:bottomright()
  local othertopleft = other:topleft()
  local otherbottomright = other:bottomright()
  return not (
    thistopleft.x > otherbottomright.x
    or thisbottomright.x < othertopleft.x
    or thistopleft.y > otherbottomright.y
    or thisbottomright.y < othertopleft.y
  )
end

---Clones the rectangle.
---@return rect
function rect:clone()
  return rect:new(self.position:clone(), self.width, self.height)
end

---String representation.
function rect:__tostring()
  return string.format(
    'rect(pos=%.2f, %.2f, size=%.2f x %.2f)',
    self.position.x,
    self.position.y,
    self.width,
    self.height
  )
end

return rect
