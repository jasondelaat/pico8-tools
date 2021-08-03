function _init()
   onground = true
   jumping = false
   y = 120
   vy = 0
   ay = 0

   -- tune these --------------------------------------------
   max_height = -16            -- height
   gravity = 0.15              -- grav
   initial_acceleration = -0.3 -- acc
   alpha = 0                   -- alpha
   ----------------------------------------------------------

   -- delete this stuff -------------------------------------
   calc_alpha()
   cursor_pos = 0
   actual_height = 120
   frame = 3
   t=0
   ----------------------------------------------------------
end

function _update60()
   -- jump handling code --------
   if btn(5) and onground then
      actual_height = 120 -- this can be deleted
      t = 0
      ay = initial_acceleration
      onground = false
      jumping = true
   elseif btn(5) and jumping then
      ay += alpha
      if ay > gravity then
	 ay = gravity
	 jumping = false
      end
   else
      ay = gravity
      jumping = false
   end
   -- animation stuff can be deleted --
   if vy > 0 then
      frame = 8
   elseif vy < 0 then
      frame = 7
   else
      frame += 1 / 15
      if frame > 7 then
	 frame = 3
      end
   end
   -- end animation -------------------
   vy += ay
   y += vy
   if y > 120 then
      y = 120
      vy = 0
      onground = true
   end
   -- end jump code -------------------

   -- delete this ---------------------
   if y < actual_height then
      actual_height = y
   end
   if not onground then
      t += 1
   end
   if btnp(2) then
      cursor_pos = (cursor_pos - 1) % 3
   elseif btnp(3) then
      cursor_pos = (cursor_pos + 1) % 3
   elseif btnp(0) then
      decrement_value(cursor_pos)
   elseif btnp(1) then
      increment_value(cursor_pos)
   end
   ------------------------------------
end

-- delete this stuff too ------------------------
function _draw()
   cls()
   map()
   for i=0,14 do
      print(120 - 8*i, 3, 8*i + 2, 7)
   end
   print('height:'..max_height, 52, 2)
   print('grav:'..gravity)
   print('acc:'..initial_acceleration)
   print('alpha:'..alpha)
   print('---------------')
   print('actual height:'..(120 - actual_height))
   print('jump time:'..t)
   cur_y = 2 + cursor_pos * 6
   spr(2, 47, cur_y)
   spr(2, 94, cur_y, 1, 1, true)
   spr(frame, 42, y)

end

function magic(y)
   local a = initial_acceleration
   local g = gravity
   local h = max_height
   local X = sqrt((6 * y) / (2 * a + g))
   local Y = 2 * sqrt(-2 * (h - y) * g) / (a + g)
   return X + Y
end

function calc_y()
   local s = max_height
   local e = 0
   local mid, v
   while true do
      mid = 0.5 * (s + e)
      v = magic(mid)
      if abs(v) <= 0.01 then
	 return mid
      elseif v * magic(s) > 0 then
	 s = mid
      else
	 e = mid
      end
   end
end

function calc_alpha()
   local y1 = calc_y()
   local t1 = sqrt((6 * y1) / (2 * initial_acceleration + gravity))
   alpha = (gravity - initial_acceleration) / t1
end

function increment_value(v)
   if v == 0 then
      max_height -= 1
   elseif v == 1 then
      gravity += 0.05
   elseif v == 2 then
      initial_acceleration -= 0.05
   end
   calc_alpha()
end

function decrement_value(v)
   if v == 0 then
      max_height += 1
   elseif v == 1 then
      gravity -= 0.05
   elseif v == 2 then
      initial_acceleration += 0.05
   end
   calc_alpha()
end
-------------------------------------------------
