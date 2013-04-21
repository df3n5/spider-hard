Sprite = {image="", 
    pos={x=0, y=0},
    rot=0,
    scale={x=1, y=1},
    halfDims={w=0, h=0},
    currentLeg=0}

function Sprite:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
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
Man = Sprite:new()

function Spider:init()
    Sprite.init(self)
    self.legs = {}
    self.legs[0] = {x=15, y=-24}
    self.legs[1] = {x=24, y=-9}
    self.legs[2] = {x=24, y=-9}
    self.legs[3] = {x=24, y=-9}
    self.legs[4] = {x=24, y=-9}
    self.legs[5] = {x=24, y=-9}
    self.legs[6] = {x=24, y=-9}
    self.legs[7] = {x=24, y=-9}
end

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
    love.graphics.print(string.format("Current Leg. %d ", target.currentLeg), 0, 0)
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
end

function love.keypressed(key)
    leg = target.currentLeg
    if key == "1" then
        leg = leg + 1
        if(leg > 7) then
            leg = 0
        end
    elseif key == "2" then
        leg = leg - 1
        if(leg < 0) then
            leg = 7
        end
    end
    target.currentLeg = leg
end


function love.update(dt)
    -- TODO: Point to all legs

    target:setTarget(spider.centrePos, spider.legs[target.currentLeg])
    checkQuit()
end
