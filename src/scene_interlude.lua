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

return function (puzzle_index)
  local s = {}
  local W, H = W, H
  local font = _G['global_font']

  local steps = {}
  if puzzles[puzzle_index].gallery then
    local gallery_id = puzzles[puzzle_index].gallery
    local gallery_entry = gallery[gallery_id]
    steps[#steps + 1] = {
      gallery_id = gallery_id,
      name_text = love.graphics.newText(font(48), gallery_entry.id),
      desc_text = wrap_lines(font(36), gallery_entry.desc, W * 0.46)
    }
  end

  if puzzles[puzzle_index].msg then
    steps[#steps + 1] = {
      cutscene_text = wrap_lines(font(36), puzzles[puzzle_index].msg, W * 0.75)
    }
  end

  local t_cont = love.graphics.newText(font(32), 'Press screen / <Enter> key')

  local move_on = function ()
    local next_index = puzzle_index + 1
    if not puzzles[next_index] then next_index = 1 end
    replaceScene(scene_gameplay(next_index), transitions['fade'](0.1, 0.1, 0.1))
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
  end

  s.draw = function ()
    love.graphics.clear(0.1, 0.1, 0.1)

    local step = steps[1]
    if step.gallery_id then
      love.graphics.setColor(0.97, 0.97, 0.97)
      draw.img('stars/' .. step.gallery_id, W * 0.27, H * 0.48, W * 0.5)
      local text_base = H * (0.4 - (#step.desc_text - 1) * 0.04)
      draw(step.name_text, W * 0.5, text_base, nil, nil, 0, 0)
      for i, t in ipairs(step.desc_text) do
        draw(t, W * 0.5, text_base + H * (0.13 + (i - 1) * 0.08), nil, nil, 0, 0)
      end
    else
      love.graphics.setColor(0.97, 0.97, 0.97)
      for i, t in ipairs(step.cutscene_text) do
        draw(t, W * 0.5, H * (0.7 - (#step.cutscene_text - i) * 0.08))
      end
    end

    love.graphics.setColor(1, 1, 1, 0.4)
    draw(t_cont, W * 0.95, H * 0.9, nil, nil, 1, 1)
  end

  s.destroy = function ()
  end

  return s
end
