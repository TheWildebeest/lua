--- @todo 1. Finish animations (climbing state, throwing state)
--- @todo 2. Add instructions on menu screen
--- @todo 3. Add win screen (lighten room, leave lightbulb where it is and turn on)
--- @todo 4. SUBMIT
--- @todo 5. Look in to setting inertia on bodies
--- @todo 6. Smashable bulbs
--- -- YouTube: recursor tutorials https://www.youtube.com/watch?v=_NpDbNtJyDQ&list=PLZVNxI_lsRW2kXnJh2BMb6D82HCAoSTUB&index=3&ab_channel=recursor

-- Required for realtime debugging. Delete before deploying
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
require "global_functions"

-- Global state
MENU = true
WIN = false

-- Global getters / setters
function START_GAME()
  MENU = false
  Sounds.menu_music:pause()
  Sounds.level_1_music:play()
end

function love.load()
  -- Seed pseudo-random number generator
  math.randomseed(os.time())
  
  -- Set up environment variables
  ENVIRONMENT = Environment(love.graphics.getWidth(), love.graphics.getHeight(), true, false)

  -- Load audio files
  Sounds:load()
  Menu:load()

  -- Allow repeat key inputs
  love.keyboard.setKeyRepeat(true)

  -- Set up world
  love.physics.setMeter(ENVIRONMENT.meter)
  Map = Tiled("assets/map/1.lua", { "box2d" })
  World = love.physics.newWorld(0, ENVIRONMENT.GRAVITY)
  Map:box2d_init(World)
  Map.layers.solid.visible = false
  World:setCallbacks(BeginContact, EndContact, PreSolve)
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
  MAIN_MENU()
end


function love.update(dt)
  ENVIRONMENT:update(dt, love.graphics.getWidth(), love.graphics.getHeight())
  if MENU then
    Menu:update()
  end

  if not MENU then
    World:update(dt)
    -- Boy.updateAll(AllBoyz, dt)
    Boy.updateAll(AllBoyz, dt)
    -- Bulb.updateAll(AllBulbz, dt)
    Box.update(dt)
    Map:update(dt)
  end
  -- SOCKET:update(dt)
end

function love.draw()
  if MENU then Menu:draw()
  elseif WIN then
    local win_text = love.graphics.newText(love.graphics.newFont("assets/choreboyz.ttf", 100), "OMG YOU TOTALLY WON!!!")
    love.graphics.draw(Background)
    love.graphics.setColor(unpack({ 0.5, 0.3, 0.1 }))
    love.graphics.draw(win_text, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0.25, 1, 1, win_text:getWidth() / 2, win_text:getHeight() / 2)
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Background)
    -- Walls:draw()
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

  --   -- Draw collisions
  --   love.graphics.setColor(1,0,0)
  --   for _, body in pairs(World:getBodies()) do
  --     for _, fixture in pairs(body:getFixtures()) do
  --         local shape = fixture:getShape()
  
  --         if shape:typeOf("CircleShape") then
  --             local cx, cy = body:getWorldPoints(shape:getPoint())
  --             love.graphics.circle("fill", cx, cy, shape:getRadius())
  --         elseif shape:typeOf("PolygonShape") then
  --             love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
  --         else
  --             love.graphics.line(body:getWorldPoints(shape:getPoints()))
  --         end
  --     end
  -- end
  end
end

function love.keypressed(key, _, isrepeat)
  for _, eachboy in ipairs(AllBoyz) do
    eachboy:keypressed(key, _, isrepeat)
  end

  if key == "x" and not isrepeat then
    local new_boy = Boy(ENVIRONMENT, World)
    table.insert(AllBoyz, new_boy)
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


