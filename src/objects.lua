function NewObject(body_type, shape_type, world, x_pos, y_pos, width, height)
  local object = {}
  object.body = love.physics.newBody(world, x_pos, y_pos, body_type)
  if shape_type == "rectangle" then
    object.shape = love.physics.newRectangleShape(width, height)
  elseif shape_type == "circle" then
    object.shape = love.physics.newCircleShape(width)
  end
  object.fixture = love.physics.newFixture(object.body, object.shape)
  return object
end
