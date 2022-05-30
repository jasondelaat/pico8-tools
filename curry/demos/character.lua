character = {
   update=function()
      if btnp(4) then
     pop()
      end
   end,
   draw=function()
      cls()
      print("character creation")
      print("------------------\n")
      --print("--------------------------------")
      print("you'll create a simple chracter")
      print("with 3 stats-strength, weapon")
      print("and health-and then 'fight' some")
      print("'monsters.'\n")
      print("play a few times to see how the")
      print("stats affect your actions.")
      btn2cont()
   end
}

-- allows the player to choose their character's strength
strength = {
   cursor=0,
   update=function()
      if btnp(2) then
     strength.cursor -= 1
      elseif btnp(3) then
     strength.cursor += 1
      end
      strength.cursor %= 10
      if btnp(4) then
     -- since this has already been partially applied with both
     -- the attribute string ("str") and the player table we only
     -- need to pass in the strength value itself.
     set_player_str(strength.cursor + 1)
     pop()
      end
   end,
   draw=function()
      cls()
      print("strength")
      print("--------\n")
      for i=1,10 do
     if i-1==strength.cursor then
        print("> \0")
     else
        print("  \0")
     end
     print(i)
      end
      btn2cont()
   end
}

-- allows the player to choose their character's health
health = {
   cursor = 0,
   update=function()
      if btnp(2) then
     health.cursor -= 1
      elseif btnp(3) then
     health.cursor += 1
      end
      health.cursor %= 10
      if btnp(4) then
     set_player_hp(health.cursor + 1)
     pop()
      end
   end,
   draw=function()
      cls()
      print("health")
      print("------\n")
      for i=1,10 do
     if i-1==health.cursor then
        print("> \0")
     else
        print("  \0")
     end
     print(i)
      end
      btn2cont()
   end
}

-- allows the player to choose their character's weapon
weapon = {
   cursor=0,
   update=function()
      if btnp(2) then
     weapon.cursor -= 1
      elseif btnp(3) then
     weapon.cursor += 1
      end
      weapon.cursor %= 4
      if btnp(4) then
     set_player_weap(weapon_list[weapon.cursor + 1])
     pop()
     push(fight(gen_enemies()))
      end
   end,
   draw=function()
      cls()
      print("weapon")
      print("------\n")
      for i=1,4 do
     if i-1==weapon.cursor then
        print("> \0")
     else
        print("  \0")
     end
     print(i..'. '..weapon_list[i][1])
      end
      btn2cont()
   end
}

-- a list of weapons and their damage multipliers
weapon_list = {
   {"bare hands", 1},
   {"board with a nail (rusty)", 2},
   {"big pointy tree branch", 3},
   {"sword", 4}
}
