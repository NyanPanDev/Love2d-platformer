local Player = {}
local Sounds = {}
local Play = true

function Player:load()
    self.x = 100
    self.y = 50
    self.startX = self.x
    self.startY = self.y
    self.width = 20
    self.height = 60
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 200
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1500
    self.jumpAmount = -500
    self.coins = 0
    self.health = {current = 3, max = 3}

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3,
    }

    self.graceTime = 0
    self.graceDuration = 0.1

    self.alive = true
    self.grounded = false
    self.attacking = false
    self.hasDoubleJump = false
    self.idle = true
    self.direction = "right"
    self.state = "idle"

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setGravityScale(0)

    Sounds.run = love.audio.newSource("resources/audio/walk.mp3","static")
    Sounds.run:setVolume(0.4)
    Sounds.jump = love.audio.newSource("resources/audio/jump_01.wav", "static")
    Sounds.jump:setVolume(0.5)
end

function Player:loadAssets()
    self.animation = {timer = 0, rate = 0.07}
 
    self.animation.run = {total = 8, current = 1, img = {}}
    for i=1, self.animation.run.total do
       self.animation.run.img[i] = love.graphics.newImage("resources/player/run/run"..i..".png")
    end
 
    self.animation.idle = {total = 6, current = 1, img = {}}
    for i=1, self.animation.idle.total do
       self.animation.idle.img[i] = love.graphics.newImage("resources/player/idle/idle"..i..".png")
    end
 
    self.animation.jump = {total = 4, current = 1, img = {}}
    for i=1, self.animation.jump.total do
       self.animation.jump.img[i] = love.graphics.newImage("resources/player/jump/jump"..i..".png")
    end

    self.animation.attack = {total = 8, current = 1, img = {}}
    for i=1, self.animation.attack.total do
      self.animation.attack.img[i] = love.graphics.newImage("resources/player/attack/slam"..i..".png")
   end
 
    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
 end

 function Player:takeDamage(amount)
    self:tintRed()
    if self.health.current - amount > 0 then
       self.health.current = self.health.current - amount
    else
       self.health.current = 0
       self:die()
    end
    print("Player health: "..self.health.current)
 end

 function Player:die()
    print("Player died")
    self.alive = false
 end

 function Player:respawn()
    if not self.alive then
       self:resetPosition()
       self.health.current = self.health.max
       self.alive = true
    end
 end

 function Player:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
 end

 function Player:tintRed()
    self.color.green = 0
    self.color.blue = 0
 end

 function Player:incrementCoins()
    self.coins = self.coins + 1
 end

 function Player:update(dt)
    self:unTint(dt)
    self:respawn()
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
 end

 function Player:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
 end

 function Player:setState()
    if not self.grounded then
       self.state = "jump"
       if Play then
         Sounds.jump:play()
         Play = false
       end
       Sounds.run:pause()
    elseif self.xVel == 0 then
      if self.attacking and not self.idle then
         self.state = "attack"
      elseif self.idle then
         self.state = "idle"
         Sounds.run:pause()
         Play = true
      end
    else
      self.state = "run"
      Sounds.run:play()
      Play = true
    end
 end

 function Player:setDirection()
    if self.xVel < 0 then
       self.direction = "left"
    elseif self.xVel > 0 then
       self.direction = "right"
    end
 end

 function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
       self.animation.timer = 0
       if self.state == "attack" then
         self:setAttackFrame()
         self.state = "idle"
       else
         self:setNewFrame()
       end
    end
 end

 function Player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
       anim.current = anim.current + 1
    else
       anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
    if anim.current == anim.total then
      self.idle = true
   end
 end

function Player:setAttackFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
   if anim.current == anim.total then
      self.idle = true
   end
   if love.keyboard.isDown("z") then
      anim.current = 1
   end
end

 function Player:decreaseGraceTime(dt)
    if not self.grounded then
       self.graceTime = self.graceTime - dt
    end
 end
 
 function Player:applyGravity(dt)
    if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
    end
 end
 
 function Player:move(dt)
    if love.keyboard.isDown("d", "right") then
      self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
      self.attacking = false
    elseif love.keyboard.isDown("a", "left") then
      self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
      self.attacking = false
    else
       self:applyFriction(dt)
    end
 end

 function Player:stopAnimation(bool)
   self.idle = bool
 end
 
 function Player:applyFriction(dt)
    if self.xVel > 0 then
       self.xVel = math.max(self.xVel - self.friction * dt, 0)
    elseif self.xVel < 0 then
       self.xVel = math.min(self.xVel + self.friction * dt, 0)
    end
 end
 
 function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
 end
 
 function Player:beginContact(a, b, collision)
    if self.grounded == true then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
       if ny > 0 then
          self:land(collision)
       elseif ny < 0 then
          self.yVel = 0
       end
    elseif b == self.physics.fixture then
       if ny < 0 then
          self:land(collision)
       elseif ny > 0 then
          self.yVel = 0
       end
    end
 end
 
 function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
   --  ENABLE DOUBLE JUMP
   --  self.hasDoubleJump = true
    self.graceTime = self.graceDuration
 end
 
 function Player:jump(key)
    if (key == "w" or key == "up") then
       if self.grounded or self.graceTime > 0 then
          self.yVel = self.jumpAmount
          self.graceTime = 0
       elseif self.hasDoubleJump then
          self.hasDoubleJump = false
          self.yVel = self.jumpAmount * 0.8
       end
    end
 end

 function Player:attack(key)
   if (key == "z" or key == "j") then
      if self.grounded then
         self.attacking = true
         self.idle = false
      end
   end
end
 
 function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
       if self.currentGroundCollision == collision then
          self.grounded = false
       end
    end
 end
 
 function Player:draw()
    local scaleX = 1
    if self.direction == "left" then
       scaleX = -1
    end
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
    love.graphics.setColor(1,1,1,1)
 end
 
 return Player