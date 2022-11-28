Boy = Object:extend()

-- Static properties/methods

Boy.width = love.physics:getMeter() * 2.5
Boy.height = love.physics:getMeter() * 5
Boy.default_base_color = { 0.20, 0.20, 0.20 }
Boy.default_highlight_color = { 0.5, 0.3, 0.1 }
Boy.gravity = 2000
Boy.images = {
  idle = love.graphics.newImage("assets/img/boy/idle_new.png"),
  walking = love.graphics.newImage("assets/img/boy/walking.png")
}

Boy.sprites = {
  idle = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.idle:getWidth(), Boy.images.idle:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.idle:getWidth(), Boy.images.idle:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.idle:getWidth(), Boy.images.idle:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.idle:getWidth(), Boy.images.idle:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.idle:getWidth(), Boy.images.idle:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.idle:getWidth(), Boy.images.idle:getHeight())
  },
  walking = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.walking:getWidth(), Boy.images.walking:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.walking:getWidth(), Boy.images.walking:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.walking:getWidth(), Boy.images.walking:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.walking:getWidth(), Boy.images.walking:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.walking:getWidth(), Boy.images.walking:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.walking:getWidth(), Boy.images.walking:getHeight()),
  }
}

Boy.getFrameRate = function(speed, state)
  if state == 'idle' then return 5 end
  if state == 'walking' then return math.abs(speed) / 30 end
end


-- `Static`
Boy.initBody = function (environment, world)
  return love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic")
end

-- `Static`
Boy.initShape = function ()
  return love.physics.newRectangleShape(Boy.width, Boy.height)
end


function Boy:init(environment, world)

  self.spriteState = 'idle'
  self.spriteFrameRef = 1
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
  self.scale = (Boy.width / self.images.idle:getHeight()) * 2
  self.x_position_override = nil
  self.y_position_override = nil

  self.body:setFixedRotation(true)
  self.fixture:setCategory(Categories.LIVEBOY)

end

function Boy:new(environment, world)
  self:init(environment, world)
end

