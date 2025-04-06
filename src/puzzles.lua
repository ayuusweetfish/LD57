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

local murmur = function (n) return function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({n, 180})
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
  [1] = {
    seq = {1, 1, 2, 3, 2},
    earthbound = true,
    resp = {filter(3), filter(2), filter(1), filter(2), filter(3)},
  },
  [2] = {
    seq = {1, 1, 2, 3, 2},
    earthbound = true,
    resp = {murmur(4), murmur(4), murmur(4), echo, murmur(4)},
  },
  [3] = {
    seq = {1, 2},
    earthbound = true,
    resp = {murmur(3), murmur(2), murmur(1), murmur(2), murmur(3)},
  },
  [4] = {
    seq = {2, 1, 3, 2},
    earthbound = true,
    resp = {symmetry, symmetry, symmetry, symmetry, symmetry},
  },
  [5] = {
    seq = {1, 2, 1, 3, 2},
    earthbound = true,
    resp = {symmetry, symmetry, symmetry, symmetry, symmetry},
  },
}
