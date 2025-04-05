function love.conf(t)
    t.title = "Platformer Test"
    t.author = "NyanPanDev"
    t.version = "11.3"
    t.window.width = 640
    t.window.height = 480
    t.audio.mic = false
    t.audio.mixwithsystem = true
    t.window.vsync = 0
    t.console = false
    t.release = false
    t.window.fullscreen = false
    t.window.vsync = true
    t.window.fsaa = 0
    t.modules.audio = true
    t.modules.keyboard = true
    t.modules.joystick = true
    t.modules.event = true
    t.modules.image = true
    t.modules.timer = true
    t.modules.graphics = true
    t.modules.sound = true
    t.modules.physics = true
end