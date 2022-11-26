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
    print('source is table')
    local index = math.random(#self.src)
    for i, v in pairs(self.src) do
      if v:isPlaying() and (not v:isLooping()) then sourceToStop = v end
      if i == index then sourceToPlay = v end
    end
  else
    if self.src:isPlaying() and (not self.src:isLooping()) then sourceToStop = self.src end
    sourceToPlay = self.src
  end
  if sourceToStop then sourceToStop:seek(0) end
  sourceToPlay:play()
end

function Sound:pause()
  local source = self.src
  source:pause()
end

function Sound:setLooping(shouldLoop)

  if type(self.src) == 'table' then
    for _, v in pairs(self.src) do
      v:setLooping(shouldLoop)
    end
  else
    print('Setting looping to true')
    self.src:setLooping(shouldLoop)
  end
end

function Sounds:new()

  -- Music
  local music = Sound(SoundTypes.MUSIC, 'assets/audio/menu_music.mp3')
  music:setLooping(true)
  Sounds.music = music

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