local Map = {}
local STI = require("sti")
local Player = require("player")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0,2000)
    World:setCallbacks(beginContact, endContact)
 
    self:init()
 end

 function Map:init()
    self.level = STI("map/"..self.currentLevel..".lua", {"box2d"})
 
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    -- self.entityLayer = self.level.layers.entity
 
    self.solidLayer.visible = false
    -- self.entityLayer.visible = false
    MapWidth = self.groundLayer.width * 16
 
    -- self:spawnEntities()
 end

 function Map:next()
    self:clean()
    self.currentLevel = self.currentLevel + 1
    self:init()
    Player:resetPosition()
 end

 function Map:clean()
    self.level:box2d_removeLayer("ground")
 end

 function Map:update()
    if Player.x > MapWidth - 16 then
       self:next()
    end
 end

 function Map:selfLevel(number)
   number = self.currentLevel
   return number
 end

 return Map