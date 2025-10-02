# Collision System Migration Specification

## Overview

This document outlines the migration from the current custom collision detection system to Love2D's native Box2D physics system, while maintaining the existing lowercase variable naming conventions and accessibility/abstraction design patterns.

## Current System Analysis

### Architecture Overview
The current collision system operates with a hierarchical class structure:
- `object` (base class with position, size, drawing)
- `entity` (adds movement and speed)
- `bot`/`food` (specific implementations)

### Current Collision Implementation

#### Detection System
- **Function**: `utils.colliding(entity1, entity2)`
- **Algorithm**: Axis-Aligned Bounding Box (AABB)
- **Logic**: 
  ```lua
  local overlap_x = (entity1.truesize + entity2.truesize) / 2 - math.abs(entity2.x - entity1.x)
  local overlap_y = (entity1.truesize + entity2.truesize) / 2 - math.abs(entity2.y - entity1.y)
  return overlap_x > 0 and overlap_y > 0
  ```

#### Resolution System
- **Function**: `utils.handlecollision(object1, object2)`
- **Algorithm**: Mass-based separation along minimum overlap axis
- **Features**: 
  - Considers object mass (using `truesize` as mass proxy)
  - Resolves overlaps by pushing objects apart proportionally to mass
  - Chooses minimum overlap axis for separation

#### Integration Points
- **Tracker System**: Uses `tracker:pairwise(utils.handlecollision)` for O(n²) collision checking
- **Food Consumption**: `foodtracker:consumecycle()` handles bot-food collisions
- **Collision Testing Mode**: Dedicated mode for collision system validation

### Naming Conventions Observed
- **Variables**: Consistent lowercase with underscores (`truesize`, `handlecollision`, `movedirection`)
- **Functions**: Lowercase with descriptive names (`colliding`, `handlecollision`, `getmagnitude`)
- **Classes**: Lowercase class names (`bot`, `entity`, `object`, `tracker`)
- **Fields**: Lowercase properties (`x`, `y`, `size`, `energy`, `destroyed`)

### Abstraction Patterns
- **Dual Access**: Objects expose both raw (`size`) and computed (`truesize`) values
- **Method Chaining**: Position setting via `object:position(x, y)`
- **Polymorphic Updates**: Each class level adds specific update behavior
- **Tracker Abstraction**: Generic container with type-specific implementations

## Love2D Physics System Overview

### Core Components

#### World
- **Purpose**: Physics simulation container
- **Creation**: `love.physics.newWorld(gravityX, gravityY, sleep)`
- **Key Methods**: 
  - `world:update(dt)` - Step simulation
  - `world:setCallbacks(beginContact, endContact, preSolve, postSolve)` - Collision callbacks

#### Bodies
- **Types**: `static`, `dynamic`, `kinematic`
- **Creation**: `love.physics.newBody(world, x, y, type)`
- **Key Methods**: 
  - `body:setPosition(x, y)` - Set position
  - `body:setLinearVelocity(vx, vy)` - Set velocity
  - `body:applyForce(fx, fy)` - Apply forces
  - `body:setMass(mass)` - Set mass

#### Shapes
- **Types**: `CircleShape`, `RectangleShape`, `PolygonShape`
- **Creation**: `love.physics.newCircleShape(radius)`, `love.physics.newRectangleShape(width, height)`

#### Fixtures
- **Purpose**: Attach shapes to bodies with material properties
- **Creation**: `love.physics.newFixture(body, shape, density)`
- **Properties**: density, friction, restitution, sensor
- **User Data**: `fixture:setUserData(data)` for object association

## Migration Strategy

### Full Transition Approach
This plan implements a complete migration to Love2D physics with **no deprecated code**. All `truesize` references and manual collision detection are removed immediately, replaced with image-based physics sizing.

### Image-Based Physics Sizing
Since all sprites are 40x40 pixels, the physics system will:
- Use image dimensions directly for collision shapes
- Scale physics bodies based on object `size` multiplier
- Eliminate `truesize` completely from the start

### Phase 1: Core Infrastructure

#### 1.1 Physics World Setup
Create physics world manager in new file `src/physics.lua`:

