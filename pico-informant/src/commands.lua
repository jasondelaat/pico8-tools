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
            local v, o1, o2 = unpack(split(_command_string, ' '))
            local obj1 = o1 and (get_object(o1) or object("'"..o1.."'"))
            local obj2 = o2 and (get_object(o2) or object("'"..o2.."'"))
            perform_verb(env, v, obj1, obj2)
            clear_command()
         end

         function command_backspace()
            _command_string = sub(_command_string, 1, #_command_string - 1)
         end
   end)()
end
--------------------------------











