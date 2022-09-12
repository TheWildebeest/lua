Environment = Object:extend()

function Environment:new(screen_width, screen_height, fullscreen, debug)
  self.screen_width = screen_width
  self.screen_height = screen_height
  self.fullscreen = fullscreen
  self.wall_thickness = 16
  self.spacer = screen_width * 0.02
  self.meter = screen_width * 0.1
  self.use_ball = debug

  if self.fullscreen then love.window.setFullscreen(true, "exclusive") end
end

function Environment:update(dt, screen_width, screen_height)
  self.screen_width = screen_width
  self.screen_height = screen_height
end
