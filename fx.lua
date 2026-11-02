local Fx = {}

local FLASH_DURATION = 0.3
local SHAKE_DURATION = 0.3
local SHAKE_FORCE = 7

local particles = {}
local texts = {}
local shakeTimer = 0
local flashTimer = 0
local font

function Fx.load(textFont)
    font = textFont
end

function Fx.reset()
    particles = {}
    texts = {}
    shakeTimer = 0
    flashTimer = 0
end

function Fx.burst(x, y, color, amount)
    for _ = 1, amount do
        local angle = math.random() * math.pi * 2
        local speed = math.random(60, 220)
        table.insert(particles, {
            x = x,
            y = y,
            dx = math.cos(angle) * speed,
            dy = math.sin(angle) * speed,
            life = 0.5,
            size = math.random(3, 6),
            color = color
        })
    end
end

function Fx.text(x, y, text, color)
    table.insert(texts, { x = x, y = y, text = text, color = color, life = 0.8 })
end

function Fx.damage()
    shakeTimer = SHAKE_DURATION
    flashTimer = FLASH_DURATION
end

function Fx.update(dt)
    shakeTimer = math.max(0, shakeTimer - dt)
    flashTimer = math.max(0, flashTimer - dt)

    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt
        p.dy = p.dy + 500 * dt
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end

    for i = #texts, 1, -1 do
        local t = texts[i]
        t.life = t.life - dt
        t.y = t.y - 50 * dt
        if t.life <= 0 then
            table.remove(texts, i)
        end
    end
end

function Fx.applyShake()
    if shakeTimer > 0 then
        local force = SHAKE_FORCE * (shakeTimer / SHAKE_DURATION)
        love.graphics.translate(
            (math.random() * 2 - 1) * force,
            (math.random() * 2 - 1) * force
        )
    end
end

function Fx.draw()
    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life / 0.5)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end

    love.graphics.setFont(font)
    for _, t in ipairs(texts) do
        local alpha = math.min(1, t.life / 0.4)
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.printf(t.text, t.x - 100 + 2, t.y + 2, 200, "center")
        love.graphics.setColor(t.color[1], t.color[2], t.color[3], alpha)
        love.graphics.printf(t.text, t.x - 100, t.y, 200, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

function Fx.drawFlash()
    if flashTimer > 0 then
        love.graphics.setColor(0.9, 0.05, 0.05, 0.35 * (flashTimer / FLASH_DURATION))
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
    end
end

return Fx
