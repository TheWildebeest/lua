io.stdout:setvbuf("no")

Object = require("classic")
Tiled = require("tiled")

require "menu"
require "util"
require "collisions"
require "environment"
require "categories"
require "boy"
require "bulb"
require "bulb_socket"
require "audio"

-- Global state
MENU = true
WIN = false

-- Global getters / setters
function START_GAME()
  MENU = false
  Sounds.music:pause()
end

function MAIN_MENU()
  MENU = true
  Sounds.music:play()
end

function WIN_GAME()
  WIN = true
end

function EXIT_GAME()
  love.event.push("quit")
end

function love.load()

  Menu:load()
  MAIN_MENU()

  ---
  --- DONE! 1. Add ladder behaviour
  --- DONE 2. Add win condition - nearly there, added bulb socket, just need to check for bulb collisions on bottom.
  --- Enough for CS50 completion ?
  --- @todo 3. Create main menu UI before game
  --- @todo 4. Create main menu UI before game
  --- @todo 5. Sounds
  --- @todo 6. Animations
  --- @todo 7. Create levels system
  --- @todo 8. Look in to setting inertia on bodies
  --- @todo 9. Smashable bulbs
  --- -- YouTube: recursor tutorials https://www.youtube.com/watch?v=_NpDbNtJyDQ&list=PLZVNxI_lsRW2kXnJh2BMb6D82HCAoSTUB&index=3&ab_channel=recursor
  love.graphics.setDefaultFilter("nearest", "nearest")
  math.randomseed(os.time())
  ENVIRONMENT = Environment(love.graphics.getWidth(), love.graphics.getHeight(), true, false)
  love.physics.setMeter(ENVIRONMENT.meter)
  Map = Tiled("assets/map/1.lua", { "box2d" })
  World = love.physics.newWorld(0, 0)
  Map:box2d_init(World)
  Map.layers.solid.visible = false
  World:setCallbacks(BeginContact, EndContact)
  Background = love.graphics.newImage("assets/img/background_7_lights_off.jpg")
  -- Choreboyz box (dispenses new boyz)
  Box = {
    size = ENVIRONMENT.screen_width * 0.1,
    color = { 0.1, 0.3, 0.5 },
    font = love.graphics.newFont("assets/box.ttf", 20)
  }
  Box['text'] = love.graphics.newText(Box.font, "CHOREBOYZ")
  Box.update = function (dt)
    if love.keyboard.isDown("x") then Box.color = { 0.1, 0.3, 0.5 } else Box.color = { 0.5, 0.3, 0.1 } end
  end

  -- Table to hold AllBoyz
  AllBoyz = { }
  -- Table to hold AllBulbz
  AllBulbz = { }

  SOCKET = Socket(ENVIRONMENT, World)
end


function love.update(dt)
  Menu:update()
  ENVIRONMENT:update(dt, love.graphics.getWidth(), love.graphics.getHeight())
  World:update(dt)
  for _, each in ipairs(AllBoyz) do
    each:update(dt)
  end

  for _, each in ipairs(AllBulbz) do
    each:update(dt)
  end

  Box.update(dt)
  if Ball then
    Ball.update(dt)
  end
  Map:update(dt)
  -- SOCKET:update(dt)
end

function love.draw()
  if WIN then
    local win_text = love.graphics.newText(love.graphics.newFont("assets/choreboyz.ttf", 100), "OMG YOU TOTALLY WON!!!")
    love.graphics.draw(Background)
    love.graphics.setColor(unpack({ 0.5, 0.3, 0.1 }))
    love.graphics.draw(win_text, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0.25, 1, 1, win_text:getWidth() / 2, win_text:getHeight() / 2)
  elseif MENU then Menu:draw()
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Background)
    -- Walls:draw()
    if Ball then
      Ball.draw()
    end
    Map:draw(0, 0, 1, 1)
    
    -- Draw the choreboyz
    for _, boy in ipairs(AllBoyz) do
      if boy ~= nil then
        boy:draw()
      end
    end

    -- Draw the bulbz
    for _, bulb in ipairs(AllBulbz) do
      if bulb ~= nil then
        bulb:draw()
      end
    end

    -- Draw choreboyz box and text
    love.graphics.setColor(unpack(Box.color))
    love.graphics.rectangle("fill", ENVIRONMENT.wall_thickness, ENVIRONMENT.wall_thickness, Box.size, Box.size)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Box.text, ENVIRONMENT.wall_thickness + (Box.size / 2), ENVIRONMENT.wall_thickness + (Box.size / 2), 0.25, 1, 1, Box.text:getWidth() / 2, Box.text:getHeight() / 2)

    -- Draw the bulb socket
    SOCKET:draw()
  end
end

function love.keypressed(key, _, isrepeat)
  for _, eachboy in ipairs(AllBoyz) do
    eachboy:keypressed(key, _, isrepeat)
  end

  if key == "x" then
    table.insert(AllBoyz, Boy(ENVIRONMENT, World))
  end

  if key == "f11" then
    ENVIRONMENT.fullscreen = not ENVIRONMENT.fullscreen
    if ENVIRONMENT.fullscreen then
      love.window.setFullscreen(true, "exclusive")
    else
      love.window.setMode(1920, 1088, { resizable=true, borderless=false })
    end
  end

  if key == "escape" then
    MAIN_MENU()
  end
end


