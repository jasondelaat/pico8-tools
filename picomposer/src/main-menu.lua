-- main menu
function create_new_album()
   state_pop()
   alb_name = text_entry(2, 2, 'album name: ')
   sng_name = text_entry(2, 2, 'song name: ')
   bpm_entry = text_entry(2, 2, 'tempo (bpm): ')
   time_entry = text_entry(2, 2, 'time signature: ')
   state_push({
         update=function()
            album_name = alb_name.value
            new_song(
               album,
               sng_name.value,
               tonum(bpm_entry.value),
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
