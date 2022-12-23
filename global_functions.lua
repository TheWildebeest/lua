function MAIN_MENU()
  if Sounds.level_1_music:isPlaying() then Sounds.level_1_music:stop() end
  if Sounds.win_music:isPlaying() then Sounds.win_music:stop() end
  WIN = false
  MENU = true
  Sounds.menu_music:play()
  if Menu.SHOW_CONTROLS then Menu:toggleControls() end
end

function WIN_GAME()
  if Sounds.level_1_music:isPlaying() then Sounds.level_1_music:stop() end
  Sounds.win_music:play()
  WIN = true
end

function EXIT_GAME()
  love.event.push("quit")
end