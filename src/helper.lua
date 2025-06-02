local functions = {}

---@param r number
---@param g number
---@param b number
---@return number
---@return number
---@return number
function functions.color3(r, g, b)
  return r / 255, g / 255, b / 255
end

---Calculates the magnitude of an *xy* point, i.e. the distance from (0, 0).
---@param x number @ The *x* vector.
---@param y number @ The *y* vector.
---@return number
function functions.getmagnitude(x, y)
  return math.sqrt(x * x + y * y)
end

---Calculates the distance between 2 *xy* points.
---@alias point {x: number, y: number} | number[]
---@overload fun(x1: number, y1: number, x2: number, y2: number): number Pass in *x* & *y* positions individually.
---@overload fun(p1: point, p2: point): number Pass in *xy* positions as tables.
---@return number
function functions.getdistance(x1, y1, x2, y2)
  local ist2 = type(y1) == "table"
  x2, y2 = ist2 and (y1.x or y1[1]) or x2, ist2 and (y1.y or y1[2]) or y2
  local ist1 = type(x1) == "table"
  x1, y1 = ist1 and (x1.x or x1[1]) or x1, ist1 and (x1.y or x1[2]) or y1

  return functions.getmagnitude(x2 - x1, y2 - y1)
end

return functions
