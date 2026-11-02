love.graphics.setDefaultFilter("nearest", "nearest")

local Player = require("player")
local Food = require("food")
local Enemy = require("enemy")
local Fx = require("fx")
local Screens = require("screens")

local enemies = {}
local enemySpawnTimer = 0
local player
local foods = {}
local score = 0
local lives = 3
local gameOver = false
local buffTimer = 0
local spawnTimer = 0
local spawnInterval = 0.4
local foodSpeedMultiplier = 0.5
local goodFoodMeter = 0
local goodFoodThreshold = 2
local highScore = 0
local gameState = "menu" -- menu, jogo, pause
local x = math.random(100, 700)
local y = math.random(100, 500)
local showText = true
local newRecord = false
local fade = 1
local scorePop = 0

local GOLD = { 1, 0.78, 0.2 }
local CYAN = { 0.3, 0.85, 1 }
local RED = { 1, 0.3, 0.25 }
local GREY = { 0.6, 0.6, 0.6 }
local DUST = { 1, 1, 1 }

local MENU_OPTIONS = { "JOGAR", "COMO JOGAR", "SAIR" }
local PAUSE_OPTIONS = { "CONTINUAR", "REINICIAR", "MENU PRINCIPAL" }
local END_OPTIONS = { "JOGAR DE NOVO", "MENU PRINCIPAL" }

local foodsEaten = 0
local playTime = 0

function saveHighScore(score)
    love.filesystem.write("highscore.txt", tostring(score))
end

local function newVignette()
    local data = love.image.newImageData(200, 150)
    data:mapPixel(function(px, py)
        local dx, dy = (px - 100) / 100, (py - 75) / 75
        local alpha = math.max(0, math.sqrt(dx * dx + dy * dy) - 0.7) * 0.6
        return 0.12, 0.05, 0, alpha
    end)
    local image = love.graphics.newImage(data)
    image:setFilter("linear", "linear")
    return image
end

function resetGame()
    audGO:stop()
    Fx.reset()
    newRecord = false
    fade = 1
    scorePop = 0
    foodsEaten = 0
    playTime = 0
    player = Player.new(400, 300)
    foods = {}
    score = 0
    lives = 3
    gameOver = false
    buffTimer = 0
    spawnTimer = 0
    spawnInterval = 0.4
    foodSpeedMultiplier = 3
    goodFoodMeter = 0
    goodFoodThreshold = 2
    enemies = {}
    enemySpawnTimer = 0
end

function love.load()
    local favicon = love.image.newImageData("assets/favicon.png")
    love.window.setIcon(favicon)

    love.window.setTitle("Kitchen Kunai")
    love.window.setMode(800, 600)

    fontStart = love.graphics.newFont("assets/font/start.ttf", 24)
    fontMenus = love.graphics.newFont("assets/font/menus.ttf", 76) 
    fontMenus:setFilter("linear", "linear")
    fontLabel = love.graphics.newFont("assets/font/start.ttf", 12)
    fontLabel:setLineHeight(1.4)
    fontFloat = love.graphics.newFont("assets/font/start.ttf", 16)
    fontOption = love.graphics.newFont("assets/font/start.ttf", 20)
    fontTitle = love.graphics.newFont("assets/font/menus.ttf", 56)
    fontTitle:setFilter("linear", "linear")
    Fx.load(fontFloat)

    love.graphics.setBackgroundColor(0.2, 0.27, 0.45)
    vignette = newVignette()
    Screens.load()
    Screens.enter()
    highScore = tonumber(love.filesystem.read("highscore.txt") or "") or 0

    logo = love.graphics.newImage("assets/kitchen-kunai-logo.png")
    logo:setFilter("linear", "linear")

    heart = love.graphics.newImage("assets/sprites/gui/heart.png")
    heart:setFilter("linear", "linear")

    dojoSprite = love.graphics.newImage("assets/backgrounds/dojoBackground.jpg")
    dojoMenuSprite = love.graphics.newImage("assets/backgrounds/kk-start.jpg")
    dojoEndSprite = love.graphics.newImage("assets/backgrounds/kk-go.jpg")

    audGameplay = love.audio.newSource("assets/aud/OST/gameplay.wav", "stream")
    audGameplay:setVolume(0.10)
    audGameplay:setLooping(true)

    audGO = love.audio.newSource("assets/aud/OST/gameover.wav", "stream")
    audGO:setLooping(false)
    audGO:setVolume(0.05)
