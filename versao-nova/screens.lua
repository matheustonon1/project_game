local Screens = {}

local ORANGE = { 1, 0.55, 0.1 }
local GOLD = { 1, 0.78, 0.2 }
local WHITE = { 1, 1, 1 }
local FADED = { 1, 1, 1, 0.7 }
local EMBER_COUNT = 40

local time = 0 -- Tempo desde que a tela atual abriu
local selected = 1
local embers = {}
local foodSheet, badFoodSheet, enemySheet, enemyQuad

local function newEmber(anywhere)
    return {
        x = math.random(0, 800),
        y = anywhere and math.random(0, 600) or 610,
        speed = math.random(20, 70),
        size = math.random(2, 4),
        phase = math.random() * math.pi * 2
    }
end

function Screens.load()
    foodSheet = love.graphics.newImage("assets/sprites/foods.png")
    badFoodSheet = love.graphics.newImage("assets/sprites/badfoods.png")
    enemySheet = love.graphics.newImage("assets/sprites/enemy.png")
    enemyQuad = love.graphics.newQuad(0, 0, 32, 32, enemySheet:getDimensions())

    for i = 1, EMBER_COUNT do
        embers[i] = newEmber(true)
    end
end

function Screens.enter()
    time = 0
    selected = 1
end

function Screens.update(dt)
    time = time + dt
    for i, ember in ipairs(embers) do
        ember.y = ember.y - ember.speed * dt
        if ember.y < -10 then
            embers[i] = newEmber(false)
        end
    end
end

function Screens.moveSelection(step, count)
    selected = (selected - 1 + step) % count + 1
end

function Screens.selected()
    return selected
end

local function easeOutBack(t)
    t = math.min(1, math.max(0, t))
    local c = 1.70158
    return 1 + (c + 1) * (t - 1) ^ 3 + c * (t - 1) ^ 2
end

local function pulse(speed)
    return 0.8 + 0.2 * math.sin(time * speed)
end

local function printShadow(text, x, y, width, align, color)
    love.graphics.setColor(0, 0, 0, color[4] or 1)
    love.graphics.printf(text, x + 3, y + 3, width, align)
    love.graphics.setColor(color)
    love.graphics.printf(text, x, y, width, align)
    love.graphics.setColor(1, 1, 1)
end

local function drawPanel(x, y, width, height)
    love.graphics.setColor(0.07, 0.04, 0.03, 0.88)
    love.graphics.rectangle("fill", x, y, width, height, 10, 10)
    love.graphics.setColor(ORANGE)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 10, 10)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

local function drawEmbers(color)
    love.graphics.setBlendMode("add")
    for _, ember in ipairs(embers) do
        local alpha = 0.35 + 0.35 * math.sin(time * 3 + ember.phase)
        local drift = math.sin(time + ember.phase) * 12
        love.graphics.setColor(color[1], color[2], color[3], alpha)
        love.graphics.rectangle("fill", ember.x + drift, ember.y, ember.size, ember.size)
    end
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1)
end

local function drawKunai(x, y)
    love.graphics.setColor(GOLD)
    love.graphics.polygon("fill", x + 14, y, x, y - 6, x - 2, y, x, y + 6)
    love.graphics.rectangle("fill", x - 12, y - 1.5, 10, 3)
    love.graphics.circle("line", x - 15, y, 3)
    love.graphics.setColor(1, 1, 1)
end

local function drawOptions(options, x, y, width, spacing)
    love.graphics.setFont(fontOption)
    for i, option in ipairs(options) do
        local rowY = y + (i - 1) * spacing
        if i == selected then
            local textWidth = fontOption:getWidth(option)
            local kunaiX = x + (width - textWidth) / 2 - 26 + math.sin(time * 6) * 3
            drawKunai(kunaiX, rowY + fontOption:getHeight() / 2)
            printShadow(option, x, rowY, width, "center", GOLD)
        else
            printShadow(option, x, rowY, width, "center", FADED)
        end
    end
end

local function drawHint(text)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 574, 800, 26)
    love.graphics.setFont(fontLabel)
    printShadow(text, 0, 580, 800, "center", GOLD)
end

function Screens.drawMenu(options, highScore)
    love.graphics.draw(dojoMenuSprite, 0, 0)
    love.graphics.draw(vignette, 0, 0, 0, 4, 4)
    drawEmbers(ORANGE)

    local logoY = -200 + 360 * easeOutBack(time / 0.8) + math.sin(time * 1.5) * 6
    local logoAngle = math.sin(time * 0.8) * 0.015
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 0.6, 0.2, 0.2 + 0.12 * math.sin(time * 2))
    love.graphics.draw(logo, 400, logoY, logoAngle, 0.37, 0.37, 512, 512)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(logo, 400, logoY, logoAngle, 0.36, 0.36, 512, 512)

    local slide = 1 - easeOutBack((time - 0.3) / 0.5)
    local menuX = 24 - 340 * slide
    drawPanel(menuX, 296, 290, 150)
    drawOptions(options, menuX, 316, 290, 42)

    if highScore > 0 then
        local recordX = 556 + 280 * slide
        drawPanel(recordX, 310, 220, 90)
        love.graphics.setFont(fontLabel)
        printShadow("RECORDE", recordX, 326, 220, "center", WHITE)
        love.graphics.setFont(fontStart)
        printShadow(highScore .. " KG", recordX, 350, 220, "center", GOLD)
    end

    drawHint("SETAS ESCOLHEM  -  ENTER CONFIRMA")
