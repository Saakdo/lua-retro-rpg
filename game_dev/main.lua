--Magika Spell--

-- main.lua

local STATE_EXPLORE = "explore"
local STATE_BATTLE = "battle"
local STATE_INTRO = "intro"
local currentState = STATE_INTRO

local NES_WIDTH = 256
local NES_HEIGHT = 240
local SCALE = 3

-- IMPORTANT: Tile 15 is NOT here because we handle it manually!
local SOLID_TILES = {
    [2] = true, [20] = true, [3] = true, [19] = true, [22] = true, [23] = true
}

function love.load()
    love.window.setTitle("RPG Prototype")
    love.window.setMode(NES_WIDTH * SCALE, NES_HEIGHT * SCALE)
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- 1. PLAYER & MAP ASSETS
    playerSpriteSheet = love.graphics.newImage("mage1_walking_right.png")
    local gridW, gridH = 16, 16
    playerQuads = {}
    for i = 0, 3 do 
        table.insert(playerQuads, love.graphics.newQuad(i * gridW, 0, gridW, gridH, playerSpriteSheet:getDimensions()))
    end

    -- Player Setup
    player = { x = 50, y = 522, speed = 100, currentFrame = 1, animTimer = 0, facingX = 1, maxHP = 20, maxMP = 10}
    
    slimeIdle = love.graphics.newImage("Slime2.png")       
    slimeRun  = love.graphics.newImage("Slime2-Sheet.png") 
    slimeQuads = {}
    for i = 0, 3 do table.insert(slimeQuads, love.graphics.newQuad(i * 16, 0, 16, 16, slimeRun:getDimensions())) end
    
    enemies = {}
    function spawnSlime(x, y)
        table.insert(enemies, { x = x, y = y, state = "idle", timer = 2.0, moveDir = 1, currentFrame = 1, animTimer = 0 })
    end
    -- WAVE 1 SPAWNS
    spawnSlime(200, 522); spawnSlime(350, 572)
    
    currentWave = 1
    
    -- NEW: MESSAGE SYSTEM VARIABLES
    infoMessage = ""
    infoTimer = 0

    camera = { x = 0, y = 0 }
    tilesetImage = love.graphics.newImage("tileset3.png")
    local imgW, imgH = tilesetImage:getDimensions()
    local cols = math.floor(imgW / 16); local rows = math.floor(imgH / 16)
    tileQuads = {}
    for y = 0, rows - 1 do
        for x = 0, cols - 1 do table.insert(tileQuads, love.graphics.newQuad(x * 16, y * 16, 16, 16, imgW, imgH)) end
    end
    
    gameMap = {
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,27,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,29,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,43,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,45,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
        {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,15,2,2,2,2,2,2,20,18,17,18,17,18,17,18,17,18,17,18,17,18,17,18,17},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,21,26,25,26,25,26,25,26,25,26,25,26,25,26,25,26,21},
        {2,1,1,1,1,1,1,2,2,4,4,4,4,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,20,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,20},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,2,2,2,2,2,1,1,1,1,1,21,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,21},
        {2,1,50,51,52,53,1,1,1,1,1,1,1,1,1,2,2,1,1,2,2,2,2,2,1,1,1,1,1,17,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,20},
        {2,1,58,59,60,61,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,25,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,21},
        {2,1,66,67,68,69,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,33,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,20},
        {2,1,74,75,76,77,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,20,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,21},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,21,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,20},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,20,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,21},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,21,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,20},
        {2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,20,33,34,33,34,33,34,33,34,33,34,33,34,33,34,33,21},
        {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,17,18,17,18,17,18,17,18,17,18,17,18,17,18,17,18,20}, 
    }
    
    battleBgImage    = love.graphics.newImage("BattleBackground.png")
    slimeBattleImage = love.graphics.newImage("SlimeBM.png")
    
    slashImage = love.graphics.newImage("slashBattle-Sheet.png")
    slashQuads = {} 
    
    local SLASH_FRAMES = 11 
    local slashFrameWidth = slashImage:getWidth() / SLASH_FRAMES
    local slashFrameHeight = slashImage:getHeight()
    
    for i = 0, SLASH_FRAMES - 1 do
        table.insert(slashQuads, love.graphics.newQuad(i * slashFrameWidth, 0, slashFrameWidth, slashFrameHeight, slashImage:getDimensions()))
    end
    
    bgmExplore = love.audio.newSource("WanderingMinstrel.mp3", "stream")
    bgmExplore:setLooping(true)
    
    bgmBattle = love.audio.newSource("Knight's_Charge.mp3", "stream")
    bgmBattle:setLooping(true)

    sfxHit = love.audio.newSource("hitHurt.wav", "static")
    
    bgmExplore:play()

    battleState = {
        menuSelection = 1, 
        menuOptions = {"ATTACK", "MAGIC", "RUN"},
        playerHP = player.maxHP,
        playerMP = player.maxMP,
        enemyHP = 10,
        showLog = "A WILD SLIME APPEARS!",
        phase = "player", 
        timer = 0,
        isShaking = false,
        shakeTimer = 0,
        shakeIntensity = 5,
        isSlashing = false,
        slashFrame = 1,
        slashTimer = 0,
        isMagicAttack = false 
    }

    excaliburImage = love.graphics.newImage("Excalibur-Sheet.png")
    excaliburQuads = {}

    local EXCALIBUR_FRAMES = 18
    local excFrameW = 32
    local excFrameH = 32

    for i = 0, EXCALIBUR_FRAMES - 1 do
        table.insert(excaliburQuads, love.graphics.newQuad(
            i * excFrameW, 0, excFrameW, excFrameH, excaliburImage:getDimensions()
        ))
    end
    
    excaliburFrame = 1
    excaliburTimer = 0
    excaliburX = 350
    excaliburY = 368


    ----Cutscene Variables----
    introTimer = 0
    introMageX = -20
    -- Set to 120 so the mage walks right through the middle of your 240px tall screen
    introMageY = 120 
    introText = ""
    introAlpha = 0 -- Added this missing variable!
