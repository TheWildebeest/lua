Boy = Object:extend()

-- Sprites
Boy.images = {
  idle_left = love.graphics.newImage("assets/img/boy/idle_left.png"),
  idle_right = love.graphics.newImage("assets/img/boy/idle_right.png"),
  ladder_left = love.graphics.newImage("assets/img/boy/ladder_left.png"),
  ladder_right = love.graphics.newImage("assets/img/boy/ladder_right.png"),
  walking_left = love.graphics.newImage("assets/img/boy/walking_left.png"),
  walking_right = love.graphics.newImage("assets/img/boy/walking_right.png")
}

Boy.sprites = {
  idle_left = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.idle_left:getWidth(), Boy.images.idle_left:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.idle_left:getWidth(), Boy.images.idle_left:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.idle_left:getWidth(), Boy.images.idle_left:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.idle_left:getWidth(), Boy.images.idle_left:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.idle_left:getWidth(), Boy.images.idle_left:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.idle_left:getWidth(), Boy.images.idle_left:getHeight())
  },
  idle_right = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.idle_right:getWidth(), Boy.images.idle_right:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.idle_right:getWidth(), Boy.images.idle_right:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.idle_right:getWidth(), Boy.images.idle_right:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.idle_right:getWidth(), Boy.images.idle_right:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.idle_right:getWidth(), Boy.images.idle_right:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.idle_right:getWidth(), Boy.images.idle_right:getHeight())
  },
  ladder_left = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.ladder_left:getWidth(), Boy.images.ladder_left:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.ladder_left:getWidth(), Boy.images.ladder_left:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.ladder_left:getWidth(), Boy.images.ladder_left:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.ladder_left:getWidth(), Boy.images.ladder_left:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.ladder_left:getWidth(), Boy.images.ladder_left:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.ladder_left:getWidth(), Boy.images.ladder_left:getHeight())
  },
  ladder_right = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.ladder_right:getWidth(), Boy.images.ladder_right:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.ladder_right:getWidth(), Boy.images.ladder_right:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.ladder_right:getWidth(), Boy.images.ladder_right:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.ladder_right:getWidth(), Boy.images.ladder_right:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.ladder_right:getWidth(), Boy.images.ladder_right:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.ladder_right:getWidth(), Boy.images.ladder_right:getHeight())
  },
  walking_left = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.walking_left:getWidth(), Boy.images.walking_left:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.walking_left:getWidth(), Boy.images.walking_left:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.walking_left:getWidth(), Boy.images.walking_left:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.walking_left:getWidth(), Boy.images.walking_left:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.walking_left:getWidth(), Boy.images.walking_left:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.walking_left:getWidth(), Boy.images.walking_left:getHeight()),
  },
  walking_right = {
    [1] = love.graphics.newQuad(2,2, 498,998, Boy.images.walking_right:getWidth(), Boy.images.walking_right:getHeight()),
    [2] = love.graphics.newQuad(502,2, 498,998, Boy.images.walking_right:getWidth(), Boy.images.walking_right:getHeight()),
    [3] = love.graphics.newQuad(1002,2, 498,998, Boy.images.walking_right:getWidth(), Boy.images.walking_right:getHeight()),
    [4] = love.graphics.newQuad(1502,2, 498,998, Boy.images.walking_right:getWidth(), Boy.images.walking_right:getHeight()),
    [5] = love.graphics.newQuad(2002,2, 498,998, Boy.images.walking_right:getWidth(), Boy.images.walking_right:getHeight()),
    [6] = love.graphics.newQuad(2502,2, 498,998, Boy.images.walking_right:getWidth(), Boy.images.walking_right:getHeight()),
  }
}

Boy.getFrameRate = function(speed, state)
  if state == 'idle' then return 5 end
  if state == 'ladder' then return 4 end
  if state == 'walking' or state == 'walking' then return math.abs(speed) / 30 end
end

-- Static properties/methods

Boy.width = love.physics:getMeter() * 2.5
Boy.height = love.physics:getMeter() * 5
Boy.scale = (Boy.width / Boy.images.idle_right:getHeight()) * 2
Boy.MAX_SPEED = 600
Boy.MAX_CLIMB_SPEED = 800
Boy.LADDER_GRAVITY_ON = 0
Boy.LADDER_GRAVITY_OFF = 1
Boy.resistance = 3500
Boy.acceleration = 4000
Boy.climb_acceleration = 1200
Boy.jump_strength = 900
function Boy.getBody(environment, world)
  local body = love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic")
  body:setFixedRotation(true)
  body:setLinearVelocity(0, 100)
  return body
