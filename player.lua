local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.size = 18
    self.speed = 200
    self.spriteSheet = love.graphics.newImage("assets/sprites/player.png")
    self.quads = {}
    self.currentFrame = 0
    self.animationTimer = 0
    self.animationSpeed = 0.1
    self.direction = "idle"
    self.lastDirection = "idle"
    self.facingLeft = false
    self.spritesize = 1

    -- Invulnerabilidade
    self.invulnerable = false
    self.invulnerableTimer = 0
    self.blinkTimer = 0
    self.visible = true

    local spriteWidth, spriteHeight = 16, 16
    for i = 0, 9 do
        self.quads[i] = love.graphics.newQuad(i * spriteWidth, 0, spriteWidth, spriteHeight, self.spriteSheet:getDimensions())
    end

    return self
end

function Player:update(dt, isBuffed)
    local buffMultiplier = isBuffed and 1.05 or 1.0
    local moveSpeed = self.speed * buffMultiplier / (self.size / 30)
    local moving = false

    if love.keyboard.isDown("up") then
        self.y = self.y - moveSpeed * dt
        self.direction = "up"
        moving = true
    elseif love.keyboard.isDown("down") then
        self.y = self.y + moveSpeed * dt
        self.direction = "down"
        moving = true
    elseif love.keyboard.isDown("left") then
        self.x = self.x - moveSpeed * dt
        self.direction = "left"
        self.facingLeft = true
        moving = true
    elseif love.keyboard.isDown("right") then
        self.x = self.x + moveSpeed * dt
        self.direction = "right"
        self.facingLeft = false
        moving = true
    else
        self.direction = "idle"
    end

    self.x = math.max(self.size / 2, math.min(800 - self.size / 2, self.x))
    self.y = math.max(self.size / 2, math.min(600 - self.size / 2, self.y))

    if self.direction ~= self.lastDirection then
        if self.direction == "down" then
            self.currentFrame = 1
        elseif self.direction == "left" or self.direction == "right" then
            self.currentFrame = 4
        elseif self.direction == "up" then
            self.currentFrame = 7
        elseif self.direction == "idle" then
            self.currentFrame = 0
        end
        self.lastDirection = self.direction
    end

    if moving then
        self.animationTimer = self.animationTimer + dt
        if self.animationTimer >= self.animationSpeed then
            self.animationTimer = 0
            self.currentFrame = self.currentFrame + 1

            if self.direction == "down" and self.currentFrame > 3 then
                self.currentFrame = 1
            elseif (self.direction == "left" or self.direction == "right") and self.currentFrame > 6 then
                self.currentFrame = 4
            elseif self.direction == "up" and self.currentFrame > 9 then
                self.currentFrame = 7
            end
        end
    end

   if self.invulnerable then
    self.invulnerableTimer = self.invulnerableTimer - dt
    self.blinkTimer = self.blinkTimer + dt

    -- Piscar alternando entre branco e vermelho
    if self.blinkTimer >= 0.1 then
        self.blinkTimer = 0
        self.visible = not self.visible
    end

    if self.invulnerableTimer <= 0 then
        self.invulnerable = false
        self.visible = true
    end
  end

end

function Player:draw()
    if not self.visible then return end -- Só desenha se estiver visível

    self.spriteSheet:setFilter("nearest", "nearest")
    local scale = 1.5 + self.spritesize
    local flip = self.facingLeft and -scale or scale
    local offsetX = self.facingLeft and 16 or 0

    if self.invulnerable then
        love.graphics.setColor(1, 0, 0) -- vermelho
    else
        love.graphics.setColor(1, 1, 1) -- normal
    end

    love.graphics.draw(
        self.spriteSheet,
        self.quads[self.currentFrame],
        self.x,
        self.y,
        0,
        flip,
        scale,
        8,
        8
    )

    love.graphics.setColor(1, 1, 1)
end

function Player:grow()
    self.size = self.size + 0.5
    self.spritesize = self.spritesize + 0.01
end

function Player:collidesWith(food)
    local dx = self.x - food.x
    local dy = self.y - food.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < self.size + food.size
end

function Player:takeDamage()
    if not self.invulnerable then
        self.invulnerable = true
        self.invulnerableTimer = 1
        self.blinkTimer = 0
        self.visible = true -- Começa como visível (vermelho)
        self.Enemy = false
    end
end


return Player