function Boy:update(dt)
  local frame_rate = Boy.getFrameRate(self.x_velocity, self.spriteState)
  local current_frame = self.spriteFrameRef + (frame_rate * dt)

  -- Movement SFX

  -- if self.spriteState == 'walking' then
  --   if math.floor(current_frame) == 1 then
  --     Sounds.step_one:play()
  --   end

  --   if math.floor(current_frame) == 4 then
  --     Sounds.step_two:play()
  --   end
  -- end

  -- if self.spriteState == 'idle' then
    
  -- end

  if current_frame > (#(Boy.sprites[self.spriteState]) + 1) then
    self.spriteFrameRef = 1
  else
    self.spriteFrameRef = current_frame
  end
  local category = self.fixture:getCategory()
  local is_on_surface = self:isOnSurface()
  local is_beneath_surface = self:isBeneathSurface()
  local is_on_ladder = self:isOnLadder()

  -- Only apply movement if this instance is the player sprite
  if category == Categories.LIVEBOY then
    self:move(dt)
  end

  if category == Categories.DEADBOY then
    if (is_on_ladder or is_on_surface) then
      if not self.fixture:isSensor() then
        self.gravity = 0
        self.fixture:setSensor(true)
      end
    end

    if not (is_on_ladder or is_on_surface) then
      if self.fixture:isSensor() then
        self.gravity = Boy.gravity
        self.y_velocity = -self.jump_strength * 0.3
        self.fixture:setSensor(false)
      end
    end
  end


  if (
    is_on_surface and
    self.y_velocity > 0
  ) then
    self:stopVerticalMotion()
  end

  if (
    is_beneath_surface and
    self.y_velocity < 0
  ) then
    self:stopVerticalMotion()
  end

  -- Apply gravity to sprite if airborne
  if (
    (not is_on_surface)
    -- (not is_on_ladder)
    ) then
      self:applyGravity(dt)
  end

  -- Apply friction to all sprites
  self:applyFriction(dt)
  self.body:setLinearVelocity(self.x_velocity, self.y_velocity)

  -- If there are overrides in place for x and y position, move player back there and then reset to nil
  if self.x_position_override then
    self.body:setX(self.x_position_override)
    self.x_position_override = nil
  end

  if self.y_position_override then
    self.body:setY(self.y_position_override)
    self.y_position_override = nil
  end

end

function Boy:move(dt)

  local walking = false
  local direction = 'forward'

  -- Move right
  if love.keyboard.isDown("d", "right") then

    walking = true
    direction = 'right'

    if self.x_velocity < self.max_speed then
      if self.x_velocity + self.acceleration * dt < self.max_speed then
        self.x_velocity = self.x_velocity + self.acceleration * dt
      else
        self.x_velocity = self.max_speed
      end
    end

  -- Move left
  elseif love.keyboard.isDown("a", "left") then

    walking = true
    direction = 'left'

    if self.x_velocity > -self.max_speed then
      if self.x_velocity - self.acceleration * dt > -self.max_speed then
        self.x_velocity = self.x_velocity - self.acceleration * dt
      else
        self.x_velocity = -self.max_speed
      end
    end
  end

  if walking then self.spriteState = 'walking' else self.spriteState = 'idle' end
  self.direction = direction

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
  if (self:isOnLadder() and self.y_velocity < 0) then

    if self.y_velocity + Boy.gravity* dt >= 0 then
      self.y_velocity = 0
    else
      self.y_velocity = self.y_velocity + Boy.gravity * dt
    end
    
  else

    self.y_velocity = self.y_velocity + self.gravity * dt

  end
end

function Boy:changeLightbulb()
  print('Changing the lightbulb!')
  local x, y = self.body:getPosition()
  Sounds.change_lightbulb:play()
  table.insert(AllBulbz, Bulb(World, x + 50, y))
end


function Boy:draw()
  love.graphics.setColor({ 1, 1, 1 })

  local x, y = self.body:getPosition()

  local scale_x
  if self.direction == 'left'    then scale_x = -self.scale end
  if self.direction == 'right'   then scale_x = self.scale end
  if self.direction == 'forward' then scale_x = self.scale end


  love.graphics.draw(Boy.images[self.spriteState], Boy.sprites[self.spriteState][math.floor(self.spriteFrameRef)], x, y, 0, scale_x, self.scale, self.images[self.spriteState]:getWidth() / 6 / 2, self.images[self.spriteState]:getHeight() / 2, 0, 0)
end

function Boy:keypressed(key, _, isrepeat)
  local category= self.fixture:getCategory()
  if category == Categories.DEADBOY then return end
  if category == Categories.LIVEBOY then

    if key == "x" then
      if not isrepeat then
        self.spriteState = "idle"
        self.fixture:setCategory(Categories.DEADBOY)
        -- if self:isOnSurface() or self:isOnLadder() then
        --   self.fixture:setSensor(true)
        -- end
      end
    end

    if key == "space" then
      if not isrepeat then
        if self:isOnSurface() then
          print('is on surface')
          Sounds.jump:play()
          self.y_velocity = -self.jump_strength
        elseif self:isOnLadder() then
          print('is on ladder')
          Sounds.jump:play()
          self.y_velocity = -self.jump_strength
        end
      end
    end

    if key == "e" then
      -- print("Pressing E ")
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
  local x, y = self.body:getPosition()
  self.x_position_override = x
  self.y_position_override = y
  local normal_x, normal_y = contact:getNormal()
  local coll = { fixture_a = a, fixture_b = b, normal_x = normal_x, normal_y = normal_y }
  local is_player = self.fixture:getCategory() == Categories.LIVEBOY
  table.insert(self.collisions, coll)

  -- Determine whether the player has changed state from being on a ladder or not on a ladder
  self:contactStartLadderCheck(self.fixture, a, b)

  -- Check whether the player has landed
  self:checkHasLanded(self.fixture, a, b, normal_y, is_player)

end

function Boy:endContact(a, b, contact)

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
  print('stopping vertical motion')
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
  -- Has the player just come into contact with a ladder? (Coming ON to a ladder)
  if (IsLadderCollision(object, a, b)) then
    if self.gravity ~= 0 then
      local y_velocity = self.y_velocity
      self:playLandingAudio(y_velocity)
      self:stopVerticalMotion()
      self.gravity = 0
    end
  end
end

function Boy:checkHasLanded(object, a, b, normal_y, is_player)
  -- Has the player just come into contact with the floor or is on top of a stationary object? (Coming OFF of a ladder)
  -- print('Checking if has landed...')
  --  if (IsAbove(object, a, b, normal_y)) then print('Is above: True. Normal_y: '..math.round(normal_y)) else print('Is above: False. Normal_y: '..math.round(normal_y)) end
  --  if (IsStationaryObjectCollision(object, a, b)) then print('Is stationary object collision: True.') else print('Is stationary object collision: False.') end
    
  if (
    (IsAbove(object, a, b, normal_y)) and
    (IsStationaryObjectCollision(object, a, b))
  ) then
    if not is_player then
      -- print('Landed.')
      print("Vertical motion: ", self.y_velocity)
      self:land()
    end

    if (is_player) and (not IsLadderCollision(object, a, b)) then
      -- print('Landed.')
      print("Vertical motion: ", self.y_velocity)

      self:land()
    end

  else
    print('Not landed.')
  end
end

function Boy:isOnLadder()

  local on_ladder = false

  for _, collision in ipairs(self.collisions) do
    if IsLadderCollision(self.fixture, collision.fixture_a, collision.fixture_b) then
      on_ladder = true
    end
  end

  return on_ladder
end

function Boy:land()
  local y_velocity = self.y_velocity
  self:playLandingAudio(y_velocity)
  self:stopVerticalMotion()
  self.gravity = Boy.gravity
end

function Boy:playLandingAudio(y_velocity)
  print("VERTICAL MOTION: ", self.y_velocity)
  local weight = nil -- TODO: only have light impact above a threshold (should be higher than 0 or 1 though)

  if y_velocity > 200 then weight = "light" end
  if y_velocity > 1000 then weight = "mid" end
  if y_velocity > 1500 then weight = "heavy" end

  if weight then
    Sounds.landing_impact[weight]:play()
    Sounds.landing_effort[weight]:play()
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