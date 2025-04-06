local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H

  ------ Display ------
  local radar_x, radar_y = W * 0.5, H * 0.42
  local radar_r = H * 0.3

  ------ Game state ------
  local ant_ori = 0
  local ori_step = math.pi * 2 / 8 / 240

  local sel_sym = 1

  ------ Buttons ------
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
    btn.x = W * (0.5 + (i - 2) * 0.15)
    btn.y = H * 0.8
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

    if love.keyboard.isDown('left') then
      ant_ori = ant_ori - ori_step
      if ant_ori < 0 then ant_ori = ant_ori + math.pi * 2 end
    end
    if love.keyboard.isDown('right') then
      ant_ori = ant_ori + ori_step
      if ant_ori >= math.pi * 2 then ant_ori = ant_ori - math.pi * 2 end
    end
  end

  s.draw = function ()
    love.graphics.clear(0.99, 0.99, 0.98)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', radar_x, radar_y, radar_r)

    love.graphics.setColor(0, 0, 0)
    love.graphics.line(radar_x, radar_y,
      radar_x + radar_r * math.cos(ant_ori),
      radar_y + radar_r * math.sin(ant_ori))
    love.graphics.setColor(1, 1, 1)
    draw.img('nn_01',
      radar_x + radar_r * math.cos(ant_ori),
      radar_y + radar_r * math.sin(ant_ori),
      H * 0.1, nil, 1, 0.5, ant_ori
    )

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end
  end

  s.destroy = function ()
  end

  return s
end
