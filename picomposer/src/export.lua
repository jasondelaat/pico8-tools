-- save/load/export
function _note_types(...)
   local types = {...}
   note_types = {}
   for i=1,#types do
      note_types[chr(i)] = types[i]
      note_types[types[i]] = chr(i)
   end
end
_note_types('simple', 'rest')

function int2bin(i)
   return chr((i&32512)>>8, i&255)
end

function pp_note(note)
   local s = '('
   s ..= '1:'..note_types[note.type]
   s ..= '1:'..chr(note.value)
   s ..= '2:'..int2bin(note.data)
   return s..')'
end

function pp_voice(voice)
   local inst = ''..voice.instrument
   s = '('..#inst..':'..inst..'('
   for note in all(voice.notes) do
      s ..= '2:'..int2bin(unique_notes[pp_note(note)])
   end
   return s..'))'
end

function pp_track(title, track, s)
   local bpm_bin = int2bin(track.bpm)
   local time_string = time2string(track.time)
   s = '('..#title..':'..title
   s ..= '2:'..bpm_bin
   s ..= #time_string..':'..time_string
   for voice in all(track.voices) do
      s ..= pp_voice(voice)
   end
   return s..')'
end

function pp_unique_notes()
   unique_notes = {} -- global, will be used elsewhere in the save routine
   local note_pos = 1
   local s = '('
   for title,song in pairs(album.songs) do
      for voice in all(song.voices) do
         for note in all(voice.notes) do
            local n_str = pp_note(note)
            if not unique_notes[n_str] then
               unique_notes[n_str] = note_pos
               note_pos += 1
               s ..= n_str
            end
         end
      end
   end
   return s..')'
end

function pp_album()
   local s = '('
   s ..= pp_unique_notes()
   for title,track in pairs(album.songs) do
      s ..= pp_track(title, track)
   end
   return s..')'
end

function save_album()
   memset(0x8000, 0, 0x4300)
   local s = pp_album()
   s = lzw_compress(s)
   --printh(#s, 'log.txt', true)
   poke2(0x8000, #s)
   for i=1,#s do
      poke(0x8001+i, ord(sub(s, i, i)))
   end
   cstore(0, 0x8000, 0x4300, album_name..'.p8')
end

function load_album_from_file()
   reload(0x8000, 0, 0x4300, album_name..'.p8')
   local album_string = decompress_album()
   local album_data
   if sub(album_string, 1, 1) == '(' then
      album_data, _ = parse_list(album_string, 2)
   else
      cls()
      print('parse error!')
      stop()
   end
   parse_unique_notes(album_data[1])
   for i=2,#album_data do
      local song = album_data[i]
      local title = song[1]
      local bpm = ord(sub(song[2], 1, 1)) + ord(sub(song[2], 2, 2))
      local time = parse_time_sig(song[3])
      local voices = {}
      for i = 4, 7 do
         local v = song[i]
         if v then
            local notes = {}
            local inst = v[1]
            for n in all(v[2]) do
               local ref = (ord(sub(n, 1, 1))<<8) + ord(sub(n, 2, 2))
               local note = unique_notes[ref]
               add(notes, note)
               show_note(note)
            end
            add(voices, {instrument=inst, notes=notes})
         end
      end
      album.songs[title] = {bpm=bpm, time=time, voices=voices}
      edit_song(album, title)
   end 
end

function parse_list(al_str, i)
   local lst = {}
   local nlst, token
   local next_byte = sub(al_str, i, i)
   while next_byte != ')' do
      if next_byte == '(' then
         nlst, i = parse_list(al_str, i+1)
         add(lst, nlst)
      else
         token, i = parse_token(al_str, i)
         add(lst, token)
      end
      next_byte = sub(al_str, i, i)
   end
   return lst, i+1
end

function parse_token(al_str, i)
   local num_string = ''
   local token = ''
   local byte = sub(al_str, i, i)
   while byte != ':' and byte != '' do
      num_string ..= byte
      i += 1
      byte = sub(al_str, i, i)
   end
   local num = tonum(num_string)
   for j=1,num do
      token ..= sub(al_str, i+j, i+j)
   end
   return token, i+num+1
end

function parse_unique_notes(lst)
   unique_notes = {}
   for n in all(lst) do
      local data = (ord(sub(n[3], 1, 1))<<8) + ord(sub(n[3], 2, 2))
      local note = {type=note_types[n[1]], value=ord(n[2]), data=data}
      add(unique_notes, note)
   end
end

function decompress_album()
   local bytes = peek2(0x8000)
   local s = ''
   for i=1,bytes do
      s ..= chr(peek(0x8001 + i))
   end
   return lzw_decompress(s)
end
