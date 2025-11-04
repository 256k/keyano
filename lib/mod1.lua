--
-- require the `mods` module to gain access to hooks, menu, and other utility
-- functions.
--

local mod = require 'core/mods'
-- local MU = require("musicutil")
local notes = include('keyano/lib/notes')
--
-- [optional] a mod is like any normal lua module. local variables can be used
-- to hold any state which needs to be accessible across hooks, the menu, and
-- any api provided by the mod itself.
--
-- here a single table is used to hold some x/y values
--

 local kbd -- keyboard device
 local md -- midi device

 local state = {
  pressedKeys = {},    -- array of currently active/pressed keys to use as reference to note off
  keyPressedState = 0, -- state of currently pressed key
  octave = 1,
  velocity = 100,
  midi_channel = 1,
}

 local function keyano_init()
  print("===============KEYANO INIT=====================")
kbd = hid.connect()
print("KEYANO POST KBD CONNECT")
md = midi.connect()
print("KEYANO POST MD CONNECT")

tab.print(md)




function kbd.event(typ, code, value)
  print( code, value)
print("notes[copde]", notes[code])
  -- if (notes[code]) then             -- if the key code matches one of the note keys in notes array then play a midi note
  if (true) then             -- if the key code matches one of the note keys in notes array then play a midi note
    state.pressedKeys[code] = value -- save the current value (state) of the currently pressed key (code)
    if (state.pressedKeys[code] == 1) then
      md:note_on(code + state.octave * 12, state.velocity, state.midi_channel)
      -- draw(notes[code] + state.octave * 12)
      print("NOTE TRIGERED")
    end
    if (state.pressedKeys[code] == 0) then
      md:note_off(code + state.octave * 12)
    end
  end
  if (value == 1 and state.keyPressedState == 0) then -- this checks to see if we hae a changed state in pressedkeys. this is simply to avoid key repetition. if you hold down a key it will only trigger once until you release it.
    state.keyPressedState = 1
    if (code == "X") then
      state.octave = state.octave + 1
      -- draw()
    end
    if (code == "Z") then
      state.octave = state.octave - 1
      -- draw()
    end
    if (tonumber(code)) then
      state.velocity = tonumber(code) * 14
      -- draw()
    end
    -- checks if the key code is a number using the 'tonumber' function, it returns either a nil if not a number or the int value of that string number
  elseif (value == 0 and state.keyPressedState == 1) then
    state.keyPressedState = 0
  end
end

end

-- mod.hook.register("system_post_startup", "Keyano-script-post-startup", function()
--   -- state.system_post_startup = true
--   print("=====================================")
--   print("=====================================")
--   print("=============hello===================")
--   print("=====================================")
--   print("=====================================")
--   keyano_init()
-- end)

mod.hook.register("script_post_init", "keyano script post init", keyano_init)

mod.hook.register("script_post_cleanup", "keyano post script cleanup", function()
  print("keyano post s cript cleanup ran.")
end)

-- local api = {}

-- api.get_state = function()
--   return state
-- end

-- return api

--
-- [optional] hooks are essentially callbacks which can be used by multiple mods
-- at the same time. each function registered with a hook must also include a
-- name. registering a new function with the name of an existing function will
-- replace the existing function. using descriptive names (which include the
-- name of the mod itself) can help debugging because the name of a callback
-- function will be printed out by matron (making it visible in maiden) before
-- the callback function is called.
--
-- here we have dummy functionality to help confirm things are getting called
-- and test out access to mod level state via mod supplied fuctions.
--



--
-- [optional] menu: extending the menu system is done by creating a table with
-- all the required menu functions defined.
--

-- local m = {}

-- m.key = function(n, z)
--   if n == 2 and z == 1 then
--     -- return to the mod selection menu
--     mod.menu.exit()
--   end
-- end

-- m.enc = function(n, d)
--   if n == 2 then
--     state.x = state.x + d
--   elseif n == 3 then
--     state.y = state.y + d
--   end
--   -- tell the menu system to redraw, which in turn calls the mod's menu redraw
--   -- function
--   mod.menu.redraw()
-- end

-- m.redraw = function()
--   screen.clear()
--   screen.move(64, 40)
--   screen.text_center(state.x .. "/" .. state.y)
--   screen.update()
-- end

-- m.init = function()
--   print("Hello Keyano mod from init")
--   if not my_midi then
--     my_midi = midi.connect()
--     my_keyboard = hid.connect()
--   end
-- end

-- on menu entry, ie, if you wanted to start timers
-- m.deinit = function() end -- on menu exit

-- register the mod menu
--
-- NOTE: `mod.this_name` is a convienence variable which will be set to the name
-- of the mod which is being loaded. in order for the menu to work it must be
-- registered with a name which matches the name of the mod in the dust folder.
--
-- mod.menu.register(mod.keyano, m)


--
-- [optional] returning a value from the module allows the mod to provide
-- library functionality to scripts via the normal lua `require` function.
--
-- NOTE: it is important for scripts to use `require` to load mod functionality
-- instead of the norns specific `include` function. using `require` ensures
-- that only one copy of the mod is loaded. if a script were to use `include`
-- new copies of the menu, hook functions, and state would be loaded replacing
-- the previous registered functions/menu each time a script was run.
--
-- here we provide a single function which allows a script to get the mod's
-- state table. using this in a script would look like:
--
-- local mod = require 'name_of_mod/lib/mod'
-- local the_state = mod.get_state()
--