end

local function drawHowToRow(y, title, description)
    love.graphics.setFont(fontFloat)
    printShadow(title, 300, y, 410, "left", GOLD)
    love.graphics.setFont(fontLabel)
    printShadow(description, 300, y + 26, 410, "left", WHITE)
end

function Screens.drawHowTo()
    love.graphics.draw(dojoMenuSprite, 0, 0)
    love.graphics.draw(vignette, 0, 0, 0, 4, 4)
    drawEmbers(ORANGE)

    drawPanel(60, 30, 680, 530)
    love.graphics.setFont(fontTitle)
    printShadow("COMO JOGAR", 60, 44, 680, "center", GOLD)

    love.graphics.draw(foodSheet, 90, 140)
    drawHowToRow(130, "COMIDAS COLORIDAS", "+5 KG, O NINJA CRESCE, GANHA TURBO E ENCHE O ESCUDO")

    love.graphics.draw(badFoodSheet, 90, 240)
    drawHowToRow(230, "COMIDAS CINZENTAS", "TIRAM UMA VIDA, A MENOS QUE A BARRA DE ESCUDO TENHA CARGA")

    love.graphics.draw(enemySheet, enemyQuad, 162, 330, 0, 1.5, 1.5)
    drawHowToRow(330, "LUTADORES", "ARREMESSAM O NINJA PARA LONGE E ZERAM O ESCUDO")

    love.graphics.setFont(fontFloat)
    printShadow("SETAS MOVEM  -  P PAUSA", 60, 440, 680, "center", WHITE)
    printShadow("ENTER VOLTA", 60, 500, 680, "center", { 1, 1, 1, pulse(4) })
end

function Screens.drawPause(options, score)
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(1, 1, 1)

    local scale = 0.8 + 0.2 * easeOutBack(time / 0.25)
    love.graphics.push()
    love.graphics.translate(400, 300)
    love.graphics.scale(scale)
    love.graphics.translate(-400, -300)

    drawPanel(220, 120, 360, 360)
    love.graphics.setFont(fontTitle)
    printShadow("PAUSA", 220, 138, 360, "center", GOLD)
    love.graphics.setFont(fontLabel)
    printShadow("PESO ATUAL: " .. score .. " KG", 220, 216, 360, "center", WHITE)
    drawOptions(options, 220, 262, 360, 48)
    love.graphics.setFont(fontLabel)
    printShadow("P CONTINUA", 220, 442, 360, "center", FADED)

    love.graphics.pop()
end

local function rankFor(score)
    if score < 50 then
        return "APRENDIZ"
    elseif score < 150 then
        return "NINJA GULOSO"
    elseif score < 300 then
        return "MESTRE DO BANQUETE"
    end
    return "LENDA DO DOJO"
end

local function drawStat(label, value, y, color)
    love.graphics.setFont(fontOption)
    printShadow(label, 232, y, 336, "left", WHITE)
    printShadow(value, 232, y, 336, "right", color)
end

-- O ninja nocauteado, deitado no canto, com estrelas girando sobre a cabeça
local function drawKnockedOut(player, x, y)
    local scale = 3 + player.spritesize * 2
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", x, y + 7 * scale * 0.5, 9 * scale, 2 * scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(player.spriteSheet, player.quads[0], x, y, -math.pi / 2, scale, scale, 8, 8)

    love.graphics.setColor(GOLD)
    for i = 1, 3 do
        local angle = time * 3 + i * math.pi * 2 / 3
        local starX = x - 5 * scale + math.cos(angle) * 24
        local starY = y - 7 * scale + math.sin(angle) * 7
        love.graphics.polygon("fill", starX, starY - 4, starX + 4, starY, starX, starY + 4, starX - 4, starY)
    end
    love.graphics.setColor(1, 1, 1)
end

function Screens.drawGameOver(options, stats)
    love.graphics.setColor(0.5, 0.5, 0.55)
    love.graphics.draw(dojoEndSprite, 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(vignette, 0, 0, 0, 4, 4)

    if stats.newRecord then
        drawEmbers(GOLD)
    end

    love.graphics.setFont(fontMenus)
    printShadow("GAME OVER", 0, -110 + 140 * easeOutBack(time / 0.6), 800, "center", GOLD)

    drawPanel(210, 128, 380, 226)
    local counted = math.floor(stats.score * math.min(1, math.max(0, (time - 0.3) / 0.8)))
    drawStat("PESO FINAL", counted .. " KG", 146, WHITE)
    if stats.newRecord then
        drawStat("RECORDE", "NOVO!", 186, { GOLD[1], GOLD[2], GOLD[3], pulse(6) })
    else
        drawStat("RECORDE", stats.highScore .. " KG", 186, GOLD)
    end
    drawStat("COMIDAS", tostring(stats.foodsEaten), 226, WHITE)
    drawStat("TEMPO", string.format("%d:%02d", stats.playTime / 60, stats.playTime % 60), 266, WHITE)
    love.graphics.setFont(fontLabel)
    printShadow(rankFor(stats.score), 210, 318, 380, "center", GOLD)

    drawPanel(210, 368, 380, 112)
    drawOptions(options, 210, 388, 380, 42)

    drawKnockedOut(stats.player, 110, 510)
    drawHint("SETAS ESCOLHEM  -  ENTER CONFIRMA  -  R JOGA DE NOVO")
end

return Screens
