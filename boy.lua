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
  self.max_speed = Boy.max_speed
  self.jump_strength = Boy.jump_strength
  self.acceleration = Boy.acceleration
  self.resistance = Boy.resistance
  self.x_velocity = Boy.initial_x_velocity
  self.y_velocity = Boy.initial_y_velocity
  self.collisions = {}

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
  
  -- State variables
  local is_player = self.fixture:getCategory() == Categories.LIVEBOY
  local is_on_ladder = self:isOnLadder()
  local is_on_surface = self:isOnSurface()
  local is_beneath_surface = self:isBeneathSurface()
  local is_jumping = self:isJumping(self.jump_key_pressed, #self.collisions, is_beneath_surface, is_on_ladder, is_on_surface)
  -- local is_landing = self:isLanding(self.collisions, is_beneath_surface, is_on_ladder, is_on_surface)
  
  local arrow_left_pressed = love.keyboard.isDown("a", "left")
  local arrow_right_pressed = love.keyboard.isDown("d", "right")
  local arrow_up_pressed = love.keyboard.isDown("w", "up")
  local arrow_down_pressed = love.keyboard.isDown("s", "down")

  local current_x_velocity = self.x_velocity
  local current_y_velocity = self.y_velocity
  local frame_rate = Boy.getFrameRate(current_x_velocity, self.spriteState)
  local current_frame = self.spriteFrameRef + (frame_rate * dt)
  -- local gravity = self:getGravity(is_player, is_on_ladder, is_on_surface, Boy.gravity)

  -- Set animation state
  self.direction = self.direction or self:getDirection(arrow_left_pressed, arrow_right_pressed, arrow_up_pressed, arrow_down_pressed, is_player)
  self.spriteFrameRef = self:setAnimationFrame(current_frame)
  self.spriteState = self:setSpriteState(self.direction, is_player)

  -- Determine ladder status of non-player sprites
  if not is_player then
    local is_already_ladder = self.fixture:isSensor()
    local is_ladder = self:isLadder(is_on_ladder, is_on_surface)
    if is_already_ladder ~= is_ladder then
      self.fixture:setSensor(is_ladder)
    end
  end

  -- Calculate horizontal velocity
  local x_velocity_after_acceleration = self:addAcceleration(dt, current_x_velocity, self.direction, is_player)
  local x_velocity_after_friction = self:addFriction(dt, x_velocity_after_acceleration, self.resistance)
  self.x_velocity = x_velocity_after_friction

  -- Calculate vertical velocity
  local y_velocity_after_collisions = self:addVerticalCollision(dt, current_y_velocity, is_beneath_surface, is_on_surface, is_jumping)
  local y_velocity_after_gravity = self:applyGravity(dt, is_on_surface, is_on_ladder, y_velocity_after_collisions, Boy.gravity, is_player)
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
  if is_player then self.direction = nil end

  -- Debugging
  -- if is_player then print(y_velocity_after_collisions) end
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

function Boy:applyGravity(dt, is_on_surface, is_on_ladder, current_y_velocity, gravitational_force, is_player)
  local velocity

  local velocity_after_gravity = current_y_velocity + gravitational_force * dt

  if not is_on_surface and not is_on_ladder then
    velocity = velocity_after_gravity
  end

  if is_on_ladder and velocity_after_gravity < 0 then
    velocity = velocity_after_gravity
  end

  if is_on_ladder and velocity_after_gravity >= 0 then
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
  local x, y = self.body:getPosition()
  Sounds.change_lightbulb:play()
  table.insert(AllBulbz, Bulb(World, x + 50, y))
end


function Boy:draw()
  love.graphics.setColor({ 1, 1, 1 })

  local x, y = self.body:getPosition()

  local scale_x = Boy.scale
  if self.fixture:getCategory() == Categories.LIVEBOY and (love.keyboard.isDown('a') or love.keyboard.isDown('left')) then scale_x = -Boy.scale end
  love.graphics.draw(Boy.images[self.spriteState], Boy.sprites[self.spriteState][math.floor(self.spriteFrameRef)], x, y, 0, scale_x, Boy.scale, Boy.images[self.spriteState]:getWidth() / 6 / 2, Boy.images[self.spriteState]:getHeight() / 2, 0, 0)
end

function Boy:keypressed(key, _, isrepeat)
  if self.fixture:getCategory() ~= Categories.LIVEBOY then return end

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

  if IsDirectionKey(key) then
    self.direction = Boy.DIRECTIONS[key]
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
  local x, y = self.body:getPosition()
  self.x_position_override = x
  self.y_position_override = y
  local normal_x, normal_y = contact:getNormal()
  local coll = { fixture_a = a, fixture_b = b, normal_x = normal_x, normal_y = normal_y }
  table.insert(self.collisions, coll)
  self:playCollisionAudio(self.y_velocity)
end

-- Removes collision data from the Boy's collisions table
function Boy:endContact(a, b, contact)
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

function Boy:isOnLadder()

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
  if frame > (#(Boy.sprites[self.spriteState]) + 1) then
    return 1
  end
  return frame
end

function Boy:setSpriteState(direction, is_player)
  local spriteState
  if is_player and (direction == 'left' or direction == 'right') then spriteState = 'walking' end
  if is_player and direction == 'forward' then spriteState = 'idle' end
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

  if jump_key_pressed and (collisions ~= 0) then
    if is_on_ladder or is_on_surface then
      if not is_beneath_surface then
        is_jumping = true
      end
    end
  end

  return is_jumping
end

function Boy:getGravity(is_player, is_on_ladder, is_on_surface, default_gravity)
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

function Boy:getDirection(arrow_left_pressed, arrow_right_pressed, arrow_up_pressed, arrow_down_pressed, is_player)
  local direction = 'forward'

  if not is_player then return direction else 
    if arrow_down_pressed then direction = 'forward' end
    if arrow_up_pressed then direction = 'forward' end
    if arrow_left_pressed then direction = 'left' end
    if arrow_right_pressed then direction = 'right' end
  end

  return direction
end