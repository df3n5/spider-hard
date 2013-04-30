require("AnAL")

function ObjectNew(o, self)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

Sprite = {image="", 
    pos={x=0, y=0},
    rot=0,
    scale={x=1, y=1},
    halfDims={w=0, h=0},
    currentLeg=1,
    visible=true}

function Sprite:new(o)
    return ObjectNew(o, self)
end

function Sprite:init()
    self.visible = true
    self.sprite = love.graphics.newImage(self.image)
    self.halfDims.w = self.sprite:getWidth() / 2
    self.halfDims.h = self.sprite:getHeight() / 2
    self.centrePos = {}
    self.centrePos.x = self.pos.x + self.halfDims.w
    self.centrePos.y = self.pos.y + self.halfDims.h
end

function Sprite:draw()
    if(self.visible) then
        love.graphics.draw(self.sprite, 
            self.pos.x, 
            self.pos.y, 
            self.rot, 
            self.scale.x,
            self.scale.y, 
            self.halfDims.w, 
            self.halfDims.h)
    end
end

function Sprite:setPos(pos)
    self.pos = pos
    self.centrePos.x = self.pos.x + self.halfDims.w
    self.centrePos.y = self.pos.y + self.halfDims.h
end

Target = Sprite:new()

function Target:init()
    Sprite.init(self)
    target:setTarget(spider.centrePos, spider.legs[target.currentLeg])
end

function Target:setTarget(spritePos, relativePos)
    self:setPos({x=(spritePos.x + relativePos.x - self.halfDims.w),
        y=(spritePos.y + relativePos.y - self.halfDims.h)})
end

Spider = Sprite:new()

function Spider:init()
    Sprite.init(self)
    self.movingLeft = false
    self.legs = {}
    self.legs[1] = {x=15, y=-24}
    self.legs[2] = {x=24, y=-9}
    self.legs[3] = {x=24, y=10}
    self.legs[4] = {x=15, y=22}
    self.legs[5] = {x=-18, y=22}
    self.legs[6] = {x=-26, y=10}
    self.legs[7] = {x=-26, y=-9}
    self.legs[8] = {x=-13, y=-24}
    -- TODO: Randomise this
    --self.weakestLeg = 1
    self.weakestLeg = math.random(1,8)
    self.health = (level*2)
    --self.legHealth = {}
    --for i=1,8 do
    --    self.legHealth[i] = 1
    --end
    self.origPos = {}
    self.origPos.x = self.pos.x
    self.origPos.y = self.pos.y
end

