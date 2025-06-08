local functions = {}

-- POINT:
---@class point
---@field x number
---@field y number
local point = {
  __index = function(t, k)
    if k == 1 then
      return t.x
    elseif k == 2 then
      return t.y
    end
  end,
}

---Creates a new `xy` point.
---@param x number
---@param y number
---@return point
function point.new(x, y)
  local new = setmetatable({ x = x, y = y }, point)
  return new
end
functions.point = point

-- ALIASES AND TYPES:
---@class object
---@field x number
---@field y number
---@field truesize number
---@field position fun(self: object, x: number, y: number)

---@class entity: object
---@field truesize number
---@field truespeed number
---@field movedirection point

--FUNCTIONS:
---Clamps a number between any two numbers.
---@param value number
---@param min number
---@param max number
---@return number
function functions.clamp(value, min, max)
  return math.min(max, math.max(min, value))
end

---Convert 24-bit colors to float based colors easily.
---@param r number Red
---@param g number Green
---@param b number Blue
---@param a? number *[optional]* Alpha
---@return number, number, number, number?
function functions.color(r, g, b, a)
  if a then
    return r / 255, g / 255, b / 255, a / 255
  else
    return r / 255, g / 255, b / 255
  end
end

---Calculates the magnitude of an *xy* point, i.e. the distance from (0, 0).
---@param x number @ The *x* vector.
---@param y number @ The *y* vector.
---@return number
---@overload fun(point): number
function functions.getmagnitude(x, y)
  if type(x) == 'table' then
    x, y = x.x or x[1], x.y or x[2]
  end
  return math.sqrt(x * x + y * y)
end

---Calculates the distance between 2 *xy* points.
---@overload fun(x1: number, y1: number, x2: number, y2: number): number Pass in *x* & *y* positions individually.
---@overload fun(p1: point, p2: point): number Pass in *xy* positions as tables.
---@return number
function functions.getdistance(x1, y1, x2, y2)
  local ist2 = type(y1) == 'table'
  x2, y2 = ist2 and (y1.x or y1[1]) or x2, ist2 and (y1.y or y1[2]) or y2
  local ist1 = type(x1) == 'table'
  x1, y1 = ist1 and (x1.x or x1[1]) or x1, ist1 and (x1.y or x1[2]) or y1

  return functions.getmagnitude(x2 - x1, y2 - y1)
end

---Determines if 2 entities are colliding.
---@param entity1 entity
---@param entity2 entity
---@return boolean
function functions.colliding(entity1, entity2)
  local overlap_x = (entity1.truesize + entity2.truesize) / 2 - math.abs(entity2.x - entity1.x)
  local overlap_y = (entity1.truesize + entity2.truesize) / 2 - math.abs(entity2.y - entity1.y)

  return overlap_x > 0 and overlap_y > 0
end

---Handles collision between 2 entities.
---@param e1 entity
---@param e2 entity
function functions.handlecollision(e1, e2)
  local dx = e2.x - e1.x
  local dy = e2.y - e1.y
  local xoverlap = (e1.truesize + e2.truesize) / 2 - math.abs(dx)
  local yoverlap = (e1.truesize + e2.truesize) / 2 - math.abs(dy)

  if xoverlap > 0 and yoverlap > 0 then
    local mass1 = e1.truesize
    local mass2 = e2.truesize
    local total_mass = mass1 + mass2

    if xoverlap < yoverlap then
      e1:position(e1.x - ((dx > 0) and 1 or -1) * (mass2 / total_mass) * xoverlap, e1.y)
      e2:position(e2.x + ((dx > 0) and 1 or -1) * (mass1 / total_mass) * xoverlap, e2.y)
    else
      e1:position(e1.x, e1.y - ((dy > 0) and 1 or -1) * (mass2 / total_mass) * yoverlap)
      e2:position(e2.x, e2.y + ((dy > 0) and 1 or -1) * (mass1 / total_mass) * yoverlap)
    end
  end
end

return functions
