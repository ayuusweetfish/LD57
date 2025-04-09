local draw = require 'draw_utils'
local button = require 'button'
local audio = require 'audio'

local puzzles = require 'puzzles'

local clamp = function (x, a, b)
  if x < a then return a elseif x > b then return b else return x end
end

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
local ease_sine = function (x)
  return (1 - math.cos(x * math.pi)) * 0.5
end
local ease_pow_out = function (x, n)
  return 1 - (1 - x) ^ n
end
local ease_elastic = function (x, k)
  return (1 - x) * (1 - x) * math.sin(k * x)
end
local ease_stuck_0 = function (x, t)
  -- f(0) = 0, f(1) = 1, f'(0) = 1, f'(1) = 0
  return 1 - (1 - x) * (1 - x) * math.exp(-t * x)
end
local ease_stuck = function (x, t)
  -- f(0) = 0, f(inf) = t, f'(0) = 1, f'(inf) = 0
  return t * (1 - math.exp(-x / t))
end
local ease_stuck_inverse = function (y, t)
  return -t * math.log(1 - y / t)
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

local create_gallery_overlay = function ()
  local o = {}

  local buttons = {}

  -- Local coordinate origin in world coordinates
  local o_x, o_y = W * 0.17, H * 0.6
  -- Local shearing
  local s_x, s_y = 0.1, -0.07

  -- Global offset
  local offs_x = 0
  local offs_y_t = 0

  local anim_t, anim_dir  -- anim_dir = +1: in, 0: none, -1: out
  local is_active

  local n_pages = 18
  local cur_page = 7
  local flip_page = function (delta)
    cur_page = cur_page + delta
    if cur_page < 1 then cur_page = n_pages
    elseif cur_page > n_pages then cur_page = 1 end
  end

  local button_scale = W * 0.22 / draw.get('card'):getWidth()

  local close_button = button(
    draw.get('gallery_book/btn_close'), function () o.close() end, button_scale,
    { drawable_scale_is_absolute = true })
  close_button.x, close_button.y = 2, 186
  buttons[#buttons + 1] = close_button

  local last_button = button(
    draw.extend(draw.get('gallery_book/btn_prev'), 30, 30),
    function () flip_page(-1) end, button_scale,
    { drawable_scale_is_absolute = true })
  last_button.x, last_button.y = -120, 6
  buttons[#buttons + 1] = last_button

  local next_button = button(
    draw.extend(draw.get('gallery_book/btn_next'), 30, 30),
    function () flip_page(1) end, button_scale,
    { drawable_scale_is_absolute = true })
  next_button.x, next_button.y = 120, 7
  buttons[#buttons + 1] = next_button

  o.reset = function ()
    anim_t, anim_dir = 0, 0
    is_active = false
  end
  o.reset()

  o.toggle_open = function ()
    if is_active then
      if anim_dir == 0 then o.close() end
      return
    end
    anim_t, anim_dir = 0, 1
    is_active = true
  end

  o.close = function ()
    anim_t, anim_dir = 0, -1
  end

  o.state = function ()
    return (anim_dir == -1 and 120 - anim_t or anim_t), anim_dir
  end

  o.pull = function (target_offs_x)
    local rate = (target_offs_x * (target_offs_x - offs_x) < 0) and 0.09 or 0.02
    offs_x = offs_x + (target_offs_x - offs_x) * rate
    offs_y_t = offs_y_t + 1
  end

  local world_to_local = function (x, y)
    x = x - o_x
    y = y - o_y
    local det = 1 - s_x * s_y
    x, y =
      (x - s_x * y) / det,
      (y - s_y * x) / det
    return x, y
  end

  o.press = function (x, y)
    if not is_active then return false end
    if anim_dir ~= 0 then return false end
    x, y = world_to_local(x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
  end

  o.move = function (x, y)
    if not is_active then return false end
    if anim_dir ~= 0 then return false end
    x, y = world_to_local(x, y)
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
  end

  o.release = function (x, y)
    if not is_active then return false end
    if anim_dir ~= 0 then return false end
    x, y = world_to_local(x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end
  end

  o.key = function (key)
    if not is_active then return false end
    if anim_dir ~= 0 then return false end
    if key == 'tab' then o.close() return true
    elseif key == 'q' then flip_page(-1) return true
    elseif key == 'w' then flip_page(1) return true
    end
  end

  o.update = function ()
    if not is_active then return end
    for i = 1, #buttons do buttons[i].update() end

    if anim_dir ~= 0 then
      anim_t = anim_t + 1
      if anim_t == 120 then
        if anim_dir == -1 then
          anim_t = 0
          is_active = false
        end
        anim_dir = 0
      end
    end
  end

  o.draw = function ()
    if not is_active then return end

    love.graphics.push('transform')

    local scale_x, scale_y = 1, 1
    local move_progress_x, move_progress_y, rotation = 1, 1, 0
    local alpha = 1
    if anim_dir == 1 then
      local x = anim_t / 120
      scale_x = ease_quad(x)
      scale_y = scale_x * ease_pow_out(x, 4)
      move_progress_x = ease_quad(x)
      move_progress_y = ease_quad(x)
      rotation = -1.6 * (1 - ease_pow_out(x, 3))
      alpha = ease_quad_out(math.max(0, (x - 0.7) / 0.3))
    elseif anim_dir == -1 then
      local x = anim_t / 120
      scale_x = 1 - ease_quad(x)
      scale_y = scale_x * ease_pow_out(1 - x, 4)
      move_progress_x = 1 - ease_quad(x)
      move_progress_y = 1 - ease_quad(x)
      rotation = -1.6 * (1 - ease_pow_out(1 - x, 3))
      alpha = ease_quad_out(math.max(0, (1 - x - 0.7)) / 0.3)
    end

    -- >-<
    local o0_x, o0_y = W * 0.12, H * 0.7
    local oo_x = o0_x + (o_x - o0_x) * move_progress_x
    local oo_y = o0_y + (o_y - o0_y) * move_progress_y
    oo_x = oo_x + offs_x * W * 0.005
    oo_y = oo_y + offs_x * math.sin(offs_y_t / 20) * H * 0.0005

    love.graphics.translate(oo_x, oo_y)
    love.graphics.shear(s_x, s_y)
    love.graphics.scale(scale_x, scale_y)
    love.graphics.rotate(rotation)

    love.graphics.setColor(1, 1, 1, alpha)
    draw.img('card', 0, 0, W * 0.22)
    love.graphics.setColor(0.2, 0.1, 0.1, alpha)
    draw.img('stars/' .. tostring(cur_page), 0, H * -0.1, W * 0.2)

    love.graphics.setColor(1, 1, 1, alpha)
    for i = 1, #buttons do buttons[i].draw() end

    love.graphics.pop()
  end

  return o
end

local gallery_overlay = create_gallery_overlay()

local blend_shader = function (blend_fn)
  return love.graphics.newShader([[
    uniform Image filter_tex;

    float blend(float a, float b) {
]] .. blend_fn .. [[
    }

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
      vec4 A = Texel(tex, texture_coords);
      vec4 B = Texel(filter_tex, texture_coords);
      vec3 C = vec3(
        blend(A.r, B.r),
        blend(A.g, B.g),
        blend(A.b, B.b)
      );
      return vec4(A.rgb + (C - A.rgb) * B.a, A.a);
    }
  ]])
end

local global_filter_shader = {
  overlay = blend_shader([[
    if (a < 0.5) return 2. * a * b;
    else return 1. - 2. * (1. - a) * (1. - b);
  ]]),
  soft_light = blend_shader([[
    if (b < 0.5) return 2. * a * b + a * a * (1. - b - b);
    else return 2. * a * (1. - b) + sqrt(a) * (b + b - 1.);
  ]]),
}

return function (puzzle_index)
  local s = {}
  local W, H = W, H

  local puzzle = puzzles[puzzle_index]
  local earthbound = (#puzzle.resp <= 5)
  local unisymbol = puzzle.unisymbol
  local chapter_index
  if puzzle_index <= 10 then chapter_index = 1
  elseif puzzle_index <= 18 then chapter_index = 2
  elseif puzzle_index <= 20 then chapter_index = 3
  else chapter_index = 4 end

  ------ Canvas for global effect overlay ------
  local canvas = love.graphics.newCanvas(W, H)

  local global_shader = global_filter_shader[
    chapter_index == 3 and 'soft_light' or 'overlay']
  global_shader:send('filter_tex', draw.get('filters/' .. chapter_index))

  ------ Display ------
  local radar_x, radar_y = W * 0.498, H * 0.367
  local radar_r = H * 0.3

  local bg_int = 'bg_int/' .. (chapter_index == 1 and 1 or 2)

  local bg_ext_slices = {}
  local bg_ext_w_total = 0
  for i = 0, 2 do
    local bg_ext_name = 'bg_ext/' .. chapter_index .. '-' .. i
    local w, _ = draw.get(bg_ext_name):getDimensions()
    bg_ext_slices[i + 1] = { name = bg_ext_name, width = w }
    bg_ext_w_total = bg_ext_w_total + w
  end

  ------ Game state ------
  local T = 0

  local N_ORI = 8

  local ant_ori = math.pi * 1.5
  local ori_step = math.pi * 2 / N_ORI / 240 * 1.5
  local ant_speed = 0
  local ant_sector = 6
  local ant_sector_last, ant_sector_anim = ant_sector, 0
  local SECTOR_ANIM_DUR = 40
  local RESP_DISP_DUR = 720
  local ant_ori_stuck, ant_ori_stuck_dir = 0, 0

  local sel_sym = 2

  local LEVER_COOLDOWN = 360
  local T_last_lever = -LEVER_COOLDOWN

  local objective_seq = puzzle.seq
  local objective_pos = 0
  local objective_next = calc_kmp_next(objective_seq)
  local OBJECTIVE_ANIM_DUR_IN = 120
  local OBJECTIVE_ANIM_DUR_OUT = 90
  local objective_seq_change = {}
  for i = 1, #objective_seq do objective_seq_change[i] = -OBJECTIVE_ANIM_DUR_OUT - 1 end

  -- Deep space entities!
  local responders = {}
  local responses = {}  -- responses[i] = list of {symbol = number, timestamp = number}
  local transmits = {}  -- Same as above
  for i = 0, N_ORI - 1 do
    local resp_idx = (i + 4) % N_ORI + 1
    if not earthbound or (i == 0 or i >= 4) then
      responders[i] = puzzle.resp[resp_idx]()
    end
    responses[i] = {}
    transmits[i] = {}
  end

  ------ State animations and scene elements ------
  local since_clear = -1

  local STEER_N_FRAMES = 6
  local last_steer = 0          -- Last acceleration
  local last_steer_nonzero = 1  -- For animation
  local steer_cont_dur = 0
  local screen_steer = 0        -- Screen-pressed steer value

  gallery_overlay.reset()

  local trail_start_speed = 1
  local trail_start_ramp = 0
  local radar_trail_frame = 1   -- These are persistent to avoid tail-popping
  local radar_trail_flip = 1

  local sel_sym_since = 0

  local rx_intensity = 0    -- Order 2
  local rx_intensity_accum = 0

  ------ Buttons ------
  local buttons = { }

  -- Symbol buttons
  local sym_btns = {}
  local refresh_sym_btns

  local select_sym = function (i)
    if sel_sym == i then return end
    if sym_btns[i] then   -- Hide 1/3 symbols in `unisymbol` mode
      sel_sym = i
      sel_sym_since = 0
      refresh_sym_btns()
    end
  end
  refresh_sym_btns = function ()
    for i, _ in pairs(sym_btns) do
      sym_btns[i].set_drawable(
        draw.get('symbols/' .. tostring(i) .. (sel_sym == i and '_btn_sel' or '_btn_ord')))
    end
  end
  for i = (unisymbol and 2 or 1), (unisymbol and 2 or 3) do
    local btn = button(
      draw.get('symbols/' .. tostring(i) .. '_btn_ord'),
      function () select_sym(i) end,
      nil, { use_tint = true }
    )
    btn.x = (715 + (i - 1) * 246) * (2/3)
    btn.y = 786 * (2/3)
    sym_btns[i] = btn
    buttons[#buttons + 1] = btn
  end
  refresh_sym_btns()

  -- Lever button
  local pull_lever
  local btn_lever = button(
    draw.get('lever/1'),
    function () pull_lever() end,
    nil, { use_tint = true }
  )
  btn_lever.x = (1344 + 420/2) * (2/3)
  btn_lever.y = (288 + 720/2) * (2/3)
  buttons[#buttons + 1] = btn_lever

  pull_lever = function ()
    if T < T_last_lever + LEVER_COOLDOWN then return end
    if since_clear >= 0 then return end

    btn_lever.hidden = true
    btn_lever.enabled = false
    T_last_lever = T

    -- Send to responder
    responders[ant_sector].send(sel_sym, T)

    -- Record transmission
    table.insert(transmits[ant_sector], {symbol = sel_sym, timestamp = T})

    audio.sfx('lever')
  end

  -- Gallery button
  local open_gallery
  local btn_gallery = button(
    draw.get('gallery_book/1'),
    function () open_gallery() end,
    nil, { use_tint = true }
  )
  btn_gallery.x = 124
  btn_gallery.y = 484
  buttons[#buttons + 1] = btn_gallery

  open_gallery = function ()
    gallery_overlay.toggle_open()
  end

  ------ Scene methods ------

  s.press = function (x, y)
    if gallery_overlay.press(x, y) then return true end
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end

    if y >= H * 0.7 and math.abs(x - W * 0.5) < W * 0.25 then
      screen_steer = (x < W * 0.5 and -1 or 1)
      return true
    end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if gallery_overlay.move(x, y) then return true end
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end

    if screen_steer ~= 0 then
      screen_steer = (x < W * 0.5 and -1 or 1)
    end
  end

  s.release = function (x, y)
    if gallery_overlay.release(x, y) then return true end
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end

    if screen_steer ~= 0 then
      screen_steer = 0
      return true
    end
  end

  s.key = function (key)
    if gallery_overlay.key(key) then return true end

    if key == '1' then select_sym(1)
    elseif key == '2' then select_sym(2)
    elseif key == '3' then select_sym(3)
    elseif key == 'return' then pull_lever()
    elseif key == 'tab' then open_gallery()
    elseif key == 'space' then
      replaceScene(scene_interlude(puzzle_index), transitions['fade'](0.1, 0.1, 0.1))
    elseif key == 'n' then
      if puzzles[puzzle_index + 1] then
        replaceScene(scene_gameplay(puzzle_index + 1), transitions['fade'](0.1, 0.1, 0.1))
      end
    elseif key == 'p' then
      if puzzles[puzzle_index - 1] then
        replaceScene(scene_gameplay(puzzle_index - 1), transitions['fade'](0.1, 0.1, 0.1))
      end
    end
  end

  s.update = function ()
    T = T + 1
    for i = 1, #buttons do buttons[i].update() end

    -- `ant_sector_last` is for animation,
    -- here we do a backup to check whether sector changed
    local ant_sector_backup = ant_sector
    local accel = screen_steer
    if love.keyboard.isDown('left') then accel = accel - 1 end
    if love.keyboard.isDown('right') then accel = accel + 1 end
    accel = clamp(accel, -1, 1)
    ant_speed = clamp(ant_speed + accel / 20, -1, 1)
    if accel == 0 then
      if ant_speed > 0 then ant_speed = math.max(0, ant_speed - 1 / 120)
      else ant_speed = math.min(0, ant_speed + 1 / 120) end
    end
    ant_ori = ant_ori + ori_step * ant_speed
    if earthbound then
      if accel == 0 then
        local value = ease_stuck(ant_ori_stuck, 0.1)
        value = value * 0.94
        ant_ori_stuck = ease_stuck_inverse(value, 0.1)
      else
        if ant_ori < math.pi then
          ant_ori_stuck = ant_ori_stuck + ori_step * math.abs(ant_speed)
          ant_ori_stuck_dir = 1
        elseif ant_ori > math.pi * 2 then
          ant_ori_stuck = ant_ori_stuck + ori_step * math.abs(ant_speed)
          ant_ori_stuck_dir = -1
        end
      end
      ant_ori = clamp(ant_ori, math.pi, math.pi * 2)
    else
      if ant_ori < 0 then ant_ori = ant_ori + math.pi * 2
      elseif ant_ori >= math.pi * 2 then ant_ori = ant_ori - math.pi * 2 end
    end
    ant_sector = math.floor(ant_ori / (math.pi * 2 / N_ORI) + 0.5) % N_ORI
    if ant_sector_backup ~= ant_sector then
      ant_sector_last = ant_sector_backup
      ant_sector_anim = SECTOR_ANIM_DUR
    end

    if accel ~= 0 and last_steer ~= accel then
      audio.sfx('steer', 0, true)
      steer_cont_dur = 0
    elseif last_steer ~= 0 and accel == 0 then
      audio.sfx_stop('steer')
    end
    if accel ~= 0 then
      if steer_cont_dur < STEER_N_FRAMES * 20 then
        steer_cont_dur = steer_cont_dur + 1
      end
      local vol = math.min(1, steer_cont_dur / 120)
      audio.sfx_vol('steer', vol)
    elseif steer_cont_dur > 0 then
      steer_cont_dur = steer_cont_dur - 1
    end
    last_steer = accel
    if accel ~= 0 then last_steer_nonzero = accel end

    if T <= T_last_lever + LEVER_COOLDOWN then
      if T == T_last_lever + LEVER_COOLDOWN then
        btn_lever.hidden = false
        btn_lever.enabled = true
      end
    end

    if ant_sector_anim > 0 then
      ant_sector_anim = ant_sector_anim - 1
    end

    -- Update all responders and collect responses
    local last_seq_pos = objective_pos
    for i = 0, N_ORI - 1 do if responders[i] then
      local sym = responders[i].update()
      if sym ~= nil then
        table.insert(responses[i], {symbol = sym, timestamp = T})
        rx_intensity_accum = rx_intensity_accum + 60
        if since_clear == -1 then
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
            since_clear = 0
          end
        end
      end

      -- Remove expired ones
      local prune_expired_symbols = function (l)
        while #l > 0 and (#l > 4 or l[1].timestamp < T - RESP_DISP_DUR) do
          table.remove(l, 1)
        end
      end
      prune_expired_symbols(responses[i])
      -- And also transmissions
      prune_expired_symbols(transmits[i])
    end end

    for i = math.min(last_seq_pos, objective_pos) + 1,
            math.max(last_seq_pos, objective_pos) do
      objective_seq_change[i] = T
    end

    -- Radar trail
    if ant_speed * trail_start_speed <= 0 then
      trail_start_ramp = 0
      if ant_speed ~= 0 then trail_start_speed = ant_speed end
    else
      trail_start_ramp = trail_start_ramp + 1
    end

    if T % 20 == 0 then
      if ant_speed ~= 0 then
        radar_trail_flip = (ant_speed > 0 and -1 or 1)
        if math.abs(ant_speed) >= 3/4 and trail_start_ramp >= 80 then
          radar_trail_frame = 6 + math.floor(T / 20) % 4
        elseif math.abs(ant_speed) >= 1/2 and trail_start_ramp >= 40 then
          radar_trail_frame = 4 + math.floor(T / 20) % 2
        else
          radar_trail_frame = 2 + math.floor(T / 20) % 2
        end
      else
        radar_trail_frame = 1
        radar_trail_flip = 1
      end
    end

    -- Button highlight animation
    sel_sym_since = sel_sym_since + 1

    -- RX intensity animation bar
    rx_intensity = rx_intensity * 0.98
    if rx_intensity_accum > 0 then
      rx_intensity = rx_intensity + rx_intensity_accum
      rx_intensity_accum = rx_intensity_accum - 1
    end

    -- Puzzle-clear transition out
    if since_clear >= 0 then
      since_clear = since_clear + 1
      if since_clear == 600 then
        replaceScene(scene_interlude(puzzle_index), transitions['fade'](0.1, 0.1, 0.1))
      end
    end

    gallery_overlay.pull(-last_steer)
    gallery_overlay.update()
  end

  local meter_texs = {}
  local meter_quads = {}
  for i = 1, 3 do
    local tex = draw.get('meter/' .. i)
    local quads = {}
    local w, h = tex:getDimensions()
    for j = 1, 25 do
      local y = (25 - j) / 25 * h
      quads[j] = love.graphics.newQuad(0, y, w, h - y, tex)
    end
    meter_texs[i] = tex
    meter_quads[i] = quads
  end

  s.draw = function ()
    love.graphics.setCanvas(canvas)
    love.graphics.push()
    love.graphics.replaceTransform(love.math.newTransform())
    love.graphics.clear(0, 0, 0, 0)

    -- Ease on stuck directions
    local disp_ori = ant_ori
    if ant_ori_stuck_dir < 0 then
      disp_ori = disp_ori + ease_stuck(ant_ori_stuck, 0.1)
    else
      disp_ori = disp_ori - ease_stuck(ant_ori_stuck, 0.1)
    end

    -- Outer background
    love.graphics.setColor(1, 1, 1)
    local bg_ext_pos = -disp_ori / (math.pi * 2) * bg_ext_w_total   -- Logical position
    local bg_ext_y = 4
    -- Vibration on land
    if chapter_index == 1 or chapter_index == 3 then
      bg_ext_y = 4 * (1 + 2 * (love.math.noise(T / 180) - 0.5) * ant_speed)
    end
    for i = 1, #bg_ext_slices do
      local start_pos = bg_ext_pos
      -- Physical position: fold around
      if start_pos < -bg_ext_w_total + W then start_pos = start_pos + bg_ext_w_total end
      local end_pos = start_pos + bg_ext_slices[i].width
      if math.max(0, start_pos) < math.min(W, end_pos) then
        draw.img(bg_ext_slices[i].name, start_pos, -bg_ext_y, bg_ext_slices[i].width, nil, 0, 0)
      end
      bg_ext_pos = bg_ext_pos + bg_ext_slices[i].width  -- Still logical
    end
    draw.img(bg_int, W / 2, H / 2, W, H)

    -- Sector highlight
    local sector = function (n)
      draw.img('sector', radar_x, radar_y, nil, nil, 9/240, 307/312, (n + 1.5) * math.pi * 2 / N_ORI)
    end
    local sector_alpha = 1
    if ant_sector_anim > 0 then
      local x = ant_sector_anim / SECTOR_ANIM_DUR
      local last_alpha = x ^ 0.8
      sector_alpha = (1 - x) ^ 0.8
      love.graphics.setColor(0.5, 0.5, 0.5, last_alpha * 0.7)
      sector(ant_sector_last)
    end
    love.graphics.setColor(0.5, 0.5, 0.5, sector_alpha * 0.7)
    sector(ant_sector)

    -- Radar line
    love.graphics.setColor(0.25, 0.27, 0.15)
    draw.img('radar_trail/' .. radar_trail_frame, radar_x, radar_y,
      108 * radar_trail_flip, 216, 6.5/162, 317/324, disp_ori + math.pi / 2)

    -- Sector responses
    local symbol_list = function (rs, i, radius, slide, angle_sep, tint_r, tint_g, tint_b)
      if #rs == 0 then return end
      local base_angle = i * math.pi * 2 / N_ORI
      local offs_x = 0
      local offs = {}
      local scales = {}
      local slides = {}
      local alphas = {}
      for j = 1, #rs do
        local t = T - rs[j].timestamp
        local dx
        local s = 1
        local l = 0
        local a = 1
        if t < 20 then
          local x = t / 20
          s = ease_quad_out(x)
          l = 1 - ease_pow_out(x, 3)
          dx = ease_quad(x)
        elseif t > RESP_DISP_DUR - 40 then
          local x = 1 - (RESP_DISP_DUR - t) / 40
          a = ease_quad_in(1 - x)
          dx = 1 - ease_quad(x)
        else
          dx = 1
        end
        offs[j] = offs_x + dx / 2
        offs_x = offs_x + dx
        scales[j] = s
        slides[j] = l
        alphas[j] = a
      end
      local global_offs = -offs_x / 2
      local orth_x = math.sin(-i * math.pi * 2 / N_ORI)
      local orth_y = math.cos(-i * math.pi * 2 / N_ORI)
      for j = 1, #rs do
        local angle = base_angle + (offs[j] + global_offs) * angle_sep
        local x = radar_x + radius * math.cos(angle)
        local y = radar_y + radius * math.sin(angle)
        local slide_x = slide * math.cos(angle)
        local slide_y = slide * math.sin(angle)
        local s = scales[j]
        local l = slides[j]
        love.graphics.setColor(tint_r, tint_g, tint_b, alphas[j])
        draw.img('symbols/' .. rs[j].symbol,
          x - l * slide_x, y - l * slide_y, 40 * s, 40 * s)
      end
    end
    for i = 0, N_ORI - 1 do
      symbol_list(responses[i], i, radar_r * 0.825, radar_r * -0.15, 0.225, 0.9, 0.9, 0.85)
      symbol_list(transmits[i], i, radar_r * 0.4, radar_r * 0.15, 0.225 * 0.825 / 0.4, 0.3, 0.7, 0.4)
    end

    -- Screen noise
    love.graphics.setColor(0.25, 0.27, 0.15)
    local noise_frame = 1 + math.floor(T / 20) % 10
    draw.img('noise/' .. noise_frame, W / 2, (111 + 630/2) * (2/3))

    -- Numeral
    love.graphics.setColor(1, 1, 1)
    local numerals_frame = -1
    if T >= 240 + 20 * 4 then
      numerals_frame = (puzzle_index - 1) % 10 + 1
    elseif T >= 240 then
      numerals_frame = 11 + math.floor((T - 240) / 20)
    end
    if numerals_frame >= 1 and numerals_frame <= 13 then
      draw.img('numerals/' .. numerals_frame, (1218 + 108/2) * (2/3), (56 + 108/2) * (2/3))
    end
    draw.img('numerals/highlight', (1209 + 120/2) * (2/3), (51 + 81/2) * (2/3))

    -- Meter
    love.graphics.setColor(1, 1, 1)
    for i = 1, 3 do
      local x0 = (1374 + 42 * (i - 1)) * (2/3)
      local y0 = 144 * (2/3)
      local h0 = 276 * (2/3)
      local n = 0
      if i == 1 then n = math.abs(ant_speed)
      elseif i == 2 then
        local t = T - T_last_lever
        if t < 480 then
          local x = (t - 60) / 30
          if x > 0 then x = x / 3 end
          n = 2 / (math.exp(x) + math.exp(-x))
        end
      else
        n = math.max(0, math.log(rx_intensity) - 4) / 6
      end
      n = math.min(25, math.floor(2 + love.math.noise(i * 0.8, T - T % (2000^0.5)) * 4 + 21 * n))
      if n > 0 then
        love.graphics.draw(meter_texs[i], meter_quads[i][n], x0, y0 + h0 * (25 - n) / 25, 0, 2/3)
      end
    end

    -- Television screen
    love.graphics.setColor(1, 1, 1)
    draw.img('tv', W / 2, H / 2, W, H)

    -- Objective sequence
    local symbols_per_line = (#objective_seq >= 6 and #objective_seq <= 8 and 4 or 5)
    local n_lines = math.ceil(#objective_seq / symbols_per_line)
    for i = 1, #objective_seq do
      local x = W * 0.124 + 53 * ((i - 1) % symbols_per_line)
      local y = H * 0.175 + 53 * (-n_lines + 1 + math.floor((i - 1) / symbols_per_line))
      local scale = 1
      local alpha = i <= objective_pos and 1 or 0.3

      local anim_t = T - objective_seq_change[i]
      if i <= objective_pos and anim_t <= OBJECTIVE_ANIM_DUR_IN then
        local x = anim_t / OBJECTIVE_ANIM_DUR_IN
        scale = 1 + ease_elastic(x, 10) * 0.1
      elseif i > objective_pos and anim_t <= OBJECTIVE_ANIM_DUR_OUT then
        local x = anim_t / OBJECTIVE_ANIM_DUR_OUT
        alpha = 1 - 0.7 * ease_pow_out(x, 4)
        scale = 1 - ease_elastic(x, 4) * 0.08
      end

      love.graphics.setColor(1, 1, 1, alpha)
      draw.img('symbols/' .. objective_seq[i] .. '_tv', x, y, 54 * scale, 54 * scale, 0.5, 0.5, 0.03)
    end

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.print(tostring(puzzle_index), W * 0.04, H * 0.88)

    -- Gallery book
    local book_frame = 1
    local book_anim, book_anim_dir = gallery_overlay.state()
    if book_anim_dir == -1 then
      -- Closing
      book_frame = math.max(6, 8 - math.floor(book_anim / 20))
    else
      -- Opening
      book_frame = math.min(6, 1 + math.floor(book_anim / 20))
    end
    if book_frame ~= 1 then
      love.graphics.setColor(1, 1, 1)
      draw.img('gallery_book/' .. tostring(book_frame), 124, 484)
      btn_gallery.hidden = true
    else
      btn_gallery.hidden = false
    end

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end

    -- Button highlight
    local btn_light_frame = math.min(6, 1 + math.floor(sel_sym_since / 10))
    local btn_light_alpha = {0.26, 0.21, 0.65, 0.26, 0.84, 1}
    love.graphics.setColor(1, 1, 1, btn_light_alpha[btn_light_frame])
    draw.img('btn_light', sym_btns[sel_sym].x, (591 + 270/2) * (2/3))

    -- Lever
    love.graphics.setColor(1, 1, 1)
    if T < T_last_lever + LEVER_COOLDOWN then
      local frame = 1 + math.floor((T - T_last_lever) / 30)
      draw.img('lever/' .. tostring(frame), (1344 + 420/2) * (2/3), (288 + 720/2) * (2/3))
    end

    -- Steering wheel
    local steer_frame = math.min(STEER_N_FRAMES, 1 + math.floor(steer_cont_dur / 20))
    local steer_flip_x = (last_steer_nonzero < 0)
    draw.img('steer/' .. tostring(steer_frame), 640, 664, steer_flip_x and -516 or 516, 112)

    -- Back to global canvas
    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.clear(0.99, 0.99, 0.98)
    love.graphics.setShader(global_shader)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

    -- Gallery
    gallery_overlay.draw()
  end

  s.destroy = function ()
  end

  return s
end
