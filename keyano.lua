-- a keyboard piano script

MU = require("musicutil")
notes = include('lib/notes')

my_midi = midi.connect()
my_string = ""
pressedKeys = {}
keyPressedState= 0
octave = 12

function init()

end

function keyboard.code(code,value)
  if (notes[code]) then
      print("code, "..code)
  print("value, "..value)
  pressedKeys[code] = value
  if (pressedKeys[code] == 1) then
  my_midi:note_on(notes[code] + octave)
  draw(notes[code] + octave)
  end
  if (pressedKeys[code] == 0) then 
      my_midi:note_off(notes[code] + octave)
  end
  end
  if (value == 1 and keyPressedState == 0) then 
    keyPressedState = 1 
    if (code == "X") then octave = octave + 12 draw("Octave +") end
    if (code == "Z") then octave = octave - 12 draw("Octave -") end
  elseif (value == 0 and keyPressedState == 1) then keyPressedState = 0 
    end
  
end

function draw(note)
  screen.clear()
  screen.move(50, 24)
  screen.text(note)
  redraw();
end

  
function redraw()
  screen.update()
end

