io.stdout:setvbuf("no")
Object = require("classic")
Collisions = require("collisions")
Tiled = require("tiled")
require "environment"
require "boundaries"
require "categories"
require "boy"


function love.load()
  math.randomseed(os.time())
  ENVIRONMENT = Environment(love.graphics.getWidth(), love.graphics.getHeight(), true, false)
  Map = Tiled("assets/map/1.lua", { "box2d" })
  World = love.physics.newWorld(0, 0)
  Map:box2d_init(World)
  Map.layers.solid.visible = false
  love.physics.setMeter(ENVIRONMENT.meter)
  World:setCallbacks(Collisions.beginContact, Collisions.endContact)
  Background = love.graphics.newImage("assets/map/1.jpg")
  -- World boundaries (ceiling, walls, and floor)
  Walls = Boundaries(ENVIRONMENT, World)
  -- Choreboyz box (dispenses new boyz)
  require "box"
  require "ball"
  -- Table to hold AllBoyz
  AllBoyz = { }
end


function love.update(dt)
  ENVIRONMENT:update(dt, love.graphics.getWidth(), love.graphics.getHeight())
  World:update(dt)
  for _, each in ipairs(AllBoyz) do
    each:update(dt, Walls, World)
  end

  Box.update(dt)
  Ball.update(dt)
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
      love.window.setMode(1280, 720, { resizable=true, borderless=false })
    end
  end

  if key == "escape" then
    love.event.push("quit")
  end
end