function Spider:update(delta, man)
    speed = 500
    if not ended then
        if self.movingLeft == true then
            if (#anims == 0) then
                self.pos.x = self.pos.x - (delta*speed)
                if(self.pos.x < man.pos.x) then
                    man.health = man.health - 1
                    -- go back to orig pos
                    self.pos.x = self.origPos.x
                    self.pos.y = self.origPos.y
                    self.movingLeft = false
                    hurt = loadSound("hurt.ogg")
                    hurt:play()
                    if(man.health <= 0) then
                        ended = true
                        win = false
                        man.visible = false
                    else
                        spiderMove = false
                        local img = love.graphics.newImage("anim_man.png")
                        local anim = newAnimation(img, 128, 128, 0.2, 0)
                        anim:setMode("once")
                        table.insert(anims, {pos=man.pos, anim=anim})
                    end
                end
            end
        end
    end
end


function Spider:draw()
    Sprite.draw(self)
    love.graphics.print(string.format("Health %d", self.health), self.pos.x-25, self.pos.y + 75)
end

Man = Sprite:new{}

function Man:init()
    Sprite.init(self)
    self.health = 13
end

function Man:draw()
    Sprite.draw(self)
    love.graphics.print(string.format("Health %d", self.health), self.pos.x, self.pos.y + 100)
end

function Man:fire(spider, leg)
    logger:d(string.format("In man:fire leg is %d weakest is %d", leg, spider.weakestLeg))
    local nearDelta = 1
    if(spider.weakestLeg == leg) then
        -- We have a successful hit.
        --spider.legHealth[leg] = spider.health - 1
        spider.health = spider.health - 1
        --randomise again
        spider.weakestLeg = math.random(1,8)
        table.insert(events, "SPIDER_LEG_DEAD")
    elseif(((spider.weakestLeg >= (leg - nearDelta)) and (spider.weakestLeg <= (leg + nearDelta)))
        or (spider.weakestLeg==1 and leg==8) or (spider.weakestLeg==8 and leg==1)) then
        table.insert(events, "SPIDER_LEG_ALMOST_DEAD")
    else
        table.insert(events, "SPIDER_LEG_MISS")
    end
    -- We need to do something interesting here like show if they are close.
end


--Love2D Logging
Logger = { logs={}, 
    maxLogs=100,
    startPos={x=0,y=0},
    logYDelta=14,
    visible=false}

function Logger:new(o)
    return ObjectNew(o, self)
end

function Logger:insert(msg)
    while #self.logs > self.maxLogs do
        table.remove()
    end
    table.insert(self.logs, msg)
end

function Logger:d(msg)
    self:insert(os.date("%c") .. " DEBUG: " .. msg)
end

function Logger:e(msg)
    self:insert(os.date("%c") .. " ERROR: " .. msg)
end

function Logger:draw()
    if self.visible == true then
        logY = self.startPos.y
        for i=#self.logs, 1, -1 do
            love.graphics.print(self.logs[i], 0, logY)
            logY = logY + self.logYDelta
        end
    end
end

--

function checkQuit()
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end


function loadSound(filename)
    -- TODO: Put into a function
    data = love.sound.newSoundData(filename)
    return love.audio.newSource(data)
end

function ui()
end

function drawGame()
    ui()
    if inExplanation then
        love.graphics.setBackgroundColor(0, 0, 0)
        storyString1 = "Story:\n\nYou are a man with a gun. \nA giant spider threatens to eat you and everyone you care about. \nTo defeat him, you will need to hit him in his vulnerable leg repeatedly.\n\n"
        storyString2 = "Rules:\n\n1) When he flashes green it means you hit his vulnerable leg and his health went down.\n\n"
        storyString3 = "2) When he flashes orange, it means you hit a leg right next to the vulnerable leg.\n\n"
        storyString4 = "3) When he flashes red, it means you completely missed the vulnerable leg.\n\n"
        storyString5 = "4) After you hit his vulnerable leg, the vulnerable leg will change.\n\n"
        storyString6 = "Controls:\n\nArrow keys to select a leg and space to fire.\n\n"
        love.graphics.printf(storyString1 .. storyString2 .. storyString3 .. storyString4 .. storyString5 .. storyString6, 100,100, love.graphics.getWidth()-200)
    else
        love.graphics.setBackgroundColor(85, 0, 0)
        spider:draw()
        man:draw()
        target:draw()
        love.graphics.print(string.format("level %d", level), 0,0)
        if not spiderMove then
            target.visible = true
            while #events > 0 do
                event = table.remove(events)
                local animTime = 0.3
                spiderMove = not spiderMove
                if event == "SPIDER_LEG_DEAD" then
                    if not ended then 
                        local img = love.graphics.newImage("anim_spider_good.png")
                        local anim = newAnimation(img, 64, 64, animTime, 0)
                        anim:setMode("once")
                        table.insert(anims, {pos=spider.pos, anim=anim})

                        sound = loadSound("pickup.ogg")
                        sound:play()
                        --sound = loadSound("small_explosion.ogg")
                        --sound:play()
                    end
                elseif event == "SPIDER_LEG_ALMOST_DEAD" then
                    local img = love.graphics.newImage("anim_spider_med.png")
                    local anim = newAnimation(img, 64, 64, animTime, 0)
                    anim:setMode("once")
                    table.insert(anims, {pos=spider.pos, anim=anim})
                    laser = loadSound("blip2.ogg")
                    laser:play()
                elseif event == "SPIDER_LEG_MISS" then
                    local img = love.graphics.newImage("anim_spider_bad.png")
                    local anim = newAnimation(img, 64, 64, animTime, 0)
                    anim:setMode("once")
                    table.insert(anims, {pos=spider.pos, anim=anim})
                    laser = loadSound("blip.ogg")
                    laser:play()
                end
            end
        else
            target.visible = false
        end
        for i = 1, #anims do
            anims[i].anim:draw(anims[i].pos.x - 15, anims[i].pos.y - 15)
        end
        --Check for win condition
        if ended then
            if win then
                -- wait until anim done completely
                if (#anims == 0) then
                    love.graphics.print("YOU WIN", 350, 100)
                end
            else
                -- wait until anim done completely
                if (#anims == 0) then
                    love.graphics.print("YOU LOST", 350, 100)
                end
            end
            love.graphics.print("Press space to continue", 250, 150)
        end
    end
    logger:draw()
end

-- Do some loading here
function love.load()
    level = 1
    -- constants
    PI = 3.14159
    -- create some sprites.
    spider = Spider:new{pos={x=450.0,y=225.0}, image="spider.png"}
    spider:init()
    man = Man:new{pos={x=250.0,y=200.0},image="man.png"}
    man:init()
    target = Target:new{pos={x=100,y=200},image="target.png"}
    target:init()
    -- Set bg
    --love.graphics.setBackgroundColor(155, 100, 100)
    love.graphics.setBackgroundColor(85, 0, 0)
    events = {}
    logger = Logger:new()
    anims = {}
    titleImage = love.graphics.newImage("title.png")
    inTitle = true
    inExplanation = false
    win = false
    ended = false 
    spiderMove = false
    mainFont = love.graphics.setNewFont("Vdj.ttf", 14);

    music = loadSound("light_fluffy.ogg")
    music:setLooping(true)
    music:play()
end

-- Do some drawing here.
function love.draw()
    if(inTitle) then
        love.graphics.draw(titleImage, 
            0, 
            0)
    else
        drawGame()
    end
end


function love.keypressed(key)
    if key == "tab" then
        logger.visible = not logger.visible
    end
    if(inTitle) then
        if key == " " then
            inTitle=false
            inExplanation=true
        end
    elseif(inExplanation) then
        if key == " " then
            inExplanation=false
        end
    else
        if ended then
            if key == " " then
                spider:init()
                man:init()
                target:init()
                ended = false
                win = false
                spiderMove = false
                playedExplosionSound = false
            end
        else
            if(not spiderMove) then
                leg = target.currentLeg
                if key == "down" or key=="right" then
                    leg = leg + 1
                    if(leg > 8) then
                        leg = 1
                    end
                elseif key == "up" or key=="left" then
                    leg = leg - 1
                    if(leg < 1) then
                        leg = 8
                    end
                elseif key == " " then
                    man:fire(spider, target.currentLeg)
                end
                target.currentLeg = leg
                target:setTarget(spider.centrePos, spider.legs[target.currentLeg])
            else
                --spider move can't do anything                
            end
        end
    end
end

function love.update(dt)
    -- TODO: Point to all legs
    checkQuit()
    spider:update(dt, man)
    for i=#anims, 1, -1 do
        anims[i].anim:update(dt)
        if not anims[i].anim.playing then
            table.remove(anims, i)
        end
    end
    if spiderMove then
        -- Spider's time to shine
        if spider.movingLeft == false then
            -- Do spider anim
            spider.movingLeft = true
        end
    end

    --Check for win condition
    if spider.health <= 0 then
        win = true
        ended = true
        spider.visible=false
        if(not playedExplosionSound) then
            level = level + 1
            sound = loadSound("explosion.ogg")
            sound:play()
            playedExplosionSound = true
        end
    end
end
