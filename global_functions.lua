function MAIN_MENU()
  if Sounds.level_1_music:isPlaying() then Sounds.level_1_music:stop() end
  WIN = false
  MENU = true
  Sounds.menu_music:play()
  if Menu.SHOW_CONTROLS then Menu:toggleControls() end
end

function WIN_GAME()
  WIN = true
end

function EXIT_GAME()
  love.event.push("quit")
end