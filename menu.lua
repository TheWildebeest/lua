-- -- Requirements --
require("buttons")
Colors = require("colors")

-- -- ------------ --
local windowWidth = love.graphics.getWidth()
local windowHeight = love.graphics.getHeight()
local TitleFont = love.graphics.newFont("assets/box.ttf", 102, "normal", 50)
local HeroImage = love.graphics.newImage('assets/img/boy/1.png')

Menu = Object:extend()

function Menu:load()

  Title =  {}

  Title['text'] = "CHOREBOYZ!"
  Title['font'] = TitleFont
  Title['width'] = Title.font:getWidth(Title.text) 
  Title['height'] = Title.font:getHeight(Title.text)
  Title['x'] = (windowWidth * 0.5)
  Title['y'] = (windowHeight * 0.4)

  local btnWidth = windowWidth * 0.33
  Buttons = {
    Button(
      "Start game",
      START_GAME,
      windowWidth * 0.5 - (btnWidth * 0.5),
      windowHeight * 0.7,
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
  print(Title.x)

  -- Draw main graphic
  love.graphics.setColor(1,1,1, 0.3)
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


  -- Draw title
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

  -- Draw buttons
  for i, button in ipairs(Buttons) do
    button:draw()
  end

end