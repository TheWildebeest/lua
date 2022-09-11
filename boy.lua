Boy = Object:extend()

-- Static properties/methods

-- `Static`
Boy.headRadius = 25


-- `Static`
Boy.initHeadBody = function (environment, world)
  return love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.025, "dynamic")
end

-- `Static`
Boy.initHeadShape = function ()
  -- return love.physics.newCircleShape(Boy.headRadius)
  return love.physics.newRectangleShape(0, 0, 50, 45)
end

-- `Static`
Boy.initTorsoBody = function (environment, world)
  return love.physics.newBody(world, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.075, "dynamic")
end

-- `Static`
Boy.initTorsoShape = function ()
  return love.physics.newRectangleShape(0, 0, 50, 75)
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
  self.can_jump = false
end

function Boy:update(dt, walls, world)
  local cat1, cat2 = self.torsoFixture:getCategory()
  if cat1 == Categories.DEADBOY or cat2 == Categories.DEADBOY then return end
  if cat1 == Categories.LIVEBOY or cat2 == Categories.LIVEBOY then
    self.color = self.base_color

    local torso_x, torso_y = self.torsoBody:getLinearVelocity()
    local head_x, head_y = self.headBody:getLinearVelocity()
    
    -- Move right
    if love.keyboard.isDown("d") then
      self.torsoBody:setLinearVelocity(dt * 40000, torso_y)
      self.headBody:setLinearVelocity(dt * 40000, head_y)
      -- self.torsoBody:applyForce(, 0)
      self.color = self.highlight_color

    -- Move left
    elseif love.keyboard.isDown("a") then
      self.torsoBody:setLinearVelocity(dt * -40000, torso_y)
      self.headBody:setLinearVelocity(dt * -40000, head_y)
      -- self.torsoBody:applyForce(dt * -100000, 0)
      self.color = self.highlight_color

    else
      self.torsoBody:setLinearVelocity(0, torso_y)
      self.headBody:setLinearVelocity(0, head_y)
    end
    
    -- Jump
    if love.keyboard.isDown("space") then
      self.can_jump = false
      local is_on_surface = false
      local contacts = self.torsoBody:getContacts()

      for _, each in ipairs(contacts) do
        local x1, y1, x2, y2 = each:getPositions()
        if x1 ~= nil and x2 ~= nil and y1 ~= nil and y1 ~= nil then
          if (math.floor(y1) == math.floor(y2)) and (math.floor(x1) ~= math.floor(x2)) and not self.headBody:isTouching(walls.top.body) then
            is_on_surface = true
          end
        end
      end

      if self.torsoBody:isTouching(walls.bottom.body) or is_on_surface then
        self.can_jump = true
        self.torsoBody:setLinearVelocity(torso_x, 0)
        self.headBody:setLinearVelocity(head_x, 0)
      else
        self.can_jump = false
      end

      -- if self.body:isTouching(walls.bottom.body) then
      if self.can_jump then
        -- print("LIVEBOY can jump")
        x, y = self.torsoBody:getLinearVelocity()
        self.torsoBody:setLinearVelocity(x, -90000 * dt)
      else
        local contacts = self.torsoBody:getContacts()
        for _, each in ipairs(contacts) do
          local x1, y1, x2, y2 = each:getPositions()
            -- print(x1, y1, x2, y2)
        end
        local top_left, top_right, bottom_right, bottom_left = self.torsoBody:getWorldPoints(self.torsoShape:getPoints())
      end
      self.color = self.highlight_color
    end
  end
end
  

function Boy:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon("fill", self.headBody:getWorldPoints(self.headShape:getPoints()))
  love.graphics.polygon("fill", self.torsoBody:getWorldPoints(self.torsoShape:getPoints()))
end

function Boy:keypressed(key, _, isrepeat)
  if key == "x" then
    if not isrepeat then
    local cat1, cat2 = self.torsoFixture:getCategory()
    if cat1 == Categories.LIVEBOY or cat2 == Categories.LIVEBOY then
        self.torsoFixture:setCategory(Categories.OBJECT, Categories.DEADBOY)
        self.headFixture:setCategory(Categories.OBJECT, Categories.DEADBOY)
      end
    end
  end
end

function Boy:init(environment, world)
  self.torsoBody = Boy.initTorsoBody(environment, world)
  self.torsoBody:setFixedRotation(true)
  self.torsoBody:setLinearDamping(0)
  self.torsoBody:setAngularDamping(0)
  self.torsoBody:setMass(0)
  self.headBody = Boy.initHeadBody(environment, world)
  self.headBody:setFixedRotation(true)
  self.headBody:setLinearDamping(0)
  self.headBody:setAngularDamping(0)
  self.headBody:setMass(0)
  self.torsoShape = Boy.initTorsoShape()
  self.headShape = Boy.initHeadShape()
  self.torsoFixture = love.physics.newFixture(self.torsoBody, self.torsoShape)
  self.headFixture = love.physics.newFixture(self.headBody, self.headShape)
  self.torsoFixture:setDensity(0)
  self.torsoFixture:setFriction(10)
  self.torsoFixture:setCategory(Categories.OBJECT, Categories.LIVEBOY)
  self.headFixture:setDensity(0)
  self.headFixture:setFriction(5)
  self.headFixture:setRestitution(-0.5)
  self.torsoFixture:setRestitution(-0.5)
  self.headFixture:setCategory(Categories.OBJECT, Categories.LIVEBOY)
  self.neck = love.physics.newDistanceJoint(self.headBody, self.torsoBody, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.04, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.02, false)

  local x, y, mass, inertia = self.torsoBody:getMassData()
  print(x,y,mass,inertia)
  -- self.torsoBody:setMassData(5, 5, 0.5, 200)

end

function Boy:reset(environment, world)
  self.fixture:destroy()
  self.body:destroy()
  self:init(environment, world)
end