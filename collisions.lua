Collisions = {}

function Collisions.beginContact(a, b, collision)
  for _, boy in ipairs(AllBoyz) do
    if boy ~= nil and collision ~= nil then
      boy:beginContact(a, b, collision)
    end
  end
end

function Collisions.endContact(a, b, collision)
  for _, boy in ipairs(AllBoyz) do
    if boy ~= nil and collision ~= nil then
      boy:endContact(a, b, collision)
    end
  end
end

function Collisions.preSolve(a, b, collision)
  print(a, b, collision)

end

function Collisions.postSolve(a, b, collision, normalimpulse, tangentimpulse)
  print(a, b, collision, normalimpulse, tangentimpulse)

end

return Collisions

-- https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks -- this is what I need to add sounds on collision events