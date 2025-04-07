-- Responder:
-- `send` accepts a symbol
-- `update` returns responded symbol, if any

local decay_priority_queue = function ()
  local o = {}

  local q = {}

  o.insert = function (entry)
    q[#q + 1] = entry
    table.sort(q, function (a, b) return a[2] < b[2] end)
  end

  o.pop = function ()
    if #q > 0 then
      for i = 1, #q do q[i][2] = q[i][2] - 1 end
      if q[1][2] <= 0 then
        return table.remove(q, 1)[1]
      end
    end
  end

  return o
end

local murmur = function (n, dur, count) return function ()
  dur = dur or 180
  count = count or 1
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    for i = 1, count do q.insert({n, dur * i}) end
  end
  o.update = q.pop
  return o
end end

local block = murmur(4, 40, 2)

local double_mur = function (n) return function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({n, 60})
    q.insert({n, 300})
  end
  o.update = q.pop
  return o
end end

local double_mur_slow = function (n) return function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({n, 120})
    q.insert({n, 600})
  end
  o.update = q.pop
  return o
end end

local filter = function (pass_sym) return function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym == pass_sym and sym or 4, 180})
  end
  o.update = q.pop
  return o
end end

local echo = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym, 180})
  end
  o.update = q.pop
  return o
end

local mirror = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({4 - sym, 180})
  end
  o.update = q.pop
  return o
end

local symmetry = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym, 60})
    q.insert({4 - sym, 600})
  end
  o.update = q.pop
  return o
end

return {
  -- Just play
  {
    seq = {1, 1, 1, 1, 1, 1, 1},
    resp = {murmur(1), murmur(1), murmur(1), murmur(1), murmur(1)},
    unisymbol = true,
  },
  -- Find one inside many obstacles
  {
    seq = {1, 1, 1, 1, 1},
    resp = {block, block, block, murmur(1), block},
    unisymbol = true,
  },
  -- Construct sequence
  {
    seq = {1, 2, 3, 2, 1},
    resp = {murmur(1), murmur(2), murmur(3), murmur(2), murmur(1)},
    unisymbol = true,
  },
  -- Sometimes you get more than one
  {
    seq = {2, 3, 1, 3, 2},
    resp = {murmur(3), double_mur(1), double_mur(2), double_mur(3), murmur(1)},
    unisymbol = true,
  },
  -- Interleave responses
  -- Strange fail rules?
  {
    seq = {1, 3, 1, 3, 1},
    resp = {block, double_mur_slow(3), double_mur_slow(1), double_mur_slow(3), block},
    unisymbol = true,
  },
  -- The other antenna has been fixed!
  {
    seq = {1, 2, 3, 2, 1},
    resp = {block, echo, block, block, block},
  },
  {
    seq = {1, 1, 2, 3, 2},
    resp = {filter(3), filter(2), filter(1), filter(2), filter(3)},
  },
  {
    seq = {3, 1, 2, 2, 1, 3},
    resp = {block, symmetry, block, block, block},
  },
  {
    seq = {3, 2, 1, 2, 3},
    resp = {block, symmetry, block, block, block},
  },
  {
    seq = {2, 1, 3, 2},
    resp = {symmetry, symmetry, symmetry, symmetry, symmetry},
  },
  {
    seq = {1, 2, 1, 3, 2},
    resp = {symmetry, symmetry, symmetry, symmetry, symmetry},
  },
}
