local draw = require 'draw_utils'
local button = require 'button'

local puzzles = require 'puzzles'

return function (puzzle_index)
  local s = {}
  local W, H = W, H
  local font = _G['global_font']

  local t1 = love.graphics.newText(font(40),
    puzzles[puzzle_index].msg or 'Gallery +1')

  local t_cont = love.graphics.newText(font(32), 'Press screen / <Enter> key')

  local move_on = function ()
    replaceScene(scene_gameplay(puzzle_index + 1), transitions['fade'](0.1, 0.1, 0.1))
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
    love.graphics.setColor(1, 1, 1)
    draw(t1, W * 0.5, H * 0.7)
    love.graphics.setColor(1, 1, 1, 0.4)
    draw(t_cont, W * 0.95, H * 0.9, nil, nil, 1, 1)
  end

  s.destroy = function ()
  end

  return s
end
