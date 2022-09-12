Boy = Object:extend()

-- Static properties/methods

Boy.width = love.physics:getMeter() * 1.5
Boy.height = love.physics:getMeter() * 3

-- `Static`
Boy.initBody = function (environment, world)
  return love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic")
end

-- `Static`
Boy.initShape = function ()
  return love.physics.newRectangleShape(0, 0, Boy.width, Boy.height)
end

-- `Static`
Boy.default_base_color = { 0.20, 0.20, 0.20 }

-- `Static`
Boy.default_highlight_color = { 0.5, 0.3, 0.1 }


function Boy:new(environment, world)
  self:init(environment, world)
  self.base_color = { math.random(), math.random(), math.random() }
  -- Boy.default_base_color
  self.highlight_color = Boy.default_highlight_color
  self.color = self.base_color
end

function Boy:update(dt)
  local category = self.fixture:getCategory()
  self:syncPhysics()
  self:move(dt, category)
  self:applyGravity(dt)
end

function Boy:syncPhysics()
  self.x_position, self.y_position = self.body:getPosition()
  self.body:setLinearVelocity(self.x_velocity, self.y_velocity)
end

function Boy:move(dt, category)
  if category == Categories.DEADBOY then
    self:applyFriction(dt)
  end
  if category == Categories.LIVEBOY then
    -- Move right
    if love.keyboard.isDown("d", "right") then

      if self.x_velocity < self.max_speed then
        if self.x_velocity + self.acceleration * dt < self.max_speed then
          self.x_velocity = self.x_velocity + self.acceleration * dt
        else
          self.x_velocity = self.max_speed
        end
      end

    -- Move left
    elseif love.keyboard.isDown("a", "left") then
      if self.x_velocity > -self.max_speed then
        if self.x_velocity - self.acceleration * dt > -self.max_speed then
          self.x_velocity = self.x_velocity - self.acceleration * dt
        else
          self.x_velocity = -self.max_speed
        end
      end
    else
      -- self.body:setLinearVelocity(0, y)
      self:applyFriction(dt)
    end
  end

end

function Boy:applyFriction(dt)
  if self.x_velocity > 0 then
    if self.x_velocity - self.friction * dt > 0 then
      self.x_velocity = self.x_velocity - self.friction * dt
    else
      self.x_velocity = 0
    end
  elseif self.x_velocity < 0 then
    if self.x_velocity + self.friction * dt < 0 then
      self.x_velocity = self.x_velocity + self.friction * dt
    else
      self.x_velocity = 0
    end
  end
end

function Boy:applyGravity(dt)
  if not self.is_on_ground then
    self.y_velocity = self.y_velocity + self.gravity * dt
  end
end


function Boy:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

function Boy:keypressed(key, _, isrepeat)
  local category= self.fixture:getCategory()
  if category == Categories.DEADBOY then return end
  if category == Categories.LIVEBOY then

    if key == "x" then
      if not isrepeat then
        self.fixture:setCategory(Categories.DEADBOY)
      end
    end

    if key == "space" then
      if not isrepeat then
        if self.is_on_ground then
          self.y_velocity = -self.jump_strength
          self.is_on_ground = false
        end
      end
    end

  end
end

function Boy:init(environment, world)

  self.body = Boy.initBody(environment, world)
  self.shape = Boy.initShape()
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.x_position = environment.wall_thickness + environment.screen_width * 0.05
  self.y_position = environment.wall_thickness + environment.screen_width * 0.075
  self.is_on_ground = false
  self.current_collision = nil

  self.x_velocity = 0
  self.y_velocity = 100
  self.gravity = 1500
  self.max_speed = 200
  self.jump_strength = 900
  self.acceleration = 4000
  self.friction = 3500

  self.body:setFixedRotation(true)
  self.fixture:setCategory(Categories.LIVEBOY)

end

function Boy:reset(environment, world)
  self.fixture:destroy()
  self.body:destroy()
  self:init(environment, world)
end

function Boy:beginContact(a, b, collision)
  if self.is_on_ground then return end
  local _, normal_y
  _, normal_y = collision:getNormal()
  if a == self.fixture then
    if normal_y > 0 then
      self:land(collision)
    elseif normal_y < 0 then
      self.y_velocity = 0
    end
  elseif b == self.fixture then
    if normal_y < 0 then
      self:land(collision)
    elseif normal_y > 0 then
      self.y_velocity = 0
    end
  end
end

function Boy:endContact(a, b, collision)
  if (a == self.fixture or b == self.fixture) and self.is_on_ground then
    if self.current_collision == collision then
      self.is_on_ground = false
    end
  end

  self.is_on_ground = false
end

function Boy:land(collision)
  self.current_collision = collision
  self.y_velocity = 0
  self.is_on_ground = true
end