local Player = {}
Player.__index = Player

local KNOCK_DURATION = 0.55
local KNOCK_SPEED = 1320
local KNOCK_FRICTION = 6
local KNOCK_HEIGHT = 60
local KNOCK_SPINS = 2
local SQUASH_DURATION = 0.15

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

    -- Arremesso ao colidir com um lutador
    self.knockTimer = 0
    self.knockVX = 0
    self.knockVY = 0
    self.knockSpin = 1
    self.squashTimer = 0
    self.landed = false

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

    self.squashTimer = math.max(0, self.squashTimer - dt)

    if self:isFlying() then
        self:updateKnockback(dt)
        self.direction = "idle"
    elseif love.keyboard.isDown("up") then
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

function Player:isFlying()
    return self.knockTimer > 0
end

function Player:knockback(nx, ny)
    self.knockTimer = KNOCK_DURATION
    self.knockVX = nx * KNOCK_SPEED
    self.knockVY = ny * KNOCK_SPEED
    self.knockSpin = nx < 0 and -1 or 1
end

function Player:updateKnockback(dt)
    self.knockTimer = self.knockTimer - dt
    self.x = self.x + self.knockVX * dt
    self.y = self.y + self.knockVY * dt

    local friction = math.exp(-KNOCK_FRICTION * dt)
    self.knockVX = self.knockVX * friction
    self.knockVY = self.knockVY * friction

    -- Quica nas paredes em vez de parar seco
    if self.x < self.size / 2 or self.x > 800 - self.size / 2 then
        self.knockVX = -self.knockVX * 0.6
    end
    if self.y < self.size / 2 or self.y > 600 - self.size / 2 then
        self.knockVY = -self.knockVY * 0.6
    end

    if self.knockTimer <= 0 then
        self.knockTimer = 0
        self.squashTimer = SQUASH_DURATION
        self.landed = true
    end
end

function Player:draw()
    local scale = 1.5 + self.spritesize
    local lift, angle = 0, 0

    if self:isFlying() then
        local progress = 1 - self.knockTimer / KNOCK_DURATION
        lift = math.sin(progress * math.pi) * KNOCK_HEIGHT
        angle = (1 - (1 - progress) ^ 2) * KNOCK_SPINS * math.pi * 2 * self.knockSpin
    end

    local shadowSize = 1 - lift / KNOCK_HEIGHT * 0.5
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.ellipse("fill", self.x, self.y + 8 * scale - 2, 6 * scale * shadowSize, 2 * scale * shadowSize)
    love.graphics.setColor(1, 1, 1)

    if not self.visible then return end -- Só desenha se estiver visível

    self.spriteSheet:setFilter("nearest", "nearest")
    -- Achata um pouco ao tocar o chão
    local squash = 1 + 0.3 * (self.squashTimer / SQUASH_DURATION)
    local flip = (self.facingLeft and -scale or scale) * squash
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
        self.y - lift,
        angle,
        flip,
        scale / squash,
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