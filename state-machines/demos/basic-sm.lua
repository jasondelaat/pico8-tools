--[[ 
   simple state machine with two states, 'state 1' and 'state 2'.
   transitions:
       'state 1' -> 'state 2' when x-button is pressed
       'state 2' -> 'state 1' when o-button is pressed
]] 

sm = state_machine:new()
sm:add_state('state 1',
	     -- transition function
	     function()
		if btn(5) then
		   return 'state 2'
		else
		   return 'state 1'
		end
	     end,
	     
	     -- update function
	     function() end,
	     
	     -- draw function
	     function()
		print(sm._current_state)
		spr(1, 60, 60)
	     end
)

sm:add_state('state 2',
	     -- transition function
	     function()
		if btn(4) then
		   return 'state 1'
		else
		   return 'state 2'
		end
	     end,
	     
	     -- update function
	     function() end,
	     
	     -- draw function
	     function()
		print(sm._current_state)
		spr(2, 60, 60)
	     end
)

function _init()
   sm:set_state('state 1')
end

function _update()
   sm:update()
end


function _draw()
   cls()
   sm:draw()
end
