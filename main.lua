love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Camera = require("camera")
local Map = require("map")
local Music = {}

function love.load()
    Map:load()
    background = love.graphics.newImage("resources/world/Background.png")
    Player:load()
    Music.forest = love.audio.newSource("resources/audio/Woodland_Fantasy.mp3", "stream")
    Music.forest:setLooping(true)

end
function love.update(dt)
    World:update(dt)
    Player:update(dt)
    Camera:setPosition(Player.x, 0)
    Map:update(dt)
    if Map:selfLevel(3) then
        Music.forest:play()
    end

end
function love.draw()
    s1 = love.graphics:getWidth()
    s2 = love.graphics:getHeight()
    love.graphics.draw(background, x, y, r, s1, s2)
	Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
    Camera:apply()
	Player:draw()
    Camera:clear()

end

function love.keypressed(key)
	Player:jump(key)
end

function beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end