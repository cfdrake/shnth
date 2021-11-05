-- shnth loader
-- by @cfd90
--
-- load shnth programs...
-- ...from your norns
--
-- ><>

local files = {}
local idx = 1

local shlisp_progs_dir = "/home/we/dust/code/shnth-patches"
local shlisp_exe = "/home/we/dust/code/shnth/bin/shlisp"

function init()
  load_files()
end

function redraw()
  screen.clear()
  
  screen.level(15)
  screen.move(117, 60)
  screen.text("><>")

  screen.level(5)
  screen.move(0, 30)
  screen.text("KEY 2 to load")
  
  screen.move(0, 60)
  screen.text("KEY 3 to refresh files")
  
  screen.move(0, 40)
  if #files > 0 then
    screen.text("* ")
    screen.level(15)
    screen.text(files[idx])
  else
    screen.text("<no files>")
  end
  
  screen.update()
end

function enc(n, d)
  idx = util.clamp(idx + d, 1, #files)
  redraw()
end

function key(n, z)
  if n == 2 and z == 1 then
    print("loading program!")
    load_current_file()
  elseif n == 3 and z == 1 then
    print("reloading file list...")
    load_files()
    idx = 1
  end
  
  redraw()
end

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function load_current_file()
  print(os.execute("sudo " .. shlisp_exe .. " " .. shlisp_progs_dir .. "/" .. files[idx]))
end

function load_files()
  local handle = io.popen("ls " .. shlisp_progs_dir)
  local result = handle:read("*a")
  handle:close()
  files = split(result,"\n")
end