local draw = require 'draw_utils'
local button = require 'button'

local puzzles = require 'puzzles'
local gallery = require 'gallery'

local wrap_lines = function (font, text, limit)
  local w, t = font:getWrap(text, limit)
  for i = 1, #t do
    t[i] = love.graphics.newText(font, t[i])
  end
  return t
end

local clamp = function (x, a, b)
  if x < a then return a elseif x > b then return b else return x end
end
local ease_quad = function (x)
  if x < 0.5 then return x * x * x * 4
  else return 1 - (1 - x) * (1 - x) * 2 end
end
local ease_exp_out_inv = function (x)
  return (math.exp(-x * 4) - math.exp(-4)) / (1 - math.exp(-4))
end
local ease_cubic = function (x)
  if x < 0.5 then return x * x * x * 4
  else return 1 - (1 - x) * (1 - x) * (1 - x) * 4 end
end

return function (puzzle_index)
  local s = {}
  local W, H = W, H
  local font = _G['global_font']

  local steps = {}
  if puzzles[puzzle_index].gallery then
    local ids = puzzles[puzzle_index].gallery
    if type(ids) == 'string' then ids = { ids } end
    for _, gallery_id in ipairs(ids) do
      local gallery_entry = gallery[gallery_id]
      steps[#steps + 1] = {
        gallery_id = gallery_id,
        name_text = love.graphics.newText(font(48), gallery_entry.name),
        desc_text = wrap_lines(font(36), gallery_entry.desc, W * 0.46),
        fade_out = 480,
      }
    end
  end

  if puzzles[puzzle_index].msg then
    steps[#steps + 1] = {
      cutscene_text = wrap_lines(font(36), puzzles[puzzle_index].msg, W * 0.75),
      fade_out = 120,
    }
  end

  local t_cont = love.graphics.newText(font(32), 'Press screen / <Enter> key')

  local cur_step = 1
  local T = 0
  local last_step_T_offs = 0

  local move_on = function ()
    if T < 240 then return end
    last_step_T_offs = T + steps[cur_step].fade_out
    T = -steps[cur_step].fade_out
    cur_step = cur_step + 1
  end

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
    move_on()
  end

  s.key = function (key)
    if key == 'return' then move_on() end
  end

  local continued = false

  s.update = function ()
    T = T + 1
    if cur_step > #steps and T == 0 then
      T = -1
      if not continued then
        continued = true
        local next_index = puzzle_index + 1
        if not puzzles[next_index] then next_index = 1 end
        replaceScene(scene_gameplay(next_index), transitions['crossfade']())
      end
    end
  end

  local draw_step = function (step, T, base_alpha, fade_out_T)
    if step.gallery_id then
      local img_alpha = ease_quad(clamp(T / 120, 0, 1))
      local img_x, img_y, img_scale, img_rota = W * 0.27, H * 0.48, 1, 0
      -- Collect-to-book animation
      if fade_out_T > 0 then
        local x = clamp((fade_out_T - 150) / 180, 0, 1)
        local qx = ease_cubic(x)
        img_scale = 1 - 0.5 * ease_quad(x)
        img_alpha = img_alpha * (1 - qx) * (1 - qx)
        img_x = img_x + (W * 0.1 - img_x) * qx
        img_y = img_y + (H * 0.6 - img_y) * qx
        img_rota = -0.25 * qx
      end
      love.graphics.setColor(0.97, 0.97, 0.97, img_alpha * base_alpha)
      draw.img('stars/ord/' .. step.gallery_id, img_x, img_y,
        W * 0.5 * img_scale, nil, 0.5, 0.5, img_rota)

      local x = clamp((T - 60) / 120, 0, 1)
      love.graphics.setColor(0.97, 0.97, 0.97,
        ease_quad(x) * ease_quad(clamp(1 - fade_out_T / 60, 0, 1)) * base_alpha)
      local text_base = H * (0.4 - (#step.desc_text - 1) * 0.04)
      draw(step.name_text, W * 0.5, text_base + H * ease_exp_out_inv(x) * 0.01, nil, nil, 0, 0)
      for i, t in ipairs(step.desc_text) do
        local x = clamp((T - 100 - 30 * (i - 1)) / 120, 0, 1)
        love.graphics.setColor(0.97, 0.97, 0.97,
          ease_quad(x) * ease_quad(clamp(1 - (fade_out_T - i * 7) / 60, 0, 1)) * base_alpha)
        draw(t, W * 0.5, text_base + H * (0.13 + (i - 1) * 0.08 + ease_exp_out_inv(x) * 0.01), nil, nil, 0, 0)
      end

      if fade_out_T > 0 then
        local book_alpha, book_frame
        if fade_out_T <= 200 then
          book_alpha = ease_quad(clamp(fade_out_T / 120, 0, 1)) * base_alpha
          book_frame = clamp(1 + math.floor((fade_out_T - 80) / 20), 1, 6)
        else
          book_alpha = ease_quad(clamp((480 - fade_out_T) / 120, 0, 1)) * base_alpha
          book_frame = clamp(6 + math.floor((fade_out_T - 280) / 20), 6, 8)
          -- Stay if the last step
          if step == steps[#steps] then book_alpha = 1 end
        end
        love.graphics.setColor(0.97, 0.97, 0.97, book_alpha)
        if book_frame == 8 then book_frame = 1 end
        draw.img('gallery_book/outline_' .. tostring(book_frame), 124, 484)
      end
    else
      for i, t in ipairs(step.cutscene_text) do
        local x = clamp((T - 30 * (i - 1)) / 120, 0, 1)
        love.graphics.setColor(0.97, 0.97, 0.97, ease_quad(x) * base_alpha)
        draw(t, W * 0.5, H * (0.7 - (#step.cutscene_text - i) * 0.08 + ease_exp_out_inv(x) * 0.01))
      end
    end

    local x = clamp((T - 480) / 120, 0, 1)
    local y = clamp(1 - fade_out_T / 40, 0, 1)
    love.graphics.setColor(0.97, 0.97, 0.97, 0.4 * ease_quad(x) * ease_quad(y) * base_alpha)
    draw(t_cont, W * 0.95, H * (0.9 + ease_exp_out_inv(x) * 0.01), nil, nil, 1, 1)
  end

  s.draw = function ()
    love.graphics.clear(0, 0, 0)

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle('fill', 0, 0, W, H)

    if T < 0 then
      draw_step(steps[cur_step - 1], last_step_T_offs + T,
        ease_quad(clamp(-T / 120, 0, 1)),
        steps[cur_step - 1].fade_out + T
      )
    else
      draw_step(steps[cur_step], T, 1, 0)
    end
  end

  s.destroy = function ()
  end

  return s
end
