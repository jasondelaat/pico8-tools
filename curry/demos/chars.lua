-- a curried function to set attributes on objects
set_attribute = curry(
   3,
   function(attribute, obj, value)
      obj[attribute] = value
   end
)

-- create some new functions by partially applying the set_attribute
-- function. This "locks in" which attributes we're allowed to set on
-- our characters (player and enemies.)
set_hp = set_attribute('hp')
set_str = set_attribute('str')
set_weap = set_attribute('weap')

function is_dead(char)
   return char.hp == 0
end

attack = curry(
   2,
   function(attacker, target)
      local dmg = attacker.str * attacker.weap[2]
      target.hp -= dmg
      if target.hp < 0 then
          target.hp = 0
      end
   end
)

show_character = curry(
   2,
   function(stat_block, stat)
      if stat_block.hp <= 0 then
     color(5)
      end
      if stat == -1 then -- display all stats
     for s,v in pairs(stat_block) do
        print(s..':'..v)
     end
      elseif stat == 'weap' then
     print(stat..':'..stat_block[stat][1])
      else
     print(stat..':'..stat_block[stat])
      end
      color(6)
   end
)

-- generates a set of enemies for the player to fight.
function gen_enemies()
   local enemies = {}
   local n = rnd_int(2)
   for i=1,n do
      local new_enemy = {}
      set_hp(new_enemy, rnd_int(10))
      set_str(new_enemy, rnd_int(2))
      set_weap(new_enemy, weapon_list[rnd_int(2)])
      add(enemies, new_enemy)
   end
   return enemies
end

-- returns true if any of the enemies in the list have hp > 0
function any_alive(enemies)
   for i=1,#enemies do
      if enemies[i].hp > 0 then
          return true
      end
   end
end
