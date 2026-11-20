-- SKYBOUND TRAILS
-- Original colourful side-scrolling platformer for LÖVE 11.x
-- Single-file project: save this file as main.lua and open it with LÖVE.
-- No external images, sounds, or libraries are required.
--
-- Controls:
--   Keyboard: A/D or arrows to move, Space/W/Up to jump
--   Mobile: use the on-screen LEFT, RIGHT and JUMP buttons
--   Pause: P or Escape
--   Restart level: R
--
-- This is an original game inspired by classic side-scrolling platformers.
-- All characters, names, shapes and level layouts are original.

local GAME = {
    title = "SKYBOUND TRAILS",
    version = "1.0",
    width = 960,
    height = 540,
    gravity = 1650,
    moveSpeed = 255,
    jumpVelocity = -610,
    maxFall = 900,
    tile = 48,
    mobile = false
}

local COLORS = {
    skyTop = {0.25, 0.66, 0.96},
    skyBottom = {0.72, 0.88, 1.00},
    cloud = {1, 1, 1, 0.92},
    hillFar = {0.36, 0.76, 0.51},
    hillNear = {0.20, 0.62, 0.37},
    ground = {0.48, 0.29, 0.16},
    groundTop = {0.25, 0.72, 0.30},
    block = {0.92, 0.62, 0.22},
    blockDark = {0.63, 0.34, 0.12},
    player = {0.92, 0.25, 0.20},
    playerDark = {0.55, 0.10, 0.13},
    enemy = {0.55, 0.26, 0.72},
    coin = {1.00, 0.82, 0.12},
    gem = {0.15, 0.90, 0.95},
    text = {1, 1, 1},
    shadow = {0.08, 0.13, 0.22, 0.38}
}

local fonts = {}
local state = "menu"
local levelIndex = 1
local camera = {x = 0, y = 0, shake = 0}
local player
local level
local particles = {}
local floatingTexts = {}
local collectedTotal = 0
local deaths = 0
local elapsed = 0
local bestTimes = {}
local touchButtons = {}
local input = {left = false, right = false, jump = false}
local jumpWasDown = false
local screenScale = 1
local screenOffsetX = 0
local screenOffsetY = 0
local levelMessage = ""
local levelMessageTimer = 0
local menuSelection = 1
local pauseSelection = 1

local LEVELS = {
    {
        name = "Sunny Meadow",
        sky = {0.25, 0.67, 0.97},
        map = {
            "................................................................",
            "................................................................",
            "................................................................",
            "...........C..............C...................................",
            "..........###............###.............C....................",
            "..........................................###..................",
            ".....C.........................................................",
            "....###.............E................C.........................",
            "...................###...............###.......................",
            "...............................................................G",
            "P.............C.............C.....................E...........#",
            "###############....#################....########################",
            "###############....#################....########################"
        }
    },
    {
        name = "Mossy Heights",
        sky = {0.35, 0.70, 0.91},
        map = {
            "....................................................................",
            "....................................................................",
            "................C.......................C...........................",
            "...............###.....................###..........................",
            "..............................................................C.....",
            "......C....................E................................###.....",
            ".....###..................###..............C.........................",
            "...........................................###.......................",
            "..............C......................................................",
            ".............###...............E....................................G",
            "P....................C........###...............C..................#",
            "#########....#########....#############....##########################",
            "#########....#########....#############....##########################"
        }
    },
    {
        name = "Cloudstep Cliffs",
        sky = {0.46, 0.69, 0.93},
        map = {
            "........................................................................",
            "........................................................................",
            "........C...................C...........................................",
            ".......###.................###...................C.....................",
            "..................................................###...................",
            "....................E...................................................",
            "...................###................C.................................",
            "......................................###...............................",
            ".....C....................................................E.............",
            "....###...............C..................................###............G",
            "P....................###...........C...................................#",
            "########....################....###....############....#################",
            "########....################....###....############....#################"
        }
    },
    {
        name = "Amber Cavern",
        sky = {0.20, 0.30, 0.48},
        map = {
            "........................................................................",
            "........................................................................",
            "...........C......................C.....................................",
            "..........###....................###...................C................",
            ".......................................................###...............",
            ".....E..................C................................................",
            "....###................###...................E..........................",
            ".............................................###........................",
            "................C.......................................................",
            "...............###...............C.....................................G",
            "P...............................###..................C.................#",
            "########....##########....############....########....###################",
            "########....##########....############....########....###################"
        }
    }
}

