-- -- Requirements --
require("buttons")
Colors = require("colors")

-- -- ------------ --
local windowWidth = love.graphics.getWidth()
local windowHeight = love.graphics.getHeight()
local TitleFont = love.graphics.newFont("assets/maintenance-man.ttf", 145, "normal", 10)
local ControlsFont = love.graphics.newFont("assets/controls.ttf", 50, "normal", 50)
local InstructionsFont = love.graphics.newFont("assets/instructions.ttf", 50, "normal", 50)
local HeroImage = love.graphics.newImage('assets/img/player/hero.png')

Menu = Object:extend()

Menu.SHOW_CONTROLS = false

function Menu:load()

  Title =  {}

  Title['text_one'] = "Maintenance"
  Title['text_two'] = "MAN"
  Title['font'] = TitleFont
  Title['width_one'] = Title.font:getWidth(Title.text_one)
  Title['width_two'] = Title.font:getWidth(Title.text_two)
  Title['height_one'] = Title.font:getHeight()
  Title['height_two'] = Title.font:getHeight()
  Title['x'] = (windowWidth * 0.5)
  Title['y'] = (windowHeight * 0.1)

  Instructions = {}
  Instructions['text_one'] = "INSTRUCTIONS"
  Instructions['text_two'] = "\n\nThe ceiling light fixture is missing a bulb!\n\nYou will need to call the maintenance man to put a new bulb in.\n\nHe will bring a ladder and lots of bulbs, and you can hire as many maintenance men as you need..."
  Instructions['font'] = InstructionsFont
  Instructions['width'] = Instructions.font:getWidth(Instructions.text_two)
  Instructions['x'] = (windowWidth * 0.34)
  Instructions['y'] = (windowHeight * 0.05)

  
  Controls =  {}

  Controls['text_one'] = "CONTROLS\n\nMove\n\n\nJump\n\n\nHire a maintenance man\n\n\nHold a ladder\n\n\nThrow lightbulb\n\n\nMenu"
  Controls['text_two'] = "\n\n\nwasd or arrow keys\n\n\nSpacebar\n\n\nX\n\n\nL\n\n\nE\n\n\nEsc"
  Controls['font'] = ControlsFont
  Controls['width'] = Controls.font:getWidth(Controls.text_two)
  Controls['x'] = (windowWidth * 0.8)
  Controls['y'] = (windowHeight * 0.05)

  local btnWidth = windowWidth * 0.33
  Buttons = {
    Button(
      "Start game",
      START_GAME,
      windowWidth * 0.5 - (btnWidth * 0.5),
      windowHeight * 0.6,
      btnWidth,
      windowHeight * 0.1
    ),
    Button(
      "How to play",
      Menu.toggleControls,
      windowWidth * 0.5 - (btnWidth * 0.5),
      windowHeight * 0.725,
      btnWidth,
      windowHeight * 0.1
    ),
    Button(
      "Quit",
      EXIT_GAME,
      windowWidth * 0.5 - (btnWidth * 0.5),
      windowHeight * 0.85,
      btnWidth,
      windowHeight * 0.1
    ),
    Button(
    "XMAS",
    Menu.toggleXmas,
    windowWidth - (btnWidth * 0.15) - (windowHeight * 0.05),
    windowHeight * 0.05,
    btnWidth * 0.20,
    btnWidth * 0.05,
    true
  )
  }
  BackButton = Button(
    "Back",
    Menu.toggleControls,
    windowWidth * 0.5 - (btnWidth * 0.5),
    windowHeight * 0.85,
    btnWidth,
    windowHeight * 0.1
  )
end

function Menu:update(dt)
  if not MENU then return end
  local mouseX, mouseY = love.mouse.getPosition()
  local mouseDown = love.mouse.isDown(1)
  if not Menu.SHOW_CONTROLS then
    for _, button in ipairs(Buttons) do
      local hotX = mouseX > button.x and mouseX < button.x + button.width
      local hotY = mouseY > button.y and mouseY < button.y + button.height
      local isHot = hotX and hotY
      button:update(isHot, mouseDown)
    end
  end
  if Menu.SHOW_CONTROLS then
    local hotX = mouseX > BackButton.x and mouseX < BackButton.x + BackButton.width
    local hotY = mouseY > BackButton.y and mouseY < BackButton.y + BackButton.height
    local isHot = hotX and hotY
    BackButton:update(isHot, mouseDown)
  end
end

