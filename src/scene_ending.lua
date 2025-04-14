local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H

  local T = 0

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
  end

  s.update = function ()
    T = T + 1
  end

  s.draw = function ()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    draw.img('ending/bg_ext', W / 2, H / 2, W, H)
    draw.img('ending/bg_int', W / 2, H / 2, W, H)

    local radar_x, radar_y = W * 0.498, H * 0.367
    -- 630x630+641+81
    local r = T
    draw.img('ending/credits', radar_x, radar_y, nil, nil, nil, nil, T * 0.004)
  end

  s.destroy = function ()
  end

  return s
end