local function copyColor(c)
    return {c[1], c[2], c[3], c[4] or 1}
end

local function setColor(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or c[4] or 1)
end

local function rect(x, y, w, h, color, mode, radius)
    setColor(color)
    if radius then
        love.graphics.rectangle(mode or "fill", x, y, w, h, radius, radius)
    else
        love.graphics.rectangle(mode or "fill", x, y, w, h)
    end
end

local function circle(x, y, r, color, mode)
    setColor(color)
    love.graphics.circle(mode or "fill", x, y, r)
end

local function textCentered(str, y, font, color)
    font = font or fonts.medium
    color = color or COLORS.text
    love.graphics.setFont(font)
    setColor(COLORS.shadow)
    love.graphics.printf(str, 3, y + 3, GAME.width, "center")
    setColor(color)
    love.graphics.printf(str, 0, y, GAME.width, "center")
end

local function makePlayer(x, y)
    return {
        x = x, y = y, w = 30, h = 42,
        vx = 0, vy = 0,
        onGround = false,
        facing = 1,
        alive = true,
        invulnerable = 0,
        coyote = 0,
        jumpBuffer = 0,
        animTime = 0,
        coins = 0,
        gems = 0
    }
end

local function tileAt(tx, ty)
    if not level then return "." end
    if ty < 1 or ty > level.rows then return "." end
    if tx < 1 then return "#" end
    if tx > level.cols then return "." end
    return level.grid[ty]:sub(tx, tx)
end

local function isSolidTile(ch)
    return ch == "#" or ch == "B"
end

local function tileRect(tx, ty)
    local s = GAME.tile
    return (tx - 1) * s, (ty - 1) * s, s, s
end

