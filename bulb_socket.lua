Socket = Object:extend()

-- Static properties/methods

Socket.width = love.physics:getMeter() * 2.5
Socket.height = love.physics:getMeter() * 2.35

function Socket:init(environment, world)
  self.image = love.graphics.newImage("assets/img/socket.png")
  self.scale = Socket.width / self.image:getWidth()
  self.body =  love.physics.newBody(world, environment.screen_width / 2, Socket.height / 2, "static")
  self.shape = love.physics.newPolygonShape(0,0, Socket.width / 2,Socket.height / 2, -Socket.width / 2, Socket.height / 2)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.collisions = { }
end

function Socket:new(environment, world)
  self:init(environment, world)
end

-- function Socket:update(dt)
--   self:checkCollisions()
--   return nil
-- end

function Socket:beginContact(a, b, contact)
  local normal_x, normal_y = contact:getNormal()
  local x1, y1, x2, y2 = contact:getPositions()

  local x_contact = false
  local y_contact = false

  if x1 ~= nil then
    local current = math.round(x1)
    local target = math.round(love.graphics.getWidth() / 2) 
    print("x1: ", current, "Aim: ", target)
    if ((target - 10) <= (current)) and ((current) <= (target + 10)) then
      x_contact = true
      print("X contact: ", x_contact)
    end
  end

  if y1 ~= nil then
    local current = math.round(y1)
    local target = math.round(self.image:getHeight() * self.scale)
    if ((target - 2) <= (current)) and ((current) <= (target + 2)) then
      y_contact = true
    end
  end

  if x2 ~= nil then
    local current = math.round(x2)
    local target = math.round(love.graphics.getWidth() / 2) 
    print("x2: ", current, "Aim: ", target)
    if ((target - 10) <= (current)) and ((current) <= (target + 10)) then
      x_contact = true
      print("X contact: ", x_contact)
    end
  end

  if y2 ~= nil then
    local current = math.round(y2)
    local target = math.round(self.image:getHeight() * self.scale)
    if ((target - 2) <= (current)) and ((current) <= (target + 2)) then
      y_contact = true
    end
  end

  if y_contact and x_contact then
    print("You win!!!")
    WIN = true
  end

end

function Socket:draw()
  love.graphics.draw(self.image, self.body:getX(), self.body:getY(), 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2, 0, 0)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end
