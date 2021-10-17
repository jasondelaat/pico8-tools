function vec(x, y, w)
   local v = {x=x, y=y, w=w or 0}
   setmetatable(v, _vec_meta)
   return v
end

_vec_meta = {
   __add=function(a, b)
      return vec(a.x+b.x, a.y+b.y, a.w+b.w)
   end,
   __sub=function(a, b)
      return a + -b
   end,
   __mul=function(s, v)
      return vec(s*v.x, s*v.y, s*v.w)
   end,
   __unm=function(a)
      return vec(-a.x, -a.y, -a.w)
   end,
   __len=function(a)
      return sqrt(a.x^2 + a.y^2)
   end
}

ground = sdf_line(1, 100, 0, 100)
steep = ground:rotate(20, 100, -70/360)
crater = sdf_circ(64, 90, 19.5)
hill = crater:translate(34, 20)
big_circ = sdf_circ(80, 40, 25)
para = sdf_parabola(80, 64, 0.1):rotate(64, 64, -90/360)
sq = sdf_box(75, 75, 86, 86):rotate(81, 81, 45/360)
level = ground - crater + hill + steep + big_circ
level = level:rotate(64, 64, 30/360) + para + sq
function draw_level()
   cls()
   for x=0,127 do
      for y=0,127 do
	 local d = level(x, y)
	 if d < 0 then
	    pset(x, y, abs(d)%7 + 9)
	 elseif d > 0 then
	    pset(x, y, d%7)
	 else
	    --pset(x, y, 8)
	 end
      end
   end
   memcpy(0x0000, 0x6000, 8192)
end

function _init()
   p = {
      pos = vec(10, 15),
      vel = vec(0, 0)
   }
   mode = 0
   field = fields[mode]
   pal(pallettes[mode], 1)
   draw_level()
end

right = vec(1, 0)
down = vec(0, 1)
stopped = vec(0, 0)

fields = {[0]='neither', 'interior', 'exterior', 'both'}
pallettes = {
   [0]={[0]=0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 7, 7, 7, 7, 7},
   {[0]=0, 0, 0, 0, 0, 0, 0, 0, 8, 9, 10, 11, 12, 13, 14, 15},
   {[0]=0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 7, 7, 7, 7, 7, 7},
   {[0]=0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
}
function _update60()
   if btn(0) then
      p.vel -= right
   elseif btn(1) then
      p.vel += right
   end
   if btn(2) then
      p.vel -= down
   elseif btn(3) then
      p.vel += down
   end
   if btnp(4) and not made_tunnel then
      mode = (mode + 1) % 4
      pal(pallettes[mode], 1)
      field = fields[mode]
   end
   p.pos += move_ratio()*p.vel
   p.vel = stopped
end

function move_ratio()
   local new_p = p.pos + p.vel
   d = level(new_p.x, new_p.y)
   local allowed = #p.vel
   if d <= 0 then
      return 0
   elseif d < allowed then
      return d/allowed
   else
      return 1
   end
end

function _draw()
   local x = p.pos.x
   local y = p.pos.y
   cls()
   memcpy(0x6000, 0x0000, 8192)
   circfill(x, y, 2.5, 8)
   pset(x, y, 12)
   rectfill(0, 0, 127, 7, 0)
   print('visible dist field:'..field, 0, 1, 8)
   rectfill(0, 119, 127, 127, 0)
   print('dist to nearest surface:'..d, 0, 120, 8)
end
