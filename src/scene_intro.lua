local draw = require 'draw_utils'
local button = require 'button'
local audio = require 'audio'

return function ()
  local s = {}
  local W, H = W, H

  local T = 0
  local since_press = -1

  local start_game = function ()
    if since_press < 0 then
      audio.sfx('ad_astra_morse')
      since_press = 0
    end
  end

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
    start_game()
  end

  s.key = function (key)
    if key == 'return' then start_game() end
  end

  s.update = function ()
    T = T + 1
    if since_press >= 0 then
      since_press = since_press + 1
      if since_press == 480 then
        replaceScene(scene_gameplay(1), transitions['crossfade']())
      end
    end
  end

  s.draw = function ()
    love.graphics.clear(0, 0, 0)

    love.graphics.setColor(1, 1, 1)
    draw.img('ending/bg_int', W / 2, H / 2, W, H)
    love.graphics.setColor(0.22, 0.38, 0.22)
    local noise_frame = 1 + math.floor(T / 20) % 10
    draw.img('noise/' .. noise_frame, W / 2, (111 + 630/2) * (2/3))

    love.graphics.setColor(1, 1, 1)
    draw.img('intro/bg', W / 2, H / 2, W, H)

    local progress = math.max(0, math.min(1, since_press / 400))
    local delta_y = progress * progress * progress
    draw.img('intro/fg', W / 2, 460 / 720 * H + H * 0.62 * delta_y)
  end

  s.destroy = function ()
  end

  return s
end
