local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['global_font']

  local t1 = love.graphics.newText(font(80), 'Game')

  local btn = button(
    draw.enclose(love.graphics.newText(font(36), 'Start'), 120, 60),
    function () replaceScene(scene_intro(), transitions['fade'](0.1, 0.1, 0.1)) end
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
    love.graphics.clear(0.996, 0.988, 0.878)
    love.graphics.setColor(1, 1, 1)
    draw.img('intro_bg', W / 2, H / 2, W, H)
    draw.shadow(0.1, 0.1, 0.1, 1, t1, W / 2, H * 0.35)

    love.graphics.setColor(0.1, 0.1, 0.1)
    for i = 1, #buttons do buttons[i].draw() end
  end

  s.destroy = function ()
  end

  return s
end
