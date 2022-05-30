-- state machine functions

state = {}
function state_push(s)
   add(state, s)
end

function state_pop()
   deli(state, #state)
end

function state_peek()
   return state[#state]
end
