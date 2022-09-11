if ENVIRONMENT.use_ball then

  Ball = NewObject("dynamic", "circle", World, ENVIRONMENT.screen_width / 2, ENVIRONMENT.screen_height / 2, 20)
  Ball.fixture:setRestitution(0.7) -- let the ball bounce
  Ball.fixture:setDensity(0.5)

  Ball.update = function(dt)
    if love.keyboard.isDown("right") then
      Ball.body:applyForce(400, 0)
    elseif love.keyboard.isDown("left") then
      Ball.body:applyForce(-400, 0)
    elseif love.keyboard.isDown("up") then
      Ball.body:applyForce(0, -400)
    elseif love.keyboard.isDown("down") then
      Ball.body:applyForce(0, 400)
    end
  end

  Ball.draw = function()
    love.graphics.setColor(0.76, 0.18, 0.05)
    love.graphics.circle("fill", Ball.body:getX(), Ball.body:getY(), Ball.shape:getRadius())
  end

else
  Ball = {}
  Ball.update = function () end
  Ball.draw = function () end

end