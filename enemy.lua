local Enemy = {}
Enemy.__index = Enemy

-- Carrega o sprite sheet e cria os quadros (quads)
local spriteSheet = love.graphics.newImage("assets/enemy.png")
local quads = {
    down = {
        love.graphics.newQuad(0, 0, 32, 32, spriteSheet:getDimensions()),
        love.graphics.newQuad(32, 0, 32, 32, spriteSheet:getDimensions())
    },
    left = {
        love.graphics.newQuad(64, 0, 32, 32, spriteSheet:getDimensions()),
        love.graphics.newQuad(96, 0, 32, 32, spriteSheet:getDimensions())
    }
}

function Enemy.new(x, y, direction)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    self.width = 32
    self.height = 32
    self.speed = 100
    -- Garantir que `direction` seja válida
    if direction ~= "horizontal" and direction ~= "vertical" then
        error("Direção inválida ao criar inimigo: " .. tostring(direction))
    end
    self.direction = direction == "horizontal" and "left" or "down"
    self.animationTimer = 0
    self.animationFrame = 1
    self.animationSpeed = 0.2
    return self
end


function Enemy:update(dt)
    -- Atualiza a posição do inimigo
    if self.direction == "left" then
        self.x = self.x + self.speed * dt
        if self.x + self.width < 0 or self.x > 800 then
            -- Talvez remover o inimigo ou reiniciá-lo
        end
    else -- self.direction == "down"
        self.y = self.y + self.speed * dt
        if self.y + self.height < 0 or self.y > 600 then
            -- Mesmo tratamento para saída da tela
        end
    end

    -- Atualiza a animação
    self.animationTimer = self.animationTimer + dt
    if self.animationTimer >= self.animationSpeed then
        self.animationTimer = self.animationTimer - self.animationSpeed
        self.animationFrame = self.animationFrame % #quads[self.direction] + 1
    end
end


function Enemy:draw()
    local quad = quads[self.direction] and quads[self.direction][self.animationFrame]
    if quad then
        -- Desenha o sprite com escala de 1.5
        love.graphics.draw(spriteSheet, quad, self.x, self.y, 0, 1.5, 1.5)
    else
        -- Caso algo esteja errado, desenhamos um retângulo vermelho para debug
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
        print("Erro: Direção inválida no inimigo. Direção: " .. tostring(self.direction))
    end
end


function Enemy:collidesWith(player)
    if not player or not player.x or not player.y then return false end
    local closestX = math.max(self.x, math.min(player.x, self.x + self.width))
    local closestY = math.max(self.y, math.min(player.y, self.y + self.height))
    local dx = player.x - closestX
    local dy = player.y - closestY
    return dx * dx + dy * dy < (player.size * player.size)
end

function Enemy:pushPlayer(player)
    local dx = player.x - (self.x + self.width / 2)
    local dy = player.y - (self.y + self.height / 2)
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance == 0 then
        dx, dy = 1, 0
        distance = 1
    end

    local nx, ny = dx / distance, dy / distance
    local knockbackStrength = 10000
    player.x = player.x + nx * knockbackStrength * love.timer.getDelta()
    player.y = player.y + ny * knockbackStrength * love.timer.getDelta()
end

return Enemy