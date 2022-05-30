-- main loop and globals

function _init()
   -- enable keyboard
   poke(0x5f2d, 1)

   -- These two pokes create a note in sfx(0) that will never play but
   -- the non-empty pattern means that I'm able to 'play' rests when
   -- there's no note in the first sfx slot.
   poke2(0x3202, 1537)
   poke(0x3200+66, 1)

   palt(0, false)
   palt(12, true)

   color(7)

   -- create the album data structure
   album = new_album()

   state_push(main_menu)
end

function _update()
   local s = state_peek()
   if s then
      s.update()
   else
      stop()
   end
end

function _draw()
   color(7)
   local s = state_peek()
   if s then
      s.draw()
   end
   --print('mem:'..stat(0), 2, 100, 12)
   --print('cpu:'..stat(1), 12)
end

