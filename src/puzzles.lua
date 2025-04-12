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

  o.count = function ()
    return #q
  end
  o.clear = function ()
    q = {}
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
  o.id = (n == 4 and 'stardust' or 'beacon_' .. n)
  return o
end end

local dust = murmur(4, 40, 2)

local double_mur = function (n, t1, t2) return function ()
  t1 = t1 or 60
  t2 = t2 or 300
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({n, t1})
    q.insert({n, t2})
  end
  o.update = q.pop
  o.id = 'double_beacon'
  return o
end end

local double_mur_slow = function (n) return double_mur(n, 120, 600) end

local filter = function (pass_sym) return function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym == pass_sym and sym or 4, 180})
  end
  o.update = q.pop
  o.id = 'filter'
  return o
end end

local echo = function (...)
  local t = {...}
  if #t == 0 then t[1] = 180 end
  return function ()
    local o = {}
    local q = decay_priority_queue()
    o.send = function (sym)
      if q.count() > 0 then
        q.clear()
        q.insert({4, 40})
        q.insert({4, 80})
        return
      end
      for i = 1, #t do
        q.insert({sym, t[i]})
      end
    end
    o.update = q.pop
    o.id = (t[#t] == 1680 and 'long_double_echo' or 'echo')
    return o
  end
end

local galaxia = echo(960, 1680)

local echo_dust = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym, 60})
    q.insert({4, 600})
  end
  o.update = q.pop
  o.id = 'echo_dust'
  return o
end

local invert = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({4 - sym, 180})
  end
  o.update = q.pop
  o.id = 'invert'
  return o
end

local harmonia = function ()
  local o = {}
  local q = decay_priority_queue()
  o.send = function (sym)
    q.insert({sym, 60})
    q.insert({4 - sym, 600})
  end
  o.update = q.pop
  o.id = 'harmonia'
  return o
end

local condense = function ()
  local o = {}
  local q = decay_priority_queue()
  local last = 0
  o.send = function (sym)
    if last == 0 then
      last = sym
    else
      local out_sym = (last == sym) and last or (6 - last - sym)
      q.insert({out_sym, 60})
      last = 0
    end
  end
  o.update = q.pop
  o.id = 'condense'
  return o
end

local traverse = function ()
  local o = {}
  local q = decay_priority_queue()
  local last = 0
  o.send = function (sym)
    last = last % 3 + 1
    q.insert({last, 60})
  end
  o.update = q.pop
  o.id = 'traverse'
  return o
end

