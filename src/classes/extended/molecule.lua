local entity = require 'src.classes.base.entity'
local vector = require 'src.classes.vector'
local const = require 'src.constants'

---@class molecule: entity
local molecule = setmetatable({}, entity)
molecule.__index = molecule
molecule.type = 'molecule'

---Molecular collision filter. They bounce off everything by default.
---@param other any
---@return string
function molecule:filter(other)
    return 'bounce'
end

---Creates a new molecule to be displayed on screen.
---All the following arguments are *optional*.
---@param args {position: vector?, size: nil, radius: number?, speed: number?, image: love.Image?, world: slick.world?, bodytype: "circle"}? **table**  containing the following arguments:
--- `position`: **vector**  The molecule's position.
--- `radius`: **number**    The molecule's radius.
--- `speed`: **number**     The molecule's speed
--- `image`: **love.image** The molecule's sprite.
--- `world`: **slick.world** The collision world.
---@return molecule
function molecule:new(args)
    args = args or {}
    args.bodytype = "circle"
    local new = entity.new(self, args)
    ---@cast new molecule

    -- Start with a random direction
    new.movedirection = vector:new(math.random() * 2 - 1, math.random() * 2 - 1):normal()

    return new
end

---Updates the molecule after an elapsed amount of time.
---@param delta number The elapsed amount of time.
function molecule:update(delta)
    entity.update(self, delta)

    if self.lastcollisioncount and self.lastcollisioncount > 0 then
        for i = 1, self.lastcollisioncount do
            local col = self.lastcollisions[i]

            if col.other and col.other.type == 'molecule' then
                local other = col.other
                local colNormal = vector:new(col.normal.x, col.normal.y) -- other -> self

                local v1 = self.movedirection * self.speed
                local v2 = other.movedirection * other.speed
                local relVel = v1 - v2
                local dot = relVel:dot(colNormal)

                if dot < 0 then
                    local impulse = colNormal * dot
                    local v1_new = v1 - impulse
                    local v2_new = v2 + impulse

                    self.speed = v1_new:length()
                    self.movedirection = v1_new:normal()

                    other.speed = v2_new:length()
                    other.movedirection = v2_new:normal()
                end
            elseif col.extra and col.extra.bounceNormal then
                self.movedirection = vector:new(col.extra.bounceNormal.x, col.extra.bounceNormal.y)
            end
        end
    end
end

return molecule