```lua
local physics = {}

-- world configuration
physics.world = nil
physics.gravity_x = 0
physics.gravity_y = 0
physics.meter = 64 -- pixels per meter
physics.baseimagesize = 40 -- all sprites are 40x40

function physics.init()
  physics.world = love.physics.newWorld(physics.gravity_x, physics.gravity_y, true)
  physics.world:setCallbacks(physics.begincontact, physics.endcontact, nil, nil)
end

function physics.update(dt)
  if physics.world then
    physics.world:update(dt)
  end
end

function physics.begincontact(a, b, coll)
  local userdata_a = a:getUserData()
  local userdata_b = b:getUserData()
  
  if userdata_a and userdata_b then
    physics.handlecollision(userdata_a, userdata_b, coll)
  end
end

function physics.endcontact(a, b, coll)
  -- handle collision end if needed
end

function physics.handlecollision(object1, object2, collision)
  -- handle collision logic
  if (object1.type == 'bot' and object2.type == 'food') or
     (object1.type == 'food' and object2.type == 'bot') then
    local bot = object1.type == 'bot' and object1 or object2
    local food = object1.type == 'food' and object1 or object2
    food:feed(bot)
  end
end

return physics
```

#### 1.2 Rewritten Object Base Class
Completely rewrite `src/classes/object.lua` with physics-first approach:

```lua
local const = require 'src.const'
local physics = require 'src.physics'

---@class object
---@field destroyed boolean
---@field x number
---@field y number
---@field size number
---@field image love.Image
---@field body love.Body
---@field fixture love.Fixture
---@field shape love.Shape
---@field type string
local object = {}
object.__index = object

function object:new(args)
  args = args or {}

  local new = setmetatable({}, self)
  new.x = args.x or 0
  new.y = args.y or 0
  new.size = args.size or 1
  new.image = args.image or const.images.object
  new.destroyed = false
  new.type = args.type or 'object'
  
  -- physics properties
  new.body = nil
  new.fixture = nil
  new.shape = nil
  new.bodytype = args.bodytype or 'dynamic'

  return new
end

function object:getphysicsradius()
  -- base radius on image size and size multiplier
  return (physics.baseimagesize * self.size) / 2
end

function object:createphysicsbody(world)
  if not world then return end
  
  -- create body
  self.body = love.physics.newBody(world, self.x, self.y, self.bodytype)
  
  -- create circular shape based on image size and size multiplier
  local radius = self:getphysicsradius()
  self.shape = love.physics.newCircleShape(radius)
  
  -- create fixture
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)
  
  -- sync initial position
  self:syncphysics()
end

function object:syncphysics()
  if self.body then
    -- sync position from physics body to object
    self.x, self.y = self.body:getPosition()
  end
end

function object:position(x, y)
  if type(x) == 'table' then
    x, y = x.x or x[1], x.y or x[2]
  end
  
  self.x, self.y = x, y
  
  -- update physics body if exists
  if self.body then
    self.body:setPosition(x, y)
  end
end

function object:updatephysicssize()
  if self.body and self.fixture and self.shape then
    -- recreate fixture with new size
    local density = self.fixture:getDensity()
    local category = self.fixture:getCategory()
    local mask = self.fixture:getMask()
    local issensor = self.fixture:isSensor()
    
    self.fixture:destroy()
    
    local radius = self:getphysicsradius()
    self.shape = love.physics.newCircleShape(radius)
    self.fixture = love.physics.newFixture(self.body, self.shape, density)
    self.fixture:setUserData(self)
    self.fixture:setCategory(category)
    self.fixture:setMask(mask)
    self.fixture:setSensor(issensor)
    
    self.body:resetMassData()
  end
end

function object:draw()
  local radius = self:getphysicsradius()
  local scale = (radius * 2) / physics.baseimagesize
  love.graphics.draw(self.image, self.x - radius, self.y - radius, 0, scale, scale)
end

function object:destroy()
  self.destroyed = true
  self.draw = function() end
  
  -- cleanup physics body
  if self.fixture then
    self.fixture:destroy()
    self.fixture = nil
  end
  if self.body then
    self.body:destroy()
    self.body = nil
  end
  self.shape = nil
end

return object
```

#### 1.3 Rewritten Entity Class
Completely rewrite `src/classes/entity.lua` for physics-only movement:

```lua
local const = require 'src.const'
local utils = require 'src.utils'
local object = require 'src.classes.object'
local magnitude = utils.getmagnitude
local point = utils.point

---@class entity: object
---@field speed number
---@field movedirection point
local entity = setmetatable({}, object)
entity.__index = entity

function entity:new(args)
  args = args or {}
  local new = object.new(self, args)
  ---@cast new entity
  
  new.speed = args.speed or 1
  new.movedirection = point:new(0, 0)
  new.type = args.type or 'entity'
  
  return new
end

function entity:move(x, y)
  local mag = magnitude(x, y)
  mag = mag == 0 and 1 or mag
  self.movedirection.x = x / mag
  self.movedirection.y = y / mag
  
  -- apply velocity to physics body (physics-only, no fallback)
  if self.body then
    local truespeed = self.speed * const.trueentityspeed
    local vel_x = self.movedirection.x * truespeed
    local vel_y = self.movedirection.y * truespeed
    self.body:setLinearVelocity(vel_x, vel_y)
  end
end

function entity:update(delta)
  -- always sync from physics simulation - no manual movement
  self:syncphysics()
end

return entity
```

#### 1.4 Rewritten Bot Class
Completely rewrite `src/classes/bot.lua` with physics-first approach:

```lua
local const = require 'src.const'
local entity = require 'src.classes.entity'
local utils = require 'src.utils'
local clamp = utils.clamp
local magnitude = utils.getmagnitude

---@class bot: entity
---@field range number
---@field energy number
---@field team number
local bot = setmetatable({}, entity)
bot.__index = bot

function bot:new(args)
  args = args or {}
  local new = entity.new(self, args)
  ---@cast new bot

  new.size = clamp(args.size or 1, const.minbotsize, const.maxbotsize)
  new.range = clamp(args.range or 1, const.minbotrange, const.maxbotrange)
  new.energy = (args.energy or 1) * const.maxenergy
  new.team = args.team or 0
  new.type = 'bot'
  
  -- set appropriate image based on team
  if new.team == 1 then
    new.image = const.images.bluebot
  elseif new.team == 2 then
    new.image = const.images.orangebot
  else
    new.image = const.images.bluebot
  end

  return new
end

function bot:consume(energy, reset)
  if not reset then
    self.energy = self.energy + energy
  else
    self.energy = energy
  end
end

function bot:update(delta)
  -- sync position from physics
  entity.update(self, delta)
  
  -- energy consumption based on size and movement
  local radius = self:getphysicsradius()
  local physicssize = radius * 2
  
  self:consume(
    (
      (physicssize / const.baseimagesize)^2 * 10  -- size-based consumption
      + magnitude(self.movedirection) * self.speed * self.speed * 2  -- movement cost
      + self.range * self.range * math.sqrt(self.range) * 3  -- range cost
    ) * delta * -2
  )
end

function bot:createphysicsbody(world)
  entity.createphysicsbody(self, world)
  
  if self.fixture then
    -- set density based on size
    local mass = self.size
    self.fixture:setDensity(mass)
    self.body:resetMassData()
    
    -- collision categories
    self.fixture:setCategory(1)  -- bot category
    self.fixture:setMask(2, 3)   -- collides with food and other bots
  end
end

function bot:reproduce()
  if self.energy > const.reproductionmin then
    self:consume(-const.reproductioncost)
    return bot:new {
      x = self.x,
      y = self.y,
      size = self.size + (math.random() / 5 - 0.1),
      speed = self.speed + (math.random() / 2.5 - 0.2),
      range = self.range + (math.random() / 5 - 0.1),
      energy = self.energy / 2 / const.maxenergy,
      team = math.random(3),
    }
  end
end

return bot
```

#### 1.5 Rewritten Food Class
Completely rewrite `src/classes/food.lua` as physics-first:

```lua
local const = require 'src.const'
local object = require 'src.classes.object'

---@class food: object
---@field energy number
local food = setmetatable({}, object)
food.__index = food

function food:new(args)
  args = args or {}
  local new = object.new(self, args)
  ---@cast new food

  new.size = args.size or 1
  new.energy = (args.energy or 1) * const.foodenergy
  new.image = args.image or const.images.food
  new.bodytype = 'static'  -- food doesn't move
  new.type = 'food'

  return new
end

function food:createphysicsbody(world)
  object.createphysicsbody(self, world)
  
  if self.fixture then
    -- food is sensor for consumption detection
    self.fixture:setSensor(true)
    self.fixture:setCategory(2)  -- food category
  end
end

function food:feed(bot)
  bot:consume(self.energy)
  self.energy = 0
  self:destroy()
end

return food
```

### Phase 2: Complete Tracker System Rewrite

#### 2.1 Physics-Only Tracker
Completely rewrite `src/classes/tracker.lua` removing all manual collision code:

```lua
local const = require 'src.const'

---@class tracker
---@field type string
---@field objects any[]
---@field physicsworld love.World
local tracker = {}
tracker.__index = tracker

function tracker:new()
  local new = setmetatable({}, self)

  new.type = 'normal'
  new.objects = {}
  new.physicsworld = nil

  return new
end

function tracker:initphysics(world)
  self.physicsworld = world
  
  -- initialize physics for existing objects
  for _, obj in ipairs(self.objects) do
    obj:createphysicsbody(world)
  end
end

function tracker:add(object)
  table.insert(self.objects, object)
  
  -- auto-create physics body if world exists
  if self.physicsworld then
    object:createphysicsbody(self.physicsworld)
  end
end

function tracker:remove(object)
  local objects = self.objects
  for i = 1, #objects do
    if objects[i] == object then
      objects[i] = objects[#objects]
      objects[#objects] = nil
      return
    end
  end
end

function tracker:get(index)
  return self.objects[index]
end

function tracker:iterate(func)
  for _, v in next, self.objects do
    func(v)
  end
end

-- NO MORE PAIRWISE - physics handles all collision detection

function tracker:clean()
  local objects = self.objects
  for i = #objects, 1, -1 do
    if objects[i].destroyed then
      objects[i] = objects[#objects]
      objects[#objects] = nil
    end
  end
end

function tracker:draw()
  for _, v in next, self.objects do
    v:draw()
  end
end

---@class bottracker: tracker
local bottracker = setmetatable({}, { __index = tracker })
bottracker.__index = bottracker

function bottracker:new()
  local new = tracker.new(self)
  new.type = 'bot'
  ---@cast new bottracker
  return new
end

function bottracker:update(delta)
  for _, v in next, self.objects do
    v:update(delta)
    if v.energy <= 0 then
      v:destroy()
      self:remove(v)
    end
  end
end

function bottracker:reproducecycle()
  local offspring = {}
  for _, v in next, self.objects do
    local new = v:reproduce()
    if new then
      table.insert(offspring, new)
    end
  end
  for _, v in next, offspring do
    self:add(v)  -- use add() to auto-create physics body
  end
end

---@class foodtracker: tracker
local foodtracker = setmetatable({}, { __index = tracker })
foodtracker.__index = foodtracker

function foodtracker:new()
  local new = tracker.new(self)
  new.type = 'food'
  ---@cast new foodtracker
  return new
end

function foodtracker:generate(x, y, size, energy)
  local food = require('src.classes.food')
  self:add(food:new { x = x, y = y, size = size, energy = energy })
end

-- NO MORE CONSUMECYCLE - physics callbacks handle consumption

return { tracker = tracker, bottracker = bottracker, foodtracker = foodtracker }
```

### Phase 3: Integration Points

#### 3.1 Main Loop Integration
Update `main.lua` to initialize physics:

```lua
local const = require 'src.const'
local utils = require 'src.utils'
local physics = require 'src.physics'
local color = utils.color

local modes = {
  foodchaser = require 'src.modes.foodtester',
  collisiontester = require 'src.modes.collisiontester',
}

local currentmode = modes.collisiontester

function love.load()
  -- Window Setup
  love.window.setTitle(const.windowtitle)
  love.window.setMode(const.windowsize[1], const.windowsize[2], { borderless = false, resizable = true })
  love.graphics.setBackgroundColor(color(60, 60, 60, 60))
  
  -- Initialize physics
  physics.init()
end

function love.update(delta)
  -- Update dimensions
  local w, h = love.window.getMode()
  const.windowsize[1], const.windowsize[2] = w, h
  
  -- Update physics first, then mode
  physics.update(delta)
  currentmode.update(delta)
end

function love.draw()
  currentmode.draw()
end
```

