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

local echo = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym, 180})
  end
  o.update = q.pop
  return o
end

local symmetry = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym, 60})
    q.insert({sym == 2 and 2 or 4 - sym, 600})
  end
  o.update = q.pop
  return o
end

return {
  [1] = {
    seq = {1, 2},
    resp = {
      echo, echo, echo, echo,
      echo, echo, echo, echo,
    },
  },
  [2] = {
    seq = {2, 1, 3, 2},
    resp = {
      symmetry, symmetry, symmetry, symmetry,
      symmetry, symmetry, symmetry, symmetry,
    },
  },
  [3] = {
    seq = {1, 2, 1, 3, 2},
    resp = {
      symmetry, symmetry, symmetry, symmetry,
      symmetry, symmetry, symmetry, symmetry,
    },
  },
}
