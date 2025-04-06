local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H

  -- Game state
  local ant_ori = 0
  local sel_sym = 1

  local buttons = { }

  local sym_btns = {}

  local refresh_sym_btns = function ()
    for j = 1, #sym_btns do
      sym_btns[j].set_drawable(
        draw.get(sel_sym == j and 'nn_01' or 'intro_bg'))
    end
  end
  for i = 1, 3 do
    local btn = button(
      draw.get('intro_bg'),
      function ()
        sel_sym = i
        refresh_sym_btns()
      end,
      H * 0.1 / 300
    )
    btn.x = W * (0.5 + (i - 2) * 0.27)
    btn.y = H * 0.65
    sym_btns[i] = btn
    buttons[#buttons + 1] = btn
  end
  refresh_sym_btns()

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