#### 3.2 Updated Collision Tester Mode
Completely rewrite `src/modes/collisiontester.lua` without manual collision:

```lua
local bot = require 'src.classes.bot'
local const = require 'src.const'
local utils = require 'src.utils'
local tracker = require 'src.classes.tracker'
local physics = require 'src.physics'
local color = utils.color
local bottracker = tracker.bottracker

---@type bottracker
local tracker1 = bottracker:new()

-- initialize physics for tracker
tracker1:initphysics(physics.world)

-- create initial bot
tracker1:add(bot:new {
  x = 400,
  y = 300,
  team = math.random(2),
})

-- setup cycle for reproduction
for _ = 1, 10 do
  tracker1:iterate(function(v)
    v:move(math.random() * 2 - 1, math.random() * 2 - 1)
  end)
  tracker1:update(0.001)
  tracker1:iterate(function(v)
    v:consume(9000, true)
  end)
  tracker1:reproducecycle()
end

local time = love.timer.getTime()
local x = 200

local function update(delta)
  if love.timer.getTime() > time + 2 then
    time = love.timer.getTime()
    x = x == 200 and 600 or 200
  end
  
  tracker1:iterate(function(v)
    v:move(x - v.x, 300 - v.y)
    v:update(delta)
  end)
  
  -- NO MORE MANUAL COLLISION - physics handles everything
end

local function draw()
  tracker1:draw()
end

return {
  name = 'Collision Tester',
  update = update,
  draw = draw,
}
```

### Phase 4: Utils and Constants Cleanup

#### 4.1 Clean Utils - Remove All Manual Collision Code
Completely rewrite `src/utils.lua` removing collision functions:

```lua
local utils = {}

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
function point:new(x, y)
  local new = setmetatable({ x = x, y = y }, self)
  return new
end
utils.point = point

--FUNCTIONS:
---Clamps a number between any two numbers.
---@param value number
---@param min number
---@param max number
---@return number
function utils.clamp(value, min, max)
  return math.min(max, math.max(min, value))
end

---Convert 24-bit colors to float based colors easily.
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

---Calculates the magnitude of an *xy* point, i.e. the distance from (0, 0).
---@param x number @ The *x* vector.
---@param y number @ The *y* vector.
---@return number
---@overload fun(point): number
function utils.getmagnitude(x, y)
  if type(x) == 'table' then
    x, y = x.x or x[1], x.y or x[2]
  end
  return math.sqrt(x * x + y * y)
end

---Calculates the distance between 2 *xy* points.
---@overload fun(x1: number, y1: number, x2: number, y2: number): number Pass in *x* & *y* positions individually.
---@overload fun(p1: point, p2: point): number Pass in *xy* positions as tables.
---@return number
function utils.getdistance(x1, y1, x2, y2)
  local ist2 = type(y1) == 'table'
  x2, y2 = ist2 and (y1.x or y1[1]) or x2, ist2 and (y1.y or y1[2]) or y2
  local ist1 = type(x1) == 'table'
  x1, y1 = ist1 and (x1.x or x1[1]) or x1, ist1 and (x1.y or x1[2]) or y1

  return utils.getmagnitude(x2 - x1, y2 - y1)
end

-- REMOVED: utils.colliding() - physics handles collision detection
-- REMOVED: utils.handlecollision() - physics handles collision resolution

return utils
```

#### 4.2 Update Constants - Remove truesize Dependencies
Update `src/const.lua` for image-based physics:

```lua
local utils = require 'src.utils'
local point = utils.point

---@enum consts
local consts = {
  windowtitle = 'Life Simulator v0.6.0',
  framerate = 0,
  dimensions = point:new(love.window.getDesktopDimensions(0)),
  windowsize = point:new(800, 500),

  -- Physics-based sizing (removed trueobjectsize)
  baseimagesize = 40,       -- all images are 40x40
  trueentityspeed = 120,
  truebotrange = 90,
  
  -- Updated size constraints (now in multipliers, not pixels)
  minbotsize = 0.5,         -- 0.5x image size = 20px
  maxbotsize = 3.0,         -- 3.0x image size = 120px
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
```