local function overlaps(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

local function getTileRange(x, y, w, h)
    local s = GAME.tile
    local left = math.floor(x / s) + 1
    local right = math.floor((x + w - 0.001) / s) + 1
    local top = math.floor(y / s) + 1
    local bottom = math.floor((y + h - 0.001) / s) + 1
    return left, right, top, bottom
end

local function makeParticle(x, y, vx, vy, color, life, size)
    particles[#particles + 1] = {
        x = x, y = y, vx = vx, vy = vy,
        color = copyColor(color),
        life = life or 0.45,
        maxLife = life or 0.45,
        size = size or 4
    }
end

local function burst(x, y, color, count)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = love.math.random(70, 230)
        makeParticle(x, y, math.cos(angle) * speed,
            math.sin(angle) * speed - 40, color, 0.55, love.math.random(3, 6))
    end
end

local function addFloatingText(x, y, value, color)
    floatingTexts[#floatingTexts + 1] = {
        x = x, y = y, text = value,
        color = copyColor(color or COLORS.text),
        life = 0.9, maxLife = 0.9
    }
end

local function parseLevel(def)
    local parsed = {
        name = def.name,
        sky = def.sky,
        grid = {},
        rows = #def.map,
        cols = 0,
        coins = {},
        enemies = {},
        gems = {},
        goal = nil,
        spawn = {x = 80, y = 100}
    }

    for y, sourceRow in ipairs(def.map) do
        parsed.grid[y] = sourceRow
        parsed.cols = math.max(parsed.cols, #sourceRow)
        for x = 1, #sourceRow do
            local ch = sourceRow:sub(x, x)
            local wx = (x - 1) * GAME.tile
            local wy = (y - 1) * GAME.tile
            if ch == "P" then
                parsed.spawn = {x = wx + 9, y = wy + 4}
                parsed.grid[y] = parsed.grid[y]:sub(1, x - 1) .. "." .. parsed.grid[y]:sub(x + 1)
            elseif ch == "C" then
                parsed.coins[#parsed.coins + 1] = {
                    x = wx + 24, y = wy + 24, r = 11, taken = false, bob = love.math.random() * 6
                }
                parsed.grid[y] = parsed.grid[y]:sub(1, x - 1) .. "." .. parsed.grid[y]:sub(x + 1)
            elseif ch == "E" then
                parsed.enemies[#parsed.enemies + 1] = {
                    x = wx + 7, y = wy + 12, w = 34, h = 30,
                    vx = 65, minX = wx - 48, maxX = wx + 64,
                    alive = true, phase = love.math.random() * 5
                }
                parsed.grid[y] = parsed.grid[y]:sub(1, x - 1) .. "." .. parsed.grid[y]:sub(x + 1)
            elseif ch == "G" then
                parsed.goal = {x = wx + 10, y = wy - 48, w = 28, h = 96}
                parsed.grid[y] = parsed.grid[y]:sub(1, x - 1) .. "." .. parsed.grid[y]:sub(x + 1)
            end
        end
    end

    for y = 1, parsed.rows do
        if #parsed.grid[y] < parsed.cols then
            parsed.grid[y] = parsed.grid[y] .. string.rep(".", parsed.cols - #parsed.grid[y])
        end
    end
    return parsed
end

local function loadLevel(index)
    levelIndex = math.max(1, math.min(index, #LEVELS))
    level = parseLevel(LEVELS[levelIndex])
    player = makePlayer(level.spawn.x, level.spawn.y)
    camera.x = 0
    camera.y = 0
    particles = {}
    floatingTexts = {}
    elapsed = 0
    levelMessage = level.name
    levelMessageTimer = 2.2
    state = "playing"
    input.left, input.right, input.jump = false, false, false
    jumpWasDown = false
end

local function restartLevel()
    deaths = deaths + 1
    loadLevel(levelIndex)
end

local function nextLevel()
    if levelIndex < #LEVELS then
        loadLevel(levelIndex + 1)
    else
        state = "complete"
    end
end

local function spawnPlayerAtCheckpoint()
    player.x = level.spawn.x
    player.y = level.spawn.y
    player.vx = 0
    player.vy = 0
    player.invulnerable = 1.5
    camera.shake = 0.18
end

local function damagePlayer()
    if player.invulnerable > 0 or not player.alive then return end
    player.alive = false
    burst(player.x + player.w / 2, player.y + player.h / 2, COLORS.player, 16)
    camera.shake = 0.32
    state = "dead"
end

local function collectCoin(coin)
    if coin.taken then return end
    coin.taken = true
    player.coins = player.coins + 1
    collectedTotal = collectedTotal + 1
    burst(coin.x, coin.y, COLORS.coin, 7)
    addFloatingText(coin.x, coin.y - 15, "+1", COLORS.coin)
end

local function collectGem(gem)
    if gem.taken then return end
    gem.taken = true
    player.gems = player.gems + 1
    collectedTotal = collectedTotal + 5
    burst(gem.x, gem.y, COLORS.gem, 12)
    addFloatingText(gem.x, gem.y - 18, "GEM +5", COLORS.gem)
end

local function resolveHorizontal(entity, dt)
    entity.x = entity.x + entity.vx * dt
    local left, right, top, bottom = getTileRange(entity.x, entity.y, entity.w, entity.h)
    for ty = top, bottom do
        for tx = left, right do
            if isSolidTile(tileAt(tx, ty)) then
                local bx, by, bw, bh = tileRect(tx, ty)
                if overlaps(entity.x, entity.y, entity.w, entity.h, bx, by, bw, bh) then
                    if entity.vx > 0 then
                        entity.x = bx - entity.w
                    elseif entity.vx < 0 then
                        entity.x = bx + bw
                    end
                    entity.vx = 0
                end
            end
        end
    end
end

local function resolveVertical(entity, dt)
    entity.y = entity.y + entity.vy * dt
    entity.onGround = false
    local left, right, top, bottom = getTileRange(entity.x, entity.y, entity.w, entity.h)
    for ty = top, bottom do
        for tx = left, right do
            if isSolidTile(tileAt(tx, ty)) then
                local bx, by, bw, bh = tileRect(tx, ty)
                if overlaps(entity.x, entity.y, entity.w, entity.h, bx, by, bw, bh) then
                    if entity.vy > 0 then
                        entity.y = by - entity.h
                        entity.onGround = true
                    elseif entity.vy < 0 then
                        entity.y = by + bh
                    end
                    entity.vy = 0
                end
            end
        end
    end
end

local function updatePlayer(dt)
    if not player or not player.alive then return end
    player.animTime = player.animTime + dt
    player.invulnerable = math.max(0, player.invulnerable - dt)
    player.coyote = math.max(0, player.coyote - dt)
    player.jumpBuffer = math.max(0, player.jumpBuffer - dt)

    local direction = 0
    if input.left then direction = direction - 1 end
    if input.right then direction = direction + 1 end
    if direction ~= 0 then
        player.facing = direction
        player.vx = direction * GAME.moveSpeed
    else
        player.vx = player.vx * math.pow(0.0008, dt)
        if math.abs(player.vx) < 5 then player.vx = 0 end
    end

    if player.onGround then player.coyote = 0.12 end
    if input.jump and not jumpWasDown then player.jumpBuffer = 0.14 end
    jumpWasDown = input.jump

    if player.jumpBuffer > 0 and (player.onGround or player.coyote > 0) then
        player.vy = GAME.jumpVelocity
        player.onGround = false
        player.coyote = 0
        player.jumpBuffer = 0
        makeParticle(player.x + player.w / 2, player.y + player.h, -35, 30, COLORS.cloud, 0.25, 4)
        makeParticle(player.x + player.w / 2, player.y + player.h, 35, 30, COLORS.cloud, 0.25, 4)
    end

    if not input.jump and player.vy < -180 then
        player.vy = player.vy * 0.55
    end

    player.vy = math.min(player.vy + GAME.gravity * dt, GAME.maxFall)
    resolveHorizontal(player, dt)
    resolveVertical(player, dt)

    if player.y > level.rows * GAME.tile + 160 then
        damagePlayer()
    end

    for _, coin in ipairs(level.coins) do
        coin.bob = coin.bob + dt * 4
        if not coin.taken and overlaps(player.x, player.y, player.w, player.h,
            coin.x - coin.r, coin.y - coin.r, coin.r * 2, coin.r * 2) then
            collectCoin(coin)
        end
    end

    for _, gem in ipairs(level.gems) do
        if not gem.taken and overlaps(player.x, player.y, player.w, player.h,
            gem.x - 13, gem.y - 13, 26, 26) then
            collectGem(gem)
        end
    end

    if level.goal and overlaps(player.x, player.y, player.w, player.h,
        level.goal.x, level.goal.y, level.goal.w, level.goal.h) then
        state = "levelclear"
        burst(player.x + player.w / 2, player.y + player.h / 2, COLORS.coin, 22)
    end
end

local function updateEnemies(dt)
    for _, enemy in ipairs(level.enemies) do
        if enemy.alive then
            enemy.phase = enemy.phase + dt * 5
            enemy.x = enemy.x + enemy.vx * dt
            if enemy.x < enemy.minX then
                enemy.x = enemy.minX
                enemy.vx = math.abs(enemy.vx)
            elseif enemy.x + enemy.w > enemy.maxX then
                enemy.x = enemy.maxX - enemy.w
                enemy.vx = -math.abs(enemy.vx)
            end

            local aheadX = enemy.vx > 0 and enemy.x + enemy.w + 2 or enemy.x - 2
            local footY = enemy.y + enemy.h + 3
            local tx = math.floor(aheadX / GAME.tile) + 1
            local ty = math.floor(footY / GAME.tile) + 1
            if not isSolidTile(tileAt(tx, ty)) then enemy.vx = -enemy.vx end

            if player and player.alive and overlaps(player.x, player.y, player.w, player.h,
                enemy.x, enemy.y, enemy.w, enemy.h) then
                local playerBottom = player.y + player.h
                if player.vy > 80 and playerBottom - enemy.y < 22 then
                    enemy.alive = false
                    player.vy = GAME.jumpVelocity * 0.58
                    burst(enemy.x + enemy.w / 2, enemy.y + enemy.h / 2, COLORS.enemy, 10)
                    addFloatingText(enemy.x, enemy.y - 12, "BOUNCE!", COLORS.coin)
                else
                    damagePlayer()
                end
            end
        end
    end
end

local function updateCamera(dt)
    if not player then return end
    local target = player.x + player.w / 2 - GAME.width * 0.42
    local maxX = math.max(0, level.cols * GAME.tile - GAME.width)
    target = math.max(0, math.min(target, maxX))
    camera.x = camera.x + (target - camera.x) * math.min(1, dt * 7)
    camera.shake = math.max(0, camera.shake - dt)
end

local function updateEffects(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 520 * dt
        if p.life <= 0 then table.remove(particles, i) end
    end

    for i = #floatingTexts, 1, -1 do
        local f = floatingTexts[i]
        f.life = f.life - dt
        f.y = f.y - 34 * dt
        if f.life <= 0 then table.remove(floatingTexts, i) end
    end
    levelMessageTimer = math.max(0, levelMessageTimer - dt)
end

local function update(dt)
    updateEffects(dt)
    if state == "playing" then
        elapsed = elapsed + dt
        updatePlayer(dt)
        updateEnemies(dt)
        updateCamera(dt)
    end
end

local function drawBackground()
    local sky = level and level.sky or COLORS.skyTop
    local top = copyColor(sky)
    local bottom = {math.min(1, sky[1] + 0.28), math.min(1, sky[2] + 0.20), math.min(1, sky[3] + 0.05), 1}
    for y = 0, GAME.height, 4 do
        local t = y / GAME.height
        local c = {
            top[1] * (1 - t) + bottom[1] * t,
            top[2] * (1 - t) + bottom[2] * t,
            top[3] * (1 - t) + bottom[3] * t,
            1
        }
        rect(0, y, GAME.width, 4, c)
    end

    local parallax = camera.x * 0.18
    for i = 1, 7 do
        local x = ((i * 205 - parallax) % (GAME.width + 260)) - 100
        circle(x, 420 + (i % 2) * 18, 100 + (i % 3) * 18, COLORS.hillFar)
    end
    parallax = camera.x * 0.34
    for i = 1, 8 do
        local x = ((i * 170 - parallax) % (GAME.width + 240)) - 80
        circle(x, 485 + (i % 2) * 14, 95 + (i % 3) * 15, COLORS.hillNear)
    end

    -- Drifting decorative clouds.
    local cloudOffset = (elapsed * 13) % (GAME.width + 180)
    for i = 1, 5 do
        local x = ((i * 225 - cloudOffset) % (GAME.width + 240)) - 100
        local y = 65 + (i % 3) * 55
        circle(x, y, 22, COLORS.cloud)
        circle(x + 24, y - 8, 28, COLORS.cloud)
        circle(x + 52, y + 1, 21, COLORS.cloud)
        rect(x - 2, y, 56, 18, COLORS.cloud)
    end
end

local function drawBlock(tx, ty, ch)
    local x, y, w, h = tileRect(tx, ty)
    if ch == "#" then
        rect(x, y, w, h, COLORS.ground)
        rect(x, y, w, 7, COLORS.groundTop)
        rect(x + 5, y + 15, 8, 5, COLORS.blockDark)
        rect(x + 27, y + 28, 11, 5, COLORS.blockDark)
        rect(x + 18, y + 10, 5, 5, {0.72, 0.50, 0.31})
    elseif ch == "B" then
        rect(x + 2, y + 2, w - 4, h - 4, COLORS.block, "fill", 7)
        rect(x + 2, y + 2, w - 4, 5, {1, 0.83, 0.43}, "fill", 3)
        rect(x + 7, y + 7, w - 14, h - 14, COLORS.blockDark, "line", 3)
    end
end

local function drawWorld()
    if not level then return end
    love.graphics.push()
    local shakeX, shakeY = 0, 0
    if camera.shake > 0 then
        shakeX = love.math.random(-4, 4) * camera.shake * 3
        shakeY = love.math.random(-3, 3) * camera.shake * 3
    end
    love.graphics.translate(-camera.x + shakeX, -camera.y + shakeY)

    local first = math.max(1, math.floor(camera.x / GAME.tile) + 1)
    local last = math.min(level.cols, first + math.ceil(GAME.width / GAME.tile) + 2)
    for ty = 1, level.rows do
        for tx = first, last do
            local ch = tileAt(tx, ty)
            if isSolidTile(ch) then drawBlock(tx, ty, ch) end
        end
    end

    for _, coin in ipairs(level.coins) do
        if not coin.taken then
            local bobY = math.sin(coin.bob) * 4
            circle(coin.x, coin.y + bobY, 10, COLORS.coin)
            circle(coin.x, coin.y + bobY, 6, {1, 0.94, 0.52})
            rect(coin.x - 2, coin.y - 6 + bobY, 3, 12, {1, 1, 0.85})
        end
    end

    for _, gem in ipairs(level.gems) do
        if not gem.taken then
            local points = {
                gem.x, gem.y - 14, gem.x + 12, gem.y,
                gem.x, gem.y + 14, gem.x - 12, gem.y
            }
            setColor(COLORS.gem)
            love.graphics.polygon("fill", points)
            setColor({0.75, 1, 1})
            love.graphics.polygon("line", points)
        end
    end

    if level.goal then
        local g = level.goal
        rect(g.x + 11, g.y, 6, g.h, {0.92, 0.92, 0.96})
        rect(g.x + 17, g.y + 4, 32, 22, {0.98, 0.35, 0.25})
        circle(g.x + 17, g.y + 15, 4, {1, 0.85, 0.25})
        rect(g.x + 4, g.y + g.h - 8, 36, 8, {0.45, 0.28, 0.18})
    end

    for _, enemy in ipairs(level.enemies) do
        if enemy.alive then
            local bob = math.sin(enemy.phase) * 2
            circle(enemy.x + enemy.w / 2, enemy.y + enemy.h / 2 + bob, 17, COLORS.enemy)
            circle(enemy.x + 11, enemy.y + 12 + bob, 4, {1, 1, 1})
            circle(enemy.x + 24, enemy.y + 12 + bob, 4, {1, 1, 1})
            circle(enemy.x + 12, enemy.y + 12 + bob, 2, {0.08, 0.08, 0.12})
            circle(enemy.x + 25, enemy.y + 12 + bob, 2, {0.08, 0.08, 0.12})
            rect(enemy.x + 5, enemy.y + 25 + bob, 24, 5, {0.25, 0.12, 0.35}, "fill", 2)
        end
    end

    if player and player.alive then
        local blink = player.invulnerable > 0 and math.floor(elapsed * 18) % 2 == 0
        if not blink then
            local x, y, w, h = player.x, player.y, player.w, player.h
            rect(x + 3, y + 12, w - 6, h - 12, COLORS.player, "fill", 7)
            rect(x + 1, y + 7, w - 2, 13, COLORS.playerDark, "fill", 5)
            rect(x + 2, y + 4, w - 4, 7, {1, 0.42, 0.30}, "fill", 4)
            circle(x + (player.facing > 0 and 21 or 9), y + 20, 3, {1, 1, 1})
            circle(x + (player.facing > 0 and 22 or 8), y + 20, 1.5, {0.05, 0.08, 0.12})
            rect(x + 4, y + h - 4, 9, 5, {0.15, 0.20, 0.34}, "fill", 2)
            rect(x + 17, y + h - 4, 9, 5, {0.15, 0.20, 0.34}, "fill", 2)
        end
    end

    for _, p in ipairs(particles) do
        local alpha = math.max(0, p.life / p.maxLife)
        setColor(p.color, alpha)
        love.graphics.circle("fill", p.x, p.y, p.size * alpha)
    end

    for _, f in ipairs(floatingTexts) do
        local alpha = math.max(0, f.life / f.maxLife)
        love.graphics.setFont(fonts.small)
        setColor(f.color, alpha)
        love.graphics.print(f.text, f.x, f.y)
    end
    love.graphics.pop()
end

local function drawHud()
    rect(16, 14, 240, 48, {0.04, 0.10, 0.18, 0.62}, "fill", 12)
    love.graphics.setFont(fonts.small)
    setColor(COLORS.text)
    love.graphics.print("LEVEL " .. levelIndex .. "  -  " .. level.name, 30, 22)
    love.graphics.print("COINS: " .. (player and player.coins or 0), 30, 42)

    rect(GAME.width - 174, 14, 158, 48, {0.04, 0.10, 0.18, 0.62}, "fill", 12)
    love.graphics.printf("TIME  " .. string.format("%02d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60)),
        GAME.width - 164, 22, 140, "right")
    love.graphics.printf("GEMS  " .. (player and player.gems or 0),
        GAME.width - 164, 42, 140, "right")
end

local function drawButton(x, y, w, h, label, active)
    local c = active and {0.98, 0.73, 0.20, 0.94} or {0.05, 0.12, 0.22, 0.62}
    rect(x, y + 4, w, h, {0.02, 0.05, 0.10, 0.35}, "fill", 12)
    rect(x, y, w, h, c, "fill", 12)
    rect(x + 3, y + 3, w - 6, h - 6, {1, 1, 1, 0.13}, "line", 9)
    love.graphics.setFont(fonts.medium)
    setColor(active and {0.20, 0.12, 0.04} or COLORS.text)
    love.graphics.printf(label, x, y + h / 2 - fonts.medium:getHeight() / 2, w, "center")
end

local function drawTouchControls()
    if not GAME.mobile then return end
    drawButton(24, GAME.height - 88, 74, 64, "<", input.left)
    drawButton(108, GAME.height - 88, 74, 64, ">", input.right)
    drawButton(GAME.width - 112, GAME.height - 100, 88, 76, "JUMP", input.jump)
end

local function drawMenu()
    drawBackground()
    circle(480, 180, 70, {1, 0.82, 0.24, 0.20})
    textCentered("SKYBOUND TRAILS", 105, fonts.title, {1, 1, 1})
    textCentered("A little adventure above the clouds", 172, fonts.small, {0.95, 0.98, 1})
    drawButton(330, 260, 300, 58, "PLAY", menuSelection == 1)
    drawButton(330, 330, 300, 58, "HOW TO PLAY", menuSelection == 2)
    drawButton(330, 400, 300, 58, "QUIT", menuSelection == 3)
    textCentered("Move: A/D or arrows     Jump: SPACE", 485, fonts.small, {1, 1, 1, 0.9})
end

local function drawOverlay(title, subtitle, firstLabel, secondLabel)
    rect(0, 0, GAME.width, GAME.height, {0.02, 0.05, 0.12, 0.68})
    textCentered(title, 145, fonts.title, {1, 1, 1})
    textCentered(subtitle, 220, fonts.medium, {0.88, 0.94, 1})
    drawButton(315, 300, 330, 54, firstLabel, pauseSelection == 1)
    if secondLabel then
        drawButton(315, 366, 330, 54, secondLabel, pauseSelection == 2)
    end
end

local function draw()
    if state == "menu" then
        drawMenu()
        return
    end

    drawBackground()
    drawWorld()
    drawHud()
    drawTouchControls()

    if levelMessageTimer > 0 and state == "playing" then
        rect(310, 92, 340, 48, {0.02, 0.07, 0.15, 0.58}, "fill", 12)
        textCentered(levelMessage, 103, fonts.medium, {1, 1, 1})
    end

    if state == "paused" then
        drawOverlay("PAUSED", "Take a short break.", "RESUME", "MAIN MENU")
    elseif state == "dead" then
        drawOverlay("TRY AGAIN!", "The trail is tricky. Give it another go!", "RETRY", "MAIN MENU")
    elseif state == "levelclear" then
        drawOverlay("LEVEL COMPLETE!", "Great jumping! Ready for the next area?", "NEXT LEVEL", "MAIN MENU")
    elseif state == "complete" then
        drawOverlay("YOU DID IT!", "You explored every trail. Total score: " .. collectedTotal, "PLAY AGAIN", "MAIN MENU")
    end
end

local function toGameCoordinates(x, y)
    return (x - screenOffsetX) / screenScale, (y - screenOffsetY) / screenScale
end

local function pointInRect(x, y, rx, ry, rw, rh)
    return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

local function activateMenuChoice()
    if menuSelection == 1 then
        loadLevel(1)
    elseif menuSelection == 2 then
        state = "help"
    elseif menuSelection == 3 then
        love.event.quit()
    end
end

local function activateOverlayChoice()
    if state == "paused" then
        if pauseSelection == 1 then
            state = "playing"
        else
            state = "menu"
        end
    elseif state == "dead" then
        if pauseSelection == 1 then
            loadLevel(levelIndex)
        else
            state = "menu"
        end
    elseif state == "levelclear" then
        if pauseSelection == 1 then
            nextLevel()
        else
            state = "menu"
        end
    elseif state == "complete" then
        if pauseSelection == 1 then
            collectedTotal = 0
            deaths = 0
            loadLevel(1)
        else
            state = "menu"
        end
    end
end

function love.load()
    love.window.setTitle(GAME.title)
    love.graphics.setDefaultFilter("nearest", "nearest")
    fonts.small = love.graphics.newFont(16)
    fonts.medium = love.graphics.newFont(25)
    fonts.title = love.graphics.newFont(46)
    love.graphics.setBackgroundColor(0.15, 0.35, 0.55)
    GAME.mobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    love.math.setRandomSeed(os.time())
end

function love.update(dt)
    dt = math.min(dt, 1 / 30)
    update(dt)
end

function love.draw()
    local sw, sh = love.graphics.getDimensions()
    screenScale = math.min(sw / GAME.width, sh / GAME.height)
    screenOffsetX = (sw - GAME.width * screenScale) / 2
    screenOffsetY = (sh - GAME.height * screenScale) / 2

    love.graphics.clear(0.02, 0.04, 0.08)
    love.graphics.push()
    love.graphics.translate(screenOffsetX, screenOffsetY)
    love.graphics.scale(screenScale, screenScale)
    draw()
    if state == "help" then
        rect(0, 0, GAME.width, GAME.height, {0.02, 0.05, 0.12, 0.88})
        textCentered("HOW TO PLAY", 100, fonts.title)
        textCentered("Move with A/D or the arrow keys.", 205, fonts.medium)
        textCentered("Jump with SPACE, W or UP.", 250, fonts.medium)
        textCentered("Stomp small creatures from above.", 295, fonts.medium)
        textCentered("Collect coins and reach the flag.", 340, fonts.medium)
        drawButton(330, 405, 300, 56, "BACK", true)
    end
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" or key == "p" then
        if state == "playing" then
            state = "paused"
            pauseSelection = 1
        elseif state == "paused" then
            state = "playing"
        elseif state == "help" then
            state = "menu"
        end
        return
    end

    if state == "menu" then
        if key == "up" or key == "w" then
            menuSelection = math.max(1, menuSelection - 1)
        elseif key == "down" or key == "s" then
            menuSelection = math.min(3, menuSelection + 1)
        elseif key == "return" or key == "space" then
            activateMenuChoice()
        end
        return
    end

    if state == "help" then
        if key == "return" or key == "space" then state = "menu" end
        return
    end

    if state == "paused" or state == "dead" or state == "levelclear" or state == "complete" then
        if key == "up" or key == "w" then
            pauseSelection = 1
        elseif key == "down" or key == "s" then
            pauseSelection = 2
        elseif key == "return" or key == "space" then
            activateOverlayChoice()
        end
        return
    end

    if key == "a" or key == "left" then input.left = true end
    if key == "d" or key == "right" then input.right = true end
    if key == "space" or key == "w" or key == "up" then input.jump = true end
    if key == "r" and state == "playing" then loadLevel(levelIndex) end
end

function love.keyreleased(key)
    if key == "a" or key == "left" then input.left = false end
    if key == "d" or key == "right" then input.right = false end
    if key == "space" or key == "w" or key == "up" then input.jump = false end
end

local function handleTouchPress(x, y)
    x, y = toGameCoordinates(x, y)

    if state == "menu" then
        if pointInRect(x, y, 330, 260, 300, 58) then
            menuSelection = 1
            activateMenuChoice()
        elseif pointInRect(x, y, 330, 330, 300, 58) then
            menuSelection = 2
            activateMenuChoice()
        elseif pointInRect(x, y, 330, 400, 300, 58) then
            menuSelection = 3
            activateMenuChoice()
        end
        return
    end

    if state == "help" then
        state = "menu"
        return
    end

    if state == "paused" or state == "dead" or state == "levelclear" or state == "complete" then
        if pointInRect(x, y, 315, 300, 330, 54) then
            pauseSelection = 1
            activateOverlayChoice()
        elseif pointInRect(x, y, 315, 366, 330, 54) then
            pauseSelection = 2
            activateOverlayChoice()
        end
        return
    end

    if y > GAME.height - 120 then
        if x < 205 then
            if x < 105 then input.left = true else input.right = true end
        elseif x > GAME.width - 145 then
            input.jump = true
        end
    end
end

local function handleTouchRelease()
    input.left = false
    input.right = false
    input.jump = false
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    handleTouchPress(x, y)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    handleTouchRelease()
end

function love.mousepressed(x, y, button)
    if button == 1 then handleTouchPress(x, y) end
end

function love.mousereleased(x, y, button)
    if button == 1 then handleTouchRelease() end
end

function love.resize(w, h)
    -- The virtual 16:9 canvas is letterboxed in love.draw.
end

function love.focus(focused)
    if not focused and state == "playing" then
        state = "paused"
        pauseSelection = 1
        handleTouchRelease()
    end
end

-- End of main.lua
