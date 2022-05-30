-- playback state

function draw_play_button()
   rectfill(104, 1, 125, 13, 0)
   rectfill(105, 2, 124, 12, 7)
   spr(79, 114, 4)
end

playback_index = {}

function play_song(song)
   for i=1,#song.voices do
      play_voice(song.voices[i], i)
   end
end

function play_voice(voice, v_index)
   if not playback_index[v_index] then
      playback_index[v_index] = 0
   end
   if stat(45 + v_index) < 0 then
      local i = playback_index[v_index] + 1
      if i <= #voice.notes then
         play_note(voice.notes[i])
         playback_index[v_index] = i
      else
         playback_index[v_index] = nil
         state_pop()
      end
   end
end

playback = {
   update=function()
      play_song(album.edit.song)
      if stat(30) and stat(31) == ' ' then
         state_pop()
         playback_index = {}
      end
   end,
   draw=function()
      cls(7)
      print(album_name..':'..album.edit.song_title, 2, 2, 0)
      print(album.edit.song.bpm..' bpm')
      print(time2string(album.edit.song.time))
      draw_staff()
      draw_play_button()
      draw_notes(playback_index[1], true)
   end
}
