-->8
-- pico-if command parser system
--------------------------------
do
   (function()
         local _command_string = ''

         function command_string()
            return _command_string
         end

         function append_command(c)
            _command_string ..= c
         end

         function clear_command()
            _command_string = ''
         end

         function parse_command(env)
            local v, obj1, obj2 = unpack(split(_command_string, ' '))
            perform_verb(env, v, get_object(obj1), get_object(obj2))
            clear_command()
         end

         function command_backspace()
            _command_string = sub(_command_string, 1, #_command_string - 1)
         end
   end)()
end
--------------------------------











