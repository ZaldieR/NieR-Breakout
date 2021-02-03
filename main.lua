local core = {}
local racket
local bricks
local lives
local ball

function love.load()

    love.window.setMode(800, 600, flags)
    love.window.setTitle("Casse Brique")
    mainFont = love.graphics.newFont("27thRPS-Regular.TTF", 50)
    love.graphics.setFont(mainFont)
    core["wallpaper"] = love.graphics.newImage("wallpaper1.jpg")
    core["wallGame"] = love.graphics.newImage("wallGame2.png")
    core["image1"] = love.graphics.newImage("image24.png")
    core["image2"] = love.graphics.newImage("image33.png")
    core["image3"] = love.graphics.newImage("image41.jpg")
    core["imageS"] = 0
    core["nbimage"] = -1
    core["track"] = love.audio.newSource("track1.mp3", 'stream')
    core["wallfinal"] = love.graphics.newImage("wallpaper1.png")
    core["scene"] = 0
    core["barre"] = love.graphics.newImage("perso1.png")
    core["barreX"] = 195
    core["balle"] = love.graphics.newImage("balle1.png")
    core["block1"] = love.graphics.newImage("block212.jpg") 
    core["block2"] = love.graphics.newImage("block222.jpg")
    core["block3"] = love.graphics.newImage("block132.jpg")
    core["brick"] = 0
    core["brickLine"] = 10
    core["brickcol"] = 6
    core["vie"] = 2
    core["racketHeight"] = 90
    core["racketY"] = 510
    core["defaultSpeedY"] = 335
    core["defaultSpeedX"] = 130
    WIN_WIDTH = 600
    WIN_HEIGHT = 350
    nbBricks = core.brickLine * core.brickcol

    math.randomseed(love.timer.getTime())  -- Pemet un vrai Random    
    core.initializeRacket()
    core.initializeBricks()
    core.initializeVies()
    core.initializeBall(core.racketHeight, core.racketY)
    core.image()
    core.randomMusic()

end

function love.draw()

    if (core.scene == 0) then
        core.menu()
        if (positionx > 720 and positionx < 770 and positiony > 10 and positiony < 50) then
            if (love.mouse.isDown(1)) then
                love.event.quit()
            end
        end

    elseif (core.scene == 1) then
        core.game()
        love.audio.play(core.track)            
        for line=1, #bricks do -- Ligne
            for column=1, #bricks[line] do -- Colonne
              local brick = bricks[line][column]
              if brick.isNotBroken then -- Si la brique n'est pas cassée
                love.graphics.draw(core.block1, brick.x, brick.y)--, brick.width, brick.height) -- Rectangle
              end
            end
        end
        for i = 0, lives.count - 1 do
            local posX = 5 + i * 1.20 * lives.width
            love.graphics.draw(lives.img, posX + 71, WIN_HEIGHT - lives.height + 250)
        end
        love.graphics.draw(core.barre, racket.x, racket.y)
        love.graphics.draw(core.balle, ball.x, ball.y)

    elseif (core.scene == 3) then
        core.gameOver()
        love.audio.stop(core.track)
    end

end

