Socket = Object:extend()

-- Static properties/methods

Socket.width = love.physics:getMeter() * 2.5
Socket.height = love.physics:getMeter() * 2.35

function Socket:init(environment, world)
  self.image = love.graphics.newImage("assets/img/socket.png")
  self.scale = 1
  self.body =  love.physics.newBody(world, environment.screen_width / 2, 0, "static")
  self.shape = love.physics.newPolygonShape(Socket.width / 2, Socket.height / 2, Socket.width, Socket.height, 0, Socket.height)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.collisions = { }
end

function Socket:new(environment, world)
  self:init(environment, world)
end

function Socket:update(dt)
  self:checkCollisions()
  return nil
end

function Socket:checkCollisions()
  return nil
end

function Socket:draw()
  love.graphics.draw(self.image, self.body:getX(), self.body:getY(), 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2, 0, 0)
end