end

function love.update(dt)
    -- ===========================================
    -- 1. INTRO CUTSCENE STATE (Added this logic!)
    -- ===========================================
    if currentState == STATE_INTRO then
        introTimer = introTimer + dt
        
        -- Phase 1: Mage walks in from the left (0 to 2 seconds)
        if introTimer < 2.0 then
            introMageX = introMageX + (50 * dt) -- Move right at speed 50
            
            -- Animate the walking legs
            player.animTimer = player.animTimer + dt
            if player.animTimer > 0.15 then
                player.animTimer = 0
                player.currentFrame = player.currentFrame + 1
                if player.currentFrame > 4 then player.currentFrame = 1 end
            end
            
        -- Phase 2: Mage stops, Text fades in (2 to 4.5 seconds)
        elseif introTimer < 4.5 then
            player.currentFrame = 1 -- Stand still (Idle frame)
            
            introText = "THE GATE HAS CLOSED..."
            
            -- Fade text in slowly
            if introAlpha < 1 then 
                introAlpha = introAlpha + (0.8 * dt) 
            end
            
        -- Phase 3: Transition to Gameplay
        else
            -- We DON'T snap player.x or player.y here.
            -- They will spawn at x=50, y=522 exactly as you defined in love.load!
            currentState = STATE_EXPLORE
        end

    -- ===========================================
    -- 2. EXPLORATION STATE 
    -- ===========================================
    elseif currentState == STATE_EXPLORE then
        local isMoving = false; local speed = player.speed * dt; local halfWidth = 8; local margin = 2 
        if love.keyboard.isDown("d") then 
            if not isWall(player.x+speed+halfWidth-margin, player.y+margin) and not isWall(player.x+speed+halfWidth-margin, player.y+16-margin) then player.x = player.x + speed end
            player.facingX = 1; isMoving = true
        end
        if love.keyboard.isDown("a") then 
            if not isWall(player.x-speed-halfWidth+margin, player.y+margin) and not isWall(player.x-speed-halfWidth+margin, player.y+16-margin) then player.x = player.x - speed end
            player.facingX = -1; isMoving = true
        end
        if love.keyboard.isDown("w") then 
            if not isWall(player.x-halfWidth+margin, player.y-speed+margin) and not isWall(player.x+halfWidth-margin, player.y-speed+margin) then player.y = player.y - speed end
            isMoving = true
        end
        if love.keyboard.isDown("s") then 
            if not isWall(player.x-halfWidth+margin, player.y+speed+16-margin) and not isWall(player.x+halfWidth-margin, player.y+speed+16-margin) then player.y = player.y + speed end
            isMoving = true
        end
        
        if isMoving then
            player.animTimer = player.animTimer + dt
            if player.animTimer > 0.15 then player.animTimer = 0; player.currentFrame = player.currentFrame + 1; if player.currentFrame > 4 then player.currentFrame = 1 end end
        else player.currentFrame = 1 end
        
        excaliburTimer = excaliburTimer + dt
        if excaliburTimer > 0.15 then
            excaliburTimer = 0
            excaliburFrame = excaliburFrame + 1
            if excaliburFrame > #excaliburQuads then
                excaliburFrame = 1
            end
        end

        -- NEW: UPDATE MESSAGE TIMER
        if infoTimer > 0 then
            infoTimer = infoTimer - dt
        end

        -- VISUAL UPDATE: OPEN GATE
        if #enemies == 0 then
            for y, row in ipairs(gameMap) do
                for x, id in ipairs(row) do
                    if id == 15 then
                        gameMap[y][x] = 1 
                    end
                end
            end
        end

        -- WAVE 2 SPAWNER (Y < 140 to prevent getting stuck!)
        if player.y < 372 and currentWave == 1 then
            currentWave = 2
            spawnSlime(400, 184)
            spawnSlime(300, 248)
            spawnSlime(450, 284)
            -- Lock Gate
            gameMap[28][23] = 15
        end
        
        for i, enemy in ipairs(enemies) do
            enemy.timer = enemy.timer - dt
            if enemy.timer < 0 then enemy.timer = love.math.random(1, 3); if love.math.random() > 0.5 then enemy.state = "move"; enemy.moveDir = love.math.random() > 0.5 and 1 or -1 else enemy.state = "idle" end end
            if enemy.state == "move" then
                local nextX = enemy.x + (20 * dt * enemy.moveDir)
                if not isWall(nextX, enemy.y + 8) then enemy.x = nextX else enemy.moveDir = enemy.moveDir * -1 end
                enemy.animTimer = enemy.animTimer + dt
                if enemy.animTimer > 0.15 then enemy.animTimer = 0; enemy.currentFrame = enemy.currentFrame + 1; if enemy.currentFrame > 4 then enemy.currentFrame = 1 end end
            else enemy.currentFrame = 1 end
            
            if math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2) < 12 then 
                currentState = STATE_BATTLE 
                bgmExplore:stop()
                bgmBattle:play()
                
                battleState.targetIndex = i
                battleState.showLog = "A WILD SLIME APPEARS!"
                battleState.menuSelection = 1; battleState.enemyHP = 10; battleState.phase = "player" 
                battleState.isShaking = false; battleState.isSlashing = false
                battleState.isMagicAttack = false 
            end
        end
        camera.x = player.x - (NES_WIDTH/2); camera.y = player.y - (NES_HEIGHT/2)
        if camera.x < 0 then camera.x = 0 end; if camera.y < 0 then camera.y = 0 end
        local mapW = #gameMap[1] * 16; local mapH = #gameMap * 16
        if camera.x > mapW - NES_WIDTH then camera.x = mapW - NES_WIDTH end; if camera.y > mapH - NES_HEIGHT then camera.y = mapH - NES_HEIGHT end

    -- ===========================================
    -- 3. BATTLE STATE
    -- ===========================================
    elseif currentState == STATE_BATTLE then
        if battleState.isSlashing then
            battleState.slashTimer = battleState.slashTimer + dt
            if battleState.slashTimer > 0.05 then
                battleState.slashTimer = 0
                battleState.slashFrame = battleState.slashFrame + 1
                
                if battleState.slashFrame > #slashQuads then
                    battleState.isSlashing = false
                    sfxHit:stop()
                    sfxHit:play()
                    
                    local damage = 0
                    if battleState.isMagicAttack then
                        damage = love.math.random(6, 9)
                        battleState.showLog = "FIREBALL BURNS SLIME FOR " .. damage .. "!"
                        battleState.isMagicAttack = false 
                    else
                        damage = love.math.random(3, 5)
                        battleState.showLog = "YOU HIT SLIME FOR " .. damage .. "!"
                    end
                    
                    battleState.enemyHP = battleState.enemyHP - damage
                    battleState.isShaking = true
                    battleState.shakeTimer = 0.5
                    
                    if battleState.enemyHP <= 0 then
                        battleState.enemyHP = 0
                        battleState.showLog = "SLIME FAINTED!"
                        battleState.phase = "victory"
                        battleState.timer = 1.5 
                    else
                        battleState.phase = "enemy"
                        battleState.timer = 1.5
                    end
                end
            end
        end

        if battleState.isShaking then
            battleState.shakeTimer = battleState.shakeTimer - dt
            if battleState.shakeTimer <= 0 then 
                battleState.isShaking = false; battleState.shakeTimer = 0 
            end
        end

        if battleState.timer > 0 then
            battleState.timer = battleState.timer - dt
            if battleState.timer <= 0 then
                if battleState.phase == "enemy" then
                    local damage = love.math.random(2, 4)
                    battleState.playerHP = battleState.playerHP - damage
                    battleState.showLog = "SLIME ATTACKS! -" .. damage .. " HP"
                    battleState.phase = "player"
                    
                elseif battleState.phase == "victory" then
                    bgmBattle:stop() 
                    bgmExplore:play() 
                    
                    if battleState.targetIndex then
                        table.remove(enemies, battleState.targetIndex)
                        battleState.targetIndex = nil 
                    end
                    
                    currentState = STATE_EXPLORE
                end
            end
        end
    end
