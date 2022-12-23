SoundTypes = {}
SoundTypes.SFX = 'static'
SoundTypes.MUSIC = 'stream'

Sounds = Object:extend()
Sound = Object:extend()

function Sound:new(audioType, source)
  if type(source) == 'string' then
    local audio = love.audio.newSource(source, audioType)
    self.src = audio
    return
  end

  if type(source) == 'table' then
    local sources = {}
    for _, v in pairs(source) do
      local audio = love.audio.newSource(v, audioType)
      table.insert(sources, audio)
    end
    self.src = sources
  end
end

function Sound:play()
  local sourceToPlay = nil
  local sourceToStop = nil

  if type(self.src) == 'table' then
    local index = math.random(#self.src)
    for i, v in pairs(self.src) do
      if v:isPlaying() and (not v:isLooping()) then sourceToStop = v end
      if i == index then sourceToPlay = v end
    end
  else
    if self.src:isPlaying() and (not self.src:isLooping()) then sourceToStop = self.src end
    sourceToPlay = self.src
  end
  if sourceToStop then sourceToStop:stop() end
  sourceToPlay:play()
end

function Sound:isPlaying()
  local isPlaying = false
  if type(self.src) == 'table' then
    for i, v in pairs(self.src) do
      if v:isPlaying() then isPlaying = true end
    end
  else
    isPlaying = self.src:isPlaying()
  end
  return isPlaying
end

function Sound:pause()
  if type(self.src) == 'table' then
    for i, v in pairs(self.src) do
      if v:isPlaying() then v:pause() end
    end
  else
    self.src:pause()
  end
end

function Sound:stop()
  if type(self.src) == 'table' then
    for i, v in pairs(self.src) do
      if v:isPlaying() then v:stop() end
    end
  else
    self.src:stop()
  end
end

function Sound:setLooping(shouldLoop)

  if type(self.src) == 'table' then
    for _, v in pairs(self.src) do
      v:setLooping(shouldLoop)
    end
  else
    self.src:setLooping(shouldLoop)
  end
end

function Sounds:new()

  -- Music
  local menu_music = Sound(SoundTypes.MUSIC, 'assets/audio/menu_music.wav')
  menu_music:setLooping(true)
  Sounds.menu_music = menu_music

  local level_1_music = Sound(SoundTypes.MUSIC, 'assets/audio/level_1_music.wav')
  level_1_music:setLooping(true)
  Sounds.level_1_music = level_1_music

  local win_music = Sound(SoundTypes.MUSIC, 'assets/audio/win_music.wav')
  win_music:setLooping(true)
  Sounds.win_music = win_music

  -- SFX

  -- Landing impact
  local landing_impact = {
    light = Sound(SoundTypes.SFX, 'assets/audio/land_impact_light.wav'),
    mid = Sound(SoundTypes.SFX, 'assets/audio/land_impact_mid.wav'),
    heavy = Sound(SoundTypes.SFX, 'assets/audio/land_impact_heavy.wav')
  }
  Sounds.landing_impact = landing_impact

  -- Landing effort
  local landing_effort_light_files = {}
  for i = 1, 5, 1 do landing_effort_light_files[i] = 'assets/audio/land_effort_light_'..i..'.wav' end
  local landing_effort_mid_files = {}
  for i = 1, 5, 1 do landing_effort_mid_files[i] = 'assets/audio/land_effort_mid_'..i..'.wav' end
  local landing_effort_heavy_files = {}
  for i = 1, 11, 1 do landing_effort_heavy_files[i] = 'assets/audio/land_effort_heavy_'..i..'.wav' end

  local landing_effort = {
    light = Sound(SoundTypes.SFX, landing_effort_light_files),
    mid = Sound(SoundTypes.SFX, landing_effort_mid_files),
    heavy = Sound(SoundTypes.SFX, landing_effort_heavy_files)
  }
  Sounds.landing_effort = landing_effort

  -- Change lightbulb
  local change_lightbulb_files = {}
  for i = 1, 9, 1 do change_lightbulb_files[i] = 'assets/audio/throw'..i..'.wav' end
  local change_lightbulb = Sound(SoundTypes.SFX, change_lightbulb_files)
  Sounds.change_lightbulb = change_lightbulb

  -- Jump
  local jump_files = {}
  for i = 1, 5, 1 do jump_files[i] = 'assets/audio/jump'..i..'.wav' end
  local jump = Sound(SoundTypes.SFX, jump_files)
  Sounds.jump = jump

end

function Sounds:load()
  return Sounds()
end