end

function Boy.getShape()
  local shape = love.physics.newRectangleShape(Boy.width, Boy.height)
  return shape
end

function Boy.getFixture(body, shape)
  local fixture = love.physics.newFixture(body, shape)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture:setCategory(Categories.LIVEBOY)
  -- fixture:setSensor(false)
  return fixture
end

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
  self.body:setLinearVelocity(0, 100)
  self.collisions = {}
  
  -- Set animation state
  self.spriteState = 'idle'
  self.spriteFrameRef = 1
  self.facing = 'right'
end

function Boy:update(dt)

  -- State variables
  local is_player = self.fixture:getCategory() == Categories.LIVEBOY
  local is_touching_ladder = self:isTouchingLadder()
  local is_on_surface = self:isOnSurface()
  local is_jumping = self:isJumping(self.jump_key_pressed, is_touching_ladder, is_on_surface)

  local arrow_left_pressed = love.keyboard.isDown("a", "left")
  local arrow_right_pressed = love.keyboard.isDown("d", "right")
  local arrow_up_pressed = love.keyboard.isDown("w", "up")
  local arrow_down_pressed = love.keyboard.isDown("s", "down")
  
  local current_x_velocity, current_y_velocity = self.body:getLinearVelocity()

  -- Set direction
  local direction
  if arrow_left_pressed and arrow_right_pressed then direction = 'forward'
  elseif arrow_up_pressed and arrow_down_pressed then direction = 'forward'
  elseif arrow_left_pressed then direction = 'left'
  elseif arrow_right_pressed then direction = 'right'
  elseif arrow_down_pressed then direction = 'down'
  elseif arrow_up_pressed then direction = 'up'
  else direction = 'forward' end

  -- Set animation state
  local frame_rate = Boy.getFrameRate(current_x_velocity, self.spriteState)
  local current_frame = self.spriteFrameRef + (frame_rate * dt)
  self.spriteFrameRef = self:setAnimationFrame(current_frame)
  self.spriteState = self:setSpriteState(direction, is_player)
  -- ---

  -- Calculate horizontal velocity
  if is_player then
    if arrow_left_pressed then
      current_x_velocity = self:addAcceleration(dt, current_x_velocity, 'left')
    end
    if arrow_right_pressed then
      current_x_velocity = self:addAcceleration(dt, current_x_velocity, 'right')
    end
  end
  current_x_velocity = self:addFriction(dt, current_x_velocity, Boy.resistance)
  -- ---

  -- Set gravity
  local existing_gravity = self.body:getGravityScale()
  local correct_gravity = self:calculateGravityState(is_touching_ladder, current_y_velocity, arrow_up_pressed, arrow_down_pressed)
  if correct_gravity ~= existing_gravity then
    self.body:setGravityScale(correct_gravity)
  end
  -- ---

  -- Calculate vertical velocity
  if is_player then

    -- Move up and down on ladder
    if is_touching_ladder then
      if arrow_up_pressed then
        current_y_velocity = self:addAcceleration(dt, current_y_velocity, 'up')
      end
      if arrow_down_pressed then
        current_y_velocity = self:addAcceleration(dt, current_y_velocity, 'down')
      end

      if (not arrow_up_pressed) and (not arrow_down_pressed) and (current_y_velocity > 0) then
        current_y_velocity = 0
      end
    end

    -- Jump
    if is_jumping then
      current_y_velocity = -Boy.jump_strength
    end
  end
  -- ---

  -- Update physics body with computed velocity
  self.body:setLinearVelocity(current_x_velocity, current_y_velocity)
  
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
  local _x, _y = self.body:getLinearVelocity()
  -- print('Vertical speed:', _y)
end

