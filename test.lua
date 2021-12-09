-- shbobo shnth test
-- by @cfd90
--
-- prints out shnth values
-- connect shnth on HID slot 1

local shnth = include("shnth/lib/shnth")

-- Data for display.
local bars = {0, 0, 0, 0}
local corps = {0, 0}
local majors = {0, 0, 0, 0}
local minors = {0, 0, 0, 0}
local wind = 0

function init()
  -- Connect shnth.
  s = hid.connect()
  s.event = shnth.event
  
  -- Update screen timer.
  screen_metro = metro.init()
  screen_metro.event = function()
    redraw()
  end
  
  screen_metro:start(1/15)
end

function shnth.bar(n, d)
  -- bar input, always firing
  -- n bar index
  -- d bar depth
  bars[n] = d
end

function shnth.corp(n, d)
  -- corp input, always firing
  -- n corp index
  -- d corp depth
  corps[n] = d
end

function shnth.major(n, z)
  -- major buttons, fires on touch
  -- n button index
  -- z button state
  majors[n] = z
end

function shnth.minor(n, z)
  -- minor buttons, fires on touch
  -- n button index
  -- z button state
  minors[n] = z
end

function shnth.wind(d)
  -- wind input, always firing
  -- d wind depth
  wind = v
end

function redraw()
  screen.clear()
  
  screen.move(1, 10)
  screen.level(1)
  screen.text("shbobo shnth test")
  
  screen.move(1, 20)
  screen.level(15)
  screen.text("bars: ")
  for i=1,4 do
    screen.level(3)
    screen.text(math.floor(bars[i] * 10) / 10 .. " ")
  end
  
  screen.move(1, 30)
  screen.level(15)
  screen.text("corps: ")
  for i=1,2 do
    screen.level(3)
    screen.text(math.floor(corps[i] * 10) / 10 .. " ")
  end

  screen.move(1, 40)
  screen.level(15)
  screen.text("minors: ")
  for i=1,4 do
    screen.level(3)
    screen.text(minors[i] .. " ")
  end
  
  screen.move(1, 50)
  screen.level(15)
  screen.text("majors: ")
  for i=1,4 do
    screen.level(3)
    screen.text(majors[i] .. " ")
  end
  
  screen.move(1, 60)
  screen.level(15)
  screen.text("wind: ")
  screen.level(3)
  screen.text(math.floor(wind * 10) / 10)
  
  screen.update()
end