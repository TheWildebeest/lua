Bulb = Object:extend()

-- Static properties/methods

Bulb.width = love.physics:getMeter() * 1
Bulb.vertices = {150,0, 250,200, 250,300, 150,350, 100,350, 0,300, 0,200, 100,0}
Bulb.on = love.graphics.newImage("assets/img/bulb/on.png")
Bulb.off = love.graphics.newImage("assets/img/bulb/off.png")

-- `Static`
Bulb.initBody = function (world, x, y)
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setBullet(true)
  return body
end

-- `Static`
Bulb.initShape = function (scale)
  local vertices = table.map(function (x) return x * scale end, Bulb.vertices)
  local polygon = love.physics.newPolygonShape(unpack(vertices))
  return polygon
end

-- `Static`
Bulb.updateAll = function(allBulbz, dt)
  for _, each in ipairs(allBulbz) do
    each:update(dt)
  end
end

function Bulb:init(world, x, y, direction)
  local x_velocity = 0
  if direction == "left" then x_velocity = -1200 else x_velocity = 1200 end
  self.scale = Bulb.width / Bulb.on:getWidth()
  self.body = Bulb.initBody(world, x, y)
  self.body:setLinearVelocity(x_velocity, -900)
  self.shape = Bulb.initShape(self.scale)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(0)
  self.fixture:setFriction(0.1)
  self.fixture:setCategory(Categories.BULB)
  self.fixture:setMask(Categories.DEADBOY)
 
  -- print('Bulb scale: ', self.scale)
  self.fixture:setDensity(0)
  -- self.body:setMass(0.1)
  self.collisions = { }

  self.x_velocity = 1500
  self.y_velocity = -1000
  self.gravity = 1500 -- 3500
  self.max_speed = 200 -- 10000
  self.acceleration = 4000
  self.friction = 3500

  self.body:setFixedRotation(false)

end

function Bulb:new(world, x, y, direction)
  self:init(world, x, y, direction)
  self.base_color = { math.random(), math.random(), math.random() }
  self.color = self.base_color
end

-- function Bulb:update(dt)
--   -- Apply gravity to all airborne sprites
--   if not self:isOnSurface() then
--     self:applyGravity(dt)
--   end

--   if self:isOnSurface() and self.y_velocity > 0 then
--     self:stopVerticalMotion()
--   end

--   if self:isBeneathSurface() and self.y_velocity < 0 then
--     self:stopVerticalMotion()
--   end

--   -- Apply friction to all sprites
--   self:applyFriction(dt)
--   self.body:setLinearVelocity(self.x_velocity, self.y_velocity)
-- end

-- function Bulb:applyFriction(dt)
--   if self.x_velocity > 0 then
--     if self.x_velocity - self.friction * dt > 0 then
--       self.x_velocity = self.x_velocity - self.friction * dt
--     else
--       self.x_velocity = 0
--     end
--   elseif self.x_velocity < 0 then
--     if self.x_velocity + self.friction * dt < 0 then
--       self.x_velocity = self.x_velocity + self.friction * dt
--     else
--       self.x_velocity = 0
--     end
--   end
-- end

-- function Bulb:applyGravity(dt)
--   self.y_velocity = self.y_velocity + self.gravity * dt
-- end

function Bulb:draw()
  local img = Bulb.off
  if #self.body:getJoints() > 0 then
    img = Bulb.on
  end
  --   color = Colors.bulb_on
  -- end
  -- love.graphics.setColor(color)

  local x, y = self.body:getWorldCenter()
  -- love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))

  love.graphics.setColor({ 1, 1, 1 })
  love.graphics.draw(img, x, y, self.body:getAngle(), self.scale, self.scale, img:getWidth() / 2, img:getHeight() / 2, 0, 0)
end

-- function Bulb:keypressed()
--   return nil
-- end

-- function Bulb:beginContact(a, b, contact)
--   -- print("beginContact")
--   local normal_x, normal_y = contact:getNormal()
--   local coll = { fixture_a = a, fixture_b = b, normal_x = normal_x, normal_y = normal_y }
--   table.insert(self.collisions, coll)

--   -- If the bulb has landed on a surface, reset y velocity to 0
--   if IsAbove(a, b, self.fixture, normal_y) or IsStationaryObjectCollision(a, b, self.fixture) then
--     self:stopVerticalMotion()
--   end

-- end

-- function Bulb:endContact(a, b, contact)
--   -- print("endContact")

--   local index = nil

--   for i, collision_data in ipairs(self.collisions) do
--     if a == collision_data.fixture_a and b == collision_data.fixture_b then
--       index = i
--     elseif a == collision_data.fixture_b and b == collision_data.fixture_a then
--       index = i
--     end
--   end

--   if index then
--     table.remove(self.collisions, index)
--   end

-- end

-- function Bulb:stopVerticalMotion()
--   self.y_velocity = 0
-- end

-- function Bulb:isOnSurface()

--   local on_top = false

--   for _, collision in ipairs(self.collisions) do
--     if IsAbove(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
--       on_top = true
--     end
--   end
  
--   return on_top
  
-- end

-- function Bulb:isBeneathSurface()

--   local beneath = false

--   for _, collision in ipairs(self.collisions) do
--     if IsBeneath(self.fixture, collision.fixture_a, collision.fixture_b, collision.normal_y) then
--       beneath = true
--     end
--   end
  
--   return beneath
  
-- end

--- ----------------------------------------------------------------------------------------------------------------------