---2D vector library written by @AtTheZenith.

---Vector Class with custom functions for versatility.
---@class vector
---@field x number X component
---@field y number Y component
local vector = {}
vector.__index = vector

--   === CONSTANTS ===

---The zero vector (0, 0).
vector.ZERO = setmetatable({ x = 0, y = 0 }, vector)
---The one vector (1, 1).
vector.ONE = setmetatable({ x = 1, y = 1 }, vector)
---Unit up vector (0, 1).
vector.UP = setmetatable({ x = 0, y = 1 }, vector)
---Unit down vector (0, -1).
vector.DOWN = setmetatable({ x = 0, y = -1 }, vector)
---Unit left vector (-1, 0).
vector.LEFT = setmetatable({ x = -1, y = 0 }, vector)
---Unit right vector (1, 0).
vector.RIGHT = setmetatable({ x = 1, y = 0 }, vector)

--   === CONSTRUCTOR ===

---@alias xytable {x:number, y:number}

---Creates a new vector.
---@param x? number
---@param y? number
---@return vector
function vector:new(x, y)
  ---@cast x number
  ---@cast y number
  local v = { x = x or 0, y = y or 0 }
  return setmetatable(v, self)
end

---Creates a new vector from a table or vector
---@param tbl vector|xytable|number[]
---@return vector
function vector:from(tbl)
  if tbl.x and tbl.y then
    ---@cast tbl vector|xytable
    return vector:new(tbl.x, tbl.y)
  else
    ---@cast tbl number[]
    return vector:new(tbl[1], tbl[2])
  end
end

--   === ACCESSORS ===

---Returns the components of the vector.
---@return number, number
function vector:get()
  return self.x, self.y
end

---Sets the components of this vector.
---Accepts:
--- - Two numbers (x, y)
--- - Another vector
--- - A table {x, y}
---@param x number|table|vector
---@param y number|nil
---@return vector self
function vector:set(x, y)
  if type(x) == 'table' and x.get then
    x, y = x:get()
  elseif type(x) == 'table' then
    x, y = x[1], x[2]
  end

  ---@cast x number
  ---@cast y number
  self.x, self.y = x, y
  return self
end

---Returns a clone of this vector.
---@return vector
function vector:clone()
  return vector:new(self.x, self.y)
end

--   === VECTOR PROPERTIES ===

---The length (magnitude) of this vector.
---@return number
function vector:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

---The squared length of this vector.
---Faster than length() if you only need comparisons.
---@return number
function vector:sqrlength()
  return self.x * self.x + self.y * self.y
end

---Distance between this vector and another.
---@param p vector
---@return number
function vector:distance(p)
  return (self - p):length()
end

---Squared distance between this vector and another.
---@param p vector
---@return number
function vector:sqrDistance(p)
  local dx, dy = self.x - p.x, self.y - p.y
  return dx * dx + dy * dy
end

---Returns a normalized (unit length) version of this vector.
---@return vector
function vector:normal()
  local len = self:length()
  return len == 0 and vector.ZERO or vector:new(self.x / len, self.y / len)
end

---Dot product with another vector.
---@param p vector
---@return number
function vector:dot(p)
  return self.x * p.x + self.y * p.y
end

---2D "cross product" with another vector.
---In 2D, returns the scalar z-component of the 3D cross.
---@param p vector
---@return number
function vector:cross(p)
  return self.x * p.y - self.y * p.x
end

---Linear interpolation between this and another vector.
---@param p vector Target vector
---@param t number Alpha (0 → self, 1 → p)
---@return vector
function vector:lerp(p, t)
  return self + (p - self) * t
end

---Angle between this vector and another (in radians).
---@param p vector
---@return number
function vector:angleBetween(p)
  return math.acos(self:dot(p) / (self:length() * p:length()))
end

---Angle of this vector relative to the x-axis (radians).
---@return number
function vector:angle()
  return math.atan2(self.y, self.x)
end

---Rotate this vector by theta radians.
---@param theta number
---@return vector
function vector:rotate(theta)
  local c, s = math.cos(theta), math.sin(theta)
  return vector:new(self.x * c - self.y * s, self.x * s + self.y * c)
end

---Projection of this vector onto another.
---@param onto vector
---@return vector
function vector:projection(onto)
  local u = onto:normal()
  return u * self:dot(u)
end

---Rejection of this vector from another (perpendicular component).
---@param onto vector
---@return vector
function vector:rejection(onto)
  return self - self:projection(onto)
end

---Perpendicular vector (rotated +90°).
---@return vector
function vector:perp()
  return vector:new(-self.y, self.x)
end

--   === UTILITIES ===

---Floor both components.
---@return vector
function vector:floor()
  return vector:new(math.floor(self.x), math.floor(self.y))
end

---Ceil both components.
---@return vector
function vector:ceil()
  return vector:new(math.ceil(self.x), math.ceil(self.y))
end

---Round both components.
---@return vector
function vector:round()
  return vector:new(math.floor(self.x + 0.5), math.floor(self.y + 0.5))
end

---Checks if this vector lies within two bounds.
---@param min vector
---@param max vector
---@return boolean
function vector:within(min, max)
  return self.x >= min.x and self.x <= max.x and self.y >= min.y and self.y <= max.y
end

---Applies a function to both components.
---@param fn fun(v:number):number
---@return vector
function vector:map(fn)
  return vector:new(fn(self.x), fn(self.y))
end

--   === OPERATORS ===

---Addition of two vectors.
---@param a vector
---@param b vector
---@return vector
function vector.__add(a, b)
  return vector:new(a.x + b.x, a.y + b.y)
end

---Subtraction of two vectors.
---@param a vector
---@param b vector
---@return vector
function vector.__sub(a, b)
  return vector:new(a.x - b.x, a.y - b.y)
end

---Unary negation.
---@param a vector
---@return vector
function vector.__unm(a)
  return vector:new(-a.x, -a.y)
end

---Multiplication (vectors*number, number*vectors, or component-wise).
---@param a vector|number
---@param b vector|number
---@return vector
function vector.__mul(a, b)
  if type(b) == 'number' then
    return vector:new(a.x * b, a.y * b)
  elseif type(a) == 'number' then
    return vector:new(a * b.x, a * b.y)
  else
    return vector:new(a.x * b.x, a.y * b.y)
  end
end

---Division (vectors/number or component-wise).
---@param a vector
---@param b vector|number
---@return vector
function vector.__div(a, b)
  if type(b) == 'number' then
    return vector:new(a.x / b, a.y / b)
  else
    return vector:new(a.x / b.x, a.y / b.y)
  end
end

---Check if equal.
---@param a vector
---@param b vector
---@return boolean
function vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

---String representation.
---@param a vector
---@return string
function vector.__tostring(a)
  return string.format('vector(%.4f, %.4f)', a.x, a.y)
end

return vector
