Gamestate = require "sti/plugins/hump.gamestate"

local menu = {} -- previously: Gamestate.new()
local game = require("map")


function menu:draw()
    love.graphics.print("Press Enter to continue", 10, 10)
end

function menu:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(game)
    end
end

function game:enter()
    Entities.clear()
    -- setup entities here
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end