-- a simple platformer example which transitions between various
-- states during play.

-- state names
state = {
   intro='intro',
   tut_movement='tut_movement',
   tut_jump='tut_jump',
   play='play',
   gameover='gameover'
}

-- create the state machine...
sm = state_machine:new()

-- ...and add the states
sm:add_state(
   state.intro,

   -- transition function
   function()
      if btn(5) then
	 return state.tut_movement
      else
	 return state.intro
      end
   end,
   
   -- update function
   function()
   end,
   
   -- draw function
   function()
      show_state()
      print('press ❎ to start', 30, 61, 6)
   end
)

sm:add_state(
   state.tut_movement,
   -- transition function
   function()
      if btnp(0) or btnp(1) then
	 return state.play
      else
	 return state.tut_movement
      end
   end,
   
   -- update function
   function()
   end,
   
   -- draw function
   function()
      show_state()
      show_scene()
      print('reach the flag to win!', 20, 58, 6)
      print('⬅️➡️ to move.')
   end
)

sm:add_state(
   state.play,
   -- transition function
   function()
      if x == 32 and not jump_enabled then
	 return state.tut_jump
      elseif x >= 116 and y <= 80 then
	 return state.gameover
      else
	 return state.play
      end
   end,
   
   -- update function
   function()
      if btn(0) then
	 x -= 1
	 check_collisions('left')
	 flp=true
      elseif btn(1) then
	 x += 1
	 check_collisions('right')
	 flp=false
      end
      
      if btn(5) and jump_enabled and onground then
	 vy = -4
	 onground = false
      end
      vy += gravity
      y += vy
      check_collisions('down')
   end,
   
   -- draw function
   function()
      show_state()
      show_scene()
   end
)

sm:add_state(
   state.tut_jump,
   -- transition function
   function()
      if btnp(5) then
	 return state.play
      else
	 return state.tut_jump
      end
   end,
   
   -- update function
   function()
      jump_enabled = true
   end,
   
   -- draw function
   function()
      show_state()
      show_scene()
      print('press ❎ to jump', 32, 61, 6)
   end
)

sm:add_state(
   state.gameover,
   -- transition function
   function()
      return state.gameover
   end,
   
   -- update function
   function()
   end,
   
   -- draw function
   function()
      show_state()
      show_scene()
      print('congratulations! you win!', 0, 32, 6)
   end
)

function show_state()
   print(sm._current_state, 10, 10, 7)
end

function show_scene()
   map()
   spr(5, x, y, 1, 1, flp)
end

function check_collisions(dir)
   if dir == 'left' then
      if x < 0 then
	 x = 0
      elseif fget(mget(x/8, (y+4)/8), 0) then
	 x = x + (8 - x % 8)
      end
   elseif dir == 'right' then
      if fget(mget((x+7)/8, (y+4)/8), 0) then
	 x = x - (x % 8)
      end
   elseif dir == 'down' then
      if y > 128 then
	 x = 0
	 y = 112
	 vy=0
	 onground = true
      elseif fget(mget((x+4)/8, (y+7)/8), 0) then
	 y = y - (y % 8)
	 vy = 0
	 onground = true
      end
   end
end

function _init()
   sm:set_state(state.intro)
   x = 0
   y = 112
   vy = 0
   jump_enabled = false
   onground = true
   gravity = 0.3
   flp = false
end

function _update60()
   sm:update()
end

function _draw()
   cls()
   sm:draw()
end
