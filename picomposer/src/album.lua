function new_album()
   local album = {edit={}, songs={}}
   return album
end

function edit_song(album, title)
   local song = album.songs[title]
   album.edit.song_title = title
   album.edit.song = song
   edit_voice(album, 1)
end

function edit_voice(album, voice_num)
   local voice = album.edit.song.voices[voice_num]
   if not voice then
      voice = {instrument=0, notes={}}
      album.edit.song.voices[voice_num] = voice
   end
   album.edit.voice = voice
   album.edit.index = #voice.notes
end

function new_song(album, title, bpm, time_string)
   local time_sig = parse_time_sig(time_string)
   album.songs[title] = {bpm=bpm, time=time_sig, voices={}}
   edit_song(album, title)
end

function parse_time_sig(s)
   local split_s = split(s, '/')
   return {tonum(split_s[1]), tonum(split_s[2])}
end

function add_note(album, note)
   local i = album.edit.index + 1
   album.edit.voice.notes[i] = note
   album.edit.index = i
end

function delete_note(album)
   deli(album.edit.voice.notes, album.edit.index)
   local num_notes = #album.edit.voices.notes 
   if album.edit.index > num_notes then
      album.edit.index = num_notes
   end
end

function select_note(album, index)
   local num_notes = #album.edit.voice.notes 
   if index < 1 then
      index = 1
   elseif index > num_notes then
      index = num_notes
   end
   album.edit.index = index
end

function set_instrument(album, inst)
   album.edit.voice.instrument = inst
end

function time2string(time_sig)
   return time_sig[1]..'/'..time_sig[2]
end