function love.update(dt)

    positionx = love.mouse.getX()
    positiony = love.mouse.getY()
    if (core.scene == 0) then
        if (positionx > 650 and positionx < 750 and positiony > 550 and positiony < 580) then
            if (love.mouse.isDown(1)) then
                core.scene = 1
            end
        end
    elseif (core.scene == 1) then
        if (love.keyboard.isDown("d", "right")) then
            racket.x = racket.x + 5
        end
        if (love.keyboard.isDown("q", "left")) then
            racket.x = racket.x - 5
        end   
        if (racket.x <= 75) then
            racket.x = 75
        elseif (racket.x >= 380) then
            racket.x = 380
        end 

        ball.x = ball.x + ball.speedX * dt
        ball.y = ball.y + ball.speedY * dt
        if ball.x + ball.width >= WIN_WIDTH - 130 then  -- Bordure droite
            ball.speedX = -ball.speedX
        elseif ball.x <= 69 then -- Bordure gauche
            ball.speedX = -ball.speedX
        end
          
        if ball.y <= 2 then  -- Bordure haut
            ball.speedY = -ball.speedY
        elseif ball.y + ball.height >= WIN_HEIGHT + 500 then -- Bordure bas
            lives.count = lives.count - 1
            resetBall(core.racketY)
        end

        if (collideRect(ball, racket)) then
            collisionBallWithRacket()
        end

        for line = #bricks, 1, -1 do 
            for column= #bricks[line], 1, -1 do
                if (bricks[line][column].isNotBroken and collideRect(ball, bricks[line][column])) then
                    collisionBallWithBrick(ball, bricks[line][column])
                end
            end
        end

        if (nbBricks == 0 or lives.count == -1) then
            core.scene = 3
        end

    elseif (core.scene == 3) then
        if (positionx > 720 and positionx < 770 and positiony > 10 and positiony < 50) then
            if (love.mouse.isDown(1)) then
                love.event.quit()
            end
        elseif (positionx > 650 and positionx < 780 and positiony > 550 and positiony < 580) then
            if (love.mouse.isDown(1)) then
                core.scene = 0
                math.randomseed(love.timer.getTime())  -- Pemet un vrai Random
                core.initializeRacket()
                core.initializeBricks()
                core.initializeVies()
                core.initializeBall(core.racketHeight, core.racketY)
                nbBricks = core.brickLine * core.brickcol
                core.image()
                core.randomMusic()
            end
        end
        
    end

end

function core.menu()

    love.graphics.draw(core.wallpaper)
    love.graphics.print("Game", 300, 100, 0, 1.5, 1.5)
    love.graphics.print("Quit", 720, 10, 0, 0.7, 0.7)
    love.graphics.print("Play", 650, 550, 0, 1, 1)

end

function core.game()

    love.graphics.draw(core.wallGame, -180, 0)
    love.graphics.draw(core.imageS, 69, 0)
    love.graphics.print(racket.x, 10, 10)

end

function core.initializeRacket()

    racket = {}
    racket.speedX = 251 
    racket.width = 90
    racket.height = 35
    racket.x = (WIN_WIDTH - racket.width - 285)
    racket.y = WIN_HEIGHT - 64 + 225

end

function createBrick(line, column)

    -- Fonction pour créer une brique et l'initialiser en fonction de sa position dans le mur
    local brick = {}
    brick.isNotBroken = true -- Brique pas encore cassée
    brick.width = WIN_WIDTH / core.brickLine - 5 -- Largeur
    brick.height = WIN_HEIGHT / 35 -- Hauteur
    brick.x = 2.5 + (column-1) * (brick.width - 14.14) + 68-- Position en abscisse
    brick.y = line * (WIN_HEIGHT/9.1+2.5)  + 40 -- Position en ordonnée
    return brick
    
end

function core.initializeBricks()

    bricks = {}
    for line = 1, core.brickcol do
        table.insert(bricks, {})
        for column = 1, core.brickLine do
            local brick = createBrick(line, column)
            table.insert(bricks[line], brick)
        end
    end

end

function core.initializeVies()

    lives = {}
    lives.count = core.vie
    lives.img = love.graphics.newImage("balle1.png")
    lives.width, lives.height = lives.img:getDimensions()
    lives.width = lives.width - 3

end

function core.initializeBall(racketHeight, racketY)

    ball = {}
    ball.width, ball.height = 25, 25
    ball.speedY = -core.defaultSpeedY
    ball.speedX = math.random(-core.defaultSpeedX, core.defaultSpeedX)
    ball.x = WIN_WIDTH / 2 - ball.width / 2
    ball.y = racketY - 2 * ball.height - ball.height / 2

end

