local molecule = require 'src.classes.extended.molecule'
local barrier = require 'src.classes.base.barrier'
local tracker = require 'src.classes.base.tracker'
local const = require 'src.constants'
local vector = require 'src.classes.vector'
local slick = require 'src.slick'

local world, moleculeTracker, barrierTracker

local function load()
    ---Init world
    world = slick.newWorld(const.windowsize.x, const.windowsize.y)

    ---Init trackers
    moleculeTracker = tracker:new(world)
    barrierTracker = tracker:new(world)

    --- Create walls
    local wallthickness = 20
    local walls = {
        {
            x = 0,
            y = 0,
            w = const.windowsize.x,
            h = wallthickness
        },
        {
            x = 0,
            y = const.windowsize.y - wallthickness,
            w = const.windowsize.x,
            h = wallthickness
        },
        {
            x = 0,
            y = 0,
            w = wallthickness,
            h = const.windowsize.y
        },
        {
            x = const.windowsize.x - wallthickness,
            y = 0,
            w = wallthickness,
            h = const.windowsize.y
        },
    }

    for _, wall in ipairs(walls) do
        barrierTracker:add(barrier:new {
            position = vector:new(wall.x, wall.y),
            size = vector:new(wall.w, wall.h),
            world = world,
            bodytype = "rectangle",
            image = const.images.rectangle,
        })
    end

    for i = 1, 100 do
        moleculeTracker:add(molecule:new {
            position = vector:new(
                math.random(wallthickness + 20, const.windowsize.x - wallthickness - 20),
                math.random(wallthickness + 20, const.windowsize.y - wallthickness - 20)
            ),
            radius = 10,
            speed = 80,
            world = world,
            image = const.images.circle,
        })
    end
end

local function update(delta)
    moleculeTracker:iterate(function(m)
        m:update(delta)
    end)
end

local function draw()
    barrierTracker:draw()
    moleculeTracker:draw()
end

return {
    name = 'Diffusion',
    load = load,
    update = update,
    draw = draw,
}
