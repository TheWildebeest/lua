require "objects"
Boundaries = Object:extend()

function Boundaries:new(environment, world)
  self.bottom = NewObject("static", "rectangle", world, environment.screen_width / 2, environment.screen_height * 0.95, environment.screen_width, environment.screen_height * 0.1)
  self.top = NewObject("static", "rectangle", world, environment.screen_width / 2, environment.wall_thickness / 2, environment.screen_width, environment.wall_thickness)
  self.left = NewObject("static", "rectangle", world, environment.wall_thickness / 2, environment.screen_height / 2, environment.wall_thickness, environment.screen_height)
  self.right = NewObject("static", "rectangle", world, environment.screen_width - (environment.wall_thickness / 2), environment.screen_height / 2, environment.wall_thickness, environment.screen_height)
  self.color = { 0.5, 0.5, 0.5 }
end

function Boundaries:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon("fill", self.top.body:getWorldPoints(self.top.shape:getPoints()))
  love.graphics.polygon("fill", self.bottom.body:getWorldPoints(self.bottom.shape:getPoints()))
  love.graphics.polygon("fill", self.left.body:getWorldPoints(self.left.shape:getPoints()))
  love.graphics.polygon("fill", self.right.body:getWorldPoints(self.right.shape:getPoints()))
end