end

function love.draw()
    love.graphics.scale(SCALE, SCALE)
    
    -- ===========================================
    -- 1. INTRO CUTSCENE DRAW (Added this logic!)
    -- ===========================================
    if currentState == STATE_INTRO then
        -- Black Background
        love.graphics.clear(0, 0, 0)
        
        -- Draw the Mage walking in
        local frame = math.floor(player.currentFrame)
        if frame < 1 then frame = 1 end
        love.graphics.draw(playerSpriteSheet, playerQuads[frame], introMageX, introMageY)
        
        -- Draw Fading Text
        love.graphics.setColor(1, 1, 1, introAlpha) 
        love.graphics.print(introText, 60, 100)
        love.graphics.setColor(1, 1, 1, 1) -- Reset color back to normal
        
    elseif currentState == STATE_EXPLORE then 
        drawExploration()
    elseif currentState == STATE_BATTLE then 
        drawBattle() 
    end
end

function drawExploration()
    love.graphics.clear(0, 0, 0)
    love.graphics.push(); love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))
    love.graphics.setColor(1, 1, 1)
    
    for y, row in ipairs(gameMap) do
        for x, tileID in ipairs(row) do
            if tileID > 0 and tileID <= #tileQuads then love.graphics.draw(tilesetImage, tileQuads[tileID], (x-1)*16, (y-1)*16) end
        end
    end

    local currentExcQuad = excaliburQuads[excaliburFrame]
    if currentExcQuad then
        love.graphics.draw(excaliburImage, currentExcQuad, excaliburX, excaliburY)
    end
    
    local jumpOffsets = {0, -2, -5, -2}
    for i, enemy in ipairs(enemies) do
        local yOffset = (enemy.state == "move") and (jumpOffsets[enemy.currentFrame] or 0) or 0
        local img = (enemy.state == "move") and slimeRun or slimeIdle
        local quad = (enemy.state == "move") and slimeQuads[enemy.currentFrame] or nil
        if quad then love.graphics.draw(img, quad, enemy.x, enemy.y + yOffset, 0, 1, 1, 8, 8)
        else love.graphics.draw(img, enemy.x, enemy.y, 0, 1, 1, 8, 8) end
    end
    
    love.graphics.draw(playerSpriteSheet, playerQuads[player.currentFrame], player.x, player.y, 0, player.facingX, 1, 8, 0)
    love.graphics.pop(); 
    
    -- NEW: DRAW INFO MESSAGE AT TOP OF SCREEN
    if infoTimer > 0 then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 10, 10, NES_WIDTH - 20, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(infoMessage, 10, 14, NES_WIDTH - 20, "center")
    else
        love.graphics.print("WASD to Move. Space to Interact.", 10, 10)
    end
