function menu(x, y, ...) -- input: any number of {option, callback} 
   _options = {...}
   _cursor = 0
   local m_state = {
      update=function()
         process_input()
      end,
      draw=function()
         cls()
         cursor(x, y)
         for i=1,#_options do
            if i-1 == _cursor then
               print('> \0')
            else
               print('  \0')
            end
            print(_options[i][1])
         end
      end
   }
   -- optimization: for something this simple it's going to be more
   -- token efficient to implement directly in m_state.update(). but
   -- i like the declarative nature of streams for processing input so
   -- i'll leave it like this until i start running out of tokens.
   local events = events:filter(eq_state(m_state))
   events
      :filter(eq(4)) -- cursor up
      :map(function(_)
            _cursor -= 1
            _cursor %= #_options
          end)
   events
      :filter(eq(8)) -- cursor down
      :map(function(_)
            _cursor += 1
            _cursor %= #_options
          end)
   events
      :filter(eq('\r')) -- select item
      :map(function(_)
            _options[_cursor+1][2]() -- call the associated callback
          end)
   return m_state
end

function text_entry(x, y, prompt)
   local te_state
   te_state = {
      value='',
      update=function()
         if btnp(6) then
            poke(0x5f30, 1)
         end
         process_devkey()
      end,
      draw=function()
         cls()
         print(prompt..te_state.value, x, y, 7)
      end
   }
   local events = events:filter(eq_state(te_state))
   events:filter(function(c) return c == '\r' and te_state.value != '' end)
      :map(state_pop)
   events:filter(eq('\b'))
      :map(function()
            te_state.value = sub(te_state.value, 1, #te_state.value - 1)
          end)
   events:map(function(c)
            if c != '\r' and c != '\b' then
               te_state.value ..= c
            end
   end)
   return te_state
end
