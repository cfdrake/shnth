-- shnth mod

local mod = require 'core/mods'

---------------------
-- State
---------------------

local m = {}
local state = {
  shlisp_progs_dir = "/home/we/dust/code/shnth-patches",
  shlisp_exe = "/home/we/dust/code/shnth/bin/shlisp",
  idx = 1,
  files = {}
}

---------------------
-- Helpers
---------------------

local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function load_current_file()
  print(os.execute("sudo " .. state.shlisp_exe .. " " .. state.shlisp_progs_dir .. "/" .. state.files[state.idx]))
end

local function load_files()
  local handle = io.popen("ls " .. state.shlisp_progs_dir)
  local result = handle:read("*a")
  handle:close()
  state.files = split(result,"\n")
end

---------------------
-- Menu
---------------------

m.key = function(n, z)
  if n == 2 and z == 1 then
    mod.menu.exit()
  elseif n == 3 and z == 1 then
    print("loading program!")
    load_current_file()
  end
  
  mod.menu.redraw()
end

m.enc = function(n, d)
  state.idx = util.clamp(state.idx + d, 1, #state.files)
  mod.menu.redraw()
end

m.redraw = function()
  screen.clear()
  
  screen.level(15)
  screen.move(117, 30)
  screen.text("><>")

  screen.level(5)
  screen.move(0, 30)
  screen.text("KEY 3 to load")
  
  screen.move(0, 40)
  if #state.files > 0 then
    screen.text("* ")
    screen.level(15)
    screen.text(state.files[state.idx])
  else
    screen.text("<no files>")
  end
  
  screen.update()
end

m.init = function()
  load_files()
  state.idx = 1
end

m.deinit = function() end

mod.menu.register(mod.this_name, m)