#### 4.3 Updated Food Tester Mode
Update `src/modes/foodtester.lua` to use physics system:

```lua
local bot = require 'src.classes.bot'
local const = require 'src.const'
local utils = require 'src.utils'
local tracker = require 'src.classes.tracker'
local physics = require 'src.physics'
local color = utils.color
local bottracker = tracker.bottracker
local foodtracker = tracker.foodtracker

---@type bottracker
local bottracker1 = bottracker:new()
---@type foodtracker
local foodtracker1 = foodtracker:new()

-- initialize physics for both trackers
bottracker1:initphysics(physics.world)
foodtracker1:initphysics(physics.world)

-- create initial entities
for i = 1, 20 do
  bottracker1:add(bot:new {
    x = math.random(const.windowsize[1]),
    y = math.random(const.windowsize[2]),
    team = math.random(2),
  })
end

local foodtimer = 0

local function update(delta)
  bottracker1:update(delta)
  bottracker1:reproducecycle()
  bottracker1:clean()
  foodtracker1:clean()
  
  -- spawn food periodically
  foodtimer = foodtimer + delta
  if foodtimer > const.foodcooldown then
    foodtimer = 0
    if #foodtracker1.objects < const.foodstart then
      foodtracker1:generate(
        math.random(const.windowsize[1]),
        math.random(const.windowsize[2]),
        const.foodsize,
        const.foodenergy
      )
    end
  end
  
  -- NO MORE MANUAL CONSUMECYCLE - physics handles it
end

local function draw()
  bottracker1:draw()
  foodtracker1:draw()
end

return {
  name = 'Food Chaser',
  update = update,
  draw = draw,
}
```

## Implementation Order

### Step 1: Create Physics System
1. Create `src/physics.lua` with physics world management
2. Update `main.lua` to initialize physics

### Step 2: Rewrite Core Classes (Physics-First)
1. Completely rewrite `src/classes/object.lua` - image-based physics sizing
2. Completely rewrite `src/classes/entity.lua` - physics-only movement 
3. Completely rewrite `src/classes/bot.lua` - remove truesize, use physics radius
4. Completely rewrite `src/classes/food.lua` - static physics bodies

### Step 3: Rewrite Tracker System
1. Completely rewrite `src/classes/tracker.lua` - remove all pairwise collision
2. Remove `consumecycle()` method entirely

### Step 4: Clean Supporting Files
1. Clean `src/utils.lua` - remove collision functions completely
2. Update `src/const.lua` - remove truesize dependencies
3. Update both mode files to use physics-only approach

### Step 5: Testing
1. Test collision detection accuracy
2. Test performance improvements
3. Verify all functionality preserved

## Implementation Guidelines

### Variable Naming Consistency
- Maintain lowercase with underscores: `physics_world`, `body_type`, `collision_data`
- Physics-specific properties: `physicsmass`, `physicsworld`, `bodytype`
- Method names: `createphysicsbody()`, `syncphysics()`, `initphysics()`

### Accessibility Patterns
- **Direct Access**: Keep existing `x`, `y` properties for compatibility
- **Computed Properties**: Add `physics_x`, `physics_y` for raw physics values
- **Dual Methods**: Provide both `position()` and `setphysicsposition()` methods

### Abstraction Maintenance
- **Transparent Migration**: Existing code should work without changes initially
- **Layered Implementation**: Physics as optional enhancement, not requirement
- **Backward Compatibility**: Keep `utils.colliding()` and `utils.handlecollision()` available

### Performance Considerations
- **Selective Physics**: Not all objects need full physics (e.g., UI elements)
- **Spatial Optimization**: Leverage Box2D's built-in spatial partitioning
- **Body Pooling**: Reuse physics bodies for frequently created/destroyed objects

## Full Transition Timeline

### Day 1: Physics Infrastructure
- Create `src/physics.lua`
- Update `main.lua` to initialize physics
- Commit and test basic physics world creation

### Day 2: Core Object Classes
- Rewrite `src/classes/object.lua` with image-based sizing
- Rewrite `src/classes/entity.lua` for physics-only movement
- Test basic object creation and physics body initialization

