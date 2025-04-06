local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H

  ------ Display ------
  local radar_x, radar_y = W * 0.5, H * 0.42
  local radar_r = H * 0.3

  ------ Game state ------
  local T = 0

  local ant_ori = 0
  local ori_step = math.pi * 2 / 8 / 240
  local ant_sector = 0
  local ant_sector_last, ant_sector_anim = ant_sector, 0
  local SECTOR_ANIM_DUR = 40

  local sel_sym = 1

  local LEVER_COOLDOWN = 240
  local T_last_lever = -LEVER_COOLDOWN

  ------ Buttons ------
  local buttons = { }

  -- Symbol buttons
  local sym_btns = {}
  local refresh_sym_btns

  local select_sym = function (i)
    sel_sym = i
    refresh_sym_btns()
  end
  refresh_sym_btns = function ()
    for i = 1, #sym_btns do
      sym_btns[i].set_drawable(
        draw.get('icon_sym_' .. tostring(i) .. (sel_sym == i and '_sel' or '')))
    end
  end
  for i = 1, 3 do
    local btn = button(
      draw.get('icon_sym_' .. tostring(i)),
      function () select_sym(i) end,
      H * 0.1
    )
    btn.x = W * (0.5 + (i - 2) * 0.15)
    btn.y = H * 0.8
    sym_btns[i] = btn
    buttons[#buttons + 1] = btn
  end
  refresh_sym_btns()

  -- Lever button
  local pull_lever
  local btn_lever = button(
    draw.get('intro_bg'),
    function () pull_lever() end,
    W * 0.1
  )
  btn_lever.x = W * 0.78
  btn_lever.y = H * 0.5
  buttons[#buttons + 1] = btn_lever

  pull_lever = function ()
    if T < T_last_lever + LEVER_COOLDOWN then return end
    btn_lever.set_drawable(draw.get('nn_01'))
    T_last_lever = T
  end

  ------ Scene methods ------

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

  s.key = function (key)
    if key == '1' then select_sym(1)
    elseif key == '2' then select_sym(2)
    elseif key == '3' then select_sym(3)
    elseif key == 'return' then pull_lever()
    end
  end

  s.update = function ()
    T = T + 1
    for i = 1, #buttons do buttons[i].update() end

    -- `ant_sector_last` is for animation,
    -- here we do a backup to check whether sector changed
    local ant_sector_backup = ant_sector
    if love.keyboard.isDown('left') then
      ant_ori = ant_ori - ori_step
      if ant_ori < 0 then ant_ori = ant_ori + math.pi * 2 end
      ant_sector = math.floor(ant_ori / (math.pi * 2 / 8) + 0.5) % 8
    end
    if love.keyboard.isDown('right') then
      ant_ori = ant_ori + ori_step
      if ant_ori >= math.pi * 2 then ant_ori = ant_ori - math.pi * 2 end
      ant_sector = math.floor(ant_ori / (math.pi * 2 / 8) + 0.5) % 8
    end
    if ant_sector_backup ~= ant_sector then
      ant_sector_last = ant_sector_backup
      ant_sector_anim = SECTOR_ANIM_DUR
    end

    if T <= T_last_lever + LEVER_COOLDOWN then
      if T == T_last_lever + LEVER_COOLDOWN then
        btn_lever.set_drawable(draw.get('intro_bg'))
      end
    end

    if ant_sector_anim > 0 then
      ant_sector_anim = ant_sector_anim - 1
    end
  end

  s.draw = function ()
    love.graphics.clear(0.99, 0.99, 0.98)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', radar_x, radar_y, radar_r)

    local sector = function (n)
      love.graphics.arc('fill', radar_x, radar_y, radar_r,
        (n - 0.5) * math.pi * 2 / 8,
        (n + 0.5) * math.pi * 2 / 8
      )
    end
    local sector_alpha = 1
    if ant_sector_anim > 0 then
      local x = ant_sector_anim / SECTOR_ANIM_DUR
      local last_alpha = x ^ 0.8
      sector_alpha = (1 - x) ^ 0.8
      love.graphics.setColor(0.5, 0.5, 0.5, last_alpha * 0.3)
      sector(ant_sector_last)
    end
    love.graphics.setColor(0.5, 0.5, 0.5, sector_alpha * 0.3)
    sector(ant_sector)

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
