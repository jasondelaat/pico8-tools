-- sdf definitions
ln = sdf_line(0, 7, 1, 7)
tris_func = ln - ln:rotate(10, 7, -60/360) - ln:rotate(-10, 7, 60/360)
td = tris_func._dist
tris_func._dist=function(x, y)
   return td((x%32)-16, (y%32)-16)
end

box_func = sdf_box(-10, -10, 10, 10)
bd = box_func._dist
box_func._dist=function(x, y)
   return bd((x%32)-16, (y%32)-16)
end

sq = sdf_box(32, 32, 96, 96)
star_func = sq + sq:rotate(64, 64, 45/360)

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

sdfs = {
   [0]=box_func,
   tris_func,
   star_func,
   palm_func
}

-- rendering modes
function field(x, y, d)
   return d
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
   local sd = sdf_table[128*(y-3)+x-4]
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
modes = {
   [0] = field,
   bw,
   drop_shadow,
   neon
}

-- main program
function do_compression()
   dat = vdt_compress(sdfs[sdf], 128, 128)
   dat_len = #dat
   sdf_table = vdt_decompress(dat)
   render(sdf_table, modes[mode])
end

function _init()
   mode = 0
   sdf = 0
   timer = 0
   do_compression()
end

function _update()
   timer += 1
   if timer%240 == 0 then
      sdf = (sdf + 1) % 4
      do_compression()
   end
   if timer%60 == 0 then
      mode = (mode + 1) % 4
      render(sdf_table, modes[mode])
   end
end

function _draw()
   print(
      'bytes:'..dat_len..' ratio:'..(100*(dat_len/16384))..'%',
      3, 119, 7
   )
end

function render(sdf, clr)
   cls()
   for x=0,127 do
      for y=0,117 do
	 local d = sdf[128*y+x+1]
	 local c = clr(x, y, d)
	 pset(x, y, c)
      end
   end
   flip()
end

