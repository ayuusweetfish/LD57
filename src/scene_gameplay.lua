local draw = require 'draw_utils'
local button = require 'button'

local ease_quad = function (x)
  if x < 0.5 then return x * x * 2
  else return 1 - (1 - x) * (1 - x) * 2 end
end
local ease_quad_out = function (x)
  return 1 - (1 - x) * (1 - x)
end
local ease_quad_in = function (x)
  return x * x
end

local space_responder = function ()
  local o = {}

  local q = {}

  o.send = function (sym)
    q[#q + 1] = {sym, 120}
    q[#q + 1] = {sym == 2 and 2 or 4 - sym, 600}
    table.sort(q, function (a, b) return a[2] < b[2] end)
  end

  -- Returns responded symbol, if any
  o.update = function ()
    if #q > 0 then
      for i = 1, #q do q[i][2] = q[i][2] - 1 end
      if q[1][2] <= 0 then
        return table.remove(q, 1)[1]
      end
    end
  end

  return o
end

-- Knuth-Morris-Pratt's partial match table (failure/next function)
local calc_kmp_next = function (a)
  local next = {[0] = -1, [1] = 0}
  for i = 2, #a do
    local j = next[i - 1]
    while j > 0 and a[i] ~= a[j + 1] do
      j = next[j]
    end
    if a[i] == a[j + 1] then
      j = j + 1
    end
    next[i] = j
  end
  return next
end

return function ()
  local s = {}
  local W, H = W, H

  ------ Display ------
  local radar_x, radar_y = W * 0.5, H * 0.42
  local radar_r = H * 0.3

  ------ Game state ------
  local T = 0

  local N_ORI = 8

  local ant_ori = 0
  local ori_step = math.pi * 2 / N_ORI / 240 * 1.5
  local ant_sector = 0
  local ant_sector_last, ant_sector_anim = ant_sector, 0
  local SECTOR_ANIM_DUR = 40
  local RESP_DISP_DUR = 720

  local sel_sym = 1

  local LEVER_COOLDOWN = 240
  local T_last_lever = -LEVER_COOLDOWN

  local objective_seq = {1, 2, 1, 3, 2}
  local objective_pos = 0
  local objective_next = calc_kmp_next(objective_seq)

  -- Deep space entities!
  local responders = {}
  local responses = {}  -- responses[i] = list of {symbol = number, timestamp = number}
  local transmits = {}  -- Same as above
  for i = 0, N_ORI - 1 do
    responders[i] = space_responder()
    responses[i] = {}
    transmits[i] = {}
  end

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

    -- Send to responder
    responders[ant_sector].send(sel_sym)

    -- Record transmission
    table.insert(transmits[ant_sector], {symbol = sel_sym, timestamp = T})
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
      ant_sector = math.floor(ant_ori / (math.pi * 2 / N_ORI) + 0.5) % N_ORI
    end
    if love.keyboard.isDown('right') then
      ant_ori = ant_ori + ori_step
      if ant_ori >= math.pi * 2 then ant_ori = ant_ori - math.pi * 2 end
      ant_sector = math.floor(ant_ori / (math.pi * 2 / N_ORI) + 0.5) % N_ORI
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

    -- Update all responders and collect responses
    for i = 0, N_ORI - 1 do
      local sym = responders[i].update()
      if sym ~= nil then
        table.insert(responses[i], {symbol = sym, timestamp = T})
        -- Update objective progression
        -- KMP's `next` array
        while objective_pos >= 0 do
          if objective_seq[objective_pos + 1] == sym then
            break
          else
            objective_pos = objective_next[objective_pos]
          end
        end
        objective_pos = objective_pos + 1
        if objective_pos == #objective_seq then
          print('Clear!')
        end
      end
      -- Remove expired ones
      while #responses[i] > 0 and responses[i][1].timestamp < T - RESP_DISP_DUR do
        table.remove(responses[i], 1)
      end
      -- And also transmissions
      while #transmits[i] > 0 and transmits[i][1].timestamp < T - RESP_DISP_DUR do
        table.remove(transmits[i], 1)
      end
    end
  end

  s.draw = function ()
    love.graphics.clear(0.99, 0.99, 0.98)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', radar_x, radar_y, radar_r)

    -- Sector highlight
    local sector = function (n)
      love.graphics.arc('fill', radar_x, radar_y, radar_r,
        (n - 0.5) * math.pi * 2 / N_ORI,
        (n + 0.5) * math.pi * 2 / N_ORI
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

    -- Radar line
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

    -- Sector responses
    local symbol_list = function (rs, i, radius, is_transmit)
      local x = radar_x + radius * math.cos(i * math.pi * 2 / N_ORI)
      local y = radar_y + radius * math.sin(i * math.pi * 2 / N_ORI)
      local offs_x = 0
      local offs = {}
      local scales = {}
      for j = 1, #rs do
        local t = T - rs[j].timestamp
        offs[j] = offs_x
        local s = 1
        if t < 30 then
          local x = t / 30
          s = ease_quad_out(x)
          offs_x = offs_x + ease_quad(x)
        elseif t > RESP_DISP_DUR - 60 then
          local x = 1 - (RESP_DISP_DUR - t) / 60
          s = ease_quad_in(1 - x)
          offs_x = offs_x + 1 - ease_quad(x)
        else
          offs_x = offs_x + 1
        end
        scales[j] = s
      end
      local global_offs = -(offs_x - 1) / 2
      local orth_x = math.sin(-i * math.pi * 2 / N_ORI)
      local orth_y = math.cos(-i * math.pi * 2 / N_ORI)
      if is_transmit then love.graphics.setColor(0, 0, 1)
      else love.graphics.setColor(1, 1, 1) end
      for j = 1, #rs do
        local s = scales[j]
        draw.img('icon_sym_' .. rs[j].symbol,
          x + (offs[j] + global_offs) * 80 * orth_x,
          y + (offs[j] + global_offs) * 80 * orth_y,
          80 * s, 80 * s)
      end
    end
    for i = 0, N_ORI - 1 do
      symbol_list(responses[i], i, radar_r, false)
      symbol_list(transmits[i], i, radar_r * 0.5, true)
    end

    -- Objective sequence
    for i = 1, #objective_seq do
      local x = W * 0.1 + 60 * (i - 1)
      local y = H * 0.12
      love.graphics.setColor(1, 1, 1, i <= objective_pos and 1 or 0.3)
      draw.img('icon_sym_' .. objective_seq[i], x, y, 60, 60)
    end

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end
  end

  s.destroy = function ()
  end

  return s
end