function Menu:draw()
  if not MENU then return end

  -- Draw background
  love.graphics.setColor(Colors.brown_light)
  love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
  -- print(Title.x)

  -- Draw main graphic
  love.graphics.setColor(1,1,1)
  love.graphics.draw(
    HeroImage,
    windowWidth * 0.175,
    windowHeight * 0.5,
    0,
    1.2,
    1.2,
    HeroImage:getWidth() * 1.2 * 0.5,
    HeroImage:getHeight() * 1.2 * 0.4

)


  -- Draw text
  if Menu.SHOW_CONTROLS then
    love.graphics.setColor(Colors.brown_dark)
    love.graphics.print(
      Instructions.text_one,
      Instructions.font,
      Instructions.x,
      Instructions.y,
      0,
      1,
      1
    )
    love.graphics.setColor(Colors.black)
    love.graphics.printf(
      Instructions.text_two,
      Instructions.font,
      Instructions.x,
      Instructions.y,
      windowWidth * 0.3,
      "left",
      0,
      1,
      1
    )
    love.graphics.setColor(Colors.brown_dark)
    love.graphics.print(
      Controls.text_one,
      Controls.font,
      Controls.x,
      Controls.y,
      0,
      1,
      1,
      (Controls.width / 2)
    )
    love.graphics.setColor(Colors.green)
    love.graphics.print(
      Controls.text_two,
      Controls.font,
      Controls.x,
      Controls.y,
      0,
      1,
      1,
      (Controls.width / 2)
    )
  end

  if not Menu.SHOW_CONTROLS then
    love.graphics.setColor(Colors.brown_dark)
    love.graphics.print(
      Title.text_one,
      Title.font,
      Title.x,
      Title.y,
      0,
      1,
      1,
      (Title.width_one / 2)
    )
    love.graphics.setColor(Colors.green)
    love.graphics.print(
      Title.text_one,
      Title.font,
      Title.x  + windowWidth * 0.006,
      Title.y + windowHeight * 0.006,
      0,
      1,
      1,
      (Title.width_one / 2)
    )
    love.graphics.setColor(Colors.brown_dark)
    love.graphics.print(
      Title.text_two,
      Title.font,
      Title.x,
      Title.y + Title.height_one,
      0,
      1,
      1,
      (Title.width_two / 2)
    )
    love.graphics.setColor(Colors.green)
    love.graphics.print(
      Title.text_two,
      Title.font,
      Title.x  + windowWidth * 0.006,
      Title.y + Title.height_one + windowHeight * 0.006,
      0,
      1,
      1,
      (Title.width_two / 2)
    )
  end


    -- Draw buttons
  if Menu.SHOW_CONTROLS then
    BackButton:draw()    
  end
  if not Menu.SHOW_CONTROLS then
    for i, button in ipairs(Buttons) do
      button:draw()
    end
  end


end

function Menu:toggleControls()
  Menu.SHOW_CONTROLS = not Menu.SHOW_CONTROLS
end

function Menu:toggleXmas()
  XMAS = not XMAS
  local infix = ""
  if XMAS then infix = 'xmas-' end
  HeroImage = love.graphics.newImage("assets/img/player/"..infix.."hero.png")
  Boy.images.idle_left = love.graphics.newImage("assets/img/player/"..infix.."idle-left.png")
  Boy.images.idle_right = love.graphics.newImage("assets/img/player/"..infix.."idle-right.png")
  Boy.images.ladder_left = love.graphics.newImage("assets/img/player/"..infix.."ladder-left.png")
  Boy.images.ladder_right = love.graphics.newImage("assets/img/player/"..infix.."ladder-right.png")
  Boy.images.walking_left = love.graphics.newImage("assets/img/player/"..infix.."walking-left.png")
  Boy.images.walking_right = love.graphics.newImage("assets/img/player/"..infix.."walking-right.png")
  Background.DEFAULT = love.graphics.newImage("assets/img/background/"..infix.."background-lights-off.png")
  Background.WIN = love.graphics.newImage("assets/img/background/"..infix.."background-lights-on.png")
  Box.image = love.graphics.newImage("assets/img/"..infix.."crate.png")
  Socket.image = love.graphics.newImage("assets/img/"..infix.."socket.png")
  Bulb.on = love.graphics.newImage("assets/img/bulb/"..infix.."on.png")
  Bulb.off = love.graphics.newImage("assets/img/bulb/"..infix.."off.png")

  local play_menu_music = false
  if Sounds.menu_music:isPlaying() then play_menu_music = true Sounds.menu_music:stop() end
  local menu_music = Sound(SoundTypes.MUSIC, "assets/audio/"..infix.."menu_music.wav")
  menu_music:setLooping(true)
  Sounds.menu_music = menu_music
  if play_menu_music then Sounds.menu_music:play() end


  local play_level_1_music = false
  if Sounds.level_1_music:isPlaying() then play_level_1_music = true Sounds.level_1_music:stop() end
  local level_1_music = Sound(SoundTypes.MUSIC, "assets/audio/"..infix.."level_1_music.wav")
  level_1_music:setLooping(true)
  Sounds.level_1_music = level_1_music
  if play_level_1_music then Sounds.level_1_music:play() end

  local play_win_music = false
  if Sounds.win_music:isPlaying() then play_win_music = true Sounds.win_music:stop() end
  local win_music = Sound(SoundTypes.MUSIC, "assets/audio/"..infix.."win_music.wav")
  win_music:setLooping(true)
  Sounds.win_music = win_music
  if play_win_music then Sounds.win_music:play() end

end