local palindrome = function ()
  local o = {}
  local q = decay_priority_queue()
  local hist = {}
  o.send = function (sym, t)
    if q.count() > 0 then
      q.clear()
      q.insert({4, 40})
      q.insert({4, 80})
      return
    end

    hist[#hist + 1] = {sym, t}
    if #hist == 3 then
      local T = hist[#hist][2]
      local sep = T - hist[#hist - 1][2]
      for i = #hist, 1, -1 do
        q.insert({hist[i][1], sep + T - hist[i][2]})
      end
     hist = {}
    end
  end
  o.update = q.pop
  o.id = 'palindrome'
  return o
end

local stickbug = function ()
  local o = {}
  local q = decay_priority_queue()
  local last_T = -9999
  o.send = function (sym, T)
    local delta = T - last_T
    local resp = (delta < 1200 and 1 or 3)
    q.insert({resp, 180})
    last_T = T
  end
  o.update = q.pop
  o.id = 'stickbug'
  return o
end

local pulsar = function (n, offs) return function ()
  offs = offs or 0
  offs = (offs + 1) % 480   -- First update is T = 1
  local o = {}
  local q = decay_priority_queue()
  local last_T = -9999
  o.send = function (sym, T)
    last_T = T
    q.insert({9, 60})
  end
  o.update = function (T)
    if (T + 60) % 480 == offs then return 9 end
    if T % 480 == offs and T >= last_T + 960 then return n end
    return q.pop()
  end
  o.id = 'pulsar'
  return o
end end

local vagus = function ()
  local o = {}
  local q = decay_priority_queue()
  local cnt, start = 0, 0
  o.send = function (sym, T)
    if cnt > 0 and T >= start then
      -- Cancel
      cnt, start = 0, 0
      q.insert({9, 10})
      q.insert({2, 40})
      q.insert({2, 80})
    else
      cnt = cnt + 1
      start = T + 480 * cnt
    end
  end
  o.update = function (T)
    if cnt > 0 and T >= start then
      if T == start + (cnt - 1) * 480 + 40 then
        -- Finish
        cnt, start = 0, 0
        return 2
      elseif (T - start) % 480 == 0 then
        return 4
      elseif (T - start) % 480 == 440 then
        return 9
      end
    end
    return q.pop()
  end
  o.id = 'vagus'
  return o
end

return {
  ------ Chapter 1 ------
  -- Just play
  {
    seq = {1, 1, 1, 1, 1, 1, 1},
    resp = {murmur(1), murmur(1), murmur(1), murmur(1), murmur(1)},
    unisymbol = true,
    gallery = 'beacon_1',
  },
  -- Find one inside many obstacles
  {
    seq = {1, 1, 1},
    resp = {dust, dust, dust, murmur(1), dust},
    unisymbol = true,
    gallery = 'stardust',
  },
  -- Construct sequence
  {
    seq = {1, 2, 3, 2, 1},
    resp = {murmur(1), murmur(2), murmur(3), murmur(2), murmur(1)},
    unisymbol = true,
    gallery = {'beacon_3', 'beacon_2'},
  },
  -- Sometimes you get more than one
  {
    seq = {2, 3, 1, 2},
    resp = {murmur(3), double_mur(1), double_mur(2), double_mur(3), murmur(1)},
    unisymbol = true,
    gallery = 'double_beacon',
  },
  -- Interleave responses
  {
    seq = {1, 3, 1, 1, 3, 1},
    resp = {dust, double_mur_slow(3), double_mur_slow(1), double_mur_slow(3), dust},
    unisymbol = true,
    msg = 'I guess the antenna works now!',
  },
  -- Select symbols
  {
    seq = {1, 2, 3, 2, 1},
    resp = {dust, echo(180), dust, dust, dust},
    gallery = 'echo',
  },
  {
    seq = {1, 1, 2, 3, 2},
    resp = {filter(3), filter(2), filter(1), filter(2), filter(3)},
    gallery = 'filter',
  },
  {
    seq = {3, 1, 2, 2, 1, 3},
    resp = {dust, harmonia, dust, dust, dust},
    gallery = 'harmonia',
  },
  {
    seq = {3, 2, 1, 2, 3},
    resp = {dust, harmonia, dust, dust, dust},
    msg = 'The cosmos exercises restraint in communication. Messages in one direction never reach another.',
  },
  {
    seq = {1, 2, 1, 3, 2},
    resp = {harmonia, harmonia, harmonia, harmonia, harmonia},
    msg = 'To Chapter 2',
  },

  ------ Chapter 2 ------
  -- Introduce echo-dust type
  {
    seq = {2, 2, 4, 4, 4},
    resp = {echo_dust, dust, echo_dust, dust, echo_dust, dust, echo_dust, dust},
    gallery = 'echo_dust',
  },
  -- Challenge with time
  {
    seq = {4, 2, 4, 4, 2, 4},
    resp = {double_mur_slow(2), dust, echo_dust, dust, double_mur_slow(2), dust, echo_dust, dust},
    msg = 'So much stuff floating in space. I guess we might not be lonely at all.',
  },
  -- Sometimes you need to send more than one
  {
    seq = {1, 2, 3, 2, 1},
    resp = {condense, dust, condense, dust, condense, dust, condense, dust},
    gallery = 'condense',
  },
  -- And sometimes the response changes
  {
    seq = {1, 2, 3, 2, 1},
    resp = {dust, dust, traverse, dust, dust, dust, traverse, dust},
    gallery = 'traverse',
  },
  {
    seq = {1, 2, 2, 3, 2, 2, 1},
    resp = {dust, traverse, traverse, dust, dust, harmonia, harmonia, dust},
    msg = 'It takes patience, and solitude, to face the depths.',
  },
  {
    seq = {1, 4, 4, 2, 3},
    resp = {dust, dust, palindrome, dust, dust, dust, dust, dust},
    gallery = 'palindrome',
  },
  {
    seq = {1, 3, 4, 3, 1},
    resp = {dust, dust, palindrome, dust, dust, echo_dust, dust, dust},
    msg = '... Do you think we will ever investigate every corner of the cosmos?',
  },
  {
    seq = {1, 4, 2, 2, 2, 4, 3},
    resp = {harmonia, dust, palindrome, dust, harmonia, dust, filter(2), dust},
    msg = 'To Chapter 3',
  },

  ------ Chapter 3 ------
  {
    seq = {1, 3, 3, 4},
    resp = {dust, dust, stickbug, dust, dust, dust, dust, dust},
    gallery = 'stickbug',
  },
  {
    seq = {3, 2, 1, 2, 3},
    resp = {dust, stickbug, dust, harmonia, dust, dust, dust, dust},
    msg = '...',
  },
  {
    seq = {4, 4, 1, 4, 4},
    resp = {dust, pulsar(1, 0), dust, dust, dust, pulsar(3, 120), dust, dust},
    gallery = 'pulsar',
  },
  {
    seq = {1, 1, 1, 1, 2},
    resp = {dust, pulsar(1, 0), dust, pulsar(3, 160), dust, pulsar(3, 320), dust, double_mur(2), dust},
    msg = '...',
  },
  {
    seq = {1, 2, 3, 3, 2},
    resp = {dust, pulsar(1, 0), dust, pulsar(3, 240), dust, harmonia, dust, echo_dust, dust},
    msg = '...',
  },
  {
    seq = {1, 3, 1, 2, 2, 3, 1, 4},
    resp = {pulsar(1, 0), dust, echo_dust, dust, pulsar(3, 320), dust, pulsar(2, 160), dust},
    msg = 'This place is too noisy.',
  },
  {
    seq = {3, 1, 1, 1, 3, 2, 3},
    resp = {murmur(2), dust, palindrome, dust, dust, dust, pulsar(1, 0), dust},
    msg = 'To Chapter 4',
  },

  ------ Chapter 4 ------
  {
    seq = {2, 2, 1, 3, 1, 3},
    resp = {galaxia, galaxia, galaxia, galaxia, galaxia, galaxia, galaxia, galaxia},
    gallery = 'long_double_echo',
  },
  {
    seq = {1, 2, 3, 2, 1},
    resp = {galaxia, galaxia, galaxia, galaxia, galaxia, galaxia, galaxia, galaxia},
    msg = 'But in the end, you receive something. Emptiness only prevails on the surface.',
  },
  {
    seq = {1, 2, 3, 2, 1, 2, 3},
    resp = {galaxia, galaxia, galaxia, galaxia, galaxia, galaxia, galaxia, galaxia},
    msg = 'That was a tough one',
  },
  {
    seq = {4, 2, 4, 3, 4, 2},
    resp = {dust, dust, vagus, dust, stickbug, dust, dust, dust},
    gallery = 'vagus',
  },
  {
    -- seq = {4, 3, 4, 3, 2},
    seq = {2, 1, 4, 1, 2},
    resp = {dust, dust, vagus, dust, stickbug, dust, dust, dust},
    msg = '...',
  },
  {
    seq = {2, 1, 4, 3, 2},
    resp = {dust, vagus, dust, stickbug, dust, stickbug, dust, galaxia},
    msg = '...',
  },
}
