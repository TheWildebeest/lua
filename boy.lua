Boy = Object:extend()

-- Sprites
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

-- Static properties/methods

Boy.width = love.physics:getMeter() * 2.5
Boy.height = love.physics:getMeter() * 5
Boy.scale = (Boy.width / Boy.images.idle:getHeight()) * 2
Boy.gravity = 2000
Boy.max_speed = 600
Boy.jump_strength = 900
Boy.acceleration = 4000
Boy.resistance = 3500
Boy.jump_threshold = 1000
Boy.initial_x_velocity = 0
Boy.initial_y_velocity = 100
function Boy.getBody(environment, world) local body = love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic") body:setFixedRotation(true) return body end
function Boy.getShape() return love.physics.newRectangleShape(Boy.width, Boy.height) end
function Boy.getFixture(body, shape) local fixture = love.physics.newFixture(body, shape) fixture:setCategory(Categories.LIVEBOY) return fixture end

Boy.updateAll = function(allBoyz, dt)
  for _, each in ipairs(allBoyz) do
    each:update(dt)
  end
end

function Boy:new(environment, world)

  -- Initialise physics entities
  self.body = Boy.getBody(environment, world)
  self.shape = Boy.getShape()
  self.fixture = Boy.getFixture(self.body, self.shape)

  -- Set physics properties
  self.gravity = Boy.gravity
  self.max_speed = Boy.max_speed
  self.jump_strength = Boy.jump_strength
  self.acceleration = Boy.acceleration
  self.resistance = Boy.resistance
  self.x_velocity = Boy.initial_x_velocity
  self.y_velocity = Boy.initial_y_velocity
  self.collisions = { }

  -- Set default overrides (used for collisions and player interaction)
  self.x_position_override = nil
  self.y_position_override = nil
  self.is_grounded = false
  self.jump_key_pressed = false
  self.can_jump = false
  
  -- Set animation state
  self.spriteState = 'idle'
  self.direction = 'forward'
  self.spriteFrameRef = 1
end

