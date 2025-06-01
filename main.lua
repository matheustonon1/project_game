local Player = require("player")
local Food = require("food")
local Enemy = require("enemy")

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

function saveHighScore(score)
    love.filesystem.write("highscore.txt", tostring(score))
end

function resetGame()
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
    love.window.setTitle("Kitchen Kunai")
    love.window.setMode(800, 600)

    fontStart = love.graphics.newFont("assets/font/start.ttf", 24)
    fontMenus = love.graphics.newFont("assets/font/menus.ttf", 48) 

    dojoSprite = love.graphics.newImage("assets/backgrounds/dojoBackground.jpg")
    dojoMenuSprite = love.graphics.newImage("assets/backgrounds/kk-start.jpg")
    dojoEndSprite = love.graphics.newImage("assets/backgrounds/kk-go.jpg")
end

function love.keypressed(key)
    if gameState == "menu" and key == "return" then
        resetGame()
        gameState = "jogo"
    elseif gameState == "jogo" then
        if gameOver and key == "r" then
            resetGame()
        elseif key == "p" then
            gameState = "pause"
        end
    elseif gameState == "pause" and key == "p" then
        gameState = "jogo"
    end
end

function love.update(dt)
    if gameState ~= "jogo" then return end
    if gameOver then return end

    player:update(dt, buffTimer > 0)

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
                else
                    player:takeDamage() 
                    lives = lives - 1
                    if lives <= 0 then
                        gameOver = true
                        if score > highScore then
                            highScore = score
                            saveHighScore(score)
                        end
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

        if enemy:collidesWith(player) then
            enemy:pushPlayer(player)
            if goodFoodMeter > 0 then
                goodFoodMeter = 0
            else
                if lives <= 0 then
                    gameOver = true
                    if score > highScore then
                        highScore = score
                        saveHighScore(score)
                    end
                end
            end
        end

        if enemy.x < -50 or enemy.x > 850 or enemy.y < -50 or enemy.y > 650 then
            table.remove(enemies, i)
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)

    if gameState == "menu" then
        love.graphics.draw(dojoMenuSprite, 0, 0)
        love.graphics.setFont(love.graphics.newFont(48))
        love.graphics.
        love.graphics.printf("Ninja Arcade", 0, 200, 800, "center")
        love.graphics.setFont(fontStart)
        love.graphics.printf("PRESS ENTER TO START", 0, 300, 800, "center")
        return
    end

    love.graphics.draw(dojoSprite, 0, 0)

    player:draw()
    for _, food in ipairs(foods) do
        food:draw()
    end
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Peso: " .. score .. "KG", 10, 10)
    love.graphics.print("Vidas: " .. lives, 10, 30)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 300, 10, 200, 20)
    love.graphics.setColor(0, 0.8, 1)
    local fillWidth = (goodFoodMeter / goodFoodThreshold) * 200
    love.graphics.rectangle("fill", 300, 10, fillWidth, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 300, 10, 200, 20)

    if buffTimer > 0 then
        local maxBuffTime = 2
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 300, 40, 200, 10)
        love.graphics.setColor(1, 1, 0)
        local buffWidth = (buffTimer / maxBuffTime) * 200
        love.graphics.rectangle("fill", 300, 40, buffWidth, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 300, 40, 200, 10)
    end

    if gameOver then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(dojoEndSprite, 0, 0)
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(fontMenus)
        love.graphics.printf("GAME OVER\nAperte R para reiniciar", 0, 150, 800, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("Pontuação máxima: " .. highScore, 0, 320, 800, "center")
    elseif gameState == "pause" then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("PAUSADO\nPressione P para continuar", 0, 250, 800, "center")
    end
end