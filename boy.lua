Boy = Object:extend()

-- Static properties/methods

Boy.width = love.physics:getMeter() * 2.5
Boy.height = love.physics:getMeter() * 5
Boy.default_base_color = { 0.20, 0.20, 0.20 }
Boy.default_highlight_color = { 0.5, 0.3, 0.1 }
Boy.gravity = 2000

-- `Static`
Boy.initBody = function (environment, world)
  return love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic")
end

-- `Static`
Boy.initShape = function ()
  return love.physics.newRectangleShape(Boy.width, Boy.height)
end


function Boy:init(environment, world)

  self.image = love.graphics.newImage("assets/img/boy/1.png")
  self.body = Boy.initBody(environment, world)
  self.shape = Boy.initShape()
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.collisions = { }

  self.x_velocity = 0
  self.y_velocity = 100
  self.gravity = Boy.gravity
  self.max_speed = 600
  self.jump_strength = 900
  self.acceleration = 4000
  self.friction = 3500
  self.scale = Boy.width / self.image:getWidth()

  self.body:setFixedRotation(true)
  self.fixture:setCategory(Categories.LIVEBOY)

end

function Boy:new(environment, world)
  self:init(environment, world)
  self.base_color = { math.random(), math.random(), math.random() }
  self.highlight_color = Boy.default_highlight_color
  self.color = self.base_color
end

function Boy:update(dt)
  local category = self.fixture:getCategory()

  -- Only apply movement to the player sprite
  if category == Categories.LIVEBOY then
    self:move(dt)
  end

  if self:isOnSurface() and self.y_velocity > 0 then
    self:stopVerticalMotion()
  end

  if self:isBeneathSurface() and self.y_velocity < 0 then
    self:stopVerticalMotion()
  end

  -- Apply gravity to all airborne sprites
  if not self:isOnSurface() then
    self:applyGravity(dt)
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
  table.insert(AllBulbz, Bulb(World, x + 50, y))
end


function Boy:draw()
  love.graphics.setColor({ 1, 1, 1 })

  local x, y = self.body:getPosition()


  love.graphics.draw(self.image, x, y, 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2, 0, 0)
end

function Boy:keypressed(key, _, isrepeat)
  local category= self.fixture:getCategory()
  if category == Categories.DEADBOY then return end
  if category == Categories.LIVEBOY then

    if key == "x" then
      if not isrepeat then
        self.fixture:setCategory(Categories.DEADBOY)
        self.fixture:setSensor(true)
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

  -- Determine whether the player has changed state from being on a ladder or not on a ladder
  self:contactStartLadderCheck(self.fixture, a, b)

  -- Check whether the player has landed
  self:checkHasLanded(self.fixture, a, b, normal_y)

end

function Boy:endContact(a, b, contact)
  print("endContact")

  local index = nil
  local ladder_collisions = 0

  for i, collision_data in ipairs(self.collisions) do
    local category_a = collision_data.fixture_a:getCategory()
    local category_b = collision_data.fixture_b:getCategory()

    if (category_a == Categories.DEADBOY) or (category_b == Categories.DEADBOY) then
      ladder_collisions = ladder_collisions + 1
    end

    if (a == collision_data.fixture_a and b == collision_data.fixture_b) or (a == collision_data.fixture_b and b == collision_data.fixture_a)
    then
      index = i
    end

  end

  if IsLadderCollision(self.fixture, a, b) then ladder_collisions = ladder_collisions - 1 end

  if index then table.remove(self.collisions, index) end

  if ladder_collisions == 0 then self.gravity = Boy.gravity end

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

function Boy:isBeneathSurface()

  local beneath = false

  for _, collision in ipairs(self.collisions) do
    if IsBeneath(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
      beneath = true
    end
  end
  
  return beneath
  
end

function Boy:contactStartLadderCheck(object, a, b)
  print('updateLadderState called')
  -- Has the player just come into contact with a ladder? (Coming ON to a ladder)
  if (IsLadderCollision(object, a, b)) then
    print('Colliding with ladder!')
    print('Current gravity: ', self.gravity)
    if self.gravity ~= 0 then
      self:stopVerticalMotion()
      self.gravity = 0
    end
  end
end

function Boy:checkHasLanded(object, a, b, normal_y)
  -- Has the player just come into contact with the floor or is on top of a stationary object? (Coming OFF of a ladder)
  if (not IsLadderCollision) and IsStationaryObjectCollision(object, a, b) and (IsAbove(object, a, b, normal_y)) then
    self:stopVerticalMotion()
    self.gravity = Boy.gravity
  end
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