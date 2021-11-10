function _init()
   triangles = vdt_decompress(triangles, false)
   render(triangles, bw)
   mode = bw
end

function _update()
   local old_mode = mode
   local b = btnp(5)
   if b and mode == bw then
      mode = multi_color
   elseif b and mode == multi_color then
      mode = drop_shadow
   elseif b and mode == drop_shadow then
      mode = neon
   elseif b then
      mode = bw
   end
   if mode != old_mode then
      render(triangles, mode)
   end
end

function _draw()end

function render(sdf, clr)
   for x=0,127 do
      for y=0,127 do
	 local d = sdf[128*y+x+1]
	 local c = clr(x, y, d)
	 pset(x, y, c)
      end
   end
   flip()
end

function bw(x, y, d)
   if d < 0 then
      return 7
   else
      return 0
   end
end

function multi_color(x, y, d)
   if d < 0 then
      x = flr(x / 33)
      y = flr(y / 33)
      return 4*y+x
   else
      return 0
   end
end

function drop_shadow(x, y, d)
   local sd = triangles[128*(y-3)+x-4]
   if sd and sd < 0 and d >= 0 then
      return 0
   end
   if d < 0 then
      return 3
   else
      return 6
   end
end

function neon(x, y, d)
   d = abs(d)
   if d < 0.5 then
      return 7
   elseif d < 1 then
      return 14
   elseif d < 2 then
      return 13
   elseif d < 3 then
      return 2
   else
      return 0
   end
end
