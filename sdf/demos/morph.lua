s = sdf_box(24, 24, 104, 104)
c = sdf_circ(64, 64, 40)
moon = c - sdf_circ(84, 64, 35)
star = (s + s:rotate(64, 64, 45/360)):rotate(64, 64, 22.5/360)

sdf_map_1 = {}
for x=0,127 do
   for y=0,127 do
      local d = star(x, y)
      sdf_map_1[128*y+x] = d
   end
end

sdf_map_2 = {}
for x=0,127 do
   for y=0,127 do
      local d = moon(x, y)
      sdf_map_2[128*y+x] = d
   end
end

sdf_map_3 = {}
for x=0,127 do
   for y=0,127 do
      local d = c(x, y)
      sdf_map_3[128*y+x] = d
   end
end

function lerp(a, b)
   return function(x, y, t)
      local da = a[128*y+x]
      local db = b[128*y+x]
      return da + (db - da)*t
   end
end

--img1 = lerp(c, star)
--img2 = lerp(star, moon)
img1 = lerp(sdf_map_3, sdf_map_1)
img2 = lerp(sdf_map_1, sdf_map_2)

function unclean()
   cls()
   for t=0,2,0.15 do
      addr = 0
      for y=0,127 do
	 for x=0,127,2 do
	    local col = 0
	    for i=1,0,-1 do
	       local d = t <= 1 and img1(x+i, y, t) or img2(x+i, y, t-1)
	       if abs(d) < 0.5 then
		  col = col | 7
		  --pset(x, y, 7)
	       elseif abs(d) < 1.2 then
		  col = col | 10
		  --pset(x, y, 10)
	       elseif abs(d) < 2 then
		  col = col | 9
		  --pset(x, y, 9)
	       elseif abs(d) < 3.5 then
		  col = col | 8
		  --pset(x, y, 8)
	       end
	       if i == 1 then
		  col = col << 4
	       end
	    end
	    poke(addr, col)
	    addr += 1
	 end
      end
      memcpy(0x6000, 0, 8192)
      flip()
   end
end

function clean()
   cls()
   for y=0,127 do
      for x=0,127 do
	 local d = img2(x, y, 1)
	 if abs(d) < 0.5 then
	    pset(x, y, 7)
	 elseif abs(d) < 1.2 then
	    pset(x, y, 10)
	 elseif abs(d) < 2 then
	    pset(x, y, 9)
	 elseif abs(d) < 3.5 then
	    pset(x, y, 8)
	 end
      end
   end
end

unclean()
--clean()
print(stat(0))

function _draw()end
