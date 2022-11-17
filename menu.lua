Menu = Object:extend()

local function newButton(text, fn)
  return {
    text = text,
    fn = fn
  }
end

function Menu:load()
  local startGame = newButton("Start game", function() print("starting game...") end)
  local exitGame = newButton("Quit", function() print("qutting...") end)

  Buttons = {}

  ButtonFontSmall = love.graphics.newFont("assets/menu.ttf", 75, "normal", 50)
  ButtonFontLarge = love.graphics.newFont("assets/menu.ttf", 90, "normal", 50)

  table.insert(Buttons, startGame)
  table.insert(Buttons, exitGame)

  Colors = {
    brown =   {0.57, 0.55, 0.44},
    yellow = {0.76, 0.77, 0.55}
  }
end

function Menu:update(dt)
  if not MENU then return end
end

function Menu:draw()
  if not MENU then return end
  local windowWidth = love.graphics.getWidth()
  local windowHeight = love.graphics.getHeight()
  local buttonWidth = windowWidth / 3
  local buttonHeight = windowHeight / 10
  local marginY = windowHeight / 20
  local totalHeight = (buttonHeight * #Buttons) + (marginY * (#Buttons - 1))

  -- Draw background
  love.graphics.setColor(Colors.brown)
  love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

  -- Draw buttons
  for i, button in ipairs(Buttons) do
    local buttonX = windowWidth / 2 - buttonWidth / 2
    local buttonY = windowHeight / 2 - totalHeight / 2 + ((i - 1) * (buttonHeight + marginY))
    local mouseX, mouseY = love.mouse.getPosition()
    local hotX = mouseX > buttonX and mouseX < buttonX + buttonWidth
    local hotY = mouseY > buttonY and mouseY < buttonY + buttonHeight
    local hot = hotX and hotY


    local font = ButtonFontSmall
    local btnFillMode = "fill"
    local btnTextColor = Colors.brown

    if hot then
      btnFillMode = "line"
      btnTextColor = Colors.yellow
      font = ButtonFontLarge
    end
    love.graphics.setColor(Colors.yellow)
    love.graphics.rectangle(
      btnFillMode,
      buttonX,
      buttonY,
      buttonWidth,
      buttonHeight
    )

    local textWidth = font:getWidth(button.text)
    local textHeight = font:getHeight(button.text)
    love.graphics.setColor(btnTextColor)
    love.graphics.print(
      button.text,
      font,
      buttonX + buttonWidth / 2 - textWidth / 2,
      buttonY + buttonHeight / 2 - textHeight / 2
    )
  end

end