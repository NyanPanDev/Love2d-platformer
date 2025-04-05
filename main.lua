gamestate = require("sti/plugins/hump.gamestate")
vector = require("sti/plugins/hump.vector")
tween = require("sti/plugins/tween")
suit = require("sti/plugins/suit")
love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Camera = require("camera")
local Map = require("map")
local Music = {}
local menu = {}
local game = {}



function menu:init()
	-- body
end

function menu:draw()
	love.graphics.setBackgroundColor(0, 0, 0)
	suit.draw()
end

function menu:update(dt)
	if suit.Button("Play", 140, 40, 300, 30).hit then
		gamestate.switch(game)
	end

	if suit.Button("Quit", 140, 90, 300, 30).hit then
		love.event.quit()
	end
end


function menu:keypressed(key, unicode)
    -- Switches to menu gamestate
	-- if key == 'm' then
	-- 	gamestate.switch(game)
	-- end
end
   
function game:enter()
    Map:load()
    background = love.graphics.newImage("resources/world/Background.png")
    Player:load()
    Music.forest = love.audio.newSource("resources/audio/Woodland_Fantasy.mp3", "stream")
    Music.forest:setLooping(true)
end

function game:update(dt)
	World:update(dt)
    Player:update(dt)
    Camera:setPosition(Player.x, 0)
    Map:update(dt)
    if Map:selfLevel(3) then
        Music.forest:play()
    end
end

function game:keypressed(key, unicode)
    -- Switches to menu gamestate
        if key == 'r' then
            gamestate.switch(menu)
            Music.forest:stop()
        end

        if key == "w" or key == "up" then
            Player:jump(key)
        elseif key == "z" or key == "j" then
            Player:attack(key)
        end
    end

function game:draw()
    s1 = love.graphics:getWidth()
    s2 = love.graphics:getHeight()
    love.graphics.draw(background, x, y, r, s1, s2)
	Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
    Camera:apply()
	Player:draw()
    Camera:clear()
end


function love.load()
    gamestate.registerEvents()
    gamestate.switch(menu)
end

function love.keyreleased(key)
    if key == "a" or key == "left" or key == "d" or key == "right" then
        Player:stopAnimation(true)
    end
end

function beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end