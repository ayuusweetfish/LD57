W = 1280
H = 720

local isMobile = (love.system.getOS() == 'Android' or love.system.getOS() == 'iOS')
local isWeb = (love.system.getOS() == 'Web')

love.window.setMode(
  W, H,
  { fullscreen = false, highdpi = true }
)

local globalScale, Wx, Hx, offsX, offsY

local updateLogicalDimensions = function ()
  love.window.setTitle('Game')
  local wDev, hDev = love.graphics.getDimensions()
  globalScale = math.min(wDev / W, hDev / H)
  Wx = wDev / globalScale
  Hx = hDev / globalScale
  offsX = (Wx - W) / 2
  offsY = (Hx - H) / 2
end
updateLogicalDimensions()

-- Load font
local fontSizeFactory = function (path, preload)
  local font = {}
  if preload ~= nil then
    for i = 1, #preload do
      local size = preload[i]
      if path == nil then
        font[size] = love.graphics.newFont(size)
      else
        font[size] = love.graphics.newFont(path, size)
      end
    end
  end
  return function (size)
    if font[size] == nil then
      if path == nil then
        font[size] = love.graphics.newFont(size)
      else
        font[size] = love.graphics.newFont(path, size)
      end
    end
    return font[size]
  end
end
_G['global_font'] = fontSizeFactory(nil, {28, 36})
love.graphics.setFont(_G['global_font'](40))

_G['cyrillic_font'] = fontSizeFactory('fnt/EBGaramond-MediumItalic_subset.ttf', {})

_G['scene_intro'] = require 'scene_intro'
_G['scene_gameplay'] = require 'scene_gameplay'
_G['scene_interlude'] = require 'scene_interlude'

local audio = require 'audio'
local bgm, bgm_update = audio.loop(
  nil, 0,
  'aud/background_1.ogg', 96,
  1600 * 4
)
bgm:setVolume(1)
bgm:play()

local curScene = scene_gameplay(26)  -- scene_intro()
local lastScene = nil
local transitionTimer = 0
local currentTransition = nil
local transitions = {}
_G['transitions'] = transitions

_G['replaceScene'] = function (newScene, transition)
  lastScene = curScene
  curScene = newScene
  transitionTimer = 0
  currentTransition = transition or transitions['fade'](0.9, 0.9, 0.9)
end

local mouseScene = nil
function love.mousepressed(x, y, button, istouch, presses)
  if button ~= 1 then return end
  if lastScene ~= nil then return end
  mouseScene = curScene
  curScene.press((x - offsX) / globalScale, (y - offsY) / globalScale)
end
function love.mousemoved(x, y, button, istouch)
  curScene.hover((x - offsX) / globalScale, (y - offsY) / globalScale)
  if mouseScene ~= curScene then return end
  curScene.move((x - offsX) / globalScale, (y - offsY) / globalScale)
end
function love.mousereleased(x, y, button, istouch, presses)
  if button ~= 1 then return end
  if mouseScene ~= curScene then return end
  curScene.release((x - offsX) / globalScale, (y - offsY) / globalScale)
  mouseScene = nil
end

local T = 0
local timeStep = 1 / 240

function love.update(dt)
  T = T + dt
  local count = 0
  bgm_update()
  while T > timeStep and count < 4 do
    T = T - timeStep
    count = count + 1
    if lastScene ~= nil then
      lastScene:update()
      -- At most 4 ticks per update for transitions
      if count <= 4 then
        transitionTimer = transitionTimer + 1
      end
    else
      curScene:update()
    end
  end
end

transitions['fade'] = function (r, g, b)
  return {
    dur = 120,
    draw = function (x)
      love.graphics.clear(0, 0, 0)
      local opacity = 0
      if x < 0.5 then
        lastScene:draw()
        opacity = x * 2
      else
        curScene:draw()
        opacity = 2 - x * 2
      end
      love.graphics.setColor(r, g, b, opacity)
      love.graphics.rectangle('fill', 0, 0, W, H)
    end
  }
end

transitions['crossfade'] = function ()
  local canvas = love.graphics.newCanvas(W, H)
  return {
    dur = 120,
    draw = function (x)
      local opacity = (x < 0.5 and x * x * 2 or 1 - (1 - x) * (1 - x) * 2)

      love.graphics.push()
      love.graphics.replaceTransform(love.math.newTransform())
      love.graphics.setCanvas(canvas)
      lastScene:draw()
      love.graphics.setCanvas()
      love.graphics.pop()
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(canvas, 0, 0)

      love.graphics.push()
      love.graphics.replaceTransform(love.math.newTransform())
      love.graphics.setCanvas(canvas)
      curScene:draw()
      love.graphics.setCanvas()
      love.graphics.pop()
      love.graphics.setColor(1, 1, 1, opacity)
      love.graphics.draw(canvas, 0, 0)
    end
  }
end

function love.draw()
  love.graphics.scale(globalScale)
  love.graphics.setColor(1, 1, 1)
  love.graphics.push()
  love.graphics.translate(offsX, offsY)
  if lastScene ~= nil then
    local x = transitionTimer / currentTransition.dur
    currentTransition.draw(x)
    if x >= 1 then
      if lastScene.destroy then lastScene.destroy() end
      lastScene = nil
    end
  else
    curScene.draw()
  end
  love.graphics.pop()
end

function love.keypressed(key)
  if key == 'lshift' then
    if not isMobile and not isWeb then
      love.window.setFullscreen(not love.window.getFullscreen())
      updateLogicalDimensions()
    end
  elseif curScene.key ~= nil then
    curScene.key(key)
  end
end
