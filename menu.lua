-- -- Requirements --
require("buttons")
Colors = require("colors")

-- -- ------------ --
local windowWidth = love.graphics.getWidth()
local windowHeight = love.graphics.getHeight()
local TitleFont = love.graphics.newFont("assets/box.ttf", 102, "normal", 50)
local ControlsFont = love.graphics.newFont("assets/controls.ttf", 70, "normal", 50)
local HeroImage = love.graphics.newImage('assets/img/boy/1.png')

Menu = Object:extend()

Menu.SHOW_CONTROLS = false

function Menu:load()

  Title =  {}

  Title['text'] = "Maintenance\n      Man!"
  Title['font'] = TitleFont
  Title['width'] = Title.font:getWidth(Title.text) 
  Title['height'] = Title.font:getHeight(Title.text)
  Title['x'] = (windowWidth * 0.5)
  Title['y'] = (windowHeight * 0.25)

  
  Controls =  {}

  Controls['text_one'] = "MOVE\n\n\nJUMP\n\n\nSPAWN\n\n\nMENU\n\n\nThrow lightbulb"
  Controls['text_two'] = "\nwasd or arrow keys\n\n\nSpacebar\n\n\n X\n\n\nEsc\n\n\nE"
  Controls['font'] = ControlsFont
  Controls['width_one'] = Controls.font:getWidth(Controls.text_one) 
  Controls['height_one'] = Controls.font:getHeight(Controls.text_one)
  Controls['width_two'] = Controls.font:getWidth(Controls.text_two) 
  Controls['height_two'] = Controls.font:getHeight(Controls.text_two)
  Controls['x'] = (windowWidth * 0.5)
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
      "Controls",
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
    )
  }
end

function Menu:update(dt)
  if not MENU then return end
  local mouseX, mouseY = love.mouse.getPosition()
  local mouseDown = love.mouse.isDown(1)
  for _, button in ipairs(Buttons) do
    local hotX = mouseX > button.x and mouseX < button.x + button.width
    local hotY = mouseY > button.y and mouseY < button.y + button.height
    local isHot = hotX and hotY
    button:update(isHot, mouseDown)
  end
end

function Menu:draw()
  if not MENU then return end

  -- Draw background
  love.graphics.setColor(Colors.brown)
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
    love.graphics.setColor(Colors.yellow)
    love.graphics.print(
      Controls.text_one,
      Controls.font,
      Controls.x,
      Controls.y,
      0,
      1,
      1,
      (Controls.width_two / 2)
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
      (Controls.width_two / 2)
    )
  end

  if not Menu.SHOW_CONTROLS then
    love.graphics.setColor(Colors.green)
    love.graphics.print(
      Title.text,
      Title.font,
      Title.x,
      Title.y,
      0,
      1,
      1,
      (Title.width / 2)
    )
  end


    -- Draw buttons
  if not Menu.SHOW_CONTROLS then
    for i, button in ipairs(Buttons) do
      button:draw()
    end
  end


end

function Menu:toggleControls()
  Menu.SHOW_CONTROLS = not Menu.SHOW_CONTROLS
end
