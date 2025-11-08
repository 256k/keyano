local mod = require 'core/mods'
local notes = include('keyano/lib/notes')

local md  

local state = {
  pressedKeys = {},  
  keyPressedState = 0,
}

local function init_params()
   params:add_separator("")
   params:add_separator("MOD - Keyano")
   params:add{
      type = "number",
      id = "octave",
      name = "Octave",
      min = 1,
      max = 9,
      default = 3,
   }
   params:add{
      type = "number",
      id = "velocity",
      name = "Velocity",
      min = 0,
      max = 128,
      default = 100,
   }
   params:add{
      type = "number",
      id = "channel",
      name = "Midi channel",
      min = 1,
      max = 16,
      default = 1,
   }
end

local function send_to_virtual_port(midi_msg)
  if not md then return false end
  
  local data = midi.to_data(midi_msg)
  
  -- Check if there's an event handler bound (script is listening)
  if md.event ~= nil then
    -- Call the event handler directly with the MIDI data
    md.event(data)
    return true
  end
  
  return false
end

-- Send note on to virtual port
local function note_on(note_num, velocity, channel)
  local msg = {
    type = 'note_on',
    note = note_num,
    vel = velocity,
    ch = channel or 1
  }
  send_to_virtual_port(msg)
end

-- Send note off to virtual port
local function note_off(note_num, channel)
  local msg = {
    type = 'note_off',
    note = note_num,
    vel = 0,
    ch = channel or 1
  }
  send_to_virtual_port(msg)
end

local function keyano_init()
   init_params()
  print("===============KEYANO INIT=====================")

  for _, dev in pairs(midi.devices) do
    if dev.name == 'virtual' and dev.port ~= nil then
      md = midi.vports[dev.port]
      print("KEYANO FOUND VIRTUAL PORT")
      break
    else print("KEYANO: Virtual port not found!")
    end
  end
  
  function keyboard.code(code, value)
     -- print(code, value)
     -- print("notes[code]", notes[code])
    local param_octave = params:get("octave")
    local param_velocity = params:get("velocity")
    local param_channel = params:get("channel")
    
     
    if (notes[code]) then
       state.pressedKeys[code] = value
       
      if (state.pressedKeys[code] == 1) then
	 note_on(notes[code] + param_octave * 12, param_velocity, param_channel)
        -- print("NOTE TRIGGERED")
      end
      
      if (state.pressedKeys[code] == 0) then
	 -- print("note off: ", (notes[code]))
        note_off(notes[code] +  param_octave * 12, param_channel)
      end
    end
    
    if (value == 1 and state.keyPressedState == 0) then
      state.keyPressedState = 1
      if (code == "UP") then
	 params:set("octave", math.min(9, param_octave + 1))
      end
      if (code == "DOWN") then
	 params:set("octave", math.min(9, param_octave - 1))
      end
      if (code == "RIGHT") then
	 -- print("param_velocity", param_velocity)
	 params:set("velocity",math.min(128, param_velocity + 10))
      end
      if (code == "LEFT") then
	 -- print("param_velocity", param_velocity)
	 params:set("velocity",math.max(0, param_velocity - 10))
      end
      if (code == "ESC") then
	 print("all notes off")
	 --  in case midi notes freeze
	 all_midi_notes_off()
      end
    elseif (value == 0 and state.keyPressedState == 1) then
      state.keyPressedState = 0
    end
  end
end

mod.hook.register("script_post_init", "keyano script post init", keyano_init)

mod.hook.register("script_post_cleanup", "keyano post script cleanup", function()
		     all_midi_notes_off()
		     print("keyano post script cleanup ran.")
		     md = nil 
end)

function all_midi_notes_off()
   -- tab.print(notes)
   -- tab.print(state.pressedKeys)
   for key, v in pairs(state.pressedKeys) do
      print("key: ", key, "v: ", v)
     note_off(notes[key], param_channel)  
   end

   for i=1,128 do
      note_off(i, param_channel)
      
   end
end
