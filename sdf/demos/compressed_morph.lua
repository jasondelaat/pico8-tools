-->8
-- decompression code
function _expand_dists(min_dist, width, vecs, dists)
   local sdf = {}
   local d_index = 1
   for i=1,#vecs do
      local v=vecs[i]
      if v == 0 then
	 sdf[i] = dists[d_index]
	 d_index += 1
      elseif v == 1 then
	 local d1 = sdf[i-1]
	 local d2 = sdf[i-2]
	 sdf[i] = sqrt(2*d1^2 - d2^2 + 2)
      elseif v == 2 then
	 local d1 = sdf[i-width]
	 local d2 = sdf[i-2*width]
	 sdf[i] = sqrt(2*d1^2 - d2^2 + 2)
      elseif v == 3 then
	 local d1 = sdf[i-(width+1)]
	 local d2 = sdf[i-2*(width+1)]
	 sdf[i] = sqrt(2*d1^2 - d2^2)
      end
   end
   for i=1,#sdf do
      sdf[i] += min_dist
   end
   return sdf
end

function bin_to_int(s) -- should be a 2-character string
   return (ord(s, 1) << 8) | ord(s, 2)
end

function bin_to_lst(s, bits)
   local lst={}
   local in_n = 0
   local n = 0
   for i=1,#s do
      local m = ord(s, i)
      local in_elem = 8
      while in_elem > 0 do
	 local needed = min(bits - in_n, 8)
	 local taken = min(needed, in_elem)
	 n = (n << taken) | (m >> (in_elem - taken))&(2^taken - 1)
	 in_n += taken
	 in_elem -= taken
	 if in_n == bits then
	    add(lst, n)
	    n = 0
	    in_n = 0
	 end
      end
   end
   if n != 0 then
      add(lst, n<<(bits-in_n))
   end
   return lst
end

function vdt_decompress(data)
   local min_dist = bin_to_int(sub(data, 1, 2))
   local dist_bits = ord(data, 3)
   local width = bin_to_int(sub(data, 4, 5))
   local height = bin_to_int(sub(data, 6, 7))
   local vec_length = (width*height)/4
   local vecs = bin_to_lst(sub(data, 8, 7+vec_length), 2)
   local dists = bin_to_lst(sub(data, 8+vec_length), dist_bits)
   return _expand_dists(
      min_dist,
      width,
      vecs,
      dists
   )
end

circ_field = vdt_decompress(circles)
box_field = vdt_decompress(squares)
tris_field = vdt_decompress(triangles)
star_field = vdt_decompress(star)
rot_star_field = vdt_decompress(rot_star)
line_field = vdt_decompress(line)


-->8
-- animation and related code

function constrain(n, min, max)
   if n > max then
      return max
   elseif n < min then
      return min
   else
      return n
   end
end

function field_lerp(f, g)
   return function(x, y, t)
      local d1 = f[128*y+x+1]
      local d2 = g[128*y+x+1]
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

circ_to_box = field_lerp(circ_field, box_field)
box_to_tris = field_lerp(box_field, tris_field)
tris_to_star = field_lerp(tris_field, star_field)
star_to_rot_star = field_lerp(star_field, rot_star_field)
rot_star_to_line = field_lerp(rot_star_field, line_field)

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

cls()
for t=0,1,0.125 do
   for x=0,127 do
      for y=0,127 do
	 local d = circ_field[128*y+x+1]
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

function _draw()end