function Boy:addAcceleration(dt, current_velocity, direction)

  local velocity = 0

  -- Move right
  if direction == 'right' then
    if current_velocity < Boy.MAX_SPEED then
      if current_velocity + Boy.acceleration * dt < Boy.MAX_SPEED then
        velocity = current_velocity + Boy.acceleration * dt
      else
        velocity = Boy.MAX_SPEED
      end
    end
  end

  -- Move left
  if direction == 'left' then
    if current_velocity > -Boy.MAX_SPEED then
      if current_velocity - Boy.acceleration * dt > -Boy.MAX_SPEED then
        velocity = current_velocity - Boy.acceleration * dt
      else
        velocity = -Boy.MAX_SPEED
      end
    end
  end

  -- Move up
  if direction == 'up' then
    if current_velocity > -Boy.MAX_CLIMB_SPEED then
      if current_velocity - Boy.climb_acceleration * dt > -Boy.MAX_CLIMB_SPEED then
        velocity = current_velocity - Boy.climb_acceleration * dt
      else
        velocity = -Boy.MAX_CLIMB_SPEED
      end
    else
      velocity = -Boy.MAX_CLIMB_SPEED
    end
  end

  if direction == 'down' then
    if current_velocity < Boy.MAX_CLIMB_SPEED then
      if current_velocity + Boy.climb_acceleration * dt < Boy.MAX_CLIMB_SPEED then
        velocity = current_velocity + Boy.climb_acceleration * dt
      else
        velocity = Boy.MAX_CLIMB_SPEED
      end
    else
      velocity = Boy.MAX_CLIMB_SPEED
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

function Boy:applyGravity(dt, is_on_surface, is_touching_ladder, current_y_velocity, gravitational_force, is_player)
  local velocity

  local velocity_after_gravity = current_y_velocity + gravitational_force * dt

  if not is_on_surface and not is_touching_ladder then
    velocity = velocity_after_gravity
  end

  if is_touching_ladder and velocity_after_gravity < 0 then
    velocity = velocity_after_gravity
  end

  if is_touching_ladder and velocity_after_gravity >= 0 then
    velocity = 0
  end

  if is_on_surface and velocity_after_gravity >= 0 then
    velocity = 0
  end

  if is_on_surface and velocity_after_gravity < 0 then
    velocity = velocity_after_gravity
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
  local facing = self.facing
  local x, y = self.body:getPosition()
  if facing == "left" then x = x - 25 else x = x + 5 end
  Sounds.change_lightbulb:play()
  table.insert(AllBulbz, Bulb(World, x, y, facing))
end


function Boy:draw()
  love.graphics.setColor({ 1, 1, 1 })

  local x, y = self.body:getPosition()
  if not x then x = 10 end
  if not y then y = 10 end

  local state = self.spriteState..'_'..self.facing

  local scale_x = Boy.scale
  love.graphics.draw(Boy.images[state], Boy.sprites[state][math.floor(self.spriteFrameRef)], x, y, 0, scale_x, Boy.scale, Boy.images[state]:getWidth() / 6 / 2, Boy.images[state]:getHeight() / 2, 0, 0)
end

function Boy:keypressed(key, _, isrepeat)
  if self.fixture:getCategory() == Categories.DEADBOY then return end

  if key == "space" then
    if not isrepeat then
      self.jump_key_pressed = true
    end
  end

  if key == "d" or key == "right" then
    self.facing = "right"
  end

  if key == "a" or key == "left" then
    self.facing = "left"
  end

  if key == "e" then
    self:changeLightbulb()
  end

  if key == "l" then
    if not isrepeat then
      self.spriteState = "ladder"
      self.fixture:setCategory(Categories.DEADBOY)
    end
  end
end

function Boy:reset(environment, world)
  self.fixture:destroy()
  self.body:destroy()
  self:init(environment, world)
end

-- Adds collision data to the Boy's collisions table.
--
-- Plays collision audio if needed
function Boy:beginContact(a, b, contact)
  local x, y = self.body:getLinearVelocity()
  local normal_x, normal_y = contact:getNormal()
  local coll = { fixture_a = a, fixture_b = b, normal_x = normal_x, normal_y = normal_y }
  table.insert(self.collisions, coll)
  if self.body:getGravityScale() == Boy.LADDER_GRAVITY_OFF then
    self:playCollisionAudio(y)
  end
end

-- Removes collision data from the Boy's collisions table
function Boy:endContact(a, b)
  local index = nil
  for i, collision_data in ipairs(self.collisions) do
    local match = false
    if (a == collision_data.fixture_a and b == collision_data.fixture_b) then match = true end
    if (a == collision_data.fixture_b and b == collision_data.fixture_a) then match = true end
    if match then index = i end
  end
  if index then table.remove(self.collisions, index) end
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

