Collisions = Object:extend()

function Collisions:beginContact(a, b, coll)
  cat1, cat2 = a:getCategory()
  print(cat1, cat2, b, coll)

end

function Collisions:endContact(a, b, coll)
  print(a, b, coll)
end

function Collisions:preSolve(a, b, coll)
  print(a, b, coll)

end

function Collisions:postSolve(a, b, coll, normalimpulse, tangentimpulse)
  print(a, b, coll, normalimpulse, tangentimpulse)

end

return Collisions

-- https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks -- this is what I need to add sounds on collision events