-->8
-- update and draw

poke(0x5f2d, 1)

function _update()
   local _ENV = title_screen or location()
   if stat(30) then
      local key = stat(31)
      if key == '\r' or key == 'p' then
         poke(0x5f30, 1)
      end
      if key == '\r' then
         if _ENV != title_screen then
            parse_command(_ENV)
         end
         if obj_update then
            obj_update(_ENV)
         end
      elseif key == '\b' then
         command_backspace()
      else
         append_command(key)
      end
   end
end

function _draw()
   cls()
   local _ENV = title_screen or location()
   print(name)
   print('--------------------------------')
   if attributes&light > 0 then
      print(description)
   else
      print("It's pitch black. You can't see anything.")
   end
   for _ENV in all(contents) do
      if attributes&scenery == 0 then
         print('you see a '..name)
      end
   end
   display_messages()
   if _ENV != title_screen then
      print('> '..command_string(), 2, 120)
   end
end
