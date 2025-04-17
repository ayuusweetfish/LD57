local draw = require 'draw_utils'

local PLANET_FRAMES = {
  {{634,51,1},{617,41,2},{599,32,3},{581,25,4},{564,15,4},{548,6,4},{531,0,4},{511,0,8},{494,0,9},{477,0,10},{459,0,11},{437,0,12},{424,0,13}},
  {{578,92,1},{522,66,1},{468,47,1},{412,27,1},{360,11,1},{305,0,6}},
  {{632,155,1},{624,149,2},{617,143,3},{609,139,4},{602,134,4},{594,129,4},{588,125,4},{581,121,4},{571,116,4},{566,112,4},{558,109,4},{550,103,4},{542,99,4},{533,94,4},{525,91,4},{517,86,4},{508,83,4},{501,79,4},{492,75,4},{484,72,4},{476,69,4},{467,65,4},{460,63,4},{452,57,4},{443,55,4},{435,52,4},{427,48,4},{418,46,4},{410,43,4},{402,41,4},{393,36,4},{384,35,4},{376,31,4},{368,30,4},{358,25,4},{351,25,4},{341,22,4},{330,20,4},{322,18,4},{314,16,4},{302,14,4},{292,13,4},{284,10,4},{275,10,4},{267,7,4},{256,7,4},{248,6,4},{240,5,4},{229,5,4},{219,5,4},{209,5,4},{202,4,4},{194,3,4},{183,3,4},{177,1,4},{174,0,56},{174,2,57},{174,3,58}}
}

return function ()
  local o = {}

  local tv_planet_seq = -love.math.random(240, 2400)
  local tv_planet_t = 0

  o.update = function ()
    if tv_planet_seq > 0 then
      tv_planet_t = tv_planet_t + 1
      if tv_planet_t >= 20 * #PLANET_FRAMES[tv_planet_seq] then
        tv_planet_seq = -love.math.random(240, 2400)
      end
    else
      tv_planet_seq = tv_planet_seq + 1
      if tv_planet_seq == 0 then
        tv_planet_seq = love.math.random(1, 3)
        tv_planet_t = 0
      end
    end
  end

  o.draw = function ()
    if tv_planet_seq > 0 then
      local tv_planet_frame = 1 + math.floor(tv_planet_t / 20)
      local x, y, n = unpack(PLANET_FRAMES[tv_planet_seq][tv_planet_frame])
      draw.img(string.format('tv_planet/%c-%d', tv_planet_seq + 64, n),
        x * 2/3, y * 2/3, nil, nil, 0, 0)
    end
  end

  return o
end
