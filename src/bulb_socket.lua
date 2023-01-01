Socket = Object:extend()

-- Static properties/methods

Socket.image = love.graphics.newImage("assets/img/socket.png")
Socket.width = love.physics:getMeter() * 2.5
Socket.height = love.physics:getMeter() * 2.35
Socket.joint = nil
Socket.joint_data = nil

function Socket:init(environment, world)
  self.scale = Socket.width / self.image:getWidth()
  self.body =  love.physics.newBody(world, environment.screen_width / 2, Socket.height / 2, "static")
  self.shape = love.physics.newPolygonShape(0,0, Socket.width / 2,Socket.height / 2, -Socket.width / 2, Socket.height / 2)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.collisions = { }
end

function Socket:new(environment, world)
  self:init(environment, world)
end

function Socket:update(dt)
  if (WIN) and (not Socket.joint) and (Socket.joint_data) then
    Socket.joint = love.physics.newRopeJoint(unpack(Socket.joint_data))
  end
end

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
    local target = math.round(Socket.image:getHeight() * self.scale)
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
    local target = math.round(Socket.image:getHeight() * self.scale)
    if ((target - 2) <= (current)) and ((current) <= (target + 2)) then
      y_contact = true
    end
  end

  if y_contact and x_contact then

    local anchor_point_socket_x = ENVIRONMENT.screen_width / 2
    local anchor_point_socket_y = Socket.height

    local body_a_category = a:getCategory()
    local body_b_category = b:getCategory()

    local bulb = nil
    if body_a_category == Categories.BULB then bulb = a:getBody() end
    if body_b_category == Categories.BULB then bulb = b:getBody() end

    if not bulb then return end

    local anchor_point_bulb_x_world, anchor_point_bulb_y_world = bulb:getWorldPoint(Bulb.width / 2, 0)

    Socket.joint_data = {
      SOCKET.body,
      bulb,
      anchor_point_socket_x,
      anchor_point_socket_y,
      anchor_point_bulb_x_world,
      anchor_point_bulb_y_world,
      love.physics:getMeter() / 4,
      false
    }
    WIN_GAME()
  end

  print(a:getCategory())
  print(b:getCategory())

end

function Socket:draw()
  love.graphics.draw(Socket.image, self.body:getX(), self.body:getY(), 0, self.scale, self.scale, Socket.image:getWidth() / 2, Socket.image:getHeight() / 2, 0, 0)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end
