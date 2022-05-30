function _init()
   init_state_stack(true)
   init_player()
end

function init_state_stack(include_intro)
   -- initial state machine stack. The last entry is the top of the
   -- stack. See the 'states' tab for the game state definitions.
   local state_stack = {
      game_over,
      weapon,
      health,
      strength
   }
   if include_intro then
      extend(state_stack, {character, intro_state})
   end

   -- partially applying (or deferring in the case of _pop and _top)
   -- the stack functions is an example of dependency injection: the
   -- stack functions depend on a stack and we pass it in here. But
   -- once state_stack goes out of scope at the end of the function it
   -- will no longer be directly accessible anywhere else in the
   -- program. We'll only be able to manipulate the stack via the
   -- functions push, pop, and top (no underscore.)
   push = _push(state_stack)
   pop = _pop(state_stack)
   top = _top(state_stack)
end

function init_player()
   local plr = {}

   -- here we partially apply the plr table to the already partially
   -- applied set_* functions to create setter functions specific to
   -- the player table.
   set_player_hp = set_hp(plr)
   set_player_str = set_str(plr)
   set_player_weap = set_weap(plr)

   -- we then partially apply the attack function in two different
   -- ways: first, a straight partial application to create a function
   -- for attacking enemies.
   attack_enemy = attack(plr)

   -- then a partial application with the parameters swapped (see
   -- utilities tab) to create a function for attacking the player.
   attack_player = swap(attack)(plr)

   -- then we partially apply/defer a couple more functions to fully
   -- encapsulate the plr table. just like with state_stack above,
   -- when plr goes out of scope we'll no longer be able to manipulate
   -- it directly anywhere else in the program and will only be able
   -- to manipulate it via the functions defined here.
   show_player = show_character(plr)
   player_is_dead = defer(is_dead)(plr)
end

function _update()
   -- notice that there's no way to manipulate state_stack directly
   -- because it's not in scope (it's local to init_state_stack)
   if state_stack then
      print('this should never run')
      print('because the only way to access')
      print('the state stack is through the')
      print('functions push, pop, and top.')
      stop()
   end
   top().update() -- run the current state's update function
end

function _draw()
   top().draw() -- run the current state's draw function
end
