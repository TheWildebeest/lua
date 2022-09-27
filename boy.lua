Boy = Object:extend()

-- Static properties/methods

Boy.width = love.physics:getMeter() * 4
Boy.height = love.physics:getMeter() * 7

-- `Static`
Boy.initBody = function (environment, world)
  return love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic")
end

-- `Static`
Boy.initShape = function ()
  return love.physics.newRectangleShape(Boy.width, Boy.height)
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
  self.image = love.graphics.newImage("assets/img/boy/1.png")
end

function Boy:update(dt)
  local category = self.fixture:getCategory()

  -- Only apply movement to the player sprite
  if category == Categories.LIVEBOY then
    self:move(dt)
  end

  -- Apply gravity to all airborne sprites
  if not self:isOnSurface() then
    self:applyGravity(dt)
  elseif self.y_velocity > 0 then
    self.y_velocity = 0
  end

  -- Apply friction to all sprites
  self:applyFriction(dt)

  self.body:setLinearVelocity(self.x_velocity, self.y_velocity)

  
  if category == Categories.DEADBOY then
    if (self.y_velocity == 0) and (self.x_velocity == 0) then
      self.body:setType("static")
    end
  end
end

function Boy:move(dt)

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
  self.y_velocity = self.y_velocity + self.gravity * dt
end


function Boy:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
  x, y = self.body:getPosition()
  love.graphics.setColor({ 1, 1, 1 })
  love.graphics.draw(self.image, x, y, 0, 0.075, 0.075, self.image:getWidth() / 2, self.image:getHeight() / 2, 0, 0)
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
      print("Y velocity: "..self.y_velocity)
      if not isrepeat then
        if self:isOnSurface() then
          self.y_velocity = -self.jump_strength
        end
      end
    end

  end
end

function Boy:init(environment, world)

  self.body = Boy.initBody(environment, world)
  self.shape = Boy.initShape()
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.collisions = { }

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

function Boy:beginContact(a, b, contact)
  print("beginContact")
  local normal_x, normal_y = contact:getNormal()
  local coll = { fixture_a = a, fixture_b = b, normal_x = normal_x, normal_y = normal_y }
  if IsOnTop(a, b, self.fixture, normal_y) then self:stopVerticalMotion() end
  table.insert(self.collisions, coll)
end

function Boy:endContact(a, b, contact)
  print("endContact")

  local index = nil

  for i, collision_data in ipairs(self.collisions) do
    if a == collision_data.fixture_a and b == collision_data.fixture_b then
      index = i
    elseif a == collision_data.fixture_b and b == collision_data.fixture_a then
      index = i
    end
  end

  if index then
    table.remove(self.collisions, index)
  end

end

function Boy:stopVerticalMotion()
  self.y_velocity = 0
end

function Boy:isOnSurface()

  local on_top = false

  for _, collision in ipairs(self.collisions) do
    if IsOnTop(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
      on_top = true
    end
  end
  
  return on_top
  
end