function Boy:update(dt)
  
  local is_player = self.fixture:getCategory() == Categories.LIVEBOY
  local is_on_ladder = self:isOnLadder()
  local is_on_surface = self:isOnSurface()
  local is_beneath_surface = self:isBeneathSurface()
  local is_moving_left = love.keyboard.isDown("a", "left")
  local is_moving_right = love.keyboard.isDown("d", "right")
  local is_walking = is_moving_left or is_moving_right
  local is_jumping = self:isJumping(self.jump_key_pressed, #self.collisions, is_beneath_surface, is_on_ladder, is_on_surface)

  local current_x_velocity = self.x_velocity
  local current_y_velocity = self.y_velocity
  local frame_rate = Boy.getFrameRate(current_x_velocity, self.spriteState)
  local current_frame = self.spriteFrameRef + (frame_rate * dt)
  local direction = self:getDirection(is_moving_left, is_moving_right, is_player)
  local gravity = self:setGravity(is_player, is_on_ladder, is_on_surface, Boy.gravity)

  -- Set animation state
  self.direction = direction
  self.spriteFrameRef = self:setAnimationFrame(current_frame)
  self.spriteState = self:setSpriteState(is_walking, is_player)

  -- Determine ladder status of non-player sprites
  if not is_player then
    local is_already_ladder = self.fixture:isSensor()
    local is_ladder = self:isLadder(is_on_ladder, is_on_surface)
    if is_already_ladder ~= is_ladder then
      self.fixture:setSensor(is_ladder)
    end
  end

  -- Calculate horizontal velocity
  local x_velocity_after_acceleration = self:addAcceleration(dt, current_x_velocity, direction, is_player)
  local x_velocity_after_friction = self:addFriction(dt, x_velocity_after_acceleration, self.resistance)
  self.x_velocity = x_velocity_after_friction

  -- Calculate vertical velocity
  local y_velocity_after_collisions = self:addVerticalCollision(dt, current_y_velocity, is_beneath_surface, is_on_surface, is_jumping)
  local y_velocity_after_gravity = self:applyGravity(dt, is_on_surface, is_on_ladder, y_velocity_after_collisions, gravity)
  local y_velocity_after_jumping = self:applyJumpForce(is_jumping, y_velocity_after_gravity, self.jump_strength)
  self.y_velocity = y_velocity_after_jumping
  
  -- If there are overrides in place for x and y position, move player back there and then reset to nil
  if self.x_position_override then
    self.body:setX(self.x_position_override)
    self.x_position_override = nil
  end
  
  if self.y_position_override then
    self.body:setY(self.y_position_override)
    self.y_position_override = nil
  end

  -- Update physics body with computed velocity
  self.body:setLinearVelocity(self.x_velocity, self.y_velocity)
  
  -- Play sound effects
  if is_jumping then
    Sounds.jump:play()
  end

  -- if self.spriteState == 'walking' then
  --   if math.floor(current_frame) == 1 then
  --     Sounds.step_one:play()
  --   end
  --   if math.floor(current_frame) == 4 then
  --     Sounds.step_two:play()
  --   end
  -- end

  -- Reset variables
  self.jump_key_pressed = false

  -- Debugging
  if is_player then print(y_velocity_after_collisions) end
end

function Boy:addAcceleration(dt, current_velocity, direction, is_player)

  local velocity

  if not is_player then velocity = current_velocity end

  if is_player then
    -- Don't add / remove acceleration if both direction keys are pressed
    if direction == 'forward' then velocity = current_velocity end
    -- Move right
    if direction == 'right' then
      if current_velocity < self.max_speed then
        if current_velocity + self.acceleration * dt < self.max_speed then
          velocity = current_velocity + self.acceleration * dt
        else
          velocity = self.max_speed
        end
      end
    end
    -- Move left
    if direction == 'left' then
      if current_velocity > -self.max_speed then
        if current_velocity - self.acceleration * dt > -self.max_speed then
          velocity = current_velocity - self.acceleration * dt
        else
          velocity = -self.max_speed
        end
      end
    end
  end

  return velocity
end

function Boy:addFriction(dt, current_velocity, resistance)
  local velocity = 0
  if current_velocity > 0 then
    if current_velocity - resistance * dt > 0 then
      velocity = current_velocity - resistance * dt
    end
  end
  if current_velocity < 0 then
    if current_velocity + resistance * dt < 0 then
      velocity = current_velocity + resistance * dt
    end
  end
  return velocity
end

function Boy:applyGravity(dt, is_on_surface, is_on_ladder, current_y_velocity, gravitational_force)
  local velocity

  if is_on_surface or gravitational_force == 0 then velocity = 0 end

  if is_on_ladder then
    if current_y_velocity < 0 then
      if current_y_velocity + gravitational_force * dt >= 0 then
        velocity = 0
      else
        velocity = current_y_velocity + gravitational_force * dt
      end
    end
  else
    velocity = current_y_velocity + gravitational_force * dt
  end

  return velocity
end

function Boy:addVerticalCollision(dt, y_velocity, is_beneath_surface, is_on_surface, is_jumping)
  local velocity = y_velocity

  if is_beneath_surface and y_velocity < 0 then
    velocity = 0
  end

  if is_on_surface and (not is_jumping) and y_velocity > 0  then
    velocity = 0
  end

  return velocity
end

function Boy:changeLightbulb()
  local x, y = self.body:getPosition()
  Sounds.change_lightbulb:play()
  table.insert(AllBulbz, Bulb(World, x + 50, y))
end


function Boy:draw()
  love.graphics.setColor({ 1, 1, 1 })

  local x, y = self.body:getPosition()

  local scale_x
  if self.direction == 'left'    then scale_x = -Boy.scale end
  if self.direction == 'right'   then scale_x = Boy.scale end
  if self.direction == 'forward' then scale_x = Boy.scale end

  love.graphics.draw(Boy.images[self.spriteState], Boy.sprites[self.spriteState][math.floor(self.spriteFrameRef)], x, y, 0, scale_x, Boy.scale, Boy.images[self.spriteState]:getWidth() / 6 / 2, Boy.images[self.spriteState]:getHeight() / 2, 0, 0)
end

function Boy:keypressed(key, _, isrepeat)
  local category= self.fixture:getCategory()
  if category == Categories.DEADBOY then return end
  if category == Categories.LIVEBOY then

    if key == "x" then
      if not isrepeat then
        self.spriteState = "idle"
        self.fixture:setCategory(Categories.DEADBOY)
      end
    end

    if key == "space" then
      if not isrepeat then
        self.jump_key_pressed = true
      end
    end

    if key == "e" then
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
    if (collision.fixture_a:getCategory() ~= Categories.BULB) and (collision.fixture_b:getCategory() ~= Categories.BULB) then
      if IsBeneath(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
        beneath = true
      end
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
      -- print("Vertical motion: ", self.y_velocity)
      self:land()
    end

    if (is_player) and (not IsLadderCollision(object, a, b) and self.y_velocity > 0) then
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
  if y_velocity > 0 then
    self:stopVerticalMotion()
  end
  self.gravity = Boy.gravity
end

function Boy:playLandingAudio(y_velocity)
  -- print("VERTICAL MOTION: ", self.y_velocity)
  local weight = nil -- TODO: only have light impact above a threshold (should be higher than 0 or 1 though)

  if y_velocity > 200 then weight = "light" end
  if y_velocity > 1000 then weight = "mid" end
  if y_velocity > 1500 then weight = "heavy" end

  if weight then
    Sounds.landing_impact[weight]:play()
    Sounds.landing_effort[weight]:play()
  end
end

function Boy:setAnimationFrame(frame)
  if frame > (#(Boy.sprites[self.spriteState]) + 1) then
    return 1
  end
  return frame
end

function Boy:getDirection(left, right, is_player)
  local direction = 'forward'

  if is_player and left and not right then direction = 'left' end
  if is_player and right and not left then direction = 'right' end

  return direction
end

function Boy:setSpriteState(walking, is_player)
  local spriteState
  if is_player and walking then spriteState = 'walking' end
  if not walking then spriteState = 'idle' end
  if not is_player then spriteState = 'idle' end
  return spriteState
end

function Boy:applyJumpForce(is_jumping, y_velocity, jump_strength)
  local velocity

  if is_jumping then
    velocity = -jump_strength
  end

  if not is_jumping then
    velocity = y_velocity
  end

  return velocity
end

function Boy:isJumping(jump_key_pressed, collisions, is_beneath_surface, is_on_ladder, is_on_surface)
  local is_jumping = false

  if jump_key_pressed and collisions ~= 0 then
    if is_on_ladder or is_on_surface then
      if not is_beneath_surface then
        is_jumping = true
      end
    end
  end

  return is_jumping
end

function Boy:setGravity(is_player, is_on_ladder, is_on_surface, default_gravity)
  local gravity

  -- Non-player sprite 
  if (not is_player) and (is_on_ladder or is_on_surface) then gravity = 0 end
  if (not is_player) and (not (is_on_ladder or is_on_surface)) then gravity = default_gravity end

  -- Player sprite
  if is_player and is_on_ladder then gravity = 0 end
  if is_player and not is_on_ladder then gravity = default_gravity end

  return gravity
end

function Boy:isLadder(is_on_ladder, is_on_surface)
  local is_ladder

  if (is_on_ladder or is_on_surface) then
    is_ladder = true
  end
  
  if not (is_on_ladder or is_on_surface) then
    is_ladder = false
  end

  return is_ladder
end