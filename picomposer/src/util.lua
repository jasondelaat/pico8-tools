eq_state = curry(
   2,
   function(state, key)
      return state_peek() == state
   end
)

not_state = curry(
   2,
   function(state, key)
      return state_peek() != state
   end
)

function process_input(suppress)
   if btnp(6) then
      poke(0x5f30, 1)
   end
   process_events()
   process_devkey()
end

function transform(v)
   return function()
      return v
   end
end
