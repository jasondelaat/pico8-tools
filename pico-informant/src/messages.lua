-->8
-- pico-if messages system
--------------------------------
do
   (function()
         local _messages = ''
         function append_message(m)
            _messages ..= m
         end

         function clear_messages()
            _messages = ''
         end
         
         function display_messages()
            print(_messages)
         end
   end)()
end
--------------------------------











