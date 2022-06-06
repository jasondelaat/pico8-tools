-- note entry
_sharps = {
   [0]=false,
   true,
   false,
   true,
   false,
   false,
   true,
   false,
   true,
   false,
   true,
   false
}
function is_sharp(note)
   return _sharps[(note.data&63)%12]
end

function draw_notes(note_index, highlight)
   if note_index then
      -- pre-calculate x-positions.
      local xs = {2}
      local offset = 0
      for i=note_index-8,note_index+7 do
         local n = note_q[i]
         add(xs, xs[#xs] + (n and n.x or 8))
         if i == note_index then
            offset = 64 - xs[#xs]
         end
      end

      -- draw the notes with note at note_index centered.
      for i=note_index-8,note_index+7 do
         local n = note_q[i]
         local j = i - note_index + 9
         if n then
            if highlight and i == note_index then
               pal(0, 12)
            end
            if n.x == 16 then
               spr(69, xs[j]+1+offset, n.y+2)
               spr(n.spr, xs[j]+8+offset, n.y)
            else
               spr(n.spr, xs[j]+offset, n.y)
            end
            pal(0, 0)
         end
      end
   end
end

function delete_selected_note(_)
   local i = album.edit.index
   deli(note_q, i)
   deli(album.edit.voice.notes, i)
   if i > 0 then
      album.edit.index -= 1
   end
end

function record(note)
   add(album.edit.voice.notes, note)
   album.edit.index = #album.edit.voice.notes
   return note
end

function octave_down(key)
   if octave > 0 then
      octave -= 1
   end
   return key
end

function octave_up(key)
   if octave < 5 then
      octave += 1
   end
   return key
end

transpose_by_semitone = curry(
   2,
   function(n, k)
      local note = album.edit.voice.notes[album.edit.index]
      if note then
         local old_pitch = (63 & note.data)
         local new_pitch = n + old_pitch
         if new_pitch >= 0 and new_pitch < 64 then
            note.data = ((1023<<6) & note.data) + new_pitch
            return note
         end
      end
   end
)

move_selected = curry(
   2,
   function(pix, note)
      if note then
         note_q[album.edit.index].y += pix
         return note
      end
   end
)

function draw_note_value()
   rectfill(104, 1, 125, 13, 0)
   rectfill(105, 2, 124, 12, 7)
   spr(note_sprites[note_value], 106, 3)
   spr(rest_sprites[note_value], 115, 3)
end

function draw_staff()
   local ys = {86, 82, 78, 74, 70}
   for y in all(ys) do
      line(0, y, 127, y, 0)
   end
end

simple_note = curry(
   2,
   function(pitch, _)
      return {
         type='simple',
         value=note_value,
         data=(3<<9)+12*octave + pitch
      }
   end
)

function rest(_)
   return {
      type='rest',
      value=note_value,
      data=0
   }
end

set_note_value = curry(
   2,
   function(val, _)
      note_value = val
   end
)

function play_note(note)
   _play_note[note.type](note)
   return note
end

_play_note = {
   simple=function(note)
      local bpm = album.edit.song.bpm
      local bpnote = album.edit.song.time[2]
      local speed = (7200 * bpnote)/(bpm * note.value)
      poke2(0x3200, note.data)
      poke(0x3200+65, speed)
      sfx(0)
   end,
   rest=function(note)
      _play_note.simple(note)
   end
}

function show_note(note)
   _show_note[note.type](note)
   return note
end

_show_note = {
   simple=function(note)
      local pitch = (note.data&63)
      local octave = pitch \ 12
      local y = note_positions[pitch % 12]
      add(note_q,
          {x=is_sharp(note) and 16 or 8,
           y=-14*octave + y,
           spr=note_sprites[note.value]
          }
      )
   end,
   rest=function(note)
      add(note_q, {x=8, y=74, spr=rest_sprites[note.value]})
   end
}

octave=3
note_value=4
note_sprites = {
   [1]=80,
   [2]=81,
   [4]=82,
   [8]=83,
   [16]=84
}
rest_sprites = {
   [1]=96,
   [2]=97,
   [4]=98,
   [8]=99,
   [16]=100
}
note_q={}
note_positions = {
   [0]= 112, 112, 110, 110, 108, 106, 106, 104, 104, 102, 102, 100
}

note_entry = {
   _initialize=function(self)
      if not note_entry._initialized then
         local events = events:filter(eq_state(self))
         
         -- notes
         local note_c = events:filter(eq('z'))
            :map(simple_note(0))
            :map(show_note)
         local note_c_sharp = events:filter(eq('s'))
            :map(simple_note(1))
            :map(show_note)
         local note_d = events:filter(eq('x'))
            :map(simple_note(2))
            :map(show_note)
         local note_d_sharp = events:filter(eq('d'))
            :map(simple_note(3))
            :map(show_note)
         local note_e = events:filter(eq('c'))
            :map(simple_note(4))
            :map(show_note)
         local note_f = events:filter(eq('v'))
            :map(simple_note(5))
            :map(show_note)
         local note_f_sharp = events:filter(eq('g'))
            :map(simple_note(6))
            :map(show_note)
         local note_g = events:filter(eq('b'))
            :map(simple_note(7))
            :map(show_note)
         local note_g_sharp = events:filter(eq('h'))
            :map(simple_note(8))
            :map(show_note)
         local note_a = events:filter(eq('n'))
            :map(simple_note(9))
            :map(show_note)
         local note_a_sharp = events:filter(eq('j'))
            :map(simple_note(10))
            :map(show_note)
         local note_b = events:filter(eq('m'))
            :map(simple_note(11))
            :map(show_note)
         local rest = events:filter(eq('r'))
            :map(rest)
            :map(show_note)
         
         merge(
            note_c,
            note_c_sharp,
            note_d,
            note_d_sharp,
            note_e,
            note_f,
            note_f_sharp,
            note_g,
            note_g_sharp,
            note_a,
            note_a_sharp,
            note_b,
            rest)
            :map(play_note)
            :map(record)
         
         -- change note values
         events:filter(eq('1')):map(set_note_value(1))
         events:filter(eq('2')):map(set_note_value(2))
         events:filter(eq('3')):map(set_note_value(4))
         events:filter(eq('4')):map(set_note_value(8))
         events:filter(eq('5')):map(set_note_value(16))
         
         -- change octaves
         events:filter(eq('-'))
            :map(octave_down)
            :map(transpose_by_semitone(-12))
            :map(move_selected(14))
         
         
         events:filter(eq('='))
            :map(octave_up)
            :map(transpose_by_semitone(12))
            :map(move_selected(-14))
         
         -- delete selected note
         events:filter(eq('\b'))
            :map(delete_selected_note)
         
         
         -- playback
         events:filter(eq(' '))
            :map(function() state_push(playback) end)
         
         self._initialized = true
         
         -- save (aka: _w_rite)
         events:filter(eq('w'))
            :map(save_album)
      end
   end,
   update=function()
      note_entry:_initialize()
      process_input()
   end,
   draw=function()
      cls(7)
      print(album_name..':'..album.edit.song_title, 2, 2, 0)
      print(album.edit.song.bpm..' bpm')
      print(time2string(album.edit.song.time))
      draw_staff()
      draw_note_value()
      draw_notes(album.edit.index)
   end
}
