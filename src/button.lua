return function (drawable, fn, drawable_scale, options)
  local s = {}
  local W, H = W, H

  s.x = 0
  s.y = 0
  s.s = 1
  s.enabled = true

  options = options or {}

  local w, h = drawable:getDimensions()
  if drawable_scale then
    if not options.drawable_scale_is_absolute then
      drawable_scale = drawable_scale / w
    end
    w = w * drawable_scale
    h = h * drawable_scale
  else
    drawable_scale = 1
  end

  local use_tint = options.use_tint
  local disabled_semitransparent = options.disabled_semitransparent

  local scale = 1

  local held = false
  local inside = false

  s.press = function (x, y)
    if not s.enabled and not s.response_when_disabled then return false end
    if x >= s.x - w/2 and x <= s.x + w/2 and
       y >= s.y - h/2 and y <= s.y + h/2 then
      held = true
      inside = true
      return true
    else
      return false
    end
  end

  s.move = function (x, y)
    if not held then return false end
    inside =
      x >= s.x - w/2 and x <= s.x + w/2 and
      y >= s.y - h/2 and y <= s.y + h/2
    return true
  end

  s.cancel_pt = function ()
    inside = false
    held = false
  end

  s.release = function (x, y)
    if not held then return false end
    if s.enabled and inside then fn() end
    inside = false
    held = false
    return true
  end

  s.update = function ()
    local target = ((s.enabled and inside and not use_tint) and 1.12 or 1)
    if math.abs(target - scale) <= 0.005 then
      scale = target
    else
      scale = scale + (target - scale) * 0.1
    end
  end

  s.set_drawable = function (d)
    drawable = d
  end

  s.draw = function ()
    if s.hidden then return end
    local sc = scale * s.s
    local x, y, sc = s.x - w/2 * sc, s.y - h/2 * sc, sc
    love.graphics.push('all')
    if use_tint then
      local tint = inside and 0.75 or 1
      love.graphics.setColor(tint, tint, tint)
    end
    if disabled_semitransparent and not s.enabled then
      local r, g, b, a = love.graphics.getColor()
      love.graphics.setColor(r, g, b, a * 0.35)
    end
    if drawable.draw then
      drawable:draw(x, y, sc * drawable_scale)
    else
      love.graphics.draw(drawable, x, y, 0, sc * drawable_scale)
    end
    love.graphics.pop()
  end

  return s
end
