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
        desc_text = wrap_lines(font(36), gallery_entry.desc, W * 0.46)
      }
    end
  end

  if puzzles[puzzle_index].msg then
    steps[#steps + 1] = {
      cutscene_text = wrap_lines(font(36), puzzles[puzzle_index].msg, W * 0.75)
    }
  end

  local t_cont = love.graphics.newText(font(32), 'Press screen / <Enter> key')

  local cur_step = 1
  local T = 0
  local last_step_T_offs = 0

  local move_on = function ()
    if T < 240 then return end
    cur_step = cur_step + 1
    last_step_T_offs = T + 120
    T = -120
    if cur_step > #steps then
      local next_index = puzzle_index + 1
      if not puzzles[next_index] then next_index = 1 end
      replaceScene(scene_gameplay(next_index), transitions['fade'](0.1, 0.1, 0.1))
    end
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

  s.update = function ()
    T = T + 1
  end

  local draw_step = function (step, T, base_alpha)
    if step.gallery_id then
      local img_alpha = ease_quad(clamp(T / 120, 0, 1))
      love.graphics.setColor(0.97, 0.97, 0.97, img_alpha * base_alpha)
      draw.img('stars/' .. step.gallery_id, W * 0.27, H * 0.48, W * 0.5)

      local x = clamp((T - 60) / 120, 0, 1)
      love.graphics.setColor(0.97, 0.97, 0.97, ease_quad(x) * base_alpha)
      local text_base = H * (0.4 - (#step.desc_text - 1) * 0.04)
      draw(step.name_text, W * 0.5, text_base + H * ease_exp_out_inv(x) * 0.01, nil, nil, 0, 0)
      for i, t in ipairs(step.desc_text) do
        local x = clamp((T - 100 - 30 * (i - 1)) / 120, 0, 1)
        love.graphics.setColor(0.97, 0.97, 0.97, ease_quad(x) * base_alpha)
        draw(t, W * 0.5, text_base + H * (0.13 + (i - 1) * 0.08 + ease_exp_out_inv(x) * 0.01), nil, nil, 0, 0)
      end
    else
      for i, t in ipairs(step.cutscene_text) do
        local x = clamp((T - 30 * (i - 1)) / 120, 0, 1)
        love.graphics.setColor(0.97, 0.97, 0.97, ease_quad(x) * base_alpha)
        draw(t, W * 0.5, H * (0.7 - (#step.cutscene_text - i) * 0.08 + ease_exp_out_inv(x) * 0.01))
      end
    end

    local x = clamp((T - 480) / 120, 0, 1)
    love.graphics.setColor(0.97, 0.97, 0.97, 0.4 * ease_quad(x) * base_alpha)
    draw(t_cont, W * 0.95, H * (0.9 + ease_exp_out_inv(x) * 0.01), nil, nil, 1, 1)
  end

  s.draw = function ()
    love.graphics.clear(0.1, 0.1, 0.1)

    if T < 0 then draw_step(steps[cur_step - 1], last_step_T_offs + T, ease_quad(-T / 120))
    else draw_step(steps[cur_step], T, 1) end
  end

  s.destroy = function ()
  end

  return s
end
