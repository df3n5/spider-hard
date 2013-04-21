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
    currentLeg=0}

function Sprite:new(o)
    return ObjectNew(o, self)
end

function Sprite:init()
    self.sprite = love.graphics.newImage(self.image)
    self.halfDims.w = self.sprite:getWidth() / 2
    self.halfDims.h = self.sprite:getHeight() / 2
    self.centrePos = {}
    self.centrePos.x = self.pos.x + self.halfDims.w
    self.centrePos.y = self.pos.y + self.halfDims.h
end

function Sprite:draw()
    love.graphics.draw(self.sprite, 
        self.pos.x, 
        self.pos.y, 
        self.rot, 
        self.scale.x,
        self.scale.y, 
        self.halfDims.w, 
        self.halfDims.h)
end

function Sprite:setPos(pos)
    self.pos = pos
    self.centrePos.x = self.pos.x + self.halfDims.w
    self.centrePos.y = self.pos.y + self.halfDims.h
end

Target = Sprite:new()

function Target:init()
    Sprite.init(self)
    self.currentLeg = 0
end

function Target:setTarget(spritePos, relativePos)
    self:setPos({x=(spritePos.x + relativePos.x - self.halfDims.w),
        y=(spritePos.y + relativePos.y - self.halfDims.h)})
end

Spider = Sprite:new()

function Spider:init()
    Sprite.init(self)
    self.legs = {}
    self.legs[0] = {x=15, y=-24}
    self.legs[1] = {x=24, y=-9}
    self.legs[2] = {x=24, y=10}
    self.legs[3] = {x=15, y=22}
    self.legs[4] = {x=-18, y=22}
    self.legs[5] = {x=-26, y=10}
    self.legs[6] = {x=-26, y=-9}
    self.legs[7] = {x=-13, y=-24}
    -- TODO: Randomise this
    self.weakestLeg = 0
    self.legHealth = {}
    for i=0,9 do
        self.legHealth[i] = 1
    end
end

Man = Sprite:new()

function Man:fire(spider, leg)
    if(spider.weakestLeg == leg) then
        -- We have a successful hit.
        spider.legHealth[leg] = 0
        table.insert(events, "SPIDER_LEG_DEAD")
    end
    -- We need to do something interesting here like show if they are close.
end


--Love2D Logging
Logger = { logs={}, 
    maxLogs=100,
    startPos={x=0,y=0},
    logYDelta=14,
    visible=true}

function Logger:new(o)
    return ObjectNew(o, self)
end

function Logger:insert(msg)
    while table.getn(self.logs) > self.maxLogs do
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
        for i = table.getn(self.logs), 1, -1 do
            love.graphics.print(self.logs[i], 0, logY)
            logY = logY + self.logYDelta
        end
    end
end

--

function checkQuit()
    if love.keyboard.isDown("escape") then
        love.graphics.print("It's a quitting time.", 400, 300)
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

-- Do some drawing here.
function love.draw()
    spider:draw()
    man:draw()
    target:draw()
    ui()
    while table.getn(events) > 0 do
        event = table.remove(events)
        if event == "SPIDER_LEG_DEAD" then
            love.graphics.print("SPIDER_LEG_DEAD", 0, 0)
        end
    end
    logger:draw()
end

-- Do some loading here
function love.load()
    -- constants
    PI = 3.14159
    -- create some sprites.
    spider = Spider:new{pos={x=50.0,y=50.0}, image="spider.png"}
    spider:init()
    man = Man:new{pos={x=400.0,y=50.0},image="man.png"}
    man:init()
    target = Target:new{pos={x=100,y=200},image="target.png"}
    target:init()
    -- Set bg
    love.graphics.setBackgroundColor(155, 100, 100)
    -- Howto load sound
    bounce = loadSound("bounce.wav")
    events = {}
    logger = Logger:new()
end

function love.keypressed(key)
    leg = target.currentLeg
    if key == "`" then
        logger.visible = not logger.visible
    elseif key == "1" then
        leg = leg + 1
        if(leg > 7) then
            leg = 0
        end
    elseif key == "2" then
        leg = leg - 1
        if(leg < 0) then
            leg = 7
        end
    elseif key == "return" then
        man:fire(spider)
        logger:d("Return Pressed")
        logger:d("Blah Blah")
        logger:d("Blah Blah")
    end
    target.currentLeg = leg
end


function love.update(dt)
    -- TODO: Point to all legs

    target:setTarget(spider.centrePos, spider.legs[target.currentLeg])
    checkQuit()
end
