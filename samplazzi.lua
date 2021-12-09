-- ~ samplazzi ~
-- a port of rodrigo's max patch
-- to norns
-- by: @cfd90
-- 
-- load four samples
-- and plug in a shnth!
--
-- controls:
-- bars  - play sample
-- major - toggle 1/2 rate
-- minor - directions
-- corps - rate slew
--
-- don't forget to (tar)!

local shnth = require "shnth/lib/shnth"

local ui_metro
local s
local rates = {1, 1, 1, 1}
local max_rates = {1, 1, 1, 1}
local dirs = {1, 1, 1, 1}
local slews = {1, 1}

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
  params:add_separator()
  
  for i=1,4 do
    params:add_file("sample " .. i, "sample " .. i)
    params:set_action("sample " .. i, function(filename)
      load_file(i, filename)
    end)
  end
end

function shnth.bar(n, d)
  rates[n] = d

  -- Note: we call abs() on rate to keep direction, but pan goes from -1 to 1.
	softcut.rate(n, math.abs(d) * max_rates[n] * dirs[n])
	softcut.pan(n, d)
end

function shnth.minor(n, z)
  if z == 0 then
    return
  end
  
  if dirs[n] == 1 then
    dirs[n] = -1
  else
    dirs[n] = 1
  end
end

function shnth.major(n, z)
  if z == 0 then
    return
  end
  
  if max_rates[n] == 1 then
    max_rates[n] = 0.5
  else
    max_rates[n] = 1
  end
end

function shnth.corp(n, d)
  local slew = math.abs(d)
  
  if n == 1 then
    slews[1] = slew
    softcut.rate_slew_time(1, slew * 3)
    softcut.rate_slew_time(2, slew * 3)
  else
    slews[2] = slew
    softcut.rate_slew_time(3, slew * 3)
    softcut.rate_slew_time(4, slew * 3)
  end
end

function redraw()
  screen.clear()
  
  -- Draw bar indicators and sample info.
  for i=1,4 do
    local r = rates[i]
    
    -- Draw bars.
    if math.abs(r) >= 0.1 then
      screen.level(r > 0 and 15 or 2)
      screen.move((i * 32) - 16 + math.abs(r * 15), 26)
      screen.circle((i * 32) - 16, 26, math.abs(r * 15))
      screen.stroke()
    end

    -- Draw sample info (max speed, direction).
    screen.level(5)
    screen.move((i * 32) - 16, 55)
    screen.text_center((max_rates[i] == 0.5 and "0.5" or "1.0") .. (dirs[i] == 1 and ">" or "<"))
  end
  
  -- Draw slew rects at bottom.
  screen.level(15)
  screen.move(8, 60)
  screen.rect(8, 60, 48 * slews[1], 2)
  screen.fill()
  
  screen.move(72, 60)
  screen.rect(72, 60, 48 * slews[2], 2)
  screen.fill()
  
  screen.update()
end

function load_file(i, filename)
  -- Samples get loaded two buffer 1 or 2 and
  -- "slot" (offset) 1 or 2 depending on bar index.
  local buf = (i == 1 or i == 2) and 1 or 2
  local off = (i == 1 or i == 3) and 1 or 30
  
  -- Load into appropriate buffer.
  softcut.buffer_read_mono(filename, 0, off, -1, 1, buf)
  
  -- Configure default voice settings.
  softcut.enable(i, 1)
  softcut.buffer(i, buf)
  softcut.level(i, 1)
  softcut.loop(i, 1)
  softcut.loop_start(i, off)
  softcut.loop_end(i, off + file_length(filename))
  softcut.position(i, off)
  softcut.play(i, 1)
end

function file_length(file)
  if util.file_exists(file) == true then
    local ch, samples, samplerate = audio.file_info(file)
    local duration = samples / samplerate
    
    return duration
  else
    return 0
  end
end