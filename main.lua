--- @todo 1. SUBMIT
--- @todo 2. Make box transparent when touching Man
--- @todo 2. Finish animations (climbing state, throwing state)
--- @todo 3. Look in to setting inertia on bodies
--- @todo 4. Smashable bulbs
--- @todo 5. BUG - boy.lua:357: bad argument #2 to 'draw' (Quad expected, got nil)
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
require "player"
require "bulb"
require "bulb_socket"
require "audio"
require "global_functions"

-- Global state
MENU = true
WIN = false
XMAS = false

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
  Background = {}
  Background.DEFAULT = love.graphics.newImage("assets/img/background/background-lights-off.png")
  Background.WIN = love.graphics.newImage("assets/img/background/background-lights-on.png")

  -- Choreboyz box (dispenses new boyz)
  Box = {}
  Box.image = love.graphics.newImage("assets/img/crate.png")
  Box.size = ENVIRONMENT.screen_width * 0.1
  Box.scale = Box.size / Box.image:getWidth()
  Box.color = Colors.box_inactive
  Box.timer = 0

  Box.update = function (dt)
    if Box.timer - dt <=0 then Box.timer = 0 else Box.timer = Box.timer - dt end
    if Box.timer == 0 then Box.color = Colors.box_inactive end
    if Box.timer > 0 then Box.color = Colors.box_active end
  end

  -- Table to hold AllBoyz
  AllBoyz = { }
  -- Table to hold AllBulbz
  AllBulbz = { }

  SOCKET = Socket(ENVIRONMENT, World)
  WIN_FONT = love.graphics.newFont("assets/controls.ttf", 50)
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
  SOCKET:update(dt)
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  if MENU then Menu:draw()
  else
    -- Draw background
    local background = Background.DEFAULT
    if WIN then background = Background.WIN end
    love.graphics.draw(background)
    -- end

    -- Draw map
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
    local x = ENVIRONMENT.screen_width * 0.05
    local y = ENVIRONMENT.screen_width * 0.05
    love.graphics.draw(Box.image, x, y, 0, Box.scale, Box.scale, Box.size * 2, Box.size * 2, 0, 0)
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.draw(Box.text, ENVIRONMENT.wall_thickness + (Box.size / 2), ENVIRONMENT.wall_thickness + (Box.size / 2), 0.25, 1, 1, Box.text:getWidth() / 2, Box.text:getHeight() / 2)

    -- Draw the bulb socket
    SOCKET:draw()

    -- Draw WIN text
    if WIN then
      love.graphics.setColor(unpack(Colors.black_alpha))
      love.graphics.rectangle(
        "fill",
        ENVIRONMENT.screen_width * 0.665,
        ENVIRONMENT.screen_height * 0.025,
        ENVIRONMENT.screen_width * 0.325,
        WIN_FONT:getHeight() * 6
      )
      love.graphics.setColor(unpack(Colors.green))
      love.graphics.printf(
        "Congratulations!",
        WIN_FONT,
        ENVIRONMENT.screen_width * 0.675,
        ENVIRONMENT.screen_height * 0.05,
        ENVIRONMENT.screen_width * 0.3,
        "left",
        0,
        1,
        1
      )
      love.graphics.setColor(unpack(Colors.yellow))
      love.graphics.printf(
        "\nYou completed the task using:",
        WIN_FONT,
        ENVIRONMENT.screen_width * 0.675,
        ENVIRONMENT.screen_height * 0.05,
        ENVIRONMENT.screen_width * 0.3,
        "left",
        0,
        1,
        1
      )
      love.graphics.setColor(unpack(Colors.brown_light))
      love.graphics.printf(
        "\n\n\n      Maintenance Men\n      bulbs",
        WIN_FONT,
        ENVIRONMENT.screen_width * 0.675,
        ENVIRONMENT.screen_height * 0.05,
        ENVIRONMENT.screen_width * 0.3,
        "left",
        0,
        1,
        1
      )
      love.graphics.setColor(unpack(Colors.green))
      love.graphics.printf(
        "\n\n\n"..tostring(#AllBoyz).."\n"..tostring(#AllBulbz),
        WIN_FONT,
        ENVIRONMENT.screen_width * 0.675,
        ENVIRONMENT.screen_height * 0.05,
        ENVIRONMENT.screen_width * 0.3,
        "left",
        0,
        1,
        1
      )
      -- love.graphics.draw(win_text, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, 1, 1, win_text:getWidth() / 2, win_text:getHeight() / 2)
    end

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
    local player_alive = false
    for k, v in pairs(AllBoyz) do
      if v.fixture:getCategory() == Categories.LIVEBOY then
        player_alive = true
        break
      end
    end
    if not player_alive then
      local new_boy = Boy(ENVIRONMENT, World)
      table.insert(AllBoyz, new_boy)
      Box.timer = 0.3
    end
  end

  if key == "f11" then
    ENVIRONMENT.fullscreen = not ENVIRONMENT.fullscreen
    if ENVIRONMENT.fullscreen then
      love.window.setFullscreen(true, "exclusive")
    else
      love.window.setMode(1920, 1088, { resizable=true, borderless=false })
    end
  end

  -- if key == "w" then
  --   WIN_GAME()
  -- end

  if key == "escape" then
    MAIN_MENU()
  end
end


