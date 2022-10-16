io.stdout:setvbuf("no")
require "util"
Object = require("classic")
Tiled = require("tiled")
require "collisions"
require "environment"
require "categories"
require "boy"
require "bulb"


function love.load()
  ---@TODO
  --- 1. Add ladder behaviour
  --- 2. Add win condition
  --- 3. Create main menu UI before game
  --- 4. Create main menu UI before game
  --- 5. Sounds
  --- 6. Animations
  --- 7. Create levels system
  --- 8. Look in to setting inertia on bodies
  --- 9. Smashable bulbs
  --- -- YouTube: recursor tutorials https://www.youtube.com/watch?v=_NpDbNtJyDQ&list=PLZVNxI_lsRW2kXnJh2BMb6D82HCAoSTUB&index=3&ab_channel=recursor

  -- love.graphics.setDefaultFilter("nearest", "nearest")
  math.randomseed(os.time())
  ENVIRONMENT = Environment(love.graphics.getWidth(), love.graphics.getHeight(), true, false)
  love.physics.setMeter(ENVIRONMENT.meter)
  Map = Tiled("assets/map/1.lua", { "box2d" })
  World = love.physics.newWorld(0, 0)
  Map:box2d_init(World)
  Map.layers.solid.visible = false
  World:setCallbacks(BeginContact, EndContact)
  Background = love.graphics.newImage("assets/img/background.png")
  -- Choreboyz box (dispenses new boyz)
  require "box"
  require "ball"
  -- Table to hold AllBoyz
  AllBoyz = { }
  -- Table to hold AllBulbz
  AllBulbz = { }
end


function love.update(dt)
  ENVIRONMENT:update(dt, love.graphics.getWidth(), love.graphics.getHeight())
  World:update(dt)
  for _, each in ipairs(AllBoyz) do
    each:update(dt)
  end

  for _, each in ipairs(AllBulbz) do
    each:update(dt)
  end

  Box.update(dt)
  Ball.update(dt)
  Map:update(dt)
end

function love.draw()
  love.graphics.draw(Background)
  -- Walls:draw()
  Ball.draw()
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
    love.event.push("quit")
  end
end


