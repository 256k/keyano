local mod = require 'core/mods'
local notes = include('keyano/lib/notes')

local md  

local state = {
  pressedKeys = {},  
  keyPressedState = 0,
  octave = 3,
  velocity = 100,
  midi_channel = 1,
}

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
  
  print("===============KEYANO INIT=====================")

  for _, dev in pairs(midi.devices) do
    if dev.name == 'virtual' and dev.port ~= nil then
      md = midi.vports[dev.port]
      print("KEYANO FOUND VIRTUAL PORT")
      break
    else print("KEYANO: Virtual port not found!")
    end
  end
  
  function keyboard.code( code, value)
    -- print(code, value)
    -- print("notes[code]", notes[code])
    if (notes[code]) then
    notes array then play a midi note
       state.pressedKeys[code] = value
       
      if (state.pressedKeys[code] == 1) then
        note_on(notes[code] + state.octave * 12, state.velocity, state.midi_channel)
        -- print("NOTE TRIGGERED")
      end
      
      if (state.pressedKeys[code] == 0) then
	 -- print("note off: ", (notes[code]))
        note_off(notes[code] + state.octave * 12, state.midi_channel)
      end
    end
    
    if (value == 1 and state.keyPressedState == 0) then
      state.keyPressedState = 1
      if (code == "UP") then
	 state.octave = math.min(9, state.octave + 1)
      end
      if (code == "DOWN") then
	 state.octave = math.max(1, state.octave - 1)
      end
      if (code == "RIGHT") then
	 state.velocity = math.min(128, state.velocity + 10)
      end
      if (code == "LEFT") then
	 state.velocity = math.max(0, state.velocity - 10)
      end
    elseif (value == 0 and state.keyPressedState == 1) then
      state.keyPressedState = 0
    end
  end
end

mod.hook.register("script_post_init", "keyano script post init", keyano_init)

mod.hook.register("script_post_cleanup", "keyano post script cleanup", function()
  print("keyano post script cleanup ran.")
  md = nil 
end)