end

function drawBattle()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(battleBgImage, 0, 0)
    
    local SLIME_SCALE = 2
    local enemyW = slimeBattleImage:getWidth() * SLIME_SCALE
    local enemyH = slimeBattleImage:getHeight() * SLIME_SCALE
    local drawX = (NES_WIDTH / 2) - (enemyW / 2) + 10
    local drawY = (NES_HEIGHT / 2) - (enemyH / 2) - 32 
    
    local offsetX = 0
    if battleState.isShaking then offsetX = love.math.random(-battleState.shakeIntensity, battleState.shakeIntensity) end
    love.graphics.draw(slimeBattleImage, drawX + offsetX, drawY, 0, SLIME_SCALE, SLIME_SCALE)
    
    if battleState.isSlashing then
        local slashQuad = slashQuads[battleState.slashFrame]
        if slashQuad then
            love.graphics.draw(slashImage, slashQuad, drawX + offsetX, drawY, 0, 2, 2)
        end
    end
    
    love.graphics.setColor(1, 1, 1); love.graphics.rectangle("fill", 20, 160, NES_WIDTH - 40, 70)
    love.graphics.setColor(0, 0, 0); love.graphics.rectangle("fill", 22, 162, NES_WIDTH - 44, 66)
    
    love.graphics.setColor(1, 1, 1); love.graphics.print(battleState.showLog, 30, 30)
    love.graphics.print("HP: " .. battleState.playerHP, 30, 170)
    
    love.graphics.setColor(0.4, 0.4, 1)
    love.graphics.print("MP: " .. battleState.playerMP, 80, 170)
    love.graphics.setColor(1, 1, 1)
    
    local startY = 170
    for i, option in ipairs(battleState.menuOptions) do
        love.graphics.print(option, 150, startY + (i * 15))
        if battleState.menuSelection == i then love.graphics.print(">", 140, startY + (i * 15)) end
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if currentState == STATE_EXPLORE then
        if key == "space" then
            -- 1. Get Player's Grid Position (Center of player)
            local gridX = math.floor((player.x + 8) / 16) + 1
            local gridY = math.floor((player.y + 8) / 16) + 1
            
            -- 2. Define neighbors to check (Up, Down, Left, Right)
            local directions = {
                {x = 0, y = -1}, -- UP
                {x = 0, y = 1},  -- DOWN
                {x = -1, y = 0}, -- LEFT
                {x = 1, y = 0}   -- RIGHT
            }
            
            -- 3. Check all neighbors for Tile 15
            for _, dir in ipairs(directions) do
                local checkX = gridX + dir.x
                local checkY = gridY + dir.y
                
                -- Ensure we don't check outside the map (Avoid crashes)
                if gameMap[checkY] and gameMap[checkY][checkX] then
                    local tileID = gameMap[checkY][checkX]
                    
                    if tileID == 15 then
                        -- FOUND THE GATE!
                        if #enemies > 0 then
                            infoMessage = "GATE LOCKED! ENEMIES: " .. #enemies
                            infoTimer = 2.0
                        else
                            -- Optional: Message if gate is open?
                            -- infoMessage = "The path is clear."
                            -- infoTimer = 1.0
                        end
                    end
                end
            end
        end

    elseif currentState == STATE_BATTLE then
        -- (Battle controls remain exactly the same)
        if key == "w" then
            battleState.menuSelection = battleState.menuSelection - 1
            if battleState.menuSelection < 1 then battleState.menuSelection = 3 end
        end
        if key == "s" then
            battleState.menuSelection = battleState.menuSelection + 1
            if battleState.menuSelection > 3 then battleState.menuSelection = 1 end
        end
        
        if key == "space" then
            if battleState.phase == "player" and not battleState.isSlashing then
                local choice = battleState.menuOptions[battleState.menuSelection]
                
                if choice == "ATTACK" then
                    battleState.isSlashing = true
                    battleState.slashFrame = 1
                    battleState.slashTimer = 0
                    battleState.isMagicAttack = false

                elseif choice == "MAGIC" then
                    if battleState.playerMP >= 3 then
                        battleState.playerMP = battleState.playerMP - 3
                        battleState.isSlashing = true
                        battleState.slashFrame = 1
                        battleState.slashTimer = 0
                        battleState.isMagicAttack = true
                    else
                        battleState.showLog = "NOT ENOUGH MP!"
                    end
                    
                elseif choice == "RUN" then
                    bgmBattle:stop() 
                    bgmExplore:play() 
                    currentState = STATE_EXPLORE
                    player.x = player.x - 20 
                end
            end
        end
    end
end

function isWall(x, y)
    local gridX = math.floor(x / 16) + 1; local gridY = math.floor(y / 16) + 1
    if gridY < 1 or gridY > #gameMap or gridX < 1 or gridX > #gameMap[1] then return true end
    local tileID = gameMap[gridY][gridX]
    
    if SOLID_TILES[tileID] == true then return true end
    
    -- Gate Logic (15)
    if tileID == 15 then
        if #enemies > 0 then return true else return false end
    end
    
    return false
end