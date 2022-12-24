Button = Object:extend()

Button.FontXmasSmall = love.graphics.newFont("assets/controls.ttf", 35, "normal", 50)
Button.FontXmasLarge = love.graphics.newFont("assets/controls.ttf", 45, "normal", 50)
Button.FontSmall = love.graphics.newFont("assets/controls.ttf", 85, "normal", 50)
Button.FontLarge = love.graphics.newFont("assets/controls.ttf", 100, "normal", 50)

function Button:new(text, fn, x, y, width, height, xmas)
  self.text = text
  self.fn = fn
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.state = {
    hot = false,
    wasClicked = false,
    isClicked = false,
    xmas = xmas
  }
end

function Button:update(hot, mouseDown)
  self.state.hot = hot
  self.state.wasClicked = self.state.isClicked
  self.state.isClicked = mouseDown

  if self.state.hot and self.state.wasClicked and not self.state.isClicked then
    self.fn()
  end

end

function Button:draw()

  love.graphics.setColor(Colors.yellow)
  local font = Button.FontSmall
  if self.state.xmas then font = Button.FontXmasSmall end
  local btnFillMode = "fill"
  local btnTextColor = Colors.brown_light

  if self.state.hot then
    btnFillMode = "line"
    btnTextColor = Colors.yellow
    font = Button.FontLarge
    if self.state.xmas then font = Button.FontXmasLarge end

    if self.state.isClicked then
      btnFillMode = "fill"
      love.graphics.setColor(Colors.green)
    end
  end
  love.graphics.rectangle(
    btnFillMode,
    self.x,
    self.y,
    self.width,
    self.height
  )

  local textWidth = font:getWidth(self.text)
  local textHeight = font:getHeight(self.text)
  love.graphics.setColor(btnTextColor)
  love.graphics.print(
    self.text,
    font,
    self.x + self.width / 2 - textWidth / 2,
    self.y + self.height / 2 - textHeight / 2
  )
end