Player = Object:extend()

function Player:new(screen_width, screen_height)
  self.image = love.graphics.newImage("assets/sprite_player.png")
  self.x_position = screen_width * 0.2
  self.y_position = screen_height * 0.2
  self.rotation = 0
  self.scale_x = 0.25
  self.scale_y = 0.25
  self.x_origin = 175
  self.y_origin = 175
  self.speed = 300
  self.midpoint = 43.75

end

function Player:update(dt, screen_width, screen_height)
  -- Get movement from key presses
  if love.keyboard.isDown("up") then
    self.y_position = self.y_position - (dt * self.speed)
  end
  if love.keyboard.isDown("down") then
    self.y_position = self.y_position + (dt * self.speed)
  end
  if love.keyboard.isDown("left") then
    self.x_position = self.x_position - (dt * self.speed)
  end
  if love.keyboard.isDown("right") then
    self.x_position = self.x_position + (dt * self.speed)
  end
  if love.keyboard.isDown("space") then
    self.clone = true
  else
    self.clone = false
  end
  
  -- Check bounds
  local min_x = self.midpoint
  local max_x = screen_width - self.midpoint
  local min_y = self.midpoint
  local max_y = screen_height - self.midpoint
  if self.x_position > max_x then self.x_position = max_x end
  if self.x_position < min_x then self.x_position = min_x end
  if self.y_position > max_y then self.y_position = max_y end
  if self.y_position < min_y then self.y_position = min_y end

  --end
  --if self.x_position > (window_width - self_midpoint) then
  --  self.x_position = window_width - self_midpoint
  --end
end

function Player:draw()
  love.graphics.draw(self.image, self.x_position, self.y_position, self.rotation, self.scale_x, self.scale_y, self.x_origin, self.y_origin)
end