### Day 3: Specialized Classes
- Rewrite `src/classes/bot.lua` without truesize
- Rewrite `src/classes/food.lua` as static physics bodies
- Test bot creation, movement, and energy consumption

### Day 4: Tracker System
- Rewrite `src/classes/tracker.lua` removing all manual collision
- Test object tracking with automatic physics body creation
- Verify reproduction and cleanup systems

### Day 5: Final Cleanup
- Clean `src/utils.lua` - remove collision functions
- Update `src/const.lua` - remove truesize constants
- Update mode files for physics-only approach
- Final integration testing

## Testing Strategy

### Functional Testing
1. **Collision Accuracy**: Compare physics vs manual collision results
2. **Performance Testing**: Benchmark O(n²) vs Box2D spatial optimization
3. **Integration Testing**: Ensure bot behavior remains consistent
4. **Regression Testing**: Verify existing functionality preserved

### Validation Criteria
- **Collision Detection**: Physics-based collision detection working correctly
- **Performance**: Significant improvement in collision performance (O(n²) → O(n log n))
- **Code Cleanliness**: Complete removal of deprecated collision code
- **Image-Based Sizing**: All objects sized based on 40x40 image dimensions
- **Physics Integration**: All objects use physics bodies for movement and collision
- **No Backward Compatibility**: Clean break from old system - no deprecated code remaining

## Benefits of Migration

### Performance Improvements
- **Spatial Optimization**: Box2D uses efficient spatial data structures
- **Native Implementation**: C++ performance vs Lua loops
- **Scalability**: Better performance with larger entity counts

### Feature Enhancements
- **Realistic Physics**: Access to forces, impulses, joints
- **Advanced Collision**: Different collision types (sensor, solid)
- **Material Properties**: Friction, restitution, density
- **Collision Filtering**: Category-based collision control

### Maintainability
- **Industry Standard**: Box2D is well-documented and stable
- **Built-in Features**: Many collision scenarios handled automatically
- **Debugging Tools**: Love2D provides physics debug drawing
- **Community Support**: Large Box2D community and resources

## Potential Challenges

### Integration Complexity
- **Coordinate Systems**: Box2D uses different coordinate conventions
- **Unit Conversion**: Need to convert between pixels and meters
- **Synchronization**: Keeping object state in sync with physics bodies

### Behavioral Changes
- **Movement Feel**: Physics simulation may feel different than direct control
- **Collision Response**: Box2D collision resolution may differ from current system
- **Performance Characteristics**: Different performance profile during transition

### Breaking Changes (Intentional)
- **Complete API Overhaul**: No backward compatibility - clean transition
- **Removed Properties**: `truesize` completely eliminated
- **Removed Functions**: `utils.colliding()` and `utils.handlecollision()` deleted
- **Removed Methods**: `tracker:pairwise()` and `foodtracker:consumecycle()` deleted
- **Physics Required**: All objects must have physics bodies - no fallback
- **Image-Based Sizing**: Size calculations based on 40x40 image dimensions

## Conclusion

This migration will significantly improve collision detection performance while maintaining the existing lowercase variable naming conventions and accessibility/abstraction patterns. The phased approach ensures minimal disruption to current functionality while enabling advanced physics features for future development.

The key to success is complete elimination of the old system and full adoption of physics-based collision detection with image-based sizing.

### Benefits of Full Transition

**Clean Architecture:**
- Complete elimination of redundant collision code
- Single physics-based collision system
- Image-based sizing provides consistent visual/collision relationship
- No deprecated code to maintain

**Improved Performance:**
- Box2D's spatial partitioning replaces O(n²) collision detection
- Native C++ collision detection vs Lua loops
- Automatic collision resolution vs manual separation
- Physics engine optimizations for large entity counts

**Enhanced Maintainability:**
- Single source of truth for collision detection
- Industry-standard physics system
- Automatic collision callbacks vs manual detection loops
- Cleaner, more focused codebase without deprecated functionality

**Future-Proof Design:**
- Foundation for advanced physics features (forces, joints, materials)
- Scalable collision system for larger simulations
- Standard physics debugging tools available
- Community support for Box2D physics system
