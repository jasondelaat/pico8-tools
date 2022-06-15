-- main menu
function create_new_album()
   state_pop()
   alb_name = text_entry(2, 2, 'album name: ')
   sng_name = text_entry(2, 2, 'song name: ')
   bpm_entry = text_entry(2, 2, 'tempo (default 120): ', true)
   bpm_entry.value = tostr(bpm_entry.value)
   time_entry = text_entry(2, 2, 'time signature\n(default 4/4): ', true)
   state_push({
         update=function()
            local bpm = tonum(bpm_entry.value)
            if not bpm then
               bpm = 120
            end
            album_name = alb_name.value
            new_song(
               album,
               sng_name.value,
               bpm,
               time_entry.value
            )
            state_pop()
            state_push(note_entry)
         end,
         draw=function()
         end
   })
   state_push(time_entry)
   state_push(bpm_entry)
   state_push(sng_name)
   state_push(alb_name)
end

function load_album()
   state_pop()
   alb_name = text_entry(2, 2, 'album name: ')
   state_push({
         update=function()
            album_name = alb_name.value
            load_album_from_file()
            state_pop()
            state_push(note_entry)
         end,
         draw=function()
         end
   })
   state_push(alb_name)
end

main_menu = menu(
   2, 2, {'load album', load_album}, {'new album', create_new_album}
)
