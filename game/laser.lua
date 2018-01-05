local vector = require("vector")
local denver = require("denver")

local Laser = {}
Laser.tick = 0.05

function Laser:new(x, y, dirX, dirY)
    local inst = {
        x = x,
        y = y,
        dirX = dirX,
        dirY = dirY,
        timeSinceTick = 0,
        hitList = {}
    }
    
    inst.raycastCallback = function(fixture, x,y, xn,yn, fraction)
        local hit = {}
        hit.fixture = fixture
        hit.x,hit.y = x,y
        hit.xn,hit.yn = xn,yn
        hit.fraction = fraction
        table.insert(inst.hitList, hit)
        return 0
    end

    self.__index = self
    setmetatable(inst, self)
    
    return inst
end

function Laser:update(dt)
    self.timeSinceTick = self.timeSinceTick + dt
    if self.timeSinceTick >= self.tick then
        self.timeSinceTick = self.timeSinceTick - self.tick
        local hitListLen = #self.hitList
        for i=1, hitListLen do
            self.hitList[i] = nil
        end
        self.level.world:rayCast(self.x*game.cellWidth, self.y*game.cellHeight, love.mouse.getX(), love.mouse.getY(), self.raycastCallback)
    end
end

function Laser:setLevel(level)
    self.level = level
end

function Laser:draw()
    -- draw it according to points found in update
    love.graphics.setColor(255,0,0,255)
    if #self.hitList > 0 then
        love.graphics.line(self.x*game.cellWidth, self.y*game.cellHeight, self.hitList[1].x, self.hitList[1].y)
    else
        love.graphics.line(self.x*game.cellWidth, self.y*game.cellHeight, love.mouse.getX(), love.mouse.getY())
    end
end

return Laser