end

local function endGame()
    gameOver = true
    fade = 1
    Screens.enter()
    if score > highScore then
        highScore = score
        newRecord = true
        saveHighScore(score)
    end
end

local function startGame()
    resetGame()
    gameState = "jogo"
end

local function goToMenu()
    resetGame()
    gameState = "menu"
    Screens.enter()
end

local function choose(option)
    if option == "JOGAR" or option == "JOGAR DE NOVO" or option == "REINICIAR" then
        startGame()
    elseif option == "COMO JOGAR" then
        gameState = "comojogar"
        Screens.enter()
    elseif option == "CONTINUAR" then
        gameState = "jogo"
    elseif option == "MENU PRINCIPAL" then
        goToMenu()
    elseif option == "SAIR" then
        love.event.quit()
    end
end

local function currentOptions()
    if gameState == "menu" then
        return MENU_OPTIONS
    elseif gameState == "pause" then
        return PAUSE_OPTIONS
    elseif gameState == "jogo" and gameOver then
        return END_OPTIONS
    end
end

function love.keypressed(key)
    local options = currentOptions()
    if options then
        if key == "up" then
            Screens.moveSelection(-1, #options)
        elseif key == "down" then
            Screens.moveSelection(1, #options)
        elseif key == "return" or key == "kpenter" then
            choose(options[Screens.selected()])
            return
        end
    end

    if gameState == "comojogar" then
        if key == "return" or key == "kpenter" or key == "escape" then
            gameState = "menu"
            Screens.enter()
        end
    elseif gameState == "jogo" then
        if gameOver then
            if key == "r" then
                startGame()
            end
        elseif key == "p" or key == "escape" then
            gameState = "pause"
            Screens.enter()
        end
    elseif gameState == "pause" and (key == "p" or key == "escape") then
        gameState = "jogo"
    end
end

function love.update(dt)
    Screens.update(dt)
    fade = math.max(0, fade - dt / 0.4)
    scorePop = math.max(0, scorePop - dt)
    audGameplay:play()
    if gameState ~= "jogo" then
        return 
    end
    if gameOver then
        audGO:play()
        audGameplay:stop()
        return
    end

    Fx.update(dt)
    playTime = playTime + dt
    player:update(dt, buffTimer > 0)

    if player.landed then
        player.landed = false
        Fx.burst(player.x, player.y + 16, DUST, 10)
    end

    spawnInterval = math.max(0.15, 0.4 - score * 0.002)
    spawnTimer = spawnTimer + dt

    if spawnTimer >= spawnInterval then
        local baseGoodChance = 0.8
        local decayRate = 0.002
        local goodChance = math.max(0.05, baseGoodChance - decayRate * score) * 0.7

        foodSpeedMultiplier = 3 + score * 0.02
        table.insert(foods, Food.new(goodChance, foodSpeedMultiplier))
        spawnTimer = 0
    end

    if buffTimer > 0 then
        buffTimer = buffTimer - dt
    end

    for i = #foods, 1, -1 do
        local food = foods[i]
        food:update(dt)

        if player:collidesWith(food) then
            if food.good then
                score = score + (5 or 10)
                scorePop = 0.25
                foodsEaten = foodsEaten + 1
                Fx.burst(food.x, food.y, GOLD, 14)
                Fx.text(food.x, food.y - 24, "+5 KG", GOLD)
                player:grow()
                buffTimer = 2
                goodFoodMeter = goodFoodMeter + 1

                if goodFoodMeter >= goodFoodThreshold then
                    goodFoodMeter = 0
                    foodSpeedMultiplier = foodSpeedMultiplier + 0.4
                    goodFoodThreshold = goodFoodThreshold + 1
                end
            else
                if goodFoodMeter > 0 then
                    goodFoodMeter = 0
                    Fx.burst(food.x, food.y, CYAN, 14)
                    Fx.text(food.x, food.y - 24, "ESCUDO!", CYAN)
                else
                    player:takeDamage() 
                    lives = lives - 1
                    Fx.damage()
                    Fx.burst(food.x, food.y, GREY, 14)
                    Fx.text(food.x, food.y - 24, "-1 VIDA", RED)
                    if lives <= 0 then
                        endGame()
                    end
                end
            end
            table.remove(foods, i)
        elseif food.x < -30 or food.x > 830 or food.y < -30 or food.y > 630 then
            table.remove(foods, i)
        end
    end

    enemySpawnTimer = enemySpawnTimer + dt
    if enemySpawnTimer >= 0.5 then
        local direction = math.random() < 0.5 and "horizontal" or "vertical"
        local x, y
        if direction == "horizontal" then
            x = (math.random() < 0.5) and -40 or 840
            y = math.random(0, 600 - 32)
        else
            y = (math.random() < 0.5) and -40 or 640
            x = math.random(0, 800 - 32)
        end
        table.insert(enemies, Enemy.new(x, y, direction))
        enemySpawnTimer = 0
    end

    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt)

        if not player:isFlying() and enemy:collidesWith(player) then
            enemy:pushPlayer(player)
            Fx.shake()
            Fx.burst(player.x, player.y, DUST, 18)
            if goodFoodMeter > 0 then
                goodFoodMeter = 0
            else
                if lives <= 0 then
                    endGame()
                end
            end
        end

        if enemy.x < -50 or enemy.x > 850 or enemy.y < -50 or enemy.y > 650 then
            table.remove(enemies, i)
        end
    end
end

local function drawBar(label, y, height, fill, color)
    love.graphics.setFont(fontLabel)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(label, 190, y + (height - fontLabel:getHeight()) / 2, 100, "right")

    love.graphics.setColor(0.12, 0.1, 0.1)
    love.graphics.rectangle("fill", 300, y, 200, height, 3, 3)
    if fill > 0 then
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", 300, y, 200 * fill, height, 3, 3)
    end
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", 300, y, 200, height, 3, 3)
    love.graphics.setColor(1, 1, 1)
end

local function drawHud()
    love.graphics.setColor(0.07, 0.04, 0.03, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 58)
    love.graphics.setColor(1, 0.55, 0.1)
    love.graphics.rectangle("fill", 0, 58, 800, 2)

    for i = 1, 3 do
        if i <= lives then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0, 0, 0, 0.45)
        end
        love.graphics.draw(heart, 12 + (i - 1) * 40, 9, 0, 0.8, 0.8)
    end

    drawBar("ESCUDO", 10, 16, goodFoodMeter / goodFoodThreshold, CYAN)
    drawBar("TURBO", 34, 12, math.max(0, buffTimer) / 2, GOLD)

    love.graphics.setFont(fontStart)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(score .. " KG", 522, 8, 266, "right")
    love.graphics.setColor(scorePop > 0 and GOLD or { 1, 1, 1 })
    love.graphics.printf(score .. " KG", 520, 6, 266, "right")

    love.graphics.setFont(fontLabel)
    love.graphics.setColor(GOLD)
    love.graphics.printf("RECORDE " .. math.max(highScore, score) .. " KG", 520, 38, 266, "right")
    love.graphics.setColor(1, 1, 1)
end

local function drawFade()
    if fade > 0 then
        love.graphics.setColor(0, 0, 0, fade)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    if gameState == "menu" or gameState == "comojogar" then
        if gameState == "menu" then
            Screens.drawMenu(MENU_OPTIONS, highScore)
        else
            Screens.drawHowTo()
        end
        drawFade()
        return
    end

    love.graphics.push()
    Fx.applyShake()
    love.graphics.draw(dojoSprite, 0, 0)
    player:draw()
    for _, food in ipairs(foods) do
        food:draw()
    end
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
    Fx.draw()
    love.graphics.pop()

    love.graphics.draw(vignette, 0, 0, 0, 4, 4)
    Fx.drawFlash()
    drawHud()

    if gameOver then
        Screens.drawGameOver(END_OPTIONS, {
            score = score,
            highScore = highScore,
            newRecord = newRecord,
            foodsEaten = foodsEaten,
            playTime = playTime,
            player = player
        })
    elseif gameState == "pause" then
        Screens.drawPause(PAUSE_OPTIONS, score)
    end

    drawFade()
end