function Boy:isTouchingLadder()

  local on_ladder = false

  for _, collision in ipairs(self.collisions) do
    if IsLadderCollision(self.fixture, collision.fixture_a, collision.fixture_b) then
      on_ladder = true
    end
  end

  return on_ladder
end

function Boy:playCollisionAudio(y_velocity)
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
  local state = self.spriteState..'_'..self.facing
  if frame > (#(Boy.sprites[state]) + 1) then
    return 1
  end
  return frame
end

function Boy:setSpriteState(direction, is_player)
  if not is_player then return 'ladder' end
  
  local spriteState
  if direction == 'left' then spriteState = 'walking' end
  if direction == 'right' then spriteState = 'walking' end
  if (direction == 'up' or direction == 'down') then spriteState = 'idle' end
  if direction == 'down' then spriteState = 'idle' end
  if direction == 'forward' then spriteState = 'idle' end
  return spriteState
end

function Boy:isJumping(jump_key_pressed, is_touching_ladder, is_on_surface)
  local is_jumping = false

  if jump_key_pressed then
    if is_touching_ladder or is_on_surface then
      is_jumping = true
    end
  end

  return is_jumping
end

function Boy:getGravity(is_player, is_touching_ladder, is_on_surface, default_gravity)
  local gravity

  -- Non-player sprite 
  if (not is_player) and (is_touching_ladder or is_on_surface) then gravity = 0 end
  if (not is_player) and (not (is_touching_ladder or is_on_surface)) then gravity = default_gravity end

  -- Player sprite
  if is_player and is_touching_ladder then gravity = 0 end
  if is_player and not is_touching_ladder then gravity = default_gravity end

  return gravity
end

function Boy:isLadder(is_touching_ladder, is_on_surface)
  local is_ladder

  if (is_touching_ladder or is_on_surface) then
    is_ladder = true
  end
  
  if not (is_touching_ladder or is_on_surface) then
    is_ladder = false
  end

  return is_ladder
end

function Boy:calculateGravityState(is_touching_ladder, y_velocity, up_arrow_pressed, down_arrow_pressed)
  local new_state = Boy.LADDER_GRAVITY_OFF

  if is_touching_ladder then
    if y_velocity >= 0 or up_arrow_pressed then
      new_state = Boy.LADDER_GRAVITY_ON
    end


    -- if y_velocity == 0 then
    --   new_state = Boy.LADDER_GRAVITY_ON
    -- end

    -- if y_velocity > 0 and (down_arrow_pressed or up_arrow_pressed) then
    --   new_state = Boy.LADDER_GRAVITY_ON
    -- end

    -- if y_velocity < 0 and (down_arrow_pressed or up_arrow_pressed) then
    --   new_state = Boy.LADDER_GRAVITY_ON
    -- end

  end

  return new_state
end

Boy.DIRECTIONS = {
  a = 'left',
  left = 'left',
  d = 'right',
  right = 'right',
  -- w = 'up',
  w = 'forward',
  -- up = 'up',
  up = 'forward',
  -- s = 'down',
  s = 'forward',
  -- down = 'down'
  down = 'forward'
}

function Boy:preSolve(a, b, collision)
  local own_fixture = self.fixture
  if a == own_fixture and a:getCategory() == Categories.LIVEBOY then
    if b:getCategory() == Categories.DEADBOY then
      collision:setEnabled(false)
      -- local x, _ = self.body:getLinearVelocity()
      -- self.body:setLinearVelocity(x, 0)
      -- self.is_touching_ladder = true
    end
  end

  if b == own_fixture and b:getCategory() == Categories.LIVEBOY then
    if a:getCategory() == Categories.DEADBOY then
      collision:setEnabled(false)
      -- local x, _ = self.body:getLinearVelocity()
      -- self.body:setLinearVelocity(x, 0)
      -- self.is_touching_ladder = true
    end
  end
  -- print('Player collision with ', Categories[other:getCategory()])
end

function Boy:postSolve(own_fixture, other_fixture, collision)
  if own_fixture:getCategory() == Categories.LIVEBOY then
    if other_fixture:getCategory() == Categories.DEADBOY then
      collision:setEnabled(false)
      -- local x, _ = self.body:getLinearVelocity()
      -- self.body:setLinearVelocity(x, 0)
      -- self.is_touching_ladder = true
    end
  end
  -- print('Player collision with ', Categories[other:getCategory()])
end