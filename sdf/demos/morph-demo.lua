cls()
print('loading...please wait')

function constrain(n, min, max)
   if n > max then
      return max
   elseif n < min then
      return min
   else
      return n
   end
end

-- just an approximation. nowhere near as accurate but much faster and
-- good enough for my purposes.
_squares = {1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121}
function fast_sqrt(n)
   for i=11,1,-1 do
      local s = _squares[i]
      if s < n then
	 return i + (n - s)/(2*i + 1)
      end
   end
   return 0
end

function convert(f)
   local field={}
   for x=0,127 do
      for y=0,127 do
	 field[128*y+x] = f(x, y)
      end
   end
   return field
end

function field_lerp(f, g)
   return function(x, y, t)
      local d1 = f[128*y+x]
      local d2 = g[128*y+x]
      return d1 + (d2 - d1)*t
   end
end

function color_lerp(c, d)
   return function(x, y, dist, t)
      local col1 = c(x, y, dist)
      local col2 = d(x, y, dist)
      return col1 + (col2 - col1)*t
   end
end

function render(interp_func, color_func, t)
   local addr = 0
   for y=0,127 do
      for x=0,127,4 do
	 local col = 0
	 for i=3,0,-1 do
	    local d = interp_func(x+i, y, t)
	    col = col | flr(color_func(x+i, y, d, t))
	    if i != 0 then
	       col = col<<4
	    end
	 end
	 poke2(addr, col)
	 addr += 2
      end
   end
   memcpy(0x6000, 0, 8192)
   flip()
end

ln = sdf_line(0, 7, 1, 7)
tris_func = ln - ln:rotate(10, 7, -60/360) - ln:rotate(-10, 7, 60/360)
td = tris_func._dist
tris_func._dist=function(x, y)
   return td((x%32)-16, (y%32)-16)
end
tris_field = convert(tris_func)

circ_func = sdf_circ(0, 0, 2.5)
cd = circ_func._dist
circ_func._dist=function(x, y)
   return cd((x%32)-16, (y%32)-16)
end
circ_field = convert(circ_func)

box_func = sdf_box(-10, -10, 10, 10)
bd = box_func._dist
box_func._dist=function(x, y)
   return bd((x%32)-16, (y%32)-16)
end
box_field = convert(box_func)

sq = sdf_box(32, 32, 96, 96)
star_func = sq + sq:rotate(64, 64, 45/360)
star_field = convert(star_func)
rot_star_field = convert(star_func:rotate(64, 64, 22.5/360))

line_field = convert(-ln:translate(0, 57))

-- the sdf for this image adapted from 'the principles of painting with math' by inigo quilez: https://www.youtube.com/watch?v=0ifChJ0nJfM&t=1155s
s = sdf_box(-0.01, 0, 0.01, 0.5)
sd = s._dist
s._dist = function(x, y)
   local p = x/128
   local q = y/128
   p += -0.3*sin(0.4*q)
   p += 0.007*cos(25*q)
   p *= (3*(0.5 - y/128))^1.1
   local d = sd(p, q)
   return 128*d
end

sw = s:translate(0, 0) -- hacky way to make a copy...
swd = sw._dist
sw._dist=function(x, y)
   return swd(x - ((y-64)/28)^2, y)
end

c = sdf_circ(0, 0, 0.2)
cd = c._dist
c._dist=function(x, y)
   local p = x/128
   local q = y/128
   local d = cd(p, q) + 0.1*cos(10*atan2(p, q) + 7*p + 0.65)
   return 128*d
end
palm_func = s + c
palm_func = palm_func:translate(64, 64)
palm_field = convert(palm_func)
sway_palm_func = (c:translate(0.25, 0.5) + sw):translate(64, 64)
sway_palm_field = convert(sway_palm_func)

circ_to_box = field_lerp(circ_field, box_field)
box_to_tris = field_lerp(box_field, tris_field)
tris_to_star = field_lerp(tris_field, star_field)
star_to_rot_star = field_lerp(star_field, rot_star_field)
rot_star_to_line = field_lerp(rot_star_field, line_field)
line_to_palm = field_lerp(line_field, palm_field)

function circ_color(x, y, d)
   if d < 0 then
      return 12
   else
      return 1
   end
end

function box_color(x, y, d)
   if d < 0 then
      return 14
   else
      return 2
   end
end

function tris_color(x, y, d)
   if d < 0 then
      return 11
   else
      return 3
   end
end

function star_color(x, y, d)
   d = abs(d)
   if d < 0.5 then
      return 7
   elseif d < 1 then
      return 12
   elseif d < 2 then
      return 13
   elseif d < 4 then
      return 1
   else
      return 3
   end
end

function rot_star_color(x, y, d)
   d = abs(d)
   if d < 0.5 then
      return 7
   elseif d < 1 then
      return 10
   elseif d < 2 then
      return 9
   elseif d < 4 then
      return 8
   else
      return 1
   end
end

function line_color(x, y, d)
   if d < 0 then
      return 0
   else
      return constrain(ceil(0.0014*d*d - 0.037*d + 7.1), 8, 10)
   end
end

function palm_color(x, y, d)
   local n = constrain(fast_sqrt(x*(128-y))/128, 0, 1)
   if d > 0 then
      return flr(8 + 2*n)
   else
      return 0
   end
end

print('mem usage:'..stat(0))
stop()

cls()
for t=0,1,0.125 do
   for x=0,127 do
      for y=0,127 do
	 local d = circ_field[128*y+x]
	 pset(x, y, circ_color(x, y, d))
      end
   end
end
for t=0,1,0.125 do
   render(circ_to_box, color_lerp(circ_color, box_color), t)
end

for t=0,1,0.125 do
   render(box_to_tris, color_lerp(box_color, tris_color), t)
end

for t=0,1,0.125 do
   render(tris_to_star, color_lerp(tris_color, star_color), t)
end

for t=0,-1,-0.125 do
   render(star_to_rot_star, star_color, t)
end

for t=-1,2,0.125 do
   render(star_to_rot_star, rot_star_color, t)
end

for t=2,-1,-0.125 do
   render(star_to_rot_star, star_color, t)
end

for t=-1,1,0.125 do
   render(star_to_rot_star, rot_star_color, t)
end

for t=0,1,0.125 do
   render(rot_star_to_line, color_lerp(rot_star_color, line_color), t)
end

for t=0,1,0.0625 do
   render(line_to_palm, color_lerp(line_color, palm_color), t)
end

t = 0
while true do
   t += 0.05
   render(field_lerp(palm_field, sway_palm_field), palm_color, sin(t))
end

