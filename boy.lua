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
  return love.physics.newCircleShape(Boy.headRadius)
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
  self.base_color = Boy.default_base_color
  self.highlight_color = Boy.default_highlight_color
  self.color = self.base_color
  self.can_jump = false
end

function Boy:update(dt, walls, world)
  local cat1, cat2 = self.torsoFixture:getCategory()
  if cat1 == Categories.DEADBOY or cat2 == Categories.DEADBOY then return end
  if cat1 == Categories.LIVEBOY or cat2 == Categories.LIVEBOY then
    self.color = self.base_color
    
    -- Move right
    if love.keyboard.isDown("d") then
      self.torsoBody:applyForce(dt * 100000, 0)
      self.color = self.highlight_color
    end
    
    -- Move left
    if love.keyboard.isDown("a") then
      self.torsoBody:applyForce(dt * -100000, 0)
      self.color = self.highlight_color
    end
    
    -- Jump
    if love.keyboard.isDown("space") then
      self.can_jump = false
      local contacts = self.torsoBody:getContacts()
      for _, each in ipairs(contacts) do
        local x1, y1, x2, y2 = each:getPositions()
        if x1 ~= nil and x2 ~= nil and y1 ~= nil and y1 ~= nil then
          if math.floor(y1) == math.floor(y2) and math.floor(x1) ~= math.floor(x2) then self.can_jump = true end
          -- print(x1, y1, x2, y2)
        end
      end
      if self.torsoBody:isTouching(walls.bottom.body) then self.can_jump = true end

      -- if self.body:isTouching(walls.bottom.body) then
      if self.can_jump then
        -- print("LIVEBOY can jump")
        self.torsoBody:applyForce(0, dt * -1000000)
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
  love.graphics.circle("fill", self.headBody:getX(), self.headBody:getY(), Boy.headRadius)
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
  self.torsoShape = Boy.initTorsoShape()
  self.headBody = Boy.initHeadBody(environment, world)
  self.headShape = Boy.initHeadShape()
  self.torsoFixture = love.physics.newFixture(self.torsoBody, self.torsoShape)
  self.headFixture = love.physics.newFixture(self.headBody, self.headShape)
  self.torsoFixture:setDensity(1)
  self.torsoFixture:setFriction(0.9)
  self.torsoFixture:setCategory(Categories.OBJECT, Categories.LIVEBOY)
  self.headFixture:setDensity(0)
  self.headFixture:setFriction(0)
  self.headFixture:setRestitution(2)
  self.headFixture:setCategory(Categories.OBJECT, Categories.LIVEBOY)
  self.neck = love.physics.newWeldJoint(self.headBody, self.torsoBody, environment.wall_thickness + environment.screen_width * 0.05, environment.wall_thickness + environment.screen_width * 0.05, true)
end

function Boy:reset(environment, world)
  self.fixture:destroy()
  self.body:destroy()
  self:init(environment, world)
end