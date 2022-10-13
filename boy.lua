Boy = Object:extend()

-- Static properties/methods

Boy.width = love.physics:getMeter() * 2.5
Boy.height = love.physics:getMeter() * 5

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

function Boy:new(environment, world)
  self:init(environment, world)
  self.base_color = { math.random(), math.random(), math.random() }
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
  end

  if self:isOnSurface() and self.y_velocity > 0 then
    self:stopVerticalMotion()
  end

  -- Apply friction to all sprites
  self:applyFriction(dt)
  self.body:setLinearVelocity(self.x_velocity, self.y_velocity)
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

function Boy:changeLightbulb()
  print('Changing the lightbulb!')
  local x, y = self.body:getPosition()
  table.insert(AllBulbz, Bulb(World, x, y - 20))
end


function Boy:draw()
  love.graphics.setColor({ 1, 1, 1 })

  local x, y = self.body:getPosition()
  local scale_x = Boy.width / self.image:getWidth()
  local scale_y = Boy.height / self.image:getHeight()

  love.graphics.draw(self.image, x, y, 0, scale_x, scale_y, self.image:getWidth() / 2, self.image:getHeight() / 2, 0, 0)
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

    if key == "e" then
      print("Pressing E ")
      if not isrepeat then
        self:changeLightbulb()
      end
    end

  end
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
  table.insert(self.collisions, coll)

  -- If the player has landed, reset y velocity to 0
  if IsAbove(a, b, self.fixture, normal_y) then
    self:stopVerticalMotion()
  end

  -- If the player touches

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
    if IsAbove(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
      on_top = true
    end
  end
  
  return on_top
  
end

-- function Boy:hasLanded()

--   local on_top = false

--   for _, collision in ipairs(self.collisions) do
--     if (
--       IsAbove(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y)
--     and
--       (IsCollidingWithNonMovingBody())
--     ) then
--       on_top = true
--     end
--   end
-- 
--   return on_top
-- 
-- end