Box = { size = ENVIRONMENT.screen_width * 0.1, color = { 0.1, 0.3, 0.5 }, text = love.graphics.newText(love.graphics.newFont("assets/choreboyz.ttf", 20), "CHOREBOYZ") }
Box.update = function (dt)
  if love.keyboard.isDown("x") then Box.color = { 0.5, 0.3, 0.1 } else Box.color = { 0.1, 0.3, 0.5 } end
end