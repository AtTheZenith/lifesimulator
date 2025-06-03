local functions = {}

-- ALIASES AND TYPES:
---@alias point {x: number, y: number} | number[]

-- FUNCTIONS:
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

return functions
