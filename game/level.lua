local vector = require("vector")
local Door = require("door")
local Laser = require("laser")

local Level = {}

function Level:new()
    local inst = {
        levelObjects = {}
    }
    self.__index = self
    setmetatable(inst, self)    
    return inst
end

function Level:update(dt)
    --self.world:update(dt)
    for i, o in ipairs(self.levelObjects) do
        o:update(dt)
    end
end

function Level:draw(cellWidth, cellHeight)
    for i, o in ipairs(self.levelObjects) do
        o:draw(cellWidth, cellHeight)
    end
    local occupied = ""
    for y=1, self.height do
        for x=1, self.width do
            local p = self:getP(x, y)
            if p.go then
                occupied = occupied..tostring(x).."/"..tostring(y).."  "
            end
        end
    end
    love.graphics.print(occupied, 0, love.graphics.getHeight()*4/6, 0, 2, 2)
end

function Level:load(data)
    -- clean up the level
    self.levelObjects = {}

    if data then
        -- todo
    else
        -- create a default test level
        self.width, self.height = 32, 24

        -- physics grid
        love.physics.setMeter(game.cellWidth)
        self.world = love.physics.newWorld(0, 0, false)
        self:createPGrid()

        -- door
        local downx, downy = vector.down()
        local door = Door:new(20, 3, 4, downx, downy)
        door:setLevel(self)
        table.insert(self.levelObjects, door)

        -- laser
        local laser = Laser:new(1,1,-1,-1)
        laser:setLevel(self)
        table.insert(self.levelObjects, laser)

    end
end

function Level:createPGrid()
    self.pGrid = {}
    local cellWidth, cellHeight = game.cellWidth, game.cellHeight
    for y=1, self.height do
        for x=1, self.width do
            local p = {}
            --love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
            p.body = love.physics.newBody(self.world, (x-1)*cellWidth+(cellWidth/2), (y-1)*cellHeight+(cellHeight/2))
            p.shape = love.physics.newRectangleShape(cellWidth, cellHeight)
            p.fixture = love.physics.newFixture(p.body, p.shape)
            p.body:setActive(false)
            self:setP(x, y, p)
        end
    end
    print("world with " .. self.world:getBodyCount() .. " bodies created") --to much? probably!
    -- todo: create static bodies for static stuff, and kinematic ones..
end

function Level:getP(x, y)
    return self.pGrid[(y-1)*self.width+x]
end

function Level:setP(x, y, p)
    self.pGrid[(y-1)*self.width +x] = p
end

return Level