function table.map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

function math.round(num)
  if num >= 0 then
    return math.floor(num+.5)
  else
    return math.ceil(num-.5)
  end
end

function IsDirectionKey(key)
  return (
    key == 'w' or
    key == 'a' or
    key == 's' or
    key == 'd' or
    key == 'up' or
    key == 'left' or
    key == 'down' or
    key == 'right'
  )
end