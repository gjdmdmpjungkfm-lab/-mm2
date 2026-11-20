-- Простая мобильная 2D-игра для LÖVE (Love2D)
-- Скопируй этот файл в main.lua своего проекта.
-- Управление: удерживай палец слева или справа от игрока,
-- чтобы двигаться в соответствующую сторону. На компьютере — стрелки.

local player = { x = 0, y = 0, w = 44, h = 44, speed = 360 }
local obstacles = {}
local score = 0
local spawnTimer = 0
local gameOver = false
local screenW, screenH = 800, 600

local function resetGame()
    screenW, screenH = love.graphics.getDimensions()
    player.x = screenW / 2 - player.w / 2
    player.y = screenH - 110
    obstacles = {}
    score = 0
    spawnTimer = 0
    gameOver = false
end

function love.load()
    love.graphics.setBackgroundColor(0.06, 0.09, 0.15)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Уклоняйся — LÖVE2D")
    resetGame()
end

local function spawnObstacle()
    local w = love.math.random(30, 70)
    table.insert(obstacles, {
        x = love.math.random(0, math.max(1, screenW - w)),
        y = -50,
        w = w,
        h = love.math.random(25, 45),
        speed = love.math.random(190, 290)
    })
end

function love.update(dt)
    screenW, screenH = love.graphics.getDimensions()

    if gameOver then
        return
    end

    local direction = 0

    if love.keyboard.isDown("left", "a") then
        direction = direction - 1
    end
    if love.keyboard.isDown("right", "d") then
        direction = direction + 1
    end

    -- Сенсорное управление: палец слева/справа от центра игрока.
    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
        local tx, ty = love.touch.getPosition(id)
        local scaleX = screenW / love.graphics.getWidth()
        tx = tx * scaleX

        if tx < player.x + player.w / 2 then
            direction = direction - 1
        else
            direction = direction + 1
        end
    end

    if direction < 0 then direction = -1 end
    if direction > 0 then direction = 1 end

    player.x = player.x + direction * player.speed * dt
    player.x = math.max(0, math.min(screenW - player.w, player.x))

    spawnTimer = spawnTimer + dt
    if spawnTimer >= 0.75 then
        spawnTimer = 0
        spawnObstacle()
    end

    for i = #obstacles, 1, -1 do
        local obstacle = obstacles[i]
        obstacle.y = obstacle.y + obstacle.speed * dt

        if obstacle.y > screenH + 60 then
            table.remove(obstacles, i)
            score = score + 1
        elseif player.x < obstacle.x + obstacle.w
            and player.x + player.w > obstacle.x
            and player.y < obstacle.y + obstacle.h
            and player.y + player.h > obstacle.y then
            gameOver = true
        end
    end
end

function love.draw()
    screenW, screenH = love.graphics.getDimensions()

    -- Игровое поле
    love.graphics.setColor(0.10, 0.15, 0.24)
    for x = 0, screenW, 48 do
        love.graphics.line(x, 0, x, screenH)
    end
    for y = 0, screenH, 48 do
        love.graphics.line(0, y, screenW, y)
    end

    -- Игрок
    love.graphics.setColor(0.25, 0.65, 1.0)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h, 8, 8)

    -- Препятствия
    love.graphics.setColor(1.0, 0.28, 0.32)
    for _, obstacle in ipairs(obstacles) do
        love.graphics.rectangle("fill", obstacle.x, obstacle.y,
            obstacle.w, obstacle.h, 6, 6)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Очки: " .. score, 16, 16, 0, 1.4, 1.4)
    love.graphics.printf("Удерживай слева или справа от игрока, чтобы двигаться",
        10, screenH - 42, screenW - 20, "center")

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.72)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ИГРА ОКОНЧЕНА", 0, screenH / 2 - 45,
            screenW, "center")
        love.graphics.printf("Счёт: " .. score .. "\nНажми на экран, чтобы начать заново",
            0, screenH / 2, screenW, "center")
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if gameOver then
        resetGame()
    end
end

function love.keypressed(key)
    if gameOver and (key == "space" or key == "return") then
        resetGame()
    end
end

function love.mousepressed(x, y, button)
    if gameOver then
        resetGame()
    end
end

function love.resize(w, h)
    screenW, screenH = w, h
    player.y = h - 110
    player.x = math.max(0, math.min(w - player.w, player.x))
end
