c = sdf_circ(0, 0, 32)
cd = c._dist
c._dist = function(x, y)
   return cd(x, 1.1*y + abs(x)*sqrt((50 + abs(x))/100))
end
img = c
img = img:translate(64, 70)

function _init()
   px = 10
   py = 10
   vx = 0
   vy = 0
end

function _update60()
   if btn(0) then
      vx = -1
   elseif btn(1) then
      vx = 1
   else
      vx = 0
   end
   if btn(2) then
      vy = -1
   elseif btn(3) then
      vy = 1
   else
      vy = 0
   end
   local f = move_factor()
   px += f*vx
   py += f*vy
end

function move_factor()
   local x = px + vx
   local y = py + vy
   local d = img(x, y)
   if d < 6 then
      return 0
   else
      return 1
   end
end

function _draw()
   cls()
   memcpy(0x6000, 0x0000, 8192)
   circfill(px, py, 3, 8)
end
