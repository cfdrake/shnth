-- ~ grainzer ~
-- control grainz with a shnth
-- by: @cfd90
--
-- controls:
-- bar 1 - speed
-- bar 2 - density
-- bar 3 - size
-- bar 4 - jitter
-- corps 1 - spread
-- corps 2 - volume
-- minor - reverb tail
-- major - pitches
--
-- don't forget to (tar)!

local shnth = require "shnth/lib/shnth"

local ui_metro
local s
local bars = {1, 1, 1, 1}
local corps = {1, 1}
local greverb = 50
local gpitch = 0
local VOICES = 1

engine.name = 'Glut'

function init()
  -- Connect to shnth device.
  s = hid.connect()
  s.event = shnth.event

  -- Setup UI refresh metro.
  ui_metro = metro.init()
  ui_metro.time = 1/15
  ui_metro.event = function()
    redraw()
  end
  
  ui_metro:start()

  -- Reset softcut state.
  softcut.buffer_clear()

  -- Build out params.  
  local sep = ": "
  
  params:add_separator()

  params:add_taper("reverb_mix", "*"..sep.."mix", 0, 100, 50, 0, "%")
  params:set_action("reverb_mix", function(value) engine.reverb_mix(value / 100) end)

  params:add_taper("reverb_room", "*"..sep.."room", 0, 100, 50, 0, "%")
  params:set_action("reverb_room", function(value)
    engine.reverb_room(value / 100)
    greverb = value
  end)

  params:add_taper("reverb_damp", "*"..sep.."damp", 0, 100, 50, 0, "%")
  params:set_action("reverb_damp", function(value) engine.reverb_damp(value / 100) end)

  for v = 1, VOICES do
    params:add_separator()

    params:add_file(v.."sample", v..sep.."sample")
    params:set_action(v.."sample", function(file)
      engine.read(v, file)
      engine.gate(v, 1)
    end)

    params:add_option(v.."play", v..sep.."play", {"off","on"}, 2)
    params:set_action(v.."play", function(x) engine.gate(v, x-1) end)

    params:add_taper(v.."volume", v..sep.."volume", -60, 20, -60, 0, "dB")
    params:set_action(v.."volume", function(value) engine.volume(v, math.pow(10, value / 20)) end)

    params:add_taper(v.."speed", v..sep.."speed", -200, 200, 100, 0, "%")
    params:set_action(v.."speed", function(value) engine.speed(v, value / 100) end)

    params:add_taper(v.."jitter", v..sep.."jitter", 0, 500, 0, 5, "ms")
    params:set_action(v.."jitter", function(value) engine.jitter(v, value / 1000) end)

    params:add_taper(v.."size", v..sep.."size", 1, 500, 100, 5, "ms")
    params:set_action(v.."size", function(value) engine.size(v, value / 1000) end)

    params:add_taper(v.."density", v..sep.."density", 0, 512, 20, 6, "hz")
    params:set_action(v.."density", function(value) engine.density(v, value) end)

    params:add_taper(v.."pitch", v..sep.."pitch", -24, 24, 0, 0, "st")
    params:set_action(v.."pitch", function(value)
      engine.pitch(v, math.pow(0.5, -value / 12))
      gpitch = value
    end)

    params:add_taper(v.."spread", v..sep.."spread", 0, 100, 0, 0, "%")
    params:set_action(v.."spread", function(value) engine.spread(v, value / 100) end)

    params:add_taper(v.."fade", v..sep.."att / dec", 1, 9000, 1000, 3, "ms")
    params:set_action(v.."fade", function(value) engine.envscale(v, value / 1000) end)
  end
end

function shnth.bar(n, d)
  bars[n] = math.abs(d)
  
  if n == 1 then
    params:set("1speed", math.abs(d * 200))
  elseif n == 2 then
    params:set("1density", 100 + math.abs(d * 256))
  elseif n == 3 then
    params:set("1size", 100 + math.abs(d * 400))
  elseif n == 4 then
    params:set("1jitter", math.abs(d * 500))
  end
end

function shnth.corp(n, d)
  corps[n] = math.abs(d)
  
  if n == 1 then
    params:set("1spread", math.abs(d * 100))
  else
    params:set("1volume", -60 + math.abs(d * 60))
  end
end

function shnth.minor(n, z)
  if z == 0 then
    return
  end
  
  params:set("reverb_room", n * 25)
end

function shnth.major(n, z)
  if z == 0 then
    return
  end
  
  local pitch = 0
  
  if n == 1 then
    pitch = -5
  elseif n == 2 then
    pitch = 0
  elseif n == 3 then
    pitch = 7
  else
    pitch = 12
  end
  
  params:set("1pitch", pitch)
end

function redraw()
  screen.clear()
  
  -- Draw bar indicators and sample info.
  for i=1,4 do
    local r = bars[i]
    
    -- Draw bars.
    if math.abs(r) >= 0.1 then
      screen.level(r > 0 and 15 or 2)
      screen.move((i * 32) - 16 + math.abs(r * 15), 26)
      screen.circle((i * 32) - 16, 26, math.abs(r * 15))
      screen.stroke()
    end
  end
  
  -- Draw sample info (max speed, direction).
  screen.level(5)
  screen.move((1 * 32) - 16, 55)
  screen.text_center("r: " .. greverb)
  
  screen.level(5)
  screen.move((4 * 32) - 16, 55)
  screen.text_center("p: " .. gpitch)
  
  -- Draw corps at bottom.
  screen.level(15)
  screen.move(8, 60)
  screen.rect(8, 60, 48 * corps[1], 2)
  screen.fill()
  
  screen.move(72, 60)
  screen.rect(72, 60, 48 * corps[2], 2)
  screen.fill()
  
  screen.update()
end