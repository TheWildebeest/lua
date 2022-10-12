Bulb = Object:extend()

--- ----------------------------------------------------------------------------------------------------------------------


-- Static properties/methods

Bulb.width = love.physics:getMeter() * 1.5
Bulb.height = love.physics:getMeter() * 1.5

-- `Static`
Bulb.initBody = function (world, x, y)
  return love.physics.newBody(world, x, y, "dynamic")
end

-- `Static`
Bulb.initShape = function ()
  return love.physics.newRectangleShape(Bulb.width, Bulb.height)
end

function Bulb:init(world, x, y)

  self.body = Bulb.initBody(world, x, y)
  self.shape = Bulb.initShape()
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(0.7) -- let the ball bounce
  self.fixture:setDensity(0.5)

  self.collisions = { }

  self.x_velocity = 500
  self.y_velocity = -1500
  self.gravity = 1500
  self.max_speed = 10000
  self.acceleration = 4000
  self.friction = 3500

  -- self.body:setFixedRotation(false)
  self.fixture:setCategory(Categories.BULB)

end


function Bulb:new(world, x, y)
  self:init(world, x, y)
  self.base_color = { math.random(), math.random(), math.random() }
  -- Boy.default_base_color
  self.color = self.base_color
  self.image = love.graphics.newImage("assets/img/sprite_bulb.png")
end

function Bulb:keypressed()
  return nil
end


function Bulb:update(dt)

  -- Apply gravity to all airborne sprites
  if not self:isOnSurface() then
    self:applyGravity(dt)
  elseif self.y_velocity > 0 then
    self.y_velocity = 0
  end

  -- Apply friction to all sprites
  self:applyFriction(dt)

  self.body:setLinearVelocity(self.x_velocity, self.y_velocity)

  
  -- if category == Categories.DEADBOY then
  --   if (self.y_velocity == 0) and (self.x_velocity == 0) then
  --     self.body:setType("static")
  --   end
  -- end
end

function Bulb:applyFriction(dt)
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

function Bulb:applyGravity(dt)
  self.y_velocity = self.y_velocity + self.gravity * dt
end



function Bulb:draw()
  local x, y = self.body:getPosition()
  love.graphics.setColor({ 1, 1, 1 })

  local scale_x = Bulb.width / self.image:getWidth()
  local scale_y = Bulb.height / self.image:getHeight()
  love.graphics.draw(self.image, x, y, 0, scale_x, scale_y, self.image:getWidth() / 2, self.image:getHeight() / 2, 0, 0)
end

function Bulb:beginContact(a, b, contact)
  print("beginContact")
  local normal_x, normal_y = contact:getNormal()
  local coll = { fixture_a = a, fixture_b = b, normal_x = normal_x, normal_y = normal_y }
  if IsOnTop(a, b, self.fixture, normal_y) then self:stopVerticalMotion() end
  table.insert(self.collisions, coll)
end

function Bulb:endContact(a, b, contact)
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

function Bulb:stopVerticalMotion()
  self.y_velocity = 0
end

function Bulb:isOnSurface()

  local on_top = false

  for _, collision in ipairs(self.collisions) do
    if IsOnTop(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
      on_top = true
    end
  end
  
  return on_top
  
end

--- ----------------------------------------------------------------------------------------------------------------------

-- Bulb.update = function(dt)
--   if love.keyboard.isDown("right") then
--     Ball.body:applyForce(400, 0)
--   elseif love.keyboard.isDown("left") then
--     Ball.body:applyForce(-400, 0)
--   elseif love.keyboard.isDown("up") then
--     Ball.body:applyForce(0, -400)
--   elseif love.keyboard.isDown("down") then
--     Ball.body:applyForce(0, 400)
--   end
-- end

-- Ball.draw = function()
--   love.graphics.setColor(0.76, 0.18, 0.05)
--   love.graphics.circle("fill", Ball.body:getX(), Ball.body:getY(), Ball.shape:getRadius())
-- end
