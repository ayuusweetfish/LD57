local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H

  local btn = button(
    draw.get('intro_bg'),
    function () end,
    H * 0.1 / 300
  )
  btn.x = W * 0.5
  btn.y = H * 0.65
  local buttons = { btn }

  s.press = function (x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
  end

  s.release = function (x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end
  end

  s.update = function ()
    for i = 1, #buttons do buttons[i].update() end
  end

  s.draw = function ()
    love.graphics.clear(0.99, 0.99, 0.98)
    love.graphics.setColor(1, 1, 1)

    for i = 1, #buttons do buttons[i].draw() end
  end

  s.destroy = function ()
  end

  return s
end