function collideRect(rect1, rect2)

    if (rect1.x < rect2.x + rect2.width and
        rect1.x + rect1.width > rect2.x and
        rect1.y < rect2.y + rect2.height and
        rect1.y + rect1.height > rect2.y) then
            return true
    else
        return false
    end    

end

function resetBall(racketY)

    ball.speedY = -core.defaultSpeedY
    ball.speedX = math.random(-core.defaultSpeedX, core.defaultSpeedX)
    ball.x = WIN_WIDTH / 2 - ball.width / 2
    ball.y = racketY - 2 * ball.height - ball.height / 2

end

function collisionBallWithRacket()

    if (ball.x < racket.x + 1/8 * racket.width and ball.speedX >= 0) then
        if (ball.speedX <= core.defaultSpeedX / 2) then
            ball.speedX = math.random(0.75 * core.defaultSpeedX, core.defaultSpeedX)
        end
    end
end


function collisionBallWithRacket()
  
    -- Collision par la gauche (coin haut inclus)
    if ball.x < racket.x + 1/8 * racket.width and ball.speedX >= 0 then
      if ball.speedX <= core.defaultSpeedX/2 then -- Si vitesse trop faible
        ball.speedX = -math.random(0.75*core.defaultSpeedX, core.defaultSpeedX) -- Nouvelle vitesse
      else
        ball.speedX = -ball.speedX
      end
    -- Collision par la droite (coin haut inclus)
    elseif ball.x > racket.x + 7/8 * racket.width and ball.speedX <= 0 then
      if ball.speedX >= -core.defaultSpeedX/2 then  -- Si vitesse trop faible
        ball.speedX = math.random(0.75*core.defaultSpeedX, core.defaultSpeedX) -- Nouvelle vitesse
      else 
        ball.speedX = -ball.speedX
      end
    end
    -- Collision par le haut
    if ball.y < racket.y and ball.speedY > 0 then
      ball.speedY = -ball.speedY
  end

end

function collisionBallWithBrick(ball, brick)
  
    -- Collision côté gauche brique
    if ball.x < brick.x and ball.speedX > 0 then
        ball.speedX = -ball.speedX
    -- Collision côté droit brique
    elseif ball.x > brick.x + brick.width and ball.speedX < 0 then
        ball.speedX = -ball.speedX
    end
    -- collision haut brique
    if ball.y < brick.y and ball.speedY > 0 then
      ball.speedY = -ball.speedY
    -- Collision bas brique
    elseif ball.y > brick.y and ball.speedY < 0 then
      ball.speedY = -ball.speedY
    end
      
    brick.isNotBroken = false -- Brique maintenant cassée
    nbBricks = nbBricks - 1 -- Ne pas oublier de décrémenter le nombre de briques
  
end

function core.gameOver()
    
    love.graphics.draw(core.wallfinal, -20)
    love.graphics.print("Quit", 720, 10, 0, 0.7, 0.7)
    love.graphics.print("Restart", 650, 550, 0, 1, 1)

end

function core.image()

    core.nbimage = math.random(0, 2)
    if (core.nbimage == 0) then
        core.imageS = core.image1
    elseif (core.nbimage == 1) then
        core.imageS = core.image2
    elseif (core.nbimage == 2) then
        core.imageS = core.image3
    end

end

function core.randomBrick()

    rand = math.random(0, 2)
    if (rand == 0) then
        core.brick = core.block1
    elseif (rand == 1) then
        core.brick = core.block2
    elseif (rand == 2) then
        core.brick = core.block3
    end

end

function core.randomMusic()

    rand = math.random(0,4)
    if (rand == 0) then
        core.track = love.audio.newSource("track1.mp3", 'stream')
    elseif (rand == 1) then
        core.track = love.audio.newSource("track2.mp3", 'stream')
    elseif (rand == 2) then
        core.track = love.audio.newSource("track3.mp3", 'stream')
    elseif (rand == 3) then
        core.track = love.audio.newSource("track4.mp3", 'stream')
    elseif (rand == 4) then
        core.track = love.audio.newSource("track5.mp3", 'stream')
    end

end