function BeginContact(a, b, collision)

  for _, boy in ipairs(AllBoyz) do
    if boy ~= nil then
      if a == boy.fixture or b == boy.fixture then
        boy:beginContact(a, b, collision)
      end
    end
  end

  for _, bulb in ipairs(AllBulbz) do
    if bulb ~= nil then
      if a == bulb.fixture or b == bulb.fixture then
        bulb:beginContact(a, b, collision)
      end
    end
  end

end

function EndContact(a, b, collision)

  for _, boy in ipairs(AllBoyz) do
    if boy ~= nil then
      if a == boy.fixture or b == boy.fixture then
        boy:endContact(a, b, collision)
      end
    end
  end

  for _, bulb in ipairs(AllBulbz) do
    if bulb ~= nil then
      if a == bulb.fixture or b == bulb.fixture then
        bulb:endContact(a, b, collision)
      end
    end
  end

end

function PreSolve(a, b, collision)
  print(a, b, collision)

end

function PostSolve(a, b, collision, normalimpulse, tangentimpulse)
  print(a, b, collision, normalimpulse, tangentimpulse)
end

function IsAbove(object, fixture_a, fixture_b, normal_y)
  if fixture_a == object then
    return normal_y > 0
  elseif fixture_b == object then
    return normal_y < 0
  end
end

function IsTouchingStationaryObject(object, fixture_a, fixture_b, normal_y)
  if fixture_a == object then
    return fixture_b:getBody():getLinearVelocity() == 0
  elseif fixture_b == object then
    return fixture_a:getBody():getLinearVelocity() == 0
  end
end

function IsBeneath(object, fixture_a, fixture_b, normal_y)
  if fixture_a == object then
    return normal_y < 0
  elseif fixture_b == object then
    return normal_y > 0
  end
end



-- https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks -- this is what I need to add sounds on collision events