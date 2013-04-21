function checkQuit()
    if love.keyboard.isDown("escape") then
        love.graphics.print("It's a quitting time.", 400, 300)
        love.event.quit()
    end
end

function checkVelKeys(dt)
    if love.keyboard.isDown("1") then
        rate = - 0.5 * dt
        xVel = xVel + xVel * rate
        yVel = yVel + yVel * rate
        rotVel = rotVel + rotVel * rate
    end
    if love.keyboard.isDown("2") then
        rate = 2.0 * dt
        xVel = xVel + xVel * rate
        yVel = yVel + yVel * rate
        rotVel = rotVel + rotVel * rate
    end
end

function loadSound(filename)
    -- TODO: Put into a function
    data = love.sound.newSoundData(filename)
    return love.audio.newSource(data)
end

function tag()
    love.graphics.print(string.format("Experiment by jmf. Press 1 and 2 to slow and speed up spider"), 0, 0)
end

-- Do some loading here
function love.load()
    -- constants
    PI = 3.14159
    -- spider stuff
    spider = love.graphics.newImage("spider.png")
    x = 50.0
    y = 50.0
    halfWidth = spider:getWidth() / 2
    halfHeight = spider:getHeight() / 2
    rot = 0.0

    man = love.graphics.newImage("man.png")
    manX = 50.0
    manY = 50.0
    manScale = 1
    manHalfWidth = (man:getWidth() / 2)
    manHalfHeight = (man:getHeight() / 2)
    manRot = 0.0

    speed = 400.0
    xVel = speed
    yVel = speed
    rotVel = PI / 2
    
    love.graphics.setBackgroundColor(155, 100, 100)
    -- Howto load sound
    bounce = loadSound("bounce.wav")
end

-- Do some drawing here.
function love.draw()
    love.graphics.draw(spider, x, y, rot, 1, 1, halfWidth, halfHeight)
    love.graphics.print(string.format("x : %d - y is : %d ", x, y), 400, 300)
    love.graphics.print(string.format("width %d height %d ", love.graphics.getWidth(), love.graphics.getHeight()), 400, 400)
    love.graphics.draw(man, manX, manY, manRot, manScale, manScale, manHalfWidth, manHalfHeight)
    tag()
end

function love.update(dt)
    rot = rot + (rotVel * dt)
    x = x + (xVel * dt)
    y = y + (yVel*dt)
    if x > (love.graphics.getWidth()-halfWidth) or x < halfWidth then
        xVel = -xVel
        love.audio.stop(bounce)
        love.audio.play(bounce)
    end
    if y > (love.graphics.getHeight()-halfHeight) or y < halfHeight then
        yVel = -yVel
        love.audio.stop(bounce)
        love.audio.play(bounce)
    end
    checkQuit()
    checkVelKeys(dt)
end
