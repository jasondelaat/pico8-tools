intro_state = {
   update=function()
      if btnp(4) then
         pop()
      end
   end,
   draw=function()
      cls()
      print("--------------------------------")
      print("this cart demonstrates some")
      print("possible uses of curried")
      print("functions. but it's not like")
      print("that's obvious while it's")
      print("running so remember to check out")
      print("the code.")
      print("--------------------------------")
      btn2cont()
   end
}

game_over = {
   update=function()
      if btnp(4) then
         init_state_stack() -- reinitializes the stack to restart the game
      end
   end,
   draw=function()
      cls()
      print('game  over', 44, 64)
      print("press \142 to play again", 24, 120)
   end
}

function fight(enemies)
   return {
      update=function()
         if player_is_dead() then
            -- if the player is dead the fight/game is over so pop the
            -- current state off the stack.
            pop()
         elseif any_alive(enemies) then
            -- if the player and at least one enemy is alive then the
            -- fight consists of several phases and we add each to the
            -- stack
            if btnp(4) then
               push(enemy_attack_phase(enemies))
               push(under_attack(enemies))
               push(player_attack_phase(enemies))
            end 
         else
            -- if there are no enemies alive then we pop() the current
            -- fight phase and push() a new one with a new set of
            -- enemies.
            pop()
            push(fight(gen_enemies()))
            push(new_wave)
         end
      end,
      draw=function()
          cls()
          show_player('hp')
          for i=1,#enemies do
             print('\nenemy '..i)
             show_character(enemies[i], 'hp')
             show_character(enemies[i], 'weap')
          end
          print('press \142 to begin attack', 16, 118)
          cursor(128, 0)
      end
   }
end

function enemy_attack_phase(enemies)
   return {
      update=function()
          for i=1,#enemies do
             local e = enemies[i]
             if not is_dead(e) then
                attack_player(e)
             end
          end
          pop()
      end,
      draw=function()
      end
   }
end

function player_attack_phase(enemies)
   local cur = 0
   return {
      update=function()
          if btnp(2) then
             cur -= 1
          elseif btnp(3) then
             cur += 1
          end
          if btnp(4) then
             attack_enemy(enemies[cur+1])
             pop()
          end
          cur %= #enemies
      end,
      draw=function()
          rect(32, 32, 96, 96, 6)
          rectfill(33, 33, 95, 95, 0)
          print('attack enemy')
          cursor(34, 34, 6)
          for i=1,#enemies do
             if i-1==cur then
                print('> '..i)
             else
                print('  '..i)
             end
          end
      end
   }
end

-- the next two states pretty much just display messages.
new_wave = {
   update=function()
      if btnp(4) then
         pop()
      end
   end,
   draw=function()
      cls()
      print('a new wave of')
      print('enemies approaches!')
      btn2cont()
   end
}


function under_attack(enemies)
   return {
      update=function()
         if any_alive(enemies) then
            if btnp(4) then
               pop()
            end
         else
            pop()
         end
      end,
      draw=function()
         if any_alive(enemies) then
            cls()
            print('you are being attacked!')
            btn2cont()
         end
      end
   }
end
