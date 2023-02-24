-- a keyboard piano script
--
-- by 256k
--
--
--        [] []   [] [] []
--       [] [] [] [] [] [] []

MU = require("musicutil")
notes = include('lib/notes')

my_midi = midi.connect()
pressedKeys = {} -- array of currently active/pressed keys to use as reference to note off
keyPressedState = 0 -- state of currently pressed key
octave = 1
velocity = 100
midi_channel = 1



function init()
  redraw()
end

function keyboard.code(code, value)
  -- print(code, value)

  if (notes[code]) then -- if the key code matches one of the note keys in notes array then play a midi note
    pressedKeys[code] = value -- save the current value (state) of the currently pressed key (code)
    if (pressedKeys[code] == 1) then
      my_midi:note_on(notes[code] + octave * 12, velocity, midi_channel)
      draw(notes[code] + octave * 12)
    end
    if (pressedKeys[code] == 0) then
      my_midi:note_off(notes[code] + octave * 12)
    end
  end
  if (value == 1 and keyPressedState == 0) then -- this checks to see if we hae a changed state in pressedkeys. this is simply to avoid key repetition. if you hold down a key it will only trigger once until you release it.
    keyPressedState = 1
    if (code == "X") then
      octave = octave + 1
      draw()
    end
    if (code == "Z") then
      octave = octave - 1
      draw()
    end
    if (tonumber(code)) then
      velocity = tonumber(code) * 14
      draw()
    end
    -- checks if the key code is a number using the 'tonumber' function, it returns either a nil if not a number or the int value of that string number
  elseif (value == 0 and keyPressedState == 1) then
    keyPressedState = 0
  end
end

function draw(note)
  screen.clear()
  screen.move(0, 10)
  screen.text("Root note: " .. MU.note_num_to_name(notes["A"]))
  screen.move(0, 20)
  -- print(note)
  screen.text("last note played: " .. (note and MU.note_num_to_name(note) or ""))
  screen.move(0, 30)
  screen.text("Octave: " .. octave)
  screen.move(0, 40)
  screen.text("Velocity: " .. velocity)
  screen.move(0, 50)
  screen.text("Midi channel: " .. midi_channel)
  screen.update()
end

function redraw()
  screen.clear()
  screen.move(0, 16)
  screen.text("press a key to play a note")
  screen.update()
end
