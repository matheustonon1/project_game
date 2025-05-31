local Food = {}
Food.__index = Food

-- Carrega os spritesheets
local goodSpriteSheet = love.graphics.newImage("assets/foods.png")
local badSpriteSheet = love.graphics.newImage("assets/badfoods.png")

local goodQuads = {}
local badQuads = {}

-- Cria quads para os bons alimentos (6 sprites)
for i = 0, 5 do
    table.insert(goodQuads, love.graphics.newQuad(i * 32, 0, 32, 32, goodSpriteSheet:getDimensions()))
end

-- Cria quads para os alimentos ruins (6 sprites)
for i = 0, 5 do
    table.insert(badQuads, love.graphics.newQuad(i * 32, 0, 32, 32, badSpriteSheet:getDimensions()))
end

function Food.new(goodChance, speedMultiplier)
    local self = setmetatable({}, Food)
    self.size = 12
    self.good = math.random() < goodChance
    self.speed = 50 * speedMultiplier

    -- Escolhe spriteIndex para bons ou ruins
    self.spriteIndex = math.random(1, 6)

    self.direction = math.random(1, 4)
    if self.direction == 1 then
        self.x = math.random(20, 780)
        self.y = -20
        self.dx, self.dy = 0, 1
    elseif self.direction == 2 then
        self.x = math.random(20, 780)
        self.y = 620
        self.dx, self.dy = 0, -1
    elseif self.direction == 3 then
        self.x = -20
        self.y = math.random(20, 580)
        self.dx, self.dy = 1, 0
    elseif self.direction == 4 then
        self.x = 820
        self.y = math.random(20, 580)
        self.dx, self.dy = -1, 0
    end

    return self
end

function Food:update(dt)
    self.x = self.x + self.dx * self.speed * dt
    self.y = self.y + self.dy * self.speed * dt
end

function Food:draw()
    love.graphics.setColor(1, 1, 1)
    local scale = 1.5
    local origin = 16  -- metade do tamanho original 32/2

    if self.good then
        love.graphics.draw(
            goodSpriteSheet,
            goodQuads[self.spriteIndex],
            self.x,
            self.y,
            0,
            scale,
            scale,
            origin,
            origin
        )
    else
        love.graphics.draw(
            badSpriteSheet,
            badQuads[self.spriteIndex],
            self.x,
            self.y,
            0,
            scale,
            scale,
            origin,
            origin
        )
    end
end


return Food
